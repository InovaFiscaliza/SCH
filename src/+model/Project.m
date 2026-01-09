classdef Project < handle

    % ## model.Project ##      
    % - *.*
    %   ├── Project
    %   │   |── model.ProjectBase.readRegulatronData
    %   │   └── Initialization
    %   ├── Initialization
    %   │   |── ReadReportTemplates
    %   │   └── model.ProjectBase.createInspectedProductsTable
    %   ├── CheckIfUpdateNeeded
    %   │   └── model.ProjectBase.computeProjectHash
    %   ├── IndexedDBCache
    %   │   └── appEngine.indexedDB.saveData
    %   ├── Save
    %   │   └── model.ProjectBase.computeProjectHash
    %   ├── Load
    %   │   |── Initialization
    %   │   └── updateUiInfo
    %   │   |── checkCNPJOrCPF
    %   │   |── model.ProjectBase.initializeInspectedProduct
    %   │   |── model.ProjectBase.computeProjectHash
    %   │   └── updateInspectedProducts    
    %   ├── validateReportRequirements
    %   ├── validateInspectedProducts
    %   ├── checkTypeSubtypeProductsMapping
    %   ├── updateGeneratedFiles
    %   ├── updateUploadedFiles
    %   │   └── model.ProjectBase.computeUploadedFileHash
    %   |── updateInspectedProducts
    %   │   |── model.ProjectBase.computeInspectedProductHash
    %   │   └── IndexedDBCache
    %   ├── updateUiInfo
    %   ├── getUploadedFiles
    %   ├── getGeneratedDocumentFileName
    %   |   └── updateGeneratedFiles
    %   ├── getIssueDetailsFromCache
    %   ├── getOrFetchIssueDetails
    %   |   |── getIssueDetailsFromCache
    %   |   |── ws.eFiscaliza
    %   |   └── updateUiInfo
    %   ├── getEntityDetailsFromCache
    %   |── getOrFetchEntityDetails
    %   |   ├── getEntityDetailsFromCache
    %   |   ├── checkCNPJOrCPF
    %   |   └── updateUiInfo
    %   └── ReadReportTemplates
    %       ├── appEngine.util.Path
    %       ├── util.publicLink
    %       └── util.readExternalFile.RegulatronData
    
    properties
        %-----------------------------------------------------------------%
        name
        file
        hash

        modules
        report = struct('templates', [], 'settings',  [])
        
        issueDetails = struct('system', {}, 'issue', {}, 'details', {}, 'timestamp', {})
        entityDetails = struct('id', {}, 'details', {}, 'timestamp', {})

        inspectedProducts
        typeSubtypeProductsMapping        
        regulatronData
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
        indexedDBCacheLastSync
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Project(mainApp, rootFolder)            
            obj.mainApp = mainApp;
            obj.rootFolder = rootFolder;
            obj.typeSubtypeProductsMapping = mainApp.General.ui.typeOfProduct.mapping;
            obj.regulatronData = model.ProjectBase.readRegulatronData(rootFolder, mainApp.General.fileFolder.DataHub_GET);

            Initialization(obj, {'SEARCH', 'PRODUCTS'}, mainApp.General)
        end

        %-----------------------------------------------------------------%
        function Initialization(obj, contextList, generalSettings)
            % O "id", do "generatedFiles", é a lista ordenada de "hashs" dos registros 
            % que compõem "inspectedProducts".

            obj.name = '';
            obj.file = '';
            obj.hash = '';

            for ii = 1:numel(contextList)
                context = contextList{ii};
                obj.modules.(context) = struct( ...
                    'annotationTable', [], ...
                    'generatedFiles', struct( ...
                        'id', '', ...
                        'rawFiles', {{}}, ...
                        'lastHTMLDocFullPath', '', ...
                        'lastJSONFullPath', '', ...
                        'lastTableFullPath', '', ...
                        'lastZIPFullPath', '' ...
                    ), ...
                    'uploadedFiles', struct( ...
                        'hash', {}, ...
                        'system', {}, ...
                        'issue', {}, ...
                        'status', {}, ...
                        'timestamp', {} ...
                    ), ...
                    'ui', struct( ...
                        'system', '', ...
                        'unit',   '',  ...
                        'issue',  -1,  ...
                        'templates', {{}}, ...
                        'reportModel', '',  ...
                        'reportVersion', 'Preliminar', ...
                        'entityTypes', {{}},  ...
                        'entity', struct( ...
                            'type', '', ...
                            'name', '', ...
                            'id',   '', ...
                            'status', false ...
                        ) ...
                    ) ...
                );

                obj.modules.(context).ui.entityTypes = generalSettings.ui.typeOfEntity.options;
                obj.modules.(context).ui.entity.type = generalSettings.ui.typeOfEntity.default;
            end

            ReadReportTemplates(obj, obj.rootFolder)
            obj.inspectedProducts = model.ProjectBase.createInspectedProductsTable(generalSettings);
        end

        %-----------------------------------------------------------------%
        function updateNeeded = CheckIfUpdateNeeded(obj)
            updateNeeded = false;
            
            if ~isempty(obj.name)
                currentPrjHash = model.ProjectBase.computeProjectHash(obj.name, obj.file, obj.inspectedProducts, obj.issueDetails, obj.entityDetails);
                updateNeeded   = ~isequal(obj.hash, currentPrjHash);
            end
        end

        %-----------------------------------------------------------------%
        function IndexedDBCache(obj, operationType)
            arguments
                obj 
                operationType {mustBeMember(operationType, {'normal', 'forceUpdate'})} = 'normal'
            end

            generalSettings = obj.mainApp.General;

            if ~generalSettings.Report.indexedDBCache.status
                return
            end

            if strcmp(operationType, 'forceUpdate') || isempty(obj.indexedDBCacheLastSync) || minutes(datetime('now') - obj.indexedDBCacheLastSync) > generalSettings.Report.indexedDBCache.intervalMinutes
                prjData = struct( ...
                    'version', 1, ...
                    'name', obj.name, ...
                    'file', obj.file, ...
                    'hash', obj.hash, ...
                    'modules', obj.modules, ...
                    'issueDetails', obj.issueDetails, ...
                    'entityDetails', obj.entityDetails, ...
                    'inspectedProducts', renamevars( ...
                        obj.inspectedProducts, ...
                        generalSettings.ui.reportTable.exportedFiles.sharepoint.name, ...
                        generalSettings.ui.reportTable.exportedFiles.sharepoint.label ...
                    ), ...
                    'timestamp', datestr(now) ...
                );
    
                appEngine.indexedDB.saveData(obj.mainApp.jsBackDoor, class.Constants.appName, 'prjData', prjData)
                obj.indexedDBCacheLastSync = datetime('now');
            end
        end

        %-----------------------------------------------------------------%
        function Save(obj, context, prjName, prjFile, outputFileCompressionMode)
            arguments
                obj
                context char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                prjName
                prjFile
                outputFileCompressionMode
            end

            % Trata-se da versão 2 do arquivo de projeto do SCH. A versão 1,
            % disponível até SCH v. 1.01.5, era composta por cinco variáveis
            % - "source", "type", "userData", "variables" e "version". 

            % Manteve-se a mesma estrutura de variáveis, mas o conteúdo de
            % "variables" é diferente.

            source    = class.Constants.appName;
            type      = 'ProjectData';
            version   = 2;
            userData  = [];

            prjHash   = model.ProjectBase.computeProjectHash(prjName, prjFile, obj.inspectedProducts, obj.issueDetails, obj.entityDetails);
            variables = struct( ...
                'name', prjName, ...
                'hash', prjHash, ...
                'context', context, ...
                'ui', struct( ...
                    'system', obj.modules.(context).ui.system, ...
                    'unit', obj.modules.(context).ui.unit,  ...
                    'issue', obj.modules.(context).ui.issue, ...
                    'reportModel', obj.modules.(context).ui.reportModel, ...
                    'entity', obj.modules.(context).ui.entity ...
                ), ...
                'generatedFiles', struct( ...
                    'id', obj.modules.(context).generatedFiles.id, ...
                    'lastZIPFullPath', obj.modules.(context).generatedFiles.lastZIPFullPath ...
                ), ...
                'uploadedFiles', obj.modules.(context).uploadedFiles, ...
                'issueDetails', obj.issueDetails, ...
                'entityDetails', obj.entityDetails, ...
                'inspectedProducts', obj.inspectedProducts ...
            );

            compressionMode = '';
            if strcmp(outputFileCompressionMode, 'Não')
                compressionMode = '-nocompression';
            end

            save(prjFile, 'source', 'type', 'version', 'variables', 'userData', '-mat', '-v7', compressionMode)

            obj.name = prjName;
            obj.file = prjFile;
            obj.hash = prjHash;
        end

        %-----------------------------------------------------------------%
        % ## LOAD ##
        %-----------------------------------------------------------------%
        function msg = Load(obj, origin, varargin)
            arguments
                obj 
                origin {mustBeMember(origin, {'file', 'indexedDB'})}
            end

            arguments (Repeating)
                varargin
            end

            msg = '';
            generalSettings = obj.mainApp.General;
            
            try
                switch origin
                    case 'file'
                        fileName = varargin{1};

                        required = {'source', 'version', 'variables'};
                        varsInFile = who('-file', fileName);
                        if any(~ismember(required, varsInFile))
                            missing = setdiff(required, varsInFile);
                            error('Missing required variables: %s', strjoin(missing, ', '))
                        end
                        
                        prjData = load(fileName, '-mat', required{:});
                        
                        if ~strcmp(class.Constants.appName, prjData.source)
                            error('File generated by a different application. Expected: %s. Found: %s.', class.Constants.appName, prjData.source)
                        end
            
                        switch prjData.version
                            case 1
                                context  = 'PRODUCTS';
                                Initialization(obj, {context}, generalSettings)

                                obj.name = '(NÃO DEFINIDO)';
                                obj.file = fileName;
                                
                                updateUiInfo(obj, context, 'unit', prjData.variables.projectUnit)
                                updateUiInfo(obj, context, 'issue', prjData.variables.projectIssue)
                                
                                % Validação e normalização das informações da entidade fiscalizada.
                                [entityId, status] = checkCNPJOrCPF(prjData.variables.entityID, 'NumberValidation');
                                entityType = prjData.variables.entityType;
                                if ~ismember(entityType, generalSettings.ui.typeOfEntity.options)
                                    entityType = generalSettings.ui.typeOfEntity.default;
                                end
                                
                                entity = struct( ...
                                    'type', entityType, ...
                                    'name', upper(strtrim(prjData.variables.entityName)), ...
                                    'id', entityId, ...
                                    'status', status ...
                                );
                                updateUiInfo(obj, context, 'entity', entity)

                                reportModel = prjData.variables.reportModel;
                                if ismember(reportModel, obj.modules.(context).ui.templates)
                                    updateUiInfo(obj, context, 'reportModel', reportModel)
                                end
                                
                                listOfProducts = prjData.variables.listOfProducts;
                            
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

                                    % Atenção ao mapeamento Tipo x Subtipo...
                                    subtype = checkTypeSubtypeProductsMapping(obj, listOfProducts.("Tipo")(ii));
                                
                                    % Inicializa o registro do produto, gerando o respectivo hash, usando 
                                    % a função local "initializeInspectedProduct" ao invés do método com
                                    % o mesmo nome da classe "model.ProjectBase".
                                    [productData, productHash] = model.ProjectBase.initializeInspectedProduct( ...
                                        'LegacyProject', ...
                                        generalSettings, ...
                                        listOfProducts.("Homologação"){ii}, ...
                                        listOfProducts.("Tipo")(ii), ...
                                        subtype, ...
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
                                obj.hash = model.ProjectBase.computeProjectHash( ...
                                    obj.name, obj.file, obj.inspectedProducts, obj.issueDetails, obj.entityDetails ...
                                );
        
                            case 2
                                context  = prjData.variables.context;

                                obj.name = prjData.variables.name;
                                obj.file = fileName;
                                obj.hash = prjData.variables.hash;
        
                                if isfile(prjData.variables.generatedFiles.lastZIPFullPath)
                                    try
                                        unzipFiles = unzip(prjData.variables.generatedFiles.lastZIPFullPath, generalSettings.fileFolder.tempPath);
                                        for ii = 1:numel(unzipFiles)
                                            [~, ~, unzipFileExt] = fileparts(unzipFiles{ii});
        
                                            switch lower(unzipFileExt)
                                                case '.html'
                                                    obj.modules.(context).generatedFiles.lastHTMLDocFullPath = unzipFiles{ii};
                                                case '.json'
                                                    obj.modules.(context).generatedFiles.lastJSONFullPath    = unzipFiles{ii};
                                                case '.xlsx'
                                                    obj.modules.(context).generatedFiles.lastTableFullPath   = unzipFiles{ii};
                                            end
                                        end
                                        
                                        obj.modules.(context).generatedFiles.id              = prjData.variables.generatedFiles.id;
                                        obj.modules.(context).generatedFiles.lastZIPFullPath = prjData.variables.generatedFiles.lastZIPFullPath;
                                    catch 
                                    end
                                end
        
                                obj.modules.(context).ui.system = prjData.variables.ui.system;
                                obj.modules.(context).ui.unit   = prjData.variables.ui.unit;
                                obj.modules.(context).ui.issue  = prjData.variables.ui.issue;
                                obj.modules.(context).ui.entity = prjData.variables.ui.entity;
        
                                obj.modules.(context).uploadedFiles = [prjData.variables.uploadedFiles, obj.modules.(context).uploadedFiles];
                                [~, uniqueUploadedFilesIndexes] = unique({obj.modules.(context).uploadedFiles.hash});
                                obj.modules.(context).uploadedFiles = obj.modules.(context).uploadedFiles(uniqueUploadedFilesIndexes);
        
                                obj.issueDetails = [prjData.variables.issueDetails, obj.issueDetails];                        
                                
                                obj.entityDetails = [prjData.variables.entityDetails, obj.entityDetails];                        
                                [~, uniqueDetailsIndexes] = unique({obj.entityDetails.id});
                                obj.entityDetails = obj.entityDetails(uniqueDetailsIndexes);

                                reportModel = prjData.variables.ui.reportModel;
                                if ismember(reportModel, obj.modules.(context).ui.templates)
                                    updateUiInfo(obj, context, 'reportModel', reportModel)
                                end
        
                                obj.inspectedProducts = unique([prjData.variables.inspectedProducts; obj.inspectedProducts], "rows");
            
                            otherwise
                                error('UnexpectedVersion')
                        end

                    case 'indexedDB'
                        prjData = varargin{1};

                        switch prjData.version
                            case 1
                                Initialization(obj, {'SEARCH', 'PRODUCTS'}, generalSettings)

                                obj.name = prjData.name;
                                obj.file = prjData.name;
                                obj.hash = prjData.name;

                                obj.modules = prjData.modules;

                                if ~isempty(prjData.issueDetails)
                                    obj.issueDetails = prjData.issueDetails;
                                end

                                if ~isempty(prjData.entityDetails)
                                    obj.entityDetails = prjData.entityDetails;
                                end

                                if ~isempty(prjData.inspectedProducts)
                                    listOfProducts = struct2table(prjData.inspectedProducts, "AsArray", true);
                                    
                                    if any(~ismember(listOfProducts.Properties.VariableNames, generalSettings.ui.reportTable.exportedFiles.sharepoint.label))
                                        error([ ...
                                            'A estrutura dos dados dos produtos sob análise foi alterada e os dados ' ...
                                            'salvos no navegador não são compatíveis com a versão atual do aplicativo.<br><br>' ...
                                            'Uma nova sessão foi iniciada.' ...
                                        ])
                                    end
    
                                    listOfProducts = renamevars( ...
                                        listOfProducts, ...
                                        generalSettings.ui.reportTable.exportedFiles.sharepoint.label, ...
                                        generalSettings.ui.reportTable.exportedFiles.sharepoint.name ...
                                    );
                                    listOfProducts = model.ProjectBase.validateCategoricalColumns(listOfProducts, generalSettings);
                                    obj.inspectedProducts(1:height(listOfProducts), :) = listOfProducts;
                                end

                            otherwise
                                error('UnexpectedVersion')
                        end
                end        
            catch ME
                msg = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        % ## VALIDATION ##
        %-----------------------------------------------------------------%
        function status = validateReportRequirements(obj, context, requirement)
            arguments
                obj 
                context 
                requirement {mustBeMember(requirement, {'inspectedProducts', 'issue', 'unit', 'reportModel', 'entity'})}
            end
            switch requirement
                case 'inspectedProducts'
                    status = ~isempty(obj.inspectedProducts);
                case 'issue'
                    issue  = obj.modules.(context).ui.issue;
                    status = (issue > 0) && (issue < inf);
                case 'unit'
                    status = ~isempty(obj.modules.(context).ui.unit);
                case 'reportModel'
                    status = ~isempty(obj.modules.(context).ui.reportModel);
                case 'entity'
                    entity = obj.modules.(context).ui.entity;
                    status = ~isempty(entity.type) && ~isempty(entity.name) && (strcmp(entity.type, 'Importador') || entity.status);
            end
        end

        %-----------------------------------------------------------------%
        function [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateInspectedProducts(obj)
            % Função que valida a consistência e o preenchimento de dados da
            % tabela "inspectedProducts", respeitando regras estabelecidas no
            % eFiscaliza p/ upload de tabela com lista de produtos sob análise.
            %
            % #01 "Tipo" e "Subtipo" devem estar preenchidos (≠ "-").
            % #02 "Fabricante" deve estar preenchido.
            % #03 "Modelo" deve estar preenchido.
            % #04 "Valor Unit. (R$)" não pode ser menor do que zero.
            % #05 A soma da "Qtd. uso", "Qtd. vendida", "Qtd. estoque/aduana" e "Qtd. anunciada" deve ser maior que zero.
            % #06 A soma da "Qtd. uso" e "Qtd. estoque/aduana" não pode ser menor do que a soma "Qtd. lacradas", "Qtd. apreendidas" e "Qtd. retidas (RFB)".
            % #07 "Situação" deve estar preenchida (≠ "-").
            % #08 "Situação" e "Infração" devem ser coerentes entre si, de forma que: 
            %     • situação regular → sem infração
            %     • situação irregular → infração obrigatória
            % #09 "Valor Unit. (R$)" válido (> 0) em situação irregular.
            % #10 "Fonte do valor" deve estar preenchido em situação irregular.
            % #11 A soma da "Qtd. lacradas", "Qtd. apreendidas" e "Qtd. retidas (RFB)" não pode ser maior que zero em situação regular.
            % #12 Se a soma "Qtd. lacradas" e "Qtd. apreendidas" for maior que zero, então "PLAI"  deve ser preenchido.
            % #13 Se a soma "Qtd. lacradas" e "Qtd. apreendidas" for maior que zero, então "Lacre" deve ser preenchido.

            ruleColumns = {                                                                                     ...
                {'Tipo', 'Subtipo'},                                                                            ... #01
                'Fabricante',                                                                                   ... #02
                'Modelo',                                                                                       ... #03    
                'Valor Unit. (R$)',                                                                             ... #04
                {'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada'},                          ... #05
                {'Qtd. uso', 'Qtd. estoque/aduana', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}, ... #06
                'Situação',                                                                                     ... #07
                {'Situação', 'Infração'}                                                                        ... #08
                {'Situação', 'Valor Unit. (R$)'},                                                               ... #09
                {'Situação', 'Fonte do valor'},                                                                 ... #10
                {'Situação', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'},                        ... #11
                {'Qtd. lacradas', 'Qtd. apreendidas', 'Lacre'},                                                 ... #12
                {'Qtd. lacradas', 'Qtd. apreendidas', 'PLAI'}                                                   ... #13
            };

            ruleViolationMatrix = zeros(height(obj.inspectedProducts), numel(ruleColumns), 'logical');

            ruleViolationMatrix(:,  1) = string(obj.inspectedProducts.("Tipo")) == "-" | string(obj.inspectedProducts.("Subtipo")) == "-";
            ruleViolationMatrix(:,  2) = string(obj.inspectedProducts.("Fabricante")) == "";
            ruleViolationMatrix(:,  3) = string(obj.inspectedProducts.("Modelo")) == "";
            
            ruleViolationMatrix(:,  4) = obj.inspectedProducts.("Valor Unit. (R$)") < 0;            
            ruleViolationMatrix(:,  5) = sum(obj.inspectedProducts{:, {'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada'}}, 2) <= 0;
            ruleViolationMatrix(:,  6) = sum(obj.inspectedProducts{:, {'Qtd. uso', 'Qtd. estoque/aduana'}}, 2) < sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2);            
            
            ruleViolationMatrix(:,  7) = string(obj.inspectedProducts.("Situação")) == "-";
            ruleViolationMatrix(:,  8) = ((string(obj.inspectedProducts.("Situação")) == "Regular")  & (string(obj.inspectedProducts.("Infração")) ~= "-")) | ((string(obj.inspectedProducts.("Situação")) == "Irregular") & (string(obj.inspectedProducts.("Infração")) == "-"));            
            ruleViolationMatrix(:,  9) = (string(obj.inspectedProducts.("Situação")) == "Irregular") & (obj.inspectedProducts.("Valor Unit. (R$)") == 0);
            ruleViolationMatrix(:, 10) = (string(obj.inspectedProducts.("Situação")) == "Irregular") & (string(obj.inspectedProducts.("Fonte do valor")) == "");
            ruleViolationMatrix(:, 11) = (string(obj.inspectedProducts.("Situação")) == "Regular")   & (sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2) > 0);
            
            ruleViolationMatrix(:, 12) = sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas'}}, 2) > 0 & (string(obj.inspectedProducts.("Lacre")) == "");
            ruleViolationMatrix(:, 13) = sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas'}}, 2) > 0 & (string(obj.inspectedProducts.("PLAI")) == "");

            invalidRowIndexes = find(any(ruleViolationMatrix, 2));
        end

        %-----------------------------------------------------------------%
        function [subtype, subtypeList] = checkTypeSubtypeProductsMapping(obj, type, subtype)
            arguments
                obj
                type
                subtype = '-'
            end

            [~, typeIndex] = ismember(type, {obj.typeSubtypeProductsMapping.type});
            
            if ~typeIndex
                subtype = '-';
                subtypeList = {subtype};                
            else
                subtypeList = obj.typeSubtypeProductsMapping(typeIndex).sybtype;
                if ~ismember(subtype, subtypeList)
                    subtype = subtypeList{1};
                end
            end
        end

        %-----------------------------------------------------------------%
        % ## UPDATE ##
        %-----------------------------------------------------------------%
        function updateGeneratedFiles(obj, context, id, rawFiles, htmlFile, jsonFile, tableFile, zipFile)
            arguments
                obj
                context   (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                id        char = ''
                rawFiles  cell = {}
                htmlFile  char = ''
                jsonFile  char = ''
                tableFile char = ''
                zipFile   char = ''
            end

            obj.modules.(context).generatedFiles.id                  = id;
            obj.modules.(context).generatedFiles.rawFiles            = rawFiles;
            obj.modules.(context).generatedFiles.lastHTMLDocFullPath = htmlFile;
            obj.modules.(context).generatedFiles.lastJSONFullPath    = jsonFile;
            obj.modules.(context).generatedFiles.lastTableFullPath   = tableFile;
            obj.modules.(context).generatedFiles.lastZIPFullPath     = zipFile;

            IndexedDBCache(obj)
        end

        %-----------------------------------------------------------------%
        function updateUploadedFiles(obj, context, system, issue, status)
            arguments
                obj
                context (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                system
                issue
                status
            end

            obj.modules.(context).uploadedFiles(end+1) = struct( ...
                'hash', model.ProjectBase.computeUploadedFileHash(system, issue, status), ...
                'system', system, ...
                'issue', issue, ...
                'status', status, ...
                'timestamp', datestr(now) ...
            );

            IndexedDBCache(obj)
        end

        %-----------------------------------------------------------------%
        function updateInspectedProducts(obj, operation, varargin)
            arguments
                obj
                operation char {mustBeMember(operation, {'add', 'edit', 'delete'})}
            end

            arguments (Repeating)
                varargin
            end

            switch operation
                case 'add'
                    productFields = varargin{1}(:, 1);
                    productValues = varargin{1}(:, 2)';
                    obj.inspectedProducts(end+1, productFields) = productValues;
                    obj.inspectedProducts = sortrows(obj.inspectedProducts, 'Homologação');

                case 'edit'
                    indexes = varargin{1};
                    productFields = varargin{2};
                    productValues = varargin{3};                    
                    obj.inspectedProducts(indexes, productFields) = productValues;

                    % Atualiza hash apenas dos produtos não homologados,
                    % caso aplicável.
                    indexHom = find(strcmp(obj.inspectedProducts.('Homologação'), '-'));
                    if ~isempty(indexHom)
                        hashs = cellfun(@(x, y) model.ProjectBase.computeInspectedProductHash('-', x, y), obj.inspectedProducts.("Fabricante")(indexHom), obj.inspectedProducts.("Modelo")(indexHom), 'UniformOutput', false);
                        obj.inspectedProducts.("Hash")(indexHom) = hashs;
                    end

                case 'delete'
                    indexes = varargin{1};
                    obj.inspectedProducts(indexes, :) = [];
            end

            IndexedDBCache(obj)
        end

        %-----------------------------------------------------------------%
        function updateUiInfo(obj, context, fieldName, fieldValue)
            arguments
                obj
                context    (1,:) char {mustBeMember(context, {'self', 'SEARCH', 'PRODUCTS'})}
                fieldName  (1,:) char
                fieldValue
            end

            switch fieldName
                case {'name', 'file', 'hash'}
                    obj.(fieldName) = fieldValue;

                case 'issueDetails'
                    [~, issueIndex] = ismember(fieldValue.issue, [obj.issueDetails.issue]);
                    if ~issueIndex
                        issueIndex = numel(obj.issueDetails) + 1;
                    end                    
                    obj.issueDetails(issueIndex) = fieldValue;

                case 'entityDetails'
                    [~, entityIdIndex] = ismember(fieldValue.id, {obj.entityDetails.id});
                    if ~entityIdIndex
                        entityIdIndex = numel(obj.entityDetails) + 1;
                    end                    
                    obj.entityDetails(entityIdIndex) = fieldValue;

                otherwise
                    obj.modules.(context).ui.(fieldName) = fieldValue;
            end

            IndexedDBCache(obj)
        end

        %-----------------------------------------------------------------%
        % ## GET ##
        %-----------------------------------------------------------------%
        function fileName = getGeneratedDocumentFileName(obj, fileExt, context)
            arguments
                obj
                fileExt (1,:) char {mustBeMember(fileExt, {'.html', '.xlsx', '.zip'})}
                context (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
            end

            switch fileExt
                case '.html'
                    fileName = obj.modules.(context).generatedFiles.lastHTMLDocFullPath;
                case '.json'
                    fileName = obj.modules.(context).generatedFiles.lastJSONFullPath;
                case '.xlsx'
                    fileName = obj.modules.(context).generatedFiles.lastTableFullPath;
                case '.zip'
                    fileName = obj.modules.(context).generatedFiles.lastZIPFullPath;
            end

            if ismember(fileExt, {'.html', '.zip'}) && ~isempty(fileName) && ~isfile(fileName)
                fileName = '';
                updateGeneratedFiles(obj, context)
            end
        end

        %-----------------------------------------------------------------%
        function uploadedFiles = getUploadedFiles(obj, context, system, issue)
            arguments
                obj
                context (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                system
                issue
            end

            uploadedFiles = obj.modules.(context).uploadedFiles;
            uploadedFiles = uploadedFiles(strcmp({uploadedFiles.system}, system) & [uploadedFiles.issue] == issue);
        end

        %-----------------------------------------------------------------%
        function details = getIssueDetailsFromCache(obj, system, issue)
            detailsIndex = find(strcmp({obj.issueDetails.system}, system) & [obj.issueDetails.issue] == issue, 1);
            
            if ~isempty(detailsIndex)
                details  = obj.issueDetails(detailsIndex).details;
            else
                details  = '';
            end
        end

        %-----------------------------------------------------------------%
        function details = getEntityDetailsFromCache(obj, id)
            [~, entityIndex] = ismember(id, {obj.entityDetails.id});
            
            if entityIndex
                details = obj.entityDetails(entityIndex).details;
            else
                details = '';      
            end
        end

        %-----------------------------------------------------------------%
        % ## GET/FETCH ##
        %-----------------------------------------------------------------%
        function [details, msgError] = getOrFetchIssueDetails(obj, system, issue, eFiscalizaObj)
            details  = getIssueDetailsFromCache(obj, system, issue);
            msgError = '';

            if isempty(details)
                try
                    env = strsplit(system);
                    if isscalar(env)
                        env = 'PD';
                    else
                        env = env{2};
                    end
    
                    issueInfo = struct( ...
                        'type', 'ATIVIDADE DE INSPEÇÃO', ...
                        'id', issue ...
                    );
                    
                    response = run(eFiscalizaObj, env, 'queryIssue', issueInfo);
                    if isstruct(response)
                        details = struct( ...
                            'system', system, ...
                            'issue', issue, ...
                            'details', response, ...
                            'timestamp', datestr(now) ...
                        );
                        updateUiInfo(obj, 'self', 'issueDetails', details)
    
                    else
                        error(response)
                    end    
                catch ME
                    msgError = ME.message;
                end              
            end
        end

        %-----------------------------------------------------------------%
        function [details, msgError] = getOrFetchEntityDetails(obj, id)
            details  = getEntityDetailsFromCache(obj, id);
            msgError = '';

            if isempty(details)
                [entityId, ~, details, msgError] = checkCNPJOrCPF(id, 'PublicAPI');

                if ~isempty(details)
                    updateUiInfo(obj, 'self', 'entityDetails', struct('id', entityId, 'details', details, 'timestamp', datestr(now)))
                end                
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function ReadReportTemplates(obj, rootFolder)
            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
            projectFilePath  = fullfile(projectFolder,     'ReportTemplates.json');
            externalFilePath = fullfile(programDataFolder, 'ReportTemplates.json');

            try
                if ~isdeployed()
                    error('ForceDebugMode')
                end
                obj.report.templates = jsondecode(fileread(externalFilePath));
            catch
                obj.report.templates = jsondecode(fileread(projectFilePath));
            end

            % Identifica lista de templates por módulo...
            contextList = fieldnames(obj.modules);
            templateNameList = {obj.report.templates.Name};

            for ii = 1:numel(contextList)
                templateIndexes = ismember({obj.report.templates.Module}, contextList(ii));
                obj.modules.(contextList{ii}).ui.templates = [{''}, templateNameList(templateIndexes)];
            end
        end
    end
    
end