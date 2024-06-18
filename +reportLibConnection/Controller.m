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
        function tempFileName = Run(app, webView)
            % A função Controller, da reportLib, espera os argumentos reportInfo 
            % e dataOverview.

            [modelFileContent, ...
             projectFolder,    ...
             appDataFolder] = reportLibConnection.Controller.Read(app.rootFolder);

            docIndex        = find(strcmp({modelFileContent.Name}, app.report_ModelName.Value), 1);
            docScript       = jsondecode(fileread(fullfile(appDataFolder, modelFileContent(docIndex).File)));
            
            % reportInfo
            reportInfo = struct('App',      app,                                         ...
                                'Version',  fcn.envVersion(app.rootFolder, 'reportLib'), ...
                                'Path',     struct('rootFolder',     app.rootFolder,     ...
                                                   'appConnection',  projectFolder,      ...
                                                   'appDataFolder',  appDataFolder),     ...
                                'Model',    struct('Name',           app.report_ModelName.Value,              ...
                                                   'DocumentType',   modelFileContent(docIndex).DocumentType, ...
                                                   'Script',         docScript,                               ...
                                                   'Version',        reportLibConnection.Controller.docVersion(app.report_Version.Value)), ...
                                'Function', struct('var_Issue',      num2str(app.report_Issue.Value),                                      ...
                                                   'var_EntityName', 'analyzedData.InfoSet.EntityName',                                    ...
                                                   'var_EntityID',   'analyzedData.InfoSet.EntityID',                                      ...
                                                   'var_EntityType', 'analyzedData.InfoSet.EntityType',                                    ...
                                                   'tableFcn1',      'reportLibConnection.reportTable_type1(analyzedData.InfoSet.reportTable, tableSettings)', ...
                                                   'tableFcn2',      'reportLibConnection.reportTable_type2(analyzedData.InfoSet.reportTable, tableSettings)'));
            
            % dataOverview (aceita recorrência, registra imagens e tabelas externas
            % no campo "HTML")
            dataOverview(1).ID      = app.report_EntityID.Value;
            dataOverview(1).InfoSet = struct('EntityName',           upper(app.report_Entity.Value),     ...
                                             'EntityID',             app.report_EntityID.Value,          ...
                                             'EntityType',           upper(app.report_EntityType.Value), ...
                                             'reportTable',          app.listOfProducts);
            dataOverview(1).HTML    = [];
            
            % docContent
            docContent   = reportLib.Controller(reportInfo, dataOverview);
            tempFileName = [tempname(tempdir) '.html'];
            writematrix(docContent, tempFileName, 'QuoteStrings', 'none', 'FileType', 'text')
            if webView                
                web(tempFileName)
            end
        end
    end
end