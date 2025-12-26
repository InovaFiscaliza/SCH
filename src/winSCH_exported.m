classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        NavBar                        matlab.ui.container.GridLayout
        AppInfo                       matlab.ui.control.Image
        FigurePosition                matlab.ui.control.Image
        DataHubLamp                   matlab.ui.control.Lamp
        Tab3Button                    matlab.ui.control.StateButton
        ButtonsSeparator              matlab.ui.control.Image
        Tab2Button                    matlab.ui.control.StateButton
        Tab1Button                    matlab.ui.control.StateButton
        AppName                       matlab.ui.control.Label
        AppIcon                       matlab.ui.control.Image
        TabGroup                      matlab.ui.container.TabGroup
        Tab1_Search                   matlab.ui.container.Tab
        Grid1                         matlab.ui.container.GridLayout
        PopupTempWarning              matlab.ui.control.Label
        Document                      matlab.ui.container.GridLayout
        search_Suggestions            matlab.ui.control.ListBox
        search_Table                  matlab.ui.control.Table
        search_nRows                  matlab.ui.control.Label
        search_words2Search           matlab.ui.control.Label
        search_entryPointPanel        matlab.ui.container.Panel
        search_entryPointGrid         matlab.ui.container.GridLayout
        search_entryPointImage        matlab.ui.control.Image
        search_entryPoint             matlab.ui.control.EditField
        SubTabGroup                   matlab.ui.container.TabGroup
        SubTab1_Search                matlab.ui.container.Tab
        SubGrid1                      matlab.ui.container.GridLayout
        jsBackDoor                    matlab.ui.control.HTML
        search_WordCloudPanel         matlab.ui.container.Panel
        search_ProductInfo            matlab.ui.control.Label
        search_ProductInfoImage       matlab.ui.control.Image
        search_ToolbarWordCloud       matlab.ui.control.Image
        search_ProductInfoLabel       matlab.ui.control.Label
        SubTab2_Filter                matlab.ui.container.Tab
        SubGrid2                      matlab.ui.container.GridLayout
        SecondaryPanelLabel           matlab.ui.control.Label
        LocationEditionMode           matlab.ui.control.Image
        LocationEditionConfirm        matlab.ui.control.Image
        LocationEditionCancel         matlab.ui.control.Image
        SecondaryListOfFilters        matlab.ui.control.ListBox
        SecondaryPanel                matlab.ui.container.Panel
        SecondaryGrid                 matlab.ui.container.GridLayout
        SecondaryTextListValue        matlab.ui.control.DropDown
        SecondaryTextFreeValue        matlab.ui.control.EditField
        SecondaryDateTime2            matlab.ui.control.EditField
        SecondaryDateTimeSeparator    matlab.ui.control.Label
        SecondaryDateTime1            matlab.ui.control.EditField
        SecondaryOperation            matlab.ui.control.DropDown
        SecondaryColumn               matlab.ui.control.DropDown
        ESTRATGIADEFILTRAGEMDropDown  matlab.ui.control.DropDown
        ESTRATGIADEFILTRAGEMDropDownLabel  matlab.ui.control.Label
        Toolbar                       matlab.ui.container.GridLayout
        tool_FilterIcon               matlab.ui.control.Image
        tool_FilterInfo               matlab.ui.control.Label
        tool_AddSelectedToBucket      matlab.ui.control.Image
        tool_Separator                matlab.ui.control.Image
        tool_ExportVisibleTable       matlab.ui.control.Image
        tool_AddAnnotationToSelected  matlab.ui.control.Image
        tool_PanelVisibility          matlab.ui.control.Image
        Tab2_Report                   matlab.ui.container.Tab
        Tab3_Config                   matlab.ui.container.Tab
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder
        tabGroupController
        renderCount = 0

        executionMode
        progressDialog
        popupContainer

        eFiscalizaObj
        filteringObj = tableFiltering
        wordCloudObj

        projectData
        
        rawDataTable
        releasedData
        cacheData
        cacheColumns
        annotationTable

        previousSearch   = ''
        previousItemData = 0
    end


    methods (Access = public)
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
                    % MATLAB-JS BRIDGE (matlabJSBridge.js)
                    case 'renderer'
                        MFilePath   = fileparts(mfilename('fullpath'));
                        parpoolFlag = true;

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        else
                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        end
                        
                        app.renderCount = app.renderCount+1;
    
                    case 'unload'
                        closeFcn(app)

                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                context = event.HTMLEventData.context;
                                report_uploadInfoController(app, event.HTMLEventData, 'uploadDocument', context)

                            case 'eFiscalizaSignInPage:IssueQuery'
                                error('Pendente de implementação!')
                                context = event.HTMLEventData.context;
                                report_queryIssueDetails(app, event.HTMLEventData, context)

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end

                            case 'onProjectSave'
                                error('Pendente de implementação!')
                                context = event.HTMLEventData.context;
                                prjName = event.HTMLEventData.projectName;
                                report_saveProject(app, context, prjName)
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;
    
                    case 'mainApp.search_entryPoint'
                        focus(app.jsBackDoor)
                        matlab.waitfor(app.search_entryPoint, 'Value', @(propValue) strcmp(propValue, app.previousSearch), .100, 1, 'propValue')
    
                        switch event.HTMLEventData
                            case {'Escape', 'Tab'}
                                if numel(app.search_entryPoint.Value) < app.General.search.minCharacters
                                    search_EntryPoint_InitialValue(app)
                                end
    
                                if strcmp(event.HTMLEventData, 'Tab') && app.search_entryPointImage.Enable
                                    focus(app.search_entryPointImage)
                                end
    
                                pause(.050)
                                set(app.search_Suggestions, Visible=0, Value={})
    
                            otherwise
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
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
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
                                context = varargin{1};
                                closeModule(app.tabGroupController, context, app.General)

                            case 'dockButtonPushed'
                                context = varargin{1};
                                varargout{1} = auxAppInputArguments(app, context);

                            case 'updateDataHubGetFolder'
                                app.progressDialog.Visible = 'visible';
                                startup_mainVariables(app)
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
                                    onAlgorithmValueChanged(app.wordCloudObj, app.General.search.wordCloud.algorithm);
                                end

                            case 'searchVisibleColumnsChanged'
                                [columnNames, columnWidth] = search_Table_ColumnNames(app);
                                set(app.search_Table, 'ColumnName', upper(columnNames), 'ColumnWidth', columnWidth)
                    
                                if ~isempty(app.search_Table.Data)
                                    if (numel(columnNames) ~= width(app.search_Table.Data)) || any(~ismember(app.search_Table.ColumnName, upper(columnNames)))
                                        secondaryIndex = app.search_Table.UserData.secondaryIndex;
                                        app.search_Table.Data = app.rawDataTable(secondaryIndex, columnNames);
                                    end
                                end

                            otherwise
                                error('UnexpectedCall')
                        end

                    % auxApp.winProducts
                    case {'auxApp.winProducts', 'auxApp.winProducts_exported'}
                        switch operationType
                            case 'closeFcn'
                                context = varargin{1};
                                closeModule(app.tabGroupController, context, app.General)

                            case 'dockButtonPushed'
                                context = varargin{1};
                                varargout{1} = auxAppInputArguments(app, context);

                            otherwise
                                error('UnexpectedCall')
                        end

                    % DOCKS:OTHERS
                    case {'auxApp.dockProductInfo', 'auxApp.dockProductInfo_exported'}
                        switch operationType
                            case 'closeFcn'
                                context  = varargin{1};
                                varargin = [{'closeFcnCallFromDockModule'}, varargin(2:end)];
                                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})

                            case {'TableSelectionChanged', 'TableCellEdit'}
                                context  = varargin{1};
                                varargin = [{operationType}, varargin(2:end)];
                                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})
                                return

                            otherwise
                                error('UnexpectedCall')
                        end

                    otherwise
                        error('UnexpectedCall')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            % Caso um app auxiliar esteja em modo DOCK, o progressDialog do
            % app auxiliar coincide com o do SCH. Força-se, portanto, a condição
            % abaixo para evitar possível bloqueio da tela.
            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = getAppHandle(app.tabGroupController, auxAppName);

            if ~isempty(hAuxApp)
                switch communicationType
                    case 'MATLAB'
                        operationType = varargin{1};
                        ipcSecondaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                    case 'JS'
                        event = varargin{1};
                        ipcSecondaryJSEventsHandler(hAuxApp, event)
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
                    screenHeight = 660;
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


    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            tabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
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
                            elToModify = {
                                app.search_entryPoint;
                                app.search_ProductInfo;                     % ui.TextView
                                app.search_ProductInfoImage;                % ui.TextView (Background image)
                                app.search_Suggestions;
                                app.PopupTempWarning;
                                app.search_WordCloudPanel
                            };
                            ui.CustomizationBase.getElementsDataTag(elToModify);

                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elToModify{1}.UserData.id, 'generation', 1, 'style',    struct('borderWidth', '0')), ...
                                    struct('appName', appName, 'dataTag', elToModify{1}.UserData.id, 'generation', 2, 'listener', struct('componentName', 'mainApp.search_entryPoint', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                                });
                            catch
                            end

                            try
                                ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName);
                            catch
                            end

                            try
                                ui.TextView.startup(app.jsBackDoor, elToModify{3}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                            catch
                            end
                            
                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elToModify{4}.UserData.id, 'generation', 1, 'style',    struct('borderTop', '0')), ...
                                    struct('appName', appName, 'dataTag', elToModify{4}.UserData.id, 'generation', 1, 'listener', struct('componentName', 'mainApp.search_Suggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                                });
                            catch
                            end

                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elToModify{5}.UserData.id, 'generation', 0, 'style',    struct('borderRadius', '5px', 'pointerEvents', 'none')) ...
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

        %-----------------------------------------------------------------%
        function loadConfigurationFile(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appEngine.util.generalSettingsLoad(appName, app.rootFolder, {'Annotation.xlsx'});
            if ~isempty(msgWarning)
                ui.Dialog(app.UIFigure, 'error', msgWarning);
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
                    userPaths = appEngine.util.UserPaths(app.General_I.fileFolder.userPath);
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
        function initializeAppProperties(app)
            app.projectData = model.projectLib(app, app.rootFolder);
            startup_mainVariables(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog, @app.applyJSCustomizations, '');
            addComponent(app.tabGroupController, "Built-in", "",                   app.Tab1Button, "AlwaysOn", struct('On', 'Zoom_32Yellow.png',      'Off', 'Zoom_32White.png'),      matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.Tab2Button, "AlwaysOn", struct('On', 'Detection_32Yellow.png', 'Off', 'Detection_32White.png'), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.Tab3Button, "AlwaysOn", struct('On', 'Settings_36Yellow.png',  'Off', 'Settings_36White.png'),  app.Tab1Button,                      3)

            % Salva na propriedade "UserData" as opções de ícone e o índice
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.search_ToolbarWordCloud.UserData      = false;

            % Inicialização da propriedade "UserData" da tabela.
            app.search_entryPointImage.UserData       = struct('value2Search', '', 'words2Search', '');
            app.search_Table.UserData                 = struct('primaryIndex', [], 'secondaryIndex', [], 'cacheColumns', {{}});
            app.search_Table.RowName                  = 'numbered';

            % Os painéis de metadados do registro selecionado nas tabelas já 
            % tem, na sua propriedade "UserData", a chave "id" que armazena 
            % o "data-tag" que identifica o componente no código HTML. 
            % Adicionam-se duas novas chaves: "showedRow" e "showedHom".
            app.search_ProductInfo.UserData.selectedRow = [];
            app.search_ProductInfo.UserData.showedHom   = '';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            DataHubWarningLamp(app)

            search_EntryPoint_Layout(app)
            updateFilterSpecificationToolbar(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function startup_mainVariables(app)
            [app.rawDataTable, ...
             app.releasedData, ...
             app.cacheData,    ...
             app.cacheColumns]  = util.readExternalFile.SCHData(app.rootFolder, app.General.fileFolder.DataHub_GET, app.General);
            app.annotationTable = util.readExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_GET);
        end

        %-----------------------------------------------------------------%
        function DataHubWarningLamp(app)
            if isfolder(app.General.fileFolder.DataHub_GET) && isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end

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
                {appEngine.util.OperationSystem('computerName')}, ...
                {appEngine.util.OperationSystem('userName')},     ...
                {showedHom},                                   ...
                {attributeName},                               ...
                {attributeValue},                              ...
                1, 'VariableNames', util.readExternalFile.annotationColumns);

            idx1 = find(strcmp(app.annotationTable.("Homologação"), showedHom))';
            if isempty(idx1) || wourdCloudRefreshTag
                app.annotationTable(end+1,:) = newRowTable;

            else
                if any(strcmp(app.annotationTable.("Atributo")(idx1), attributeName) & strcmp(app.annotationTable.("Valor")(idx1), attributeValue))
                    ui.Dialog(app.UIFigure, 'warning', sprintf('Conjunto atributo/valor já consta como anotação do registro %s.', showedHom));
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
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
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
                'UserData',  struct('primaryIndex', primaryIndex, 'secondaryIndex', primaryIndex, 'cacheColumns', {cacheColumnNames}))

            % Cria chart para a nuvem de palavras...
            if isempty(app.wordCloudObj)
                app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.search_WordCloudPanel, app.General.search.wordCloud.algorithm);
            end

            % Renderiza em tela o número de linhas, além de selecionar a primeira
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app)
            search_Table_InitialSelection(app, true)

            % Aplica estilo na tabela e verifica se a tabela está visível...
            search_Table_AddStyle(app)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function search_Filtering_secondaryFilter(app)
            primaryIndex = app.search_Table.UserData.primaryIndex;
            GUIColumns   = search_Table_ColumnNames(app);

            if ~isempty(app.filteringObj.filterRules)
                logicalArray   = run(app.filteringObj, 'filterRules', app.rawDataTable(primaryIndex,:));
                secondaryIndex = primaryIndex(logicalArray);
            else
                secondaryIndex = primaryIndex;
            end

            app.search_Table.Data = app.rawDataTable(secondaryIndex, GUIColumns);
            app.search_Table.UserData.secondaryIndex = secondaryIndex;

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
        function search_FilterSpecification(app)
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
                            searchNote = ' E SIMILARES';
                        else
                            searchNote = '';
                        end
    
                        app.search_words2Search.Text = sprintf('EXIBINDO RESULTADOS PARA "<b>%s</b>"%s', upper(value2Search), searchNote);
                        updateFilterSpecificationToolbar(app)
                    end

                otherwise
                    if ~isempty(words2Search)
                        app.search_words2Search.Text = sprintf('Exibindo resultados para %s', strjoin("""<b>" + string(words2Search) + "</b>""", ', '));
                        updateFilterSpecificationToolbar(app)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function updateFilterSpecificationToolbar(app)
            primaryTag   = sprintf('Filtragem primária orientada à(s) coluna(s) %s', textFormatGUI.cellstr2ListWithQuotes(search_Table_PrimaryColumnNames(app), 'none'));
            secondaryTag = strjoin(getFilterList(app.filteringObj, 'SCH', 'on'), ', ');
            if isempty(secondaryTag)
                secondaryTag = '[]';
            end

            app.tool_FilterInfo.Text = sprintf('%s\nFiltragem secundária: %s', primaryTag, secondaryTag);
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
                app.tool_ExportVisibleTable.Enable = 0;
            else
                app.search_Table.Selection    = [1, 1];
                app.tool_ExportVisibleTable.Enable = 1;
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
                    ui.Dialog(app.UIFigure, 'warning', ME.identifier);

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
                    ui.Dialog(app.UIFigure, 'warning', sprintf('O registro %s não possui cadastrado "%s". Dessa forma, consulta à internet foi realizada usando o seu "%s".', showedHom, listOfColumns{idx1}, listOfColumns{idx2}));
                end
            end
        end

        %-----------------------------------------------------------------%
        function [selectedHom, showedHom, selectedRows] = misc_Table_SelectedRow(app)
            if ~isempty(app.search_Table.Selection)
                selectedRows = unique(app.search_Table.Selection(:,1));
                selectedHom  = unique(app.search_Table.Data.("Homologação")(selectedRows), 'stable');
            else
                selectedRows = [];
                selectedHom  = {};
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
                htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoHomologado', app.rawDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable, app.projectData.regulatronData);
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

            ui.Dialog(app.UIFigure, modalWindowIcon, modalWindowMessage);
            app.progressDialog.Visible = 'hidden';
        end

        %------------------------------------------------------------------------%
        function report_sendJSONFileToSharepoint(app)
            JSONFile = app.projectData.generatedFiles.lastTableFullPath;            
            [status, msg] = copyfile(JSONFile, app.General.fileFolder.DataHub_POST, 'f');

            if ~status
                ui.Dialog(app.UIFigure, 'error', msg);
            end
        end

        %-----------------------------------------------------------------------%
        function showPopupTempWarning(app, msg)
            app.tool_AddSelectedToBucket.Enable = "off";
            set(app.PopupTempWarning, 'Text', msg, 'Visible', 'on')
            sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'PopupTempWarning', 'componentDataTag', app.PopupTempWarning.UserData.id, 'interval_ms', 75));
            drawnow
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
                appEngine.boot(app, app.Role)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
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
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
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
        
                    userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        return
                    end
                end

                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
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
                        matlab.waitfor(app.search_Suggestions, 'Value', @(propValue) ~isempty(propValue), .075, 1, 'propValue')
                    end

                    ipcMainJSEventsHandler(app, struct('HTMLEventName', 'mainApp.search_Suggestions', 'HTMLEventData', 'Enter'))

                otherwise
                    set(app.search_Suggestions, Visible=0, Value={})
                    if isempty(app.search_entryPoint.Value)
                        search_EntryPoint_InitialValue(app)
                    end
            end

        end

        % Value changed function: Tab1Button, Tab2Button, Tab3Button
        function tabNavigatorButtonPushed(app, event)

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
                    appEngine.util.setWindowPosition(app.UIFigure)

                case app.AppInfo
                    appInfo = util.HtmlTextGenerator.AppInfo( ...
                        app.General, ...
                        app.rootFolder, ...
                        app.executionMode, ...
                        app.renderCount, ...
                        app.rawDataTable, ...
                        app.releasedData, ...
                        app.cacheData, ...
                        app.annotationTable, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
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

        % Image clicked function: tool_PanelVisibility
        function misc_Panel_VisibilityImageClicked(app, event)
            
            if app.SubTabGroup.Visible
                app.tool_PanelVisibility.ImageSource = 'ArrowRight_32.png';
                app.SubTabGroup.Visible = "off";                
                app.Document.Layout.Column = [2 4];
            else
                app.tool_PanelVisibility.ImageSource = 'ArrowLeft_32.png';
                app.SubTabGroup.Visible = "on";                
                app.Document.Layout.Column = 4;
            end

        end

        % Image clicked function: tool_ExportVisibleTable
        function tool_ExportVisibleTableImageClicked(app, event)
            
            nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
            defaultName   = appEngine.util.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                idxSCH = app.search_Table.UserData.secondaryIndex;
                writetable(app.rawDataTable(idxSCH, 1:19), fileFullPath, 'WriteMode', 'overwritesheet')
            catch ME
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
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

                    app.tool_AddAnnotationToSelected.Enable = 1;
                    app.search_ToolbarWordCloud.Enable      = 1;

                    if app.PopupTempWarning.Visible
                        matlab.waitfor(app.PopupTempWarning, 'Visible', @(propValue) ~logical(propValue), .5, 5, 'propValue')
                    end
                    app.tool_AddSelectedToBucket.Enable = 1;
                end

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, htmlSource, [], '')

                if ~isempty(app.wordCloudObj) && ~isempty(app.search_WordCloudPanel.Tag)
                    app.wordCloudObj.Table        = [];
                    app.search_WordCloudPanel.Tag = '';
                end

                app.tool_AddAnnotationToSelected.Enable = 0;
                app.search_ToolbarWordCloud.Enable      = 0;

                if app.PopupTempWarning.Visible
                    matlab.waitfor(app.PopupTempWarning, 'Visible', @(propValue) ~logical(propValue), .5, 5, 'propValue')
                end
                app.tool_AddSelectedToBucket.Enable = 0;
            end

        end

        % Image clicked function: search_ToolbarWordCloud
        function search_ToolbarWordCloudImageClicked(app, event)
            
            app.search_ToolbarWordCloud.UserData = ~app.search_ToolbarWordCloud.UserData;
    
            if app.search_ToolbarWordCloud.UserData
                % O "drawnow nocallbacks" aqui é ESSENCIAL porque o
                % MATLAB precisa renderizar em tela o container do
                % WordCloud (um objeto uihtml).
                app.SubGrid1.RowHeight{3} = 150;
                drawnow
    
                selectedRow = app.search_ProductInfo.UserData.selectedRow;
                showedHom   = app.search_ProductInfo.UserData.showedHom;
                relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);
    
                if search_WordCloud_CheckCache(app, showedHom, relatedAnnotationTable)
                    search_WordCloud_PlotUpdate(app, selectedRow, showedHom, false);
                end
    
            else
                app.SubGrid1.RowHeight{3} = 0;
            end

        end

        % Image clicked function: tool_AddSelectedToBucket
        function tool_AddSelectedToBucketImageClicked(app, event)
            
            [~, ~, selectedRows] = misc_Table_SelectedRow(app);

            if isempty(selectedRows)
                app.tool_AddSelectedToBucket.Enable = 0;
                msgWarning = 'Selecione ao menos um registro na tabela.';
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                return

            else
                addedHom = 0;
                for selectedRow = selectedRows'
                    [productData, productHash] = model.projectLib.initializeInspectedProduct('Homologado', app.General, app.rawDataTable, app.search_Table.UserData.primaryIndex(selectedRow));
                    if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                        continue
                    end
                    
                    addedHom = addedHom+1;
                    updateInspectedProducts(app.projectData, 'add', productData)
                end

                if addedHom
                    showPopupTempWarning(app, sprintf('Incluído(s) %d registro(s) na lista de produtos sob análise.', addedHom))
                    ipcMainMatlabCallAuxiliarApp(app, 'PRODUCTS', 'MATLAB', 'updateInspectedProducts')
                else
                    showPopupTempWarning(app, model.projectLib.WARNING_ENTRYEXIST.SEARCH)
                end
            end

        end

        % Callback function: LocationEditionCancel, LocationEditionConfirm,
        % 
        % ...and 4 other components
        function PENDENTE_IMPLEMENTACAO(app, event)
            
            ui.Dialog(app.UIFigure, 'error', 'PENDENTE');

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
            app.GridLayout.RowHeight = {54, '1x'};
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

            % Create Grid1
            app.Grid1 = uigridlayout(app.Tab1_Search);
            app.Grid1.ColumnWidth = {10, 320, 10, '1x', 10};
            app.Grid1.RowHeight = {'1x', 34, 10, 34};
            app.Grid1.ColumnSpacing = 0;
            app.Grid1.RowSpacing = 0;
            app.Grid1.Padding = [0 0 0 40];
            app.Grid1.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Grid1);
            app.Toolbar.ColumnWidth = {22, 22, 22, 5, 22, '1x', 18};
            app.Toolbar.RowHeight = {4, 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 10 5];
            app.Toolbar.Layout.Row = 4;
            app.Toolbar.Layout.Column = [1 5];

            % Create tool_PanelVisibility
            app.tool_PanelVisibility = uiimage(app.Toolbar);
            app.tool_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.tool_PanelVisibility.Layout.Row = 2;
            app.tool_PanelVisibility.Layout.Column = 1;
            app.tool_PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'ArrowLeft_32.png');

            % Create tool_AddAnnotationToSelected
            app.tool_AddAnnotationToSelected = uiimage(app.Toolbar);
            app.tool_AddAnnotationToSelected.ScaleMethod = 'none';
            app.tool_AddAnnotationToSelected.ImageClickedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.tool_AddAnnotationToSelected.Enable = 'off';
            app.tool_AddAnnotationToSelected.Tooltip = {'Adiciona ao registro selecionado uma anotação textual'; '(fabricante, modelo etc)'};
            app.tool_AddAnnotationToSelected.Layout.Row = [2 3];
            app.tool_AddAnnotationToSelected.Layout.Column = 2;
            app.tool_AddAnnotationToSelected.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Variable_edit_16.png');

            % Create tool_ExportVisibleTable
            app.tool_ExportVisibleTable = uiimage(app.Toolbar);
            app.tool_ExportVisibleTable.ScaleMethod = 'none';
            app.tool_ExportVisibleTable.ImageClickedFcn = createCallbackFcn(app, @tool_ExportVisibleTableImageClicked, true);
            app.tool_ExportVisibleTable.Enable = 'off';
            app.tool_ExportVisibleTable.Tooltip = {'Exporta resultados de busca em arquivo Excel (.xlsx)'};
            app.tool_ExportVisibleTable.Layout.Row = [1 3];
            app.tool_ExportVisibleTable.Layout.Column = 3;
            app.tool_ExportVisibleTable.ImageSource = 'Export_16.png';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 4;
            app.tool_Separator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_AddSelectedToBucket
            app.tool_AddSelectedToBucket = uiimage(app.Toolbar);
            app.tool_AddSelectedToBucket.ImageClickedFcn = createCallbackFcn(app, @tool_AddSelectedToBucketImageClicked, true);
            app.tool_AddSelectedToBucket.Enable = 'off';
            app.tool_AddSelectedToBucket.Tooltip = {'Adiciona registros selecionados à lista de produtos sob análise'};
            app.tool_AddSelectedToBucket.Layout.Row = [1 3];
            app.tool_AddSelectedToBucket.Layout.Column = 5;
            app.tool_AddSelectedToBucket.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Picture1.png');

            % Create tool_FilterInfo
            app.tool_FilterInfo = uilabel(app.Toolbar);
            app.tool_FilterInfo.HorizontalAlignment = 'right';
            app.tool_FilterInfo.FontSize = 10;
            app.tool_FilterInfo.FontColor = [0.502 0.502 0.502];
            app.tool_FilterInfo.Layout.Row = [1 3];
            app.tool_FilterInfo.Layout.Column = 6;
            app.tool_FilterInfo.Text = {'Filtragem primária orientada à(s) coluna(s): "Homologação", "Solicitante", "Fabricante", "Modelo", "Nome Comercial"'; 'Filtragem secundária: []'};

            % Create tool_FilterIcon
            app.tool_FilterIcon = uiimage(app.Toolbar);
            app.tool_FilterIcon.ScaleMethod = 'none';
            app.tool_FilterIcon.Enable = 'off';
            app.tool_FilterIcon.Layout.Row = 2;
            app.tool_FilterIcon.Layout.Column = 7;
            app.tool_FilterIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Filter_18x18.png');

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.Grid1);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Layout.Row = [1 2];
            app.SubTabGroup.Layout.Column = 2;

            % Create SubTab1_Search
            app.SubTab1_Search = uitab(app.SubTabGroup);
            app.SubTab1_Search.AutoResizeChildren = 'off';
            app.SubTab1_Search.Title = 'PESQUISA';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1_Search);
            app.SubGrid1.ColumnWidth = {'1x', 18};
            app.SubGrid1.RowHeight = {17, '1x', 0};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create search_ProductInfoLabel
            app.search_ProductInfoLabel = uilabel(app.SubGrid1);
            app.search_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.search_ProductInfoLabel.FontSize = 10;
            app.search_ProductInfoLabel.Layout.Row = 1;
            app.search_ProductInfoLabel.Layout.Column = 1;
            app.search_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create search_ToolbarWordCloud
            app.search_ToolbarWordCloud = uiimage(app.SubGrid1);
            app.search_ToolbarWordCloud.ImageClickedFcn = createCallbackFcn(app, @search_ToolbarWordCloudImageClicked, true);
            app.search_ToolbarWordCloud.Enable = 'off';
            app.search_ToolbarWordCloud.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.search_ToolbarWordCloud.Layout.Row = 1;
            app.search_ToolbarWordCloud.Layout.Column = 2;
            app.search_ToolbarWordCloud.VerticalAlignment = 'bottom';
            app.search_ToolbarWordCloud.ImageSource = 'Cloud_32x32Gray.png';

            % Create search_ProductInfoImage
            app.search_ProductInfoImage = uiimage(app.SubGrid1);
            app.search_ProductInfoImage.ScaleMethod = 'none';
            app.search_ProductInfoImage.Layout.Row = 2;
            app.search_ProductInfoImage.Layout.Column = [1 2];
            app.search_ProductInfoImage.ImageSource = 'warning.svg';

            % Create search_ProductInfo
            app.search_ProductInfo = uilabel(app.SubGrid1);
            app.search_ProductInfo.VerticalAlignment = 'top';
            app.search_ProductInfo.WordWrap = 'on';
            app.search_ProductInfo.FontSize = 11;
            app.search_ProductInfo.Layout.Row = 2;
            app.search_ProductInfo.Layout.Column = [1 2];
            app.search_ProductInfo.Interpreter = 'html';
            app.search_ProductInfo.Text = '';

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.SubGrid1);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = 3;
            app.search_WordCloudPanel.Layout.Column = [1 2];

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.SubGrid1);
            app.jsBackDoor.Tag = 'jsBackDoor';
            app.jsBackDoor.Layout.Row = 3;
            app.jsBackDoor.Layout.Column = [1 2];

            % Create SubTab2_Filter
            app.SubTab2_Filter = uitab(app.SubTabGroup);
            app.SubTab2_Filter.AutoResizeChildren = 'off';
            app.SubTab2_Filter.Title = 'FILTRO';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2_Filter);
            app.SubGrid2.ColumnWidth = {'1x', 18, 18, 18};
            app.SubGrid2.RowHeight = {17, 22, 22, 69, '1x'};
            app.SubGrid2.ColumnSpacing = 5;
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create ESTRATGIADEFILTRAGEMDropDownLabel
            app.ESTRATGIADEFILTRAGEMDropDownLabel = uilabel(app.SubGrid2);
            app.ESTRATGIADEFILTRAGEMDropDownLabel.VerticalAlignment = 'bottom';
            app.ESTRATGIADEFILTRAGEMDropDownLabel.FontSize = 10;
            app.ESTRATGIADEFILTRAGEMDropDownLabel.Layout.Row = 1;
            app.ESTRATGIADEFILTRAGEMDropDownLabel.Layout.Column = 1;
            app.ESTRATGIADEFILTRAGEMDropDownLabel.Text = 'ESTRATÉGIA DE FILTRAGEM';

            % Create ESTRATGIADEFILTRAGEMDropDown
            app.ESTRATGIADEFILTRAGEMDropDown = uidropdown(app.SubGrid2);
            app.ESTRATGIADEFILTRAGEMDropDown.Items = {'Texto livre', 'Texto livre + filtros por coluna', 'Somente filtros por coluna'};
            app.ESTRATGIADEFILTRAGEMDropDown.FontSize = 11;
            app.ESTRATGIADEFILTRAGEMDropDown.BackgroundColor = [1 1 1];
            app.ESTRATGIADEFILTRAGEMDropDown.Layout.Row = 2;
            app.ESTRATGIADEFILTRAGEMDropDown.Layout.Column = [1 4];
            app.ESTRATGIADEFILTRAGEMDropDown.Value = 'Texto livre';

            % Create SecondaryPanel
            app.SecondaryPanel = uipanel(app.SubGrid2);
            app.SecondaryPanel.AutoResizeChildren = 'off';
            app.SecondaryPanel.Layout.Row = 4;
            app.SecondaryPanel.Layout.Column = [1 4];

            % Create SecondaryGrid
            app.SecondaryGrid = uigridlayout(app.SecondaryPanel);
            app.SecondaryGrid.ColumnWidth = {55, '1x', 10, '1x'};
            app.SecondaryGrid.RowHeight = {22, 22};
            app.SecondaryGrid.ColumnSpacing = 5;
            app.SecondaryGrid.RowSpacing = 5;
            app.SecondaryGrid.BackgroundColor = [1 1 1];

            % Create SecondaryColumn
            app.SecondaryColumn = uidropdown(app.SecondaryGrid);
            app.SecondaryColumn.Items = {};
            app.SecondaryColumn.ValueChangedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.SecondaryColumn.FontSize = 11;
            app.SecondaryColumn.BackgroundColor = [1 1 1];
            app.SecondaryColumn.Layout.Row = 1;
            app.SecondaryColumn.Layout.Column = [1 4];
            app.SecondaryColumn.Value = {};

            % Create SecondaryOperation
            app.SecondaryOperation = uidropdown(app.SecondaryGrid);
            app.SecondaryOperation.Items = {'=', '≠', '⊃', '⊅', '<', '≤', '>', '≥', '><', '<>'};
            app.SecondaryOperation.ValueChangedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.SecondaryOperation.FontName = 'Consolas';
            app.SecondaryOperation.BackgroundColor = [1 1 1];
            app.SecondaryOperation.Layout.Row = 2;
            app.SecondaryOperation.Layout.Column = 1;
            app.SecondaryOperation.Value = '=';

            % Create SecondaryDateTime1
            app.SecondaryDateTime1 = uieditfield(app.SecondaryGrid, 'text');
            app.SecondaryDateTime1.CharacterLimits = [10 10];
            app.SecondaryDateTime1.Visible = 'off';
            app.SecondaryDateTime1.Placeholder = 'dd/mm/yyyy';
            app.SecondaryDateTime1.Layout.Row = 2;
            app.SecondaryDateTime1.Layout.Column = 2;

            % Create SecondaryDateTimeSeparator
            app.SecondaryDateTimeSeparator = uilabel(app.SecondaryGrid);
            app.SecondaryDateTimeSeparator.HorizontalAlignment = 'center';
            app.SecondaryDateTimeSeparator.Visible = 'off';
            app.SecondaryDateTimeSeparator.Layout.Row = 2;
            app.SecondaryDateTimeSeparator.Layout.Column = 3;
            app.SecondaryDateTimeSeparator.Text = '-';

            % Create SecondaryDateTime2
            app.SecondaryDateTime2 = uieditfield(app.SecondaryGrid, 'text');
            app.SecondaryDateTime2.CharacterLimits = [10 10];
            app.SecondaryDateTime2.Visible = 'off';
            app.SecondaryDateTime2.Placeholder = 'dd/mm/yyyy';
            app.SecondaryDateTime2.Layout.Row = 2;
            app.SecondaryDateTime2.Layout.Column = 4;

            % Create SecondaryTextFreeValue
            app.SecondaryTextFreeValue = uieditfield(app.SecondaryGrid, 'text');
            app.SecondaryTextFreeValue.FontSize = 10;
            app.SecondaryTextFreeValue.FontColor = [0.149 0.149 0.149];
            app.SecondaryTextFreeValue.Visible = 'off';
            app.SecondaryTextFreeValue.Layout.Row = 2;
            app.SecondaryTextFreeValue.Layout.Column = [2 4];

            % Create SecondaryTextListValue
            app.SecondaryTextListValue = uidropdown(app.SecondaryGrid);
            app.SecondaryTextListValue.Items = {};
            app.SecondaryTextListValue.Visible = 'off';
            app.SecondaryTextListValue.FontSize = 10;
            app.SecondaryTextListValue.BackgroundColor = [1 1 1];
            app.SecondaryTextListValue.Layout.Row = 2;
            app.SecondaryTextListValue.Layout.Column = [2 4];
            app.SecondaryTextListValue.Value = {};

            % Create SecondaryListOfFilters
            app.SecondaryListOfFilters = uilistbox(app.SubGrid2);
            app.SecondaryListOfFilters.Items = {};
            app.SecondaryListOfFilters.Multiselect = 'on';
            app.SecondaryListOfFilters.FontSize = 11;
            app.SecondaryListOfFilters.Layout.Row = 5;
            app.SecondaryListOfFilters.Layout.Column = [1 4];
            app.SecondaryListOfFilters.Value = {};

            % Create LocationEditionCancel
            app.LocationEditionCancel = uiimage(app.SubGrid2);
            app.LocationEditionCancel.ImageClickedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.LocationEditionCancel.Enable = 'off';
            app.LocationEditionCancel.Tooltip = {'Cancela edição'};
            app.LocationEditionCancel.Layout.Row = 3;
            app.LocationEditionCancel.Layout.Column = 4;
            app.LocationEditionCancel.VerticalAlignment = 'bottom';
            app.LocationEditionCancel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Delete_32Red.png');

            % Create LocationEditionConfirm
            app.LocationEditionConfirm = uiimage(app.SubGrid2);
            app.LocationEditionConfirm.ImageClickedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.LocationEditionConfirm.Enable = 'off';
            app.LocationEditionConfirm.Tooltip = {'Confirma edição'};
            app.LocationEditionConfirm.Layout.Row = 3;
            app.LocationEditionConfirm.Layout.Column = 3;
            app.LocationEditionConfirm.VerticalAlignment = 'bottom';
            app.LocationEditionConfirm.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Ok_32Green.png');

            % Create LocationEditionMode
            app.LocationEditionMode = uiimage(app.SubGrid2);
            app.LocationEditionMode.ImageClickedFcn = createCallbackFcn(app, @PENDENTE_IMPLEMENTACAO, true);
            app.LocationEditionMode.Tooltip = {'Habilita painel de edição'};
            app.LocationEditionMode.Layout.Row = 3;
            app.LocationEditionMode.Layout.Column = 2;
            app.LocationEditionMode.VerticalAlignment = 'bottom';
            app.LocationEditionMode.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Edit_36.png');

            % Create SecondaryPanelLabel
            app.SecondaryPanelLabel = uilabel(app.SubGrid2);
            app.SecondaryPanelLabel.VerticalAlignment = 'bottom';
            app.SecondaryPanelLabel.FontSize = 10;
            app.SecondaryPanelLabel.Layout.Row = 3;
            app.SecondaryPanelLabel.Layout.Column = 1;
            app.SecondaryPanelLabel.Text = 'FILTROS POR COLUNA';

            % Create Document
            app.Document = uigridlayout(app.Grid1);
            app.Document.ColumnWidth = {412, '1x', 170};
            app.Document.RowHeight = {34, 19, 5, 342, '1x', 1};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [1 2];
            app.Document.Layout.Column = 4;
            app.Document.BackgroundColor = [1 1 1];

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

            % Create search_words2Search
            app.search_words2Search = uilabel(app.Document);
            app.search_words2Search.VerticalAlignment = 'bottom';
            app.search_words2Search.FontSize = 10;
            app.search_words2Search.Layout.Row = 2;
            app.search_words2Search.Layout.Column = 1;
            app.search_words2Search.Interpreter = 'html';
            app.search_words2Search.Text = 'AGUARDANDO PESQUISA';

            % Create search_nRows
            app.search_nRows = uilabel(app.Document);
            app.search_nRows.HorizontalAlignment = 'right';
            app.search_nRows.VerticalAlignment = 'bottom';
            app.search_nRows.FontSize = 11;
            app.search_nRows.FontColor = [0.502 0.502 0.502];
            app.search_nRows.Layout.Row = [1 2];
            app.search_nRows.Layout.Column = 3;
            app.search_nRows.Interpreter = 'html';
            app.search_nRows.Text = {'0 <font style="font-size: 9px; margin-right: 2px;">HOMOLOGAÇÕES</font>'; '0 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>'};

            % Create search_Table
            app.search_Table = uitable(app.Document);
            app.search_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.search_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.search_Table.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.search_Table.RowName = {};
            app.search_Table.RowStriping = 'off';
            app.search_Table.ClickedFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.search_Table.SelectionChangedFcn = createCallbackFcn(app, @search_Table_SelectionChanged, true);
            app.search_Table.Layout.Row = [4 5];
            app.search_Table.Layout.Column = [1 3];
            app.search_Table.FontSize = 10;

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.Document);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = [2 4];
            app.search_Suggestions.Layout.Column = 1;
            app.search_Suggestions.Value = {};

            % Create PopupTempWarning
            app.PopupTempWarning = uilabel(app.Grid1);
            app.PopupTempWarning.BackgroundColor = [0.2 0.2 0.2];
            app.PopupTempWarning.HorizontalAlignment = 'center';
            app.PopupTempWarning.WordWrap = 'on';
            app.PopupTempWarning.FontColor = [1 1 1];
            app.PopupTempWarning.Visible = 'off';
            app.PopupTempWarning.Layout.Row = 2;
            app.PopupTempWarning.Layout.Column = [2 4];
            app.PopupTempWarning.Text = '';

            % Create Tab2_Report
            app.Tab2_Report = uitab(app.TabGroup);
            app.Tab2_Report.AutoResizeChildren = 'off';

            % Create Tab3_Config
            app.Tab3_Config = uitab(app.TabGroup);
            app.Tab3_Config.AutoResizeChildren = 'off';

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

            % Create AppIcon
            app.AppIcon = uiimage(app.NavBar);
            app.AppIcon.Layout.Row = [1 5];
            app.AppIcon.Layout.Column = 1;
            app.AppIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'icon_32White.png');

            % Create AppName
            app.AppName = uilabel(app.NavBar);
            app.AppName.WordWrap = 'on';
            app.AppName.FontSize = 11;
            app.AppName.FontColor = [1 1 1];
            app.AppName.Layout.Row = [1 5];
            app.AppName.Layout.Column = [2 3];
            app.AppName.Interpreter = 'html';
            app.AppName.Text = {'SCH v. 1.10.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create Tab1Button
            app.Tab1Button = uibutton(app.NavBar, 'state');
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'SEARCH';
            app.Tab1Button.Tooltip = {''};
            app.Tab1Button.Icon = 'Zoom_32Yellow.png';
            app.Tab1Button.IconAlignment = 'top';
            app.Tab1Button.Text = '';
            app.Tab1Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab1Button.FontSize = 11;
            app.Tab1Button.Layout.Row = [2 4];
            app.Tab1Button.Layout.Column = 4;
            app.Tab1Button.Value = true;

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PRODUCTS';
            app.Tab2Button.Tooltip = {''};
            app.Tab2Button.Icon = 'Detection_32White.png';
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 5;

            % Create ButtonsSeparator
            app.ButtonsSeparator = uiimage(app.NavBar);
            app.ButtonsSeparator.ScaleMethod = 'none';
            app.ButtonsSeparator.Enable = 'off';
            app.ButtonsSeparator.Layout.Row = [2 4];
            app.ButtonsSeparator.Layout.Column = 6;
            app.ButtonsSeparator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @tabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'CONFIG';
            app.Tab3Button.Tooltip = {''};
            app.Tab3Button.Icon = 'Settings_36White.png';
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 7;

            % Create DataHubLamp
            app.DataHubLamp = uilamp(app.NavBar);
            app.DataHubLamp.Enable = 'off';
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear pastas do Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 10;
            app.DataHubLamp.Color = [1 0 0];

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
