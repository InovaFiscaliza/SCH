classdef projectLib < handle

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
        regulatronData = struct('urlPreffix', '', 'addsTable', [])
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
    end


    properties (Constant)
    %---------------------------------------------------------------------%
    % Lista de colunas e seus respectivos tipos que compõem a tabela
    % "inspectedProducts".
    %
    % As colunas comentadas — "Mercadoria retida (R$)", "Mercadoria vendida (R$)" 
    % e "Qtd. vistoriadas" — não fazem parte de "inspectedProducts", pois são 
    % colunas calculadas. Seus valores são aferidos antes da exportação dos dados.
    %
    % A seguir, os diferentes contextos de uso de "inspectedProducts":
    % • "vendorView" : visualização padrão da tabela no modo "auxApp.winProducts", 
    %                  apresentada na GUI como "Fornecedor | Usuário".
    % • "customsView": visualização da tabela no modo "auxApp.winProducts",
    %                  apresentada na GUI como "Aduana".
    % • "sharepoint" : planilha exportada para o SharePoint.
    % • "eFiscaliza" : planilha exportada para o eFiscaliza.
    %---------------------------------------------------------------------%
        INSPECTEDPRODUCTSSPECIFICATION = {
            'cell',        'Hash';
            'cell',        'Homologação';           % vendorView customsView sharepoint
            'cell',        'Importador';            %            customsView sharepoint
            'cell',        'Código aduaneiro';      %            customsView sharepoint
            'categorical', 'Tipo';                  % vendorView customsView sharepoint eFiscaliza
            'cell',        'Subtipo';               %                        sharepoint eFiscaliza
            'cell',        'Fabricante';            % vendorView customsView sharepoint eFiscaliza
            'cell',        'Modelo';                % vendorView customsView sharepoint eFiscaliza
            'logical',     'RF?';                   % vendorView customsView sharepoint eFiscaliza
            'logical',     'Em uso?';               % vendorView             sharepoint eFiscaliza
            'logical',     'Interferência?';        % vendorView             sharepoint eFiscaliza
            'double',      'Valor Unit. (R$)';      % vendorView customsView sharepoint eFiscaliza
            'cell',        'Fonte do valor';        % vendorView customsView sharepoint eFiscaliza
        ... 'double',      'Mercadoria retida (R$);
        ... 'double',      'Mercadoria vendida (R$);
        ... 'uint32',      'Qtd. vistoriadas';      %                                   eFiscaliza
            'uint32',      'Qtd. uso';              % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. vendida';          % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. estoque/aduana';   % vendorView customsView sharepoint eFiscaliza
            'uint32',      'Qtd. anunciada';        % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. lacradas';         % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. apreendidas';      % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. retidas (RFB)';    % vendorView customsView sharepoint eFiscaliza
            'cell',        'Lacre';                 %                        sharepoint eFiscaliza
            'cell',        'PLAI';                  %                        sharepoint eFiscaliza
            'categorical', 'Situação';              % vendorView customsView sharepoint eFiscaliza
            'categorical', 'Infração';              % vendorView customsView sharepoint
            'categorical', 'Sanável?';              %            customsView sharepoint
            'cell',        'Informações adicionais' %                        sharepoint
        }

        WARNING_ENTRYEXIST = struct( ...
            'SEARCH', [ ...
                'O(s) registro(s) selecionado(s) já consta(m) na lista de ' ...
                'produtos sob análise.' ...
            ], ...
            'PRODUCTS', [ ...
                'Na lista de produtos sob análise já consta um produto não ' ...
                'homologado sem fabricante e modelo definidos. Inserir um ' ...
                'novo registro irá duplicá-lo. Se houver vários produtos não ' ...
                'homologados, preencha fabricante e modelo para diferenciá-los ' ...
                'e evitar duplicidades.' ...
            ] ...
        )
    end


    methods
        %-----------------------------------------------------------------%
        function obj = projectLib(mainApp, rootFolder)            
            obj.mainApp    = mainApp;
            obj.rootFolder = rootFolder;

            Initialization(obj, {'SEARCH', 'PRODUCTS'}, mainApp.General, rootFolder)
            ReadRegulatronData(obj, rootFolder)

            obj.typeSubtypeProductsMapping = mainApp.General.ui.typeOfProduct.mapping;
        end

        %-----------------------------------------------------------------%
        function Initialization(obj, contextList, generalSettings, rootFolder)
            % O "id", do "generatedFiles", é a lista ordenada de "hashs" dos registros 
            % que compõem "inspectedProducts".

            obj.name = '';
            obj.file = '';
            obj.hash = '';

            for ii = 1:numel(contextList)
                context = contextList{ii};
                obj.modules.(context) = struct( ...
                    'annotationTable', [], ...
                    'generatedFiles',  struct('id', '', 'rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                    'ui',              struct('system',        '',  ...
                                              'unit',          '',  ...
                                              'issue',         -1,  ...
                                              'templates',    {{}}, ...
                                              'reportModel',   '',  ...
                                              'reportVersion', 'Preliminar', ...
                                              'entityTypes', {{}},  ...
                                              'entity', struct('type', '', 'name', '', 'id', '', 'status', false)) ...
                );
            end

            ReadReportTemplates(obj, rootFolder)            
            CreateInspectedProductsTable(obj, generalSettings);
        end

        %-----------------------------------------------------------------%
        function updateNeeded = CheckIfUpdateNeeded(obj)
            updateNeeded = false;
            
            if ~isempty(obj.name)
                currentPrjHash = model.projectLib.computeProjectHash(obj.name, obj.file, obj.inspectedProducts);
                updateNeeded   = ~isequal(obj.hash, currentPrjHash);
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

            appName  = class.Constants.appName;
            prjHash  = model.projectLib.computeProjectHash(prjName, prjFile, obj.inspectedProducts);
            prjData  = struct('version', 1, ...
                              'name',    prjName, ...
                              'hash',    prjHash, ...
                              'context', context, ...
                              'generatedFiles', struct('id', obj.modules.(context).generatedFiles.id, 'lastZIPFullPath', obj.modules.(context).generatedFiles.lastZIPFullPath), ...
                              'ui',      struct('system',       obj.modules.(context).ui.system, ...
                                                'unit',         obj.modules.(context).ui.unit,  ...
                                                'issue',        obj.modules.(context).ui.issue, ...
                                                'reportModel',  obj.modules.(context).ui.reportModel, ...
                                                'entity',       obj.modules.(context).ui.entity), ...
                              'issueDetails',  obj.issueDetails, ...
                              'entityDetails', obj.entityDetails, ...
                              'inspectedProducts', obj.inspectedProducts);

            compressionMode = '';
            if strcmp(outputFileCompressionMode, 'Não')
                compressionMode = '-nocompression';
            end

            save(prjFile, 'appName', 'prjData', '-mat', '-v7', compressionMode)

            obj.name = prjName;
            obj.file = prjFile;
            obj.hash = prjHash;
        end

        %-----------------------------------------------------------------%
        function msg = Load(obj, fileName, generalSettings)
            % Em 01/01/2026, a versão 1 do projeto contempla instância da 
            % classe model.projectLib. Ao ler um arquivo .mat, usando função 
            % "load", o MATLAB realiza validações simples, como adicionar 
            % novas propriedades (com valores padrão) ou remover outras que 
            % não existem mais (independentemente do seu conteúdo). 

            % A seguir lista com principais propriedades da classe.
            % • model.projectLib
            %   "name", "file", "report", "modules" e "inspectedProducts".

            % A alteração da forma de organização da informação no app pode 
            % demandar a criação de outras versões (2, 3...) do arquivo de 
            % projeto (.mat), o que deve vir acompanhado de parsers para manter 
            % compatibilidade, caso viável.

            required = {'appName', 'prjData'};

            try
                varsInFile = who('-file', fileName);
                if any(~ismember(required, varsInFile))
                    missing = setdiff(required, varsInFile);
                    error('Missing required variables: %s', strjoin(missing, ', '))
                end
                
                load(fileName, '-mat', required{:})
                
                if ~strcmp(class.Constants.appName, appName)
                    error('File generated by a different application. Expected: %s. Found: %s.', class.Constants.appName, appName)
                end
    
                switch prjData.version
                    case 1
                        obj.name = prjData.name;
                        obj.file = fileName;
                        obj.hash = prjData.hash;
    
                        context = prjData.context;

                        if isfile(prjData.generatedFiles.lastZIPFullPath)
                            try
                                unzipFiles = unzip(prjData.generatedFiles.lastZIPFullPath, generalSettings.fileFolder.tempPath);
                                for ii = 1:numel(unzipFiles)
                                    [~, ~, unzipFileExt] = fileparts(unzipFiles{ii});

                                    switch lower(unzipFileExt)
                                        case '.html'
                                            obj.modules.(context).generatedFiles.lastHTMLDocFullPath = unzipFiles{ii};
                                        case '.json'
                                            obj.modules.(context).generatedFiles.lastTableFullPath   = unzipFiles{ii};
                                    end
                                end
                                
                                obj.modules.(context).generatedFiles.id              = prjData.generatedFiles.id;
                                obj.modules.(context).generatedFiles.lastZIPFullPath = prjData.generatedFiles.lastZIPFullPath;
                            catch 
                            end
                        end

                        obj.modules.(context).ui.system = prjData.ui.system;
                        obj.modules.(context).ui.unit   = prjData.ui.unit;
                        obj.modules.(context).ui.issue  = prjData.ui.issue;
                        obj.modules.(context).ui.entity = prjData.ui.entity;

                        reportModel = prjData.ui.reportModel;
                        if ismember(reportModel, obj.modules.(context).ui.templates)
                            obj.modules.(context).ui.reportModel = reportModel;
                        end

                        obj.issueDetails  = [obj.issueDetails, prjData.issueDetails];
                        obj.entityDetails = [obj.entityDetails, prjData.entityDetails];
                        obj.inspectedProducts = unique([obj.inspectedProducts; prjData.inspectedProducts], "rows");
    
                    otherwise
                        error('UnexpectedVersion')
                end
                msg = '';

            catch ME
                msg = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        % Função que valida a consistência e o preenchimento de dados da
        % tabela "inspectedProducts". Atualmente são 11 as regras.
        %
        % #01 "Tipo" deve estar preenchido (≠ "-").
        % #02 "Fabricante" deve estar preenchido.
        % #03 "Modelo" deve estar preenchido.
        % #04 "Valor Unit. (R$)" não pode ser negativo.
        % #05 A soma da "Qtd. uso", "Qtd. vendida", "Qtd. estoque/aduana"
        %     e "Qtd. anunciada" deve ser maior que zero.
        % #06 A soma da "Qtd. uso" e "Qtd. estoque/aduana" não pode ser 
        %     menor do que a soma "Qtd. lacradas", "Qtd. apreendidas" e
        %     "Qtd. retidas (RFB)".
        % #07 "Situação" deve estar preenchida (≠ "-").
        % #08 "Situação" e "Infração" devem ser coerentes entre si, de
        %     forma que: 
        %     • situação regular → sem infração
        %     • situação irregular → infração obrigatória
        % #09 "Valor Unit. (R$)" válido (> 0) em situação irregular.
        % #10 "Fonte do valor" deve estar preenchido em situação irregular.
        % #11 A soma da "Qtd. lacradas", "Qtd. apreendidas" e "Qtd. retidas (RFB)"
        %     não pode ser maior do que zero em situação regular.
        %-----------------------------------------------------------------%
        function [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateInspectedProducts(obj)
            ruleColumns = {                                                                                     ...
                'Tipo',                                                                                         ... #01
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
            };

            ruleViolationMatrix = zeros(height(obj.inspectedProducts), 11, 'logical');

            ruleViolationMatrix(:, 1) = string(obj.inspectedProducts.("Tipo")) == "-";
            ruleViolationMatrix(:, 2) = string(obj.inspectedProducts.("Fabricante")) == "";
            ruleViolationMatrix(:, 3) = string(obj.inspectedProducts.("Modelo")) == "";
            ruleViolationMatrix(:, 4) = obj.inspectedProducts.("Valor Unit. (R$)") < 0;
            
            ruleViolationMatrix(:, 5) = sum(obj.inspectedProducts{:, {'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada'}}, 2) <= 0;
            ruleViolationMatrix(:, 6) = sum(obj.inspectedProducts{:, {'Qtd. uso', 'Qtd. estoque/aduana'}}, 2) < sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2);
            
            ruleViolationMatrix(:, 7) =   string(obj.inspectedProducts.("Situação")) == "-";
            ruleViolationMatrix(:, 8) = ((string(obj.inspectedProducts.("Situação")) == "Regular")   & (string(obj.inspectedProducts.("Infração")) ~= "-")) | ((string(obj.inspectedProducts.("Situação")) == "Irregular") & (string(obj.inspectedProducts.("Infração")) == "-"));
            ruleViolationMatrix(:, 9) =  (string(obj.inspectedProducts.("Situação")) == "Irregular") & (obj.inspectedProducts.("Valor Unit. (R$)") <= 0);
            ruleViolationMatrix(:,10) =  (string(obj.inspectedProducts.("Situação")) == "Irregular") & (string(obj.inspectedProducts.("Fonte do valor")) == "");
            ruleViolationMatrix(:,11) =  (string(obj.inspectedProducts.("Situação")) == "Regular")   & (sum(obj.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2) > 0);

            invalidRowIndexes = find(any(ruleViolationMatrix, 2));
        end

        %-----------------------------------------------------------------%
        function subtypeList = checkTypeSubtypeProductsMapping(obj, type)
            [~, typeIndex]  = ismember(type, {obj.typeSubtypeProductsMapping.type});
            if typeIndex
                subtypeList = obj.typeSubtypeProductsMapping(typeIndex).sybtype;
            else
                subtypeList = {};
            end
        end

        %-----------------------------------------------------------------%
        function updateGeneratedFiles(obj, context, id, rawFiles, htmlFile, tableFile, zipFile)
            arguments
                obj
                context   (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                id        char = ''
                rawFiles  cell = {}
                htmlFile  char = ''
                tableFile char = ''
                zipFile   char = ''
            end

            obj.modules.(context).generatedFiles.id                  = id;
            obj.modules.(context).generatedFiles.rawFiles            = rawFiles;
            obj.modules.(context).generatedFiles.lastHTMLDocFullPath = htmlFile;
            obj.modules.(context).generatedFiles.lastTableFullPath   = tableFile;
            obj.modules.(context).generatedFiles.lastZIPFullPath     = zipFile;
        end

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
                case '.xlsx'
                    fileName = obj.modules.(context).generatedFiles.lastTableFullPath;
                case '.zip'
                    fileName = obj.modules.(context).generatedFiles.lastZIPFullPath;
            end

            if ~isfile(fileName)
                fileName = '';
                updateGeneratedFiles(obj, context)
            end
        end

        %-----------------------------------------------------------------%
        function details = getIssueDetails(obj, system, issue)
            detailsIndex = find(strcmp({obj.issueDetails.system}, system) & [obj.issueDetails.issue] == issue, 1);
            
            if isempty(detailsIndex)
                details  = '';
            else
                details  = obj.issueDetails(detailsIndex).details;
            end
        end

        %-----------------------------------------------------------------%
        function details = getEntityDetails(obj, id)
            [~, entityIndex] = ismember(id, {obj.entityDetails.id});
            
            if entityIndex
                details = obj.entityDetails(entityIndex).details;
            else
                [entityId, ~, details] = checkCNPJOrCPF(id, 'PublicAPI');

                if ~isempty(details)
                    obj.entityDetails(end+1) = struct('id', entityId, 'details', details, 'timestamp', datestr(now));
                end                
            end
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
                        hashs = cellfun(@(x, y) model.projectLib.computeInspectedProductHash('-', x, y), obj.inspectedProducts.("Fabricante")(indexHom), obj.inspectedProducts.("Modelo")(indexHom), 'UniformOutput', false);
                        obj.inspectedProducts.("Hash")(indexHom) = hashs;
                    end

                case 'delete'
                    indexes = varargin{1};
                    obj.inspectedProducts(indexes, :) = [];
            end
        end

        %-----------------------------------------------------------------%
        function updateUiInfo(obj, context, fieldName, fieldValue)
            arguments
                obj
                context    (1,:) char {mustBeMember(context, {'SEARCH', 'PRODUCTS'})}
                fieldName  (1,:) char
                fieldValue
            end

            switch fieldName
                case 'name'
                    obj.name = fieldValue;

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

        %-----------------------------------------------------------------%
        function ReadRegulatronData(obj, rootFolder)
            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
            projectFilePath  = fullfile(projectFolder,     'DataBase', 'RegulatronAdds.xlsx');
            externalFilePath = fullfile(programDataFolder, 'DataBase', 'RegulatronAdds.xlsx');

            try
                urlPreffix = util.publicLink(class.Constants.appName, rootFolder, 'RegulatronAdds');
                addsTable  = readtable(externalFilePath);
            catch
                addsTable  = readtable(projectFilePath);
            end

            obj.regulatronData.urlPreffix = urlPreffix;
            obj.regulatronData.addsTable  = addsTable;
        end

        %-----------------------------------------------------------------%
        function CreateInspectedProductsTable(obj, generalSettings)
            obj.inspectedProducts = table( ...
                'Size', [0, height(model.projectLib.INSPECTEDPRODUCTSSPECIFICATION)], ...
                'VariableTypes', model.projectLib.INSPECTEDPRODUCTSSPECIFICATION(:, 1), ...
                'VariableNames', model.projectLib.INSPECTEDPRODUCTSSPECIFICATION(:, 2) ...
            );
            
            obj.inspectedProducts.("Tipo")     = categorical(obj.inspectedProducts.("Tipo"),     generalSettings.ui.typeOfProduct.options);
            obj.inspectedProducts.("Situação") = categorical(obj.inspectedProducts.("Situação"), generalSettings.ui.typeOfSituation.options);
            obj.inspectedProducts.("Infração") = categorical(obj.inspectedProducts.("Infração"), generalSettings.ui.typeOfViolation.options);
            obj.inspectedProducts.("Sanável?") = categorical(obj.inspectedProducts.("Sanável?"), {'-', 'Sim', 'Não'});
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function prjHash = computeProjectHash(prjName, prjFile, inspectedProducts)
            hashList = sort(inspectedProducts.('Hash'));
            prjHash = Hash.sha1(sprintf('%s - %s - %s', prjName, prjFile, strjoin(hashList, ' - ')));
        end

        %-----------------------------------------------------------------%
        function hash = computeInspectedProductHash(homologation, manufacturer, model)
            hash = Hash.base64encode(strjoin({homologation, manufacturer, model}, ' - '));
        end

        %-----------------------------------------------------------------%
        function [productData, productHash] = initializeInspectedProduct(status, generalSettings, varargin)
            arguments
                status char {mustBeMember(status, {'NãoHomologado', 'Homologado'})}
                generalSettings
            end

            arguments (Repeating)
                varargin
            end

            switch status
                case 'NãoHomologado'
                    homologation = '-';
                    manufacturer = '';
                    modelName    = '';
                    optionalNote = '';

                    productHash = model.projectLib.computeInspectedProductHash( ...
                        homologation, ...
                        manufacturer, ...
                        modelName ...
                    );

                otherwise
                    rawDataTable = varargin{1};
                    indexRow = varargin{2};

                    homologation = rawDataTable.("Homologação"){indexRow};
                    
                    productHash = model.projectLib.computeInspectedProductHash( ...
                        homologation, ...
                        strjoin({rawDataTable.("Solicitante"){indexRow}, rawDataTable.("Fabricante"){indexRow}}, ' - '), ...
                        strjoin({rawDataTable.("Modelo"){indexRow}, rawDataTable.("Nome Comercial"){indexRow}}, ' - ') ...
                    );

                    manufacturer = upper(rawDataTable.("Fabricante"){indexRow});

                    modelList = unique([rawDataTable.("Modelo")(indexRow), rawDataTable.("Nome Comercial")(indexRow)], 'stable');
                    modelList(cellfun(@(x) isempty(x), modelList)) = [];
                    if isempty(modelList)
                        modelList = {''};
                        modelName = '';
                    else
                        modelName = strjoin(modelList, ' - ');
                    end            

                    indexHom = strcmp(rawDataTable.("Homologação"), homologation);
                    typeList = unique(cellstr(rawDataTable.("Tipo")(indexHom)));
                    optionalNote  = sprintf('TIPO: %s', textFormatGUI.cellstr2ListWithQuotes(typeList, 'none'));
                    if numel(modelList) > 1
                        optionalNote = sprintf('%s\nMODELO: %s', optionalNote, textFormatGUI.cellstr2ListWithQuotes(modelList, 'none'));
                    end
            end

            productData = {
                'Hash',                  productHash;
                'Homologação',           homologation;
                'Tipo',                  generalSettings.ui.typeOfProduct.default;
                'Fabricante',            manufacturer;
                'Modelo',                modelName;
                'Situação',              generalSettings.ui.typeOfSituation.default;
                'Infração',              generalSettings.ui.typeOfViolation.default;
                'Sanável?',              '-';
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
    end
    
end