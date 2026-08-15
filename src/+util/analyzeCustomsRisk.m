function resultTable = analyzeCustomsRisk(customsData, rules, generalSettings)
    arguments
        customsData table
        rules struct
        generalSettings struct
    end

    % Prealoca as colunas de saída e processa cada descrição em paralelo.
    numRows = height(customsData);
    remessaDescricao = customsData.("remessaDescricao");

    numRegrasAvaliadas = zeros(numRows, 1, 'uint32');
    regraId = zeros(numRows, 1);
    regraCategoria = cell(numRows, 1);
    regraDecisaoSugerida = cell(numRows, 1);
    regraConfianca = cell(numRows, 1);
    regraMotivo = cell(numRows, 1);
    regraPalavrasEncontradas = cell(numRows, 1);

    parpoolCheck()
    parfor ii = 1:numRows
        result = analyzeDescriptionAgainstRules(remessaDescricao{ii}, rules);

        numRegrasAvaliadas(ii) = result.rulesEvaluated;
        regraId(ii) = result.ruleId;
        regraCategoria{ii} = result.category;
        regraDecisaoSugerida{ii} = result.suggestedDecision;
        regraConfianca{ii} = result.confidence;
        regraMotivo{ii} = result.reason;
        regraPalavrasEncontradas{ii} = textFormatGUI.cellstr2FriendlyListWithQuotes([result.foundTerms(:); result.foundBoosters(:)]);
    end

    resultTable = customsData;
    
    resultTable.("numRegrasAvaliadas") = numRegrasAvaliadas;
    resultTable.("regraId") = categorical(regraId);
    resultTable.("regraCategoria") = categorical(regraCategoria);
    resultTable.("regraDecisaoSugerida") = categorical(regraDecisaoSugerida);
    resultTable.("regraConfianca") = categorical(regraConfianca);
    resultTable.("regraMotivo") = categorical(regraMotivo);
    resultTable.("regraPalavrasEncontradas") = regraPalavrasEncontradas;

    % Inicializa campos de estado e auditoria com os valores padrão definidos 
    % no arquivo de configuração. "estadoRevisao" e "estadoVistoria" são
    % derivados por model.Project.updateCustomsShipments('statusColumns', ...).
    resultTable.("estadoAmostragem")(:) = generalSettings.context.CUSTOMS.estadoAmostragem.default;
    resultTable.("auditorDataHora")(:) = {''};
    resultTable.("auditorDecisaoFinal")(:) = generalSettings.context.CUSTOMS.auditorDecisaoFinal.default;
    resultTable.("auditorNota")(:) = {''};

    % Sorteia remessas cuja "regraDecisaoSugerida" for diferente de "Vistoria" 
    % para compor a amostra de vistoria. 
    resultTable = selectInspectionSample(resultTable, generalSettings);
end

%-------------------------------------------------------------------------%
function resultTable = selectInspectionSample(resultTable, generalSettings)
    samplingRate = generalSettings.context.CUSTOMS.amostragemVistoria;
    if samplingRate < 0 || samplingRate > 1
        error('analyzeCustomsRisk:invalidSamplingRate', 'A taxa de amostragem precisa estar entre 0 e 1')
    end

    eligibleMask = resultTable.regraDecisaoSugerida ~= "Vistoria";
    eligibleIdxs = find(eligibleMask);
    eligibleIdxsCount = numel(eligibleIdxs);

    resultTable.("estadoAmostragem")(eligibleMask) = "Não selecionada";

    samplingSize = round(samplingRate * eligibleIdxsCount);
    selectedIdxs = eligibleIdxs(randperm(eligibleIdxsCount, samplingSize));
    resultTable.("estadoAmostragem")(selectedIdxs) = "Selecionada";
end

%-------------------------------------------------------------------------%
function result = analyzeDescriptionAgainstRules(description, rules)
    normalizedDescription = textAnalysis.normalizeWords(description, 'pt_eng');

    if isempty(normalizedDescription)
        result = buildResult( ...
            'description', description, ...
            'category', 'n/a', ...
            'reason', 'Descrição não informada.' ...
        );
        return
    end

    bestResult = [];
    rulesEvaluated = 0;

    for ii = 1:numel(rules)
        rule = rules(ii);
        rulesEvaluated = rulesEvaluated + 1;

        foundExceptions = findMatchingTerms(normalizedDescription, rule.palavras_excecao);
        if ~isempty(foundExceptions)
            continue
        end

        foundTerms = findMatchingTerms(normalizedDescription, rule.palavras_chave);
        if isempty(foundTerms)
            continue
        end

        foundBoosters = findMatchingTerms(normalizedDescription, rule.palavras_reforco);

        score = numel(foundTerms) * rule.peso + numel(foundBoosters);

        candidate = buildResult( ...
            'hasMatch', true, ...
            'description', description, ...
            'ruleName', rule.nome, ...
            'ruleId', rule.id, ...
            'suggestedDecision', rule.decisao_sugerida, ...
            'confidence', rule.confianca, ...
            'category', rule.categoria, ...
            'score', score, ...
            'reason', rule.motivo, ...
            'foundTerms', foundTerms, ...
            'foundBoosters', foundBoosters, ...
            'priority', rule.prioridade, ...
            'weight', rule.peso, ...
            'rulesEvaluated', rulesEvaluated ...
        );

        if isempty(bestResult)
            bestResult = candidate;
        else
            bestResult = pickBestCandidate(candidate, bestResult);
        end
    end

    if isempty(bestResult)
        result = buildResult( ...
            'description', description, ...
            'category', 'n/a', ...
            'reason', sprintf('Incompatível com todas as %d regras.', rulesEvaluated), ...
            'rulesEvaluated', rulesEvaluated ...
        );
    else
        bestResult.rulesEvaluated = rulesEvaluated;
        result = bestResult;
    end
end

%-------------------------------------------------------------------------%
% Única fonte de verdade para o formato de "result", garantindo que todo
% caminho (vazio ou com regra aplicada) produza a mesma assinatura de campos.
%-------------------------------------------------------------------------%
function result = buildResult(varargin)
    result = struct( ...
        'hasMatch', false, ...
        'description', '', ...
        'ruleName', '', ...
        'ruleId', -1, ...
        'suggestedDecision', 'Vistoria', ...
        'confidence', '-', ...
        'category', '', ...
        'score', 0, ...
        'reason', '', ...
        'foundTerms', {{}}, ...
        'foundBoosters', {{}}, ...
        'foundExceptions', {{}}, ...
        'priority', -1, ...
        'weight', -1, ...
        'rulesEvaluated', 0 ...
    );

    for ii = 1:2:numel(varargin)
        result.(varargin{ii}) = varargin{ii+1};
    end
end

%-------------------------------------------------------------------------%
function found = findMatchingTerms(normalizedDescription, termList)
    if isempty(termList)
        found = {};
        return
    end

    mask = cellfun(@(x) contains(normalizedDescription, x), termList);
    found = termList(mask);
end

%-------------------------------------------------------------------------%
% Critérios de desempate entre candidatos:
% (1) menor prioridade vence
% (2) empate: maior pontuacao
% (3) empate: maior peso
% (4) empate: mais termos-chave
%-------------------------------------------------------------------------%
function best = pickBestCandidate(candidate, current)
    best = current;

    if candidate.priority < current.priority
        best = candidate;
        return
    end

    if candidate.priority == current.priority
        if candidate.score > current.score
            best = candidate;
            return
        end

        if candidate.score == current.score
            if candidate.weight > current.weight
                best = candidate;
                return
            end

            if candidate.weight == current.weight && numel(candidate.foundTerms) > numel(current.foundTerms)
                best = candidate;
            end
        end
    end
end