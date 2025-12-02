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
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
    end


    methods
        %-----------------------------------------------------------------%
        function obj = projectLib(mainApp, rootFolder)            
            obj.mainApp    = mainApp;
            obj.rootFolder = rootFolder;

            ReadReportTemplates(obj, rootFolder)
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
        function CreateInspectedProductsTable(obj, generalSettings)
            obj.inspectedProducts = table( ...
                'Size', [0, 26], ...
                'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'categorical', 'cell', 'cell', 'cell', 'logical', 'logical', 'logical', 'double', 'cell', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'cell', 'cell', 'categorical', 'categorical', 'categorical', 'cell'}, ...
                'VariableNames', {'Hash', 'Homologação', 'Importador', 'Código aduaneiro', 'Tipo', 'Subtipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', 'Fonte do valor', 'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Lacre', 'PLAI', 'Situação', 'Infração', 'Sanável?', 'Informações adicionais'} ...
            );
            
            obj.inspectedProducts.("Tipo")     = categorical(obj.inspectedProducts.("Tipo"),     generalSettings.ui.typeOfProduct.options);
            obj.inspectedProducts.("Situação") = categorical(obj.inspectedProducts.("Situação"), generalSettings.ui.typeOfSituation.options);
            obj.inspectedProducts.("Infração") = categorical(obj.inspectedProducts.("Infração"), generalSettings.ui.typeOfViolation.options);
            obj.inspectedProducts.("Sanável?") = categorical(obj.inspectedProducts.("Sanável?"), {'-', 'Sim', 'Não'});
        end

        %-----------------------------------------------------------------%
        function subtypeList = checkTypeSubtypeProductsMapping(obj, type)
            [~, typeIndex] = ismember(type, {obj.typeSubtypeProductsMapping.type});
            subtypeList = obj.typeSubtypeProductsMapping(typeIndex).sybtype;
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
    end
    
end