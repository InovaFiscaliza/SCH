classdef mobileReportLib_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        GridLayout2             matlab.ui.container.GridLayout
        UploadFinalFile         matlab.ui.control.Button
        GenerateReport          matlab.ui.control.Button
        reportPanel             matlab.ui.container.Panel
        reportGrid              matlab.ui.container.GridLayout
        reportEntityPanel       matlab.ui.container.Panel
        reportEntityGrid        matlab.ui.container.GridLayout
        reportEntityName        matlab.ui.control.EditField
        reportEntityNameLabel   matlab.ui.control.Label
        reportEntityId          matlab.ui.control.EditField
        reportEntityIdCheck     matlab.ui.control.Image
        reportEntityIdLabel     matlab.ui.control.Label
        reportEntityType        matlab.ui.control.DropDown
        reportEntityTypeLabel   matlab.ui.control.Label
        reportEntityPanelLabel  matlab.ui.control.Label
        reportVersion           matlab.ui.control.DropDown
        reportVersionLabel      matlab.ui.control.Label
        reportModel             matlab.ui.control.DropDown
        reportModelLabel        matlab.ui.control.Label
        reportLabel             matlab.ui.control.Label
        eFiscalizaPanel         matlab.ui.container.Panel
        eFiscalizaGrid          matlab.ui.container.GridLayout
        eFiscalizaIssueDetails  matlab.ui.control.Image
        eFiscalizaIssue         matlab.ui.control.NumericEditField
        eFiscalizaIssueLabel    matlab.ui.control.Label
        eFiscalizaUnit          matlab.ui.control.DropDown
        eFiscalizaUnitLabel     matlab.ui.control.Label
        eFiscalizaSystem        matlab.ui.control.DropDown
        eFiscalizaSystemLabel   matlab.ui.control.Label
        eFiscalizaLabel         matlab.ui.control.Label
        prjPanel                matlab.ui.container.Panel
        prjGrid                 matlab.ui.container.GridLayout
        prjLastReportDelete     matlab.ui.control.Image
        prjLastReportView       matlab.ui.control.Image
        prjLastReport           matlab.ui.control.EditField
        prjLastReportLabel      matlab.ui.control.Label
        prjFile                 matlab.ui.control.Label
        prjName                 matlab.ui.control.EditField
        prjNameLabel            matlab.ui.control.Label
        prjNewProjectButton     matlab.ui.control.Image
        prjSaveButton           matlab.ui.control.Image
        prjOpenFileButton       matlab.ui.control.Image
        prjLabel                matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryAppMobile'
        Context = 'PRODUCTS'
        AppHandleNameInBase = ''
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        jsBackDoor

        mainApp
        progressDialog
        projectData
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'textHighlight'
                        % Retorno dos botões de showTextHighlight.
                        dataTag = event.HTMLEventData.dataTag;
                        if isstruct(dataTag) && isfield(dataTag, 'action') && strcmp(event.HTMLEventData.id, 'confirm')
                            switch dataTag.action
                                case 'generateReport'
                                    reportDispatchOperation(app, 'onReportGenerate')
                            end
                        end

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, eventName, varargin)
            try
                switch class(callingApp)
                    case {'mainApp.mobile', 'mainApp.mobile_exported'}
                        switch eventName
                            % mainApp.mobile >> auxApp.mobileReportLib
                            % auxApp.mobileProducts >> mainApp.mobile >> auxApp.mobileReportLib
                            case {'updateInspectedProducts', ...
                                  'onInspectedProductEdited', ...
                                  'onReportGenerate',         ...
                                  'onFinalReportFileChanged'}
                                updatePanel(app, app.Context)

                            case 'onFetchIssueDetails'
                                system   = varargin{1};
                                issue    = varargin{2};
                                details  = varargin{3};
                                msgError = varargin{4};

                                if ~isempty(msgError)
                                    error(msgError)
                                end

                                msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                                showTextHighlight(app, 'info.svg', 'Detalhes da Inspeção', msg, 'info', [])

                            otherwise
                                error('auxApp:mobileReportLib:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end

                    otherwise
                        error('auxApp:mobileReportLib:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.prjPanel;
                app.eFiscalizaPanel;
                app.reportPanel;
                app.reportEntityPanel;
                app.prjName;
                app.prjLastReport;
                app.eFiscalizaSystem;
                app.eFiscalizaUnit;
                app.eFiscalizaIssue;
                app.reportModel;
                app.reportVersion;
                app.reportEntityType;
                app.reportEntityId;
                app.reportEntityName
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);
    
            try
                sendEventToHTMLSource(app.mainApp.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.prjPanel.UserData.id,          'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.eFiscalizaPanel.UserData.id,   'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.reportPanel.UserData.id,       'generation', 0, 'style', struct('backgroundColor', 'transparent')), ...
                    struct('appName', appName, 'dataTag', app.reportPanel.UserData.id,       'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.reportEntityPanel.UserData.id, 'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.prjName.UserData.id,           'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.prjLastReport.UserData.id,     'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.eFiscalizaSystem.UserData.id,  'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.eFiscalizaUnit.UserData.id,    'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.eFiscalizaIssue.UserData.id,   'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.reportModel.UserData.id,       'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.reportVersion.UserData.id,     'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.reportEntityType.UserData.id,  'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.reportEntityId.UserData.id,    'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.reportEntityName.UserData.id,  'generation', 1, 'style', struct('borderColor', '#AEBBC2')) ...
                });
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = app.mainApp.projectData;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            set([app.prjPanel, app.eFiscalizaPanel, app.reportPanel, app.reportEntityPanel], 'BorderColor', '#D5DDE1')
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updatePanel(app, app.Context)
        end
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel(app, context)
            % PROJECT INITIALIZATION
            if isempty(app.projectData.modules.(context).ui.system) && ~isequal(app.projectData.modules.(context).ui.system, app.mainApp.General.reportLib.system)
                updateUiInfo(app.projectData, context, 'system', app.mainApp.General.reportLib.system)
            end
            
            if isempty(app.projectData.modules.(context).ui.unit) && ~isequal(app.projectData.modules.(context).ui.unit, app.mainApp.General.reportLib.unit)
                updateUiInfo(app.projectData, context, 'unit', app.mainApp.General.reportLib.unit)
            end

            if isempty(app.projectData.modules.(context).ui.entityTypes)
                updateUiInfo(app.projectData, context, 'entityTypes', app.mainApp.General.reportLib.entityType.options)
                app.projectData.modules.(context).ui.entity.type = app.mainApp.General.reportLib.entityType.default;
            end

            % PROJECT PANEL
            app.prjName.Value = app.projectData.name;
            app.prjSaveButton.Enable = ~isempty(app.projectData.name);
            
            prjFileText = '(projeto ainda não exportado)';
            if isfile(app.projectData.file)
                [~, prjFileName, prjFileExt] = fileparts(app.projectData.file);
                prjFileText = [prjFileName prjFileExt];
            end
            app.prjFile.Text = prjFileText;

            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);
            if isfile(lastHTMLDocFullPath)
                [~, fileName, fileExt] = fileparts(lastHTMLDocFullPath);
                lastHTMLDocFullPath = [fileName, fileExt];
            end
            app.prjLastReport.Value = lastHTMLDocFullPath;
            set([app.prjLastReportView, app.prjLastReportDelete], 'Enable', ~isempty(app.prjLastReport.Value))

            % eFISCALIZA PANEL
            app.eFiscalizaSystem.Value = app.projectData.modules.(context).ui.system;
            app.eFiscalizaIssue.Value  = app.projectData.modules.(context).ui.issue;
            set(app.eFiscalizaUnit, 'Items', app.mainApp.General.eFiscaliza.defaultValues.unit, 'Value', app.projectData.modules.(context).ui.unit)
            app.eFiscalizaIssueDetails.Enable = (app.eFiscalizaIssue.Value > 0) && ~isinf(app.eFiscalizaIssue.Value);

            % REPORT PANEL
            set(app.reportModel, 'Items', app.projectData.modules.(context).ui.templates, 'Value', app.projectData.modules.(context).ui.reportModel)
            app.reportVersion.Value    = app.projectData.modules.(context).ui.reportVersion;

            set(app.reportEntityType, 'Items', app.projectData.modules.(context).ui.entityTypes, 'Value', app.projectData.modules.(context).ui.entity.type)
            app.reportEntityName.Value = app.projectData.modules.(context).ui.entity.name;
            
            if app.projectData.modules.(context).ui.entity.status
                backgroundColor = [1,1,1];
                fontColor       = [0,0,0];
            else
                backgroundColor = '#c80b0f';
                fontColor       = [1,1,1];
            end
            set(app.reportEntityId, 'Value', app.projectData.modules.(context).ui.entity.id, 'BackgroundColor', backgroundColor, 'FontColor', fontColor)
            app.reportEntityIdCheck.Enable = ~isempty(app.reportEntityId.Value);

            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            reportFinalVersionGenerated = ~isempty(app.projectData.modules.(app.Context).generatedFiles.lastHTMLDocFullPath);
            app.UploadFinalFile.Enable = reportFinalVersionGenerated;
        end

        %-----------------------------------------------------------------%
        function reportDispatchOperation(app, eventName)
            if isempty(app.mainApp.eFiscalizaObj) || ~isvalid(app.mainApp.eFiscalizaObj)
                eventData = ws.eFiscaliza.getCredentials('auto', app.mainApp.executionMode, app.jsBackDoor, eventName, app.Context);
                if ~isempty(eventData)
                    eventData.uuid = eventName;
                    eventData.context = app.Context;

                    ipcMainJSEventsHandler(app.mainApp, struct('HTMLEventName', 'customForm', 'HTMLEventData', eventData))
                end
            else
                ipcMainMatlabCallsHandler(app.mainApp, app, eventName, app.Context)
            end
        end

        %-----------------------------------------------------------------%
        function showTextHighlight(app, imageUrl, title, message, action, buttons)
            % "buttons" é um vetor de estruturas com os campos "id" e "label". O clique em 
            % um botão retorna ao método ipcSecondaryJSEventsHandler o "id" e o "dataTag".
            % O contexto "REPORT" (tag da aba) roteia o evento do mainApp a este módulo.
            if isempty(buttons)
                html = ['<div style="line-height: 18px;">' message '</div>'];

            else
                buttonStyle = 'padding: 0 30px; height: 38px; background-color: #087dba; color: #ffffff; border: 1px solid #7d7d7d; border-radius: 5px; font-size: 12px; cursor: pointer;';
                buttonsHtml = '';
                for ii = 1:numel(buttons)
                    margin = '';
                    if ii > 1
                        margin = ' margin-left: 8px;';
                    end
                    buttonsHtml = [buttonsHtml sprintf('<button id="%s" type="button" style="%s%s">%s</button>', buttons(ii).id, buttonStyle, margin, buttons(ii).label)]; %#ok<AGROW>
                end

                html = [ ...
                    '<div style="display: grid; grid-template-rows: auto 1fr auto; flex: 1 1 auto; line-height: 18px;">' ...
                        '<div>' message '</div>' ...
                        '<div></div>' ...
                        '<div style="text-align: right;">' buttonsHtml '</div>' ...
                    '</div>' ...
                ];
            end

            sendEventToHTMLSource(app.jsBackDoor, 'textHighlight', struct( ...
                'dataTag',  struct('context', 'REPORT', 'action', action), ...
                'imageUrl', imageUrl, ...
                'title',    title, ...
                'width',    85, ...
                'height',   60, ...
                'html',     html ...
            ));
        end

        %-----------------------------------------------------------------%
        function showConfirmationTextHighlight(app, title, message, action)
            buttons = struct('id', {'confirm', 'cancel'}, 'label', {'Sim', 'Não'});
            showTextHighlight(app, 'warning-20px-red.svg', title, message, action, buttons)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                appEngine.boot(app, app.Role, mainApp)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Image clicked function: prjNewProjectButton
        function onProjectRestart(app, event)
            
            msgQuestion = 'Deseja excluir todas as referências do projeto (incluindo a lista de produtos inspecionados) e iniciar um novo projeto?';
            selection   = ui.Dialog(app.UIFigure, "uiconfirm", msgQuestion, {'Sim', 'Não'}, 1, 2, {'Icon', 'error'});
            if strcmp(selection, 'Não')
                return
            end
    
            context = app.Context;
            restart(app.projectData, {context}, app.mainApp.General)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onProjectRestart', context)
            updatePanel(app, context)

        end

        % Image clicked function: prjOpenFileButton
        function onProjectLoad(app, event)
            
            appName  = class.Constants.appName;
            context  = app.Context;
            
            [fileFullPath, fileFolder] = ui.Dialog(app.UIFigure, 'uigetfile', '', {'*.mat', [appName ' (*.mat)']}, app.mainApp.General.fileFolder.lastVisited, {'MultiSelect', 'off'});
            if isempty(fileFullPath)
                return
            end
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', fileFolder)

            d = ui.Dialog(app.UIFigure, "progressdlg", "Em andamento...");
            
            try
                msg = load(app.projectData, 'file', fileFullPath, app.mainApp.General);
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onProjectLoad', context)
                updatePanel(app, context)

                if ~isempty(msg)
                    ui.Dialog(app.UIFigure, "warning", msg)
                end

            catch ME
                ui.Dialog(app.UIFigure, "error", ME.message);
            end
            
            delete(d)

        end

        % Image clicked function: prjSaveButton
        function onProjectSave(app, event)
            
            appName  = class.Constants.appName;
            context  = app.Context;

            if isfile(app.projectData.file)
                if ~checkIfUpdateNeeded(app.projectData)
                    msgQuestion = sprintf('Ao que parece, o projeto "<b>%s</b>" não sofreu alterações.<br><br>Deseja continuar mesmo assim?', app.projectData.name);
                    selection   = ui.Dialog(app.UIFigure, "uiconfirm", msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if strcmp(selection, 'Não')
                        return
                    end
                end

                [defaultPath, defaultFile] = fileparts(app.projectData.file);
                defaultName = fullfile(defaultPath, defaultFile);
            else
                defaultName = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, [appName '_ProjectData'], -1);
            end
            
            projectName = app.projectData.name;
            projectFile = ui.Dialog(app.UIFigure, 'uiputfile', '', {'*.mat', [appName ' (*.mat)']}, defaultName);
            if isempty(projectFile)
                return
            end

            save(app.projectData, context, projectName, projectFile, app.mainApp.General.reportLib.outputCompressionMode)
            IndexedDBCache(app.projectData)
            updatePanel(app, context)

        end

        % Value changing function: prjName
        function onProjectNameChanging(app, event)
            
            changingValue = event.Value;
            app.prjSaveButton.Enable = ~isempty(strtrim(changingValue));
            
        end

        % Value changed function: eFiscalizaIssue, eFiscalizaSystem, 
        % ...and 7 other components
        function onProjectInfoUpdate(app, event)

            context = app.Context;

            fieldValue = event.Value;
            switch event.Source
                case app.prjName
                    fieldName = 'name';
                    fieldValue = strtrim(fieldValue);

                case app.eFiscalizaSystem
                    fieldName = 'system';

                case app.eFiscalizaUnit
                    fieldName = 'unit';

                case app.eFiscalizaIssue
                    fieldName = 'issue';

                case app.reportModel
                    fieldName = 'reportModel';

                case app.reportVersion
                    fieldName = 'reportVersion';

                case {app.reportEntityType, app.reportEntityId, app.reportEntityName}
                    [entityId, status] = checkCNPJOrCPF(app.reportEntityId.Value, 'NumberValidation');

                    fieldName = 'entity';
                    fieldValue = struct( ...
                        'type', strtrim(app.reportEntityType.Value), ...
                        'name', strtrim(app.reportEntityName.Value), ...
                        'id', entityId, ...
                        'status', status ...
                    );

                case app.reportEntityIdCheck
                    fieldName = 'entityDetails';
            end

            updateUiInfo(app.projectData, context, fieldName, fieldValue)
            updatePanel(app, context)
            
        end

        % Image clicked function: eFiscalizaIssueDetails
        function onFetchIssueDetails(app, event)
            
            % <VALIDAÇÕES>
            context = app.Context;
            issue = app.projectData.modules.(context).ui.issue;
            
            if ~validateReportRequirements(app.projectData, context, 'issue')
                msg = sprintf('O número da inspeção "%.0f" é inválido.', issue);
                showTextHighlight(app, 'warning-20px-red.svg', 'Atenção', msg, 'warning', [])
                return
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            system  = app.projectData.modules.(context).ui.system;
            details = getIssueDetailsFromCache(app.projectData, system, issue);

            if ~isempty(details)
                msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                showTextHighlight(app, 'info.svg', 'Detalhes da Inspeção', msg, 'info', [])

            else
                eventName = 'onFetchIssueDetails';
                if isempty(app.mainApp.eFiscalizaObj) || ~isvalid(app.mainApp.eFiscalizaObj)
                    eventData = ws.eFiscaliza.getCredentials('auto', app.mainApp.executionMode, app.jsBackDoor, eventName, context);
                    if ~isempty(eventData)
                        eventData.uuid = eventName;
                        eventData.context = context;
    
                        ipcMainJSEventsHandler(app.mainApp, struct('HTMLEventName', 'customForm', 'HTMLEventData', eventData))
                    end
                else
                    ipcMainMatlabCallsHandler(app.mainApp, app, eventName, context)
                end
            end
            % </PROCESSO>

        end

        % Image clicked function: prjLastReportDelete, prjLastReportView
        function onFinalReportFileButtonClicked(app, event)
            
            context = app.Context;
            updateNeeded = false;
            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);

            try
                switch event.Source
                    case app.prjLastReportView                        
                        web(lastHTMLDocFullPath, '-new')

                    case app.prjLastReportDelete
                        delete(lastHTMLDocFullPath)

                        updateNeeded = true;
                        updateGeneratedFiles(app.projectData, context)                        
                end

            catch ME
                updateNeeded = true;
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            if updateNeeded
                updatePanel(app, context)
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onFinalReportFileChanged', context)
            end

        end

        % Image clicked function: reportEntityIdCheck
        function reportEntityIdCheckImageClicked(app, event)
            
            details = getEntityDetailsFromCache(app.projectData, app.reportEntityId.Value);

            if isempty(details)
                app.progressDialog.Visible = 'visible';
                details = getOrFetchEntityDetails(app.projectData, app.reportEntityId.Value);
                app.progressDialog.Visible = 'hidden';
            end

            if ~isempty(details)                
                imageUrl = 'info.svg';
                title    = 'Dados da fiscalizada';
                msg      = util.HtmlTextGenerator.entityDetails(app.reportEntityId.Value, details);                
            else
                imageUrl = 'warning-20px-red.svg';
                title    = 'Atenção';
                msg      = 'Esta pesquisa está disponível apenas para CNPJs válidos.';
            end
            
            showTextHighlight(app, imageUrl, title, msg, 'entityDetails', [])

        end

        % Button pushed function: GenerateReport
        function onGenerateReportButtonPushed(app, event)
            
            % <VALIDAÇÕES>
            context = app.Context;
            issue = app.projectData.modules.(context).ui.issue;

            msgWarning = {};
            if isempty(app.projectData.inspectedProducts)
                msgWarning{end+1} = '• A lista de produtos inspecionados está vazia.';
            end

            if ~validateReportRequirements(app.projectData, context, 'reportModel')
                msgWarning{end+1} = '• Pendente escolha do modelo de relatório.';
            end

            if ~validateReportRequirements(app.projectData, context, 'issue')
                msgWarning{end+1} = sprintf('• O número da inspeção "%.0f" é inválido.', issue);
            end

            if ~validateReportRequirements(app.projectData, context, 'unit')
                msgWarning{end+1} = '• Unidade geradora do documento precisa ser selecionada.';
            end

            if ~validateReportRequirements(app.projectData, context, 'entity')
                msgWarning{end+1} = '• Qualificação da fiscalizada ainda pendente.';
            end

            invalidRowIndexes = validateInspectedProducts(app.projectData);
            if ~isempty(invalidRowIndexes)
                msgWarning{end+1} = sprintf('• Os registros da(s) linha(s) %s estão incompletos.', strjoin(string(invalidRowIndexes), ', '));
            end

            if ~isempty(msgWarning)
                msgInfo = sprintf([ ...
                        'Foi(ram) identificada(s) a(s) pendência(s):<br>%s' ...
                        '<br><br>' ...
                        '<b>Essa(s) pendência(s) precisa(m) ser resolvida(s) ' ...
                        'antes da geração do relatório</b>.' ...
                ], strjoin(msgWarning, '<br>'));
                showTextHighlight(app, 'warning-20px-red.svg', 'Pendências', msgInfo, 'warning', [])
                return
            end
            % </VALIDAÇÕES>

            msgQuestion = sprintf('Confirma que se trata de monitoração relacionada à Atividade de Inspeção nº %.0f?', issue);
            showConfirmationTextHighlight(app, 'Confirmação', msgQuestion, 'generateReport')

        end

        % Button pushed function: UploadFinalFile
        function onUploadFinalFileButtonPushed(app, event)
            
            % <VALIDAÇÕES>
            context = app.Context;
            
            system = app.projectData.modules.(context).ui.system;
            issue = app.projectData.modules.(context).ui.issue;

            generatedHtmlFilePath = getGeneratedDocumentFileName(app.projectData, '.html', context);
            reportGenerationId = app.projectData.modules.(context).generatedFiles.id;
            currentProjectHash = model.ProjectBase.computeProjectHash('', '', app.projectData.inspectedProducts, [], []);            

            msg = '';
            if isempty(generatedHtmlFilePath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(generatedHtmlFilePath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', generatedHtmlFilePath);
            elseif ~strcmp(reportGenerationId, currentProjectHash)
                msg = [ ...
                    'A lista de produtos inspecionados foi modificada após a ' ...
                    'geração do relatório. Por essa razão, é necessário gerar ' ...
                    'novamente a versão definitiva do relatório antes do seu ' ...
                    '<i>upload</i> para o SEI' ...
                ];
            elseif ~isfolder(app.mainApp.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            elseif ~validateReportRequirements(app.projectData, context, 'issue')
                msg = sprintf('O número da inspeção "%.0f" é inválido.', issue);
            elseif ~validateReportRequirements(app.projectData, context, 'unit')
                msg = 'Unidade geradora do documento precisa ser selecionada.';
            elseif isempty(system)
                msg = 'Ambiente do eFiscaliza precisa ser selecionado.';
            end

            if ~isempty(msg)
                ui.Dialog(app.UIFigure, 'warning', msg);
                return
            end

            uploadedFiles = getUploadedFiles(app.projectData, context, system, issue);
            if ~isempty(uploadedFiles)
                uploadedStatus = extractAfter({uploadedFiles.status}, 'Documento cadastrado no SEI sob o nº ');

                if isscalar(uploadedStatus)
                    uploadedStatus = uploadedStatus{1};
                else                    
                    uploadedStatus = strjoin([{strjoin(uploadedStatus(1:end-1), ', ')}, uploadedStatus(end)], ' e ');
                end

                msgQuestion = sprintf([ ...
                    'Já foi realizado <i>upload</i> para o SEI de relatório que engloba ' ...
                    'a presente lista de produtos inspecionados - SEI nº %s.<br><br>' ...
                    'Deseja realizar um novo <i>upload</i> para o SEI?' ...
                ], uploadedStatus);
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                if strcmp(userSelection, 'Não')
                    return
                end
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            reportDispatchOperation(app, 'onUploadArtifacts')
            % </PROCESSO>

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, Container)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            if isempty(Container)
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.Position = [100 100 387 754];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_32.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                children = Container.Children;
                if isa(Container, 'matlab.ui.Figure') && isprop(Container, 'RunningAppInstance') && isprop(Container.RunningAppInstance, 'jsBackDoor')
                    children(children == Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)

                app.UIFigure  = ancestor(Container, 'figure');
                app.Container = Container;
                if ~isprop(Container, 'RunningAppInstance')
                    addprop(app.Container, 'RunningAppInstance');
                end
                app.Container.RunningAppInstance = app;
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {'1x', 22, 22, 22};
            app.GridLayout.RowHeight = {22, 176, 1, 22, 90, 1, 22, '1x', 1, 38};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [10 10 10 42];
            app.GridLayout.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create prjLabel
            app.prjLabel = uilabel(app.GridLayout);
            app.prjLabel.VerticalAlignment = 'bottom';
            app.prjLabel.FontWeight = 'bold';
            app.prjLabel.FontColor = [0.1294 0.2 0.2392];
            app.prjLabel.Layout.Row = 1;
            app.prjLabel.Layout.Column = 1;
            app.prjLabel.Text = 'Projeto';

            % Create prjOpenFileButton
            app.prjOpenFileButton = uiimage(app.GridLayout);
            app.prjOpenFileButton.ScaleMethod = 'none';
            app.prjOpenFileButton.ImageClickedFcn = createCallbackFcn(app, @onProjectLoad, true);
            app.prjOpenFileButton.Layout.Row = 1;
            app.prjOpenFileButton.Layout.Column = 2;
            app.prjOpenFileButton.VerticalAlignment = 'bottom';
            app.prjOpenFileButton.ImageSource = 'Import_16.png';

            % Create prjSaveButton
            app.prjSaveButton = uiimage(app.GridLayout);
            app.prjSaveButton.ScaleMethod = 'none';
            app.prjSaveButton.ImageClickedFcn = createCallbackFcn(app, @onProjectSave, true);
            app.prjSaveButton.Enable = 'off';
            app.prjSaveButton.Layout.Row = 1;
            app.prjSaveButton.Layout.Column = 3;
            app.prjSaveButton.VerticalAlignment = 'bottom';
            app.prjSaveButton.ImageSource = 'save.svg';

            % Create prjNewProjectButton
            app.prjNewProjectButton = uiimage(app.GridLayout);
            app.prjNewProjectButton.ScaleMethod = 'none';
            app.prjNewProjectButton.ImageClickedFcn = createCallbackFcn(app, @onProjectRestart, true);
            app.prjNewProjectButton.Layout.Row = 1;
            app.prjNewProjectButton.Layout.Column = 4;
            app.prjNewProjectButton.VerticalAlignment = 'bottom';
            app.prjNewProjectButton.ImageSource = 'new-project.svg';

            % Create prjPanel
            app.prjPanel = uipanel(app.GridLayout);
            app.prjPanel.AutoResizeChildren = 'off';
            app.prjPanel.Layout.Row = 2;
            app.prjPanel.Layout.Column = [1 4];

            % Create prjGrid
            app.prjGrid = uigridlayout(app.prjPanel);
            app.prjGrid.ColumnWidth = {130, '1x', 22, 22};
            app.prjGrid.RowHeight = {22, 38, 15, 22, 38};
            app.prjGrid.ColumnSpacing = 5;
            app.prjGrid.RowSpacing = 5;
            app.prjGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create prjNameLabel
            app.prjNameLabel = uilabel(app.prjGrid);
            app.prjNameLabel.Layout.Row = 1;
            app.prjNameLabel.Layout.Column = 1;
            app.prjNameLabel.Text = 'Nome do projeto:';

            % Create prjName
            app.prjName = uieditfield(app.prjGrid, 'text');
            app.prjName.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.prjName.ValueChangingFcn = createCallbackFcn(app, @onProjectNameChanging, true);
            app.prjName.FontSize = 11;
            app.prjName.Layout.Row = 2;
            app.prjName.Layout.Column = [1 4];

            % Create prjFile
            app.prjFile = uilabel(app.prjGrid);
            app.prjFile.VerticalAlignment = 'top';
            app.prjFile.FontColor = [0.502 0.502 0.502];
            app.prjFile.Layout.Row = 3;
            app.prjFile.Layout.Column = [1 4];
            app.prjFile.Text = '(projeto ainda não exportado)';

            % Create prjLastReportLabel
            app.prjLastReportLabel = uilabel(app.prjGrid);
            app.prjLastReportLabel.VerticalAlignment = 'bottom';
            app.prjLastReportLabel.Layout.Row = 4;
            app.prjLastReportLabel.Layout.Column = [1 3];
            app.prjLastReportLabel.Text = 'Último relatório gerado:';

            % Create prjLastReport
            app.prjLastReport = uieditfield(app.prjGrid, 'text');
            app.prjLastReport.Editable = 'off';
            app.prjLastReport.FontSize = 11;
            app.prjLastReport.Layout.Row = 5;
            app.prjLastReport.Layout.Column = [1 2];

            % Create prjLastReportView
            app.prjLastReportView = uiimage(app.prjGrid);
            app.prjLastReportView.ScaleMethod = 'none';
            app.prjLastReportView.ImageClickedFcn = createCallbackFcn(app, @onFinalReportFileButtonClicked, true);
            app.prjLastReportView.Enable = 'off';
            app.prjLastReportView.Layout.Row = 5;
            app.prjLastReportView.Layout.Column = 3;
            app.prjLastReportView.ImageSource = 'eye.svg';

            % Create prjLastReportDelete
            app.prjLastReportDelete = uiimage(app.prjGrid);
            app.prjLastReportDelete.ScaleMethod = 'none';
            app.prjLastReportDelete.ImageClickedFcn = createCallbackFcn(app, @onFinalReportFileButtonClicked, true);
            app.prjLastReportDelete.Enable = 'off';
            app.prjLastReportDelete.Layout.Row = 5;
            app.prjLastReportDelete.Layout.Column = 4;
            app.prjLastReportDelete.ImageSource = 'close-16px-red.svg';

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.GridLayout);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontWeight = 'bold';
            app.eFiscalizaLabel.FontColor = [0.1294 0.2 0.2392];
            app.eFiscalizaLabel.Layout.Row = 4;
            app.eFiscalizaLabel.Layout.Column = [1 4];
            app.eFiscalizaLabel.Text = 'eFiscaliza';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.GridLayout);
            app.eFiscalizaPanel.AutoResizeChildren = 'off';
            app.eFiscalizaPanel.Layout.Row = 5;
            app.eFiscalizaPanel.Layout.Column = [1 4];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {110, 10, 105, 10, '1x', 5, 22};
            app.eFiscalizaGrid.RowHeight = {22, 38};
            app.eFiscalizaGrid.ColumnSpacing = 0;
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create eFiscalizaSystemLabel
            app.eFiscalizaSystemLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaSystemLabel.Layout.Row = 1;
            app.eFiscalizaSystemLabel.Layout.Column = 1;
            app.eFiscalizaSystemLabel.Text = 'Ambiente:';

            % Create eFiscalizaSystem
            app.eFiscalizaSystem = uidropdown(app.eFiscalizaGrid);
            app.eFiscalizaSystem.Items = {'eFiscaliza', 'eFiscaliza TS', 'eFiscaliza HM', 'eFiscaliza DS'};
            app.eFiscalizaSystem.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaSystem.BackgroundColor = [1 1 1];
            app.eFiscalizaSystem.Layout.Row = 2;
            app.eFiscalizaSystem.Layout.Column = 1;
            app.eFiscalizaSystem.Value = 'eFiscaliza DS';

            % Create eFiscalizaUnitLabel
            app.eFiscalizaUnitLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaUnitLabel.Layout.Row = 1;
            app.eFiscalizaUnitLabel.Layout.Column = 3;
            app.eFiscalizaUnitLabel.Text = 'Unidade:';

            % Create eFiscalizaUnit
            app.eFiscalizaUnit = uidropdown(app.eFiscalizaGrid);
            app.eFiscalizaUnit.Items = {''};
            app.eFiscalizaUnit.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaUnit.BackgroundColor = [1 1 1];
            app.eFiscalizaUnit.Layout.Row = 2;
            app.eFiscalizaUnit.Layout.Column = 3;
            app.eFiscalizaUnit.Value = '';

            % Create eFiscalizaIssueLabel
            app.eFiscalizaIssueLabel = uilabel(app.eFiscalizaGrid);
            app.eFiscalizaIssueLabel.Layout.Row = 1;
            app.eFiscalizaIssueLabel.Layout.Column = [5 7];
            app.eFiscalizaIssueLabel.Text = 'Atividade inspeção:';

            % Create eFiscalizaIssue
            app.eFiscalizaIssue = uieditfield(app.eFiscalizaGrid, 'numeric');
            app.eFiscalizaIssue.Limits = [-1 Inf];
            app.eFiscalizaIssue.RoundFractionalValues = 'on';
            app.eFiscalizaIssue.ValueDisplayFormat = '%d';
            app.eFiscalizaIssue.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.eFiscalizaIssue.Layout.Row = 2;
            app.eFiscalizaIssue.Layout.Column = 5;
            app.eFiscalizaIssue.Value = -1;

            % Create eFiscalizaIssueDetails
            app.eFiscalizaIssueDetails = uiimage(app.eFiscalizaGrid);
            app.eFiscalizaIssueDetails.ScaleMethod = 'none';
            app.eFiscalizaIssueDetails.ImageClickedFcn = createCallbackFcn(app, @onFetchIssueDetails, true);
            app.eFiscalizaIssueDetails.Enable = 'off';
            app.eFiscalizaIssueDetails.Layout.Row = 2;
            app.eFiscalizaIssueDetails.Layout.Column = 7;
            app.eFiscalizaIssueDetails.ImageSource = 'eye.svg';

            % Create reportLabel
            app.reportLabel = uilabel(app.GridLayout);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontWeight = 'bold';
            app.reportLabel.FontColor = [0.1294 0.2 0.2392];
            app.reportLabel.Layout.Row = 7;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'Relatório';

            % Create reportPanel
            app.reportPanel = uipanel(app.GridLayout);
            app.reportPanel.AutoResizeChildren = 'off';
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 8;
            app.reportPanel.Layout.Column = [1 4];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {225, '1x', 17};
            app.reportGrid.RowHeight = {22, 38, 22, '1x'};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create reportModelLabel
            app.reportModelLabel = uilabel(app.reportGrid);
            app.reportModelLabel.VerticalAlignment = 'bottom';
            app.reportModelLabel.Layout.Row = 1;
            app.reportModelLabel.Layout.Column = 1;
            app.reportModelLabel.Text = 'Modelo (.json):';

            % Create reportModel
            app.reportModel = uidropdown(app.reportGrid);
            app.reportModel.Items = {''};
            app.reportModel.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportModel.BackgroundColor = [1 1 1];
            app.reportModel.Layout.Row = 2;
            app.reportModel.Layout.Column = 1;
            app.reportModel.Value = '';

            % Create reportVersionLabel
            app.reportVersionLabel = uilabel(app.reportGrid);
            app.reportVersionLabel.WordWrap = 'on';
            app.reportVersionLabel.Layout.Row = 1;
            app.reportVersionLabel.Layout.Column = [2 3];
            app.reportVersionLabel.Text = 'Versão:';

            % Create reportVersion
            app.reportVersion = uidropdown(app.reportGrid);
            app.reportVersion.Items = {'Preliminar', 'Definitiva'};
            app.reportVersion.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportVersion.BackgroundColor = [1 1 1];
            app.reportVersion.Layout.Row = 2;
            app.reportVersion.Layout.Column = [2 3];
            app.reportVersion.Value = 'Preliminar';

            % Create reportEntityPanelLabel
            app.reportEntityPanelLabel = uilabel(app.reportGrid);
            app.reportEntityPanelLabel.VerticalAlignment = 'bottom';
            app.reportEntityPanelLabel.Layout.Row = 3;
            app.reportEntityPanelLabel.Layout.Column = 1;
            app.reportEntityPanelLabel.Text = 'Fiscalizada';

            % Create reportEntityPanel
            app.reportEntityPanel = uipanel(app.reportGrid);
            app.reportEntityPanel.AutoResizeChildren = 'off';
            app.reportEntityPanel.Layout.Row = 4;
            app.reportEntityPanel.Layout.Column = [1 3];

            % Create reportEntityGrid
            app.reportEntityGrid = uigridlayout(app.reportEntityPanel);
            app.reportEntityGrid.ColumnWidth = {22, '1x', '1x', 22};
            app.reportEntityGrid.RowHeight = {22, 38, 22, 38};
            app.reportEntityGrid.RowSpacing = 5;
            app.reportEntityGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create reportEntityTypeLabel
            app.reportEntityTypeLabel = uilabel(app.reportEntityGrid);
            app.reportEntityTypeLabel.VerticalAlignment = 'bottom';
            app.reportEntityTypeLabel.Layout.Row = 1;
            app.reportEntityTypeLabel.Layout.Column = [1 2];
            app.reportEntityTypeLabel.Text = 'Tipo:';

            % Create reportEntityType
            app.reportEntityType = uidropdown(app.reportEntityGrid);
            app.reportEntityType.Items = {''};
            app.reportEntityType.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityType.BackgroundColor = [1 1 1];
            app.reportEntityType.Layout.Row = 2;
            app.reportEntityType.Layout.Column = [1 2];
            app.reportEntityType.Value = '';

            % Create reportEntityIdLabel
            app.reportEntityIdLabel = uilabel(app.reportEntityGrid);
            app.reportEntityIdLabel.VerticalAlignment = 'bottom';
            app.reportEntityIdLabel.WordWrap = 'on';
            app.reportEntityIdLabel.Layout.Row = 1;
            app.reportEntityIdLabel.Layout.Column = 3;
            app.reportEntityIdLabel.Text = 'CNPJ/CPF:';

            % Create reportEntityIdCheck
            app.reportEntityIdCheck = uiimage(app.reportEntityGrid);
            app.reportEntityIdCheck.ImageClickedFcn = createCallbackFcn(app, @reportEntityIdCheckImageClicked, true);
            app.reportEntityIdCheck.Enable = 'off';
            app.reportEntityIdCheck.Layout.Row = 1;
            app.reportEntityIdCheck.Layout.Column = 4;
            app.reportEntityIdCheck.VerticalAlignment = 'bottom';
            app.reportEntityIdCheck.ImageSource = 'Info_36.png';

            % Create reportEntityId
            app.reportEntityId = uieditfield(app.reportEntityGrid, 'text');
            app.reportEntityId.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityId.Layout.Row = 2;
            app.reportEntityId.Layout.Column = [3 4];

            % Create reportEntityNameLabel
            app.reportEntityNameLabel = uilabel(app.reportEntityGrid);
            app.reportEntityNameLabel.VerticalAlignment = 'bottom';
            app.reportEntityNameLabel.WordWrap = 'on';
            app.reportEntityNameLabel.Layout.Row = 3;
            app.reportEntityNameLabel.Layout.Column = [1 4];
            app.reportEntityNameLabel.Text = 'Nome da fiscalizada:';

            % Create reportEntityName
            app.reportEntityName = uieditfield(app.reportEntityGrid, 'text');
            app.reportEntityName.ValueChangedFcn = createCallbackFcn(app, @onProjectInfoUpdate, true);
            app.reportEntityName.Layout.Row = 4;
            app.reportEntityName.Layout.Column = [1 4];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 10;
            app.GridLayout2.Layout.Column = [1 4];

            % Create GenerateReport
            app.GenerateReport = uibutton(app.GridLayout2, 'push');
            app.GenerateReport.ButtonPushedFcn = createCallbackFcn(app, @onGenerateReportButtonPushed, true);
            app.GenerateReport.Icon = 'Publish_HTML_16.png';
            app.GenerateReport.BackgroundColor = [0.0314 0.4902 0.7294];
            app.GenerateReport.FontColor = [1 1 1];
            app.GenerateReport.Layout.Row = 1;
            app.GenerateReport.Layout.Column = 1;
            app.GenerateReport.Text = 'Gerar relatório';

            % Create UploadFinalFile
            app.UploadFinalFile = uibutton(app.GridLayout2, 'push');
            app.UploadFinalFile.ButtonPushedFcn = createCallbackFcn(app, @onUploadFinalFileButtonPushed, true);
            app.UploadFinalFile.Icon = 'up-20px.png';
            app.UploadFinalFile.BackgroundColor = [0.0314 0.4902 0.7294];
            app.UploadFinalFile.FontColor = [1 1 1];
            app.UploadFinalFile.Enable = 'off';
            app.UploadFinalFile.Layout.Row = 1;
            app.UploadFinalFile.Layout.Column = 2;
            app.UploadFinalFile.Text = 'Upload relatório';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobileReportLib_exported(Container, varargin)

            % Create UIFigure and components
            createComponents(app, Container)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            if app.isDocked
                children = app.Container.Children;
                if isa(app.Container, 'matlab.ui.Figure') && isprop(app.Container, 'RunningAppInstance') && isprop(app.Container.RunningAppInstance, 'jsBackDoor')
                    children(children == app.Container.RunningAppInstance.jsBackDoor) = [];
                end
                delete(children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
