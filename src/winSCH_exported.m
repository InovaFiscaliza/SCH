classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        popupContainerGrid              matlab.ui.container.GridLayout
        SplashScreen                    matlab.ui.control.Image
        popupContainer                  matlab.ui.container.Panel
        menu_Grid                       matlab.ui.container.GridLayout
        dockModule_Close                matlab.ui.control.Image
        dockModule_Undock               matlab.ui.control.Image
        AppInfo                         matlab.ui.control.Image
        FigurePosition                  matlab.ui.control.Image
        DataHubLamp                     matlab.ui.control.Lamp
        jsBackDoor                      matlab.ui.control.HTML
        menu_Button3                    matlab.ui.control.StateButton
        menu_Separator                  matlab.ui.control.Image
        menu_Button2                    matlab.ui.control.StateButton
        menu_Button1                    matlab.ui.control.StateButton
        TabGroup                        matlab.ui.container.TabGroup
        Tab1_Search                     matlab.ui.container.Tab
        Tab1_SearchGrid                 matlab.ui.container.GridLayout
        search_Document                 matlab.ui.container.GridLayout
        search_nRows                    matlab.ui.control.Label
        search_Suggestions              matlab.ui.control.ListBox
        search_Metadata                 matlab.ui.control.Label
        search_entryPointPanel          matlab.ui.container.Panel
        search_entryPointGrid           matlab.ui.container.GridLayout
        search_entryPointImage          matlab.ui.control.Image
        search_entryPoint               matlab.ui.control.EditField
        search_Table                    matlab.ui.control.Table
        search_Tab1Grid                 matlab.ui.container.GridLayout
        search_ProductInfo              matlab.ui.control.Label
        search_ProductInfoImage         matlab.ui.control.Image
        search_menuBtn1Grid             matlab.ui.container.GridLayout
        search_menuBtn1Icon             matlab.ui.control.Image
        search_menuBtn1Label            matlab.ui.control.Label
        search_ToolbarAnnotation        matlab.ui.control.Image
        search_ListOfProducts           matlab.ui.control.ListBox
        search_ListOfProductsAdd        matlab.ui.control.Image
        search_ListOfProductsLabel      matlab.ui.control.Label
        search_WordCloudRefresh         matlab.ui.control.Image
        search_WordCloudPanel           matlab.ui.container.Panel
        search_AnnotationPanel          matlab.ui.container.Panel
        search_AnnotationGrid           matlab.ui.container.GridLayout
        search_AnnotationPanelAdd       matlab.ui.control.Image
        search_AnnotationValue          matlab.ui.control.TextArea
        search_AnnotationValueLabel     matlab.ui.control.Label
        search_AnnotationAttribute      matlab.ui.control.DropDown
        search_AnnotationAttributeLabel  matlab.ui.control.Label
        search_AnnotationPanelLabel     matlab.ui.control.Label
        search_ToolbarListOfProducts    matlab.ui.control.Image
        search_ToolbarWordCloud         matlab.ui.control.Image
        search_ProductInfoLabel         matlab.ui.control.Label
        search_toolGrid                 matlab.ui.container.GridLayout
        search_OrientationProduct       matlab.ui.control.Button
        search_OrientationEntity        matlab.ui.control.Button
        search_OrientationHomologation  matlab.ui.control.Button
        search_ExportTable              matlab.ui.control.Image
        search_FilterSetup              matlab.ui.control.Image
        search_leftPanelVisibility      matlab.ui.control.Image
        Tab2_Report                     matlab.ui.container.Tab
        Tab2_ReportGrid                 matlab.ui.container.GridLayout
        report_Tab2Grid                 matlab.ui.container.GridLayout
        report_menuBtn2Grid             matlab.ui.container.GridLayout
        report_menuBtn2Icon             matlab.ui.control.Image
        report_ProjectWarnIcon          matlab.ui.control.Image
        report_menuBtn2Label            matlab.ui.control.Label
        report_EntityPanel              matlab.ui.container.Panel
        report_EntityGrid               matlab.ui.container.GridLayout
        report_Entity                   matlab.ui.control.EditField
        report_EntityLabel              matlab.ui.control.Label
        report_EntityID                 matlab.ui.control.EditField
        report_EntityCheck              matlab.ui.control.Image
        report_EntityIDLabel            matlab.ui.control.Label
        report_EntityType               matlab.ui.control.DropDown
        report_EntityTypeLabel          matlab.ui.control.Label
        report_EntityPanelLabel         matlab.ui.control.Label
        report_ProjectName              matlab.ui.control.TextArea
        report_ProjectSave              matlab.ui.control.Image
        report_ProjectOpen              matlab.ui.control.Image
        report_ProjectNew               matlab.ui.control.Image
        report_IssuePanel               matlab.ui.container.Panel
        report_IssueGrid                matlab.ui.container.GridLayout
        report_system                   matlab.ui.control.DropDown
        report_systemLabel              matlab.ui.control.Label
        report_Version                  matlab.ui.control.DropDown
        report_VersionLabel             matlab.ui.control.Label
        report_ModelNameLabel           matlab.ui.control.Label
        report_ModelName                matlab.ui.control.DropDown
        report_Issue                    matlab.ui.control.NumericEditField
        report_IssueLabel               matlab.ui.control.Label
        report_IssuePanelLabel          matlab.ui.control.Label
        report_ProjectLabel             matlab.ui.control.Label
        GridLayout7                     matlab.ui.container.GridLayout
        Image5                          matlab.ui.control.Image
        report_Table                    matlab.ui.control.Table
        report_EditProduct              matlab.ui.control.Image
        report_nRows                    matlab.ui.control.Label
        LISTADEPRODUTOSSOBANLISEButtonGroup  matlab.ui.container.ButtonGroup
        AduanaButton                    matlab.ui.control.RadioButton
        FornecedorouusurioButton        matlab.ui.control.RadioButton
        report_Tab1Grid                 matlab.ui.container.GridLayout
        report_ProductInfo              matlab.ui.control.Label
        report_ProductInfoImage         matlab.ui.control.Image
        report_menuBtn1Grid             matlab.ui.container.GridLayout
        report_menuBtn1Icon             matlab.ui.control.Image
        report_menuBtn1Label            matlab.ui.control.Label
        report_ProductInfoLabel         matlab.ui.control.Label
        report_toolGrid                 matlab.ui.container.GridLayout
        report_rightPanelVisibility     matlab.ui.control.Image
        report_FiscalizaUpdate          matlab.ui.control.Image
        report_ReportGeneration         matlab.ui.control.Image
        report_ShowCells2Edit           matlab.ui.control.Image
        report_leftPanelVisibility      matlab.ui.control.Image
        Tab3_Config                     matlab.ui.container.Tab
        report_ContextMenu              matlab.ui.container.ContextMenu
        report_ContextMenu_EditFcn      matlab.ui.container.Menu
        report_ContextMenu_DeleteFcn    matlab.ui.container.Menu
        search_ContextMenu              matlab.ui.container.ContextMenu
        search_ContextMenu_DeleteFcn    matlab.ui.container.Menu
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        % PROPRIEDADES COMUNS A TODOS OS APPS
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder
        entryPointFolder

        % Essa propriedade registra o tipo de execução da aplicação, podendo
        % ser: 'built-in', 'desktopApp' ou 'webApp'.
        executionMode

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos
        % componentes essenciais da GUI (especificados em "createComponents"),
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj

        % Controla a seleção da TabGroup a partir do menu.
        tabGroupController

        % Janela de progresso já criada no DOM. Dessa forma, controla-se
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog

        % Objeto que possibilita integração com o eFiscaliza.
        eFiscalizaObj
        fiscalizaObj

        %-----------------------------------------------------------------%
        % ESPECIFICIDADES
        %-----------------------------------------------------------------%
        projectData

        rawDataTable
        releasedData
        cacheData

        annotationTable

        previousSearch   = ''
        previousItemData = 0
        filteringObj     = tableFiltering
        wordCloudObj
    end


    methods
        %-----------------------------------------------------------------%
        % COMUNICAÇÃO ENTRE PROCESSOS:
        % • ipcMainJSEventsHandler
        %   Eventos recebidos do objeto app.jsBackDoor por meio de chamada
        %   ao método "sendEventToMATLAB" do objeto "htmlComponent" (no JS).
        %
        % • ipcMainMatlabCallsHandler
        %   Eventos recebidos dos apps secundários.
        %-----------------------------------------------------------------%
        function ipcMainJSEventsHandler(app, event)
            % Foi adicionado o evento JS-keydown das teclas ["ArrowUp", "ArrowDown", "Enter", "Escape"]
            % aos componentes app.search_entryPoint (matlab.ui.control.EditField) e app.search_Suggestions
            % (matlab.ui.control.ListBox) usando o JS-backdoor app.jsBackDoor (matlab.ui.control.HTML).

            % Em relação aos callbacks configuráveis no próprio MATLAB:
            % - matlab.ui.control.EditField
            %   (a) Possui os eventos "ValueChangedFcn" e "ValueChangingFcn".
            %   (b) Não responde à tecla "Escape".
            %   (c) Responde às teclas "ArrowUp" e "ArrowDown", controlando a posição
            %       do cursor (início e fim, respectivamente)
            %   (d) Reponde à tecla "Enter", executando "ValueChangingFcn" e "ValueChangedFcn",
            %       nesse ordem.

            % - matlab.ui.control.ListBox
            %   (a) possui os eventos "ValueChangedFcn", "ClickedFcn" e "DoubleClickedFcn".
            %   (b) Responde às teclas "ArrowUp" e "ArrowDown", executando "ValueChangedFcn",
            %       desde que não estejam selecionadas as suas "bordas" (valor 1 e "ArrowUp",
            %       ou valor n e "ArrowDown", por exemplo).

            % Num eventual clique de uma das teclas ["ArrowUp", "ArrowDown", "Enter", "Escape"],
            % o trigger do evento JS-keydown ocorre antes do trigger dos eventos padrões dos
            % componentes matlab.ui.control.EditField e matlab.ui.control.ListBox.

            % Isso é bom, mas ruim por criar uma complexidade extra! :(

            % Quando altero o conteúdo de app.search_entryPoint, sem alterar o seu foco, será executado
            % o evento "ValueChangingFcn". Se pressiono a tecla "Enter", será executada essa função
            % (ipcMainJSEventsHandler) antes de atualizar a propriedade "Value" do app.search_entryPoint.

            % Por conta disso, é essencial inserir waitfor(app.search_entryPoint, 'Value')
            % Isso é conseguido alterando o objeto em foco, de app.search_entryPoint para app.jsBackDoor
            % Ao fazer isso, o MATLAB "executa" a seguinte operação:
            % app.search_entryPoint.Value = app.search_entryPoint.ChangingValue
            switch event.HTMLEventName
                case 'renderer'
                    startup_Controller(app)

                case 'unload'
                    closeFcn(app)

                case 'app.search_entryPoint'
                    focus(app.jsBackDoor)

                    switch event.HTMLEventData
                        case {'Escape', 'Tab'}
                            search_EntryPoint_CheckIfNeedsUpdate(app)
                            if numel(app.search_entryPoint.Value) < app.General.search.minCharacters
                                search_EntryPoint_InitialValue(app)
                            end

                            if strcmp(event.HTMLEventData, 'Tab') && app.search_entryPointImage.Enable
                                focus(app.search_entryPointImage)
                            end

                            pause(.050)
                            set(app.search_Suggestions, Visible=0, Value={})

                        otherwise
                            search_EntryPoint_CheckIfNeedsUpdate(app)
                            if numel(app.search_entryPoint.Value) < app.General.search.minCharacters
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.search_entryPoint.UserData.id));

                            else
                                switch event.HTMLEventData
                                    case 'ArrowDown'
                                        if strcmp(app.General.search.mode, 'tokens')
                                            app.previousItemData = 1;

                                            set(app.search_Suggestions, 'Visible', 1, 'Value', 1)
                                            scroll(app.search_Suggestions, "top")
                                            focus(app.search_Suggestions)
                                        end

                                    case 'ArrowUp'
                                        if strcmp(app.General.search.mode, 'tokens')
                                            nMaxValues = numel(app.search_Suggestions.Items);

                                            app.previousItemData = nMaxValues;
                                            set(app.search_Suggestions, 'Visible', 1, 'Value', nMaxValues)
                                            scroll(app.search_Suggestions, "bottom")
                                            focus(app.search_Suggestions)
                                        end

                                    case 'Enter'
                                        drawnow
                                        search_EntryPoint_ImageClicked(app)                                        
                                        set(app.search_Suggestions, Visible=0, Value={})
                                end
                            end
                    end

                case 'app.search_Suggestions'
                    switch event.HTMLEventData
                        case 'ArrowDown'
                            nMaxValues = numel(app.search_Suggestions.Items);

                            if (app.previousItemData == nMaxValues) && (app.search_Suggestions.Value == nMaxValues)
                                app.previousItemData = 0;

                                set(app.search_Suggestions, Visible=0, Value={})
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.search_entryPoint.UserData.id));
                            else
                                if isnumeric(app.search_Suggestions.Value)
                                    app.previousItemData = app.search_Suggestions.Value;
                                else
                                    app.previousItemData = 0;
                                end
                            end

                        case 'ArrowUp'
                            if (app.previousItemData == 1) && (app.search_Suggestions.Value == 1)
                                app.previousItemData = 0;

                                set(app.search_Suggestions, Visible=0, Value={})
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.search_entryPoint.UserData.id));
                            else
                                if isnumeric(app.search_Suggestions.Value)
                                    app.previousItemData = app.search_Suggestions.Value;
                                else
                                    app.previousItemData = 0;
                                end
                            end

                        case {'Enter', 'Tab'}
                            if isnumeric(app.search_Suggestions.Value)
                                eventValue = app.search_Suggestions.Items{app.search_Suggestions.Value};

                                app.search_entryPoint.Value = eventValue;
                                search_SuggestionAlgorithm(app, eventValue, false)
                                
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.search_entryPoint.UserData.id));
                            end

                        case 'Escape'
                            set(app.search_Suggestions, Visible=0, Value={})
                    end

                case 'BackgroundColorTurnedInvisible'
                    switch event.HTMLEventData
                        case 'SplashScreen'
                            if isvalid(app.SplashScreen)
                                delete(app.SplashScreen)
                                app.popupContainerGrid.Visible = 0;
                            end
                        otherwise
                            error('UnexpectedEvent')
                    end

                case 'customForm'
                    switch event.HTMLEventData.uuid
                        case 'eFiscalizaSignInPage'
                            report_uploadInfoController(app, event.HTMLEventData, 'uploadDocument')
                        case 'openDevTools'
                            if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                webWin.openDevTools();
                            end
                    end

                otherwise
                    error('UnexpectedEvent')
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallsHandler(app, callingApp, operationType, varargin)
            try
                switch class(callingApp)
                    % CONFIG
                    case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "CONFIG", app.General)

                            case 'checkDataHubLampStatus'
                                DataHubWarningLamp(app)

                            case 'openDevTools'
                                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                            case 'searchModeChanged'
                                search_EntryPoint_Layout(app)

                            case 'wordCloudAlgorithmChanged'
                                if ~isempty(app.wordCloudObj)
                                    if ~strcmp(app.wordCloudObj.Algorithm, app.General.search.wordCloud.algorithm)
                                        delete(app.wordCloudObj.Chart.Parent)
                                        clear('app.wordCloudObj.Chart.Parent')
                    
                                        app.wordCloudObj = wordCloud(app.search_WordCloudPanel, app.General.search.wordCloud.algorithm);
                                        app.search_WordCloudPanel.Tag = '';

                                        app.search_ProductInfo.UserData.selectedRow = [];
                                        app.search_ProductInfo.UserData.showedHom   = '';
                    
                                        search_Table_SelectionChanged(app)
                                    end
                                end

                            case 'searchVisibleColumnsChanged'
                                [columnNames, columnWidth] = search_Table_ColumnNames(app);
                                set(app.search_Table, 'ColumnName', upper(columnNames), 'ColumnWidth', columnWidth)
                    
                                if ~isempty(app.search_Table.Data)
                                    if (numel(columnNames) ~= width(app.search_Table.Data)) || any(~ismember(app.search_Table.ColumnName, upper(columnNames)))
                                        secundaryIndex = app.search_Table.UserData.secundaryIndex;
                                        app.search_Table.Data = app.rawDataTable(secundaryIndex, columnNames);
                                    end
                                end

                            otherwise
                                error('UnexpectedCall')
                        end

                    % DOCKS:OTHERS
                    case {'auxApp.dockFilterSetup', 'auxApp.dockFilterSetup_exported', ... % SEARCH:FILTERSETUP
                          'auxApp.dockProductInfo', 'auxApp.dockProductInfo_exported'}     % REPORT:PRODUCTINFO

                        % Esse ramo do switch trata chamados de módulos auxiliares dos
                        % modos "SEARCH" e "REPORT". Algumas das funcionalidades
                        % desses módulos requerem atualização do SCH:
                        % (a) SEARCH: atualização da filtragem, impactando na tabela com
                        %     resultado de busca e o seu painel.
                        % (b) REPORT: atualização da tabela com a lista de produtos sob
                        %     análise e o seu painel.

                        % O flag "updateFlag" provê essa atualização, e o flag "returnFlag"
                        % evita que o módulo seja "fechado" (por meio da invisibilidade do
                        % app.popupContainerGrid).

                        updateFlag = varargin{1};
                        returnFlag = varargin{2};

                        if updateFlag
                            switch operationType
                                case 'SEARCH:FILTERSETUP'
                                    search_Filtering_secundaryFilter(app)
                                    search_FilterSpecification(app)

                                case 'REPORT:EditInfo'
                                    selectedRow = varargin{3};

                                    report_UpdatingTable(app)
                                    if isequal(selectedRow, app.report_ProductInfo.UserData.selectedRow)
                                        app.report_ProductInfo.UserData.selectedRow = [];
                                        report_TableSelectionChanged(app)
                                    end
                                    report_ProjectWarnImageVisibility(app)

                                case 'REPORT:UITableSelectionChanged'
                                    selectedRow = varargin{3};

                                    app.report_Table.Selection = selectedRow;
                                    report_TableSelectionChanged(app)
                            end
                        end

                        if returnFlag
                            return
                        end

                        app.popupContainerGrid.Visible = 0;

                    otherwise
                        error('UnexpectedCall')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end

            % Caso um app auxiliar esteja em modo DOCK, o progressDialog do
            % app auxiliar coincide com o do SCH. Força-se, portanto, a condição
            % abaixo para evitar possível bloqueio da tela.
            app.progressDialog.Visible = 'hidden';
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor.HTMLSource           = appUtil.jsBackDoorHTMLSource();
            app.jsBackDoor.HTMLEventReceivedFcn = @(~, evt)ipcMainJSEventsHandler(app, evt);
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false];
            end

            switch tabIndex
                case 0
                    sendEventToHTMLSource(app.jsBackDoor, 'startup', app.executionMode);
                    app.progressDialog  = ccTools.ProgressDialog(app.jsBackDoor);
                    customizationStatus = [false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    appName = class(app);

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1 % SEARCH
                            elToModify = {                       ...
                                app.search_entryPoint,           ...
                                app.popupContainerGrid,          ...
                                app.popupContainer,              ...
                                app.search_Suggestions,          ...
                                app.search_ProductInfo,          ... % ui.TextView
                                app.search_ProductInfoImage      ... % ui.TextView (Background image)
                                };

                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {                                                                                                                                             ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'generation', 1, 'style',    struct('borderWidth', '0px')),                                                                                         ...
                                    struct('appName', appName, 'dataTag', elDataTag{2}, 'generation', 0, 'style',    struct('backgroundColor', 'rgba(255,255,255,0.65)')),                                                                  ...
                                    struct('appName', appName, 'dataTag', elDataTag{3}, 'generation', 0, 'style',    struct('borderRadius', '5px', 'boxShadow', '0 2px 5px 1px #a6a6a6')),                                                  ...
                                    struct('appName', appName, 'dataTag', elDataTag{3}, 'generation', 1, 'style',    struct('borderRadius', '5px', 'borderColor', '#bfbfbf')),                                                              ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'generation', 2, 'listener', struct('componentName', 'app.search_entryPoint',  'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})), ...
                                    struct('appName', appName, 'dataTag', elDataTag{4}, 'generation', 1, 'listener', struct('componentName', 'app.search_Suggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})), ...
                                    });

                                ui.TextView.startup(app.jsBackDoor, elToModify{5}, appName);
                                ui.TextView.startup(app.jsBackDoor, elToModify{6}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                            end

                        case 2 % REPORT
                            elToModify = {...
                                app.report_ProductInfo, ...                 % ui.TextView
                                app.report_ProductInfoImage, ...            % ui.TextView (Background image)
                            };

                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
                                ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                            end

                            app.report_ModelName.Items = [{''}, {reportLibConnection.Controller.Read(app.rootFolder).Name}];

                        otherwise
                            % Customização dos módulos que são renderizados
                            % nesta figura são controladas pelos próprios
                            % módulos.
                    end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO DO APP
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

            % Essa propriedade registra o tipo de execução da aplicação, podendo
            % ser: 'built-in', 'desktopApp' ou 'webApp'.
            app.executionMode = appUtil.ExecutionMode(app.UIFigure);
            if ~strcmp(app.executionMode, 'webApp')
                app.FigurePosition.Visible = 1;
                appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
            end

            % Identifica o local deste arquivo .MLAPP, caso se trate das versões
            % "built-in" ou "webapp", ou do .EXE relacionado, caso se trate da
            % versão executável (neste caso, o ctfroot indicará o local do .MLAPP).
            MFilePath = fileparts(mfilename('fullpath'));
            app.rootFolder = appUtil.RootFolder(class.Constants.appName, MFilePath);

            % Customizações...
            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)
            pause(.100)

            % Inicia operações de gerar tela inicial, customizar componentes e
            % de ler informações constantes em arquivos externos, aplicando-as.
            startup_ConfigFileRead(app, MFilePath)
            startup_AppProperties(app)
            startup_GUIComponents(app)

            % Inicia módulo de operação paralelo...
            parpoolCheck()

            % Diminui a opacidade do SplashScreen. Esse processo dura
            % cerca de 1250 ms. São 50 iterações em que em cada uma
            % delas a opacidade da imagem diminuir em 0.02. Entre cada
            % iteração, 25 ms. E executa drawnow, forçando a renderização
            % em tela dos componentes.
            sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
            drawnow

            % Força a exclusão do SplashScreen.
            if isvalid(app.SplashScreen)
                pause(1)
                delete(app.SplashScreen)
            end
            app.popupContainerGrid.Visible = 0;
        end

        %-----------------------------------------------------------------%
        function startup_ConfigFileRead(app, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appUtil.generalSettingsLoad(class.Constants.appName, app.rootFolder, {'Annotation.xlsx'});
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'error', msgWarning);
            end

            % Para criação de arquivos temporários, cria-se uma pasta da
            % sessão.
            tempDir = tempname;
            mkdir(tempDir)
            app.General_I.fileFolder.tempPath  = tempDir;
            app.General_I.fileFolder.MFilePath = MFilePath;

            switch app.executionMode
                case 'webApp'
                    % Força a exclusão do SplashScreen do MATLAB WebDesigner.
                    sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");

                    % Webapp também não suporta outras janelas, de forma que os
                    % módulos auxiliares devem ser abertos na própria janela
                    % do appAnalise.
                    app.dockModule_Undock.Visible     = 0;

                    app.General_I.operationMode.Debug = false;
                    app.General_I.operationMode.Dock  = true;

                    % A pasta do usuário não é configurável, mas obtida por
                    % meio de chamada a uiputfile.
                    app.General_I.fileFolder.userPath = tempDir;

                otherwise
                    % Resgata a pasta de trabalho do usuário (configurável).
                    userPaths = appUtil.UserPaths(app.General_I.fileFolder.userPath);
                    app.General_I.fileFolder.userPath = userPaths{end};

                    switch app.executionMode
                        case 'desktopStandaloneApp'
                            app.General_I.operationMode.Debug = false;
                        case 'MATLABEnvironment'
                            app.General_I.operationMode.Debug = true;
                    end
            end

            % Especificidades...
            app.General_I.ui.SCHData = struct2table(app.General_I.ui.SCHData);
            app.General_I.search.cacheColumns = 'Modelo | Nome Comercial';

            app.General = app.General_I;
            app.General.AppVersion = util.getAppVersion('app', app.rootFolder, MFilePath, tempDir);
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.projectData = projectLib(app, app.General.ui.typeOfProduct.options, app.General.ui.typeOfViolation.options);
            startup_mainVariables(app)
        end

        %-----------------------------------------------------------------%
        function startup_mainVariables(app)
            DataHub_GET     = app.General.fileFolder.DataHub_GET;
            SCHDataFileName = app.General.search.dataSources.main;
            SCHDataFullFile = fullfile(DataHub_GET, SCHDataFileName);

            try
                if ~isfolder(DataHub_GET)
                    error('Pendente mapear a pasta "SCH" do repositório "DataHub - GET".')
                elseif isfolder(DataHub_GET) && ~isfile(SCHDataFullFile)
                    error('Apesar de mapeada a pasta "SCH" do repositório "DataHub - GET", não foi encontrado o arquivo %s. Favor verificar se a pasta foi mapeada corretamente e, persistindo o erro, relatar isso ao Escritório de inovação da SFI.', SCHDataFileName)
                end
                startup_ReadSCHDataFile(app, SCHDataFullFile)

            catch ME
                SCHDataFullFile = fullfile(app.rootFolder, 'config', 'DataBase', SCHDataFileName);
                startup_ReadSCHDataFile(app, SCHDataFullFile)

                msgWarning = ME.message;
            end

            app.annotationTable = readFile.Annotation(app.rootFolder, DataHub_GET);

            if exist('msgWarning', 'var')
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end
        end

        %-----------------------------------------------------------------%
        function startup_ReadSCHDataFile(app, SCHDataFullFile)
            [app.rawDataTable, ...
                app.releasedData, ...
                app.cacheData] = readFile.SCHData(SCHDataFullFile);
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            % Cria o objeto que conecta o TabGroup com o GraphicMenu.
            app.tabGroupController = tabGroupGraphicMenu(app.menu_Grid, app.TabGroup, app.progressDialog, @app.jsBackDoor_Customizations, '');

            addComponent(app.tabGroupController, "Built-in", "",                 app.menu_Button1, "AlwaysOn", struct('On', 'Zoom_32Yellow.png',      'Off', 'Zoom_32White.png'),      matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "Built-in", "",                 app.menu_Button2, "AlwaysOn", struct('On', 'Detection_32Yellow.png', 'Off', 'Detection_32White.png'), matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig", app.menu_Button3, "AlwaysOn", struct('On', 'Settings_36Yellow.png',  'Off', 'Settings_36White.png'),  app.menu_Button1,                    3)

            % Salva na propriedade "UserData" as opções de ícone e o índice
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.search_ToolbarAnnotation.UserData     = struct('iconOptions', {{'Edit_18x18Gray.png',    'Edit_18x18Blue.png'}});
            app.search_ToolbarWordCloud.UserData      = struct('iconOptions', {{'Cloud_32x32Gray.png',   'Cloud_32x32Blue.png'}}, 'Value', false);
            app.search_ToolbarListOfProducts.UserData = struct('iconOptions', {{'Box_32x32Gray.png',     'Box_32x32Blue.png'}});

            % Inicialização da propriedade "UserData" da tabela.
            app.search_entryPointImage.UserData       = struct('value2Search', '', 'words2Search', '');
            app.search_Table.UserData                 = struct('primaryIndex', [], 'secundaryIndex', [], 'cacheColumns', {{}});

            % Os painéis de metadados do registro selecionado nas tabelas já 
            % tem, na sua propriedade "UserData", a chave "id" que armazena 
            % o "data-tag" que identifica o componente no código HTML. 
            % Adicionam-se duas novas chaves: "showedRow" e "showedHom".
            app.search_ProductInfo.UserData.selectedRow = [];
            app.search_ProductInfo.UserData.showedHom   = '';

            app.report_ProductInfo.UserData.selectedRow = [];
            app.report_ProductInfo.UserData.showedHom   = '';

            % Outros...
            app.search_OrientationHomologation.UserData = false;
            app.search_OrientationEntity.UserData       = false;
            app.search_OrientationProduct.UserData      = true;

            userPaths = appUtil.UserPaths(app.General.fileFolder.userPath);
            app.General.fileFolder.userPath = userPaths{end};

            search_EntryPoint_Layout(app)
            DataHubWarningLamp(app)
        end

        %-----------------------------------------------------------------%
        function DataHubWarningLamp(app)
            if isfolder(app.General.fileFolder.DataHub_GET) && isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % TABGROUPCONTROLLER
        %-----------------------------------------------------------------%
        % function hAuxApp = auxAppHandle(app, auxAppName)
        %     arguments
        %         app
        %         auxAppName string {mustBeMember(auxAppName, ["DRIVETEST", "SIGNALANALYSIS", "RFDATAHUB", "CONFIG"])}
        %     end
        %
        %     hAuxApp = app.tabGroupController.Components.appHandle{app.tabGroupController.Components.Tag == auxAppName};
        % end

        %-----------------------------------------------------------------%
        function inputArguments = auxAppInputArguments(app, auxAppName)
            arguments
                app
                auxAppName char {mustBeMember(auxAppName, {'SEARCH', 'REPORT', 'CONFIG'})}
            end

            % [auxAppIsOpen, ...
            %  auxAppHandle] = checkStatusModule(app.tabGroupController, auxAppName);

            inputArguments = {app};

            % switch auxAppName
            %     case 'SEARCH'
            %
            %     case 'REPORT'
            %
            %     case 'CONFIG'
            % end
        end

        %-----------------------------------------------------------------%
        function menu_LayoutPopupApp(app, auxiliarApp, varargin)
            arguments
                app
                auxiliarApp char {mustBeMember(auxiliarApp, {'FilterSetup', 'ProductInfo', 'AddFiles'})}
            end

            arguments (Repeating)
                varargin
            end

            app.progressDialog.Visible = 'visible';

            % Inicialmente ajusta as dimensões do container.
            switch auxiliarApp
                case 'FilterSetup'; screenWidth = 412; screenHeight = 464;
                case 'ProductInfo'; screenWidth = 474; screenHeight = 588;
                case 'AddFiles';    screenWidth = 880; screenHeight = 480;
            end

            app.popupContainerGrid.ColumnWidth{2} = screenWidth;
            app.popupContainerGrid.RowHeight{3}   = screenHeight-180;

            % Executa o app auxiliar, mas antes tenta configurar transparência
            % do BackgroundColor do Grid (caso não tenha sido aplicada anteriormente).
            ccTools.compCustomizationV2(app.jsBackDoor, app.popupContainerGrid, 'backgroundColor', 'rgba(255,255,255,0.65)')
            inputArguments = [{app}, varargin];
            eval(sprintf('auxApp.dock%s_exported(app.popupContainer, inputArguments{:})', auxiliarApp))

            app.popupContainerGrid.Visible = 1;
            app.popupContainer.Visible     = 1;

            app.progressDialog.Visible = 'hidden';
        end
    end

    methods (Access = private)
        %-----------------------------------------------------------------%
        % SISTEMA DE GESTÃO DA FISCALIZAÇÃO (eFiscaliza/SEI)
        %-----------------------------------------------------------------%                
        function status = report_checkEFiscalizaIssueId(app)
            status = (app.report_Issue.Value > 0) && (app.report_Issue.Value < inf);
        end

        %-----------------------------------------------------------------%
        function report_uploadInfoController(app, credentials, operation)
            communicationStatus = report_sendHTMLDocToSEIviaEFiscaliza(app, credentials, operation);
            if communicationStatus
                report_sendJSONFileToSharepoint(app)
            end
        end

        %-------------------------------------------------------------------------%
        function communicationStatus = report_sendHTMLDocToSEIviaEFiscaliza(app, credentials, operation)
            app.progressDialog.Visible = 'visible';
            communicationStatus = false;

            try
                if ~isempty(credentials)
                    app.eFiscalizaObj = ws.eFiscaliza(credentials.login, credentials.password);
                end

                switch operation
                    case 'uploadDocument'
                        env = strsplit(app.report_system.Value);
                        if numel(env) < 2
                            env = 'PD';
                        else
                            env = env{2};
                        end

                        issue    = struct('type', 'ATIVIDADE DE INSPEÇÃO', 'id', app.report_Issue.Value);
                        fileName = app.projectData.generatedFiles.lastHTMLDocFullPath;
                        docSpec  = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId   = docSpec.internal.typeId;

                        [status, msg] = run(app.eFiscalizaObj, env, operation, issue, docSpec, fileName);
        
                    otherwise
                        error('Unexpected call')
                end
                
                if ~contains(msg, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(msg)
                end

                modalWindowIcon     = 'success';
                modalWindowMessage  = sprintf('<b>%s</b>\n%s', status, msg);
                communicationStatus = true;

            catch ME
                app.eFiscalizaObj   = [];
                
                modalWindowIcon     = 'error';
                modalWindowMessage  = ME.message;
            end

            appUtil.modalWindow(app.UIFigure, modalWindowIcon, modalWindowMessage);
            app.progressDialog.Visible = 'hidden';
        end

        %------------------------------------------------------------------------%
        function report_sendJSONFileToSharepoint(app)
            JSONFile = app.projectData.generatedFiles.lastTableFullPath;            
            [status, msg] = copyfile(JSONFile, app.General.fileFolder.DataHub_POST, 'f');

            if ~status
                appUtil.modalWindow(app.UIFigure, 'error', msg);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function search_SuggestionAlgorithm(app, eventValue, panelVisibility)
            value2Search = textAnalysis.preProcessedData(eventValue);
            search_EntryPointImage_Status(app, value2Search)

            if strcmp(app.General.search.mode, 'tokens')
                if numel(value2Search) >= app.General.search.minCharacters
                    listOfColumns = search_Filtering_PrimaryTableColumns(app);
                    nMinValues    = app.General.search.minDisplayedTokens;

                    [similarStrings, idxFiltered, redFontFlag] = suggestion.getSimilarStrings(app.cacheData, value2Search, listOfColumns, nMinValues);

                    set(app.search_Suggestions, 'Visible', panelVisibility, 'Value', {}, 'Items', similarStrings, 'ItemsData', 1:numel(idxFiltered))
                    search_EntryPoint_Color(app, redFontFlag)

                    app.previousSearch = eventValue;
                end
            end
        end

        %-----------------------------------------------------------------%
        function relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom)
            annotationLogical      = strcmp(app.annotationTable.("Homologação"), showedHom);
            relatedAnnotationTable = app.annotationTable(annotationLogical, :);
        end


        %-----------------------------------------------------------------%
        function search_Annotation_Add2Cache(app, selectedRow, showedHom, attributeName, attributeValue, wourdCloudRefreshTag)
            % !! PONTO DE EVOLUÇÃO !!
            % IMPLEMENTADA INCLUSÃO DE ANOTAÇÃO, ALÉM DE EDIÇÃO DE ANOTAÇÃO
            % DO WORDCLOUD. PENDENTE EXCLUSÃO DE ANOTAÇÃO, ALÉM DA EDIÇÃO
            % DOS OUTROS TIPOS DE ANOTAÇÃO.
            newRowTable = table({char(matlab.lang.internal.uuid())},           ...
                {datestr(now, 'dd/mm/yyyy HH:MM:SS')},         ...
                {ccTools.fcn.OperationSystem('computerName')}, ...
                {ccTools.fcn.OperationSystem('userName')},     ...
                {showedHom},                                   ...
                {attributeName},                               ...
                {attributeValue},                              ...
                1, 'VariableNames', class.Constants.annotationTableColumns);

            idx1 = find(strcmp(app.annotationTable.("Homologação"), showedHom))';
            if isempty(idx1) || wourdCloudRefreshTag
                app.annotationTable(end+1,:) = newRowTable;

            else
                if any(strcmp(app.annotationTable.("Atributo")(idx1), attributeName) & strcmp(app.annotationTable.("Valor")(idx1), attributeValue))
                    appUtil.modalWindow(app.UIFigure, 'warning', sprintf('Conjunto atributo/valor já consta como anotação do registro %s.', showedHom));
                    return

                else
                    app.annotationTable(end+1,:) = newRowTable;
                end
            end

            if wourdCloudRefreshTag
                idx2 = find(strcmp(app.annotationTable.("Homologação"), showedHom) & strcmp(app.annotationTable.("Atributo"), 'WordCloud'));
                app.annotationTable(idx2(1:end-1), :) = [];
            end

            % A cada nova inserção, gera-se uma planilha que é submetida à
            % pasta POST, ou é salva localmente em cache.
            [app.annotationTable, msgWarning] = writeFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end

            % Atualizando o painel com os metadados do registro selecionado...
            relatedAnnotationTable   = search_Annotation_RelatedTable(app, showedHom);
            htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, relatedAnnotationTable);
            misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, selectedRow, showedHom);

            % Ajusta apenas o estilo de anotação do registro.
            search_Table_RemoveStyle(app, 'cell')
            search_Table_AnnotationIcon(app)
            % !! PONTO DE EVOLUÇÃO !!
        end


        %-----------------------------------------------------------------%
        function search_Filtering_primaryFilter(app, words2Search)
            app.progressDialog.Visible = 'visible';

            % Rotina de inicialização dos objetos relacionados aos filtros
            % secundários.
            app.filteringObj.filterRules(:,:) = [];

            % O "primaryTempIndex" retorna os registros da tabela que deram match
            % com "words2Search". Uma homologação, contudo, pode estar relacionada
            % a vários registros da base de dados, por isso devem ser buscados
            % os demais.

            % A order dos registros é importante APENAS se foi usado o algoritmo
            % Levenshtein p/ cálculo da distância entre as strings.
            if strcmp(app.General.search.mode, 'tokens') && (numel(words2Search) <= app.General.search.minDisplayedTokens)
                sortOrder = 'stable';
            else
                sortOrder = 'unstable';
            end

            cacheColumnNames   = search_Table_PrimaryColumnNames(app);
            listOfCacheColumns = cellfun(@(x) sprintf('_%s', x), cacheColumnNames, 'UniformOutput', false);
            searchFunction     = app.General.search.function;

            primaryTempIndex   = run(app.filteringObj, 'words2Search', app.rawDataTable, listOfCacheColumns, sortOrder, searchFunction, words2Search);
            primaryHomProducts = unique(app.rawDataTable(primaryTempIndex,:).("Homologação"), 'stable');

            primaryIndex       = run(app.filteringObj, 'words2Search', app.rawDataTable, {'Homologação'}, sortOrder, 'strcmp', primaryHomProducts);
            GUIColumns         = search_Table_ColumnNames(app);

            set(app.search_Table, 'Data',      app.rawDataTable(primaryIndex, GUIColumns), ...
                'UserData',  struct('primaryIndex', primaryIndex, 'secundaryIndex', primaryIndex, 'cacheColumns', {cacheColumnNames}))

            % Cria chart para a nuvem de palavras...
            if isempty(app.wordCloudObj)
                app.wordCloudObj = wordCloud(app.search_WordCloudPanel, app.General.search.wordCloud.algorithm);
            end

            % Torna visível a tabela e outros elementos relacionados à tabela...
            search_Table_Visibility(app)

            % Renderiza em tela o número de linhas, além de selecionar a primeira
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app, 'search')
            search_Table_InitialSelection(app, true)

            % Aplica estilo na tabela e verifica se a tabela está visível...
            search_Table_AddStyle(app)

            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        function search_Filtering_secundaryFilter(app)
            primaryIndex = app.search_Table.UserData.primaryIndex;
            GUIColumns   = search_Table_ColumnNames(app);

            if ~isempty(app.filteringObj.filterRules)
                logicalArray   = run(app.filteringObj, 'filterRules', app.rawDataTable(primaryIndex,:));
                secundaryIndex = primaryIndex(logicalArray);
            else
                secundaryIndex = primaryIndex;
            end

            app.search_Table.Data = app.rawDataTable(secundaryIndex, GUIColumns);
            app.search_Table.UserData.secundaryIndex = secundaryIndex;

            % Renderiza em tela o número de linhas, além de selecionar a primeira
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app, 'search')
            search_Table_InitialSelection(app, false)

            % Aplica estilo na tabela...
            search_Table_AddStyle(app)
        end

        %-----------------------------------------------------------------%
        function listOfColumns = search_Filtering_PrimaryTableColumns(app)
            listOfColumns  = app.General.search.cacheColumns;
        end

        %-----------------------------------------------------------------%
        function search_SuggestionPanel_InitialValues(app)
            set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
        end

        %-----------------------------------------------------------------%
        function search_EntryPoint_Layout(app)
            switch app.General.search.mode
                case 'tokens'
                    app.search_Document.ColumnWidth = {412, '1x'};
    
                otherwise
                    app.search_Document.ColumnWidth = {'1x', 0};
    
                    app.previousSearch   = '';
                    app.previousItemData = 0;                                        
                    set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
            end
            search_EntryPoint_InitialValue(app)
        end

        %-----------------------------------------------------------------%
        function search_EntryPoint_InitialValue(app)
            set(app.search_entryPoint, 'Value', '', 'FontColor', [0,0,0])
            app.search_entryPointImage.Enable = 0;
        end

        %-----------------------------------------------------------------%
        function search_EntryPoint_CheckIfNeedsUpdate(app)
            % Conforme exposto nos comentários da função "ipcMainJSEventsHandler", quando altero o conteúdo
            % de app.search_entryPoint, sem alterar o seu foco, será executado o evento "ValueChangingFcn".
            % Se pressiono a tecla "Enter", será executada a função "ipcMainJSEventsHandler" antes de atualizar
            % a propriedade "Value" do app.search_entryPoint.

            % Por conta disso, é essencial inserir WAITFOR. O problema é que eventualmente o MATLAB
            % perde o momento exato da alteração da propriedade "Value" de app.search_entryPoint
            % e isso trava a execução do app.

            % Evidenciado que em condições normais o WAITFOR demora entre 25 e 50 milisegundos
            % para atualizar a citada propriedade. Consequentemente, foi substituído o WAITFOR por
            % um LOOP+PAUSE.

            % waitfor(app.search_entryPoint, 'Value')

            tWaitFor = tic;
            while toc(tWaitFor) < .050
                if strcmp(app.search_entryPoint.Value, app.previousSearch)
                    break
                end
                pause(.010)
            end
        end


        %-----------------------------------------------------------------%
        function search_EntryPoint_Color(app, redFlag)
            if redFlag
                fontColor = [1,0,0];
            else
                fontColor = [0,0,0];
            end
            app.search_entryPoint.FontColor = fontColor;
            %drawnow
        end


        %-----------------------------------------------------------------%
        function search_EntryPointImage_Status(app, value2Search)
            if numel(value2Search) < app.General.search.minCharacters
                app.search_entryPointImage.Enable = 0;
                search_SuggestionPanel_InitialValues(app)
            else
                app.search_entryPointImage.Enable = 1;
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_Visibility(app)
            if ~app.search_Table.Visible
                app.search_leftPanelVisibility.Enable = 1;

                app.search_Table.Visible    = 1;
                app.search_Metadata.Visible = 1;
                app.search_nRows.Visible    = 1;

                if ~app.Tab1_SearchGrid.ColumnWidth{1}
                    misc_Panel_VisibilityImageClicked(app, struct('Source', app.search_leftPanelVisibility))
                end
            end
        end


        %-----------------------------------------------------------------%
        function search_FilterSpecification(app)
            allButtons    = [app.search_OrientationHomologation, ...
                app.search_OrientationEntity,       ...
                app.search_OrientationProduct];
            clickedButton = findobj(allButtons, 'UserData', true);

            primaryTag    = strjoin(clickedButton.Tooltip);
            secondaryTag  = strjoin(FilterList(app.filteringObj, 'SCH'), ', ');
            if isempty(secondaryTag)
                secondaryTag = '[]';
            end

            value2Search = app.search_entryPointImage.UserData.value2Search;
            words2Search = app.search_entryPointImage.UserData.words2Search;

            switch app.General.search.mode
                case 'tokens'
                    if ~isempty(words2Search)
                        nWords2Search  = numel(words2Search);
                        nWordsContains = sum(contains(words2Search, value2Search));
    
                        % Inserindo o texto "e similiares" caso exista alguma
                        % palavra-chave que não contenha o termo a procurar.
                        if nWordsContains < nWords2Search
                            searchNote = ' e similares';
                        else
                            searchNote = '';
                        end
    
                        app.search_Metadata.Text = sprintf('Exibindo resultados para "<b>%s</b>"%s\n<p style="color: #808080; font-size:10px;">%s<br>Filtragem secundária: %s</p>', ...
                            value2Search, searchNote, primaryTag, secondaryTag);
                    end

                otherwise
                    if ~isempty(words2Search)
                        app.search_Metadata.Text = sprintf('Exibindo resultados para %s\n<p style="color: #808080; font-size:10px;">%s<br>Filtragem secundária: %s</p>', ...
                            strjoin("""<b>" + string(words2Search) + "</b>""", ', '), primaryTag, secondaryTag);
                    end
            end
        end


        %-----------------------------------------------------------------%
        function columnInfo = search_Table_ColumnInfo(app, type)
            switch type
                case 'staticColumns'
                    staticLogical  = logical(app.General.ui.SCHData.columnPosition);
                    staticIndex    = app.General.ui.SCHData.columnPosition(staticLogical);
                    [~, idxOrder]  = sort(staticIndex);
                    columnList     = app.General.ui.SCHData.name(staticLogical);
                    columnInfo     = columnList(idxOrder);

                case 'visibleColumns'
                    visibleLogical = logical(app.General.ui.SCHData.visible);
                    columnInfo     = app.General.ui.SCHData.name(visibleLogical);

                case 'allColumns'
                    columnInfo     = app.General.ui.SCHData.name;

                case 'allColumnsWidths'
                    columnInfo     = app.General.ui.SCHData.columnWidth;
            end
        end


        %-----------------------------------------------------------------%
        function cacheColumns = search_Table_PrimaryColumnNames(app)
            cacheColumns = strsplit(search_Filtering_PrimaryTableColumns(app), ' | ');
        end


        %-----------------------------------------------------------------%
        function [columnNames, columnWidths] = search_Table_ColumnNames(app)
            checkedNodes = search_Table_ColumnInfo(app, 'visibleColumns');
            staticColums = search_Table_ColumnInfo(app, 'staticColumns');
            columnNames  = unique([staticColums; checkedNodes], 'stable');

            allColumns   = search_Table_ColumnInfo(app, 'allColumns');
            widthColumns = search_Table_ColumnInfo(app, 'allColumnsWidths');

            columnWidths = {};
            for ii = 1:numel(columnNames)
                columnName       = columnNames{ii};
                columnIndex      = find(strcmp(allColumns, columnName), 1);

                columnWidths{ii} = widthColumns{columnIndex};
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_InitialSelection(app, focusFlag)
            if isempty(app.search_Table.Data)
                app.search_Table.Selection    = [];
                app.search_FilterSetup.Enable = 0;
                app.search_ExportTable.Enable = 0;
            else
                app.search_Table.Selection    = 1;
                app.search_FilterSetup.Enable = 1;
                app.search_ExportTable.Enable = 1;
            end
            search_Table_SelectionChanged(app)

            if focusFlag
                focus(app.search_Table)
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_AddStyle(app)
            search_Table_RemoveStyle(app, 'all')

            % Row striping
            [~, ~, uniqueHomIndex] = unique(app.search_Table.Data.("Homologação"), 'stable');
            listOfRows             = find(~mod(uniqueHomIndex, 2));
            if ~isempty(listOfRows)
                addStyle(app.search_Table, class.Constants.configStyle1, 'row', listOfRows)
            end

            % Table primary columns background
            cacheColumns = app.search_Table.UserData.cacheColumns;
            addStyle(app.search_Table, class.Constants.configStyle2, 'column', cacheColumns)

            % Table annotation icon
            search_Table_AnnotationIcon(app)
            drawnow nocallbacks
        end


        %-----------------------------------------------------------------%
        function search_Table_RemoveStyle(app, styleType)
            switch styleType
                case 'all'
                    removeStyle(app.search_Table)

                otherwise
                    styleTypeIndex  = find(strcmp(cellstr(app.search_Table.StyleConfigurations.Target), styleType));
                    if ~isempty(styleTypeIndex)
                        removeStyle(app.search_Table, styleTypeIndex)
                    end
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_AnnotationIcon(app)
            % Posição da coluna "Homologação".
            homColumnIndex    = find(strcmp(app.search_Table.Data.Properties.VariableNames, 'Homologação'), 1);

            % Valores únicos de homologação e seus índices...
            [listOfHom, ...
                lisOfHomIndex]   = unique(app.search_Table.Data.("Homologação"), 'stable');

            % Identifica registros para os quais existe anotação registrada,
            % aplicando o estilo.
            annotationLogical = ismember(listOfHom, unique(app.annotationTable.("Homologação")));
            annotationIndex   = lisOfHomIndex(annotationLogical);
            listOfCells       = [annotationIndex, repmat(homColumnIndex, numel(annotationIndex), 1)];

            if ~isempty(listOfCells)
                switch app.General.search.cacheColumns
                    case 'Homologação'
                        s = class.Constants.configStyle3;
                    otherwise
                        s = class.Constants.configStyle4;
                end
                addStyle(app.search_Table, s, "cell", listOfCells)
            end
        end


        %-----------------------------------------------------------------%
        function status = search_WordCloud_CheckCache(app, selectedHom, relatedTable)
            status = false;

            wordCloudLogical = strcmp(relatedTable.("Atributo"), 'WordCloud');
            relatedTable     = relatedTable(wordCloudLogical, :);

            if isempty(relatedTable) || any(wordCloudLogical) && ~strcmp(app.search_WordCloudPanel.Tag, selectedHom)
                status = true;
            end
        end


        %-----------------------------------------------------------------%
        function status = search_WordCloud_PlotUpdate(app, selectedRow, showedHom, wourdCloudRefreshTag)
            status = true;

            % O wordcloud, do MATLAB, é lento, demandando uma tela de progresso
            % que bloqueia a interação com o app.
            if strcmp(app.General.search.wordCloud.algorithm, 'MATLAB built-in')
                app.progressDialog.Visible = 'visible';
            end

            if wourdCloudRefreshTag
                wordCloudIndex = [];
            else
                relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);
                wordCloudIndex = find(strcmp(relatedAnnotationTable.("Atributo"), 'WordCloud'), 1);
            end

            if ~isempty(wordCloudIndex)
                wordCloudAnnotation = relatedAnnotationTable.("Valor"){wordCloudIndex};
                wordCloudTable      = util.getWordCloudFromCache(wordCloudAnnotation);

            else
                app.progressDialog.Visible = 'visible';
                try
                    word2Search = search_WordCloud_Word2Search(app, showedHom);
                    nMaxWords   = 25;

                    [wordCloudTable, wordCloudInfo] = util.getWordCloudFromWeb(word2Search, nMaxWords);
                    if ~isempty(wordCloudTable)
                        search_Annotation_Add2Cache(app, selectedRow, showedHom, 'WordCloud', wordCloudInfo, wourdCloudRefreshTag)
                    end

                catch ME
                    app.progressDialog.Visible = 'hidden';
                    appUtil.modalWindow(app.UIFigure, 'warning', ME.identifier);

                    status = false;
                    return
                end
            end

            if ~isempty(wordCloudTable)
                app.wordCloudObj.Table        = wordCloudTable;
                app.search_WordCloudPanel.Tag = showedHom;
            end

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function word2Search = search_WordCloud_Word2Search(app, showedHom)
            selectedRow = find(strcmp(app.search_Table.Data.("Homologação"), showedHom), 1);
            listOfWords = {char(app.search_Table.Data.("Modelo")(selectedRow)), ...
                char(app.search_Table.Data.("Nome Comercial")(selectedRow))};

            switch app.General.search.wordCloud.column
                case 'Modelo';         idx1 = 1;
                case 'Nome Comercial'; idx1 = 2;
            end
            word2Search = listOfWords{idx1};

            if isempty(word2Search)
                idx2 = setdiff([1 2], idx1);
                word2Search = listOfWords{idx2};

                if isempty(word2Search)
                    error('Registro %s não possui cadastrado "Modelo" ou "Nome Comercial", inviabilizando consulta à internet.', showedHom)
                else
                    listOfColumns = {'Modelo', 'Nome Comercial'};
                    appUtil.modalWindow(app.UIFigure, 'warning', sprintf('O registro %s não possui cadastrado "%s". Dessa forma, consulta à internet foi realizada usando o seu "%s".', showedHom, listOfColumns{idx1}, listOfColumns{idx2}));
                end
            end
        end

        %-----------------------------------------------------------------%
        function report_ListOfProductsAdd(app, srcMode, listOfHom2Add)
            for ii = 1:numel(listOfHom2Add)
                selectedHom2Add = listOfHom2Add{ii};

                switch srcMode
                    case 'search'
                        if ismember(selectedHom2Add, app.projectData.listOfProducts.("Homologação"))
                            continue
                        end
                        newRow2Add = report_newRow2Add(app, selectedHom2Add);

                    otherwise % 'report - addRow'
                        newRow2Add = {'-1', '', '', '-1', '', '', 'Irregular', '-1', '-1', ''};
                end

                app.projectData.listOfProducts(end+1, [1:6, 16:19]) = newRow2Add;
                app.projectData.listOfProducts = sortrows(app.projectData.listOfProducts, 'Homologação');
            end

            % Atualizando a lista de produtos homologados sob análise (do
            % modo SEARCH).
            report_ListOfHomProductsUpdating(app)

            % Atualizando a tabela e o número de linhas (do modo REPORT), nessa
            % ordem. E depois forçando uma atualização dos paineis.
            report_UpdatingTable(app)
            report_TableSelectionChanged(app)

            % Torna visível imagem de warning, caso aberto projeto.
            report_ProjectWarnImageVisibility(app)
        end


        %-----------------------------------------------------------------%
        function report_ListOfHomProductsUpdating(app)
            homLogical = ~strcmp(app.projectData.listOfProducts.("Homologação"), '-1');
            app.search_ListOfProducts.Items = app.projectData.listOfProducts.("Homologação")(homLogical);
        end


        %-----------------------------------------------------------------%
        function [listOfRows, idx, analyzedColumns] = report_ListOfProductsCheck(app)
            % Condições para que o registro seja considerado incompleto...
            analyzedColumns = {'Tipo',             ...
                'Fabricante',       ...
                'Modelo',           ...
                'Valor Unit. (R$)', ...
                {'Qtd. uso/vendida', 'Qtd. estoque/aduana'}, ...
                {'Qtd. uso/vendida', 'Qtd. estoque/aduana', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}, ...
                {'Situação', 'Sanável?'}};

            idx      = zeros(height(app.projectData.listOfProducts), 7, 'logical');
            idx(:,1) = string(app.projectData.listOfProducts.Tipo)       == "-1";
            idx(:,2) = string(app.projectData.listOfProducts.Fabricante) == "";
            idx(:,3) = string(app.projectData.listOfProducts.Modelo)     == "";
            idx(:,4) = app.projectData.listOfProducts.("Valor Unit. (R$)") <= 0;
            idx(:,5) = app.projectData.listOfProducts.("Qtd. uso/vendida") + app.projectData.listOfProducts.("Qtd. estoque/aduana") <= 0;
            idx(:,6) = sum(app.projectData.listOfProducts{:, {'Qtd. uso/vendida', 'Qtd. estoque/aduana'}}, 2) < sum(app.projectData.listOfProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2);
            idx(:,7) = (string(app.projectData.listOfProducts.("Situação")) == "Regular") & (string(app.projectData.listOfProducts.("Sanável?")) == "Não");

            listOfRows = find(any(idx, 2));
        end


        %-----------------------------------------------------------------%
        function report_UpdatingTable(app)
            report_UpdatingTableData(app)

            % LAYOUT
            misc_Table_NumberOfRows(app, 'report')

            if ~isempty(app.projectData.listOfProducts)
                app.report_ShowCells2Edit.Enable = 1;

                style2Apply = report_Table_Style2Apply(app);
                report_Table_AddStyle(app, style2Apply)

            else
                removeStyle(app.report_Table)
                set(app.report_ShowCells2Edit, 'Enable', 0, 'Tag', 'off')
            end

            report_ModelNameValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function columnIndex = report_ColumnIndex(app)
            switch app.LISTADEPRODUTOSSOBANLISEButtonGroup.SelectedObject
                case app.FornecedorouusurioButton
                    columnIndex = [1, 4:15, 17];
                case app.AduanaButton
                    columnIndex = [1, 4:7, 10, 12, 2:3, 16, 18];
            end
        end

        %-----------------------------------------------------------------%
        function report_UpdatingTableData(app)
            columnIndex = report_ColumnIndex(app);
            app.report_Table.Data = app.projectData.listOfProducts(:, columnIndex);
        end

        %-----------------------------------------------------------------%
        function style2Apply = report_Table_Style2Apply(app)
            switch app.report_ShowCells2Edit.Tag
                case 'on'
                    style2Apply = 'Icon+BackgroundColor';
                case 'off'
                    style2Apply = 'Icon+TemporaryBackgroundColor';
            end
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle(app, styleType)
            [listOfRows, idx, analyzedColumns] = report_ListOfProductsCheck(app);

            switch styleType
                case 'Icon'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                    end

                case 'BackgroundColor'
                    % O evento aqui é iniciado apenas do botão na barra de tarefas...
                    report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, false)

                case 'Icon+BackgroundColor'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                        report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, false)
                    end

                case 'Icon+TemporaryBackgroundColor'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                        report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, true)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle_Icon(app, listOfRows)
            s = class.Constants.configStyle6;
            addStyle(app.report_Table, s, "cell", [listOfRows, ones(numel(listOfRows), 1)])
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, temporaryFlag)
            % Identifica o número de estilos aplicados à tabela...
            styleIndex = height(app.report_Table.StyleConfigurations);

            % Identifica as células...
            cellList = [];
            for ii = 1:numel(analyzedColumns)
                rowIndex = find(idx(:,ii));

                if ~isempty(rowIndex)
                    columnNames = analyzedColumns{ii};
                    columnIndex = find(ismember(app.report_Table.Data.Properties.VariableNames, columnNames));

                    for jj = 1:numel(columnIndex)
                        cellList = [cellList; [rowIndex, repmat(columnIndex(jj), numel(rowIndex), 1)]];
                    end
                end
            end

            % Aplica o estilo, o qual terá o index "styleIndex+1", e depois
            % de cerca de 300ms o estilo é excluído (caso temporaryFlag = true).
            s = class.Constants.configStyle7;
            addStyle(app.report_Table, s, "cell", cellList)

            if temporaryFlag
                drawnow
                pause(.3)

                % O bloco try/catch evita retorno de erro, caso o usuário
                % interaja com a tabela durante o pause de 300 ms.
                try
                    removeStyle(app.report_Table, styleIndex+1)
                catch
                end
            end
        end

        %-----------------------------------------------------------------%
        function newRow2Add = report_newRow2Add(app, selectedHom2Add)
            selectedHomRawTableIndex = find(strcmp(app.rawDataTable.("Homologação"), selectedHom2Add));
            relatedSCHTable = app.rawDataTable(selectedHomRawTableIndex, :);

            Importador    = '';
            CodAduaneiro  = '';
            typeValue     = '-1';
            typeList      = unique(cellstr(relatedSCHTable.("Tipo")));

            Fabricante    = upper(char(relatedSCHTable.("Fabricante")(1)));
            modelValue    = char(relatedSCHTable.("Modelo")(1));
            modelList     = unique([relatedSCHTable.("Modelo"); relatedSCHTable.("Nome Comercial")]);
            modelList(cellfun(@(x) isempty(x), modelList)) = [];

            Situacao      = 'Irregular';
            typeViolation = app.General.ui.typeOfViolation.default;
            Sanavel       = '-1';
            optionalNote  = sprintf('TIPO: %s\nMODELO: %s', ccTools.fcn.FormatString(typeList), ccTools.fcn.FormatString(modelList));

            newRow2Add    = {selectedHom2Add, Importador, CodAduaneiro, typeValue, Fabricante, modelValue, Situacao, typeViolation, Sanavel, optionalNote};
        end


        %-----------------------------------------------------------------%
        % MISCELÂNEAS
        %-----------------------------------------------------------------%

        %-----------------------------------------------------------------%
        % Aqui ficarão as funções relacionadas à GUI que são chamadas por
        % módulos diferentes do app.
        %
        % Por exemplo, as funções relacionadas às tabelas dos modos SEARCH
        % e REPORT. São operações logicalmente idênticas, mas com componentes
        % diferentess.
        %
        % Em relação à nomenclatura de linha(s) selecionada(s) em uma das
        % tabelas, tem-se:
        % - selectedHom.......: Lista de homologações selecionados (cell array).
        % - showedHom.........: Homologação apresentada em painel de metadados.
        % - selected2showedHom: Em processo de atualização do painel de metadados.
        %                       De selectedHom{1} para showedHom...
        %-----------------------------------------------------------------%
        function [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, operationMode)
            switch operationMode
                case 'search'
                    table2Search = app.search_Table;
                    panel2Search = app.search_ProductInfo;
                case 'report'
                    table2Search = app.report_Table;
                    panel2Search = app.report_ProductInfo;
            end

            selectedRow = table2Search.Selection;
            if ~isempty(selectedRow)
                selectedHom = unique(table2Search.Data.("Homologação")(selectedRow), 'stable');
            else
                selectedHom = {};
            end
            showedHom = panel2Search.UserData.showedHom;
        end


        %-----------------------------------------------------------------%
        function misc_Table_NumberOfRows(app, operationMode)
            switch operationMode
                case 'search'
                    nHom  = numel(unique(app.search_Table.Data.("Homologação")));
                    nRows = height(app.search_Table.Data);
                    app.search_nRows.Text = sprintf('%d <font style="font-size: 9px; margin-right: 2px;">HOMOLOGAÇÕES</font>\n%d <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>', nHom, nRows);

                case 'report'
                    nRows = height(app.report_Table.Data);
                    app.report_nRows.Text = sprintf('%d <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>', nRows);
            end
        end


        %-----------------------------------------------------------------%
        function htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable)
            if isempty(selected2showedHom)
                htmlSource = '';

            else
                if ~strcmp(selected2showedHom, '-1')
                    selectedHomRawTableIndex = find(strcmp(app.rawDataTable.("Homologação"), selected2showedHom));
                    htmlSource = util.HtmlTextGenerator.RowTableInfo('ProdutoHomologado', app.rawDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable);

                else
                    % Esse é um caso específico do modo "REPORT", quando é
                    % selecionado registro de um produto não homologado,
                    % cuja homologação é preenchido como -1. Nesse caso,
                    % deve-se identificar a linha selecionada da tabela (do
                    % modo "REPORT) pois podem existir mais de um registro
                    % com o número igual a -1.
                    %
                    % O bloco try/catch é apenas por precaução. Não foi
                    % evidenciado erro nos testes de uso do app.

                    try
                        selectedRow = app.report_Table.Selection(1);
                        htmlSource = util.HtmlTextGenerator.RowTableInfo('ProdutoNãoHomologado', app.projectData.listOfProducts(selectedRow, :));
                    catch
                        htmlSource = '';
                    end
                end
            end
        end


        %-----------------------------------------------------------------%
        function misc_SelectedHomPanel_InfoUpdate(app, operationMode, htmlSource, selectedRow, selected2showedHom)
            userData = struct('selectedRow', selectedRow, 'showedHom', selected2showedHom);
            switch operationMode
                case 'search'
                    ui.TextView.update(app.search_ProductInfo, htmlSource, userData, app.search_ProductInfoImage);
                case 'report'
                    ui.TextView.update(app.report_ProductInfo, htmlSource, userData, app.report_ProductInfoImage);
            end
        end


        %-----------------------------------------------------------------%
        function layout_CNPJOrCPF(app, status)
            if status
                backgroundColor = [1,1,1];
                fontColor       = [0,0,0];
            else
                backgroundColor = [1,0,0];
                fontColor       = [1,1,1];
            end
            set(app.report_EntityID, 'BackgroundColor', backgroundColor, 'FontColor', fontColor)
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            try
                % WARNING MESSAGES
                appUtil.disablingWarningMessages()

                % <GUI>
                app.UIFigure.Position(4) = 660;
                app.popupContainerGrid.Layout.Row = [1,2];
                app.GridLayout.RowHeight = {44, '1x'};

                app.Tab1_SearchGrid.ColumnWidth(1:2) = {0,5};
                app.Tab2_ReportGrid.ColumnWidth(4:5) = {5,0};
                % </GUI>

                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            % Especificidade "winSCH":
            try
                writeFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            % Aspectos gerais (carregar em todos os apps):
            appUtil.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)

        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)

            % O listener que captura cliques do mouse só é aplicável no
            % modo SEARCH.
            if app.TabGroup.SelectedTab ~= app.TabGroup.Children(1)
                return
            end

            hitObject = struct(event).HitObject;
            switch hitObject
                case app.search_entryPoint
                    if ~isempty(app.search_entryPoint.Value)
                        if strcmp(app.General.search.mode, 'tokens')
                            if numel(app.search_entryPoint.Value) >= app.General.search.minCharacters
                                app.search_Suggestions.Visible = 1;
                            end
                        end
                    end

                case app.search_Suggestions
                    if isempty(app.search_Suggestions.Value)
                        waitfor(app.search_Suggestions, 'Value')
                    end

                    ipcMainJSEventsHandler(app, struct('HTMLEventName', 'app.search_Suggestions', 'HTMLEventData', 'Enter'))

                otherwise
                    set(app.search_Suggestions, Visible=0, Value={})
                    if isempty(app.search_entryPoint.Value)
                        search_EntryPoint_InitialValue(app)
                    end
            end

        end

        % Value changed function: menu_Button1, menu_Button2, menu_Button3
        function menu_mainButtonPushed(app, event)

            clickedButton  = event.Source;
            auxAppName     = clickedButton.Tag;
            inputArguments = auxAppInputArguments(app, auxAppName);
            openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, inputArguments{:})

            if ~app.TabGroup.Visible
                app.TabGroup.Visible = 1;
            end

        end

        % Image clicked function: AppInfo, FigurePosition
        function menu_auxiliarButtonPushed(app, event)

            switch event.Source
                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appUtil.winPosition(app.UIFigure)

                case app.AppInfo
                    if isempty(app.AppInfo.Tag)
                        app.progressDialog.Visible = 'visible';
                        app.AppInfo.Tag = util.HtmlTextGenerator.AppInfo(app.General, app.rootFolder, app.executionMode, app.rawDataTable, app.releasedData, app.cacheData, app.annotationTable, 'popup');
                        app.progressDialog.Visible = 'hidden';
                    end

                    msgInfo = app.AppInfo.Tag;
                    appUtil.modalWindow(app.UIFigure, 'info', msgInfo);
            end

        end

        % Value changing function: search_entryPoint
        function search_EntryPoint_ValueChanging(app, event)

            search_SuggestionAlgorithm(app, event.Value, true)

        end

        % Image clicked function: search_entryPointImage
        function search_EntryPoint_ImageClicked(app, event)

            value2Search = textAnalysis.preProcessedData(app.search_entryPoint.Value);

            switch app.General.search.mode
                case 'tokens'
                    words2Search = app.search_Suggestions.Items;
                    if ~isempty(words2Search)
                        search_Filtering_primaryFilter(app, words2Search)
                        app.search_entryPointImage.UserData = struct('value2Search', value2Search, 'words2Search', {words2Search});
                        search_FilterSpecification(app)
                    end

                otherwise
                    words2Search = textAnalysis.preProcessedData(strsplit(app.search_entryPoint.Value, ','));
                    if ~isempty(words2Search)
                        search_Filtering_primaryFilter(app, words2Search)
                        app.search_entryPointImage.UserData = struct('value2Search', value2Search, 'words2Search', {words2Search});
                        search_FilterSpecification(app)
                    end
            end

        end

        % Selection changed function: search_Table
        function search_Table_SelectionChanged(app, event)

            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'search');

            if ~isempty(selectedHom)
                if ~ismember(showedHom, selectedHom)
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, selectedRow(1), selected2showedHom)

                    % Apresenta a nuvem de palavras apenas se visível...
                    if app.search_ToolbarWordCloud.UserData.Value
                        if search_WordCloud_CheckCache(app, selected2showedHom, relatedAnnotationTable)
                            status = search_WordCloud_PlotUpdate(app, selectedRow(1), selected2showedHom, false);
                            if ~status
                                if ~isempty(app.wordCloudObj.Table)
                                    app.wordCloudObj.Table = [];
                                end
                            end
                        end

                    else
                        if ~isempty(app.wordCloudObj.Table)
                            app.wordCloudObj.Table = [];
                        end
                    end

                    app.search_ToolbarAnnotation.Enable     = 1;
                    app.search_ToolbarListOfProducts.Enable = 1;
                    app.search_ToolbarWordCloud.Enable      = 1;
                end

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, [], '')

                if ~isempty(app.wordCloudObj) && ~isempty(app.search_WordCloudPanel.Tag)
                    app.wordCloudObj.Table        = [];
                    app.search_WordCloudPanel.Tag = '';
                end

                app.search_ToolbarAnnotation.Enable     = 0;
                app.search_ToolbarWordCloud.Enable      = 0;
                app.search_ToolbarListOfProducts.Enable = 0;
            end

        end

        % Image clicked function: search_ToolbarAnnotation, 
        % ...and 2 other components
        function search_Panel_ToolbarButtonClicked(app, event)

            switch event.Source
                case app.search_ToolbarAnnotation
                    if app.search_Tab1Grid.RowHeight{5}
                        app.search_ToolbarAnnotation.ImageSource = app.search_ToolbarAnnotation.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(5)         = {0};

                        if ~app.search_Tab1Grid.RowHeight{6}
                            app.search_Tab1Grid.RowHeight(4)     = {0};
                        end

                    else
                        app.search_ToolbarAnnotation.ImageSource = app.search_ToolbarAnnotation.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight(4:5)       = {22,148};
                    end

                case app.search_ToolbarWordCloud
                    app.search_ToolbarWordCloud.UserData.Value = ~app.search_ToolbarWordCloud.UserData.Value;

                    if app.search_ToolbarWordCloud.UserData.Value
                        % O "drawnow nocallbacks" aqui é ESSENCIAL porque o
                        % MATLAB precisa renderizar em tela o container do
                        % WordCloud (um objeto uihtml).
                        app.search_ToolbarWordCloud.ImageSource = app.search_ToolbarWordCloud.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight([4,6,7])  = {22,121,22};
                        app.search_WordCloudRefresh.Visible     = 1;
                        drawnow

                        selectedRow = app.search_ProductInfo.UserData.selectedRow;
                        showedHom   = app.search_ProductInfo.UserData.showedHom;
                        relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);

                        if search_WordCloud_CheckCache(app, showedHom, relatedAnnotationTable)
                            search_WordCloud_PlotUpdate(app, selectedRow, showedHom, false);
                        end

                    else
                        app.search_ToolbarWordCloud.ImageSource = app.search_ToolbarWordCloud.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(6:7)      = {0,0};
                        app.search_WordCloudRefresh.Visible     = 0;

                        if ~app.search_Tab1Grid.RowHeight{5}
                            app.search_Tab1Grid.RowHeight(4)    = {0};
                        end
                    end

                case app.search_ToolbarListOfProducts
                    if app.search_Tab1Grid.RowHeight{9}
                        app.search_ToolbarListOfProducts.ImageSource = app.search_ToolbarListOfProducts.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(8:9)           = {0,0};

                    else
                        app.search_ToolbarListOfProducts.ImageSource = app.search_ToolbarListOfProducts.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight(8:9)           = {22,148};
                    end
            end

        end

        % Image clicked function: search_AnnotationPanelAdd
        function search_Annotation_AddImageClicked(app, event)

            app.search_AnnotationValue.Value = textFormatGUI.cellstr2TextField(app.search_AnnotationValue.Value);

            selectedRow    = app.search_ProductInfo.UserData.selectedRow;
            showedHom      = app.search_ProductInfo.UserData.showedHom;

            attributeName  = app.search_AnnotationAttribute.Value;
            attributeValue = char(app.search_AnnotationValue.Value);

            if ~isempty(attributeValue)
                search_Annotation_Add2Cache(app, selectedRow, showedHom, attributeName, attributeValue, false)
            end

        end

        % Image clicked function: search_WordCloudRefresh
        function search_WordCloud_RefreshImageClicked(app, event)

            % Primeiro tenta atualizar a nuvem de palavras...
            selectedRow = app.search_ProductInfo.UserData.selectedRow;
            showedHom   = app.search_ProductInfo.UserData.showedHom;
            search_WordCloud_PlotUpdate(app, selectedRow, showedHom, true);

        end

        % Image clicked function: search_ListOfProductsAdd
        function search_Report_ListOfProductsAddImageClicked(app, event)

            [selectedHom, showedHom] = misc_Table_SelectedRow(app, 'search');

            if isempty(selectedHom)
                msgWarning = 'Selecione ao menos um registro na tabela.';
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return

            else
                if ~isequal(selectedHom, {showedHom})
                    msgQuestion = sprintf(['<p style="font-size: 12px; text-align: justify;">Homologação apresentada no <b>PAINEL</b> à esquerda:\n• %s\n\n' ...
                        'Homologações selecionadas em <b>TABELA</b>:\n%s\n\n'                                          ...
                        'Quais os registros devem ser adicionados à lista de produtos sob análise?</p>'], showedHom, strjoin("• " + string(selectedHom), '\n'));

                    selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',                           ...
                        'Options', {' Painel ', ' Tabela ', 'Cancelar'}, ...
                        'DefaultOption', 1, 'CancelOption', 3, 'Icon', 'question');

                    switch selection
                        case ' Painel '
                            listOfHom2Add = {showedHom};
                        case ' Tabela '
                            listOfHom2Add = selectedHom;
                        otherwise % 'Cancelar'
                            return
                    end

                else
                    listOfHom2Add = selectedHom;
                end

                % Certificando que não será incluído um registro que já
                % consta em base...
                listOfHom2Add = setdiff(listOfHom2Add, app.projectData.listOfProducts.("Homologação"));
                report_ListOfProductsAdd(app, 'search', listOfHom2Add)
            end

        end

        % Image clicked function: report_ReportGeneration
        function report_ReportGenerationImageClicked(app, event)

            % VALIDAÇÕES
            if isempty(app.projectData.listOfProducts)
                appUtil.modalWindow(app.UIFigure, 'warning', 'A lista de produtos sob análise está vazia!');
                return
            end

            msgWarning = {};
            if ~report_checkEFiscalizaIssueId(app)
                msgWarning{end+1} = sprintf('• O número da inspeção "%.0f" é inválido.', app.report_Issue.Value);
            end

            switch app.report_EntityType.Value
                case ''
                    msgWarning{end+1} = '• Qualificação da fiscalizada ainda pendente.';
                case {'Fornecedor', 'Usuário'}
                    nEntity = strtrim(app.report_Entity.Value);
                    try
                        CNPJOrCPF = checkCNPJOrCPF(app.report_EntityID.Value, 'NumberValidation');
                    catch
                        CNPJOrCPF = [];
                    end

                    if isempty(nEntity) || isempty(CNPJOrCPF)
                        msgWarning{end+1} = '• Qualificação da fiscalizada ainda pendente.';
                    end
            end

            listOfRows = report_ListOfProductsCheck(app);
            if ~isempty(listOfRows)
                msgWarning{end+1} = sprintf('• Os registros da(s) linha(s) %s estão incompletos.', strjoin(string(listOfRows), ', '));
            end

            if ~isempty(msgWarning)
                msgInfo     = ['____________<br>VALIDAÇÕES<br>(a) Em relação à <b>INSPEÇÃO</b>:<br>'  ...
                    '• O número deve ser válido (inteiro, positivo e finito).<br>' ...
                    '(b) Em relação à qualificação da <b>FISCALIZADA</b>:<br>'  ...
                    '• O nome deve ser preenchido;<br>' ...
                    '• O número do CPF/CNPJ deve ser válido; e<br>' ...
                    '• O tipo não pode ser vazio.<br>' ...
                    '(c) Em relação à <b>TABELA</b> com a lista de produtos sob análise:<br>'  ...
                    '• O "Tipo" não pode ter valor igual a -1;<br>' ...
                    '• O "Fabricante" e o "Modelo" não podem ter valores vazios;<br>' ...
                    '• O "Valor Unit. (R$)" não pode ser igual a zero;<br>' ...
                    '• A soma de "Qtd. uso/vendida" e "Qtd. estoque/aduana" não pode ser igual a zero;<br>' ...
                    '• A soma de "Qtd. uso/vendida" e "Qtd. estoque/aduana" não pode ser menor do que a soma de "Qtd. lacradas", "Qtd. apreendidas", Qtd. retidas (RFB)".' ...
                    '• A "Situação", quando Regular, não pode ter "Sanável?" igual a Não.'];

                switch app.report_Version.Value
                    case 'Definitiva'
                        msgInfo     = sprintf(['<p style="font-size: 12px; text-align: justify;">Foi(ram) identificado(s) a(s) pendência(s):\n%s\n\n' ...
                            '<b>Essas pendências precisam ser resolvidas antes de ser gerada a versão "Definitiva" do relatório.</b><br><br><font style="color: gray; font-size: 11px;">%s</font></p>'], strjoin(msgWarning, '<br>'), msgInfo);
                        appUtil.modalWindow(app.UIFigure, 'warning', msgInfo);
                        return


                    case 'Preliminar'
                        msgQuestion = sprintf(['<p style="font-size: 12px; text-align: justify;">Foi(ram) identificado(s) a(s) pendência(s):\n%s\n\n' ...
                            '<b>Continuar mesmo assim?</b><br><br><font style="color: gray; font-size: 11px;">%s</font></p>'], strjoin(msgWarning, '<br>'), msgInfo);
                        selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',     ...
                            'Options', {'Sim', 'Não'}, ...
                            'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');

                        if strcmp(selection, 'Não')
                            return
                        end
                end
            end

            app.progressDialog.Visible = 'visible';
            try
                [HTMLDocFullPath, CSVDocFullPath] = reportLibConnection.Controller.Run(app, true);

                switch app.report_Version.Value
                    case 'Definitiva'
                        app.projectData.generatedFiles.lastHTMLDocFullPath = HTMLDocFullPath;
                        app.projectData.generatedFiles.lastTableFullPath   = CSVDocFullPath;

                    case 'Preliminar'
                        app.projectData.generatedFiles = [];
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'warning', getReport(ME));
            end
            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: report_ShowCells2Edit
        function report_ShowCells2EditClicked(app, event)

            if ~isempty(app.projectData.listOfProducts)
                listOfRows = report_ListOfProductsCheck(app);
                if isempty(listOfRows)
                    appUtil.modalWindow(app.UIFigure, 'warning', 'Não foi identificada pendência na lista de produtos sob análise.');
                    return
                end

                switch app.report_ShowCells2Edit.Tag
                    case 'on'
                        app.report_ShowCells2Edit.Tag = 'off';
                        report_Table_AddStyle(app, 'Icon')

                    case 'off'
                        app.report_ShowCells2Edit.Tag = 'on';
                        report_Table_AddStyle(app, 'BackgroundColor')
                end

            else
                % Não evidenciei essa condição... mas, por precaução,
                % inserido esse estado p/ evitar cliques desnecessários.
                app.report_ShowCells2Edit.Enable = 0;
            end

        end

        % Selection changed function: report_Table
        function report_TableSelectionChanged(app, event)

            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'report');

            if ~isempty(selectedHom)
                updateFlag = false;
                if ~ismember(showedHom, selectedHom) || ~isequal(selectedRow, app.report_ProductInfo.UserData.selectedRow)
                    updateFlag = true;
                end

                if updateFlag
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, selectedRow(1), selected2showedHom)
                end

                app.report_EditProduct.Enable    = 1;
                app.report_ContextMenu_EditFcn.Enable   = 1;
                app.report_ContextMenu_DeleteFcn.Enable = 1;

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, [], '')

                app.report_EditProduct.Enable    = 0;
                app.report_ContextMenu_EditFcn.Enable   = 0;
                app.report_ContextMenu_DeleteFcn.Enable = 0;
            end

        end

        % Cell edit callback: report_Table
        function report_TableCellEdit(app, event)

            % BUG "MATLAB R2024a Update 7":
            % Ao clicar no dropdown (colunas categóricas) e clicar fora do
            % painel (do dropdown) ou selecionar o valor já selecionado, o
            % MATLAB dispara esse callback. A primeira validação evita fazer
            % atualizações desnessárias.
            if isequal(event.PreviousData, event.NewData)
                return

            elseif isnumeric(event.NewData) && ((event.NewData < 0) || isnan(event.NewData))
                event.Source.Data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                return

                % Outro comportamento inesperado é a possibilidade de editar as
                % categorias das colunas categóricas. Para evitar isso, afere-se
                % se o nome valor é membro da lista de valores esperados.
            else
                editedGUIColumn = event.Source.ColumnName{event.Indices(2)};

                if (strcmpi(editedGUIColumn, 'TIPO')     && ~ismember(event.NewData, app.General.ui.typeOfProduct.options))   || ...
                   (strcmpi(editedGUIColumn, 'SITUAÇÃO') && ~ismember(event.NewData, {'Irregular', 'Regular'}))               || ...
                   (strcmpi(editedGUIColumn, 'INFRAÇÃO') && ~ismember(event.NewData, app.General.ui.typeOfViolation.options)) || ...
                   (strcmpi(editedGUIColumn, 'SANÁVEL?') && ~ismember(event.NewData, {'-1', 'Sim', 'Não'}))

                    columnNames      = app.projectData.listOfProducts.Properties.VariableNames;
                    editedRealColumn = columnNames{find(strcmpi(editedGUIColumn, columnNames), 1)};

                    app.report_Table.Data.(editedRealColumn) = app.projectData.listOfProducts.(editedRealColumn);
                    return
                end
            end

            % Grosseria! :)
            columnIndex = report_ColumnIndex(app);
            app.projectData.listOfProducts(:, columnIndex) = app.report_Table.Data;

            style2Apply = report_Table_Style2Apply(app);
            report_Table_AddStyle(app, style2Apply)

            report_ProjectWarnImageVisibility(app)

            % Atualizando o painel de metadados do registro selecionado...
            % (só pode ser editada uma célular por vez)
            [~, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'report');
            if strcmp(showedHom, '-1')
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, []);
                misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, selectedRow, showedHom)
            end

        end

        % Value changed function: report_ModelName
        function report_ModelNameValueChanged(app, event)

            if ~isempty(app.projectData.listOfProducts) && ~isempty(app.report_ModelName.Value)
                app.report_ReportGeneration.Enable = 1;
            else
                app.report_ReportGeneration.Enable = 0;
            end

        end

        % Image clicked function: report_ProjectNew, report_ProjectOpen, 
        % ...and 1 other component
        function report_ProjectToolbarImageClicked(app, event)

            switch event.Source
                case app.report_ProjectNew
                    if isempty(app.projectData.listOfProducts)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de produtos a analisar não está vazia.');
                        return
                    end

                    msgQuestion = '<p style="font-size:12px; text-align:justify;">Deseja excluir a lista de produtos sob análise, iniciando um novo projeto?</p>';
                    selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',               ...
                        'Options', {'   OK   ', 'Cancelar'}, ...
                        'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
                    if strcmp(selection, 'Cancelar')
                        return
                    end

                    app.search_ListOfProducts.Items     = {};
                    app.projectData.listOfProducts(:,:) = [];

                    report_UpdatingTable(app)
                    report_TableSelectionChanged(app)

                    app.report_ProjectName.Value = '';
                    app.report_Issue.Value       = -1;
                    app.report_Entity.Value      = '';
                    app.report_EntityID.Value    = '';
                    app.report_EntityType.Value  = '';
                    report_EntityTypeValueChanged(app)

                    app.report_ProjectWarnIcon.Visible = 0;

                    %---------------------------------------------------------%
                case app.report_ProjectOpen
                    if ~isempty(app.projectData.listOfProducts)
                        msgQuestion = '<p style="font-size:12px; text-align:justify;">Ao abrir um projeto, a lista de produtos sob análise será sobrescrita. Confirma a operação?</p>';
                        selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',               ...
                            'Options', {'   OK   ', 'Cancelar'}, ...
                            'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
                        if strcmp(selection, 'Cancelar')
                            return
                        end
                    end

                    [fileName, filePath] = uigetfile({'*.mat', 'SCH (*.mat)'}, '', app.General.fileFolder.lastVisited);
                    figure(app.UIFigure)

                    if fileName
                        fileFullPath = fullfile(filePath, fileName);

                        try
                            [~, ~, variables, ~]         = readFile.MAT(fileFullPath);
                            app.projectData.listOfProducts           = variables.listOfProducts;

                            % Atualizando os componentes da GUI...
                            app.report_ProjectName.Value = fileFullPath;
                            app.report_Issue.Value       = variables.projectIssue;
                            app.report_Entity.Value      = variables.entityName;
                            app.report_EntityID.Value    = variables.entityID;
                            app.report_EntityType.Value  = variables.entityType;
                            report_EntityTypeValueChanged(app)

                            report_UpdatingTable(app)
                            report_TableSelectionChanged(app)

                            report_ListOfHomProductsUpdating(app)
                            app.report_ProjectWarnIcon.Visible = 0;

                            app.General.fileFolder.lastVisited = filePath;
                            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General, app.executionMode)

                        catch ME
                            appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                        end
                    end

                    %---------------------------------------------------------%
                case app.report_ProjectSave
                    if isempty(app.projectData.listOfProducts)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de produtos a analisar não está vazia.');
                        return
                    end

                    if ~isempty(app.report_ProjectName.Value{1})
                        defaultFilename = app.report_ProjectName.Value{1};
                    else
                        defaultFilename = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'SCH', app.report_Issue.Value);
                    end

                    [fileName, filePath] = uiputfile({'*.mat', 'SCH (*.mat)'}, '', defaultFilename);
                    figure(app.UIFigure)

                    if fileName
                        variables = struct('listOfProducts', app.projectData.listOfProducts,           ...
                            'projectName',    fullfile(filePath, fileName), ...
                            'projectIssue',   app.report_Issue.Value,       ...
                            'entityName',     app.report_Entity.Value,      ...
                            'entityID',       app.report_EntityID.Value,    ...
                            'entityType',     app.report_EntityType.Value);
                        userData  = [];

                        msgError  = writeFile.MAT(fullfile(filePath, fileName), 'ProjectData', 'SCH', variables, userData);
                        if ~isempty(msgError)
                            appUtil.modalWindow(app.UIFigure, 'error', msgError);
                            return
                        end

                        app.report_ProjectName.Value = fullfile(filePath, fileName);
                        app.report_ProjectWarnIcon.Visible = 0;
                    end
            end

        end

        % Value changed function: report_Entity, report_Issue
        function report_ProjectWarnImageVisibility(app, event)

            if ~isempty(app.report_ProjectName.Value{1})
                app.report_ProjectWarnIcon.Visible = 1;
            end

        end

        % Image clicked function: report_EntityCheck
        function report_EntityIDCheck(app, event)

            entityID = regexprep(app.report_EntityID.Value, '\D', '');
            if isempty(entityID)
                appUtil.modalWindow(app.UIFigure, 'info', 'Consulta limitada a valores não nulos de CNPJ ou CPF');
                return
            end

            try
                % Pesquisa restrita ao CNPJ.
                CNPJInfo = checkCNPJOrCPF(app.report_EntityID.Value, 'PublicAPI');
                appUtil.modalWindow(app.UIFigure, 'info', jsonencode(CNPJInfo, "PrettyPrint", true));

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end

        end

        % Image clicked function: report_FiscalizaUpdate
        function report_FiscalizaCallbacks(app, event)

            % <VALIDATION>
            msg = '';
            if ~report_checkEFiscalizaIssueId(app)
                msg = sprintf('O número da inspeção "%.0f" é inválido.', app.report_Issue.Value);
            elseif isempty(app.projectData.generatedFiles) || isempty(app.projectData.generatedFiles.lastHTMLDocFullPath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(app.projectData.generatedFiles.lastHTMLDocFullPath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', app.projectData.generatedFiles.lastHTMLDocFullPath);
            elseif ~isfolder(app.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            end

            if ~isempty(msg)
                appUtil.modalWindow(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDATION>

            % <PROCESS>
            if isempty(app.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'eFiscalizaSignInPage', 'Fields', dialogBox))
            else
                report_uploadInfoController(app, [], 'uploadDocument')
            end
            % </PROCESS>

        end

        % Image clicked function: report_menuBtn2Icon
        function report_menuBtn2IconImageClicked(app, event)

            switch event.Source
                case app.report_menuBtn2Icon
                    app.GridLayout6.RowHeight([2,4]) = {'1x', 0};

                case app.report_menuBtn3Icon
                    if ~report_checkEFiscalizaIssueId(app)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Pendente inserir o número da Inspeção.');
                        return
                    end

                    report_FiscalizaStartup(app)
            end

        end

        % Image clicked function: report_leftPanelVisibility, 
        % ...and 2 other components
        function misc_Panel_VisibilityImageClicked(app, event)

            switch event.Source
                case app.search_leftPanelVisibility
                    if app.Tab1_SearchGrid.ColumnWidth{1}
                        app.search_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.Tab1_SearchGrid.ColumnWidth(1:2)    = {0,5};
                    else
                        app.search_leftPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.Tab1_SearchGrid.ColumnWidth(1:2)    = {325,10};
                    end

                case app.report_leftPanelVisibility
                    if app.Tab2_ReportGrid.ColumnWidth{1}
                        app.report_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.Tab2_ReportGrid.ColumnWidth(1:2)    = {0,5};
                    else
                        app.report_leftPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.Tab2_ReportGrid.ColumnWidth(1:2)    = {325,10};
                    end

                case app.report_rightPanelVisibility
                    if app.Tab2_ReportGrid.ColumnWidth{end}
                        app.report_rightPanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.Tab2_ReportGrid.ColumnWidth(4:5)    = {5,0};
                    else
                        app.report_rightPanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.Tab2_ReportGrid.ColumnWidth(4:5)    = {10,325};
                    end
            end

        end

        % Menu selected function: report_ContextMenu_DeleteFcn, 
        % ...and 1 other component
        function report_ContextMenu_DeleteFcnSelected(app, event)

            selectedTableIndex = [];
            selectedProduct    = {};

            switch event.ContextObject
                % Relacionado à exclusão de registros de produtos homologados
                % a analisar.
                case app.search_ListOfProducts
                    selectedProduct = app.search_ListOfProducts.Value;

                    if ~isempty(selectedProduct)
                        selectedTableIndex = find(ismember(app.report_Table.Data.("Homologação"), selectedProduct));
                    end

                case app.report_Table
                    selectedTableIndex = app.report_Table.Selection;

                    if ~isempty(selectedTableIndex)
                        idx = selectedTableIndex(~strcmp(app.report_Table.Data.("Homologação")(selectedTableIndex), '-1'));
                        selectedProduct = app.report_Table.Data.("Homologação")(idx);
                    end
            end

            if ~isempty(selectedTableIndex)
                app.projectData.listOfProducts(selectedTableIndex,:) = [];
                report_UpdatingTable(app)
                report_ProjectWarnImageVisibility(app)
            end

            if ~isempty(selectedProduct)
                app.search_ListOfProducts.Items = setdiff(app.search_ListOfProducts.Items, selectedProduct);
            end

            report_TableSelectionChanged(app)

        end

        % Image clicked function: search_ExportTable
        function search_ExportTableClicked(app, event)

            nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
            defaultName   = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
            fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                idxSCH = app.search_Table.UserData.secundaryIndex;
                writetable(app.rawDataTable(idxSCH, 1:19), fileFullPath, 'WriteMode', 'overwritesheet')
            catch ME
                appUtil.modalWindow(app.UIFigure, 'warning', getReport(ME));
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Selection changed function: LISTADEPRODUTOSSOBANLISEButtonGroup
        function LISTADEPRODUTOSSOBANLISEButtonGroupSelectionChanged(app, event)

            report_UpdatingTableData(app)

            switch app.LISTADEPRODUTOSSOBANLISEButtonGroup.SelectedObject
                case app.FornecedorouusurioButton
                    app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'QTD.|USO/VENDIDA'; 'QTD.|ESTOQUE'; 'QTD.|LACRADAS'; 'QTD.|APREENDIDAS'; 'QTD.|RETIDAS (RFB)'; 'INFRAÇÃO'};
                    app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 58, 96, 90, 90, 90, 90, 90, 90, 'auto'};

                case app.AduanaButton
                    app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'VALOR|UNITÁRIO (R$)'; 'QTD.|ADUANA'; 'IMPORTADOR'; 'CÓDIGO|ADUANEIRO'; 'SITUAÇÃO'; 'SANÁVEL?'};
                    app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 90, 90, 'auto', 'auto', 'auto', 70};
            end

            if strcmp(app.report_ShowCells2Edit.Tag, 'on')
                report_Table_AddStyle(app, 'Icon+BackgroundColor')
            end

        end

        % Callback function: report_ContextMenu_EditFcn,
        % report_EditProduct, 
        % ...and 1 other component
        function search_FilterSetupClicked(app, event)

            switch event.Source
                case app.search_FilterSetup
                    menu_LayoutPopupApp(app, 'FilterSetup')

                case {app.report_EditProduct, app.report_ContextMenu_EditFcn}
                    % Por alguma razão desconhecida, inseri algumas validações
                    % aqui! :)
                    % Enfim... a possibilidade de editar um registro não deve
                    % existir toda vez que a tabela esteja vazia ou que não
                    % esteja selecionada uma linha.
                    selectedRow = app.report_Table.Selection;

                    if isempty(selectedRow)
                        if isempty(app.report_Table.Data)
                            app.report_EditProduct.Enable  = 0;
                            app.report_ContextMenu_EditFcn.Enable = 0;
                            return
                        end

                        app.report_Table.Selection = 1;
                        report_TableSelectionChanged(app)
                    elseif ~isscalar(selectedRow)
                        app.report_Table.Selection = app.report_Table.Selection(1);
                    end

                    menu_LayoutPopupApp(app, 'ProductInfo')
            end

        end

        % Button pushed function: search_OrientationEntity, 
        % ...and 2 other components
        function search_OrientationHomologationButtonPushed(app, event)

            clickedButton = event.Source;
            if clickedButton.UserData
                return
            end

            allButtons = [app.search_OrientationHomologation, ...
                app.search_OrientationEntity,       ...
                app.search_OrientationProduct];

            app.General.search.cacheColumns = clickedButton.Tag;

            set(clickedButton,                      BackgroundColor = [.24 .47 .85], FontColor = [1 1 1],    UserData = true)
            set(setdiff(allButtons, clickedButton), BackgroundColor = [.94 .94 .94], FontColor = [.5 .5 .5], UserData = false)

            app.previousSearch = '';
            search_EntryPoint_InitialValue(app)
            search_SuggestionPanel_InitialValues(app)

        end

        % Image clicked function: Image5
        function Image5Clicked(app, event)

            report_ListOfProductsAdd(app, 'report', {'-1'})

        end

        % Value changed function: report_EntityType
        function report_EntityTypeValueChanged(app, event)

            switch app.report_EntityType.Value
                case {'Fornecedor', 'Usuário'}
                    app.report_Entity.Enable      = 1;
                    app.report_EntityID.Enable    = 1;
                    app.report_EntityCheck.Enable = 1;

                otherwise
                    app.report_Entity.Enable      = 0;
                    app.report_EntityID.Enable    = 0;
                    app.report_EntityCheck.Enable = 0;
            end

            report_ProjectWarnImageVisibility(app)

        end

        % Value changed function: search_ListOfProducts
        function search_ListOfProductsValueChanged(app, event)

            selectedElements = app.search_ListOfProducts.Value;
            app.search_ContextMenu_DeleteFcn.Enable = ~isempty(selectedElements);

        end

        % Value changed function: report_EntityID
        function report_EntityIDValueChanged(app, event)

            try
                CNPJOrCPF = checkCNPJOrCPF(app.report_EntityID.Value, 'NumberValidation');
                set(app.report_EntityID, 'Value', CNPJOrCPF, 'UserData', CNPJOrCPF)
                layout_CNPJOrCPF(app, true)

            catch ME
                app.report_EntityID.UserData = [];
                layout_CNPJOrCPF(app, false)

            end

            report_ProjectWarnImageVisibility(app)

        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function menu_DockButtonPushed(app, event)
            
            clickedButton = findobj(app.menu_Grid, 'Type', 'uistatebutton', 'Value', true);
            auxAppTag     = clickedButton.Tag;

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.General;
                    appGeneral.operationMode.Dock = false;

                    inputArguments = auxAppInputArguments(app, auxAppTag);
                    closeModule(app.tabGroupController, auxAppTag, app.General)
                    openModule(app.tabGroupController, clickedButton, false, appGeneral, inputArguments{:})

                case app.dockModule_Close
                    closeModule(app.tabGroupController, auxAppTag, app.General)
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [93 93 1244 660];
            app.UIFigure.Name = 'SCH';
            app.UIFigure.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'icon_32.png');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {44, '1x', 44};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1_Search
            app.Tab1_Search = uitab(app.TabGroup);
            app.Tab1_Search.AutoResizeChildren = 'off';

            % Create Tab1_SearchGrid
            app.Tab1_SearchGrid = uigridlayout(app.Tab1_Search);
            app.Tab1_SearchGrid.ColumnWidth = {325, 10, '1x', 5};
            app.Tab1_SearchGrid.RowHeight = {'1x', 34};
            app.Tab1_SearchGrid.ColumnSpacing = 0;
            app.Tab1_SearchGrid.RowSpacing = 5;
            app.Tab1_SearchGrid.Padding = [0 0 0 26];
            app.Tab1_SearchGrid.BackgroundColor = [1 1 1];

            % Create search_toolGrid
            app.search_toolGrid = uigridlayout(app.Tab1_SearchGrid);
            app.search_toolGrid.ColumnWidth = {22, 22, 22, '1x', 110, 110, 110};
            app.search_toolGrid.RowHeight = {4, 17, '1x'};
            app.search_toolGrid.ColumnSpacing = 5;
            app.search_toolGrid.RowSpacing = 0;
            app.search_toolGrid.Padding = [0 5 5 5];
            app.search_toolGrid.Layout.Row = 2;
            app.search_toolGrid.Layout.Column = [1 4];

            % Create search_leftPanelVisibility
            app.search_leftPanelVisibility = uiimage(app.search_toolGrid);
            app.search_leftPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.search_leftPanelVisibility.Enable = 'off';
            app.search_leftPanelVisibility.Layout.Row = 2;
            app.search_leftPanelVisibility.Layout.Column = 1;
            app.search_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';

            % Create search_FilterSetup
            app.search_FilterSetup = uiimage(app.search_toolGrid);
            app.search_FilterSetup.ScaleMethod = 'none';
            app.search_FilterSetup.ImageClickedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.search_FilterSetup.Enable = 'off';
            app.search_FilterSetup.Tooltip = {'Edita filtragem secundária'};
            app.search_FilterSetup.Layout.Row = [1 3];
            app.search_FilterSetup.Layout.Column = 2;
            app.search_FilterSetup.ImageSource = 'Filter_18x18.png';

            % Create search_ExportTable
            app.search_ExportTable = uiimage(app.search_toolGrid);
            app.search_ExportTable.ScaleMethod = 'none';
            app.search_ExportTable.ImageClickedFcn = createCallbackFcn(app, @search_ExportTableClicked, true);
            app.search_ExportTable.Enable = 'off';
            app.search_ExportTable.Tooltip = {'Exporta resultados de busca em arquivo XLSX'};
            app.search_ExportTable.Layout.Row = 2;
            app.search_ExportTable.Layout.Column = 3;
            app.search_ExportTable.ImageSource = 'Export_16.png';

            % Create search_OrientationHomologation
            app.search_OrientationHomologation = uibutton(app.search_toolGrid, 'push');
            app.search_OrientationHomologation.ButtonPushedFcn = createCallbackFcn(app, @search_OrientationHomologationButtonPushed, true);
            app.search_OrientationHomologation.Tag = 'Homologação';
            app.search_OrientationHomologation.WordWrap = 'on';
            app.search_OrientationHomologation.BackgroundColor = [0.9412 0.9412 0.9412];
            app.search_OrientationHomologation.FontSize = 11;
            app.search_OrientationHomologation.FontColor = [0.502 0.502 0.502];
            app.search_OrientationHomologation.Tooltip = {'Filtragem primária orientada à coluna'; '"Homologação"'};
            app.search_OrientationHomologation.Layout.Row = [1 3];
            app.search_OrientationHomologation.Layout.Column = 5;
            app.search_OrientationHomologation.Text = 'HOMOLOGAÇÃO';

            % Create search_OrientationEntity
            app.search_OrientationEntity = uibutton(app.search_toolGrid, 'push');
            app.search_OrientationEntity.ButtonPushedFcn = createCallbackFcn(app, @search_OrientationHomologationButtonPushed, true);
            app.search_OrientationEntity.Tag = 'Solicitante | Fabricante';
            app.search_OrientationEntity.WordWrap = 'on';
            app.search_OrientationEntity.BackgroundColor = [0.9412 0.9412 0.9412];
            app.search_OrientationEntity.FontSize = 11;
            app.search_OrientationEntity.FontColor = [0.502 0.502 0.502];
            app.search_OrientationEntity.Tooltip = {'Filtragem primária orientada às colunas'; '"Solicitante" e "Fabricante"'};
            app.search_OrientationEntity.Layout.Row = [1 3];
            app.search_OrientationEntity.Layout.Column = 6;
            app.search_OrientationEntity.Text = 'EMPRESA';

            % Create search_OrientationProduct
            app.search_OrientationProduct = uibutton(app.search_toolGrid, 'push');
            app.search_OrientationProduct.ButtonPushedFcn = createCallbackFcn(app, @search_OrientationHomologationButtonPushed, true);
            app.search_OrientationProduct.Tag = 'Modelo | Nome Comercial';
            app.search_OrientationProduct.WordWrap = 'on';
            app.search_OrientationProduct.BackgroundColor = [0.2392 0.4706 0.851];
            app.search_OrientationProduct.FontSize = 11;
            app.search_OrientationProduct.FontColor = [1 1 1];
            app.search_OrientationProduct.Tooltip = {'Filtragem primária orientada às colunas'; '"Modelo" e "Nome Comercial"'};
            app.search_OrientationProduct.Layout.Row = [1 3];
            app.search_OrientationProduct.Layout.Column = 7;
            app.search_OrientationProduct.Text = 'PRODUTO';

            % Create search_Tab1Grid
            app.search_Tab1Grid = uigridlayout(app.Tab1_SearchGrid);
            app.search_Tab1Grid.ColumnWidth = {'1x', 18, 18, 18};
            app.search_Tab1Grid.RowHeight = {22, 22, '1x', 0, 0, 0, 0, 0, 0};
            app.search_Tab1Grid.ColumnSpacing = 2;
            app.search_Tab1Grid.RowSpacing = 5;
            app.search_Tab1Grid.Padding = [5 0 0 0];
            app.search_Tab1Grid.Layout.Row = 1;
            app.search_Tab1Grid.Layout.Column = 1;
            app.search_Tab1Grid.BackgroundColor = [1 1 1];

            % Create search_ProductInfoLabel
            app.search_ProductInfoLabel = uilabel(app.search_Tab1Grid);
            app.search_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.search_ProductInfoLabel.FontSize = 10;
            app.search_ProductInfoLabel.Layout.Row = 2;
            app.search_ProductInfoLabel.Layout.Column = 1;
            app.search_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create search_ToolbarWordCloud
            app.search_ToolbarWordCloud = uiimage(app.search_Tab1Grid);
            app.search_ToolbarWordCloud.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarWordCloud.Enable = 'off';
            app.search_ToolbarWordCloud.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.search_ToolbarWordCloud.Layout.Row = 2;
            app.search_ToolbarWordCloud.Layout.Column = 3;
            app.search_ToolbarWordCloud.VerticalAlignment = 'bottom';
            app.search_ToolbarWordCloud.ImageSource = 'Cloud_32x32Gray.png';

            % Create search_ToolbarListOfProducts
            app.search_ToolbarListOfProducts = uiimage(app.search_Tab1Grid);
            app.search_ToolbarListOfProducts.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarListOfProducts.Enable = 'off';
            app.search_ToolbarListOfProducts.Tooltip = {'Lista de produtos homologados sob análise'};
            app.search_ToolbarListOfProducts.Layout.Row = 2;
            app.search_ToolbarListOfProducts.Layout.Column = 4;
            app.search_ToolbarListOfProducts.VerticalAlignment = 'bottom';
            app.search_ToolbarListOfProducts.ImageSource = 'Box_32x32Gray.png';

            % Create search_AnnotationPanelLabel
            app.search_AnnotationPanelLabel = uilabel(app.search_Tab1Grid);
            app.search_AnnotationPanelLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelLabel.FontSize = 10;
            app.search_AnnotationPanelLabel.Layout.Row = 4;
            app.search_AnnotationPanelLabel.Layout.Column = [1 2];
            app.search_AnnotationPanelLabel.Text = 'ANOTAÇÃO';

            % Create search_AnnotationPanel
            app.search_AnnotationPanel = uipanel(app.search_Tab1Grid);
            app.search_AnnotationPanel.AutoResizeChildren = 'off';
            app.search_AnnotationPanel.Layout.Row = 5;
            app.search_AnnotationPanel.Layout.Column = [1 4];

            % Create search_AnnotationGrid
            app.search_AnnotationGrid = uigridlayout(app.search_AnnotationPanel);
            app.search_AnnotationGrid.ColumnWidth = {'1x', 20};
            app.search_AnnotationGrid.RowHeight = {17, 22, 17, '1x', 20};
            app.search_AnnotationGrid.ColumnSpacing = 3;
            app.search_AnnotationGrid.RowSpacing = 5;
            app.search_AnnotationGrid.Padding = [10 10 5 5];
            app.search_AnnotationGrid.BackgroundColor = [1 1 1];

            % Create search_AnnotationAttributeLabel
            app.search_AnnotationAttributeLabel = uilabel(app.search_AnnotationGrid);
            app.search_AnnotationAttributeLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationAttributeLabel.FontSize = 10;
            app.search_AnnotationAttributeLabel.Layout.Row = 1;
            app.search_AnnotationAttributeLabel.Layout.Column = 1;
            app.search_AnnotationAttributeLabel.Text = 'Atributo:';

            % Create search_AnnotationAttribute
            app.search_AnnotationAttribute = uidropdown(app.search_AnnotationGrid);
            app.search_AnnotationAttribute.Items = {'Fornecedor', 'Fabricante', 'Modelo', 'EAN', 'Outras informações'};
            app.search_AnnotationAttribute.FontSize = 11;
            app.search_AnnotationAttribute.BackgroundColor = [1 1 1];
            app.search_AnnotationAttribute.Layout.Row = 2;
            app.search_AnnotationAttribute.Layout.Column = 1;
            app.search_AnnotationAttribute.Value = 'Fornecedor';

            % Create search_AnnotationValueLabel
            app.search_AnnotationValueLabel = uilabel(app.search_AnnotationGrid);
            app.search_AnnotationValueLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationValueLabel.FontSize = 10;
            app.search_AnnotationValueLabel.Layout.Row = 3;
            app.search_AnnotationValueLabel.Layout.Column = 1;
            app.search_AnnotationValueLabel.Text = 'Valor:';

            % Create search_AnnotationValue
            app.search_AnnotationValue = uitextarea(app.search_AnnotationGrid);
            app.search_AnnotationValue.FontSize = 11;
            app.search_AnnotationValue.Layout.Row = [4 5];
            app.search_AnnotationValue.Layout.Column = 1;

            % Create search_AnnotationPanelAdd
            app.search_AnnotationPanelAdd = uiimage(app.search_AnnotationGrid);
            app.search_AnnotationPanelAdd.ImageClickedFcn = createCallbackFcn(app, @search_Annotation_AddImageClicked, true);
            app.search_AnnotationPanelAdd.Layout.Row = 5;
            app.search_AnnotationPanelAdd.Layout.Column = 2;
            app.search_AnnotationPanelAdd.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelAdd.ImageSource = 'NewFile_36.png';

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.search_Tab1Grid);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = [6 7];
            app.search_WordCloudPanel.Layout.Column = [1 4];

            % Create search_WordCloudRefresh
            app.search_WordCloudRefresh = uiimage(app.search_Tab1Grid);
            app.search_WordCloudRefresh.ImageClickedFcn = createCallbackFcn(app, @search_WordCloud_RefreshImageClicked, true);
            app.search_WordCloudRefresh.Visible = 'off';
            app.search_WordCloudRefresh.Tooltip = {'Nova consulta à API do Google'};
            app.search_WordCloudRefresh.Layout.Row = 4;
            app.search_WordCloudRefresh.Layout.Column = 4;
            app.search_WordCloudRefresh.VerticalAlignment = 'bottom';
            app.search_WordCloudRefresh.ImageSource = 'Refresh_18.png';

            % Create search_ListOfProductsLabel
            app.search_ListOfProductsLabel = uilabel(app.search_Tab1Grid);
            app.search_ListOfProductsLabel.VerticalAlignment = 'bottom';
            app.search_ListOfProductsLabel.FontSize = 10;
            app.search_ListOfProductsLabel.Layout.Row = 8;
            app.search_ListOfProductsLabel.Layout.Column = [1 3];
            app.search_ListOfProductsLabel.Text = 'LISTA DE PRODUTOS HOMOLOGADOS SOB ANÁLISE';

            % Create search_ListOfProductsAdd
            app.search_ListOfProductsAdd = uiimage(app.search_Tab1Grid);
            app.search_ListOfProductsAdd.ImageClickedFcn = createCallbackFcn(app, @search_Report_ListOfProductsAddImageClicked, true);
            app.search_ListOfProductsAdd.Layout.Row = 8;
            app.search_ListOfProductsAdd.Layout.Column = 4;
            app.search_ListOfProductsAdd.VerticalAlignment = 'bottom';
            app.search_ListOfProductsAdd.ImageSource = 'Sum_36.png';

            % Create search_ListOfProducts
            app.search_ListOfProducts = uilistbox(app.search_Tab1Grid);
            app.search_ListOfProducts.Items = {};
            app.search_ListOfProducts.Multiselect = 'on';
            app.search_ListOfProducts.ValueChangedFcn = createCallbackFcn(app, @search_ListOfProductsValueChanged, true);
            app.search_ListOfProducts.FontSize = 11;
            app.search_ListOfProducts.Layout.Row = 9;
            app.search_ListOfProducts.Layout.Column = [1 4];
            app.search_ListOfProducts.Value = {};

            % Create search_ToolbarAnnotation
            app.search_ToolbarAnnotation = uiimage(app.search_Tab1Grid);
            app.search_ToolbarAnnotation.ScaleMethod = 'none';
            app.search_ToolbarAnnotation.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarAnnotation.Enable = 'off';
            app.search_ToolbarAnnotation.Tooltip = {'Anotação textual'};
            app.search_ToolbarAnnotation.Layout.Row = 2;
            app.search_ToolbarAnnotation.Layout.Column = 2;
            app.search_ToolbarAnnotation.VerticalAlignment = 'bottom';
            app.search_ToolbarAnnotation.ImageSource = 'Edit_18x18Gray.png';

            % Create search_menuBtn1Grid
            app.search_menuBtn1Grid = uigridlayout(app.search_Tab1Grid);
            app.search_menuBtn1Grid.ColumnWidth = {18, '1x'};
            app.search_menuBtn1Grid.RowHeight = {'1x'};
            app.search_menuBtn1Grid.ColumnSpacing = 3;
            app.search_menuBtn1Grid.Padding = [2 0 0 0];
            app.search_menuBtn1Grid.Layout.Row = 1;
            app.search_menuBtn1Grid.Layout.Column = [1 4];
            app.search_menuBtn1Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create search_menuBtn1Label
            app.search_menuBtn1Label = uilabel(app.search_menuBtn1Grid);
            app.search_menuBtn1Label.FontSize = 11;
            app.search_menuBtn1Label.Layout.Row = 1;
            app.search_menuBtn1Label.Layout.Column = 2;
            app.search_menuBtn1Label.Text = 'DADOS';

            % Create search_menuBtn1Icon
            app.search_menuBtn1Icon = uiimage(app.search_menuBtn1Grid);
            app.search_menuBtn1Icon.ScaleMethod = 'none';
            app.search_menuBtn1Icon.Tag = '1';
            app.search_menuBtn1Icon.Layout.Row = 1;
            app.search_menuBtn1Icon.Layout.Column = 1;
            app.search_menuBtn1Icon.HorizontalAlignment = 'left';
            app.search_menuBtn1Icon.ImageSource = 'Classification_18.png';

            % Create search_ProductInfoImage
            app.search_ProductInfoImage = uiimage(app.search_Tab1Grid);
            app.search_ProductInfoImage.ScaleMethod = 'none';
            app.search_ProductInfoImage.Layout.Row = 3;
            app.search_ProductInfoImage.Layout.Column = [1 4];
            app.search_ProductInfoImage.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'warning.svg');

            % Create search_ProductInfo
            app.search_ProductInfo = uilabel(app.search_Tab1Grid);
            app.search_ProductInfo.VerticalAlignment = 'top';
            app.search_ProductInfo.WordWrap = 'on';
            app.search_ProductInfo.FontSize = 11;
            app.search_ProductInfo.Layout.Row = 3;
            app.search_ProductInfo.Layout.Column = [1 4];
            app.search_ProductInfo.Interpreter = 'html';
            app.search_ProductInfo.Text = '';

            % Create search_Document
            app.search_Document = uigridlayout(app.Tab1_SearchGrid);
            app.search_Document.ColumnWidth = {412, '1x'};
            app.search_Document.RowHeight = {35, 1, 5, 54, 342, '1x', 1};
            app.search_Document.ColumnSpacing = 5;
            app.search_Document.RowSpacing = 0;
            app.search_Document.Padding = [0 0 0 0];
            app.search_Document.Layout.Row = 1;
            app.search_Document.Layout.Column = 3;
            app.search_Document.BackgroundColor = [1 1 1];

            % Create search_Table
            app.search_Table = uitable(app.search_Document);
            app.search_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.search_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.search_Table.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.search_Table.RowName = {};
            app.search_Table.SelectionType = 'row';
            app.search_Table.RowStriping = 'off';
            app.search_Table.SelectionChangedFcn = createCallbackFcn(app, @search_Table_SelectionChanged, true);
            app.search_Table.Visible = 'off';
            app.search_Table.Layout.Row = [5 6];
            app.search_Table.Layout.Column = [1 2];
            app.search_Table.FontSize = 10;

            % Create search_entryPointPanel
            app.search_entryPointPanel = uipanel(app.search_Document);
            app.search_entryPointPanel.AutoResizeChildren = 'off';
            app.search_entryPointPanel.BackgroundColor = [1 1 1];
            app.search_entryPointPanel.Layout.Row = 1;
            app.search_entryPointPanel.Layout.Column = 1;

            % Create search_entryPointGrid
            app.search_entryPointGrid = uigridlayout(app.search_entryPointPanel);
            app.search_entryPointGrid.ColumnWidth = {'1x', 28};
            app.search_entryPointGrid.RowHeight = {'1x'};
            app.search_entryPointGrid.ColumnSpacing = 0;
            app.search_entryPointGrid.RowSpacing = 0;
            app.search_entryPointGrid.Padding = [0 0 0 0];
            app.search_entryPointGrid.BackgroundColor = [1 1 1];

            % Create search_entryPoint
            app.search_entryPoint = uieditfield(app.search_entryPointGrid, 'text');
            app.search_entryPoint.CharacterLimits = [0 128];
            app.search_entryPoint.ValueChangingFcn = createCallbackFcn(app, @search_EntryPoint_ValueChanging, true);
            app.search_entryPoint.Tag = 'PROMPT';
            app.search_entryPoint.FontSize = 14;
            app.search_entryPoint.Placeholder = 'O que você quer pesquisar?';
            app.search_entryPoint.Layout.Row = 1;
            app.search_entryPoint.Layout.Column = 1;

            % Create search_entryPointImage
            app.search_entryPointImage = uiimage(app.search_entryPointGrid);
            app.search_entryPointImage.ScaleMethod = 'scaledown';
            app.search_entryPointImage.ImageClickedFcn = createCallbackFcn(app, @search_EntryPoint_ImageClicked, true);
            app.search_entryPointImage.Enable = 'off';
            app.search_entryPointImage.Layout.Row = 1;
            app.search_entryPointImage.Layout.Column = 2;
            app.search_entryPointImage.ImageSource = 'Zoom_36x36.png';

            % Create search_Metadata
            app.search_Metadata = uilabel(app.search_Document);
            app.search_Metadata.VerticalAlignment = 'top';
            app.search_Metadata.WordWrap = 'on';
            app.search_Metadata.FontSize = 14;
            app.search_Metadata.Visible = 'off';
            app.search_Metadata.Layout.Row = 4;
            app.search_Metadata.Layout.Column = [1 2];
            app.search_Metadata.Interpreter = 'html';
            app.search_Metadata.Text = {'Exibindo resultados para "<b>apple iphone</b>"'; '<p style="color: #808080; font-size:10px;">Filtragem primária: Homologação<br>Filtragem secundária: []</p>'};

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.search_Document);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = [2 5];
            app.search_Suggestions.Layout.Column = 1;
            app.search_Suggestions.Value = {};

            % Create search_nRows
            app.search_nRows = uilabel(app.search_Document);
            app.search_nRows.HorizontalAlignment = 'right';
            app.search_nRows.VerticalAlignment = 'bottom';
            app.search_nRows.FontColor = [0.502 0.502 0.502];
            app.search_nRows.Visible = 'off';
            app.search_nRows.Layout.Row = [1 4];
            app.search_nRows.Layout.Column = 2;
            app.search_nRows.Interpreter = 'html';
            app.search_nRows.Text = {'88 <font style="font-size: 9px; margin-right: 2px;">HOMOLOGAÇÕES</font>'; '137 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>'};

            % Create Tab2_Report
            app.Tab2_Report = uitab(app.TabGroup);
            app.Tab2_Report.AutoResizeChildren = 'off';

            % Create Tab2_ReportGrid
            app.Tab2_ReportGrid = uigridlayout(app.Tab2_Report);
            app.Tab2_ReportGrid.ColumnWidth = {325, 10, '1x', 10, 325};
            app.Tab2_ReportGrid.RowHeight = {'1x', 5, 34};
            app.Tab2_ReportGrid.ColumnSpacing = 0;
            app.Tab2_ReportGrid.RowSpacing = 0;
            app.Tab2_ReportGrid.Padding = [0 0 0 26];
            app.Tab2_ReportGrid.BackgroundColor = [1 1 1];

            % Create report_toolGrid
            app.report_toolGrid = uigridlayout(app.Tab2_ReportGrid);
            app.report_toolGrid.ColumnWidth = {22, 22, '1x', 22, 22, 22};
            app.report_toolGrid.RowHeight = {'1x', 17, '1x'};
            app.report_toolGrid.ColumnSpacing = 5;
            app.report_toolGrid.RowSpacing = 0;
            app.report_toolGrid.Padding = [0 5 0 5];
            app.report_toolGrid.Layout.Row = 3;
            app.report_toolGrid.Layout.Column = [1 5];

            % Create report_leftPanelVisibility
            app.report_leftPanelVisibility = uiimage(app.report_toolGrid);
            app.report_leftPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.report_leftPanelVisibility.Layout.Row = 2;
            app.report_leftPanelVisibility.Layout.Column = 1;
            app.report_leftPanelVisibility.ImageSource = 'ArrowLeft_32.png';

            % Create report_ShowCells2Edit
            app.report_ShowCells2Edit = uiimage(app.report_toolGrid);
            app.report_ShowCells2Edit.ScaleMethod = 'none';
            app.report_ShowCells2Edit.ImageClickedFcn = createCallbackFcn(app, @report_ShowCells2EditClicked, true);
            app.report_ShowCells2Edit.Tag = 'off';
            app.report_ShowCells2Edit.Enable = 'off';
            app.report_ShowCells2Edit.Tooltip = {'Destaca células pendentes de edição'};
            app.report_ShowCells2Edit.Layout.Row = [2 3];
            app.report_ShowCells2Edit.Layout.Column = 2;
            app.report_ShowCells2Edit.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create report_ReportGeneration
            app.report_ReportGeneration = uiimage(app.report_toolGrid);
            app.report_ReportGeneration.ScaleMethod = 'none';
            app.report_ReportGeneration.ImageClickedFcn = createCallbackFcn(app, @report_ReportGenerationImageClicked, true);
            app.report_ReportGeneration.Enable = 'off';
            app.report_ReportGeneration.Tooltip = {'Gera relatório'};
            app.report_ReportGeneration.Layout.Row = [1 3];
            app.report_ReportGeneration.Layout.Column = 4;
            app.report_ReportGeneration.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Publish_HTML_16.png');

            % Create report_FiscalizaUpdate
            app.report_FiscalizaUpdate = uiimage(app.report_toolGrid);
            app.report_FiscalizaUpdate.ImageClickedFcn = createCallbackFcn(app, @report_FiscalizaCallbacks, true);
            app.report_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.report_FiscalizaUpdate.Layout.Row = 2;
            app.report_FiscalizaUpdate.Layout.Column = 5;
            app.report_FiscalizaUpdate.ImageSource = 'Up_24.png';

            % Create report_rightPanelVisibility
            app.report_rightPanelVisibility = uiimage(app.report_toolGrid);
            app.report_rightPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.report_rightPanelVisibility.Layout.Row = 2;
            app.report_rightPanelVisibility.Layout.Column = 6;
            app.report_rightPanelVisibility.ImageSource = 'ArrowLeft_32.png';

            % Create report_Tab1Grid
            app.report_Tab1Grid = uigridlayout(app.Tab2_ReportGrid);
            app.report_Tab1Grid.ColumnWidth = {'1x'};
            app.report_Tab1Grid.RowHeight = {22, 22, '1x'};
            app.report_Tab1Grid.RowSpacing = 5;
            app.report_Tab1Grid.Padding = [5 5 0 0];
            app.report_Tab1Grid.Layout.Row = [1 2];
            app.report_Tab1Grid.Layout.Column = 1;
            app.report_Tab1Grid.BackgroundColor = [1 1 1];

            % Create report_ProductInfoLabel
            app.report_ProductInfoLabel = uilabel(app.report_Tab1Grid);
            app.report_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.report_ProductInfoLabel.FontSize = 10;
            app.report_ProductInfoLabel.Layout.Row = 2;
            app.report_ProductInfoLabel.Layout.Column = 1;
            app.report_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create report_menuBtn1Grid
            app.report_menuBtn1Grid = uigridlayout(app.report_Tab1Grid);
            app.report_menuBtn1Grid.ColumnWidth = {18, '1x'};
            app.report_menuBtn1Grid.RowHeight = {'1x'};
            app.report_menuBtn1Grid.ColumnSpacing = 3;
            app.report_menuBtn1Grid.Padding = [2 0 0 0];
            app.report_menuBtn1Grid.Layout.Row = 1;
            app.report_menuBtn1Grid.Layout.Column = 1;
            app.report_menuBtn1Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create report_menuBtn1Label
            app.report_menuBtn1Label = uilabel(app.report_menuBtn1Grid);
            app.report_menuBtn1Label.FontSize = 11;
            app.report_menuBtn1Label.Layout.Row = 1;
            app.report_menuBtn1Label.Layout.Column = 2;
            app.report_menuBtn1Label.Text = 'DADOS';

            % Create report_menuBtn1Icon
            app.report_menuBtn1Icon = uiimage(app.report_menuBtn1Grid);
            app.report_menuBtn1Icon.ScaleMethod = 'none';
            app.report_menuBtn1Icon.Tag = '1';
            app.report_menuBtn1Icon.Layout.Row = 1;
            app.report_menuBtn1Icon.Layout.Column = 1;
            app.report_menuBtn1Icon.HorizontalAlignment = 'left';
            app.report_menuBtn1Icon.ImageSource = 'Classification_18.png';

            % Create report_ProductInfoImage
            app.report_ProductInfoImage = uiimage(app.report_Tab1Grid);
            app.report_ProductInfoImage.ScaleMethod = 'none';
            app.report_ProductInfoImage.Layout.Row = 3;
            app.report_ProductInfoImage.Layout.Column = 1;
            app.report_ProductInfoImage.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'warning.svg');

            % Create report_ProductInfo
            app.report_ProductInfo = uilabel(app.report_Tab1Grid);
            app.report_ProductInfo.VerticalAlignment = 'top';
            app.report_ProductInfo.WordWrap = 'on';
            app.report_ProductInfo.FontSize = 11;
            app.report_ProductInfo.Layout.Row = 3;
            app.report_ProductInfo.Layout.Column = 1;
            app.report_ProductInfo.Interpreter = 'html';
            app.report_ProductInfo.Text = '';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.Tab2_ReportGrid);
            app.GridLayout7.ColumnWidth = {'1x', 16, 16};
            app.GridLayout7.RowHeight = {1, 22, 5, 10, '1x'};
            app.GridLayout7.ColumnSpacing = 2;
            app.GridLayout7.RowSpacing = 4;
            app.GridLayout7.Padding = [0 0 0 0];
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 3;
            app.GridLayout7.BackgroundColor = [1 1 1];

            % Create LISTADEPRODUTOSSOBANLISEButtonGroup
            app.LISTADEPRODUTOSSOBANLISEButtonGroup = uibuttongroup(app.GridLayout7);
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @LISTADEPRODUTOSSOBANLISEButtonGroupSelectionChanged, true);
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.BorderType = 'none';
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.Title = 'LISTA DE PRODUTOS SOB ANÁLISE';
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.BackgroundColor = [1 1 1];
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.Layout.Row = [2 4];
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.Layout.Column = [1 3];
            app.LISTADEPRODUTOSSOBANLISEButtonGroup.FontSize = 10;

            % Create FornecedorouusurioButton
            app.FornecedorouusurioButton = uiradiobutton(app.LISTADEPRODUTOSSOBANLISEButtonGroup);
            app.FornecedorouusurioButton.Text = 'Fornecedor ou usuário';
            app.FornecedorouusurioButton.FontSize = 11;
            app.FornecedorouusurioButton.Position = [1 1 133 23];
            app.FornecedorouusurioButton.Value = true;

            % Create AduanaButton
            app.AduanaButton = uiradiobutton(app.LISTADEPRODUTOSSOBANLISEButtonGroup);
            app.AduanaButton.Text = 'Aduana';
            app.AduanaButton.FontSize = 11;
            app.AduanaButton.Position = [186 2 180 22];

            % Create report_nRows
            app.report_nRows = uilabel(app.GridLayout7);
            app.report_nRows.HorizontalAlignment = 'right';
            app.report_nRows.VerticalAlignment = 'top';
            app.report_nRows.FontColor = [0.502 0.502 0.502];
            app.report_nRows.Layout.Row = 2;
            app.report_nRows.Layout.Column = [1 3];
            app.report_nRows.Interpreter = 'html';
            app.report_nRows.Text = '0 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>';

            % Create report_EditProduct
            app.report_EditProduct = uiimage(app.GridLayout7);
            app.report_EditProduct.ImageClickedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.report_EditProduct.Enable = 'off';
            app.report_EditProduct.Tooltip = {'Edita lista de produtos'};
            app.report_EditProduct.Layout.Row = [3 4];
            app.report_EditProduct.Layout.Column = 3;
            app.report_EditProduct.ImageSource = 'Edit_36.png';

            % Create report_Table
            app.report_Table = uitable(app.GridLayout7);
            app.report_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'QTD.|USO/VENDIDA'; 'QTD.|ESTOQUE'; 'QTD.|LACRADAS'; 'QTD.|APREENDIDAS'; 'QTD.|RETIDAS (RFB)'; 'INFRAÇÃO'};
            app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 58, 96, 90, 90, 90, 90, 90, 90};
            app.report_Table.RowName = {};
            app.report_Table.SelectionType = 'row';
            app.report_Table.ColumnEditable = [false true true true true true true true true true true true true true];
            app.report_Table.CellEditCallback = createCallbackFcn(app, @report_TableCellEdit, true);
            app.report_Table.SelectionChangedFcn = createCallbackFcn(app, @report_TableSelectionChanged, true);
            app.report_Table.Layout.Row = 5;
            app.report_Table.Layout.Column = [1 3];
            app.report_Table.FontSize = 10;

            % Create Image5
            app.Image5 = uiimage(app.GridLayout7);
            app.Image5.ImageClickedFcn = createCallbackFcn(app, @Image5Clicked, true);
            app.Image5.Tooltip = {'Adiciona produto NÃO homologado à lista'};
            app.Image5.Layout.Row = [3 4];
            app.Image5.Layout.Column = 2;
            app.Image5.ImageSource = 'Forbidden_32Red.png';

            % Create report_Tab2Grid
            app.report_Tab2Grid = uigridlayout(app.Tab2_ReportGrid);
            app.report_Tab2Grid.ColumnWidth = {'1x', 16, 16, 16};
            app.report_Tab2Grid.RowHeight = {22, 22, 47, 22, 112, 22, '1x'};
            app.report_Tab2Grid.ColumnSpacing = 5;
            app.report_Tab2Grid.RowSpacing = 5;
            app.report_Tab2Grid.Padding = [0 0 5 0];
            app.report_Tab2Grid.Layout.Row = 1;
            app.report_Tab2Grid.Layout.Column = 5;
            app.report_Tab2Grid.BackgroundColor = [1 1 1];

            % Create report_ProjectLabel
            app.report_ProjectLabel = uilabel(app.report_Tab2Grid);
            app.report_ProjectLabel.VerticalAlignment = 'bottom';
            app.report_ProjectLabel.FontSize = 10;
            app.report_ProjectLabel.Layout.Row = 2;
            app.report_ProjectLabel.Layout.Column = 1;
            app.report_ProjectLabel.Text = 'ARQUIVO';

            % Create report_IssuePanelLabel
            app.report_IssuePanelLabel = uilabel(app.report_Tab2Grid);
            app.report_IssuePanelLabel.VerticalAlignment = 'bottom';
            app.report_IssuePanelLabel.FontSize = 10;
            app.report_IssuePanelLabel.Layout.Row = 4;
            app.report_IssuePanelLabel.Layout.Column = 1;
            app.report_IssuePanelLabel.Text = 'ATIVIDADE DE INSPEÇÃO';

            % Create report_IssuePanel
            app.report_IssuePanel = uipanel(app.report_Tab2Grid);
            app.report_IssuePanel.AutoResizeChildren = 'off';
            app.report_IssuePanel.Layout.Row = 5;
            app.report_IssuePanel.Layout.Column = [1 4];

            % Create report_IssueGrid
            app.report_IssueGrid = uigridlayout(app.report_IssuePanel);
            app.report_IssueGrid.ColumnWidth = {90, '1x', 16, 64, 16};
            app.report_IssueGrid.RowHeight = {17, 22, 17, 22};
            app.report_IssueGrid.RowSpacing = 5;
            app.report_IssueGrid.Padding = [10 10 10 5];
            app.report_IssueGrid.BackgroundColor = [1 1 1];

            % Create report_IssueLabel
            app.report_IssueLabel = uilabel(app.report_IssueGrid);
            app.report_IssueLabel.VerticalAlignment = 'bottom';
            app.report_IssueLabel.WordWrap = 'on';
            app.report_IssueLabel.FontSize = 10;
            app.report_IssueLabel.FontColor = [0.149 0.149 0.149];
            app.report_IssueLabel.Layout.Row = 1;
            app.report_IssueLabel.Layout.Column = 4;
            app.report_IssueLabel.Text = 'Id:';

            % Create report_Issue
            app.report_Issue = uieditfield(app.report_IssueGrid, 'numeric');
            app.report_Issue.Limits = [-1 Inf];
            app.report_Issue.RoundFractionalValues = 'on';
            app.report_Issue.ValueDisplayFormat = '%d';
            app.report_Issue.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_Issue.FontSize = 11;
            app.report_Issue.FontColor = [0.149 0.149 0.149];
            app.report_Issue.Layout.Row = 2;
            app.report_Issue.Layout.Column = [4 5];
            app.report_Issue.Value = -1;

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.report_IssueGrid);
            app.report_ModelName.Items = {};
            app.report_ModelName.ValueChangedFcn = createCallbackFcn(app, @report_ModelNameValueChanged, true);
            app.report_ModelName.FontSize = 11;
            app.report_ModelName.BackgroundColor = [1 1 1];
            app.report_ModelName.Layout.Row = 4;
            app.report_ModelName.Layout.Column = [1 3];
            app.report_ModelName.Value = {};

            % Create report_ModelNameLabel
            app.report_ModelNameLabel = uilabel(app.report_IssueGrid);
            app.report_ModelNameLabel.VerticalAlignment = 'bottom';
            app.report_ModelNameLabel.WordWrap = 'on';
            app.report_ModelNameLabel.FontSize = 10;
            app.report_ModelNameLabel.Layout.Row = 3;
            app.report_ModelNameLabel.Layout.Column = [1 2];
            app.report_ModelNameLabel.Text = 'Modelo do relatório:';

            % Create report_VersionLabel
            app.report_VersionLabel = uilabel(app.report_IssueGrid);
            app.report_VersionLabel.VerticalAlignment = 'bottom';
            app.report_VersionLabel.WordWrap = 'on';
            app.report_VersionLabel.FontSize = 10;
            app.report_VersionLabel.Layout.Row = 3;
            app.report_VersionLabel.Layout.Column = 4;
            app.report_VersionLabel.Text = 'Versão:';

            % Create report_Version
            app.report_Version = uidropdown(app.report_IssueGrid);
            app.report_Version.Items = {'Preliminar', 'Definitiva'};
            app.report_Version.FontSize = 11;
            app.report_Version.BackgroundColor = [1 1 1];
            app.report_Version.Layout.Row = 4;
            app.report_Version.Layout.Column = [4 5];
            app.report_Version.Value = 'Preliminar';

            % Create report_systemLabel
            app.report_systemLabel = uilabel(app.report_IssueGrid);
            app.report_systemLabel.VerticalAlignment = 'bottom';
            app.report_systemLabel.WordWrap = 'on';
            app.report_systemLabel.FontSize = 10;
            app.report_systemLabel.FontColor = [0.149 0.149 0.149];
            app.report_systemLabel.Layout.Row = 1;
            app.report_systemLabel.Layout.Column = [1 3];
            app.report_systemLabel.Text = 'Sistema:';

            % Create report_system
            app.report_system = uidropdown(app.report_IssueGrid);
            app.report_system.Items = {'eFiscaliza', 'eFiscaliza DS', 'eFiscaliza HM'};
            app.report_system.FontSize = 11;
            app.report_system.BackgroundColor = [1 1 1];
            app.report_system.Layout.Row = 2;
            app.report_system.Layout.Column = [1 3];
            app.report_system.Value = 'eFiscaliza';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.report_Tab2Grid);
            app.report_ProjectNew.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 2;
            app.report_ProjectNew.Layout.Column = 2;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = 'AddFiles_36.png';

            % Create report_ProjectOpen
            app.report_ProjectOpen = uiimage(app.report_Tab2Grid);
            app.report_ProjectOpen.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectOpen.Tooltip = {'Abre projeto'};
            app.report_ProjectOpen.Layout.Row = 2;
            app.report_ProjectOpen.Layout.Column = 3;
            app.report_ProjectOpen.VerticalAlignment = 'bottom';
            app.report_ProjectOpen.ImageSource = 'OpenFile_36x36.png';

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.report_Tab2Grid);
            app.report_ProjectSave.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 2;
            app.report_ProjectSave.Layout.Column = 4;
            app.report_ProjectSave.VerticalAlignment = 'bottom';
            app.report_ProjectSave.ImageSource = 'SaveFile_36.png';

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.report_Tab2Grid);
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 3;
            app.report_ProjectName.Layout.Column = [1 4];

            % Create report_EntityPanelLabel
            app.report_EntityPanelLabel = uilabel(app.report_Tab2Grid);
            app.report_EntityPanelLabel.VerticalAlignment = 'bottom';
            app.report_EntityPanelLabel.FontSize = 10;
            app.report_EntityPanelLabel.Layout.Row = 6;
            app.report_EntityPanelLabel.Layout.Column = 1;
            app.report_EntityPanelLabel.Text = 'FISCALIZADA';

            % Create report_EntityPanel
            app.report_EntityPanel = uipanel(app.report_Tab2Grid);
            app.report_EntityPanel.Layout.Row = 7;
            app.report_EntityPanel.Layout.Column = [1 4];

            % Create report_EntityGrid
            app.report_EntityGrid = uigridlayout(app.report_EntityPanel);
            app.report_EntityGrid.ColumnWidth = {110, '1x', 16};
            app.report_EntityGrid.RowHeight = {17, 22, 17, 22};
            app.report_EntityGrid.RowSpacing = 5;
            app.report_EntityGrid.Padding = [10 10 10 5];
            app.report_EntityGrid.BackgroundColor = [1 1 1];

            % Create report_EntityTypeLabel
            app.report_EntityTypeLabel = uilabel(app.report_EntityGrid);
            app.report_EntityTypeLabel.VerticalAlignment = 'bottom';
            app.report_EntityTypeLabel.FontSize = 10;
            app.report_EntityTypeLabel.Layout.Row = 1;
            app.report_EntityTypeLabel.Layout.Column = 1;
            app.report_EntityTypeLabel.Text = 'Tipo:';

            % Create report_EntityType
            app.report_EntityType = uidropdown(app.report_EntityGrid);
            app.report_EntityType.Items = {'', 'Importador', 'Fornecedor', 'Usuário'};
            app.report_EntityType.ValueChangedFcn = createCallbackFcn(app, @report_EntityTypeValueChanged, true);
            app.report_EntityType.FontSize = 11;
            app.report_EntityType.BackgroundColor = [1 1 1];
            app.report_EntityType.Layout.Row = 2;
            app.report_EntityType.Layout.Column = 1;
            app.report_EntityType.Value = '';

            % Create report_EntityIDLabel
            app.report_EntityIDLabel = uilabel(app.report_EntityGrid);
            app.report_EntityIDLabel.VerticalAlignment = 'bottom';
            app.report_EntityIDLabel.WordWrap = 'on';
            app.report_EntityIDLabel.FontSize = 10;
            app.report_EntityIDLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityIDLabel.Layout.Row = 1;
            app.report_EntityIDLabel.Layout.Column = 2;
            app.report_EntityIDLabel.Text = 'CNPJ/CPF:';

            % Create report_EntityCheck
            app.report_EntityCheck = uiimage(app.report_EntityGrid);
            app.report_EntityCheck.ImageClickedFcn = createCallbackFcn(app, @report_EntityIDCheck, true);
            app.report_EntityCheck.Enable = 'off';
            app.report_EntityCheck.Layout.Row = 1;
            app.report_EntityCheck.Layout.Column = 3;
            app.report_EntityCheck.VerticalAlignment = 'bottom';
            app.report_EntityCheck.ImageSource = 'Info_36.png';

            % Create report_EntityID
            app.report_EntityID = uieditfield(app.report_EntityGrid, 'text');
            app.report_EntityID.ValueChangedFcn = createCallbackFcn(app, @report_EntityIDValueChanged, true);
            app.report_EntityID.FontSize = 11;
            app.report_EntityID.Enable = 'off';
            app.report_EntityID.Layout.Row = 2;
            app.report_EntityID.Layout.Column = [2 3];

            % Create report_EntityLabel
            app.report_EntityLabel = uilabel(app.report_EntityGrid);
            app.report_EntityLabel.VerticalAlignment = 'bottom';
            app.report_EntityLabel.WordWrap = 'on';
            app.report_EntityLabel.FontSize = 10;
            app.report_EntityLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityLabel.Layout.Row = 3;
            app.report_EntityLabel.Layout.Column = 1;
            app.report_EntityLabel.Text = 'Nome:';

            % Create report_Entity
            app.report_Entity = uieditfield(app.report_EntityGrid, 'text');
            app.report_Entity.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_Entity.FontSize = 11;
            app.report_Entity.Enable = 'off';
            app.report_Entity.Layout.Row = 4;
            app.report_Entity.Layout.Column = [1 3];

            % Create report_menuBtn2Grid
            app.report_menuBtn2Grid = uigridlayout(app.report_Tab2Grid);
            app.report_menuBtn2Grid.ColumnWidth = {18, '1x', 16};
            app.report_menuBtn2Grid.RowHeight = {'1x'};
            app.report_menuBtn2Grid.ColumnSpacing = 3;
            app.report_menuBtn2Grid.Padding = [2 0 0 0];
            app.report_menuBtn2Grid.Layout.Row = 1;
            app.report_menuBtn2Grid.Layout.Column = [1 4];
            app.report_menuBtn2Grid.BackgroundColor = [0.749 0.749 0.749];

            % Create report_menuBtn2Label
            app.report_menuBtn2Label = uilabel(app.report_menuBtn2Grid);
            app.report_menuBtn2Label.FontSize = 11;
            app.report_menuBtn2Label.Layout.Row = 1;
            app.report_menuBtn2Label.Layout.Column = 2;
            app.report_menuBtn2Label.Text = 'PROJETO';

            % Create report_ProjectWarnIcon
            app.report_ProjectWarnIcon = uiimage(app.report_menuBtn2Grid);
            app.report_ProjectWarnIcon.ScaleMethod = 'none';
            app.report_ProjectWarnIcon.Visible = 'off';
            app.report_ProjectWarnIcon.Tooltip = {'Pendente salvar projeto'};
            app.report_ProjectWarnIcon.Layout.Row = 1;
            app.report_ProjectWarnIcon.Layout.Column = 3;
            app.report_ProjectWarnIcon.HorizontalAlignment = 'right';
            app.report_ProjectWarnIcon.VerticalAlignment = 'bottom';
            app.report_ProjectWarnIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create report_menuBtn2Icon
            app.report_menuBtn2Icon = uiimage(app.report_menuBtn2Grid);
            app.report_menuBtn2Icon.ScaleMethod = 'none';
            app.report_menuBtn2Icon.ImageClickedFcn = createCallbackFcn(app, @report_menuBtn2IconImageClicked, true);
            app.report_menuBtn2Icon.Tag = '2';
            app.report_menuBtn2Icon.Layout.Row = 1;
            app.report_menuBtn2Icon.Layout.Column = [1 2];
            app.report_menuBtn2Icon.HorizontalAlignment = 'left';
            app.report_menuBtn2Icon.ImageSource = 'Report_18x18.png';

            % Create Tab3_Config
            app.Tab3_Config = uitab(app.TabGroup);

            % Create menu_Grid
            app.menu_Grid = uigridlayout(app.GridLayout);
            app.menu_Grid.ColumnWidth = {28, 28, 5, 28, '1x', 20, 20, 20, 20, 0, 0};
            app.menu_Grid.RowHeight = {7, '1x', 7};
            app.menu_Grid.ColumnSpacing = 5;
            app.menu_Grid.RowSpacing = 0;
            app.menu_Grid.Padding = [5 5 5 5];
            app.menu_Grid.Tag = 'COLORLOCKED';
            app.menu_Grid.Layout.Row = 1;
            app.menu_Grid.Layout.Column = 1;
            app.menu_Grid.BackgroundColor = [0.2 0.2 0.2];

            % Create menu_Button1
            app.menu_Button1 = uibutton(app.menu_Grid, 'state');
            app.menu_Button1.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button1.Tag = 'SEARCH';
            app.menu_Button1.Tooltip = {''};
            app.menu_Button1.Icon = 'Zoom_32Yellow.png';
            app.menu_Button1.IconAlignment = 'top';
            app.menu_Button1.Text = '';
            app.menu_Button1.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button1.FontSize = 11;
            app.menu_Button1.Layout.Row = [1 3];
            app.menu_Button1.Layout.Column = 1;
            app.menu_Button1.Value = true;

            % Create menu_Button2
            app.menu_Button2 = uibutton(app.menu_Grid, 'state');
            app.menu_Button2.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button2.Tag = 'REPORT';
            app.menu_Button2.Tooltip = {''};
            app.menu_Button2.Icon = 'Detection_32White.png';
            app.menu_Button2.IconAlignment = 'top';
            app.menu_Button2.Text = '';
            app.menu_Button2.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button2.FontSize = 11;
            app.menu_Button2.Layout.Row = [1 3];
            app.menu_Button2.Layout.Column = 2;

            % Create menu_Separator
            app.menu_Separator = uiimage(app.menu_Grid);
            app.menu_Separator.ScaleMethod = 'none';
            app.menu_Separator.Enable = 'off';
            app.menu_Separator.Layout.Row = [1 3];
            app.menu_Separator.Layout.Column = 3;
            app.menu_Separator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button3
            app.menu_Button3 = uibutton(app.menu_Grid, 'state');
            app.menu_Button3.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button3.Tag = 'CONFIG';
            app.menu_Button3.Tooltip = {''};
            app.menu_Button3.Icon = 'Settings_36White.png';
            app.menu_Button3.IconAlignment = 'top';
            app.menu_Button3.Text = '';
            app.menu_Button3.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button3.FontSize = 11;
            app.menu_Button3.Layout.Row = [1 3];
            app.menu_Button3.Layout.Column = 4;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.menu_Grid);
            app.jsBackDoor.Tag = 'jsBackDoor';
            app.jsBackDoor.Layout.Row = 2;
            app.jsBackDoor.Layout.Column = 6;

            % Create DataHubLamp
            app.DataHubLamp = uilamp(app.menu_Grid);
            app.DataHubLamp.Enable = 'off';
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear pastas do Sharepoint'};
            app.DataHubLamp.Layout.Row = 2;
            app.DataHubLamp.Layout.Column = 7;
            app.DataHubLamp.Color = [1 0 0];

            % Create FigurePosition
            app.FigurePosition = uiimage(app.menu_Grid);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 2;
            app.FigurePosition.Layout.Column = 8;
            app.FigurePosition.ImageSource = 'Layout1.png';

            % Create AppInfo
            app.AppInfo = uiimage(app.menu_Grid);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.AppInfo.Layout.Row = 2;
            app.AppInfo.Layout.Column = 9;
            app.AppInfo.ImageSource = 'Dots_36x36W.png';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.menu_Grid);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @menu_DockButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 2;
            app.dockModule_Undock.Layout.Column = 10;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.menu_Grid);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @menu_DockButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 2;
            app.dockModule_Close.Layout.Column = 11;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create popupContainerGrid
            app.popupContainerGrid = uigridlayout(app.GridLayout);
            app.popupContainerGrid.ColumnWidth = {'1x', 880, '1x'};
            app.popupContainerGrid.RowHeight = {'1x', 90, 300, 90, '1x'};
            app.popupContainerGrid.ColumnSpacing = 0;
            app.popupContainerGrid.RowSpacing = 0;
            app.popupContainerGrid.Padding = [13 10 0 0];
            app.popupContainerGrid.Layout.Row = 3;
            app.popupContainerGrid.Layout.Column = 1;
            app.popupContainerGrid.BackgroundColor = [1 1 1];

            % Create popupContainer
            app.popupContainer = uipanel(app.popupContainerGrid);
            app.popupContainer.Visible = 'off';
            app.popupContainer.BackgroundColor = [1 1 1];
            app.popupContainer.Layout.Row = [2 4];
            app.popupContainer.Layout.Column = 2;

            % Create SplashScreen
            app.SplashScreen = uiimage(app.popupContainerGrid);
            app.SplashScreen.Layout.Row = 3;
            app.SplashScreen.Layout.Column = 2;
            app.SplashScreen.ImageSource = 'SplashScreen.gif';

            % Create report_ContextMenu
            app.report_ContextMenu = uicontextmenu(app.UIFigure);

            % Create report_ContextMenu_EditFcn
            app.report_ContextMenu_EditFcn = uimenu(app.report_ContextMenu);
            app.report_ContextMenu_EditFcn.MenuSelectedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.report_ContextMenu_EditFcn.Enable = 'off';
            app.report_ContextMenu_EditFcn.Text = 'Editar';

            % Create report_ContextMenu_DeleteFcn
            app.report_ContextMenu_DeleteFcn = uimenu(app.report_ContextMenu);
            app.report_ContextMenu_DeleteFcn.MenuSelectedFcn = createCallbackFcn(app, @report_ContextMenu_DeleteFcnSelected, true);
            app.report_ContextMenu_DeleteFcn.ForegroundColor = [1 0 0];
            app.report_ContextMenu_DeleteFcn.Enable = 'off';
            app.report_ContextMenu_DeleteFcn.Separator = 'on';
            app.report_ContextMenu_DeleteFcn.Text = 'Excluir';
            
            % Assign app.report_ContextMenu
            app.report_Table.ContextMenu = app.report_ContextMenu;

            % Create search_ContextMenu
            app.search_ContextMenu = uicontextmenu(app.UIFigure);

            % Create search_ContextMenu_DeleteFcn
            app.search_ContextMenu_DeleteFcn = uimenu(app.search_ContextMenu);
            app.search_ContextMenu_DeleteFcn.MenuSelectedFcn = createCallbackFcn(app, @report_ContextMenu_DeleteFcnSelected, true);
            app.search_ContextMenu_DeleteFcn.ForegroundColor = [1 0 0];
            app.search_ContextMenu_DeleteFcn.Enable = 'off';
            app.search_ContextMenu_DeleteFcn.Text = 'Excluir';
            
            % Assign app.search_ContextMenu
            app.search_ListOfProducts.ContextMenu = app.search_ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winSCH_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
