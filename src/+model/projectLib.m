classdef projectLib < handle

    properties
        %-----------------------------------------------------------------%
        name (1,:) char = ''
        file (1,:) char = ''

        report  = struct( ...
            'templates', [], ...
            'settings',  [] ...
        )

        modules = struct( ...
            'SEARCH', struct('annotationTable', [], ...
                             'generatedFiles',  struct('rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                             'ui',              struct('system',        '',  ...
                                                       'unit',          '',  ...
                                                       'issue',         -1,  ...
                                                       'templates',    {{}}, ...
                                                       'reportModel',   '',  ...
                                                       'reportVersion', 'Preliminar', ...
                                                       'entity', struct('type', '', 'name', '', 'id', ''))), ...
            'PRODUCTS', struct('annotationTable', [], ...
                             'generatedFiles',  struct('rawFiles', {{}}, 'lastHTMLDocFullPath', '', 'lastTableFullPath', '', 'lastZIPFullPath', ''), ...
                             'ui',              struct('system',        '',  ...
                                                       'unit',          '',  ...
                                                       'issue',         -1,  ...
                                                       'templates',    {{}}, ...
                                                       'reportModel',   '',  ...
                                                       'reportVersion', 'Preliminar', ...
                                                       'entity', struct('type', '', 'name', '', 'id', ''))) ...
        )

        inspectedProducts
        typeSubtypeProductsMapping
        
        regulatronData = struct( ...
            'urlPreffix', '', ...
            'addsTable', [] ...
        )
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
    end


    properties (Constant)
        %-----------------------------------------------------------------%
        INSPECTEDPRODUCTSSPECIFICATION = {
            'cell',        'Hash';
            'cell',        'Homologação';
            'cell',        'Importador';
            'cell',        'Código aduaneiro';
            'categorical', 'Tipo';
            'cell',        'Subtipo';
            'cell',        'Fabricante';
            'cell',        'Modelo';
            'logical',     'RF?';
            'logical',     'Em uso?';
            'logical',     'Interferência?';
            'double',      'Valor Unit. (R$)';
            'cell',        'Fonte do valor';
            'uint32',      'Qtd. uso';
            'uint32',      'Qtd. vendida';
            'uint32',      'Qtd. estoque/aduana';
            'uint32',      'Qtd. anunciada';
            'uint32',      'Qtd. lacradas';
            'uint32',      'Qtd. apreendidas';
            'uint32',      'Qtd. retidas (RFB)';
            'cell',        'Lacre';
            'cell',        'PLAI';
            'categorical', 'Situação';
            'categorical', 'Infração';
            'categorical', 'Sanável?';
            'cell',        'Informações adicionais'
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

            ReadReportTemplates(obj, rootFolder)
            ReadRegulatronData(obj, rootFolder)
            CreateInspectedProductsTable(obj, mainApp.General)

            obj.typeSubtypeProductsMapping = mainApp.General.ui.typeOfProduct.mapping;
        end

        %-----------------------------------------------------------------%
        function Restart(obj)
            % ...

            updateGeneratedFiles(obj, 'File')
            updateGeneratedFiles(obj, 'ECD')
        end

        %-----------------------------------------------------------------%
        function ReadReportTemplates(obj, rootFolder)
            [projectFolder, ...
             programDataFolder] = appUtil.Path(class.Constants.appName, rootFolder);
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
            moduleNameList   = fieldnames(obj.modules);
            templateNameList = {obj.report.templates.Name};

            for ii = 1:numel(moduleNameList)
                templateIndexes = ismember({obj.report.templates.Module}, moduleNameList(ii));
                obj.modules.(moduleNameList{ii}).ui.templates = [{''}, templateNameList(templateIndexes)];
            end
        end

        %-----------------------------------------------------------------%
        function ReadRegulatronData(obj, rootFolder)
            [projectFolder, ...
             programDataFolder] = appUtil.Path(class.Constants.appName, rootFolder);
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
        function updateGeneratedFiles(obj, context, rawFiles, htmlFile, tableFile, zipFile)
            arguments
                obj
                context   (1,:) char {mustBeMember(context, {'File', 'ECD'})}
                rawFiles  cell = {}
                htmlFile  char = ''
                tableFile char = ''
                zipFile   char = ''
            end

            obj.modules.(context).generatedFiles.rawFiles            = rawFiles;
            obj.modules.(context).generatedFiles.lastHTMLDocFullPath = htmlFile;
            obj.modules.(context).generatedFiles.lastTableFullPath   = tableFile;
            obj.modules.(context).generatedFiles.lastZIPFullPath     = zipFile;
        end

        %-----------------------------------------------------------------%
        function updateUiInfo(obj, context, fieldName, fieldValue)
            arguments
                obj
                context    (1,:) char {mustBeMember(context, {'File', 'ECD'})}
                fieldName  (1,:) char
                fieldValue
            end

            obj.modules.(context).ui.(fieldName) = fieldValue;
        end

        %-----------------------------------------------------------------%
        function filename = getGeneratedDocumentFileName(obj, fileExt, context)
            arguments
                obj
                fileExt (1,:) char {mustBeMember(fileExt, {'rawFiles', '.html', '.xlsx', '.zip'})}
                context (1,:) char {mustBeMember(context, {'File', 'ECD'})}
            end

            switch fileExt
                case 'rawFiles'
                    filename = obj.modules.(context).generatedFiles.rawFiles;
                case '.html'
                    filename = obj.modules.(context).generatedFiles.lastHTMLDocFullPath;
                case '.xlsx'
                    filename = obj.modules.(context).generatedFiles.lastTableFullPath;
                case '.zip'
                    filename = obj.modules.(context).generatedFiles.lastZIPFullPath;
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
    end


    methods (Static = true)
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