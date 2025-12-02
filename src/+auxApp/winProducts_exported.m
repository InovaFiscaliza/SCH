classdef winProducts_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        TabGroup                     matlab.ui.container.TabGroup
        INSPEOTab                    matlab.ui.container.Tab
        report_Tab1Grid              matlab.ui.container.GridLayout
        report_ProductInfo           matlab.ui.control.Label
        report_ProductInfoImage      matlab.ui.control.Image
        report_ProductInfoLabel      matlab.ui.control.Label
        PROJETOTab                   matlab.ui.container.Tab
        Tab4Grid                     matlab.ui.container.GridLayout
        report_EntityPanel           matlab.ui.container.Panel
        report_EntityGrid            matlab.ui.container.GridLayout
        report_Entity                matlab.ui.control.EditField
        report_EntityLabel           matlab.ui.control.Label
        report_EntityID              matlab.ui.control.EditField
        report_EntityCheck           matlab.ui.control.Image
        report_EntityIDLabel         matlab.ui.control.Label
        report_EntityType            matlab.ui.control.DropDown
        report_EntityTypeLabel       matlab.ui.control.Label
        report_EntityPanelLabel      matlab.ui.control.Label
        report_ProjectName           matlab.ui.control.TextArea
        report_ProjectSave           matlab.ui.control.Image
        report_ProjectOpen           matlab.ui.control.Image
        report_ProjectNew            matlab.ui.control.Image
        report_ProjectLabel          matlab.ui.control.Label
        reportPanel                  matlab.ui.container.Panel
        reportGrid                   matlab.ui.container.GridLayout
        reportVersion                matlab.ui.control.DropDown
        reportVersionLabel           matlab.ui.control.Label
        reportModelName              matlab.ui.control.DropDown
        reportModelNameLabel         matlab.ui.control.Label
        reportLabel                  matlab.ui.control.Label
        eFiscalizaPanel              matlab.ui.container.Panel
        eFiscalizaGrid               matlab.ui.container.GridLayout
        reportIssue                  matlab.ui.control.NumericEditField
        reportIssueLabel             matlab.ui.control.Label
        reportUnit                   matlab.ui.control.DropDown
        reportUnitLabel              matlab.ui.control.Label
        reportSystem                 matlab.ui.control.DropDown
        reportSystemLabel            matlab.ui.control.Label
        eFiscalizaLabel              matlab.ui.control.Label
        DockModule                   matlab.ui.container.GridLayout
        dockModule_Undock            matlab.ui.control.Image
        dockModule_Close             matlab.ui.control.Image
        Document                     matlab.ui.container.GridLayout
        report_Table                 matlab.ui.control.Table
        report_nRows                 matlab.ui.control.Label
        report_ViewType              matlab.ui.container.ButtonGroup
        AduanaButton                 matlab.ui.control.RadioButton
        FornecedorUsurioButton       matlab.ui.control.RadioButton
        Toolbar                      matlab.ui.container.GridLayout
        report_FiscalizaUpdate       matlab.ui.control.Image
        report_ReportGeneration      matlab.ui.control.Image
        tool_EditSelectedProduct     matlab.ui.control.Image
        tool_AddNonCertificate       matlab.ui.control.Image
        tool_ControlPanelVisibility  matlab.ui.control.Image
        ContextMenu                  matlab.ui.container.ContextMenu
        EditarMenu                   matlab.ui.container.Menu
        DeletePoint                  matlab.ui.container.Menu
    end

    
    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false

        mainApp
        projectData
        
        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj
        jsBackDoor

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog
        popupContainer
    end


    methods
        %-----------------------------------------------------------------%
        % IPC: COMUNICAÇÃO ENTRE PROCESSOS
        %-----------------------------------------------------------------%
        function ipcSecundaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app)

                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                report_uploadInfoController(app.mainApp, event.HTMLEventData, 'uploadDocument')

                            otherwise
                                error('UnexpectedEvent')
                        end

                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecundaryMatlabCallsHandler(app, callingApp, operationType, varargin)
            try
                switch class(callingApp)
                    case {'winSCH', 'winSCH_exported'}
                        switch operationType
                            case 'updateInspectedProducts'
                                'updateInspectedProducts'
                                % ...

                            otherwise
                                error('UnexpectedCall')
                        end
    
                    otherwise
                        error('UnexpectedCall')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                 ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    if app.isDocked
                        app.progressDialog = app.mainApp.progressDialog;
                    else
                        sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                        app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);                        
                    end
                    customizationStatus = [false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            appName = class(app);

                            % Grid botões "dock":
                            if app.isDocked
                                elToModify = {app.DockModule};
                                elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                                if ~isempty(elDataTag)                                    
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                        struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('transition', 'opacity 2s ease', 'opacity', '0.5')) ...
                                    });
                                end
                            end

                            % Outros elementos:
                            elToModify = { ...
                                app.report_ProductInfo, ...
                                app.report_ProductInfoImage ...
                            };
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
                                ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                            end

                        case 2
                            % ...
                    end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
        %-----------------------------------------------------------------%
        function startup_timerCreation(app)
            app.timerObj = timer("ExecutionMode", "fixedSpacing", ...
                                 "StartDelay",    1.5,            ...
                                 "Period",        .1,             ...
                                 "TimerFcn",      @(~,~)app.startup_timerFcn);
            start(app.timerObj)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app)
            if ccTools.fcn.UIFigureRenderStatus(app.UIFigure)
                stop(app.timerObj)
                delete(app.timerObj)

                jsBackDoor_Initialization(app)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app)
            drawnow

            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)

            % Define tamanho mínimo do app (não aplicável à versão webapp).
            if ~strcmp(app.mainApp.executionMode, 'webApp') && ~app.isDocked
                appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
            end

            app.progressDialog.Visible = 'visible';

            startup_GUIComponents(app)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.report_Table.RowName = 'numbered';

            % ...
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            app.mainApp     = mainApp;
            app.projectData = mainApp.projectData;

            if app.isDocked
                app.GridLayout.Padding(4)  = 30;
                app.DockModule.Visible = 1;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn')
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];
                    
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Image clicked function: tool_ControlPanelVisibility
        function Toolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.tool_ControlPanelVisibility
                    if app.TabGroup.Visible
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.TabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.tool_ControlPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.TabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.tool_TableVisibility
                    app.tool_TableVisibility.UserData = mod(app.tool_TableVisibility.UserData+1, 3);

                    switch app.tool_TableVisibility.UserData
                        case 0
                            app.UITable.Visible = 0;
                            app.Document.RowHeight = {24,'1x', 0, 0};
                        case 1
                            app.UITable.Visible = 1;
                            app.Document.RowHeight = {24, '1x', 10, 186};
                        case 2
                            app.UITable.Visible = 1;
                            app.Document.RowHeight = {0, 0, 0, '1x'};
                    end

                case app.tool_peakIcon
                    if ~isempty(app.tool_peakIcon.UserData)
                        ReferenceDistance_km = 1;
                        plot.zoom(app.UIAxes, app.tool_peakIcon.UserData.Latitude, app.tool_peakIcon.UserData.Longitude, ReferenceDistance_km)
                        plot.datatip.Create(app.UIAxes, 'Measures', app.tool_peakIcon.UserData.idxMax)
                    end
            end

        end

        % Image clicked function: report_ReportGeneration
        function Toolbar_GenerateReportImageClicked(app, event)
            
            context = 'ExternalRequest';
            indexes = FileIndex(app);

            if ~isempty(indexes)
                % <VALIDAÇÕES>
                if numel(indexes) < numel(app.measData)
                    initialQuestion  = 'Deseja gerar relatório que contemple informações de TODAS as localidades de agrupamento, ou apenas da SELECIONADA?';
                    initialSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', initialQuestion, {'Todas', 'Selecionada', 'Cancelar'}, 1, 3);

                    switch initialSelection
                        case 'Cancelar'
                            return
                        case 'Todas'
                            indexes = 1:numel(app.measData);
                    end
                end

                warningMessages = {};
                if ~report_checkEFiscalizaIssueId(app.mainApp, app.projectData.modules.(context).ui.issue)
                    warningMessages{end+1} = sprintf('O número da inspeção "%.0f" é inválido.', app.projectData.modules.(context).ui.issue);
                end
                
                if ~isempty(layout_searchUnexpectedTableValues(app))
                    warningMessages{end+1} = ['Há registro de pontos críticos localizados na(s) localidade(s) sob análise para os quais '     ...
                                              'não foram identificadas medidas no entorno. Nesse caso específico, deve-se preencher ' ...
                                              'o campo "Justificativa" e anotar os registros, caso aplicável.'];
                end

                if ~isempty(warningMessages)
                    warningMessages = strjoin(warningMessages, '<br><br>');

                    switch app.reportVersion.Value
                        case 'Definitiva'
                            warningMessages = [warningMessages, '<br><br>Isso impossibilita a geração da versão DEFINITIVA do relatório.'];
                            appUtil.modalWindow(app.UIFigure, "warning", warningMessages);
                            return

                        otherwise % 'Preliminar'
                            warningMessages = [warningMessages, '<br><br>Deseja ignorar esse alerta, gerando a versão PRÉVIA do relatório?'];
                            userSelection   = appUtil.modalWindow(app.UIFigure, 'uiconfirm', warningMessages, {'Sim', 'Não'}, 2, 2);
                            if userSelection == "Não"
                                return
                            end
                    end
                end
                % </VALIDAÇÕES>

                % <PROCESSO>
                app.progressDialog.Visible = 'visible';

                try
                    reportSettings = struct('system',        app.reportSystem.Value, ...
                                            'unit',          app.reportUnit.Value, ...
                                            'issue',         app.reportIssue.Value, ...
                                            'model',         app.reportModelName.Value, ...
                                            'reportVersion', app.reportVersion.Value);
                    reportLibConnection.Controller.Run(app, app.projectData, app.measData(indexes), reportSettings, app.mainApp.General)
                catch ME
                    appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
                end

                updateToolbar(app)

                app.progressDialog.Visible = 'hidden';
                % </PROCESSO>
            end

        end

        % Image clicked function: report_FiscalizaUpdate
        function Toolbar_UploadFinalFileImageClicked(app, event)
            
            % <VALIDAÇÕES>
            context = 'Products';
            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);

            msg = '';
            if isempty(lastHTMLDocFullPath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(lastHTMLDocFullPath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', lastHTMLDocFullPath);
            elseif ~isfolder(app.mainApp.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            elseif ~report_checkEFiscalizaIssueId(app.mainApp, app.projectData.modules.(context).ui.issue)
                msg = sprintf('O número da inspeção "%.0f" é inválido.', app.projectData.modules.(context).ui.issue);
            elseif isempty(app.projectData.modules.(context).ui.system)
                msg = 'Ambiente do eFiscaliza precisa ser selecionado.';
            elseif isempty(app.projectData.modules.(context).ui.unit)
                msg = 'Unidade geradora do documento precisa ser selecionada.';
            end

            if ~isempty(msg)
                appUtil.modalWindow(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            if isempty(app.mainApp.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'eFiscalizaSignInPage', 'Fields', dialogBox, 'Context', context))
            else
                report_uploadInfoController(app.mainApp, [], 'uploadDocument', context)
            end
            % </PROCESSO>

        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)

            [~, tabIndex] = ismember(app.TabGroup.SelectedTab, app.TabGroup.Children);
            jsBackDoor_Customizations(app, tabIndex)

        end

        % Value changed function: reportModelName
        function reportModelNameValueChanged(app, event)
            
            updateToolbar(app)

        end

        % Value changed function: reportIssue, reportSystem, reportUnit
        function reportInfoValueChanged(app, event)
            
            context = 'ExternalRequest';

            switch event.Source
                case app.reportSystem
                    updateUiInfo(app.projectData, context, 'system', app.reportSystem.Value)
                case app.reportUnit
                    updateUiInfo(app.projectData, context, 'unit',   app.reportUnit.Value)
                case app.reportIssue
                    updateUiInfo(app.projectData, context, 'issue',  app.reportIssue.Value)
            end

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
                app.UIFigure.Position = [100 100 1244 660];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                if ~isempty(Container.Children)
                    delete(Container.Children)
                end

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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 22, '1x', 22, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];

            % Create tool_ControlPanelVisibility
            app.tool_ControlPanelVisibility = uiimage(app.Toolbar);
            app.tool_ControlPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_ControlPanelVisibility.Layout.Row = 2;
            app.tool_ControlPanelVisibility.Layout.Column = 1;
            app.tool_ControlPanelVisibility.ImageSource = 'ArrowLeft_32.png';

            % Create tool_AddNonCertificate
            app.tool_AddNonCertificate = uiimage(app.Toolbar);
            app.tool_AddNonCertificate.Tooltip = {'Adiciona produto NÃO homologado à lista'};
            app.tool_AddNonCertificate.Layout.Row = 2;
            app.tool_AddNonCertificate.Layout.Column = 2;
            app.tool_AddNonCertificate.ImageSource = 'Forbidden_32Red.png';

            % Create tool_EditSelectedProduct
            app.tool_EditSelectedProduct = uiimage(app.Toolbar);
            app.tool_EditSelectedProduct.ScaleMethod = 'none';
            app.tool_EditSelectedProduct.Enable = 'off';
            app.tool_EditSelectedProduct.Tooltip = {'Edita lista de produtos'};
            app.tool_EditSelectedProduct.Layout.Row = [2 3];
            app.tool_EditSelectedProduct.Layout.Column = 3;
            app.tool_EditSelectedProduct.ImageSource = 'Variable_edit_16.png';

            % Create report_ReportGeneration
            app.report_ReportGeneration = uiimage(app.Toolbar);
            app.report_ReportGeneration.ScaleMethod = 'none';
            app.report_ReportGeneration.ImageClickedFcn = createCallbackFcn(app, @Toolbar_GenerateReportImageClicked, true);
            app.report_ReportGeneration.Enable = 'off';
            app.report_ReportGeneration.Tooltip = {'Gera relatório'};
            app.report_ReportGeneration.Layout.Row = [1 3];
            app.report_ReportGeneration.Layout.Column = 5;
            app.report_ReportGeneration.ImageSource = 'Publish_HTML_16.png';

            % Create report_FiscalizaUpdate
            app.report_FiscalizaUpdate = uiimage(app.Toolbar);
            app.report_FiscalizaUpdate.ImageClickedFcn = createCallbackFcn(app, @Toolbar_UploadFinalFileImageClicked, true);
            app.report_FiscalizaUpdate.Enable = 'off';
            app.report_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.report_FiscalizaUpdate.Layout.Row = 2;
            app.report_FiscalizaUpdate.Layout.Column = 6;
            app.report_FiscalizaUpdate.ImageSource = 'Up_24.png';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 100, 16, 16};
            app.Document.RowHeight = {4, 22, 16, '1x'};
            app.Document.ColumnSpacing = 2;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

            % Create report_ViewType
            app.report_ViewType = uibuttongroup(app.Document);
            app.report_ViewType.BorderType = 'none';
            app.report_ViewType.Title = 'LISTA DE PRODUTOS SOB ANÁLISE';
            app.report_ViewType.BackgroundColor = [1 1 1];
            app.report_ViewType.Layout.Row = [2 3];
            app.report_ViewType.Layout.Column = [1 4];
            app.report_ViewType.FontSize = 10;

            % Create FornecedorUsurioButton
            app.FornecedorUsurioButton = uiradiobutton(app.report_ViewType);
            app.FornecedorUsurioButton.Tag = 'vendorView';
            app.FornecedorUsurioButton.Text = 'Fornecedor/Usuário';
            app.FornecedorUsurioButton.FontSize = 11;
            app.FornecedorUsurioButton.Position = [1 1 167 23];
            app.FornecedorUsurioButton.Value = true;

            % Create AduanaButton
            app.AduanaButton = uiradiobutton(app.report_ViewType);
            app.AduanaButton.Tag = 'customsView';
            app.AduanaButton.Text = 'Aduana';
            app.AduanaButton.FontSize = 11;
            app.AduanaButton.Position = [187 1 180 22];

            % Create report_nRows
            app.report_nRows = uilabel(app.Document);
            app.report_nRows.HorizontalAlignment = 'right';
            app.report_nRows.VerticalAlignment = 'bottom';
            app.report_nRows.FontSize = 11;
            app.report_nRows.FontColor = [0.502 0.502 0.502];
            app.report_nRows.Layout.Row = 3;
            app.report_nRows.Layout.Column = [2 4];
            app.report_nRows.Interpreter = 'html';
            app.report_nRows.Text = '0 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>';

            % Create report_Table
            app.report_Table = uitable(app.Document);
            app.report_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'FONTE|VALOR'; 'QTD.|VENDIDA'; 'QTD.|EM USO'; 'QTD.|ESTOQUE'; 'QTD.|ANUNCIADA'; 'QTD.|LACRADA'; 'QTD.|APREENDIDA'; 'QTD.|RETIDA (RFB)'; 'SITUAÇÃO'; 'INFRAÇÃO'};
            app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 42, 96, 90, 'auto', 90, 90, 90, 90, 90, 90, 90, 'auto', 'auto'};
            app.report_Table.RowName = {};
            app.report_Table.SelectionType = 'row';
            app.report_Table.ColumnEditable = [false true true true true true true true true true true true true true true true true true];
            app.report_Table.Layout.Row = 4;
            app.report_Table.Layout.Column = [1 4];
            app.report_Table.FontSize = 10;

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = 2;

            % Create INSPEOTab
            app.INSPEOTab = uitab(app.TabGroup);
            app.INSPEOTab.AutoResizeChildren = 'off';
            app.INSPEOTab.Title = 'INSPEÇÃO';

            % Create report_Tab1Grid
            app.report_Tab1Grid = uigridlayout(app.INSPEOTab);
            app.report_Tab1Grid.ColumnWidth = {'1x'};
            app.report_Tab1Grid.RowHeight = {17, '1x'};
            app.report_Tab1Grid.RowSpacing = 5;
            app.report_Tab1Grid.BackgroundColor = [1 1 1];

            % Create report_ProductInfoLabel
            app.report_ProductInfoLabel = uilabel(app.report_Tab1Grid);
            app.report_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.report_ProductInfoLabel.FontSize = 10;
            app.report_ProductInfoLabel.Layout.Row = 1;
            app.report_ProductInfoLabel.Layout.Column = 1;
            app.report_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create report_ProductInfoImage
            app.report_ProductInfoImage = uiimage(app.report_Tab1Grid);
            app.report_ProductInfoImage.ScaleMethod = 'none';
            app.report_ProductInfoImage.Layout.Row = 2;
            app.report_ProductInfoImage.Layout.Column = 1;
            app.report_ProductInfoImage.ImageSource = 'warning.svg';

            % Create report_ProductInfo
            app.report_ProductInfo = uilabel(app.report_Tab1Grid);
            app.report_ProductInfo.VerticalAlignment = 'top';
            app.report_ProductInfo.WordWrap = 'on';
            app.report_ProductInfo.FontSize = 11;
            app.report_ProductInfo.Layout.Row = 2;
            app.report_ProductInfo.Layout.Column = 1;
            app.report_ProductInfo.Interpreter = 'html';
            app.report_ProductInfo.Text = '';

            % Create PROJETOTab
            app.PROJETOTab = uitab(app.TabGroup);
            app.PROJETOTab.AutoResizeChildren = 'off';
            app.PROJETOTab.Title = 'PROJETO';

            % Create Tab4Grid
            app.Tab4Grid = uigridlayout(app.PROJETOTab);
            app.Tab4Grid.ColumnWidth = {'1x', 22, 22, 22};
            app.Tab4Grid.RowHeight = {17, 44, 22, 110, 22, 100, 22, '1x'};
            app.Tab4Grid.ColumnSpacing = 5;
            app.Tab4Grid.RowSpacing = 5;
            app.Tab4Grid.BackgroundColor = [1 1 1];

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.Tab4Grid);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 5;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'eFISCALIZA';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.Tab4Grid);
            app.eFiscalizaPanel.Layout.Row = 6;
            app.eFiscalizaPanel.Layout.Column = [1 4];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {'1x', 150};
            app.eFiscalizaGrid.RowHeight = {22, 22, 22, '1x'};
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create reportSystemLabel
            app.reportSystemLabel = uilabel(app.eFiscalizaGrid);
            app.reportSystemLabel.FontSize = 11;
            app.reportSystemLabel.Layout.Row = 1;
            app.reportSystemLabel.Layout.Column = 1;
            app.reportSystemLabel.Text = 'Sistema:';

            % Create reportSystem
            app.reportSystem = uidropdown(app.eFiscalizaGrid);
            app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS'};
            app.reportSystem.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportSystem.FontSize = 11;
            app.reportSystem.BackgroundColor = [1 1 1];
            app.reportSystem.Layout.Row = 1;
            app.reportSystem.Layout.Column = 2;
            app.reportSystem.Value = 'eFiscaliza';

            % Create reportUnitLabel
            app.reportUnitLabel = uilabel(app.eFiscalizaGrid);
            app.reportUnitLabel.FontSize = 11;
            app.reportUnitLabel.Layout.Row = 2;
            app.reportUnitLabel.Layout.Column = 1;
            app.reportUnitLabel.Text = 'Unidade responsável:';

            % Create reportUnit
            app.reportUnit = uidropdown(app.eFiscalizaGrid);
            app.reportUnit.Items = {};
            app.reportUnit.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportUnit.FontSize = 11;
            app.reportUnit.BackgroundColor = [1 1 1];
            app.reportUnit.Layout.Row = 2;
            app.reportUnit.Layout.Column = 2;
            app.reportUnit.Value = {};

            % Create reportIssueLabel
            app.reportIssueLabel = uilabel(app.eFiscalizaGrid);
            app.reportIssueLabel.FontSize = 11;
            app.reportIssueLabel.Layout.Row = [3 4];
            app.reportIssueLabel.Layout.Column = 1;
            app.reportIssueLabel.Text = {'Atividade de inspeção:'; '(# ID)'};

            % Create reportIssue
            app.reportIssue = uieditfield(app.eFiscalizaGrid, 'numeric');
            app.reportIssue.Limits = [-1 Inf];
            app.reportIssue.RoundFractionalValues = 'on';
            app.reportIssue.ValueDisplayFormat = '%d';
            app.reportIssue.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportIssue.FontSize = 11;
            app.reportIssue.FontColor = [0.149 0.149 0.149];
            app.reportIssue.Layout.Row = 3;
            app.reportIssue.Layout.Column = 2;
            app.reportIssue.Value = -1;

            % Create reportLabel
            app.reportLabel = uilabel(app.Tab4Grid);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 7;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO';

            % Create reportPanel
            app.reportPanel = uipanel(app.Tab4Grid);
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 8;
            app.reportPanel.Layout.Column = [1 4];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {'1x', 150};
            app.reportGrid.RowHeight = {22, 22};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [1 1 1];

            % Create reportModelNameLabel
            app.reportModelNameLabel = uilabel(app.reportGrid);
            app.reportModelNameLabel.FontSize = 11;
            app.reportModelNameLabel.Layout.Row = 1;
            app.reportModelNameLabel.Layout.Column = 1;
            app.reportModelNameLabel.Text = 'Modelo (.json):';

            % Create reportModelName
            app.reportModelName = uidropdown(app.reportGrid);
            app.reportModelName.Items = {''};
            app.reportModelName.ValueChangedFcn = createCallbackFcn(app, @reportModelNameValueChanged, true);
            app.reportModelName.FontSize = 11;
            app.reportModelName.BackgroundColor = [1 1 1];
            app.reportModelName.Layout.Row = 1;
            app.reportModelName.Layout.Column = 2;
            app.reportModelName.Value = '';

            % Create reportVersionLabel
            app.reportVersionLabel = uilabel(app.reportGrid);
            app.reportVersionLabel.WordWrap = 'on';
            app.reportVersionLabel.FontSize = 11;
            app.reportVersionLabel.Layout.Row = 2;
            app.reportVersionLabel.Layout.Column = 1;
            app.reportVersionLabel.Text = 'Versão do relatório:';

            % Create reportVersion
            app.reportVersion = uidropdown(app.reportGrid);
            app.reportVersion.Items = {'Preliminar', 'Definitiva'};
            app.reportVersion.FontSize = 11;
            app.reportVersion.BackgroundColor = [1 1 1];
            app.reportVersion.Layout.Row = 2;
            app.reportVersion.Layout.Column = 2;
            app.reportVersion.Value = 'Preliminar';

            % Create report_ProjectLabel
            app.report_ProjectLabel = uilabel(app.Tab4Grid);
            app.report_ProjectLabel.VerticalAlignment = 'bottom';
            app.report_ProjectLabel.FontSize = 10;
            app.report_ProjectLabel.Layout.Row = 1;
            app.report_ProjectLabel.Layout.Column = 1;
            app.report_ProjectLabel.Text = 'ARQUIVO';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.Tab4Grid);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 2;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = 'AddFiles_36.png';

            % Create report_ProjectOpen
            app.report_ProjectOpen = uiimage(app.Tab4Grid);
            app.report_ProjectOpen.Tooltip = {'Abre projeto'};
            app.report_ProjectOpen.Layout.Row = 1;
            app.report_ProjectOpen.Layout.Column = 3;
            app.report_ProjectOpen.VerticalAlignment = 'bottom';
            app.report_ProjectOpen.ImageSource = 'OpenFile_36x36.png';

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.Tab4Grid);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 1;
            app.report_ProjectSave.Layout.Column = 4;
            app.report_ProjectSave.VerticalAlignment = 'bottom';
            app.report_ProjectSave.ImageSource = 'SaveFile_36.png';

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.Tab4Grid);
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 2;
            app.report_ProjectName.Layout.Column = [1 4];

            % Create report_EntityPanelLabel
            app.report_EntityPanelLabel = uilabel(app.Tab4Grid);
            app.report_EntityPanelLabel.VerticalAlignment = 'bottom';
            app.report_EntityPanelLabel.FontSize = 10;
            app.report_EntityPanelLabel.Layout.Row = 3;
            app.report_EntityPanelLabel.Layout.Column = 1;
            app.report_EntityPanelLabel.Text = 'FISCALIZADA';

            % Create report_EntityPanel
            app.report_EntityPanel = uipanel(app.Tab4Grid);
            app.report_EntityPanel.Layout.Row = 4;
            app.report_EntityPanel.Layout.Column = [1 4];

            % Create report_EntityGrid
            app.report_EntityGrid = uigridlayout(app.report_EntityPanel);
            app.report_EntityGrid.ColumnWidth = {'1x', 124, 16};
            app.report_EntityGrid.RowHeight = {17, 22, 17, 22};
            app.report_EntityGrid.RowSpacing = 5;
            app.report_EntityGrid.Padding = [10 10 10 5];
            app.report_EntityGrid.BackgroundColor = [1 1 1];

            % Create report_EntityTypeLabel
            app.report_EntityTypeLabel = uilabel(app.report_EntityGrid);
            app.report_EntityTypeLabel.VerticalAlignment = 'bottom';
            app.report_EntityTypeLabel.FontSize = 11;
            app.report_EntityTypeLabel.Layout.Row = 1;
            app.report_EntityTypeLabel.Layout.Column = 1;
            app.report_EntityTypeLabel.Text = 'Tipo:';

            % Create report_EntityType
            app.report_EntityType = uidropdown(app.report_EntityGrid);
            app.report_EntityType.Items = {'', 'Importador', 'Fornecedor', 'Usuário'};
            app.report_EntityType.FontSize = 11;
            app.report_EntityType.BackgroundColor = [1 1 1];
            app.report_EntityType.Layout.Row = 2;
            app.report_EntityType.Layout.Column = 1;
            app.report_EntityType.Value = '';

            % Create report_EntityIDLabel
            app.report_EntityIDLabel = uilabel(app.report_EntityGrid);
            app.report_EntityIDLabel.VerticalAlignment = 'bottom';
            app.report_EntityIDLabel.WordWrap = 'on';
            app.report_EntityIDLabel.FontSize = 11;
            app.report_EntityIDLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityIDLabel.Layout.Row = 1;
            app.report_EntityIDLabel.Layout.Column = 2;
            app.report_EntityIDLabel.Text = 'CNPJ/CPF:';

            % Create report_EntityCheck
            app.report_EntityCheck = uiimage(app.report_EntityGrid);
            app.report_EntityCheck.Enable = 'off';
            app.report_EntityCheck.Layout.Row = 1;
            app.report_EntityCheck.Layout.Column = 3;
            app.report_EntityCheck.VerticalAlignment = 'bottom';
            app.report_EntityCheck.ImageSource = 'Info_36.png';

            % Create report_EntityID
            app.report_EntityID = uieditfield(app.report_EntityGrid, 'text');
            app.report_EntityID.FontSize = 11;
            app.report_EntityID.Enable = 'off';
            app.report_EntityID.Layout.Row = 2;
            app.report_EntityID.Layout.Column = [2 3];

            % Create report_EntityLabel
            app.report_EntityLabel = uilabel(app.report_EntityGrid);
            app.report_EntityLabel.VerticalAlignment = 'bottom';
            app.report_EntityLabel.WordWrap = 'on';
            app.report_EntityLabel.FontSize = 11;
            app.report_EntityLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityLabel.Layout.Row = 3;
            app.report_EntityLabel.Layout.Column = 1;
            app.report_EntityLabel.Text = 'Nome:';

            % Create report_Entity
            app.report_Entity = uieditfield(app.report_EntityGrid, 'text');
            app.report_Entity.FontSize = 11;
            app.report_Entity.Enable = 'off';
            app.report_Entity.Layout.Row = 4;
            app.report_Entity.Layout.Column = [1 3];

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winExternalRequest';

            % Create EditarMenu
            app.EditarMenu = uimenu(app.ContextMenu);
            app.EditarMenu.Enable = 'off';
            app.EditarMenu.Text = 'Editar';

            % Create DeletePoint
            app.DeletePoint = uimenu(app.ContextMenu);
            app.DeletePoint.ForegroundColor = [1 0 0];
            app.DeletePoint.Enable = 'off';
            app.DeletePoint.Separator = 'on';
            app.DeletePoint.Text = 'Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winProducts_exported(Container, varargin)

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
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
