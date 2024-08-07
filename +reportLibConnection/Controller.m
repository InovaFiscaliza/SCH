classdef (Abstract) Controller

    properties (Constant)
        %-----------------------------------------------------------------%
        fileName   = 'reportLibConfig.cfg'
        docVersion = dictionary(["Preliminar", "Definitiva"], ["preview", "final"])
    end

    methods (Static)
        %-----------------------------------------------------------------%
        function [modelFileContent, projectFolder, externalFolder] = Read(rootFolder)
            [projectFolder, ...
             externalFolder] = fcn.Path(rootFolder);
            fileName         = reportLibConnection.Controller.fileName;
        
            projectFilePath  = fullfile(projectFolder,  fileName);
            externalFilePath = fullfile(externalFolder, fileName);
        
            try
                modelFileContent = jsondecode(fileread(externalFilePath));
            catch
                modelFileContent = jsondecode(fileread(projectFilePath));
            end        
        end


        %-----------------------------------------------------------------%
        function [HTMLDocFullPath, CSVDocFullPath] = Run(app, webView)
            % A função Controller, da reportLib, espera os argumentos reportInfo 
            % e dataOverview.
            [modelFileContent, ...
             projectFolder,    ...
             appDataFolder] = reportLibConnection.Controller.Read(app.rootFolder);

            docIndex   = find(strcmp({modelFileContent.Name}, app.report_ModelName.Value), 1);
            docType    = modelFileContent(docIndex).DocumentType;
            docScript  = jsondecode(fileread(fullfile(appDataFolder, modelFileContent(docIndex).File)));            
            docVersion = reportLibConnection.Controller.docVersion(app.report_Version.Value);
            
            % reportInfo
            reportInfo = struct('App',      app,                                         ...
                                'Version',  fcn.envVersion(app.rootFolder, 'reportLib', app.rawDataTable, app.releasedData), ...
                                'Path',     struct('rootFolder',     app.rootFolder,     ...
                                                   'appConnection',  projectFolder,      ...
                                                   'appDataFolder',  appDataFolder),     ...
                                'Model',    struct('Name',           app.report_ModelName.Value, ...
                                                   'DocumentType',   docType,                    ...
                                                   'Script',         docScript,                  ...
                                                   'Version',        docVersion),                ...
                                'Function', struct('var_Issue',      num2str(app.report_Issue.Value),   ...
                                                   'var_EntityName', 'analyzedData.InfoSet.EntityName', ...
                                                   'var_EntityID',   'analyzedData.InfoSet.EntityID',   ...
                                                   'var_EntityType', 'analyzedData.InfoSet.EntityType', ...
                                                   'tableFcn1',      'reportLibConnection.reportTable_type1(analyzedData.InfoSet.reportTable, tableSettings)', ...
                                                   'tableFcn2',      'reportLibConnection.reportTable_type2(analyzedData.InfoSet.reportTable, tableSettings)'));
            
            % dataOverview (aceita recorrência, registra imagens e tabelas externas
            % no campo "HTML")
            dataOverview(1).ID      = app.report_EntityID.Value;
            dataOverview(1).InfoSet = struct('EntityName',  upper(app.report_Entity.Value),     ...
                                             'EntityID',    app.report_EntityID.Value,          ...
                                             'EntityType',  upper(app.report_EntityType.Value), ...
                                             'reportTable', app.listOfProducts);
            dataOverview(1).HTML    = [];
            
            % Documentos:
            switch docVersion
                case 'preview'; tempFullPath = tempname;
                case 'final';   tempFullPath = class.Constants.DefaultFileName(app.config_Folder_userPath.Value, 'Report', app.report_Issue.Value);
            end
            HTMLDocFullPath = [tempFullPath '.html'];
            CSVDocFullPath  = [tempFullPath '.csv'];
            
            HTMLDocContent  = reportLib.Controller(reportInfo, dataOverview);
            writematrix(HTMLDocContent, HTMLDocFullPath, 'QuoteStrings', 'none', 'FileType', 'text')
            if webView                
                web(HTMLDocFullPath)
            end

            writetable(app.listOfProducts(:, class.Constants.report_TableColumns2CSV), CSVDocFullPath, "QuoteStrings", "all");
        end
    end
end