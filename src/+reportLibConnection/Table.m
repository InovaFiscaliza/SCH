classdef (Abstract) Table
    methods (Static)
        %-----------------------------------------------------------------%
        function tbl = InspectedProducts(inspectedProducts, configTable, legalSituation)
            arguments
                inspectedProducts table
                configTable       struct
                legalSituation    string {mustBeMember(legalSituation, ["any", "Irregular", "Regular"])} = "any"
            end
        
            % A tabela "inspectedProducts" possui mais de vinte colunas - 'Homologação', 
            % 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?',
            % 'Valor Unit. (R$)', 'Fonte do valor', 'Qtd. uso', 'Qtd. vendida' etc.        
            if ismember(legalSituation, ["Irregular", "Regular"])
                idx = string(inspectedProducts.("Situação")) == legalSituation;
                inspectedProducts = inspectedProducts(idx, :);
            end
        
            % Na presente função, criam-se cinco colunas calculadas:
            % - "#" 
            % - "Produto"
            % - "Qtd. vistoriadas"
            % - "Mercadoria retida (R$)"
            % - "Mercadoria vendida (R$)"        
            inspectedProducts.("#") = (1:height(inspectedProducts))';

            inspectedProducts.("Produto") = ...
                "HOMOLOGAÇÃO: <b>" + string(inspectedProducts.("Homologação")) + "</b><br>" + ...
                "TIPO: <b>"        + string(inspectedProducts.("Tipo"))        + "</b><br>" + ...
                "SUBTIPO: <b>"     + string(inspectedProducts.("Subtipo"))     + "</b><br>" + ...
                "FABRICANTE: <b>"  + string(inspectedProducts.("Fabricante"))  + "</b><br>" + ...
                "MODELO: <b>"      + string(inspectedProducts.("Modelo"))      + "</b>";
            
            inspectedProducts.("Qtd. vistoriadas") = inspectedProducts.("Qtd. uso") + inspectedProducts.("Qtd. vendida") + inspectedProducts.("Qtd. estoque/aduana") + inspectedProducts.("Qtd. anunciada");
            inspectedProducts.("Mercadoria retida (R$)") = inspectedProducts.("Valor Unit. (R$)") .* double(inspectedProducts.("Qtd. lacradas") + inspectedProducts.("Qtd. apreendidas") + inspectedProducts.("Qtd. retidas (RFB)"));
            inspectedProducts.("Mercadoria vendida (R$)") = inspectedProducts.("Valor Unit. (R$)") .* double(inspectedProducts.("Qtd. vendida"));
        
            % Por fim, são realizadas algumas transformações nos dados, como substituição 
            % de true por "Sim" e "\n" por "<br>".        
            for ii = 1:width(inspectedProducts)
                columnName = inspectedProducts.Properties.VariableNames{ii};
        
                switch columnName
                    case 'Informações adicionais'
                        for jj = 1:numel(inspectedProducts.("Informações adicionais"))
                            currentValue = inspectedProducts.("Informações adicionais"){jj};
        
                            if ~isempty(currentValue) && (ischar(currentValue) || (isstring(currentValue) && isscalar(currentValue)))
                                inspectedProducts.("Informações adicionais"){jj} = replace(currentValue, newline, '<br>');
        
                            elseif iscellstr(currentValue)
                                inspectedProducts.("Informações adicionais"){jj} = replace(strjoin(currentValue, '<br>'), newline, '<br>');
                            end
                        end
        
                    otherwise
                        if islogical(inspectedProducts.(columnName))
                            inspectedProducts.(columnName) = reportLib.Constants.logical2String(inspectedProducts.(columnName), 'cellstr');
                        end
                end
            end 
        
            % A tabela renderizada no arquivo .HTML possuirá todas as linhas da tabela
            % "listOfProducts", mas apenas as colunas definidas no arquivo .JSON que 
            % alimenta a lib "reportLib".        
            tbl = inspectedProducts(:, configTable.Columns);
        end

        %-----------------------------------------------------------------%
        function tbl = Summarized(inspectedProducts, configTable, legalSituation)
            arguments
                inspectedProducts table
                configTable       struct
                legalSituation    string {mustBeMember(legalSituation, ["any", "Irregular", "Regular"])} = "any"
            end
        
            % A tabela "inspectedProducts" possui mais de vinte colunas - 'Homologação', 
            % 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?',
            % 'Valor Unit. (R$)', 'Fonte do valor', 'Qtd. uso', 'Qtd. vendida' etc.        
            if ismember(legalSituation, ["Irregular", "Regular"])
                idx = string(inspectedProducts.("Situação")) == legalSituation;
                inspectedProducts = inspectedProducts(idx, :);
            end
        
            % Na presente função, sumariza-se "inspectedProducts" em função dos valores
            % de uma das suas colunas.        
            columnName   = configTable.Settings(1).ColumnName;
            columnClass  = class(inspectedProducts.(columnName));
            columnValues = inspectedProducts.(columnName);
        
            if ismember(columnClass, {'string', 'categorical'})
                columnValues = cellstr(inspectedProducts.(columnName));
            end
        
            tbl = table( ...
                'Size', [0, 6], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'double', 'double'}, ...
                'VariableNames', {configTable.Settings.ColumnName} ...
            );   
        
            [uniqueValues, ~, uniqueValuesIndex] = unique(columnValues, 'stable');
            for ii = 1:numel(uniqueValues)
                idx = find((ii == uniqueValuesIndex));
        
                pricePerProductStr  = {};
                for jj = idx'
                    pricePerProductStr{end+1} = sprintf('R$ %.2f (#%d)', inspectedProducts.("Valor Unit. (R$)")(jj), jj);
                end
                pricePerProductStr  = strjoin(pricePerProductStr, '<br>');
        
                unitPricePerProduct = inspectedProducts.("Valor Unit. (R$)")(idx);
                quantityPerProduct  = double(inspectedProducts.("Qtd. lacradas")(idx) + inspectedProducts.("Qtd. apreendidas")(idx) + inspectedProducts.("Qtd. retidas (RFB)")(idx));
                totalPrice = sum(unitPricePerProduct .* quantityPerProduct);
        
                if sum(quantityPerProduct)
                    meanPrice = sprintf('R$ %.2f', totalPrice/sum(quantityPerProduct));
                else
                    meanPrice = '-';
                end
        
                tbl(ii,:) = {
                    uniqueValues{ii}, ...
                    pricePerProductStr, ...
                    char(strjoin(string(quantityPerProduct) + " (#" + string(idx) + ")", '<br>')), ...
                    meanPrice, ...
                    sum(quantityPerProduct), ...
                    totalPrice ...
                };
            end
        end

        %-----------------------------------------------------------------%
        function tbl = CustomsShipments(customsShipments, configTable, finalDecision, summarizeValues)
            arguments
                customsShipments struct
                configTable struct
                finalDecision {mustBeMember(finalDecision, {'any', 'Perdimento', 'Devolução', 'Prazo', 'Liberado'})} = 'any'
                summarizeValues (1,1) logical = false
            end

            customsData = customsShipments.Data;
        
            % A tabela "customsShipments" possui dezesseis colunas - 'remessaCodigo',
            % 'remessaImportador', 'remessaDescricao', 'numRegrasAvaliadas',
            % 'regraId', 'regraCategoria' 'regraDecisaoSugerida', 'regraConfianca',
            % 'regraMotivo', 'regraPalavrasEncontradas', 'estadoAmostragem',
            % 'estadoRevisao', 'estadoVistoria', 'auditorDataHora', 'auditorDecisaoFinal'
            % e 'auditorNota'.

            % Atualmente é previsto aplicar filtragem apenas pela decisão
            % final do auditor.
            if ~strcmp(finalDecision, 'any')
                customsData(customsData.("auditorDecisaoFinal") ~= finalDecision, :) = [];
            end
        
            % Na presente função, criam-se três colunas calculadas:
            % - "#"
            % - "Situação"
            % - "Sanável?"
            customsData.("#") = (1:height(customsData))';

            customsData.("Situação")(:) = "-";
            customsData.("Situação")(customsData.("auditorDecisaoFinal") == "Liberado") = "Regular";
            customsData.("Situação")(ismember(customsData.("auditorDecisaoFinal"), ["Prazo", "Devolução", "Perdimento"])) = "Irregular";

            customsData.("Sanável?")(:) = "-";
            customsData.("Sanável?")(customsData.("auditorDecisaoFinal") == "Prazo") = "Sim";
            customsData.("Sanável?")(ismember(customsData.("auditorDecisaoFinal"), ["Devolução", "Perdimento"])) = "Não";

            % Quando "summarizeValues" é true, as remessas são agrupadas por
            % "auditorDecisaoFinal", consolidando os códigos de remessa de
            % cada grupo em uma única linha (célula "remessaCodigo").
            if ~summarizeValues
                tbl = customsData;

            else
                summaryColumns = {'auditorDecisaoFinal', 'Situação', 'Sanável?'};
                [uniqueFinalDecisions, firstRowIdxPerDecision, decisionGroupIdx] = unique(cellstr(customsData.("auditorDecisaoFinal")));
                summarizedCustomsData = customsData(firstRowIdxPerDecision, summaryColumns);

                for ii = 1:numel(uniqueFinalDecisions)
                    rowIdxsInGroup = find(decisionGroupIdx == ii);
                    remessaCodigoList = sort(customsData.("remessaCodigo")(rowIdxsInGroup));

                    if isscalar(rowIdxsInGroup)
                        remessaCodigoList = char(remessaCodigoList);
                    else
                        remessaCodigoList = strjoin({strjoin(remessaCodigoList(1:end-1), ", "), remessaCodigoList{end}}, " e ");
                    end

                    summarizedCustomsData.("numRemessas")(ii) = numel(rowIdxsInGroup);
                    summarizedCustomsData.("remessas"){ii} = remessaCodigoList;
                end
                summarizedCustomsData = sortrows(summarizedCustomsData, 'numRemessas', 'descend');

                tbl = summarizedCustomsData;
            end
        
            % A tabela renderizada no arquivo .HTML possuirá todas as linhas da tabela
            % "customsShipments.Data", mas apenas as colunas definidas no arquivo .JSON que 
            % alimenta a lib "reportLib".        
            tbl = tbl(:, configTable.Columns);
        end

        %-----------------------------------------------------------------%
        % TABELAS PARA SHAREPOINT (SCARAB)
        %-----------------------------------------------------------------%
        function jsonFileContent = scarabJsonFile(projectData, context, correlationKey, executionMode, issueDetails, generalSettings)
            entityGroupName = projectData.modules.(context).ui.entity.name;
            entityGroupId = projectData.modules.(context).ui.entity.id;

            jsonFileConfig  = { ...
                generalSettings.context.PRODUCTS.reportTable.exportedFiles.sharepoint.name, ...
                generalSettings.context.PRODUCTS.reportTable.exportedFiles.sharepoint.label ...
            };

            inspectedProducts = [];
            customsData = [];

            switch context
                case 'PRODUCTS'
                    inspectedProducts = renamevars(projectData.inspectedProducts, jsonFileConfig{:});
                    inspectedProducts = removevars(inspectedProducts, 'hash');
                    inspectedProducts.("correlationKey")(:) = {correlationKey};
                    inspectedProducts = movevars(inspectedProducts, 'correlationKey', 'Before', 1);

                otherwise % 'CUSTOMS
                    customsShipments = projectData.customsShipments;
                    reportIncludeIdx = find(arrayfun(@(x) x.UserData.ReportInclude, customsShipments), 1);
                    if ~isempty(reportIncludeIdx)
                        customsData = customsShipments(reportIncludeIdx).Data;
                    end
            end

            jsonFileContent = struct( ...
                'schemaVersion', 3, ...
                'createdAt', datestr(now, 'yyyy-mm-ddTHH:MM:SS'), ...
                'clientName', class.Constants.appName, ...
                'clientVersion', class.Constants.appVersion, ...
                'clientExecutionMode', executionMode, ...
                'auditorName', issueDetails.usuario.nome, ...
                'auditorEmail', issueDetails.usuario.email, ...
                'auditorDepartment', issueDetails.usuario.unidade, ...
                'auditorJobTitle', issueDetails.usuario.funcao, ...
                'project', struct( ...
                    'correlationKey', correlationKey, ...
                    'system', projectData.modules.(context).ui.system, ...
                    'unit', projectData.modules.(context).ui.unit, ...
                    'issue', projectData.modules.(context).ui.issue, ...
                    'macroTheme', issueDetails.issueContext.solicitacao.classificacao.macrotema, ...
                    'sei', issueDetails.issueContext.acao.sei.processo, ...
                    'seiReport', '', ...
                    'context', context, ...
                    'entityGroupName', entityGroupName, ...
                    'entityGroupId', entityGroupId ...
                ), ...
                'inspectedProducts', inspectedProducts, ...
                'customsShipments', customsData ...
            );

            jsonFileContent = jsonencode(jsonFileContent, 'PrettyPrint', true);
        end

        %-----------------------------------------------------------------%
        function teamsFileContent = scarabTeamsFileContent(issueDetails, sharepointFileBase)
            teamsFileContent = struct( ...
                'schemaVersion', 1, ...
                'clientName', class.Constants.appName, ...
                'auditorName', issueDetails.usuario.nome, ...
                'auditorEmail', issueDetails.usuario.email, ...
                'fileNameList', {{[sharepointFileBase '.json']}} ...
            );

            teamsFileContent = jsonencode(teamsFileContent, 'PrettyPrint', true);
        end
    end
end