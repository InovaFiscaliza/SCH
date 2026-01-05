classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        NavBar                    matlab.ui.container.GridLayout
        AppInfo                   matlab.ui.control.Image
        FigurePosition            matlab.ui.control.Image
        DataHubLamp               matlab.ui.control.Image
        Tab3Button                matlab.ui.control.StateButton
        ButtonsSeparator          matlab.ui.control.Image
        Tab2Button                matlab.ui.control.StateButton
        Tab1Button                matlab.ui.control.StateButton
        AppName                   matlab.ui.control.Label
        AppIcon                   matlab.ui.control.Image
        TabGroup                  matlab.ui.container.TabGroup
        Tab1_Search               matlab.ui.container.Tab
        Grid1                     matlab.ui.container.GridLayout
        search_Suggestions        matlab.ui.control.ListBox
        search_entryPointGrid     matlab.ui.container.GridLayout
        search_entryPointImage    matlab.ui.control.Image
        search_entryPoint         matlab.ui.control.EditField
        PopupTempWarning          matlab.ui.control.Label
        Document                  matlab.ui.container.GridLayout
        SubGrid1                  matlab.ui.container.GridLayout
        jsBackDoor                matlab.ui.control.HTML
        search_WordCloudPanel     matlab.ui.container.Panel
        search_ProductInfo        matlab.ui.control.Label
        search_ProductInfoImage   matlab.ui.control.Image
        UITable                   matlab.ui.control.Table
        search_nRows              matlab.ui.control.Label
        search_words2Search       matlab.ui.control.Label
        Toolbar                   matlab.ui.container.GridLayout
        tool_FilterInfo           matlab.ui.control.Label
        tool_AddSelectedToBucket  matlab.ui.control.Image
        tool_Separator2           matlab.ui.control.Image
        tool_ExportVisibleTable   matlab.ui.control.Image
        tool_OpenPopupAnnotation  matlab.ui.control.Image
        tool_OpenPopupFilter      matlab.ui.control.Image
        tool_Separator1           matlab.ui.control.Image
        tool_WordCloudVisibility  matlab.ui.control.Image
        tool_PanelVisibility      matlab.ui.control.Image
        Tab2_Report               matlab.ui.container.Tab
        Tab3_Config               matlab.ui.container.Tab
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

        SubTabGroup = struct('Children', -1, 'UserData', [])

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


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        rowStripingStyle = uistyle('BackgroundColor', [.96,.96,.96])
        annotationStyle  = uistyle('Icon', 'edit.svg', 'IconAlignment', 'rightmargin')
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

            % Quando altero o conteúdo de app.search_entryPoint, sem alterar o seu foco, será executado
            % o evento "ValueChangingFcn".
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
                            case 'onFetchIssueDetails'
                                context = event.HTMLEventData.context;
                                reportFetchIssueDetails(app, context, event.HTMLEventData)

                            case 'onReportGenerate'
                                context = event.HTMLEventData.context;
                                reportGenerate(app, context, event.HTMLEventData)

                            case 'onUploadArtifacts'
                                context = event.HTMLEventData.context;
                                reportUploadArtifacts(app, context, event.HTMLEventData, 'uploadDocument')

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    case 'backgroundBecameTransparent'
                        switch event.HTMLEventData
                            case 'PopupTempWarning'
                                app.tool_AddSelectedToBucket.Enable = "on";
                                app.PopupTempWarning.Visible = "off";

                            otherwise
                                error('UnexpectedEvent')
                        end
    
                    case 'mainApp.search_entryPoint'
                        % HTMLEventData é uma estrutura com os campos "key" 
                        % (tecla pressionada) e "value" (valor atual do campo).
                        keydownPressed    = event.HTMLEventData.key;
                        currentInputValue = event.HTMLEventData.value;

                        % Força-se a atualização da propriedade "Value" porque, 
                        % apesar de na GUI já constar um valor novo, este ainda 
                        % não foi devidamente atualizado.
                        app.search_entryPoint.Value = currentInputValue;    
                        switch keydownPressed
                            case {'Escape', 'Tab'}
                                if numel(currentInputValue) < app.General.search.minCharacters
                                    search_EntryPoint_InitialValue(app)
                                end
    
                                if strcmp(keydownPressed, 'Tab') && app.search_entryPointImage.Enable
                                    focus(app.search_entryPointImage)
                                end
    
                                pause(.050)
                                set(app.search_Suggestions, Visible=0, Value={})
    
                            otherwise
                                if numel(currentInputValue) >= app.General.search.minCharacters
                                    switch keydownPressed
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
                        % HTMLEventData é uma string com a indicação da tecla
                        % pressionada.
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
                switch operationType
                    case 'closeFcn'
                        auxAppTag    = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        auxAppTag    = varargin{1};
                        varargout{1} = auxAppInputArguments(app, auxAppTag);

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch operationType        
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
                                        set(app.UITable, 'ColumnName', upper(columnNames), 'ColumnWidth', columnWidth)
                            
                                        if ~isempty(app.UITable.Data)
                                            if (numel(columnNames) ~= width(app.UITable.Data)) || any(~ismember(app.UITable.ColumnName, upper(columnNames)))
                                                secondaryIndex = app.UITable.UserData.secondaryIndex;
                                                app.UITable.Data = app.rawDataTable(secondaryIndex, columnNames);
                                            end
                                        end

                                    case 'updateDataHubGetFolder'
                                        app.progressDialog.Visible = 'visible';
                                        startup_mainVariables(app)
                                        app.progressDialog.Visible = 'hidden';
        
                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            % auxApp.winProducts (PRODUCTS)
                            case {'auxApp.winProducts', 'auxApp.winProducts_exported'}
                                switch operationType
                                    case 'onReportGenerate'
                                        context = varargin{1};
                                        reportGenerate(app, context, [])

                                    case 'onUploadArtifacts'
                                        context = varargin{1};
                                        reportUploadArtifacts(app, context, [], 'uploadDocument')
                                end
        
                            % DOCKS:OTHERS
                            case {'auxApp.dockProductInfo', 'auxApp.dockProductInfo_exported', ...
                                  'auxApp.dockReportLib',   'auxApp.dockReportLib_exported', ...
                                  'auxApp.dockFilterSetup', 'auxApp.dockFilterSetup_exported'}
                                switch operationType
                                    case 'closeFcnCallFromPopupApp'
                                        context = varargin{1};
                                        moduleTag = varargin{2};
        
                                        switch context
                                            case {'mainApp', 'SEARCH'}
                                                hApp = app;
                                                app.popupContainer.Parent.Visible = 0;
                                            otherwise
                                                hApp = getAppHandle(app.tabGroupController, context);
                                                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', operationType)
                                        end
                                        
                                        if ~isempty(hApp)
                                            deleteContextMenu(app.tabGroupController, hApp.UIFigure, moduleTag)
                                        end
        
                                    % auxApp.dockProductInfo
                                    case {'onTableSelectionChanged', 'onTableCellEdited'}
                                        context  = varargin{1};
                                        varargin = [{operationType}, varargin(2:end)];
                                        ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})
                                        return
        
                                    % auxApp.dockReportLib
                                    case {'onProjectRestart', 'onProjectLoad', 'onFinalReportFileChanged'}
                                        context  = varargin{1};
                                        varargin = [{operationType}, varargin(2:end)];
                                        ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})
                                        return
        
                                    % auxApp.dockReportLib
                                    case 'onUpdateLastVisitedFolder'
                                        filePath = varargin{1};
                                        updateLastVisitedFolder(app, filePath)
                                        return

                                    case 'onFetchIssueDetails'
                                        context  = varargin{1};
                                        reportFetchIssueDetails(app, context, [])

                                    % auxApp.dockFilterSetup
                                    % ...
        
                                    otherwise
                                        error('UnexpectedCall')
                                end
        
                            otherwise
                                error('UnexpectedCaller')
                        end
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
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
                    screenHeight = 602;
                case 'FilterSetup'
                    screenWidth  = 412;
                    screenHeight = 464;
                case 'ProductInfo'
                    screenWidth  = 580;
                    screenHeight = 640;
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')
            ui.PopUpContainer(callingApp, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app, callingApp}, varargin];
            auxDockAppName = sprintf('auxApp.dock%s', auxAppName);
            
            if app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName))
            else
                eval([auxDockAppName '_exported(callingApp.popupContainer, inputArguments{:})'])

                callingApp.popupContainer.UserData.auxDockAppName = auxDockAppName;
                callingApp.popupContainer.Parent.Visible = 1;
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            tabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;

            switch tabIndex
                case 1
                    appName = class(app);
                    elToModify = {
                        app.search_entryPoint;
                        app.search_ProductInfo;                             % ui.TextView
                        app.search_ProductInfoImage;                        % ui.TextView (Background image)
                        app.search_Suggestions;
                        app.PopupTempWarning;
                        app.search_WordCloudPanel;
                        app.Tab1Button;
                        app.Tab2Button;
                        app.Tab3Button;
                        app.search_entryPointGrid
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elToModify{1}.UserData.id,  'generation', 1, 'style',          struct('border', '0')), ...
                            struct('appName', appName, 'dataTag', elToModify{10}.UserData.id, 'generation', 0, 'styleImportant', struct('border', '1px solid #7d7d7d', 'borderRadius', '0')), ...
                            struct('appName', appName, 'dataTag', elToModify{1}.UserData.id,  'generation', 2, 'listener',       struct('componentName', 'mainApp.search_entryPoint', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
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
                            struct('appName', appName, 'dataTag', elToModify{5}.UserData.id, 'generation', 0, 'style',    struct('borderRadius', '8px', 'pointerEvents', 'none')) ...
                        });
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elToModify{7}.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', elToModify{8}.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', elToModify{9}.UserData.id, 'generation', 1, 'class', 'tab-navigator-button') ...
                        });
                    catch
                    end

                otherwise
                    % ...
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
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog);
            addComponent(app.tabGroupController, "Built-in", "",                   app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            convertToInlineSVG(app.tabGroupController, app.jsBackDoor)

            % Salva na propriedade "UserData" as opções de ícone e o índice
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.tool_WordCloudVisibility.UserData      = false;

            % Inicialização da propriedade "UserData" da tabela.
            app.search_entryPointImage.UserData       = struct('value2Search', '', 'words2Search', '');
            app.UITable.UserData                 = struct('primaryIndex', [], 'secondaryIndex', [], 'cacheColumns', {{}});
            app.UITable.RowName                  = 'numbered';

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

            set(app.UITable, 'Data',      app.rawDataTable(primaryIndex, GUIColumns), ...
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
            primaryIndex = app.UITable.UserData.primaryIndex;
            GUIColumns   = search_Table_ColumnNames(app);

            if ~isempty(app.filteringObj.filterRules)
                logicalArray   = run(app.filteringObj, 'filterRules', app.rawDataTable(primaryIndex,:));
                secondaryIndex = primaryIndex(logicalArray);
            else
                secondaryIndex = primaryIndex;
            end

            app.UITable.Data = app.rawDataTable(secondaryIndex, GUIColumns);
            app.UITable.UserData.secondaryIndex = secondaryIndex;

            % Renderiza em tela o número de linhas, além de selecionar a primeira
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app)
            search_Table_InitialSelection(app, false)

            % Aplica estilo na tabela...
            search_Table_AddStyle(app)
        end

        %-----------------------------------------------------------------%
        function search_EntryPoint_Layout(app)
            app.previousSearch   = '';
            app.previousItemData = 0;

            search_SuggestionPanel_InitialValues(app)
            search_EntryPoint_InitialValue(app)
        end

        %-----------------------------------------------------------------%
        function search_SuggestionPanel_InitialValues(app)
            set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
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
                            searchNote = ' e similares';
                        else
                            searchNote = '';
                        end
    
                        app.search_words2Search.Text = sprintf('Resultados para "<b>%s</b>"%s', value2Search, searchNote);
                        updateFilterSpecificationToolbar(app)
                    end

                otherwise
                    if ~isempty(words2Search)
                        app.search_words2Search.Text = sprintf('Resultados para %s', strjoin("""<b>" + string(words2Search) + "</b>""", ', '));
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
            if isempty(app.UITable.Data)
                app.UITable.Selection = [];
            else
                app.UITable.Selection = [1, 1];
            end
            UITable_SelectionChanged(app)

            if focusFlag
                focus(app.UITable)
            end
        end

        %-----------------------------------------------------------------%
        function search_Table_AddStyle(app)
            search_Table_RemoveStyle(app, 'all')

            % Row striping
            [~, ~, uniqueHomIndex] = unique(app.UITable.Data.("Homologação"), 'stable');
            listOfRows             = find(~mod(uniqueHomIndex, 2));
            if ~isempty(listOfRows)
                s = app.rowStripingStyle;
                addStyle(app.UITable, s, 'row', listOfRows)
            end

            % Table annotation icon
            search_Table_AnnotationIcon(app)
            drawnow
        end

        %-----------------------------------------------------------------%
        function search_Table_RemoveStyle(app, styleType)
            switch styleType
                case 'all'
                    removeStyle(app.UITable)

                otherwise
                    styleTypeIndex  = find(strcmp(cellstr(app.UITable.StyleConfigurations.Target), styleType));
                    if ~isempty(styleTypeIndex)
                        removeStyle(app.UITable, styleTypeIndex)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function search_Table_AnnotationIcon(app)
            % Posição da coluna "Homologação".
            homColumnIndex    = find(strcmp(app.UITable.Data.Properties.VariableNames, 'Homologação'), 1);

            % Valores únicos de homologação e seus índices...
            [listOfHom, ...
             lisOfHomIndex]   = unique(app.UITable.Data.("Homologação"), 'stable');

            % Identifica registros para os quais existe anotação registrada,
            % aplicando o estilo.
            annotationLogical = ismember(listOfHom, unique(app.annotationTable.("Homologação")));
            annotationIndex   = lisOfHomIndex(annotationLogical);
            listOfCells       = [annotationIndex, repmat(homColumnIndex, numel(annotationIndex), 1)];

            if ~isempty(listOfCells)
                s = app.annotationStyle;
                addStyle(app.UITable, s, "cell", listOfCells)
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
            selectedRow = find(strcmp(app.UITable.Data.("Homologação"), showedHom), 1);
            listOfWords = {char(app.UITable.Data.("Modelo")(selectedRow)), ...
                char(app.UITable.Data.("Nome Comercial")(selectedRow))};

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
            if ~isempty(app.UITable.Selection)
                selectedRows = unique(app.UITable.Selection(:,1));
                selectedHom  = unique(app.UITable.Data.("Homologação")(selectedRows), 'stable');
            else
                selectedRows = [];
                selectedHom  = {};
            end

            showedHom = app.search_ProductInfo.UserData.showedHom;
        end

        %-----------------------------------------------------------------%
        function misc_Table_NumberOfRows(app)
            nHom  = numel(unique(app.UITable.Data.("Homologação")));
            nRows = height(app.UITable.Data);
            app.search_nRows.Text = sprintf('%d <font style="font-size: 10px;">HOMOLOGAÇÕES </font><br>%d <font style="font-size: 10px;">REGISTROS </font>', nHom, nRows);
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

        %-----------------------------------------------------------------------%
        function showPopupTempWarning(app, msg)
            app.tool_AddSelectedToBucket.Enable = "off";
            set(app.PopupTempWarning, 'Text', msg, 'Visible', 'on')
            sendEventToHTMLSource(app.jsBackDoor, 'setBackgroundTransparent', struct('componentName', 'PopupTempWarning', 'componentDataTag', app.PopupTempWarning.UserData.id, 'interval_ms', 75));
            drawnow
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

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            nonEmptyTable     = ~isempty(app.UITable.Data);
            nonEmptySelection = ~isempty(app.UITable.Selection);
            visibleSidePanel  = app.SubGrid1.Visible;

            app.tool_WordCloudVisibility.Enable = visibleSidePanel;
            app.tool_OpenPopupAnnotation.Enable = nonEmptySelection;
            app.tool_ExportVisibleTable.Enable  = nonEmptyTable;

            if app.PopupTempWarning.Visible
                matlab.waitfor(app.PopupTempWarning, 'Visible', @(propValue) ~logical(propValue), .5, 5, 'propValue')
            end
            app.tool_AddSelectedToBucket.Enable = nonEmptySelection;
        end

        %-----------------------------------------------------------------%
        function updateLastVisitedFolder(app, filePath)
            app.General_I.fileFolder.lastVisited = filePath;
            app.General.fileFolder.lastVisited   = filePath;

            appEngine.util.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % SISTEMA DE GESTÃO DA FISCALIZAÇÃO (eFiscaliza/SEI)
        %-----------------------------------------------------------------%
        function createEFiscalizaObject(app, credentials)
            if ~isempty(credentials)
                app.eFiscalizaObj = ws.eFiscaliza(credentials.login, credentials.password);
            end
        end

        %-----------------------------------------------------------------%
        function reportFetchIssueDetails(app, context, credentials)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            system = app.projectData.modules.(context).ui.system;
            issue  = app.projectData.modules.(context).ui.issue;
            [details, msgError] = getOrFetchIssueDetails(app.projectData, system, issue, app.eFiscalizaObj);

            if app ~= callingApp
                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', 'onFetchIssueDetails', system, issue, details, msgError)
            end

            callingApp.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function reportGenerate(app, context, credentials)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            try
                reportLibConnection.Controller.Run(app, callingApp, context)
                if app == callingApp
                    updateToolbar(app)
                else
                    ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', 'onReportGenerate')
                end
            catch ME
                ui.Dialog(callingApp.UIFigure, 'error', getReport(ME));
            end

            callingApp.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function reportUploadArtifacts(app, context, credentials, operation)
            callingApp = getAppHandle(app.tabGroupController, context);
            if isempty(callingApp)
                callingApp = app;
            end

            callingApp.progressDialog.Visible = 'visible';

            createEFiscalizaObject(app, credentials)
            [status1, icon1, msg1] = reportUploadToSEI(app, context, operation);
            ui.Dialog(callingApp.UIFigure, icon1, msg1);

            callingApp.progressDialog.Visible = 'hidden';

            if status1 && strcmp(app.projectData.modules.(context).ui.system, 'eFiscaliza')
                [status2, msg2] = reportUploadJsonToSharepoint(app);

                if ~status2
                    ui.Dialog(callingApp.UIFigure, 'error', msg2);
                end
            end
        end

        %-------------------------------------------------------------------------%
        function [status, icon, msg] = reportUploadToSEI(app, context, operation)
            try
                env = strsplit(app.projectData.modules.(context).ui.system);
                if isscalar(env)
                    env = 'PD';
                else
                    env = env{2};
                end

                system = app.projectData.modules.(context).ui.system;
                unit = app.projectData.modules.(context).ui.unit;
                issue = app.projectData.modules.(context).ui.issue;
                issueInfo = struct( ...
                    'type', 'ATIVIDADE DE INSPEÇÃO', ...
                    'id', issue ...
                );

                switch operation
                    case 'uploadDocument'
                        HTMLFile = getGeneratedDocumentFileName(app.projectData, '.html', context);

                        [~, modelIdx]   = ismember(app.projectData.modules.(context).ui.reportModel, {app.projectData.report.templates.Name});
                        docType         = app.projectData.report.templates(modelIdx).DocumentType;
                        [~, docTypeIdx] = ismember(docType, {app.General.eFiscaliza.internal.typeIdMapping.type});

                        docSpec = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId = app.General.eFiscaliza.internal.typeIdMapping(docTypeIdx).id;

                        response = run(app.eFiscalizaObj, env, operation, issueInfo, unit, docSpec, HTMLFile);

                    otherwise
                        error('Unexpected call')
                end

                if ~contains(response, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(response)
                end

                updateUploadedFiles(app.projectData, context, system, issue, response)

                status = true;
                icon   = 'success';
                msg    = response;

            catch ME
                app.eFiscalizaObj = [];
                
                status = false;
                icon   = 'error';
                msg    = ME.message;
            end
        end

        %------------------------------------------------------------------------%
        function [status, msg] = reportUploadJsonToSharepoint(app)
            JSONFile = getGeneratedDocumentFileName(app.projectData, '.json', context);
            [status, msg] = copyfile(JSONFile, app.General.fileFolder.DataHub_POST, 'f');
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            try
                Toolbar_PanelVisibilityImageClicked(app)
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

            msgQuestion = '';
            if CheckIfUpdateNeeded(app.projectData)
                msgQuestion = sprintf([ ...
                    'O projeto "%s" foi modificado (nome, arquivo de saída ou ' ...
                    'lista de produtos sob análise). Caso o aplicativo seja encerrado ' ...
                    'agora, todas as alterações serão descartadas.\n\n' ...
                    'Deseja realmente fechar o aplicativo?' ...
                    ], app.projectData.name);
            
            elseif ~strcmp(app.executionMode, 'webApp')
                msgQuestion = 'Deseja fechar o aplicativo?';
            end

            if ~isempty(msgQuestion)                
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            try
                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)

        end

        % Callback function: UIFigure, UITable
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
                    focus(findobj(app.NavBar.Children, 'Type', 'uistatebutton', 'Value', true))

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
        function Toolbar_PanelVisibilityImageClicked(app, event)
            
            if app.SubGrid1.Visible
                app.tool_PanelVisibility.ImageSource = 'layout-sidebar-right-off.svg';
                app.SubGrid1.Visible = 0;
                app.UITable.Layout.Column = [1 2];
            else
                app.tool_PanelVisibility.ImageSource = 'layout-sidebar-right.svg';
                app.SubGrid1.Visible = 1;
                app.UITable.Layout.Column = 1;
            end

        end

        % Image clicked function: tool_OpenPopupAnnotation, 
        % ...and 1 other component
        function Toolbar_PENDENTE_IMPLEMENTACAO(app, event)
            
            ui.Dialog(app.UIFigure, 'error', 'PENDENTE');

        end

        % Image clicked function: tool_ExportVisibleTable
        function Toolbar_ExportVisibleTableImageClicked(app, event)
            
            nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
            defaultName   = appEngine.util.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                idxSCH = app.UITable.UserData.secondaryIndex;
                writetable(app.rawDataTable(idxSCH, 1:19), fileFullPath, 'WriteMode', 'overwritesheet')
            catch ME
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_AddSelectedToBucket
        function Toolbar_AddSelectedToBucketImageClicked(app, event)
            
            [~, ~, selectedRows] = misc_Table_SelectedRow(app);
            if isempty(selectedRows)
                return
            end

            addedHom = 0;
            for selectedRow = selectedRows'
                [productData, productHash] = model.projectLib.initializeInspectedProduct('Homologado', app.General, app.rawDataTable, app.UITable.UserData.primaryIndex(selectedRow));
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

        % Selection changed function: UITable
        function UITable_SelectionChanged(app, event)
            
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
                    if app.tool_WordCloudVisibility.UserData
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
                end

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, htmlSource, [], '')

                if ~isempty(app.wordCloudObj) && ~isempty(app.search_WordCloudPanel.Tag)
                    app.wordCloudObj.Table        = [];
                    app.search_WordCloudPanel.Tag = '';
                end
            end

            updateToolbar(app)

        end

        % Image clicked function: tool_WordCloudVisibility
        function tool_WordCloudVisibilityImageClicked(app, event)
            
            app.tool_WordCloudVisibility.UserData = ~app.tool_WordCloudVisibility.UserData;
    
            if app.tool_WordCloudVisibility.UserData
                % O "drawnow nocallbacks" aqui é ESSENCIAL porque o
                % MATLAB precisa renderizar em tela o container do
                % WordCloud (um objeto uihtml).
                app.SubGrid1.RowHeight{2} = 150;
                % drawnow
    
                selectedRow = app.search_ProductInfo.UserData.selectedRow;
                showedHom   = app.search_ProductInfo.UserData.showedHom;
                relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);
    
                if search_WordCloud_CheckCache(app, showedHom, relatedAnnotationTable)
                    search_WordCloud_PlotUpdate(app, selectedRow, showedHom, false);
                end
    
            else
                app.SubGrid1.RowHeight{2} = 0;
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
            app.Grid1.ColumnWidth = {10, '1x', 412, '1x', 10};
            app.Grid1.RowHeight = {7, 27, 342, '1x', 34, 10, 34};
            app.Grid1.ColumnSpacing = 0;
            app.Grid1.RowSpacing = 0;
            app.Grid1.Padding = [0 0 0 40];
            app.Grid1.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Grid1);
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, 22, 22, 5, 22, '1x'};
            app.Toolbar.RowHeight = {4, 17, '1x', '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 7;
            app.Toolbar.Layout.Column = [1 5];

            % Create tool_PanelVisibility
            app.tool_PanelVisibility = uiimage(app.Toolbar);
            app.tool_PanelVisibility.ScaleMethod = 'none';
            app.tool_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PanelVisibilityImageClicked, true);
            app.tool_PanelVisibility.Tooltip = {''};
            app.tool_PanelVisibility.Layout.Row = [1 4];
            app.tool_PanelVisibility.Layout.Column = 1;
            app.tool_PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout-sidebar-right-off.svg');

            % Create tool_WordCloudVisibility
            app.tool_WordCloudVisibility = uiimage(app.Toolbar);
            app.tool_WordCloudVisibility.ImageClickedFcn = createCallbackFcn(app, @tool_WordCloudVisibilityImageClicked, true);
            app.tool_WordCloudVisibility.Enable = 'off';
            app.tool_WordCloudVisibility.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.tool_WordCloudVisibility.Layout.Row = 2;
            app.tool_WordCloudVisibility.Layout.Column = 2;
            app.tool_WordCloudVisibility.VerticalAlignment = 'bottom';
            app.tool_WordCloudVisibility.ImageSource = 'Cloud_32x32Gray.png';

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.Toolbar);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 4];
            app.tool_Separator1.Layout.Column = 3;
            app.tool_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_OpenPopupFilter
            app.tool_OpenPopupFilter = uiimage(app.Toolbar);
            app.tool_OpenPopupFilter.ScaleMethod = 'none';
            app.tool_OpenPopupFilter.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PENDENTE_IMPLEMENTACAO, true);
            app.tool_OpenPopupFilter.Tooltip = {'Configura estratégia de filtragem'};
            app.tool_OpenPopupFilter.Layout.Row = [1 4];
            app.tool_OpenPopupFilter.Layout.Column = 4;
            app.tool_OpenPopupFilter.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Filter_18x18.png');

            % Create tool_OpenPopupAnnotation
            app.tool_OpenPopupAnnotation = uiimage(app.Toolbar);
            app.tool_OpenPopupAnnotation.ScaleMethod = 'none';
            app.tool_OpenPopupAnnotation.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PENDENTE_IMPLEMENTACAO, true);
            app.tool_OpenPopupAnnotation.Enable = 'off';
            app.tool_OpenPopupAnnotation.Tooltip = {'Adiciona ao registro selecionado uma anotação textual'; '(fabricante, modelo etc)'};
            app.tool_OpenPopupAnnotation.Layout.Row = [1 4];
            app.tool_OpenPopupAnnotation.Layout.Column = 5;
            app.tool_OpenPopupAnnotation.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Variable_edit_16.png');

            % Create tool_ExportVisibleTable
            app.tool_ExportVisibleTable = uiimage(app.Toolbar);
            app.tool_ExportVisibleTable.ScaleMethod = 'none';
            app.tool_ExportVisibleTable.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ExportVisibleTableImageClicked, true);
            app.tool_ExportVisibleTable.Enable = 'off';
            app.tool_ExportVisibleTable.Tooltip = {'Exporta resultados de busca em arquivo Excel (.xlsx)'};
            app.tool_ExportVisibleTable.Layout.Row = [1 4];
            app.tool_ExportVisibleTable.Layout.Column = 6;
            app.tool_ExportVisibleTable.ImageSource = 'Export_16.png';

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 4];
            app.tool_Separator2.Layout.Column = 7;
            app.tool_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_AddSelectedToBucket
            app.tool_AddSelectedToBucket = uiimage(app.Toolbar);
            app.tool_AddSelectedToBucket.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AddSelectedToBucketImageClicked, true);
            app.tool_AddSelectedToBucket.Enable = 'off';
            app.tool_AddSelectedToBucket.Tooltip = {'Adiciona registros selecionados à lista de produtos sob análise'};
            app.tool_AddSelectedToBucket.Layout.Row = [1 4];
            app.tool_AddSelectedToBucket.Layout.Column = 8;
            app.tool_AddSelectedToBucket.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Picture1.png');

            % Create tool_FilterInfo
            app.tool_FilterInfo = uilabel(app.Toolbar);
            app.tool_FilterInfo.HorizontalAlignment = 'right';
            app.tool_FilterInfo.FontSize = 10;
            app.tool_FilterInfo.FontColor = [0.502 0.502 0.502];
            app.tool_FilterInfo.Layout.Row = [1 4];
            app.tool_FilterInfo.Layout.Column = 9;
            app.tool_FilterInfo.Text = {'Filtragem primária orientada à(s) coluna(s): "Homologação", "Solicitante", "Fabricante", "Modelo", "Nome Comercial"'; 'Filtragem secundária: []'};

            % Create Document
            app.Document = uigridlayout(app.Grid1);
            app.Document.ColumnWidth = {'1x', 320};
            app.Document.RowHeight = {36, '1x', 1};
            app.Document.RowSpacing = 3;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [2 5];
            app.Document.Layout.Column = [2 4];
            app.Document.BackgroundColor = [1 1 1];

            % Create search_words2Search
            app.search_words2Search = uilabel(app.Document);
            app.search_words2Search.VerticalAlignment = 'bottom';
            app.search_words2Search.FontSize = 10;
            app.search_words2Search.FontColor = [0.502 0.502 0.502];
            app.search_words2Search.Layout.Row = 1;
            app.search_words2Search.Layout.Column = 1;
            app.search_words2Search.Interpreter = 'html';
            app.search_words2Search.Text = '';

            % Create search_nRows
            app.search_nRows = uilabel(app.Document);
            app.search_nRows.HorizontalAlignment = 'right';
            app.search_nRows.VerticalAlignment = 'bottom';
            app.search_nRows.FontSize = 11;
            app.search_nRows.FontColor = [0.502 0.502 0.502];
            app.search_nRows.Layout.Row = 1;
            app.search_nRows.Layout.Column = [1 2];
            app.search_nRows.Interpreter = 'html';
            app.search_nRows.Text = {'0 <font style="font-size: 10px; margin-right: 2px;">HOMOLOGAÇÕES</font>'; '0 <font style="font-size: 10px;">REGISTROS </font>'};

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.UITable.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.UITable.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.UITable.RowName = {};
            app.UITable.RowStriping = 'off';
            app.UITable.ClickedFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @UITable_SelectionChanged, true);
            app.UITable.Layout.Row = [2 3];
            app.UITable.Layout.Column = 1;
            app.UITable.FontSize = 10;

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.Document);
            app.SubGrid1.ColumnWidth = {'1x', 18};
            app.SubGrid1.RowHeight = {'1x', 0};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.Padding = [0 0 0 0];
            app.SubGrid1.Layout.Row = [2 3];
            app.SubGrid1.Layout.Column = 2;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create search_ProductInfoImage
            app.search_ProductInfoImage = uiimage(app.SubGrid1);
            app.search_ProductInfoImage.ScaleMethod = 'none';
            app.search_ProductInfoImage.Layout.Row = 1;
            app.search_ProductInfoImage.Layout.Column = [1 2];
            app.search_ProductInfoImage.ImageSource = 'warning.svg';

            % Create search_ProductInfo
            app.search_ProductInfo = uilabel(app.SubGrid1);
            app.search_ProductInfo.VerticalAlignment = 'top';
            app.search_ProductInfo.WordWrap = 'on';
            app.search_ProductInfo.FontSize = 11;
            app.search_ProductInfo.Layout.Row = 1;
            app.search_ProductInfo.Layout.Column = [1 2];
            app.search_ProductInfo.Interpreter = 'html';
            app.search_ProductInfo.Text = '';

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.SubGrid1);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = 2;
            app.search_WordCloudPanel.Layout.Column = [1 2];

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.SubGrid1);
            app.jsBackDoor.Layout.Row = 2;
            app.jsBackDoor.Layout.Column = [1 2];

            % Create PopupTempWarning
            app.PopupTempWarning = uilabel(app.Grid1);
            app.PopupTempWarning.BackgroundColor = [0.2 0.2 0.2];
            app.PopupTempWarning.HorizontalAlignment = 'center';
            app.PopupTempWarning.WordWrap = 'on';
            app.PopupTempWarning.FontColor = [1 1 1];
            app.PopupTempWarning.Visible = 'off';
            app.PopupTempWarning.Layout.Row = 5;
            app.PopupTempWarning.Layout.Column = [2 4];
            app.PopupTempWarning.Text = '';

            % Create search_entryPointGrid
            app.search_entryPointGrid = uigridlayout(app.Grid1);
            app.search_entryPointGrid.ColumnWidth = {'1x', 28};
            app.search_entryPointGrid.RowHeight = {'1x'};
            app.search_entryPointGrid.ColumnSpacing = 0;
            app.search_entryPointGrid.RowSpacing = 0;
            app.search_entryPointGrid.Padding = [0 0 0 0];
            app.search_entryPointGrid.Layout.Row = [1 2];
            app.search_entryPointGrid.Layout.Column = 3;
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

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.Grid1);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = 3;
            app.search_Suggestions.Layout.Column = 3;
            app.search_Suggestions.Value = {};

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
            app.Tab1Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'search-sparkle-24px-yellow.svg');
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
            app.Tab2Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'checklist-24px-white.svg');
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
            app.Tab3Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'gear-24px-white.svg');
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 7;

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.NavBar);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear o Sharepoint'};
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 10;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ScaleMethod = 'none';
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 12;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 13;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'kebab-vertical-24px-white.svg');

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
