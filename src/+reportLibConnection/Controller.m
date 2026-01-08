classdef (Abstract) Controller

    % Trata-se de classe abstrata, cujo método Run cria as variáveis requeridas
    % pelo biblioteca reportLib, de SupportPackages. São elas:
    % • reportInfo....: estrutura com os campos obrigatórios "App", "Version", 
    %   "Path", "Model" e "Function". Campos opcionais podem ser criados.

    % • dataOverview..: lista de estruturas com os campos obrigatórios "ID", 
    %   "InfoSet" e "HTML". Em "InfoSet", armazena-se um handle para instância 
    %   da classe model.ECD. As instância desse classe são agrupadas por 
    %   LOCALIDADE e ordenadas pelo início da monitoração.

    % • analyzedData..: instância de dataOverview (imaginando que dataOverview 
    %   é a variável que possibilita a recorrência).

    % Quando o objeto criado é uma IMAGEM, tem-se:
    % • imgSettings.: campo extraído do script .JSON que norteia a criação
    %   do relatório, o qual é uma estrutura com os campos "Origin", "Source", 
    %   "Caption", "Settings", "Intro", "Error" e "LineBreak".
    
    % Quando o objeto criado uma TABELA, tem-se:
    % • tableSettings.: campo extraído do script .JSON que norteia a criação
    %   do relatório, o qual é uma estrutura com os campos "Origin", "Source", 
    %   "Columns", "Caption", "Settings", "Intro", "Error" e "LineBreak".

    properties (Constant)
        %-----------------------------------------------------------------%
        docVersion = dictionary( ...
            ["Preliminar", "Definitiva"], ...
            [struct('version', 'preview', 'encoding', 'UTF-8'), struct('version', 'final', 'encoding', 'ISO-8859-1')] ...
        )
    end

    methods (Static)
        %-----------------------------------------------------------------%
        function Run(mainApp, callingApp, context)
            arguments
                mainApp
                callingApp
                context {mustBeMember(context, {'PRODUCTS'})} = 'PRODUCTS'
            end

            projectData = mainApp.projectData;
            generalSettings = mainApp.General;
            rootFolder = mainApp.rootFolder;

            [projectFolder, ...
             programDataFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);

            issueId = num2str(projectData.modules.(context).ui.issue);
            docName = projectData.modules.(context).ui.reportModel;
            docIndex = find(strcmp({projectData.report.templates.Name}, docName), 1);
            if isempty(docIndex)
                error('Pendente escolha do modelo de relatório.')
            end

            docType = projectData.report.templates(docIndex).DocumentType;
            docVersion = reportLibConnection.Controller.docVersion(projectData.modules.(context).ui.reportVersion);

            try
                if ~isdeployed()
                    error('ForceDebugMode')
                end
                docScript = jsondecode(fileread(fullfile(programDataFolder, 'ReportTemplates', projectData.report.templates(docIndex).File)));
            catch
                docScript = jsondecode(fileread(fullfile(projectFolder,     'ReportTemplates', projectData.report.templates(docIndex).File)));
            end

            %-------------------------------------------------------------%
            % reportInfo
            %
            % Importante observar que o campo "Function" armazena informações
            % gerais, a compor itens "Introdução", "Metodologia" e "Conclusão",
            % e informações específicas, a compor itens com recorrências, como 
            % "Resultados".
            %-------------------------------------------------------------%
            reportInfo = struct('App',      mainApp,                                                                  ...
                                'Version',  generalSettings.AppVersion,                                               ...
                                'Path',     struct('rootFolder',                 rootFolder,                          ...
                                                   'userFolder',                 generalSettings.fileFolder.userPath, ...
                                                   'tempFolder',                 generalSettings.fileFolder.tempPath, ...
                                                   'appConnection',              projectFolder,                       ...
                                                   'appDataFolder',              programDataFolder),                  ...
                                'Model',    struct('Name',                       docName,                             ...
                                                   'DocumentType',               docType,                             ...
                                                   'Script',                     docScript,                           ...
                                                   'Version',                    docVersion.version),                 ...
                                'Function', struct(...
                                                   ... % APLICÁVEIS ÀS SEÇÕES GERAIS DO RELATÓRIO
                                                   'cfg_SEARCH',                'reportLibConnection.Variable.GeneralSettings(reportInfo, "SEARCH+ReportTemplate")', ...
                                                   'cfg_PRODUCTS',              'reportLibConnection.Variable.GeneralSettings(reportInfo, "PRODUCTS+ReportTemplate")', ...
                                                   'var_Issue',                  num2str(projectData.modules.(context).ui.issue), ...
                                                   'var_Unit',                   projectData.modules.(context).ui.unit, ...
                                                   'eFiscaliza_solicitacaoCode', 'reportLibConnection.Variable.GeneralSettings(reportInfo, "Solicitação de Inspeção")', ...
                                                   'eFiscaliza_acaoCode',       'reportLibConnection.Variable.GeneralSettings(reportInfo, "Ação de Inspeção")', ...
                                                   'eFiscaliza_atividadeCode',  'reportLibConnection.Variable.GeneralSettings(reportInfo, "Atividade de Inspeção")', ...
                                                   'eFiscaliza_requester',      'reportLibConnection.Variable.GeneralSettings(reportInfo, "Unidade Demandante")', ...
                                                   'eFiscaliza_unit',           'reportLibConnection.Variable.GeneralSettings(reportInfo, "Unidade Executante")', ...
                                                   'eFiscaliza_unitCity',       'reportLibConnection.Variable.GeneralSettings(reportInfo, "Sede da Unidade Executante")', ...
                                                   'eFiscaliza_description',    'reportLibConnection.Variable.GeneralSettings(reportInfo, "Descrição da Atividade de Inspeção")', ...
                                                   'eFiscaliza_period',         'reportLibConnection.Variable.GeneralSettings(reportInfo, "Período Previsto da Fiscalização")', ...
                                                   'eFiscaliza_fiscais',        'reportLibConnection.Variable.GeneralSettings(reportInfo, "Lista de Fiscais")', ...
                                                   'eFiscaliza_sei',            'reportLibConnection.Variable.GeneralSettings(reportInfo, "Processo SEI")', ...
                                                   ...
                                                   ... % APLICÁVEIS À SEÇÃO COM RECORRÊNCIA DO RELATÓRIO
                                                   ... % 'var_Index'
                                                   'var_Id',                    'analyzedData.ID', ...
                                                   'var_EntityName',            'analyzedData.InfoSet.EntityName', ...
                                                   'var_EntityID',              'analyzedData.InfoSet.EntityID', ...
                                                   'var_EntityType',            'analyzedData.InfoSet.EntityType', ...
                                                   'tableProducts',             'reportLibConnection.Table.InspectedProducts(analyzedData.InfoSet.Products, tableSettings)', ...
                                                   'tableProducts_irregular',   'reportLibConnection.Table.InspectedProducts(analyzedData.InfoSet.Products, tableSettings, "Irregular")', ...
                                                   'tableProducts_regular',     'reportLibConnection.Table.InspectedProducts(analyzedData.InfoSet.Products, tableSettings, "Regular")', ...
                                                   'tableSummarized',           'reportLibConnection.Table.Summarized(analyzedData.InfoSet.Products, tableSettings)', ...
                                                   'tableSummarized_irregular', 'reportLibConnection.Table.Summarized(analyzedData.InfoSet.Products, tableSettings, "Irregular")', ...
                                                   'tableSummarized_regular',   'reportLibConnection.Table.Summarized(analyzedData.InfoSet.Products, tableSettings, "Regular")'), ...
                                'Project',  projectData, ...
                                'Context',  context,     ...
                                'Object',   [],          ...
                                'Settings', generalSettings);

            fieldsUnnecessary = {'rootFolder', 'entryPointFolder', 'tempSessionFolder', 'ctfRoot'};
            fieldsUnnecessary(cellfun(@(x) ~isfield(reportInfo.Version.application, x), fieldsUnnecessary)) = [];
            if ~isempty(fieldsUnnecessary)
                reportInfo.Version.application = rmfield(reportInfo.Version.application, fieldsUnnecessary);
            end

            %-------------------------------------------------------------%
            % dataOverview
            %
            % Caso dataOverview não seja escalar e exista um item no relatório
            % com recorrência, a própria lib cria a variável "var_Index", acessível 
            % em "reportInfo.Function.var_Index".
            % dataOverview = struct('ID', {}, 'InfoSet', {}, 'HTML', {});
            %
            % A priori, não se vislumbra uso da recorrência no SCH.
            %-------------------------------------------------------------%
            dataOverview(1).ID      = projectData.modules.(context).ui.entity.id;
            dataOverview(1).InfoSet = struct('EntityType', projectData.modules.(context).ui.entity.type, ...
                                             'EntityID',   projectData.modules.(context).ui.entity.id,   ...
                                             'EntityName', projectData.modules.(context).ui.entity.name, ...                                             
                                             'Products',   projectData.inspectedProducts);
            dataOverview(1).HTML    = [];


            %-------------------------------------------------------------%
            % Conexão com reportLib, parte do repositório "SupportPackages"
            %-------------------------------------------------------------%
            HTMLDocContent = reportLib.Controller(reportInfo, dataOverview);


            %-------------------------------------------------------------%
            % Exclui container criado para os plots, caso aplicável.
            %-------------------------------------------------------------%
            hFigure    = mainApp.UIFigure;
            hContainer = findobj(hFigure, 'Tag', 'reportGeneratorContainer');
            if ~isempty(hContainer)
                delete(hContainer)
            end


            %-------------------------------------------------------------%
            % Em sendo a versão "Preliminar", apenas apresenta o html no
            % navegador. Por outro lado, em sendo a versão "Definitiva",
            % salva-se o arquivo ZIP em pasta local.
            %-------------------------------------------------------------%
            [baseFullFileName, baseFileName] = appEngine.util.DefaultFileName(generalSettings.fileFolder.tempPath, 'SCH_FinalReport', issueId);
            HTMLFile = [baseFullFileName '.html'];
            
            writematrix(HTMLDocContent, HTMLFile, 'QuoteStrings', 'none', 'FileType', 'text', 'Encoding', docVersion.encoding)

            switch docVersion.version
                case 'preview'
                    web(HTMLFile, '-new')
                    updateGeneratedFiles(projectData, context)

                case 'final'
                    JSONFile = [baseFullFileName '.json'];
                    XLSXFile = [baseFullFileName '.xlsx'];
                    ZIPFile  = ui.Dialog(callingApp.UIFigure, 'uiputfile', '', {'*.zip', 'SCH'}, fullfile(generalSettings.fileFolder.userPath, [baseFileName '.zip']));
                    if isempty(ZIPFile)
                        return
                    end
                    
                    jsonFileConfig  = { ...
                        generalSettings.ui.reportTable.exportedFiles.sharepoint.name, ...
                        generalSettings.ui.reportTable.exportedFiles.sharepoint.label ...
                    };
                    jsonFileTable = renamevars(projectData.inspectedProducts, jsonFileConfig{:});
                    jsonFileContent = struct( ...
                        'issueId', issueId,                    ...
                        'entity',  projectData.modules.(context).ui.entity, ...
                        'items',   jsonFileTable ...
                    );

                    xlsxFileConfig  = generalSettings.ui.reportTable.exportedFiles.eFiscaliza;
                    xlsxFileContent = reportLibConnection.Table.InspectedProducts(projectData.inspectedProducts, xlsxFileConfig);
                    xlsxFileContent = renamevars(xlsxFileContent, xlsxFileConfig.Columns, {xlsxFileConfig.Settings.ColumnName});

                    writematrix(jsonencode(jsonFileContent, 'PrettyPrint', true), JSONFile, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite")
                    writetable(xlsxFileContent, XLSXFile, "UseExcel", false, "Sheet", "Upload", "FileType", "spreadsheet", "WriteMode", "replacefile")

                    ZIPFileList = {HTMLFile, JSONFile, XLSXFile};
                    zip(ZIPFile, ZIPFileList)

                    id = model.ProjectBase.computeProjectHash('', '', projectData.inspectedProducts, [], []);
                    updateGeneratedFiles(projectData, context, id, {}, HTMLFile, JSONFile, XLSXFile, ZIPFile)
            end
        end
    end
end