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
        PESQUISATab                   matlab.ui.container.Tab
        search_Tab1Grid               matlab.ui.container.GridLayout
        search_WordCloudPanel         matlab.ui.container.Panel
        search_ProductInfo            matlab.ui.control.Label
        search_ProductInfoImage       matlab.ui.control.Image
        search_ToolbarWordCloud       matlab.ui.control.Image
        search_ProductInfoLabel       matlab.ui.control.Label
        CONFIGTab                     matlab.ui.container.Tab
        GridLayout2                   matlab.ui.container.GridLayout
        Toolbar                       matlab.ui.container.GridLayout
        search_ToolbarAnnotation      matlab.ui.control.Image
        search_ToolbarListOfProducts  matlab.ui.control.Image
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
        popupContainer

        % Objeto que possibilita integração com o eFiscaliza.
        eFiscalizaObj

        %-----------------------------------------------------------------%
        % PROPRIEDADES ESPECÍFICAS
        %-----------------------------------------------------------------%
        projectData

        rawDataTable
        releasedData
        cacheData
        cacheColumns

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
        %
        % • ipcMainMatlabCallAuxiliarApp
        %   Reencaminha eventos recebidos aos apps secundários, viabilizando
        %   comunicação entre apps secundários e, também, redirecionando os 
        %   eventos JS quando o app secundário é executado em modo DOCK (e, 
        %   por essa razão, usa o "jsBackDoor" do app principal).
        %
        % • ipcMainMatlabOpenPopupApp
        %   Abre um app secundário como popup, no mainApp.
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
            try
                switch event.HTMLEventName
                    % JSBACKDOOR (compCustomization.js)
                    case 'renderer'
                        if ~app.renderCount
                            startup_Controller(app)
                        else
                            % Esse fluxo será executado especificamente na
                            % versão webapp, quando o navegador atualiza a
                            % página (decorrente de F5 ou CTRL+F5).

                            closeModule(app.tabGroupController, ["PRODUCTS", "CONFIG"], app.General)

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

                    case 'BackgroundColorTurnedInvisible'
                        switch event.HTMLEventData
                            case 'SplashScreen'
                                if isvalid(app.popupContainerGrid)
                                    delete(app.popupContainerGrid)
                                end

                            otherwise
                                error('UnexpectedEvent')
                        end
                    
                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                context = event.HTMLEventData.context;
                                report_uploadInfoController(app, event.HTMLEventData, 'uploadDocument', context)

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;
    
                    case 'mainApp.search_entryPoint'
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
    
                    case 'mainApp.search_Suggestions'
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
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.search_entryPoint.UserData.id));
                                    app.search_Suggestions.Visible = "off";
                                    drawnow

                                    search_SuggestionAlgorithm(app, eventValue, false)
                                end
    
                            case 'Escape'
                                set(app.search_Suggestions, Visible=0, Value={})
                        end
    
                    otherwise
                        error('UnexpectedEvent')
                end
                drawnow

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, operationType, varargin)
            varargout = {};

            try
                switch class(callingApp)
                    % auxApp.winConfig
                    case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                        switch operationType
                            case 'closeFcn'
                                closeModule(app.tabGroupController, "CONFIG", app.General)

                            case 'dockButtonPushed'
                                auxAppTag = varargin{1};
                                varargout{1} = auxAppInputArguments(app, auxAppTag);

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
                                        refTable = app.wordCloudObj.Table;
                                        delete(app.wordCloudObj)
                    
                                        app.wordCloudObj = wordCloud(app.search_WordCloudPanel, app.General.search.wordCloud.algorithm);
                                        app.wordCloudObj.Table = refTable;
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

                        app.popupContainer.Parent.Visible = 0;

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

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = auxAppHandle(app, auxAppName);

            if ~isempty(hAuxApp)
                switch communicationType
                    case 'MATLAB'
                        operationType = varargin{1};
                        ipcSecundaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                    case 'JS'
                        event = varargin{1};
                        ipcSecundaryJSEventsHandler(hAuxApp, event)
                end
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabOpenPopupApp(app, callingApp, auxAppName, varargin)
            arguments
                app
                callingApp
                auxAppName char {mustBeMember(auxAppName, {'ReportLib', 'FilterSetup', 'ProductInfo'})}
            end

            arguments (Repeating)
                varargin 
            end

            switch auxAppName
                case 'ReportLib'
                    screenWidth  = 460;
                    screenHeight = 308;
                case 'FilterSetup'
                    screenWidth  = 412;
                    screenHeight = 464;
                case 'ProductInfo'
                    screenWidth  = 580;
                    screenHeight = 554;
            end

            ui.PopUpContainer(callingApp, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app, callingApp}, varargin];
            
            if app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName))
            else
                eval(sprintf('auxApp.dock%s_exported(callingApp.popupContainer, inputArguments{:})', auxAppName))
                callingApp.popupContainer.Parent.Visible = 1;
            end            
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
                            elToModify = { ...
                                app.popupContainerGrid, ...
                                app.search_entryPoint, ...
                                app.search_ProductInfo, ...                 % ui.TextView
                                app.search_ProductInfoImage, ...            % ui.TextView (Background image)
                                app.search_Suggestions ...
                            };
                            ui.CustomizationBase.getElementsDataTag(elToModify);

                            appName = class(app);
                            if isvalid(app.popupContainerGrid)
                                try
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {struct('appName', appName, 'dataTag', elToModify{1}.UserData.id, 'style', struct('backgroundColor', 'rgba(255,255,255,0.65)'))});
                                catch
                                end
                            end

                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elToModify{2}.UserData.id, 'generation', 1, 'style',    struct('borderWidth', '0')), ...
                                    struct('appName', appName, 'dataTag', elToModify{2}.UserData.id, 'generation', 2, 'listener', struct('componentName', 'mainApp.search_entryPoint', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                                });
                            catch
                            end

                            try
                                ui.TextView.startup(app.jsBackDoor, elToModify{3}, appName);
                            catch
                            end

                            try
                                ui.TextView.startup(app.jsBackDoor, elToModify{4}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                            catch
                            end
                            
                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elToModify{5}.UserData.id, 'generation', 1, 'listener', struct('componentName', 'mainApp.search_Suggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                                });
                            catch
                            end

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

                % webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                % webWin.openDevTools();
                % pause(3)

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
                parpoolCheck()
    
                % Por fim, exclui-se o splashscreen, um segundo após envio do comando 
                % para que diminua a transparência do background.
                sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
                drawnow
            
                pause(1)
                if isvalid(app.popupContainerGrid)
                    delete(app.popupContainerGrid)
                end

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

            app.General_I.ui.searchTable       = struct2table(app.General_I.ui.searchTable);

            switch app.executionMode
                case 'webApp'
                    % Força a exclusão do SplashScreen do MATLAB WebDesigner.
                    sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");

                    app.General_I.operationMode.Debug = false;
                    app.General_I.operationMode.Dock  = true;

                    % A pasta do usuário não é configurável, mas obtida por
                    % meio de chamada a uiputfile.
                    app.General_I.fileFolder.userPath = tempDir;

                    % Wordcloud built-in do MATLAB é incompatível com webapps.
                    if ~strcmp(app.General_I.search.wordCloud.algorithm, 'D3.js')
                        app.General_I.search.wordCloud.algorithm = 'D3.js';
                    end

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

            app.General            = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.projectData = projectLib(app, app.General.ui.typeOfProduct.options, app.General.ui.typeOfSituation.options, app.General.ui.typeOfViolation.options);
            startup_mainVariables(app)
        end

        %-----------------------------------------------------------------%
        function startup_mainVariables(app)
            [app.rawDataTable, ...
             app.releasedData, ...
             app.cacheData,    ...
             app.cacheColumns]  = util.readExternalFile.SCHData(app.rootFolder, app.General.fileFolder.DataHub_GET);
            app.annotationTable = util.readExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_GET);
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            % Cria o objeto que conecta o TabGroup com o GraphicMenu.
            app.tabGroupController = tabGroupGraphicMenu(app.NavBar, app.TabGroup, app.progressDialog, @app.jsBackDoor_AppCustomizations, '');

            addComponent(app.tabGroupController, "Built-in", "mainApp",            app.menu_Button1, "AlwaysOn", struct('On', 'Zoom_32Yellow.png',      'Off', 'Zoom_32White.png'),      matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.menu_Button2, "AlwaysOn", struct('On', 'Detection_32Yellow.png', 'Off', 'Detection_32White.png'), matlab.graphics.GraphicsPlaceholder, 2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.menu_Button3, "AlwaysOn", struct('On', 'Settings_36Yellow.png',  'Off', 'Settings_36White.png'),  app.menu_Button1,                    3)

            % Salva na propriedade "UserData" as opções de ícone e o índice
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.search_ToolbarWordCloud.UserData      = false;

            % Inicialização da propriedade "UserData" da tabela.
            app.search_entryPointImage.UserData       = struct('value2Search', '', 'words2Search', '');
            app.search_Table.UserData                 = struct('primaryIndex', [], 'secundaryIndex', [], 'cacheColumns', {{}});
            app.search_Table.RowName                  = 'numbered';

            % Os painéis de metadados do registro selecionado nas tabelas já 
            % tem, na sua propriedade "UserData", a chave "id" que armazena 
            % o "data-tag" que identifica o componente no código HTML. 
            % Adicionam-se duas novas chaves: "showedRow" e "showedHom".
            app.search_ProductInfo.UserData.selectedRow = [];
            app.search_ProductInfo.UserData.showedHom   = '';

            search_EntryPoint_Layout(app)

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
        % MÓDULO "SEARCH"
        %-----------------------------------------------------------------%   
        function search_SuggestionAlgorithm(app, eventValue, panelVisibility)
            value2Search = textAnalysis.preProcessedData(eventValue, false);
            search_EntryPointImage_Status(app, value2Search)

            if strcmp(app.General.search.mode, 'tokens')
                if numel(value2Search) >= app.General.search.minCharacters
                    [similarStrings, idxFiltered, redFontFlag] = util.getSimilarStrings(app.cacheData, value2Search, app.General.search.minDisplayedTokens);

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
                1, 'VariableNames', util.readExternalFile.annotationColumns);

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
            [app.annotationTable, msgWarning] = util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end

            % Atualizando o painel com os metadados do registro selecionado...
            relatedAnnotationTable   = search_Annotation_RelatedTable(app, showedHom);
            htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, relatedAnnotationTable);
            misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow, showedHom);

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
            switch app.General.search.mode
                case 'tokens'
                    sortOrder = 'stable';
                otherwise
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
            misc_Table_NumberOfRows(app)
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
            misc_Table_NumberOfRows(app)
            search_Table_InitialSelection(app, false)

            % Aplica estilo na tabela...
            search_Table_AddStyle(app)
        end

        %-----------------------------------------------------------------%
        function search_SuggestionPanel_InitialValues(app)
            set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
        end

        %-----------------------------------------------------------------%
        function search_EntryPoint_Layout(app)
            switch app.General.search.mode
                case 'tokens'
                    app.search_entryPointPanel.Layout.Column = 1;
                otherwise
                    app.search_entryPointPanel.Layout.Column = [1, 2];
    
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

                if ~app.GridLayout_2.ColumnWidth{1}
                    misc_Panel_VisibilityImageClicked(app, struct('Source', app.search_leftPanelVisibility))
                end
            end
        end

        %-----------------------------------------------------------------%
        function search_FilterSpecification(app)
            listOfColumns = app.cacheColumns;
            primaryTag    = sprintf('Filtragem primária orientada à(s) coluna(s) %s', textFormatGUI.cellstr2ListWithQuotes(listOfColumns, 'none'));
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
                    staticLogical  = logical(app.General.ui.searchTable.columnPosition);
                    staticIndex    = app.General.ui.searchTable.columnPosition(staticLogical);
                    [~, idxOrder]  = sort(staticIndex);
                    columnList     = app.General.ui.searchTable.name(staticLogical);
                    columnInfo     = columnList(idxOrder);

                case 'visibleColumns'
                    visibleLogical = logical(app.General.ui.searchTable.visible);
                    columnInfo     = app.General.ui.searchTable.name(visibleLogical);

                case 'allColumns'
                    columnInfo     = app.General.ui.searchTable.name;

                case 'allColumnsWidths'
                    columnInfo     = app.General.ui.searchTable.columnWidth;
            end
        end

        %-----------------------------------------------------------------%
        function cacheColumns = search_Table_PrimaryColumnNames(app)
            cacheColumns = strsplit(app.cacheColumns, ' | ');
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
                app.search_Table.Selection    = [1, 1];
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

            % Table annotation icon
            search_Table_AnnotationIcon(app)
            drawnow
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
                s = class.Constants.configStyle4;
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
        function [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app)
            if ~isempty(app.search_Table.Selection)
                selectedRow = unique(app.search_Table.Selection(:,1));
                selectedHom = unique(app.search_Table.Data.("Homologação")(selectedRow), 'stable');
            else
                selectedRow = [];
                selectedHom = {};
            end

            showedHom = app.search_ProductInfo.UserData.showedHom;
        end

        %-----------------------------------------------------------------%
        function misc_Table_NumberOfRows(app)
            nHom  = numel(unique(app.search_Table.Data.("Homologação")));
            nRows = height(app.search_Table.Data);
            app.search_nRows.Text = sprintf('%d <font style="font-size: 9px; margin-right: 2px;">HOMOLOGAÇÕES</font>\n%d <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>', nHom, nRows);
        end

        %-----------------------------------------------------------------%
        function htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable)
            if isempty(selected2showedHom)
                htmlSource = '';
            else
                selectedHomRawTableIndex = find(strcmp(app.rawDataTable.("Homologação"), selected2showedHom));
                htmlSource = util.HtmlTextGenerator.RowTableInfo('ProdutoHomologado', app.rawDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable);
            end
        end

        %-----------------------------------------------------------------%
        function misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow, selected2showedHom)
            userData = struct('selectedRow', selectedRow, 'showedHom', selected2showedHom);
            ui.TextView.update(app.search_ProductInfo, htmlSource, userData, app.search_ProductInfoImage);
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


    methods (Access = private)
        %-----------------------------------------------------------------%
        % TABGROUPCONTROLLER
        %-----------------------------------------------------------------%
        function hAuxApp = auxAppHandle(app, auxAppName)
            arguments
                app
                auxAppName string {mustBeMember(auxAppName, ["PRODUCTS", "CONFIG"])}
            end

            hAuxApp = app.tabGroupController.Components.appHandle{app.tabGroupController.Components.Tag == auxAppName};
        end

        %-----------------------------------------------------------------%
        function inputArguments = auxAppInputArguments(app, auxAppName)
            arguments
                app
                auxAppName char {mustBeMember(auxAppName, {'SEARCH', 'PRODUCTS', 'CONFIG'})}
            end
            
            [auxAppIsOpen, ...
             auxAppHandle] = checkStatusModule(app.tabGroupController, auxAppName);

            inputArguments = {app};

            switch auxAppName
                case 'ECD'
                    if auxAppIsOpen
                        % ...
                    end
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

                app.GridLayout_2.ColumnWidth(1:2) = {0,0};
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

                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            % Aspectos gerais (comum em todos os apps):
            appUtil.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)

        end

        % Callback function: UIFigure, search_Table
        function UIFigureWindowButtonDown(app, event)

            % O listener que captura cliques do mouse só é aplicável no
            % modo SEARCH.
            if app.TabGroup.SelectedTab ~= app.TabGroup.Children(1)
                return
            end

            event = struct(event);
            if isfield(event, 'HitObject')
                hitObject = event.HitObject;
            else
                hitObject = event.Source;
            end

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

                    ipcMainJSEventsHandler(app, struct('HTMLEventName', 'mainApp.search_Suggestions', 'HTMLEventData', 'Enter'))

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
            auxAppTag      = clickedButton.Tag;

            inputArguments = auxAppInputArguments(app, auxAppTag);
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
                        app.AppInfo.Tag = util.HtmlTextGenerator.AppInfo( ...
                            app.General, ...
                            app.rootFolder, ...
                            app.executionMode, ...
                            app.renderCount, ...
                            app.rawDataTable, ...
                            app.releasedData, ...
                            app.cacheData, ...
                            app.annotationTable, ...
                            'popup' ...
                        );
                        app.progressDialog.Visible = 'hidden';
                    end

                    msgInfo = app.AppInfo.Tag;
                    appUtil.modalWindow(app.UIFigure, 'info', msgInfo);
            end

        end

        % Image clicked function: search_entryPointImage
        function search_EntryPoint_ImageClicked(app, event)
            
            value2Search = textAnalysis.preProcessedData(app.search_entryPoint.Value, false);

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

        % Value changing function: search_entryPoint
        function search_EntryPoint_ValueChanging(app, event)

            search_SuggestionAlgorithm(app, event.Value, true)
            
        end

        % Image clicked function: search_leftPanelVisibility
        function misc_Panel_VisibilityImageClicked(app, event)
            
            if app.GridLayout_2.ColumnWidth{1}
                app.GridLayout_2.ColumnWidth(1:2) = {0, 0};
                app.TabGroup_2.Visible = "off";
                app.search_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';                     
            else
                app.GridLayout_2.ColumnWidth(1:2) = {10, 320};
                app.TabGroup_2.Visible = "on";
                app.search_leftPanelVisibility.ImageSource = 'ArrowLeft_32.png';                        
            end

        end

        % Image clicked function: search_FilterSetup
        function search_FilterSetupClicked(app, event)
            
            switch event.Source
                case app.search_FilterSetup
                    ipcMainMatlabOpenPopupApp(app, app, 'FilterSetup')

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

                    ipcMainMatlabOpenPopupApp(app, app, 'ProductInfo')
            end

        end

        % Image clicked function: search_ExportTable
        function search_ExportTableImageClicked(app, event)
            
            nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
            defaultName   = appUtil.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
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

        % Selection changed function: search_Table
        function search_Table_SelectionChanged(app, event)
            
            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app);

            if ~isempty(selectedHom)
                if ~ismember(showedHom, selectedHom)
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow(1), selected2showedHom)

                    % Apresenta a nuvem de palavras apenas se visível...
                    if app.search_ToolbarWordCloud.UserData
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
                misc_SelectedHomPanel_InfoUpdate(app, htmlSource, [], '')

                if ~isempty(app.wordCloudObj) && ~isempty(app.search_WordCloudPanel.Tag)
                    app.wordCloudObj.Table        = [];
                    app.search_WordCloudPanel.Tag = '';
                end

                app.search_ToolbarAnnotation.Enable     = 0;
                app.search_ToolbarWordCloud.Enable      = 0;
                app.search_ToolbarListOfProducts.Enable = 0;
            end

        end

        % Image clicked function: search_ToolbarWordCloud
        function search_ToolbarWordCloudImageClicked(app, event)
            
            app.search_ToolbarWordCloud.UserData = ~app.search_ToolbarWordCloud.UserData;
    
            if app.search_ToolbarWordCloud.UserData
                % O "drawnow nocallbacks" aqui é ESSENCIAL porque o
                % MATLAB precisa renderizar em tela o container do
                % WordCloud (um objeto uihtml).
                app.search_Tab1Grid.RowHeight{3} = 150;
                drawnow
    
                selectedRow = app.search_ProductInfo.UserData.selectedRow;
                showedHom   = app.search_ProductInfo.UserData.showedHom;
                relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);
    
                if search_WordCloud_CheckCache(app, showedHom, relatedAnnotationTable)
                    search_WordCloud_PlotUpdate(app, selectedRow, showedHom, false);
                end
    
            else
                app.search_Tab1Grid.RowHeight{3} = 0;
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
            app.Toolbar.ColumnWidth = {22, 22, 22, '1x', 22, 22};
            app.Toolbar.RowHeight = {4, 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];

            % Create search_leftPanelVisibility
            app.search_leftPanelVisibility = uiimage(app.Toolbar);
            app.search_leftPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.search_leftPanelVisibility.Enable = 'off';
            app.search_leftPanelVisibility.Layout.Row = 2;
            app.search_leftPanelVisibility.Layout.Column = 1;
            app.search_leftPanelVisibility.ImageSource = 'ArrowRight_32.png';

            % Create search_FilterSetup
            app.search_FilterSetup = uiimage(app.Toolbar);
            app.search_FilterSetup.ScaleMethod = 'none';
            app.search_FilterSetup.ImageClickedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.search_FilterSetup.Enable = 'off';
            app.search_FilterSetup.Tooltip = {'Edita filtragem secundária'};
            app.search_FilterSetup.Layout.Row = [1 3];
            app.search_FilterSetup.Layout.Column = 2;
            app.search_FilterSetup.ImageSource = 'Filter_18x18.png';

            % Create search_ExportTable
            app.search_ExportTable = uiimage(app.Toolbar);
            app.search_ExportTable.ScaleMethod = 'none';
            app.search_ExportTable.ImageClickedFcn = createCallbackFcn(app, @search_ExportTableImageClicked, true);
            app.search_ExportTable.Enable = 'off';
            app.search_ExportTable.Tooltip = {'Exporta resultados de busca em arquivo XLSX'};
            app.search_ExportTable.Layout.Row = 2;
            app.search_ExportTable.Layout.Column = 3;
            app.search_ExportTable.ImageSource = 'Export_16.png';

            % Create search_ToolbarListOfProducts
            app.search_ToolbarListOfProducts = uiimage(app.Toolbar);
            app.search_ToolbarListOfProducts.Tooltip = {'Adiciona à cesta de produtos sob análise'};
            app.search_ToolbarListOfProducts.Layout.Row = [1 3];
            app.search_ToolbarListOfProducts.Layout.Column = 6;
            app.search_ToolbarListOfProducts.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Box_32.png');

            % Create search_ToolbarAnnotation
            app.search_ToolbarAnnotation = uiimage(app.Toolbar);
            app.search_ToolbarAnnotation.ScaleMethod = 'none';
            app.search_ToolbarAnnotation.Enable = 'off';
            app.search_ToolbarAnnotation.Tooltip = {'Anotação textual'};
            app.search_ToolbarAnnotation.Layout.Row = 2;
            app.search_ToolbarAnnotation.Layout.Column = 5;
            app.search_ToolbarAnnotation.VerticalAlignment = 'bottom';
            app.search_ToolbarAnnotation.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Variable_edit_16.png');

            % Create TabGroup_2
            app.TabGroup_2 = uitabgroup(app.GridLayout_2);
            app.TabGroup_2.AutoResizeChildren = 'off';
            app.TabGroup_2.Layout.Row = [3 4];
            app.TabGroup_2.Layout.Column = 2;

            % Create PESQUISATab
            app.PESQUISATab = uitab(app.TabGroup_2);
            app.PESQUISATab.AutoResizeChildren = 'off';
            app.PESQUISATab.Title = 'PESQUISA';

            % Create search_Tab1Grid
            app.search_Tab1Grid = uigridlayout(app.PESQUISATab);
            app.search_Tab1Grid.ColumnWidth = {'1x', 18};
            app.search_Tab1Grid.RowHeight = {17, '1x', 0};
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

            % Create search_ToolbarWordCloud
            app.search_ToolbarWordCloud = uiimage(app.search_Tab1Grid);
            app.search_ToolbarWordCloud.ImageClickedFcn = createCallbackFcn(app, @search_ToolbarWordCloudImageClicked, true);
            app.search_ToolbarWordCloud.Enable = 'off';
            app.search_ToolbarWordCloud.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.search_ToolbarWordCloud.Layout.Row = 1;
            app.search_ToolbarWordCloud.Layout.Column = 2;
            app.search_ToolbarWordCloud.VerticalAlignment = 'bottom';
            app.search_ToolbarWordCloud.ImageSource = 'Cloud_32x32Gray.png';

            % Create search_ProductInfoImage
            app.search_ProductInfoImage = uiimage(app.search_Tab1Grid);
            app.search_ProductInfoImage.ScaleMethod = 'none';
            app.search_ProductInfoImage.Layout.Row = 2;
            app.search_ProductInfoImage.Layout.Column = [1 2];
            app.search_ProductInfoImage.ImageSource = 'warning.svg';

            % Create search_ProductInfo
            app.search_ProductInfo = uilabel(app.search_Tab1Grid);
            app.search_ProductInfo.VerticalAlignment = 'top';
            app.search_ProductInfo.WordWrap = 'on';
            app.search_ProductInfo.FontSize = 11;
            app.search_ProductInfo.Layout.Row = 2;
            app.search_ProductInfo.Layout.Column = [1 2];
            app.search_ProductInfo.Interpreter = 'html';
            app.search_ProductInfo.Text = '';

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.search_Tab1Grid);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = 3;
            app.search_WordCloudPanel.Layout.Column = [1 2];

            % Create CONFIGTab
            app.CONFIGTab = uitab(app.TabGroup_2);
            app.CONFIGTab.Title = 'CONFIG';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.CONFIGTab);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {17, 22, 22, 22};
            app.GridLayout2.ColumnSpacing = 5;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create Document
            app.Document = uigridlayout(app.GridLayout_2);
            app.Document.ColumnWidth = {412, '1x'};
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
            app.search_Table.RowStriping = 'off';
            app.search_Table.ClickedFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.search_Table.SelectionChangedFcn = createCallbackFcn(app, @search_Table_SelectionChanged, true);
            app.search_Table.Visible = 'off';
            app.search_Table.Layout.Row = [5 6];
            app.search_Table.Layout.Column = [1 2];
            app.search_Table.FontSize = 10;

            % Create search_entryPointPanel
            app.search_entryPointPanel = uipanel(app.Document);
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
            app.search_entryPoint.BusyAction = 'cancel';
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
            app.search_Metadata = uilabel(app.Document);
            app.search_Metadata.VerticalAlignment = 'top';
            app.search_Metadata.WordWrap = 'on';
            app.search_Metadata.FontSize = 14;
            app.search_Metadata.Visible = 'off';
            app.search_Metadata.Layout.Row = 4;
            app.search_Metadata.Layout.Column = [1 2];
            app.search_Metadata.Interpreter = 'html';
            app.search_Metadata.Text = {'Exibindo resultados para "<b>apple iphone</b>"'; '<p style="color: #808080; font-size:10px;">Filtragem primária: Homologação<br>Filtragem secundária: []</p>'};

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.Document);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = [2 5];
            app.search_Suggestions.Layout.Column = 1;
            app.search_Suggestions.Value = {};

            % Create search_nRows
            app.search_nRows = uilabel(app.Document);
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
            app.menu_Button2.Tag = 'PRODUCTS';
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
