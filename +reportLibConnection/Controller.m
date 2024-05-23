classdef (Abstract) Controller

    properties (Constant)
        %-----------------------------------------------------------------%
        fileName   = 'reportLibConfig.cfg'
        docVersion = dictionary(["Preliminar", "Definitiva"], ["preview", "final"])
    end

    methods (Static)
        %-----------------------------------------------------------------%
        function [modelFileContent, projectFolder, appDataFolder] = Read(rootFolder)
            [projectFolder, ...
             appDataFolder]  = reportLibConnection.Controller.Path(rootFolder);
            fileName         = reportLibConnection.Controller.fileName;
        
            projectFilePath  = fullfile(projectFolder, fileName);
            appDataFilePath  = fullfile(appDataFolder, fileName);
        
            modelFileContent = jsondecode(fileread(projectFilePath));
            try
                if ~isfolder(appDataFolder)
                    mkdir(appDataFolder)
                end
        
                if ~isfile(appDataFilePath)
                    copyfile(projectFilePath, appDataFolder, 'f');

                    jsonFiles = dir(fullfile(projectFolder, '*.json'));
                    for ii = 1:numel(jsonFiles)
                        jsonFilePath = fullfile(jsonFiles(ii).folder, jsonFiles(ii).name);
                        copyfile(jsonFilePath, appDataFolder, 'f');
                    end
                else
                    modelFileContent = jsondecode(fileread(appDataFilePath));
                end
            catch
            end        
        end


        %-----------------------------------------------------------------%
        function [projectFolder, appDataFolder] = Path(rootFolder)
            projectFolder = fullfile(rootFolder, '+reportLibConnection');
            appDataFolder = fullfile(getenv('PROGRAMDATA'), 'ANATEL', class.Constants.appName, 'reportLibConnection');
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