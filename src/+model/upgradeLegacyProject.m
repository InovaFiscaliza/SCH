function upgradeLegacyProject(obj, fileName, variables, generalSettings)
    % "obj" é uma instância da classe model.projectLib. Esta função era 
    % originalmente um método da classe, mas foi extraída por se tratar de 
    % uma rotina extensa, pouco utilizada e que não se mistura com as demais 
    % responsabilidades centrais da classe.

    % A versão 1 do arquivo de projeto (.mat) possui as mesmas cinco variáveis 
    % da versão 2: "source", "type", "version", "variables" e "userData".

    % A variável "variables", entretanto, teve sua estrutura modificada
    % entre as versões, exigindo tratamento específico de compatibilidade.

    % O primeiro argumento é mantido como "obj" para facilitar uma eventual
    % refatoração futura, caso esta lógica seja encapsulada de outra forma.

    context = 'PRODUCTS';
    Initialization(obj, {context}, generalSettings)

    updateUiInfo(obj, context, 'name', '(NÃO DEFINIDO)')
    updateUiInfo(obj, context, 'file', fileName)
    
    updateUiInfo(obj, context, 'unit', variables.projectUnit)
    updateUiInfo(obj, context, 'issue', variables.projectIssue)
    
    % Validação e normalização das informações da entidade fiscalizada.
    [entityId, status] = checkCNPJOrCPF(variables.entityID, 'NumberValidation');
    entityType = variables.entityType;
    if ~ismember(entityType, generalSettings.ui.typeOfEntity.options)
        entityType = generalSettings.ui.typeOfEntity.default;
    end
    
    entity = struct( ...
        'type', entityType, ...
        'name', upper(strtrim(variables.entityName)), ...
        'id', entityId, ...
        'status', status ...
    );
    updateUiInfo(obj, context, 'entity', entity)
    
    % Atualiza o modelo de relatório, caso ainda seja compatível.
    reportModel = variables.reportModel;
    if ismember(reportModel, obj.modules.(context).ui.templates)
        updateUiInfo(obj, context, 'reportModel', reportModel)
    end
    
    listOfProducts = variables.listOfProducts;

    % Ajuste de valores iniciais ou inválidos ("-1") para "-", conforme
    % convenção adotada nas versões mais recentes. O tratamento é feito
    % coluna a coluna por se tratarem de colunas categóricas.
    listOfProducts.("Homologação") = replace(listOfProducts.("Homologação"),  {'-1'}, {'-'});
    listOfProducts.("Tipo")(:)     = categorical(replace(string(listOfProducts.("Tipo")),     "-1", "-"));
    listOfProducts.("Situação")(:) = categorical(replace(string(listOfProducts.("Situação")), "-1", "-"));
    listOfProducts.("Infração")(:) = categorical(replace(string(listOfProducts.("Infração")), "-1", "-"));
    listOfProducts.("Sanável?")(:) = categorical(replace(string(listOfProducts.("Sanável?")), "-1", "-"));
    
    % Identifica colunas com nomes coincidentes entre a tabela legada e a
    % estrutura atual, permitindo a cópia de valores adicionais além dos
    % campos básicos. Esse passo é protegido por try/catch por não ser essencial.
    matchingColumns = listOfProducts.Properties.VariableNames( ...
        ismember( ...
            listOfProducts.Properties.VariableNames, ...
            obj.inspectedProducts.Properties.VariableNames ...
        ) ...
    );
    
    for ii = 1:height(listOfProducts)
        % Valida, para cada registro, se os valores das colunas categóricas
        % ("Tipo", "Situação", "Infração" e "Sanável?") pertencem às categorias
        % atualmente suportadas pela aplicação.
        if ~ismember(listOfProducts.("Tipo")(ii), generalSettings.ui.typeOfProduct.options)
            listOfProducts.("Tipo")(ii) = generalSettings.ui.typeOfProduct.default;
        end
    
        if ~ismember(listOfProducts.("Situação")(ii), generalSettings.ui.typeOfSituation.options)
            listOfProducts.("Situação")(ii) = generalSettings.ui.typeOfSituation.default;
        end
    
        if ~ismember(listOfProducts.("Infração")(ii), generalSettings.ui.typeOfViolation.options)
            listOfProducts.("Infração")(ii) = generalSettings.ui.typeOfViolation.default;
        end
    
        if ~ismember(listOfProducts.("Sanável?")(ii), {'-', 'Sim', 'Não'})
            listOfProducts.("Sanável?")(ii) = '-';
        end
    
        % Inicializa o registro do produto, gerando o respectivo hash, usando 
        % a função local "initializeInspectedProduct" ao invés do método com
        % o mesmo nome da classe "model.projectLib".
        [productData, productHash] = initializeInspectedProduct( ...
            listOfProducts.("Homologação"){ii}, ...
            listOfProducts.("Tipo")(ii), ...
            listOfProducts.("Fabricante"){ii}, ...
            listOfProducts.("Modelo"){ii}, ...
            listOfProducts.("Situação")(ii), ...
            listOfProducts.("Infração")(ii), ...
            listOfProducts.("Sanável?")(ii), ...
            listOfProducts.("Informações adicionais"){ii} ...
        );
    
        % Evita duplicação de produtos já existentes.
        if ismember(productHash, obj.inspectedProducts.("Hash"))
            continue
        end
    
        updateInspectedProducts(obj, 'add', productData)
        try
            [~, productIndex] = ismember(productHash, obj.inspectedProducts.("Hash"));
            obj.inspectedProducts(productIndex, matchingColumns) = listOfProducts(ii, matchingColumns);
        catch
        end
    end

    % Ao final do processo, calcula-se o hash global do projeto (propriedade
    % não existente na versão 1).
    currentPrjHash = model.projectLib.computeProjectHash( ...
        obj.name, obj.file, obj.inspectedProducts, obj.issueDetails, obj.entityDetails ...
    );
    updateUiInfo(obj, context, 'hash', currentPrjHash)
end

%-------------------------------------------------------------------------%
function [productData, productHash] = initializeInspectedProduct(homologation, productType, manufacturer, modelName, situation, violation, corrigible, optionalNote)
    arguments
        homologation
        productType
        manufacturer
        modelName
        situation
        violation
        corrigible
        optionalNote
    end

    productHash = model.projectLib.computeInspectedProductHash( ...
        homologation, ...
        manufacturer, ...
        modelName ...
    );

    productData = {
        'Hash', productHash;
        'Homologação', homologation;
        'Tipo', productType;
        'Fabricante', manufacturer;
        'Modelo', modelName;
        'Situação', situation;
        'Infração', violation;
        'Sanável?', corrigible;
        'Informações adicionais', optionalNote
    };

    % Por fim, identificam-se colunas do tipo "cell" que são inicializadas 
    % como [] (numérico), mas que no contexto atual precisam ser inicializadas 
    % como '' (texto).
    cellColumnIndexes = strcmp(model.projectLib.INSPECTEDPRODUCTSSPECIFICATION(:, 1), 'cell');
    cellColumnNames = model.projectLib.INSPECTEDPRODUCTSSPECIFICATION(cellColumnIndexes, 2);
    uninitializedColumns = setdiff(cellColumnNames, productData(:, 1), 'stable');

    if ~isempty(uninitializedColumns)
        productData = [ ...
            productData; ...
            [uninitializedColumns, repmat({''}, numel(uninitializedColumns), 1)] ...
        ];
    end
end