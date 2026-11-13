classdef mobile_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        TitleGrid                matlab.ui.container.GridLayout
        Image                    matlab.ui.control.Image
        AppInfo                  matlab.ui.control.Image
        AppTitle                 matlab.ui.control.Label
        ReturnButton             matlab.ui.control.Image
        TabGroup                 matlab.ui.container.TabGroup
        Tab1                     matlab.ui.container.Tab
        Grid1                    matlab.ui.container.GridLayout
        PopupTempWarning         matlab.ui.control.Label
        SearchSuggestions        matlab.ui.control.ListBox
        SearchResults            matlab.ui.control.Label
        ViewNextRangeButton      matlab.ui.control.Image
        ViewPreviousRangeButton  matlab.ui.control.Image
        ViewRange                matlab.ui.control.Label
        CurrentFilterPanel       matlab.ui.container.Panel
        CurrentFilterGrid        matlab.ui.container.GridLayout
        CurrentFilterColumn      matlab.ui.control.Label
        CurrentFilterText        matlab.ui.control.Label
        CurrentFilterStrategy    matlab.ui.control.Label
        CurrentFilterVisibility  matlab.ui.control.Image
        CurrentFilterLabel       matlab.ui.control.Label
        CurrentFilterIcon        matlab.ui.control.Image
        SearchSetupButton        matlab.ui.control.Image
        SearchEntryButton        matlab.ui.control.Image
        SearchEntryPoint         matlab.ui.control.EditField
        Tab2                     matlab.ui.container.Tab
        Tab3                     matlab.ui.container.Tab
        Tab4                     matlab.ui.container.Tab
        ContainerAuxApps         matlab.ui.container.Panel
        NavBar                   matlab.ui.container.GridLayout
        Tab4Button               matlab.ui.control.StateButton
        Tab3Button               matlab.ui.control.StateButton
        Tab2Button               matlab.ui.control.StateButton
        Tab1Button               matlab.ui.control.StateButton
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainAppMobile'
        Context = 'SEARCH'
        AppHandleNameInBase = ''
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        jsBackDoor

        General
        General_I

        launcherApp
        rootFolder
        tabGroupController
        renderCount = 0

        executionMode
        progressDialog
        popupContainer
        popupCurrentApp

        eFiscalizaObj
        filteringObj = tableFiltering
        wordCloudObj

        projectData
        
        schData
        schDataCategories
        releasedData
        cacheData
        cacheColumns
        annotationTable

        previousSuggestionIdx = 0
        searchResults = table()
        searchResultSituations = strings(0, 1)
        resultPageStart = 1
        resultContext = struct( ...
            'SCH',        struct('data', [], 'isRendered', false), ...
            'Annotation', struct('data', [], 'isRendered', false), ...
            'WordCloud',  struct('data', [], 'index', [], 'isRendered', false), ...
            'Images',     struct('data', {{}}, 'index', [], 'isRendered', false), ...
            'Ads',        struct('data', [], 'index', [], 'isRendered', false) ...
        )
        adLastUpdate = ''
    end


    properties (Constant, Access = private)
        %-----------------------------------------------------------------%
        MAX_RESULTS_PER_PAGE = 10
    end


    methods
        %-----------------------------------------------------------------%
        function ipcMainJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    % MATLAB-JS BRIDGE (matlabJSBridge.js)
                    case 'renderer'
                        % Pasta do launcher (pai de "+mainApp").
                        MFilePath   = fileparts(fileparts(mfilename('fullpath')));
                        parpoolFlag = true;

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        end
                        
                        app.renderCount = app.renderCount+1;
    
                    case 'unload'
                        closeFcn(app, event)

                    case 'textHighlight'
                        % Eventos originados de botões de um popup de um módulo auxiliar
                        % (dataTag com o campo "context") são repassados a esse módulo.
                        hData = event.HTMLEventData;
                        if isstruct(hData) && isfield(hData, 'dataTag') && isstruct(hData.dataTag) && isfield(hData.dataTag, 'context')
                            ipcMainMatlabCallAuxiliarApp(app, hData.dataTag.context, 'JS', event)
                        else
                            uialert(app.UIFigure, jsonencode(hData), '', 'Icon', 'success')
                        end

                    case 'openExternalURL'
                        url = event.HTMLEventData;
                        try
                            uri = matlab.net.URI(url);
                            isValid = ismember(uri.Scheme, ["http", "https"]) && ~isempty(uri.Host);
                        catch
                            isValid = false;
                        end

                        if isValid
                            web(url, '-browser')
                        end

                    case 'closeFcnCallFromPopupApp'
                        context = event.HTMLEventData.context;
                        popupCurrentAppTag = event.HTMLEventData.dockAppName;

                        switch context
                            case {'mainApp', app.Context}
                                hApp = app;
                            otherwise
                                hApp = getAppHandle(app.tabGroupController, context);
                        end
                        
                        if ~isempty(hApp) && isvalid(hApp)
                            deleteContextMenu(app.tabGroupController, hApp.UIFigure, popupCurrentAppTag)
                        end

                        delete(app.popupCurrentApp)
                        app.popupCurrentApp = [];

                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'getAuthenticatedUser'
                                createEFiscalizaObject(app, event.HTMLEventData)

                            case {'onFetchIssueDetails', 'onReportGenerate', 'onUploadArtifacts'}
                                eventName = event.HTMLEventData.uuid;
                                context = event.HTMLEventData.context;
                                
                                if isfield(event.HTMLEventData, 'error')
                                    ws.eFiscaliza.getCredentials('manual', app.executionMode, app.jsBackDoor, eventName, context);
                                    return
                                end

                                varargin = {};
                                if isfield(event.HTMLEventData, 'varargin')
                                    varargin = event.HTMLEventData.varargin;
                                    if ~iscell(varargin)
                                        varargin = {varargin};
                                    end
                                end

                                reportHandleOperation(app, eventName, context, event.HTMLEventData, varargin{:})
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    case 'findResourceStaticURL'
                        resourceURL = event.HTMLEventData;
                        if ~isempty(resourceURL)
                            app.General.AppVersion.application.resourceStaticURL = resourceURL;

                            % Atualiza o placeholder, renderizado possivelmente antes da URL estar disponível.
                            if isempty(app.searchResults) && isempty(app.SearchResults.Text)
                                app.SearchResults.Text = createWarningPlaceholder(app);
                            end
                        end

                    case 'backgroundBecameTransparent'
                        switch event.HTMLEventData
                            case 'PopupTempWarning'
                                app.PopupTempWarning.Visible = "off";

                            otherwise
                                error('UnexpectedEvent')
                        end

                    case 'onMobileSearchResultDetailsRequested'
                        resultIdx = str2double(event.HTMLEventData);
                        showSearchResultDetails(app, resultIdx)

                    case 'onMobileSearchResultAddRequested'
                        resultIdx = str2double(event.HTMLEventData);
                        addSearchResultToInspected(app, resultIdx)
    
                    case 'mainApp.searchEntryPoint'
                        % HTMLEventData é uma estrutura com os campos "key" 
                        % (tecla pressionada) e "value" (valor atual do campo).
                        keydownPressed    = event.HTMLEventData.key;
                        currentInputValue = event.HTMLEventData.value;

                        % Força-se a atualização da propriedade "Value" porque, 
                        % apesar de na GUI já constar um valor novo, este ainda 
                        % não foi devidamente atualizado.
                        app.SearchEntryPoint.Value = currentInputValue;    
                        switch keydownPressed
                            case {'Escape', 'Tab'}
                                if numel(currentInputValue) < app.General.context.SEARCH.minCharacters
                                    setComponentsState(app, 'entryDisabled')
                                end
    
                                if strcmp(keydownPressed, 'Tab') && app.SearchEntryButton.Enable
                                    focus(app.SearchEntryButton)
                                end
    
                                pause(.050)
                                set(app.SearchSuggestions, Visible=0, Value={})
    
                            otherwise
                                if numel(currentInputValue) >= app.General.context.SEARCH.minCharacters
                                    switch keydownPressed
                                        case 'ArrowDown'
                                            if strcmp(app.General.context.SEARCH.mode, 'tokens')
                                                app.previousSuggestionIdx = 1;
    
                                                set(app.SearchSuggestions, 'Visible', 1, 'Value', 1)
                                                scroll(app.SearchSuggestions, "top")
                                                focus(app.SearchSuggestions)
                                            end
    
                                        case 'ArrowUp'
                                            if strcmp(app.General.context.SEARCH.mode, 'tokens')
                                                nMaxValues = numel(app.SearchSuggestions.Items);
    
                                                app.previousSuggestionIdx = nMaxValues;
                                                set(app.SearchSuggestions, 'Visible', 1, 'Value', nMaxValues)
                                                scroll(app.SearchSuggestions, "bottom")
                                                focus(app.SearchSuggestions)
                                            end
    
                                        case 'Enter'
                                            drawnow
                                            onSearchEntryButtonPushed(app)                                        
                                            set(app.SearchSuggestions, Visible=0, Value={})
                                    end
                                end
                        end
    
                    case 'mainApp.searchSuggestions'
                        % HTMLEventData é uma string com a indicação da tecla
                        % pressionada.
                        switch event.HTMLEventData
                            case 'ArrowDown'
                                nMaxValues = numel(app.SearchSuggestions.Items);
    
                                if (app.previousSuggestionIdx == nMaxValues) && (app.SearchSuggestions.Value == nMaxValues)
                                    app.previousSuggestionIdx = 0;
    
                                    set(app.SearchSuggestions, Visible=0, Value={})
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.SearchEntryPoint.UserData.id));
                                else
                                    if isnumeric(app.SearchSuggestions.Value)
                                        app.previousSuggestionIdx = app.SearchSuggestions.Value;
                                    else
                                        app.previousSuggestionIdx = 0;
                                    end
                                end
    
                            case 'ArrowUp'
                                if (app.previousSuggestionIdx == 1) && (app.SearchSuggestions.Value == 1)
                                    app.previousSuggestionIdx = 0;
    
                                    set(app.SearchSuggestions, Visible=0, Value={})
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.SearchEntryPoint.UserData.id));
                                else
                                    if isnumeric(app.SearchSuggestions.Value)
                                        app.previousSuggestionIdx = app.SearchSuggestions.Value;
                                    else
                                        app.previousSuggestionIdx = 0;
                                    end
                                end
    
                            case {'Enter', 'Tab'}
                                if isnumeric(app.SearchSuggestions.Value)
                                    eventValue = app.SearchSuggestions.Items{app.SearchSuggestions.Value};
    
                                    app.SearchEntryPoint.Value = eventValue;
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.SearchEntryPoint.UserData.id));
                                    app.SearchSuggestions.Visible = "off";
                                    drawnow

                                    onSearchEntryPointChanging(app, struct('Value', eventValue, 'ListBoxVisibility', false))
                                end
    
                            case 'Escape'
                                set(app.SearchSuggestions, Visible=0, Value={})
                        end

                    case 'indexedDB'
                        switch event.HTMLEventData.operation
                            case 'openDB'
                                if strcmp(event.HTMLEventData.status, 'success')
                                    appEngine.indexedDB.loadData(app.jsBackDoor, class.Constants.appName, 'prjData')
                                end

                            case 'saveData'
                                % ...

                            case 'loadData'
                                if isfield(event.HTMLEventData, 'data') && ~isempty(event.HTMLEventData.data)
                                    prjData = event.HTMLEventData.data;

                                    if numel(prjData.inspectedProducts) > 0
                                        if isempty(prjData.name)
                                            prjData.name = '(NÃO DEFINIDO)';
                                        end
    
                                        msgQuestion = sprintf([ ...
                                            'Foram encontrados dados salvos localmente de uma sessão anterior.<br><br>' ...
                                            'Última atualização: <b>%s</b><br>' ...
                                            'Nome do projeto: "<b>%s</b>"<br>' ...
                                            'Quantidade de produtos inspecionados: <b>%d</b><br><br>' ...
                                            'Deseja continuar o trabalho com esses dados ou iniciar uma nova sessão?' ...
                                        ], prjData.timestamp, prjData.name, numel(prjData.inspectedProducts));
        
                                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Usar dados salvos', 'Apagar e iniciar nova sessão'}, 1, 2);
                                        switch userSelection
                                            case 'Usar dados salvos'
                                                msg = load(app.projectData, "indexedDB", prjData);
                                                
                                                if ~isempty(msg)
                                                    error('mainApp:mobile:IndexedDB', msg)
                                                end
        
                                            case 'Apagar e iniciar nova sessão'
                                                appEngine.indexedDB.deleteData(app.jsBackDoor, class.Constants.appName, 'prjData')
                                        end
                                    end
                                end

                            case 'deleteData'
                                % ...
                        end
    
                    otherwise
                        error('mainApp:mobile:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
                end
                drawnow

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, eventName, varargin)
            varargout = {};

            try
                switch class(callingApp)
                    case {'auxApp.mobileSearchAddSelectedToBucket', 'auxApp.mobileSearchAddSelectedToBucket_exported'}
                        switch eventName
                            case 'onAddSelectedToBucketRequest'
                                schDetailedIdxs = varargin{1};

                                applyLayout(app, 'mainAppMobile')
                                delete(app.popupCurrentApp)
                                app.popupCurrentApp = [];

                                addInspectedProducts(app, schDetailedIdxs)

                            otherwise
                                error('mainApp:mobile:UnexpectedEvent', 'Unexpected event "%s"', eventName)
                        end

                    case {'auxApp.mobileSearchFilter', 'auxApp.mobileSearchFilter_exported'}
                        switch eventName
                            case 'onSearchModeChanged'
                                app.SearchEntryButton.UserData = struct('valueToSearch', '', 'wordsToSearch', {{}});
                                setComponentsState(app, 'searchInitial')
            
                            case 'onColumnFilterChanged'
                                if strcmp(app.General.context.SEARCH.type, 'ColumnFilter') || (strcmp(app.General.context.SEARCH.type, 'FreeText+ColumnFilter') && ~isempty(app.searchResults))
                                    applyFiltering(app)
                                else
                                    updateSearchContext(app)
                                end

                            otherwise
                                error('mainApp:mobile:UnexpectedEvent', 'Unexpected event "%s"', eventName)
                        end
    
                        applyLayout(app, 'mainAppMobile')
    
                    case {'auxApp.mobileProductInfo', 'auxApp.mobileProductInfo_exported'}
                        switch eventName
                            case 'onInspectedProductEdited'
                                context  = varargin{1};
                                varargin = [{eventName}, varargin(2:end)];
                                ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})

                            otherwise
                                error('mainApp:mobile:UnexpectedEvent', 'Unexpected event "%s"', eventName)
                        end
    
                    otherwise
                        error('mainApp:mobile:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = getAppHandle(app.tabGroupController, auxAppName);
            if isempty(hAuxApp) || ~isvalid(hAuxApp)
                return
            end

            switch communicationType
                case 'MATLAB'
                    operationType = varargin{1};
                    ipcSecondaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                case 'JS'
                    ipcSecondaryJSEventsHandler(hAuxApp, varargin{1})
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabOpenPopupApp(app, callingApp, auxAppName, context, varargin)
            arguments
                app
                callingApp
                auxAppName char {mustBeMember(auxAppName, {'SearchAddSelectedToBucket', 'SearchFilter', 'ProductInfo'})}
                context char {mustBeMember(context, {'mainApp', 'SEARCH', 'PRODUCTS', 'REPORT'})}
            end

            arguments (Repeating)
                varargin 
            end

            auxDockAppName = sprintf('auxApp.mobile%s', auxAppName);
            if ~isempty(app.popupCurrentApp) && isvalid(app.popupCurrentApp)
                if contains(class(app.popupCurrentApp), auxDockAppName)
                    ipcSecondaryMatlabCallsHandler(app.popupCurrentApp, app, 'updateForm', varargin{:})
                    applyLayout(app, 'secondaryDockAppMobile')
                    return
                end

                delete(app.popupCurrentApp)
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')

            inputArguments = [{app, callingApp, context}, varargin];
            
            if app.General.operationMode.Debug
                app.popupCurrentApp = feval(auxDockAppName, inputArguments{:});
                app.popupCurrentApp.isDocked = false;

            else
                auxAppContainer = app.ContainerAuxApps;
                app.popupCurrentApp = feval([auxDockAppName '_exported'], auxAppContainer, inputArguments{:});
                applyLayout(app, 'secondaryDockAppMobile')
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.Tab1Button;
                app.Tab2Button;
                app.Tab3Button;
                app.Tab4Button;
                app.TitleGrid;
                app.AppInfo;
                app.SearchEntryPoint;
                app.CurrentFilterPanel;
                app.SearchResults;
                app.SearchSuggestions; % Invisível na inicialização
                app.PopupTempWarning;  % Invisível na inicialização
                app.ContainerAuxApps   % Invisível na inicialização
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);
    
            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.Tab1Button.UserData.id,         'generation', 1, 'class', {{'tab-navigator-button', 'tab-navigator-button--mobile'}}), ...
                    struct('appName', appName, 'dataTag', app.Tab2Button.UserData.id,         'generation', 1, 'class', {{'tab-navigator-button', 'tab-navigator-button--mobile'}}), ...
                    struct('appName', appName, 'dataTag', app.Tab3Button.UserData.id,         'generation', 1, 'class', {{'tab-navigator-button', 'tab-navigator-button--mobile'}}), ...
                    struct('appName', appName, 'dataTag', app.Tab4Button.UserData.id,         'generation', 1, 'class', {{'tab-navigator-button', 'tab-navigator-button--mobile'}}), ...
                    struct('appName', appName, 'dataTag', app.TitleGrid.UserData.id,          'styleImportant', struct('borderRadius', '0')), ...
                    struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id,   'generation', 1, 'style', struct('borderColor', '#AEBBC2', 'borderRadius', '8px 0 0 0')), ...
                    struct('appName', appName, 'dataTag', app.CurrentFilterPanel.UserData.id, 'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id,   'selector', 'input', 'style', struct('paddingRight', '60px')), ...
                    struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id,  'generation', 1, 'style', struct('borderColor', '#AEBBC2', 'borderTop', '0')), ...
                    struct('appName', appName, 'dataTag', app.ContainerAuxApps.UserData.id,   'style', struct('borderRadius', '0 0 5px 5px')), ...
                    struct('appName', appName, 'dataTag', app.PopupTempWarning.UserData.id,   'style', struct('borderRadius', '8px', 'pointerEvents', 'none')), ...
                    struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id,   'generation', 2, 'listener', struct('componentName', 'mainApp.searchEntryPoint',  'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})), ...
                    struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id,  'generation', 1, 'listener', struct('componentName', 'mainApp.searchSuggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                });
            catch
            end

            try
                ui.TextView.startup(app.jsBackDoor, app.SearchResults, appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
            catch
            end
        end

        %-----------------------------------------------------------------%
        function loadConfigurationFile(app, appName, MFilePath)
            % "GeneralSettings.json" (lido pelo launcher)
            app.General_I = app.launcherApp.General_I;
            tempDir = app.General_I.fileFolder.tempPath;
            app.General_I.operationMode.Debug = false;

            app.General = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            app.General.AppVersion.browser = app.launcherApp.navigatorBasicInformation;
            if isempty(app.General.AppVersion.browser)
                sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')
            end

            % Ideia é identificar URL de pasta estática servida pelo backend, de 
            % forma que possam ser inseridas imagens em uilabel (como ui.TextView).
            try
                [~, resourceName, resourceExt] = fileparts(app.AppInfo.ImageSource);
                sendEventToHTMLSource(app.jsBackDoor, 'findResourceStaticURL', struct('resourceName', [resourceName resourceExt], 'resourceTag', 'img', 'resourceId', app.AppInfo.UserData.id))
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = model.Project(app, app.rootFolder);
            
            if ~strcmp(app.executionMode, 'desktopStandaloneApp') && app.General.reportLib.indexedDBCache.status
                appEngine.indexedDB.openDB(app.jsBackDoor, class.Constants.appName)
            end

            if strcmp(app.executionMode, 'webApp')
                url = ws.eFiscaliza.CURRENT_USER_URL;
                sendEventToHTMLSource(app.jsBackDoor, 'getAuthenticatedUser', struct('eventName', 'getAuthenticatedUser', 'context', app.Context, 'url', url));
            end

            % Bases de dados lidas pelo launcher.
            app.schData           = app.launcherApp.schData;
            app.schDataCategories = app.launcherApp.schDataCategories;
            app.releasedData      = app.launcherApp.releasedData;
            app.cacheData         = app.launcherApp.cacheData;
            app.cacheColumns      = app.launcherApp.cacheColumns;
            app.annotationTable   = app.launcherApp.annotationTable;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.AppTitle.Text = sprintf('<font style="font-size: 16px; line-height: 16px;"><b>SCH+</b></font><br>v.%s', class.Constants.appVersion);
            app.SearchEntryButton.UserData = struct('valueToSearch', '', 'wordsToSearch', {{}});
            app.CurrentFilterPanel.UserData.status = true;
            app.CurrentFilterPanel.BorderColor = '#c9d9ec';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            app.tabGroupController = ui.TabNavigator(app);
            addComponent(app.tabGroupController, "Built-in", "",                       app.Tab1Button, "AlwaysOn", matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.mobileProducts",  app.Tab2Button, "AlwaysOn", app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.mobileReportLib", app.Tab3Button, "AlwaysOn", app.Tab1Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.mobileConfig",    app.Tab4Button, "AlwaysOn", app.Tab1Button,                      4)
            app.Tab1Button.Value = true;

            if any(app.filteringObj.filterRules.Enable)
                app.filteringObj.filterRules.Enable(:) = false;
            end

            setComponentsState(app, 'searchInitial')
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyLayout(app, mode)
            switch mode
                case 'mainAppMobile'
                    set([app.AppInfo, app.TabGroup], 'Visible', 'on')
                    set([app.ContainerAuxApps, app.ReturnButton], 'Visible', 'off')
                    app.TabGroup.Layout.Row = [1 2];

                case 'secondaryDockAppMobile'
                    set([app.AppInfo, app.TabGroup], 'Visible', 'off')
                    set([app.ContainerAuxApps, app.ReturnButton], 'Visible', 'on')
                    app.TabGroup.Layout.Row = 1;
            end
        end

        %-----------------------------------------------------------------%
        function setComponentsState(app, state)
            arguments
                app
                state char {mustBeMember(state, {'searchInitial', 'entryEnabled', 'entryDisabled', 'resultsRange', 'rangeControlsVisible', 'rangeControlsInvisible'})}
            end

            switch state
                case 'searchInitial'
                    switch app.General.context.SEARCH.type
                        case {'FreeText', 'FreeText+ColumnFilter'}
                            enable = true;
                            value = app.SearchEntryButton.UserData.valueToSearch;
                            placeholder = 'O que você quer pesquisar?';
                            
                        otherwise % 'ColumnFilter'
                            enable = false;
                            value = '';
                            placeholder = 'Busca por texto indisponível neste modo';
                    end

                    set(app.SearchEntryPoint, 'Enable', enable, 'Value', value, 'Placeholder', placeholder, 'FontColor', [0,0,0])
                    app.SearchSuggestions.Visible = 0;
                    app.previousSuggestionIdx = 0;

                    onSearchEntryPointChanging(app, struct('Value', value, 'ListBoxVisibility', false))

                    app.searchResults = table();
                    app.searchResultSituations = strings(0, 1);
                    app.resultPageStart = 1;
                    app.SearchResults.Text = createWarningPlaceholder(app);
                    set([app.ViewPreviousRangeButton, app.ViewNextRangeButton], 'Visible', 0)
                    setComponentsState(app, 'resultsRange')
                    updateSearchContext(app)

                case 'rangeControlsVisible'
                    set([app.ViewPreviousRangeButton, app.ViewNextRangeButton], 'Visible', 1)

                case 'rangeControlsInvisible'
                    set([app.ViewPreviousRangeButton, app.ViewNextRangeButton], 'Visible', 0)

                case 'entryEnabled'
                    app.SearchEntryButton.Enable = 1;

                case 'entryDisabled'
                    app.SearchEntryButton.Enable = 0;
                    set(app.SearchSuggestions, Visible=0, Items={}, ItemsData=[])

                case 'resultsRange'
                    nResults = height(app.searchResults);
                    firstIdx = app.resultPageStart;
                    lastIdx  = min(firstIdx + app.MAX_RESULTS_PER_PAGE - 1, nResults);

                    if nResults == 0
                        app.ViewRange.Text = '';
                    else
                        app.ViewRange.Text = sprintf('%d-%d de %d', firstIdx, lastIdx, nResults);
                    end

                    app.ViewPreviousRangeButton.Enable = firstIdx > 1;
                    app.ViewNextRangeButton.Enable     = lastIdx < nResults;
            end
        end

        %-----------------------------------------------------------------%
        function applyFiltering(app)
            app.progressDialog.Visible = 'visible';

            hasWordsToSearch = ~isempty(app.SearchEntryButton.UserData.wordsToSearch);
            hasColumnFilters = any(app.filteringObj.filterRules.Enable);

            matchRowIdxs = [];
            switch app.General.context.SEARCH.type
                case 'FreeText'
                    if hasWordsToSearch
                        matchRowIdxs = applyTextFilter(app);
                    end

                case 'ColumnFilter'
                    if hasColumnFilters
                        matchRowIdxs = (1:height(app.schData.detailed))';
                        matchRowIdxs = applyColumnFilter(app, matchRowIdxs);
                    end

                case 'FreeText+ColumnFilter'
                    if hasWordsToSearch
                        matchRowIdxs = applyTextFilter(app);
                    end

                    if hasColumnFilters
                        if isempty(matchRowIdxs)
                            matchRowIdxs = (1:height(app.schData.detailed))';
                        end
                        matchRowIdxs = applyColumnFilter(app, matchRowIdxs);
                    end
            end
            updateResults(app, matchRowIdxs)
            updateSearchContext(app)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function updateSearchContext(app)
            searchType = app.General.context.SEARCH.type;
            searchMode = app.General.context.SEARCH.mode;

            switch searchType
                case 'FreeText'
                    searchStrategy = 'Texto livre';
                    app.CurrentFilterText.Visible = 'on';
                    app.CurrentFilterColumn.Visible = 'off';
                    app.CurrentFilterText.Layout.Column = [3 6];

                case 'ColumnFilter'
                    searchStrategy = 'Filtro por coluna';
                    app.CurrentFilterText.Visible = 'off';
                    app.CurrentFilterColumn.Visible = 'on';
                    app.CurrentFilterColumn.Layout.Column = [3 6];

                case 'FreeText+ColumnFilter'
                    searchStrategy = 'Texto livre +<br>Filtro por coluna';
                    set([app.CurrentFilterText, app.CurrentFilterColumn], 'Visible', 'on')
                    app.CurrentFilterText.Layout.Column = [3 4];
                    app.CurrentFilterColumn.Layout.Column = [5 6];
            end
            app.CurrentFilterStrategy.Text = sprintf('Estratégia:<br><font style="font-size:11px; color: #00213d;">%s</font>', searchStrategy);

            if contains(searchType, 'FreeText')
                searchData = app.SearchEntryButton.UserData;
                searchTextValue = '';

                switch searchMode
                    case 'tokens'
                        searchTextMode  = 'Similaridade';
                        if ~isempty(searchData.valueToSearch)
                            searchTextValue = sprintf('"%s"', searchData.valueToSearch);
                        end

                    otherwise % 'words'
                        searchTextMode  = 'Exata';
                        if ~isempty(searchData.wordsToSearch)
                            searchTextValue = textFormatGUI.cellstr2FriendlyListWithQuotes(searchData.wordsToSearch);
                        end
                end
                app.CurrentFilterText.Text = sprintf('Pesquisa textual:<br><font style="font-size:11px; color: #00213d;">%s<br>%s</font>', searchTextMode, searchTextValue);

            else
                app.CurrentFilterText.Text = '';
            end

            if contains(searchType, 'ColumnFilter')
                filterList = getFilterList(app.filteringObj, 'SCH', 'on');
                
                if isempty(filterList)
                    app.CurrentFilterColumn.Text = 'Filtros por coluna:<br><font style="font-size:11px; color: #00213d;">Nenhum aplicado</font>';
                elseif isscalar(filterList)
                    app.CurrentFilterColumn.Text = 'Filtros por coluna:<br><font style="font-size:11px; color: #00213d;">Um aplicado</font>';
                else
                    app.CurrentFilterColumn.Text = sprintf('Filtros por coluna:<br><font style="font-size:11px; color: #00213d;">%d aplicados</font>', numel(filterList));
                end

            else
                app.CurrentFilterColumn.Text = '';
            end
        end

        %-----------------------------------------------------------------%
        function ruleText = formatColumnFilterRule(~, filterRule)
            operators = filterRule.Operators{1};
            values    = filterRule.Values{1};

            switch lower(filterRule.Connector{1})
                case {'and', 'e'}
                    connector = ' e ';
                otherwise
                    connector = ' ou ';
            end

            operatorNames = containers.Map( ...
                {'begins with', 'does not begin with', 'ends with', 'does not end with', 'contains', 'does not contain'}, ...
                {'começa com', 'não começa com', 'termina com', 'não termina com', 'contém', 'não contém'} ...
            );

            conditions = strings(1, numel(operators));
            for ii = 1:numel(operators)
                operator = operators{ii};
                value = strjoin(string(values{ii}), ', ');

                if isKey(operatorNames, operator)
                    operator = operatorNames(operator);
                end

                if isscalar(operators) && strcmp(operator, '=')
                    conditions(ii) = value;
                else
                    conditions(ii) = sprintf('%s %s', operator, value);
                end
            end

            ruleText = sprintf('%s: %s', filterRule.Field{1}, strjoin(conditions, connector));
        end

        %-----------------------------------------------------------------%
        function htmlLink = createSearchActionLink(app, eventName, resultIdx, iconName, tooltip, pixels)
            htmlLink = ui.TextView.createHTMLLink('customImage', app.AppHandleNameInBase, eventName, num2str(resultIdx), iconName, pixels, pixels, app.General);
            htmlLink = sprintf('<span title="%s">%s</span>', tooltip, htmlLink);
        end

        %-----------------------------------------------------------------%
        function showSearchResultDetails(app, resultIdx)
            if ~isscalar(resultIdx) || ~isfinite(resultIdx) || resultIdx < 1 || resultIdx > height(app.searchResults)
                return
            end

            homologation = char(string(app.searchResults.('Homologação')(resultIdx)));
            relatedSCH = app.schData.detailed(strcmp(app.schData.detailed.('Homologação'), homologation), :);

            situation = char(relatedSCH.("Situação")(1));
            situationColor = getSituationColor(app, situation);

            annotations = app.annotationTable(strcmp(app.annotationTable.('Homologação'), homologation), :);
            images = unique(annotations(strcmp(annotations.('Atributo'), 'Image'), :).Valor);
            wordClouds = annotations(strcmp(annotations.('Atributo'), 'WordCloud'), :);

            adsMask = strcmp(app.projectData.regulatronData.adsTable.('certificado'), replace(homologation, '-', ''));
            ads = app.projectData.regulatronData.adsTable(adsMask, :);

            htmlContent = util.HtmlTextGenerator.ProductInfo( ...
                'ProdutoHomologado - Mobile', ...
                relatedSCH, ...
                height(wordClouds), ...
                numel(images), ...
                ads ...
            );
            sendEventToHTMLSource(app.jsBackDoor, 'textHighlight', struct( ...
                'dataTag', homologation, ...
                'imageUrl', 'package.svg', ...
                'title', sprintf('%s <font style="color: %s; font-size: 11px;">%s</font>', homologation, situationColor, situation), ...
                'width', 85, ...
                'height', 60, ...
                'html', htmlContent ...
            ));
        end

        %-----------------------------------------------------------------%
        function addSearchResultToInspected(app, resultIdx)
            if ~isscalar(resultIdx) || ~isfinite(resultIdx) || resultIdx < 1 || resultIdx > height(app.searchResults)
                return
            end

            homologation = char(string(app.searchResults.('Homologação')(resultIdx)));
            schDetailedIdxs = find(strcmp(app.schData.detailed.('Homologação'), homologation));

            schDetailed = app.schData.detailed(schDetailedIdxs, {'Homologação', 'Solicitante', 'Fabricante', 'Modelo', 'Nome Comercial'});
            [~, schDetailedUniqueFirstIdxs] = unique(schDetailed, 'rows');
            schDetailedIdxs = schDetailedIdxs(sort(schDetailedUniqueFirstIdxs));

            if numel(schDetailedIdxs) > 1
                % Abre o módulo de seleção apenas se houver ao menos um produto ainda não incluído.
                if all(isInspectedProduct(app, schDetailedIdxs))
                    showPopupTempWarning(app, model.ProjectBase.WARNING_ENTRYEXIST.SEARCH)
                else
                    ipcMainMatlabOpenPopupApp(app, app, 'SearchAddSelectedToBucket', app.Context, schDetailedIdxs)
                end
                return
            end

            addInspectedProducts(app, schDetailedIdxs)
        end

        %-----------------------------------------------------------------%
        function isIncluded = isInspectedProduct(app, schDetailedIdxs)
            isIncluded = false(size(schDetailedIdxs));

            for ii = 1:numel(schDetailedIdxs)
                [~, productHash] = model.ProjectBase.initializeInspectedProduct( ...
                    'Homologado', app.General, app.schData.detailed, schDetailedIdxs(ii));
                isIncluded(ii) = ismember(productHash, app.projectData.inspectedProducts.('Hash'));
            end
        end

        %-----------------------------------------------------------------%
        function addInspectedProducts(app, schDetailedIdxs)
            addedCount = 0;

            for ii = 1:numel(schDetailedIdxs)
                idx = schDetailedIdxs(ii);
                [productData, productHash] = model.ProjectBase.initializeInspectedProduct( ...
                    'Homologado', app.General, app.schData.detailed, idx);

                if ismember(productHash, app.projectData.inspectedProducts.('Hash'))
                    continue
                end

                updateInspectedProducts(app.projectData, 'add', productData)
                addedCount = addedCount + 1;
            end

            if addedCount > 0
                ipcMainMatlabCallAuxiliarApp(app, 'PRODUCTS', 'MATLAB', 'updateInspectedProducts')
                if addedCount == 1
                    showPopupTempWarning(app, 'Incluído um registro na lista de produtos inspecionados.')
                else
                    showPopupTempWarning(app, sprintf('Incluídos %d registros na lista de produtos inspecionados.', addedCount))
                end
            else
                showPopupTempWarning(app, model.ProjectBase.WARNING_ENTRYEXIST.SEARCH)
            end
        end

        %-----------------------------------------------------------------%
        function showPopupTempWarning(app, msg)
            set(app.PopupTempWarning, 'Text', msg, 'Visible', 'on')
            sendEventToHTMLSource(app.jsBackDoor, 'setBackgroundTransparent', struct('componentName', 'PopupTempWarning', 'componentDataTag', app.PopupTempWarning.UserData.id, 'interval_ms', 75));
            drawnow
        end

        %-----------------------------------------------------------------%
        function matchRowIdxs = applyTextFilter(app)
            switch app.General.context.SEARCH.mode
                case 'tokens'
                    sortOrder = 'stable';
                otherwise
                    sortOrder = 'unstable';
            end

            cacheColumnNames = strcat({'_'}, strsplit(app.cacheColumns, ' | '));
            searchFunction   = app.General.context.SEARCH.function;
            wordsToSearch    = app.SearchEntryButton.UserData.wordsToSearch;

            matchRowTempIdxs = run(app.filteringObj, 'wordsToSearch', app.schData.detailed, cacheColumnNames, sortOrder, searchFunction, wordsToSearch);
            matchHomList     = unique(app.schData.detailed(matchRowTempIdxs,:).("Homologação"), 'stable');
            matchRowIdxs     = run(app.filteringObj, 'wordsToSearch', app.schData.detailed, {'Homologação'}, sortOrder, 'strcmp', matchHomList);
        end

        %-----------------------------------------------------------------%
        function matchRowIdxs = applyColumnFilter(app, matchRowIdxs)
            matchRowTempIdxs = run(app.filteringObj, 'filterRules', app.schData.detailed(matchRowIdxs, :));
            matchRowIdxs = matchRowIdxs(matchRowTempIdxs);
        end

        %-----------------------------------------------------------------%
        function updateResults(app, matchRowIdxs)
            aggregatedIdxs = unique(app.schData.detailed.("Índice Homologação Agregada")(matchRowIdxs), 'stable');
            aggregatedResults = app.schData.aggregated(aggregatedIdxs, :);
            app.searchResults = aggregatedResults;
            app.resultPageStart = 1;

            [~, firstDetailedIdxs] = ismember(aggregatedIdxs, app.schData.detailed.("Índice Homologação Agregada"));
            app.searchResultSituations = string(app.schData.detailed.("Situação")(firstDetailedIdxs));

            if ~isempty(matchRowIdxs)
                setComponentsState(app, 'rangeControlsVisible')
            else
                setComponentsState(app, 'rangeControlsInvisible')
            end

            renderSearchResults(app)
        end

        %-----------------------------------------------------------------%
        function renderSearchResults(app)
            nResults = height(app.searchResults);

            if nResults == 0
                app.SearchResults.Text = '';
            else
                if isempty(app.AppHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', app.AppHandleNameInBase, app.AppHandleNameInBase, class(app), app.AppHandleNameInBase))
                    app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
                end

                pageIdxs = app.resultPageStart:min(app.resultPageStart + app.MAX_RESULTS_PER_PAGE - 1, nResults);
                resultItems = strings(numel(pageIdxs), 1);
                for ii = 1:numel(pageIdxs)
                    resultItems(ii) = createResultCard(app, pageIdxs(ii));
                end
                app.SearchResults.Text = char(join(resultItems, newline));
            end

            setComponentsState(app, 'resultsRange')
        end

        %-----------------------------------------------------------------%
        function htmlCard = createResultCard(app, resultIdx)
            % resultIdx: índice em app.searchResults (e não na página exibida).
            situation = app.searchResultSituations(resultIdx);
            situationColor = getSituationColor(app, situation);
            modelName = strjoin(unique(strtrim([string(app.searchResults.('Modelo')(resultIdx)); string(app.searchResults.('Nome Comercial')(resultIdx))]), 'stable'), ' • ');
            detailsButton = createSearchActionLink(app, 'onMobileSearchResultDetailsRequested', resultIdx, 'file-text.svg', 'Ver mais informações', 16);
            addButton = createSearchActionLink(app, 'onMobileSearchResultAddRequested', resultIdx, 'add-to-card.svg', 'Incluir nos produtos sob análise', 20);

            htmlCard = sprintf([ ...
                '<section style="background-color: white; margin: 0 2px 0 0; padding: 10px; border: 1px solid #d7dce0; border-radius: 8px;">' ...
                    '<table style="width: 100%%;"><tbody><tr>' ...
                        '<td style="background-color: %s; width: 5px;"></td>' ...
                        '<td style="padding-left: 10px;"><p>' ...
                            '<font style="color: rgb(32, 32, 32); font-size: 16px;"><b>%s</b></font><br>' ...
                            '<font style="color: %s;"><b>%s</b></font><br>' ...
                            '<font style="color: rgb(96, 96, 96);">%s</font><br>' ...
                            '<font style="color: rgb(96, 96, 96);">%s</font>' ...
                        '</p></td>' ...
                        '<td style="width: 34px;">%s</td>' ...
                        '<td style="width: 20px;">%s</td>' ...
                    '</tr></tbody></table>' ...
                '</section>' ...
            ], ...
                situationColor, ...
                escapeHtml(app, app.searchResults.('Homologação')(resultIdx)), ...
                situationColor, ...
                escapeHtml(app, situation), ...
                escapeHtml(app, app.searchResults.('Solicitante')(resultIdx)), ...
                escapeHtml(app, modelName), ...
                detailsButton, ...
                addButton ...
            );
        end

        %-----------------------------------------------------------------%
        function htmlPlaceholder = createWarningPlaceholder(app)
            title = 'Nenhuma pesquisa realizada';
            message = 'Informe os critérios de busca<br>para visualizar os resultados';
            htmlPlaceholder = util.HtmlTextGenerator.createWarningPlaceholder(app.General, title, message);
        end

        %-----------------------------------------------------------------%
        function color = getSituationColor(~, situation)
            switch string(situation)
                case "Homologação Emitida"
                    color = '#75c368'; % 'rgb(79, 127, 103)';
                case {"Homologação Anulada", "Homologação Cancelada", "Homologação Suspensa", "Homologação Vencida"}
                    color = '#ea6071'; % 'rgb(192, 57, 43)';
                otherwise
                    color = '#84939d'; % 'rgb(128, 128, 128)';
            end
        end

        %-----------------------------------------------------------------%
        function escapedValue = escapeHtml(~, value)
            escapedValue = char(value);
            escapedValue = replace(escapedValue, {'&', '<', '>', '"', ''''}, {'&amp;', '&lt;', '&gt;', '&quot;', '&#39;'});
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, launcherApp)
            
            try
                app.launcherApp = launcherApp;
                app.jsBackDoor = launcherApp.jsBackDoor;
                app.progressDialog = launcherApp.progressDialog;
                app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @onFigureWindowButtonDown, true);

                appEngine.boot(app, app.Role)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            if exist('event', 'var') && isfield(struct(event), 'Source') && event.Source == app.Container
                if strcmp(app.progressDialog.Visible, 'visible')
                    app.progressDialog.Visible = 'hidden';
                    return
                end
    
                msgQuestion = '';
                if checkIfUpdateNeeded(app.projectData)
                    msgQuestion = sprintf([ ...
                        'O projeto "%s" foi modificado (nome, arquivo de saída ou ' ...
                        'lista de produtos inspecionados). Caso o aplicativo seja encerrado ' ...
                        'agora, as alterações não serão registradas em arquivo.\n\n' ...
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
            end

            IndexedDBCache(app.projectData)

            delete(app)

        end

        % Window button down function: UIFigure
        function onFigureWindowButtonDown(app, event)
            
            % O listener que captura cliques do mouse só é aplicável no
            % modo SEARCH.
            if app.TabGroup.SelectedTab == app.TabGroup.Children(1)
                return
            end

            event = struct(event);
            if isfield(event, 'HitObject')
                hitObject = event.HitObject;
            else
                hitObject = event.Source;
            end

            switch hitObject
                case app.SearchEntryPoint
                    if ~isempty(app.SearchEntryPoint.Value)
                        if strcmp(app.General.context.SEARCH.mode, 'tokens')
                            if numel(app.SearchEntryPoint.Value) >= app.General.context.SEARCH.minCharacters
                                app.SearchSuggestions.Visible = 1;
                            end
                        end
                    end

                case app.SearchSuggestions
                    if isempty(app.SearchSuggestions.Value)
                        matlab.waitfor(app.SearchSuggestions, 'Value', @(propValue) ~isempty(propValue), .075, 1, 'propValue')
                    end

                    ipcMainJSEventsHandler(app, struct('HTMLEventName', 'mainApp.searchSuggestions', 'HTMLEventData', 'Enter'))

                otherwise
                    set(app.SearchSuggestions, Visible=0, Value={})
                    if isempty(app.SearchEntryPoint.Value)
                        setComponentsState(app, 'entryDisabled')
                    end
            end

        end

        % Image clicked function: SearchEntryButton
        function onSearchEntryButtonPushed(app, event)
            
            valueToSearch = textAnalysis.preProcessedData(app.SearchEntryPoint.Value, false);

            switch app.General.context.SEARCH.mode
                case 'tokens'
                    if isempty(app.SearchSuggestions.Items)
                        onSearchEntryPointChanging(app, struct('Value', app.SearchEntryPoint.Value, 'ListBoxVisibility', false))
                    end
                    wordsToSearch = app.SearchSuggestions.Items;

                otherwise % 'words'
                    wordsToSearch = textAnalysis.preProcessedData(strsplit(app.SearchEntryPoint.Value, ','));
            end

            newSearchEntry = struct('valueToSearch', valueToSearch, 'wordsToSearch', {wordsToSearch});
            if isequal(app.SearchEntryButton.UserData, newSearchEntry)
                return
            end
            app.SearchEntryButton.UserData = newSearchEntry;

            applyFiltering(app)

        end

        % Value changing function: SearchEntryPoint
        function onSearchEntryPointChanging(app, event)
            
            valueToSearch = textAnalysis.preProcessedData(event.Value, false);

            if numel(valueToSearch) < app.General.context.SEARCH.minCharacters
                setComponentsState(app, 'entryDisabled')

            else
                setComponentsState(app, 'entryEnabled')

                if strcmp(app.General.context.SEARCH.mode, 'tokens')
                    [similarStrings, idxFiltered, redFontFlag] = util.getSimilarStrings(app.cacheData, valueToSearch, app.General.context.SEARCH.minDisplayedTokens);
                    
                    set(app.SearchSuggestions, ...
                        'Visible', ~isfield(event, 'ListBoxVisibility'), ...
                        'Value', {}, ...
                        'Items', similarStrings, ...
                        'ItemsData', 1:numel(idxFiltered) ...
                    )
        
                    if redFontFlag
                        fontColor = [1,0,0];
                    else
                        fontColor = [0,0,0];
                    end
                    app.SearchEntryPoint.FontColor = fontColor;
                end
            end
            
        end

        % Callback function: AppInfo, ReturnButton, Tab1Button, Tab2Button,
        % 
        % ...and 2 other components
        function onTabNavigatorButtonPushed(app, event)
            
            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button, app.Tab4Button}
                    applyLayout(app, 'mainAppMobile')
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, app)

                case app.ReturnButton
                    applyLayout(app, 'mainAppMobile')

                case app.AppInfo
                    delete(app.popupCurrentApp) %% APAGAR DEPOIS %%
                    delete(app.tabGroupController.Components.appHandle{4}) %% APAGAR DEPOIS %%

                    appInfo = util.HtmlTextGenerator.AppInfo( ...
                        app.General, ...
                        app.rootFolder, ...
                        app.executionMode, ...
                        app.renderCount, ...
                        app.schData.detailed, ...
                        app.releasedData, ...
                        app.cacheData, ...
                        app.annotationTable, ...
                        app.eFiscalizaObj, ...
                        "popup" ...
                    );

                    sendEventToHTMLSource(app.jsBackDoor, 'textHighlight', struct( ...
                        'dataTag', '123456', ...
                        'imageUrl', 'info.svg', ...
                        'title', 'Aspectos gerais', ...
                        'width', 85, ...
                        'height', 60, ...
                        'html', appInfo ...
                    ));
            end

        end

        % Image clicked function: SearchSetupButton
        function SearchSetupButtonImageClicked(app, event)
            
            ipcMainMatlabOpenPopupApp(app, app, 'SearchFilter', app.Context)

        end

        % Image clicked function: ViewNextRangeButton, 
        % ...and 1 other component
        function onViewRangeButtonClicked(app, event)
            
            nResults = height(app.searchResults);

            switch event.Source
                case app.ViewPreviousRangeButton
                    app.resultPageStart = max(1, app.resultPageStart - app.MAX_RESULTS_PER_PAGE);

                case app.ViewNextRangeButton
                    nextStart = app.resultPageStart + app.MAX_RESULTS_PER_PAGE;
                    if nextStart > nResults
                        return
                    end
                    app.resultPageStart = nextStart;
            end

            renderSearchResults(app)
            focus(app.UIFigure)

        end

        % Image clicked function: Image
        function DevToolsButtonPushed(app, event)
            webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
        end

        % Image clicked function: CurrentFilterVisibility
        function CurrentFilterVisibilityImageClicked(app, event)
            
            app.CurrentFilterPanel.UserData.status = ~app.CurrentFilterPanel.UserData.status;

            if app.CurrentFilterPanel.UserData.status
                app.Grid1.RowHeight([3, 7]) = {92, 138};
                app.CurrentFilterVisibility.ImageSource = 'chevron-up.svg';
            else
                app.Grid1.RowHeight([3, 7]) = {44, 186};
                app.CurrentFilterVisibility.ImageSource = 'chevron-down.svg';
            end

            focus(app.UIFigure)

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
                app.UIFigure.Position = [100 100 393 852];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);
                app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @onFigureWindowButtonDown, true);

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
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {56, '1x', 76};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [3 0 3 0];
            app.GridLayout.BackgroundColor = [0.1294 0.2 0.2392];

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.NavBar.RowHeight = {'1x'};
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 10 10 16];
            app.NavBar.Layout.Row = 3;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.1294 0.2 0.2392];

            % Create Tab1Button
            app.Tab1Button = uibutton(app.NavBar, 'state');
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'SEARCH';
            app.Tab1Button.Icon = 'search-sparkle-24px-yellow.svg';
            app.Tab1Button.IconAlignment = 'top';
            app.Tab1Button.Text = 'Pesquisa';
            app.Tab1Button.BackgroundColor = [0.1294 0.2 0.2392];
            app.Tab1Button.FontSize = 11;
            app.Tab1Button.FontColor = [0.9412 0.9412 0.1333];
            app.Tab1Button.Layout.Row = 1;
            app.Tab1Button.Layout.Column = 1;

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PRODUCTS';
            app.Tab2Button.Icon = 'checklist-24px-white.svg';
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = 'Produtos';
            app.Tab2Button.BackgroundColor = [0.1294 0.2 0.2392];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.FontColor = [1 1 1];
            app.Tab2Button.Layout.Row = 1;
            app.Tab2Button.Layout.Column = 2;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'REPORT';
            app.Tab3Button.Icon = 'organization-24px-white.svg';
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = 'Relatório';
            app.Tab3Button.BackgroundColor = [0.1294 0.2 0.2392];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.FontColor = [1 1 1];
            app.Tab3Button.Layout.Row = 1;
            app.Tab3Button.Layout.Column = 3;

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'CONFIG';
            app.Tab4Button.Icon = 'gear-24px-white.svg';
            app.Tab4Button.IconAlignment = 'top';
            app.Tab4Button.Text = 'Configurações';
            app.Tab4Button.BackgroundColor = [0.1294 0.2 0.2392];
            app.Tab4Button.FontSize = 11;
            app.Tab4Button.FontColor = [1 1 1];
            app.Tab4Button.Layout.Row = 1;
            app.Tab4Button.Layout.Column = 4;

            % Create ContainerAuxApps
            app.ContainerAuxApps = uipanel(app.GridLayout);
            app.ContainerAuxApps.BorderType = 'none';
            app.ContainerAuxApps.Layout.Row = 2;
            app.ContainerAuxApps.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.AutoResizeChildren = 'off';

            % Create Grid1
            app.Grid1 = uigridlayout(app.Tab1);
            app.Grid1.ColumnWidth = {'1x', 90, 10, 28, 28};
            app.Grid1.RowHeight = {38, 10, 92, 10, 22, 10, 144, '1x', 46};
            app.Grid1.ColumnSpacing = 0;
            app.Grid1.RowSpacing = 0;
            app.Grid1.Padding = [10 10 10 42];
            app.Grid1.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create SearchEntryPoint
            app.SearchEntryPoint = uieditfield(app.Grid1, 'text');
            app.SearchEntryPoint.CharacterLimits = [0 128];
            app.SearchEntryPoint.ValueChangingFcn = createCallbackFcn(app, @onSearchEntryPointChanging, true);
            app.SearchEntryPoint.Tag = 'PROMPT';
            app.SearchEntryPoint.FontSize = 14;
            app.SearchEntryPoint.FontColor = [0 0.1294 0.2392];
            app.SearchEntryPoint.Placeholder = 'O que você quer pesquisar?';
            app.SearchEntryPoint.Layout.Row = 1;
            app.SearchEntryPoint.Layout.Column = [1 5];

            % Create SearchEntryButton
            app.SearchEntryButton = uiimage(app.Grid1);
            app.SearchEntryButton.ScaleMethod = 'none';
            app.SearchEntryButton.ImageClickedFcn = createCallbackFcn(app, @onSearchEntryButtonPushed, true);
            app.SearchEntryButton.Enable = 'off';
            app.SearchEntryButton.Layout.Row = 1;
            app.SearchEntryButton.Layout.Column = 4;
            app.SearchEntryButton.ImageSource = 'search-20px.svg';

            % Create SearchSetupButton
            app.SearchSetupButton = uiimage(app.Grid1);
            app.SearchSetupButton.ScaleMethod = 'none';
            app.SearchSetupButton.ImageClickedFcn = createCallbackFcn(app, @SearchSetupButtonImageClicked, true);
            app.SearchSetupButton.Layout.Row = 1;
            app.SearchSetupButton.Layout.Column = 5;
            app.SearchSetupButton.ImageSource = 'settings-20px.svg';

            % Create CurrentFilterPanel
            app.CurrentFilterPanel = uipanel(app.Grid1);
            app.CurrentFilterPanel.Layout.Row = 3;
            app.CurrentFilterPanel.Layout.Column = [1 5];

            % Create CurrentFilterGrid
            app.CurrentFilterGrid = uigridlayout(app.CurrentFilterPanel);
            app.CurrentFilterGrid.ColumnWidth = {18, '1x', 18, '1x', '1x', 18};
            app.CurrentFilterGrid.RowHeight = {22, '1x'};
            app.CurrentFilterGrid.ColumnSpacing = 5;
            app.CurrentFilterGrid.RowSpacing = 5;
            app.CurrentFilterGrid.BackgroundColor = [0.9333 0.9569 0.9843];

            % Create CurrentFilterIcon
            app.CurrentFilterIcon = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterIcon.ScaleMethod = 'none';
            app.CurrentFilterIcon.Layout.Row = 1;
            app.CurrentFilterIcon.Layout.Column = 1;
            app.CurrentFilterIcon.ImageSource = 'filter-filled.svg';

            % Create CurrentFilterLabel
            app.CurrentFilterLabel = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterLabel.FontWeight = 'bold';
            app.CurrentFilterLabel.FontColor = [0 0.1294 0.2392];
            app.CurrentFilterLabel.Layout.Row = 1;
            app.CurrentFilterLabel.Layout.Column = [2 5];
            app.CurrentFilterLabel.Text = 'Especificação do filtro atual';

            % Create CurrentFilterVisibility
            app.CurrentFilterVisibility = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterVisibility.ImageClickedFcn = createCallbackFcn(app, @CurrentFilterVisibilityImageClicked, true);
            app.CurrentFilterVisibility.Layout.Row = 1;
            app.CurrentFilterVisibility.Layout.Column = [1 6];
            app.CurrentFilterVisibility.HorizontalAlignment = 'right';
            app.CurrentFilterVisibility.ImageSource = 'chevron-up.svg';

            % Create CurrentFilterStrategy
            app.CurrentFilterStrategy = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterStrategy.VerticalAlignment = 'top';
            app.CurrentFilterStrategy.FontSize = 10;
            app.CurrentFilterStrategy.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterStrategy.Layout.Row = 2;
            app.CurrentFilterStrategy.Layout.Column = [1 2];
            app.CurrentFilterStrategy.Interpreter = 'html';
            app.CurrentFilterStrategy.Text = 'Estratégia:<br><font style="font-size:11px; color: #00213d;">Texto livre +<br>Filtro por coluna</font>';

            % Create CurrentFilterText
            app.CurrentFilterText = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterText.VerticalAlignment = 'top';
            app.CurrentFilterText.FontSize = 10;
            app.CurrentFilterText.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterText.Layout.Row = 2;
            app.CurrentFilterText.Layout.Column = [3 4];
            app.CurrentFilterText.Interpreter = 'html';
            app.CurrentFilterText.Text = 'Pesquisa textual:<br><font style="font-size:11px; color: #00213d;">Similaridade</font>';

            % Create CurrentFilterColumn
            app.CurrentFilterColumn = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterColumn.VerticalAlignment = 'top';
            app.CurrentFilterColumn.WordWrap = 'on';
            app.CurrentFilterColumn.FontSize = 10;
            app.CurrentFilterColumn.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterColumn.Layout.Row = 2;
            app.CurrentFilterColumn.Layout.Column = [5 6];
            app.CurrentFilterColumn.Interpreter = 'html';
            app.CurrentFilterColumn.Text = 'Filtros por coluna:<br><font style="font-size:11px; color: #00213d;">Nenhum aplicado</font>';

            % Create ViewRange
            app.ViewRange = uilabel(app.Grid1);
            app.ViewRange.HorizontalAlignment = 'right';
            app.ViewRange.FontSize = 11;
            app.ViewRange.FontColor = [0.4588 0.5294 0.6];
            app.ViewRange.Layout.Row = 5;
            app.ViewRange.Layout.Column = 2;
            app.ViewRange.Text = '';

            % Create ViewPreviousRangeButton
            app.ViewPreviousRangeButton = uiimage(app.Grid1);
            app.ViewPreviousRangeButton.ImageClickedFcn = createCallbackFcn(app, @onViewRangeButtonClicked, true);
            app.ViewPreviousRangeButton.Enable = 'off';
            app.ViewPreviousRangeButton.Visible = 'off';
            app.ViewPreviousRangeButton.Layout.Row = 5;
            app.ViewPreviousRangeButton.Layout.Column = 4;
            app.ViewPreviousRangeButton.ImageSource = 'chevron-left.svg';

            % Create ViewNextRangeButton
            app.ViewNextRangeButton = uiimage(app.Grid1);
            app.ViewNextRangeButton.ImageClickedFcn = createCallbackFcn(app, @onViewRangeButtonClicked, true);
            app.ViewNextRangeButton.Enable = 'off';
            app.ViewNextRangeButton.Visible = 'off';
            app.ViewNextRangeButton.Layout.Row = 5;
            app.ViewNextRangeButton.Layout.Column = 5;
            app.ViewNextRangeButton.ImageSource = 'chevron-right.svg';

            % Create SearchResults
            app.SearchResults = uilabel(app.Grid1);
            app.SearchResults.VerticalAlignment = 'top';
            app.SearchResults.WordWrap = 'on';
            app.SearchResults.FontSize = 11;
            app.SearchResults.Layout.Row = [7 9];
            app.SearchResults.Layout.Column = [1 5];
            app.SearchResults.Interpreter = 'html';
            app.SearchResults.Text = '';

            % Create SearchSuggestions
            app.SearchSuggestions = uilistbox(app.Grid1);
            app.SearchSuggestions.Items = {''};
            app.SearchSuggestions.Tag = 'CAIXA DE BUSCA';
            app.SearchSuggestions.Visible = 'off';
            app.SearchSuggestions.FontSize = 14;
            app.SearchSuggestions.FontColor = [0 0.1294 0.2392];
            app.SearchSuggestions.Layout.Row = [2 7];
            app.SearchSuggestions.Layout.Column = [1 5];
            app.SearchSuggestions.Value = {};

            % Create PopupTempWarning
            app.PopupTempWarning = uilabel(app.Grid1);
            app.PopupTempWarning.BackgroundColor = [0.6353 0.0784 0.1843];
            app.PopupTempWarning.HorizontalAlignment = 'center';
            app.PopupTempWarning.WordWrap = 'on';
            app.PopupTempWarning.FontColor = [1 1 1];
            app.PopupTempWarning.Visible = 'off';
            app.PopupTempWarning.Layout.Row = 9;
            app.PopupTempWarning.Layout.Column = [1 5];
            app.PopupTempWarning.Text = '';

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.AutoResizeChildren = 'off';

            % Create Tab3
            app.Tab3 = uitab(app.TabGroup);
            app.Tab3.AutoResizeChildren = 'off';

            % Create Tab4
            app.Tab4 = uitab(app.TabGroup);
            app.Tab4.AutoResizeChildren = 'off';

            % Create TitleGrid
            app.TitleGrid = uigridlayout(app.GridLayout);
            app.TitleGrid.ColumnWidth = {32, '1x', 28, 28};
            app.TitleGrid.RowHeight = {'1x'};
            app.TitleGrid.Padding = [0 0 0 0];
            app.TitleGrid.Layout.Row = 1;
            app.TitleGrid.Layout.Column = 1;
            app.TitleGrid.BackgroundColor = [0.1294 0.2 0.2392];

            % Create ReturnButton
            app.ReturnButton = uiimage(app.TitleGrid);
            app.ReturnButton.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.ReturnButton.Visible = 'off';
            app.ReturnButton.Layout.Row = 1;
            app.ReturnButton.Layout.Column = 1;
            app.ReturnButton.ImageSource = 'chevron-left-white.svg';

            % Create AppTitle
            app.AppTitle = uilabel(app.TitleGrid);
            app.AppTitle.HorizontalAlignment = 'center';
            app.AppTitle.FontSize = 10;
            app.AppTitle.FontColor = [1 1 1];
            app.AppTitle.Layout.Row = 1;
            app.AppTitle.Layout.Column = [2 3];
            app.AppTitle.Interpreter = 'html';
            app.AppTitle.Text = {'<font style="font-size: 16px; line-height: 16px;"><b>SCH+</b></font>'; 'v.1.00.0'};

            % Create AppInfo
            app.AppInfo = uiimage(app.TitleGrid);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Layout.Row = 1;
            app.AppInfo.Layout.Column = 4;
            app.AppInfo.ImageSource = 'kebab-vertical-24px-white.svg';

            % Create Image
            app.Image = uiimage(app.TitleGrid);
            app.Image.ImageClickedFcn = createCallbackFcn(app, @DevToolsButtonPushed, true);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = 'Debug_18.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobile_exported(Container, varargin)

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
