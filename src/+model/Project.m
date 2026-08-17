classdef Project < model.ProjectCommon

    % ## model.Project (SCH) ##      
    % PUBLIC
    %   ├── Project
    %   |   |── restart
    %   │   |── model.ProjectBase.readRegulatronData
    %   │   └── IndexedDBTimer
    %   ├── restart
    %   │   |── initialization (SuperClass)
    %   │   └── model.ProjectBase.createInspectedProductsTable
    %   ├── checkIfUpdateNeeded
    %   │   └── model.ProjectBase.computeProjectHash
    %   ├── IndexedDBCache
    %   │   └── appEngine.indexedDB.saveData
    %   ├── save
    %   │   └── model.ProjectBase.computeProjectHash
    %   ├── load
    %   │   |── restart
    %   │   |── updateUiInfo (SuperClass)
    %   │   |── checkCNPJOrCPF (Externa)
    %   │   |── checkTypeSubtypeProductsMapping
    %   │   |── model.ProjectBase.initializeInspectedProduct
    %   │   |── updateInspectedProducts
    %   │   └── model.ProjectBase.computeProjectHash
    %   ├── validateInspectedProducts
    %   ├── checkTypeSubtypeProductsMapping
    %   └── updateInspectedProducts
    %       |── model.ProjectBase.computeInspectedProductHash
    %       └── IndexedDBCache
    
    properties
        %-----------------------------------------------------------------%
        inspectedProducts
        
        customsRules
        customsShipments = struct( ...
            'FileName', {}, ...
            'Hash', {}, ...
            'Type', {}, ...
            'Data', {}, ...
            'Analysis', {}, ...
            'ReportInclude', {} ...
        )

        typeSubtypeProductsMapping        
        regulatronData
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Project(mainApp, rootFolder)
            obj@model.ProjectCommon(mainApp, rootFolder);

            restart(obj, {'SEARCH', 'PRODUCTS', 'CUSTOMS'}, mainApp.General)
            obj.typeSubtypeProductsMapping = mainApp.General.context.PRODUCTS.productType.mapping;
            obj.regulatronData = model.ProjectBase.readRegulatronData(rootFolder, mainApp.General.fileFolder.DataHub_GET);
            IndexedDBTimer(obj, @(~,~)IndexedDBCache(obj))
        end

        %-----------------------------------------------------------------%
        function restart(obj, contextList, generalSettings)
            initialization(obj, contextList, generalSettings)
            
            if ismember('PRODUCTS', contextList)
                obj.inspectedProducts = model.ProjectBase.createInspectedProductsTable(generalSettings);
            end

            if ismember('CUSTOMS', contextList)
                obj.customsShipments(:) = [];
            end
        end

        %-----------------------------------------------------------------%
        function updateNeeded = checkIfUpdateNeeded(obj, varargin)
            updateNeeded = false;
            
            if ~isempty(obj.name)
                currentPrjHash = model.ProjectBase.computeProjectHash(obj.name, obj.file, obj.inspectedProducts, obj.issueDetails, obj.entityDetails);
                updateNeeded   = ~isequal(obj.hash, currentPrjHash);
            end
        end

        %-----------------------------------------------------------------%
        function IndexedDBCache(obj)
            if ~IndexedDBStatus(obj)
                return
            end

            prjHash = model.ProjectBase.computeProjectHash(obj.name, obj.file, obj.inspectedProducts, obj.issueDetails, obj.entityDetails);

            if ~strcmp(obj.indexedDB.lastSyncHash, prjHash)
                obj.indexedDB.lastSyncAt = datetime('now');
                obj.indexedDB.lastSyncHash = prjHash;                

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
                        obj.mainApp.General.context.PRODUCTS.reportTable.exportedFiles.sharepoint.name, ...
                        obj.mainApp.General.context.PRODUCTS.reportTable.exportedFiles.sharepoint.label ...
                    ), ...
                    'timestamp', datestr(now) ...
                );

                appEngine.indexedDB.saveData(obj.mainApp.jsBackDoor, class.Constants.appName, 'prjData', prjData)
            end
        end

        %-----------------------------------------------------------------%
        function save(obj, context, prjName, prjFile, outputFileCompressionMode)
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
                'inspectedProducts', obj.inspectedProducts, ...
                'customsShipments', obj.customsShipments ...
            );

            compressionMode = {};
            if strcmp(outputFileCompressionMode, 'Não')
                compressionMode = {'-nocompression'};
            end

            save(prjFile, 'source', 'type', 'version', 'variables', 'userData', '-mat', '-v7', compressionMode{:})

            obj.name = prjName;
            obj.file = prjFile;
            obj.hash = prjHash;
        end

        %-----------------------------------------------------------------%
        % ## LOAD ##
        %-----------------------------------------------------------------%
        function msg = load(obj, origin, varargin)
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
                                restart(obj, {context}, generalSettings)

                                obj.name = '(NÃO DEFINIDO)';
                                obj.file = fileName;
                                
                                updateUiInfo(obj, context, 'unit', prjData.variables.projectUnit)
                                updateUiInfo(obj, context, 'issue', prjData.variables.projectIssue)
                                
                                % Validação e normalização das informações da entidade fiscalizada.
                                [entityId, status] = checkCNPJOrCPF(prjData.variables.entityID, 'NumberValidation');
                                entityType = prjData.variables.entityType;
                                if ~ismember(entityType, generalSettings.reportLib.entityType.options)
                                    entityType = generalSettings.reportLib.entityType.default;
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
                                    if ~ismember(listOfProducts.("Tipo")(ii), generalSettings.context.PRODUCTS.productType.options)
                                        listOfProducts.("Tipo")(ii) = generalSettings.context.PRODUCTS.productType.default;
                                    end
                                
                                    if ~ismember(listOfProducts.("Situação")(ii), generalSettings.context.PRODUCTS.situationType.options)
                                        listOfProducts.("Situação")(ii) = generalSettings.context.PRODUCTS.situationType.default;
                                    end
                                
                                    if ~ismember(listOfProducts.("Infração")(ii), generalSettings.context.PRODUCTS.violationType.options)
                                        listOfProducts.("Infração")(ii) = generalSettings.context.PRODUCTS.violationType.default;
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
                                                case '.teams'
                                                    obj.modules.(context).generatedFiles.lastTEAMSFullPath   = unzipFiles{ii};
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
                                
                                if isfield(prjData.variables, 'customsShipments') && ~isempty(prjData.variables.customsShipments)
                                    obj.customsShipments = [prjData.variables.customsShipments, obj.customsShipments];
                                    [~, uniqueFirstHashIndexes] = unique({obj.customsShipments.Hash});
                                    obj.customsShipments = obj.customsShipments(uniqueFirstHashIndexes);
                                end
            
                            otherwise
                                error('UnexpectedVersion')
                        end

                    case 'indexedDB'
                        prjData = varargin{1};

                        switch prjData.version
                            case 1
                                restart(obj, {'SEARCH', 'PRODUCTS'}, generalSettings)

                                obj.name = prjData.name;
                                obj.file = prjData.file;
                                obj.hash = prjData.hash;

                                obj.modules = prjData.modules;

                                if ~isempty(prjData.issueDetails)
                                    obj.issueDetails = prjData.issueDetails;
                                end

                                if ~isempty(prjData.entityDetails)
                                    obj.entityDetails = prjData.entityDetails;
                                end

                                if ~isempty(prjData.inspectedProducts)
                                    listOfProducts = struct2table(prjData.inspectedProducts, "AsArray", true);
                                    
                                    if any(~ismember(listOfProducts.Properties.VariableNames, generalSettings.context.PRODUCTS.reportTable.exportedFiles.sharepoint.label))
                                        error([ ...
                                            'A estrutura dos dados dos produtos inspecionados foi alterada e os dados ' ...
                                            'salvos no navegador não são compatíveis com a versão atual do aplicativo.<br><br>' ...
                                            'Uma nova sessão foi iniciada.' ...
                                        ])
                                    end
    
                                    listOfProducts = renamevars( ...
                                        listOfProducts, ...
                                        generalSettings.context.PRODUCTS.reportTable.exportedFiles.sharepoint.label, ...
                                        generalSettings.context.PRODUCTS.reportTable.exportedFiles.sharepoint.name ...
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
        function [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateInspectedProducts(obj)
            % Função que valida a consistência e o preenchimento de dados da
            % tabela "inspectedProducts", respeitando regras estabelecidas no
            % eFiscaliza p/ upload de tabela com lista de produtos inspecionados.
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
                subtypeList = obj.typeSubtypeProductsMapping(typeIndex).subtype;
                if ~ismember(subtype, subtypeList)
                    subtype = subtypeList{1};
                end
            end
        end

        %-----------------------------------------------------------------%
        function [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateCustomsShipments(obj, index)
            customsData = obj.customsShipments(index).Data;

            ruleColumns = { ...
                'auditorDecisaoFinal', ... #01
                {'estadoAmostragem', 'auditorNota'} ... #02
                {'auditorDecisaoFinal', 'auditorNota'} ... #03
            };

            ruleViolationMatrix = zeros(height(customsData), numel(ruleColumns), 'logical');
            ruleViolationMatrix(:, 1) = string(customsData.("auditorDecisaoFinal")) == "-";
            ruleViolationMatrix(:, 2) = (string(customsData.("estadoAmostragem")) == "Selecionada") & (string(customsData.("auditorNota")) == "");
            ruleViolationMatrix(:, 3) = (string(customsData.("auditorDecisaoFinal")) == "Perdimento") & (string(customsData.("auditorNota")) == "");

            invalidRowIndexes = find(any(ruleViolationMatrix, 2));
        end

        %-----------------------------------------------------------------%
        % ## UPDATE ##
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
        end

        %-----------------------------------------------------------------%
        function varargout = updateCustomsShipments(obj, operation, varargin)
            arguments
                obj
                operation char {mustBeMember(operation, {'add', 'delete', 'reportInclude', 'annotationSingleEdit', 'annotationBatchEdit', 'statusColumns'})}
            end

            arguments (Repeating)
                varargin
            end

            varargout = {};

            switch operation
                case 'add'
                    fileFullName = varargin{1};
                    generalSettings = varargin{2};
                    rootFolder = varargin{3};

                    try
                        tbl = util.readExternalFile.Customs('Data', fileFullName);

                        if isempty(tbl)
                            error('O arquivo de produtos aduaneiros não contém registros válidos.')
                        end

                        customsDataHash = Hash.sha1(strjoin(sort(tbl.("Codigo da Remessa")), ' - '));
                        if ismember(customsDataHash, {obj.customsShipments.Hash})
                            error('O arquivo de produtos aduaneiros já foi carregado anteriormente.')
                        end

                        [~, fileName, fileExt] = fileparts(fileFullName);

                        customsData = model.ProjectBase.createCustomsShipmentsTable(generalSettings);
                        customsData(1:height(tbl), {'remessaCodigo', 'remessaImportador', 'remessaDescricao'}) = tbl(:, :);

                        rules = obj.customsRules;
                        if isempty(rules)
                            rules = util.readExternalFile.Customs('Rules', rootFolder);
                            rules = model.ProjectBase.prepareRules(rules, generalSettings);
                            obj.customsRules = rules;
                        end

                        obj.customsShipments(end+1) = struct( ...
                            'FileName', [fileName fileExt], ...
                            'Hash', customsDataHash, ...
                            'Type', 'REMESSA CONFORME', ...
                            'Data', util.analyzeCustomsRisk(customsData, rules, generalSettings), ...
                            'Analysis', struct('ProcessedAt', datestr(now, 'yyyy-mm-ddTHH:MM:SS'), 'Rules', rules), ...
                            'ReportInclude', false ...
                        );

                        updateCustomsShipments(obj, 'statusColumns', numel(obj.customsShipments), 1:height(obj.customsShipments(end).Data))

                        msg = '';

                    catch ME
                        msg = ME.message;
                    end

                    varargout{1} = msg;

                case 'delete'
                    index = varargin{1};
                    obj.customsShipments(index) = [];

                case 'reportInclude'
                    index = varargin{1};
                    for ii = 1:numel(obj.customsShipments)
                        obj.customsShipments(ii).ReportInclude = ii == index;
                    end

                case 'annotationSingleEdit'
                    index = varargin{1};
                    columnRows = varargin{2};
                    columnName = varargin{3};
                    columnValue = varargin{4};

                    switch columnName
                        case 'auditorDecisaoFinal' % 'categorical'
                            if ~iscategorical(columnValue) && ~isstring(columnValue)
                                columnValue = string(column);
                            end
                            obj.customsShipments(index).Data.(columnName)(columnRows) = columnValue;
                            updateCustomsShipments(obj, 'statusColumns', index, columnRows)

                        case 'auditorNota'
                            if ~iscellstr(columnValue)
                                columnValue = cellstr(columnValue);
                            end
                            obj.customsShipments(index).Data.(columnName)(columnRows) = strtrim(columnValue);

                        otherwise
                            error('Edição da coluna "%s" não suportada', columnName)
                    end

                    obj.customsShipments(index).Data.("auditorDataHora")(columnRows) = {datestr(now, 'yyyy-mm-ddTHH:MM:SS')};

                case 'annotationBatchEdit'
                    index = varargin{1};
                    columnRows = varargin{2};
                    auditorDecisaoFinal = varargin{3};
                    auditorNota = varargin{4};

                    obj.customsShipments(index).Data.("auditorDecisaoFinal")(columnRows) = auditorDecisaoFinal;
                    obj.customsShipments(index).Data.("auditorNota")(columnRows) = {auditorNota};
                    obj.customsShipments(index).Data.("auditorDataHora")(columnRows) = {datestr(now, 'yyyy-mm-ddTHH:MM:SS')};
                    updateCustomsShipments(obj, 'statusColumns', index, columnRows)

                case 'statusColumns'
                    % "estadoRevisao" e "estadoVistoria" são somente leitura: seus valores são
                    % derivados de "estadoAmostragem", "auditorDecisaoFinal" e do estado de
                    % vistoria já engajado (lido antes da sobrescrita), para que uma decisão
                    % final tomada sem nunca ter passado por vistoria mantenha "estadoVistoria"
                    % em "-" em vez de "Concluída".
                    index = varargin{1};
                    columnRows = varargin{2};
                    
                    customsData = obj.customsShipments(index).Data(columnRows, {'estadoAmostragem', 'estadoVistoria', 'auditorDecisaoFinal'});

                    decisaoConcluida = ~ismember(customsData.("auditorDecisaoFinal"), ["-", "Vistoria"]);
                    engajada = ismember(customsData.("estadoVistoria"), ["Pendente", "Concluída"]) ...
                        | (customsData.("estadoAmostragem") == "Selecionada") ...
                        | (customsData.("auditorDecisaoFinal") == "Vistoria");

                    estadoRevisao = repmat(categorical("Pendente"), numel(columnRows), 1);
                    estadoRevisao(engajada) = "Em vistoria";
                    estadoRevisao(decisaoConcluida) = "Concluída";

                    estadoVistoria = repmat(categorical("-"), numel(columnRows), 1);
                    estadoVistoria(engajada) = "Pendente";
                    estadoVistoria(engajada & decisaoConcluida) = "Concluída";

                    obj.customsShipments(index).Data.("estadoRevisao")(columnRows)  = estadoRevisao;
                    obj.customsShipments(index).Data.("estadoVistoria")(columnRows) = estadoVistoria;
            end
        end
    end
    
end