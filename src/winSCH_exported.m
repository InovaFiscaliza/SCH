classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        popupContainerGrid            matlab.ui.container.GridLayout
        SplashScreen                  matlab.ui.control.Image
        NavBar                        matlab.ui.container.GridLayout
        menu_AppName                  matlab.ui.control.Label
        menu_AppIcon                  matlab.ui.control.Image
        menu_Button3                  matlab.ui.control.StateButton
        menu_Separator                matlab.ui.control.Image
        menu_Button2                  matlab.ui.control.StateButton
        menu_Button1                  matlab.ui.control.StateButton
        jsBackDoor                    matlab.ui.control.HTML
        DataHubLamp                   matlab.ui.control.Lamp
        AppInfo                       matlab.ui.control.Image
        FigurePosition                matlab.ui.control.Image
        TabGroup                      matlab.ui.container.TabGroup
        Tab1_Search                   matlab.ui.container.Tab
        GridLayout_2                  matlab.ui.container.GridLayout
        Document                      matlab.ui.container.GridLayout
        search_nRows                  matlab.ui.control.Label
        search_Suggestions            matlab.ui.control.ListBox
        search_Metadata               matlab.ui.control.Label
        search_entryPointPanel        matlab.ui.container.Panel
        search_entryPointGrid         matlab.ui.container.GridLayout
        search_entryPointImage        matlab.ui.control.Image
        search_entryPoint             matlab.ui.control.EditField
        search_Table                  matlab.ui.control.Table
        TabGroup_2                    matlab.ui.container.TabGroup
        PRODUTOTab                    matlab.ui.container.Tab
        search_Tab1Grid               matlab.ui.container.GridLayout
        search_ListOfProducts         matlab.ui.control.ListBox
        search_ListOfProductsAdd      matlab.ui.control.Image
        search_ListOfProductsLabel    matlab.ui.control.Label
        search_WordCloudPanel         matlab.ui.container.Panel
        search_AnnotationPanel        matlab.ui.container.Panel
        search_AnnotationGrid         matlab.ui.container.GridLayout
        search_AnnotationPanelAdd     matlab.ui.control.Image
        search_AnnotationValue        matlab.ui.control.TextArea
        search_AnnotationValueLabel   matlab.ui.control.Label
        search_AnnotationAttribute    matlab.ui.control.DropDown
        search_AnnotationAttributeLabel  matlab.ui.control.Label
        search_WordCloudRefresh       matlab.ui.control.Image
        search_AnnotationPanelLabel   matlab.ui.control.Label
        search_ProductInfo            matlab.ui.control.Label
        search_ProductInfoImage       matlab.ui.control.Image
        search_ToolbarListOfProducts  matlab.ui.control.Image
        search_ToolbarWordCloud       matlab.ui.control.Image
        search_ToolbarAnnotation      matlab.ui.control.Image
        search_ProductInfoLabel       matlab.ui.control.Label
        Toolbar                       matlab.ui.container.GridLayout
        search_ExportTable            matlab.ui.control.Image
        search_FilterSetup            matlab.ui.control.Image
        search_leftPanelVisibility    matlab.ui.control.Image
        Tab2_Report                   matlab.ui.container.Tab
        Tab3_Config                   matlab.ui.container.Tab
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
        renderCount = 0

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
                        if ~app.renderCount
                            startup_Controller(app)
                        else
                            % Esse fluxo será executado especificamente na
                            % versão webapp, quando o navegador atualiza a
                            % página (decorrente de F5 ou CTRL+F5).

                            closeModule(app.tabGroupController, ["SEARCH", "PRODUCTS", "CONFIG"], app.General)

                            if ~app.menu_Button1.Value
                                app.menu_Button1.Value = true;                    
                                menu_mainButtonPushed(app, struct('Source', app.menu_Button1, 'PreviousValue', false))
                                drawnow
                            end
    
                            if ~isempty(app.AppInfo.Tag)
                                app.AppInfo.Tag = '';
                            end

                            startup_Controller(app)

                            app.progressDialog.Visible = 'hidden';
                        end
                        
                        app.renderCount = app.renderCount+1;

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

                case 'app.search_ListOfProducts'
                    report_ContextMenu_DeleteFcnSelected(app, struct('ContextObject', app.search_ListOfProducts))

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

                            case 'updateDataHubGetFolder'
                                app.progressDialog.Visible = 'visible';

                                startup_mainVariables(app)
                                app.AppInfo.Tag = '';

                                app.progressDialog.Visible = 'hidden';

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
        function jsBackDoor_AppCustomizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false];
            end

            switch tabIndex
                case 0
                    sendEventToHTMLSource(app.jsBackDoor, 'startup', app.executionMode);
                    customizationStatus = [false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    appName = class(app);

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1 % SEARCH
                            % ... MIGRAR TODAS AS CUSTOMIZAÇÕES P/ O
                            % MAINAPP, QUE CITA O JSBACKDOOR DO APP
                            % AUXILIAR (QUE PODE SER IGUAL AO DO MAINAPP,
                            % OU NAO).

                            % EVITA DUPLICAÇÕES DE CÓDIGO... CENTRALIZA
                            % TUDO AQUI.

                        case 2 % REPORT
                            % ... MIGRAR TODAS AS CUSTOMIZAÇÕES P/ O
                            % MAINAPP, QUE CITA O JSBACKDOOR DO APP
                            % AUXILIAR (QUE PODE SER IGUAL AO DO MAINAPP,
                            % OU NAO).

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

            if ~app.renderCount
                % Essa propriedade registra o tipo de execução da aplicação, podendo
                % ser: 'built-in', 'desktopApp' ou 'webApp'.
                app.executionMode  = appUtil.ExecutionMode(app.UIFigure);
                if ~strcmp(app.executionMode, 'webApp')
                    app.FigurePosition.Visible = 1;
                    appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
                end
    
                % Identifica o local deste arquivo .MLAPP, caso se trate das versões 
                % "built-in" ou "webapp", ou do .EXE relacionado, caso se trate da
                % versão executável (neste caso, o ctfroot indicará o local do .MLAPP).
                appName = class.Constants.appName;
                MFilePath = fileparts(mfilename('fullpath'));
                app.rootFolder = appUtil.RootFolder(appName, MFilePath);

                % Customizações...
                jsBackDoor_AppCustomizations(app, 0)
                jsBackDoor_AppCustomizations(app, 1)
                pause(.100)

                % Cria tela de progresso...
                app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
    
                startup_ConfigFileRead(app, appName, MFilePath)
                startup_AppProperties(app)
                startup_GUIComponents(app)

                % Inicia módulo de operação paralelo...
                % parpoolCheck()
    
                % Por fim, exclui-se o splashscreen, um segundo após envio do comando 
                % para que diminua a transparência do background.
                sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
                drawnow
            
                pause(1)
                delete(app.popupContainerGrid)

            else
                jsBackDoor_AppCustomizations(app, 0)
                jsBackDoor_AppCustomizations(app, 1)
                pause(.100)
            end
        end

        %-----------------------------------------------------------------%
        function startup_ConfigFileRead(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appUtil.generalSettingsLoad(appName, app.rootFolder, {'Annotation.xlsx'});
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
            app.General_I.ui.searchTable = struct2table(app.General_I.ui.searchTable);
            app.General_I.search.cacheColumns = 'Modelo | Nome Comercial';

            app.General = app.General_I;
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.projectData = projectLib(app, app.General.ui.typeOfProduct.options, app.General.ui.typeOfSituation.options, app.General.ui.typeOfViolation.options);
            startup_mainVariables(app)
        end

        %-----------------------------------------------------------------%
        function startup_mainVariables(app)
            DataHub_GET     = app.General.fileFolder.DataHub_GET;
            SCHDataFileName = app.General.search.dataSources.main;
            SCHDataFullFile = fullfile(DataHub_GET, SCHDataFileName);

            try
                if ~isfolder(DataHub_GET)
                    error('Pendente mapear os repositórios "DataHub - GET" e "DataHub - POST".')
                elseif isfolder(DataHub_GET) && ~isfile(SCHDataFullFile)
                    error('Apesar de mapeado o repositório "DataHub - GET", não foi encontrado o arquivo %s. Favor verificar se a pasta foi mapeada corretamente e, persistindo o erro, relatar isso ao Escritório de inovação da SFI.', SCHDataFileName)
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
            app.tabGroupController = tabGroupGraphicMenu(app.NavBar, app.TabGroup, app.progressDialog, @app.jsBackDoor_Customizations, '');

            addComponent(app.tabGroupController, "Built-in", "mainApp",            app.menu_Button1, "AlwaysOn", struct('On', 'Zoom_32Yellow.png',      'Off', 'Zoom_32White.png'),      matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.menu_Button2, "AlwaysOn", struct('On', 'Detection_32Yellow.png', 'Off', 'Detection_32White.png'), matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.menu_Button3, "AlwaysOn", struct('On', 'Settings_36Yellow.png',  'Off', 'Settings_36White.png'),  app.menu_Button1,                    3)

            % Avalia mapeamento de pasta do Sharepoint...
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
                auxiliarApp char {mustBeMember(auxiliarApp, {'FilterSetup', 'ProductInfo'})}
            end

            arguments (Repeating)
                varargin
            end

            app.progressDialog.Visible = 'visible';

            % Inicialmente ajusta as dimensões do container.
            switch auxiliarApp
                case 'FilterSetup'; screenWidth = 412; screenHeight = 464;
                case 'ProductInfo'; screenWidth = 580; screenHeight = 554;
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
            if communicationStatus && strcmp(app.report_system.Value, 'eFiscaliza')
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
                        unit     = app.report_Unit.Value;
                        fileName = app.projectData.generatedFiles.lastHTMLDocFullPath;
                        docSpec  = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId   = docSpec.internal.typeId;

                        msg = run(app.eFiscalizaObj, env, operation, issue, unit, docSpec, fileName);
        
                    otherwise
                        error('Unexpected call')
                end
                
                if ~contains(msg, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(msg)
                end

                modalWindowIcon     = 'success';
                modalWindowMessage  = msg;
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


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            try
                % WARNING MESSAGES
                appUtil.disablingWarningMessages()

                % <GUI>
                app.popupContainerGrid.Layout.Row = [1,2];
                app.GridLayout.RowHeight(end) = [];

                app.menu_AppName.Text = sprintf('%s v. %s\n<font style="font-size: 9px;">%s</font>', ...
                    class.Constants.appName, class.Constants.appVersion, class.Constants.appRelease);
                % </GUI>

                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
                return
            end

            if ~strcmp(app.executionMode, 'webApp')
                msgQuestion   = 'Deseja fechar o aplicativo?';
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            % TODO: REORGANIZAR ISSO, DEPOIS DE MIGRADO P/ PROJECTDATA...

            try
                if ~strcmp(app.executionMode, 'webApp')
                    projectName = char(app.report_ProjectName.Value);
                    if ~isempty(projectName) && app.report_ProjectWarnIcon.Visible
                        msgQuestion = sprintf(['O projeto aberto - registrado no arquivo <b>"%s"</b> - foi alterado.\n\n' ...
                                               'Deseja descartar essas alterações? Caso não, favor salvá-las.'], projectName);
                    else
                        msgQuestion = 'Deseja fechar o aplicativo?';
                    end
        
                    userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end
                end

                writeFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            % Aspectos gerais (comum em todos os apps):
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
            app.GridLayout.RowHeight = {54, '1x', 44};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1_Search
            app.Tab1_Search = uitab(app.TabGroup);
            app.Tab1_Search.AutoResizeChildren = 'off';

            % Create GridLayout_2
            app.GridLayout_2 = uigridlayout(app.Tab1_Search);
            app.GridLayout_2.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout_2.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout_2.ColumnSpacing = 0;
            app.GridLayout_2.RowSpacing = 0;
            app.GridLayout_2.Padding = [0 0 0 31];
            app.GridLayout_2.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout_2);
            app.Toolbar.ColumnWidth = {22, 22, 22, '1x'};
            app.Toolbar.RowHeight = {4, 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];

            % Create search_leftPanelVisibility
            app.search_leftPanelVisibility = uiimage(app.Toolbar);
            app.search_leftPanelVisibility.Enable = 'off';
            app.search_leftPanelVisibility.Layout.Row = 2;
            app.search_leftPanelVisibility.Layout.Column = 1;
            app.search_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';

            % Create search_FilterSetup
            app.search_FilterSetup = uiimage(app.Toolbar);
            app.search_FilterSetup.ScaleMethod = 'none';
            app.search_FilterSetup.Enable = 'off';
            app.search_FilterSetup.Tooltip = {'Edita filtragem secundária'};
            app.search_FilterSetup.Layout.Row = [1 3];
            app.search_FilterSetup.Layout.Column = 2;
            app.search_FilterSetup.ImageSource = 'Filter_18x18.png';

            % Create search_ExportTable
            app.search_ExportTable = uiimage(app.Toolbar);
            app.search_ExportTable.ScaleMethod = 'none';
            app.search_ExportTable.Enable = 'off';
            app.search_ExportTable.Tooltip = {'Exporta resultados de busca em arquivo XLSX'};
            app.search_ExportTable.Layout.Row = 2;
            app.search_ExportTable.Layout.Column = 3;
            app.search_ExportTable.ImageSource = 'Export_16.png';

            % Create TabGroup_2
            app.TabGroup_2 = uitabgroup(app.GridLayout_2);
            app.TabGroup_2.AutoResizeChildren = 'off';
            app.TabGroup_2.Layout.Row = [3 4];
            app.TabGroup_2.Layout.Column = 2;

            % Create PRODUTOTab
            app.PRODUTOTab = uitab(app.TabGroup_2);
            app.PRODUTOTab.AutoResizeChildren = 'off';
            app.PRODUTOTab.Title = 'PRODUTO';

            % Create search_Tab1Grid
            app.search_Tab1Grid = uigridlayout(app.PRODUTOTab);
            app.search_Tab1Grid.ColumnWidth = {'1x', 18, 18, 18};
            app.search_Tab1Grid.RowHeight = {17, '1x', 0, 0, 0, 0, 0, 0};
            app.search_Tab1Grid.ColumnSpacing = 5;
            app.search_Tab1Grid.RowSpacing = 5;
            app.search_Tab1Grid.BackgroundColor = [1 1 1];

            % Create search_ProductInfoLabel
            app.search_ProductInfoLabel = uilabel(app.search_Tab1Grid);
            app.search_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.search_ProductInfoLabel.FontSize = 10;
            app.search_ProductInfoLabel.Layout.Row = 1;
            app.search_ProductInfoLabel.Layout.Column = 1;
            app.search_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create search_ToolbarAnnotation
            app.search_ToolbarAnnotation = uiimage(app.search_Tab1Grid);
            app.search_ToolbarAnnotation.ScaleMethod = 'none';
            app.search_ToolbarAnnotation.Enable = 'off';
            app.search_ToolbarAnnotation.Tooltip = {'Anotação textual'};
            app.search_ToolbarAnnotation.Layout.Row = 1;
            app.search_ToolbarAnnotation.Layout.Column = 2;
            app.search_ToolbarAnnotation.VerticalAlignment = 'bottom';
            app.search_ToolbarAnnotation.ImageSource = 'Edit_18x18Gray.png';

            % Create search_ToolbarWordCloud
            app.search_ToolbarWordCloud = uiimage(app.search_Tab1Grid);
            app.search_ToolbarWordCloud.Enable = 'off';
            app.search_ToolbarWordCloud.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.search_ToolbarWordCloud.Layout.Row = 1;
            app.search_ToolbarWordCloud.Layout.Column = 3;
            app.search_ToolbarWordCloud.VerticalAlignment = 'bottom';
            app.search_ToolbarWordCloud.ImageSource = 'Cloud_32x32Gray.png';

            % Create search_ToolbarListOfProducts
            app.search_ToolbarListOfProducts = uiimage(app.search_Tab1Grid);
            app.search_ToolbarListOfProducts.Enable = 'off';
            app.search_ToolbarListOfProducts.Tooltip = {'Lista de produtos homologados sob análise'};
            app.search_ToolbarListOfProducts.Layout.Row = 1;
            app.search_ToolbarListOfProducts.Layout.Column = 4;
            app.search_ToolbarListOfProducts.VerticalAlignment = 'bottom';
            app.search_ToolbarListOfProducts.ImageSource = 'Box_32x32Gray.png';

            % Create search_ProductInfoImage
            app.search_ProductInfoImage = uiimage(app.search_Tab1Grid);
            app.search_ProductInfoImage.ScaleMethod = 'none';
            app.search_ProductInfoImage.Layout.Row = 2;
            app.search_ProductInfoImage.Layout.Column = [1 4];
            app.search_ProductInfoImage.ImageSource = 'warning.svg';

            % Create search_ProductInfo
            app.search_ProductInfo = uilabel(app.search_Tab1Grid);
            app.search_ProductInfo.VerticalAlignment = 'top';
            app.search_ProductInfo.WordWrap = 'on';
            app.search_ProductInfo.FontSize = 11;
            app.search_ProductInfo.Layout.Row = 2;
            app.search_ProductInfo.Layout.Column = [1 4];
            app.search_ProductInfo.Interpreter = 'html';
            app.search_ProductInfo.Text = '';

            % Create search_AnnotationPanelLabel
            app.search_AnnotationPanelLabel = uilabel(app.search_Tab1Grid);
            app.search_AnnotationPanelLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelLabel.FontSize = 10;
            app.search_AnnotationPanelLabel.Layout.Row = 3;
            app.search_AnnotationPanelLabel.Layout.Column = [1 2];
            app.search_AnnotationPanelLabel.Text = 'ANOTAÇÃO';

            % Create search_WordCloudRefresh
            app.search_WordCloudRefresh = uiimage(app.search_Tab1Grid);
            app.search_WordCloudRefresh.Visible = 'off';
            app.search_WordCloudRefresh.Tooltip = {'Nova consulta à API do Google'};
            app.search_WordCloudRefresh.Layout.Row = 3;
            app.search_WordCloudRefresh.Layout.Column = 4;
            app.search_WordCloudRefresh.VerticalAlignment = 'bottom';
            app.search_WordCloudRefresh.ImageSource = 'Refresh_18.png';

            % Create search_AnnotationPanel
            app.search_AnnotationPanel = uipanel(app.search_Tab1Grid);
            app.search_AnnotationPanel.AutoResizeChildren = 'off';
            app.search_AnnotationPanel.Layout.Row = 4;
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
            app.search_AnnotationPanelAdd.Layout.Row = 5;
            app.search_AnnotationPanelAdd.Layout.Column = 2;
            app.search_AnnotationPanelAdd.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelAdd.ImageSource = 'NewFile_36.png';

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.search_Tab1Grid);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = [5 6];
            app.search_WordCloudPanel.Layout.Column = [1 4];

            % Create search_ListOfProductsLabel
            app.search_ListOfProductsLabel = uilabel(app.search_Tab1Grid);
            app.search_ListOfProductsLabel.VerticalAlignment = 'bottom';
            app.search_ListOfProductsLabel.FontSize = 10;
            app.search_ListOfProductsLabel.Layout.Row = 7;
            app.search_ListOfProductsLabel.Layout.Column = [1 3];
            app.search_ListOfProductsLabel.Text = 'LISTA DE PRODUTOS HOMOLOGADOS SOB ANÁLISE';

            % Create search_ListOfProductsAdd
            app.search_ListOfProductsAdd = uiimage(app.search_Tab1Grid);
            app.search_ListOfProductsAdd.Layout.Row = 7;
            app.search_ListOfProductsAdd.Layout.Column = 4;
            app.search_ListOfProductsAdd.VerticalAlignment = 'bottom';
            app.search_ListOfProductsAdd.ImageSource = 'Sum_36.png';

            % Create search_ListOfProducts
            app.search_ListOfProducts = uilistbox(app.search_Tab1Grid);
            app.search_ListOfProducts.Items = {};
            app.search_ListOfProducts.Multiselect = 'on';
            app.search_ListOfProducts.FontSize = 11;
            app.search_ListOfProducts.Layout.Row = 8;
            app.search_ListOfProducts.Layout.Column = [1 4];
            app.search_ListOfProducts.Value = {};

            % Create Document
            app.Document = uigridlayout(app.GridLayout_2);
            app.Document.ColumnWidth = {'1x', 412, '1x'};
            app.Document.RowHeight = {35, 1, 5, 54, 342, '1x', 1};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

            % Create search_Table
            app.search_Table = uitable(app.Document);
            app.search_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.search_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.search_Table.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.search_Table.RowName = {};
            app.search_Table.SelectionType = 'row';
            app.search_Table.RowStriping = 'off';
            app.search_Table.Visible = 'off';
            app.search_Table.Layout.Row = [5 6];
            app.search_Table.Layout.Column = [1 3];
            app.search_Table.FontSize = 10;

            % Create search_entryPointPanel
            app.search_entryPointPanel = uipanel(app.Document);
            app.search_entryPointPanel.AutoResizeChildren = 'off';
            app.search_entryPointPanel.BackgroundColor = [1 1 1];
            app.search_entryPointPanel.Layout.Row = 1;
            app.search_entryPointPanel.Layout.Column = 2;

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
            app.search_entryPoint.Tag = 'PROMPT';
            app.search_entryPoint.FontSize = 14;
            app.search_entryPoint.Placeholder = 'O que você quer pesquisar?';
            app.search_entryPoint.Layout.Row = 1;
            app.search_entryPoint.Layout.Column = 1;

            % Create search_entryPointImage
            app.search_entryPointImage = uiimage(app.search_entryPointGrid);
            app.search_entryPointImage.ScaleMethod = 'scaledown';
            app.search_entryPointImage.Enable = 'off';
            app.search_entryPointImage.Layout.Row = 1;
            app.search_entryPointImage.Layout.Column = 2;
            app.search_entryPointImage.ImageSource = 'Zoom_36x36.png';

            % Create search_Metadata
            app.search_Metadata = uilabel(app.Document);
            app.search_Metadata.VerticalAlignment = 'top';
            app.search_Metadata.WordWrap = 'on';
            app.search_Metadata.FontSize = 14;
            app.search_Metadata.Visible = 'off';
            app.search_Metadata.Layout.Row = 4;
            app.search_Metadata.Layout.Column = [1 3];
            app.search_Metadata.Interpreter = 'html';
            app.search_Metadata.Text = {'Exibindo resultados para "<b>apple iphone</b>"'; '<p style="color: #808080; font-size:10px;">Filtragem primária: Homologação<br>Filtragem secundária: []</p>'};

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.Document);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = [2 5];
            app.search_Suggestions.Layout.Column = 2;
            app.search_Suggestions.Value = {};

            % Create search_nRows
            app.search_nRows = uilabel(app.Document);
            app.search_nRows.HorizontalAlignment = 'right';
            app.search_nRows.VerticalAlignment = 'bottom';
            app.search_nRows.FontColor = [0.502 0.502 0.502];
            app.search_nRows.Visible = 'off';
            app.search_nRows.Layout.Row = [1 4];
            app.search_nRows.Layout.Column = 3;
            app.search_nRows.Interpreter = 'html';
            app.search_nRows.Text = {'88 <font style="font-size: 9px; margin-right: 2px;">HOMOLOGAÇÕES</font>'; '137 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>'};

            % Create Tab2_Report
            app.Tab2_Report = uitab(app.TabGroup);
            app.Tab2_Report.AutoResizeChildren = 'off';

            % Create Tab3_Config
            app.Tab3_Config = uitab(app.TabGroup);

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {22, 74, '1x', 34, 34, 5, 34, '1x', 20, 20, 1, 20, 20};
            app.NavBar.RowHeight = {5, 7, 20, 7, 5};
            app.NavBar.ColumnSpacing = 5;
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 5 5 5];
            app.NavBar.Tag = 'COLORLOCKED';
            app.NavBar.Layout.Row = 1;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.2 0.2 0.2];

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 12;
            app.FigurePosition.ImageSource = 'Layout1.png';

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 13;
            app.AppInfo.ImageSource = 'Dots_36x36W.png';

            % Create DataHubLamp
            app.DataHubLamp = uilamp(app.NavBar);
            app.DataHubLamp.Enable = 'off';
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear pastas do Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 10;
            app.DataHubLamp.Color = [1 0 0];

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.NavBar);
            app.jsBackDoor.Tag = 'jsBackDoor';
            app.jsBackDoor.Layout.Row = 3;
            app.jsBackDoor.Layout.Column = 9;

            % Create menu_Button1
            app.menu_Button1 = uibutton(app.NavBar, 'state');
            app.menu_Button1.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button1.Tag = 'SEARCH';
            app.menu_Button1.Tooltip = {''};
            app.menu_Button1.Icon = 'Zoom_32Yellow.png';
            app.menu_Button1.IconAlignment = 'top';
            app.menu_Button1.Text = '';
            app.menu_Button1.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button1.FontSize = 11;
            app.menu_Button1.Layout.Row = [2 4];
            app.menu_Button1.Layout.Column = 4;
            app.menu_Button1.Value = true;

            % Create menu_Button2
            app.menu_Button2 = uibutton(app.NavBar, 'state');
            app.menu_Button2.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button2.Tag = 'REPORT';
            app.menu_Button2.Tooltip = {''};
            app.menu_Button2.Icon = 'Detection_32White.png';
            app.menu_Button2.IconAlignment = 'top';
            app.menu_Button2.Text = '';
            app.menu_Button2.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button2.FontSize = 11;
            app.menu_Button2.Layout.Row = [2 4];
            app.menu_Button2.Layout.Column = 5;

            % Create menu_Separator
            app.menu_Separator = uiimage(app.NavBar);
            app.menu_Separator.ScaleMethod = 'none';
            app.menu_Separator.Enable = 'off';
            app.menu_Separator.Layout.Row = [2 4];
            app.menu_Separator.Layout.Column = 6;
            app.menu_Separator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button3
            app.menu_Button3 = uibutton(app.NavBar, 'state');
            app.menu_Button3.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button3.Tag = 'CONFIG';
            app.menu_Button3.Tooltip = {''};
            app.menu_Button3.Icon = 'Settings_36White.png';
            app.menu_Button3.IconAlignment = 'top';
            app.menu_Button3.Text = '';
            app.menu_Button3.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button3.FontSize = 11;
            app.menu_Button3.Layout.Row = [2 4];
            app.menu_Button3.Layout.Column = 7;

            % Create menu_AppIcon
            app.menu_AppIcon = uiimage(app.NavBar);
            app.menu_AppIcon.Layout.Row = [1 5];
            app.menu_AppIcon.Layout.Column = 1;
            app.menu_AppIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'icon_32White.png');

            % Create menu_AppName
            app.menu_AppName = uilabel(app.NavBar);
            app.menu_AppName.WordWrap = 'on';
            app.menu_AppName.FontSize = 11;
            app.menu_AppName.FontColor = [1 1 1];
            app.menu_AppName.Layout.Row = [1 5];
            app.menu_AppName.Layout.Column = [2 3];
            app.menu_AppName.Interpreter = 'html';
            app.menu_AppName.Text = {'SCH v. 1.10.0'; '<font style="font-size: 9px;">R2024a</font>'};

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

            % Create SplashScreen
            app.SplashScreen = uiimage(app.popupContainerGrid);
            app.SplashScreen.Layout.Row = 3;
            app.SplashScreen.Layout.Column = 2;
            app.SplashScreen.ImageSource = 'SplashScreen.gif';

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
