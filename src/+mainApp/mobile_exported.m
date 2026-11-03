classdef mobile_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        TabNavigator             matlab.ui.container.GridLayout
        Tab3Label                matlab.ui.control.Label
        Tab3Button               matlab.ui.control.Image
        Tab2Label                matlab.ui.control.Label
        Tab2Button               matlab.ui.control.Image
        Tab1Label                matlab.ui.control.Label
        Tab1Button               matlab.ui.control.Image
        ContainerMainApp         matlab.ui.container.Panel
        ContainerMainAppGrid     matlab.ui.container.GridLayout
        SearchSuggestions        matlab.ui.control.ListBox
        SearchResults            matlab.ui.control.Label
        ViewNextRangeButton      matlab.ui.control.Image
        ViewPreviousRangeButton  matlab.ui.control.Image
        ViewRange                matlab.ui.control.Label
        LastSearch               matlab.ui.control.Label
        SearchSetupButton        matlab.ui.control.Image
        SearchEntryButton        matlab.ui.control.Image
        SearchEntryPoint         matlab.ui.control.EditField
        ContainerAuxApps         matlab.ui.container.Panel
        ContainerAuxAppsGrid     matlab.ui.container.GridLayout
        ContainerAuxAppsContent  matlab.ui.control.Image
        CloseButton              matlab.ui.control.Image
        AppTitle                 matlab.ui.control.Label
        ReturnButton             matlab.ui.control.Image
        AppInfo                  matlab.ui.control.Image
    end

    
    properties (Constant, Access = private)
        %-----------------------------------------------------------------%
        MAX_RESULTS_PER_PAGE = 10
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainAppMobile'
        Context = 'SEARCH'
        AppHandleNameInBase = ''
    end


    properties
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

        SubTabGroup = struct('Children', -1, 'UserData', [])

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
                        else
                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        end
                        
                        app.renderCount = app.renderCount+1;
    
                    case 'unload'
                        closeFcn(app, event)

                    case 'textHighlight'
                        uialert(app.UIFigure, jsonencode(event.HTMLEventData), '', 'Icon', 'success')

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

                    case 'syncPopupWithPanel'
                        if ~isempty(app.popupCurrentApp) && isvalid(app.popupCurrentApp)
                            app.popupCurrentApp.Container.Position(1:2) = [event.HTMLEventData.x, event.HTMLEventData.y];
                        end

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

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end

                            case 'onGetImageUrl'
                                url = event.HTMLEventData.url;

                                try
                                    uri = matlab.net.URI(url);
                                    isValid = uri.Scheme == "https" && ~isempty(uri.Host);
                                catch
                                    isValid = false;
                                end

                                if ~isValid
                                    ui.Dialog(app.UIFigure, 'warning', 'Endereço não é válido.');
                                    return
                                end

                                requestKey = char(matlab.lang.internal.uuid());
                                jsonFileName = fullfile(app.General.fileFolder.DataHub_POST, sprintf('regulatron_%s_%s.request',  datestr(now, 'yyyymmdd'), requestKey));
                                jsonContent = jsonencode(struct( ...
                                    'requestKey', requestKey, ...
                                    'createdAt', datestr(now, 'yyyy-mm-ddTHH:MM:SS'), ...
                                    'clientName', class.Constants.appName, ...
                                    'url', url ...
                                ), 'PrettyPrint', true);

                                writematrix(jsonContent, jsonFileName, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite", "Encoding", "UTF-8")
                                ui.Dialog(app.UIFigure, 'info', sprintf('Aberta requisição de raspagem para anúncio publicado em <b>%s://%s</b>', uri.Scheme, uri.Host));
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    case 'findResourceStaticURL'
                        resourceStaticURL = event.HTMLEventData;
                        if ~isempty(resourceStaticURL)
                            app.General.AppVersion.application.resourceStaticURL = resourceStaticURL;
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
                                                    ui.Dialog(app.UIFigure, 'error', msg);
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

            switch eventName
                case 'onSearchModeChanged'
                    setComponentsState(app, 'searchInitial')

                case 'onColumnFilterChanged'
                    applyFiltering(app)
            end

            onTabNavigatorButtonPushed(app, struct('Source', app.CloseButton))
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = getAppHandle(app.tabGroupController, auxAppName);
            if isempty(hAuxApp)
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
                auxAppName char {mustBeMember(auxAppName, {'CustomsAnalysisDetails', 'CustomsFilter', 'CustomsManageFiles', 'CustomsManageRules', 'ProductInfo', 'ReportLib', 'SearchAddSelectedToBucket', 'SearchFilter', 'SearchProductDetails'})}
                context char {mustBeMember(context, {'mainApp', 'SEARCH', 'PRODUCTS', 'CUSTOMS', 'CONFIG'})}
            end

            arguments (Repeating)
                varargin 
            end

            auxDockAppName = sprintf('auxApp.mobile%s', auxAppName);
            if ~isempty(app.popupCurrentApp) && isvalid(app.popupCurrentApp)
                if contains(class(app.popupCurrentApp), auxDockAppName)
                    applyLayout(app, 'secondaryApp')
                    return
                end
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')

            inputArguments = [{app, callingApp, context}, varargin];
            
            if app.General.operationMode.Debug
                app.popupCurrentApp = feval(auxDockAppName, inputArguments{:});
                app.popupCurrentApp.isDocked = false;

            else
                auxAppContainer = app.ContainerAuxApps;
                app.popupCurrentApp = feval([auxDockAppName '_exported'], auxAppContainer, inputArguments{:});
                applyLayout(app, 'secondaryDockApp')
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end

        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            onTabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
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
                        app.AppInfo;
                        app.SearchEntryPoint;
                        app.SearchSuggestions;
                        app.SearchResults
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id, 'generation', 1, 'style', struct('borderColor', 'lightgray', 'borderRadius', '8px 0 0 0')), ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id, 'selector', 'input', 'style', struct('paddingRight', '60px')), ...
                            struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id, 'generation', 1, 'style', struct('borderColor', 'lightgray', 'borderTop', '0')), ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id, 'generation', 2, 'listener', struct('componentName', 'mainApp.searchEntryPoint',  'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})), ...
                            struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id, 'generation', 1, 'listener', struct('componentName', 'mainApp.searchSuggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.SearchResults, appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
                    catch
                    end

                otherwise
                    % ...
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

            app.Tab1Button.UserData.status = true;
            app.Tab2Button.UserData.status = false;
            app.Tab3Button.UserData.status = false;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.SearchEntryButton.UserData = struct('valueToSearch', '', 'wordsToSearch', {{}});
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            setComponentsState(app, 'searchInitial')
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyLayout(app, mode)
            switch mode
                case 'mainAppMobile'
                    app.AppInfo.Visible = 'on';
                    app.AppTitle.Text = {'<font style="font-size: 16px; line-height: 16px;"><b>SCH</b></font>'; 'v.1.00.0'};
                    app.ContainerMainApp.Visible = 'on';
                    app.ContainerAuxApps.Visible = 'off';
                    app.ReturnButton.Visible = 'off';
                    app.CloseButton.Visible = 'off';

                otherwise % {'secondaryApp', 'secondaryDockApp}
                    app.AppInfo.Visible = 'off';
                    app.AppTitle.Text = {'<font style="font-size: 16px; line-height: 16px;"><b>Configurações de filtragem e exibição</b></font>'; 'Defina como os filtros serão aplicados'};
                    app.ContainerMainApp.Visible = 'off';
                    app.ContainerAuxApps.Visible = 'on';
                    app.ReturnButton.Visible = 'on';
                    app.CloseButton.Visible = 'on';
            end
        end

        %-----------------------------------------------------------------%
        function setComponentsState(app, state)
            arguments
                app
                state char {mustBeMember(state, {'searchInitial', 'entryEnabled', 'entryDisabled', 'resultsRange', 'rangeControlsVisible'})}
            end

            switch state
                case 'searchInitial'
                    switch app.General.context.SEARCH.type
                        case {'FreeText', 'FreeText+ColumnFilter'}
                            enable = true;
                            value = app.SearchEntryButton.UserData.valueToSearch;
                            placeholder = 'O que você quer pesquisar?';
                        otherwise
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
                    app.SearchResults.Text = '';
                    app.LastSearch.Text = '';
                    set([app.ViewPreviousRangeButton, app.ViewNextRangeButton], 'Visible', 0)
                    setComponentsState(app, 'resultsRange')

                case 'rangeControlsVisible'
                    set([app.ViewPreviousRangeButton, app.ViewNextRangeButton], 'Visible', 1)

                case 'entryEnabled'
                    app.SearchEntryButton.Enable = 1;

                case 'entryDisabled'
                    app.SearchEntryButton.Enable = 0;
                    app.LastSearch.Text = '';
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
            app.LastSearch.Text = app.SearchEntryButton.UserData.valueToSearch;

            app.progressDialog.Visible = 'hidden';
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
            annotations = app.annotationTable(strcmp(app.annotationTable.('Homologação'), homologation), :);
            images = unique(annotations(strcmp(annotations.('Atributo'), 'Image'), :).Valor);
            wordClouds = annotations(strcmp(annotations.('Atributo'), 'WordCloud'), :);
            adsMask = strcmp(app.projectData.regulatronData.adsTable.('certificado'), replace(homologation, '-', ''));
            ads = app.projectData.regulatronData.adsTable(adsMask, :);

            htmlContent = util.HtmlTextGenerator.ProductInfo( ...
                'ProdutoHomologado', ...
                relatedSCH, ...
                height(wordClouds), ...
                numel(images), ...
                ads ...
            );
            ui.Dialog(app.UIFigure, 'info', htmlContent);
        end

        %-----------------------------------------------------------------%
        function addSearchResultToInspected(app, resultIdx)
            if ~isscalar(resultIdx) || ~isfinite(resultIdx) || resultIdx < 1 || resultIdx > height(app.searchResults)
                return
            end

            homologation = char(string(app.searchResults.('Homologação')(resultIdx)));
            schDetailedIdxs = find(strcmp(app.schData.detailed.('Homologação'), homologation));
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
                ui.Dialog(app.UIFigure, 'success', sprintf('%d produto(s) incluído(s) na lista de produtos sob análise.', addedCount));
            else
                ui.Dialog(app.UIFigure, 'warning', model.ProjectBase.WARNING_ENTRYEXIST.SEARCH);
            end
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

            setComponentsState(app, 'rangeControlsVisible')
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
            
            try
                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            try
                appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            catch ME
                appEngine.util.killingMATLABRuntime(app.executionMode)
            end

            delete(app)

        end

        % Window button down function: UIFigure
        function onFigureWindowButtonDown(app, event)
            
            % O listener que captura cliques do mouse só é aplicável no
            % modo SEARCH.
            if ~app.Tab1Button.UserData.status
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

        % Image clicked function: AppInfo, CloseButton, ReturnButton, 
        % ...and 3 other components
        function onTabNavigatorButtonPushed(app, event)
            
            switch event.Source
                case app.Tab1Button
                    applyLayout(app, 'mainAppMobile')
                
                case app.Tab2Button
                    applyLayout(app, 'secondaryApp')

                case app.Tab3Button
                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                    webWin.openDevTools();

                case app.ReturnButton
                    app.ContainerMainApp.Visible = 'off';
                    onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button))

                case app.CloseButton
                    app.ContainerMainApp.Visible = 'off';
                    onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button))
                    
                    delete(app.popupCurrentApp)
                    app.popupCurrentApp = [];

                case app.AppInfo
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

                    sendEventToHTMLSource(app.jsBackDoor, 'textHighlight', struct('dataTag', '123456', 'imageUrl', 'add-to-card.svg', 'title', 'Homologação', 'width', 80, 'height', 60, 'html', appInfo));
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
            app.GridLayout.ColumnWidth = {28, '1x', 28};
            app.GridLayout.RowHeight = {56, '1x', 76};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [3 0 3 0];
            app.GridLayout.BackgroundColor = [0.1294 0.2 0.2392];

            % Create AppInfo
            app.AppInfo = uiimage(app.GridLayout);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Layout.Row = 1;
            app.AppInfo.Layout.Column = 1;
            app.AppInfo.ImageSource = 'kebab-vertical-24px-white.svg';

            % Create ReturnButton
            app.ReturnButton = uiimage(app.GridLayout);
            app.ReturnButton.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.ReturnButton.Visible = 'off';
            app.ReturnButton.Layout.Row = 1;
            app.ReturnButton.Layout.Column = 1;
            app.ReturnButton.ImageSource = 'chevron-left-white.svg';

            % Create AppTitle
            app.AppTitle = uilabel(app.GridLayout);
            app.AppTitle.FontSize = 10;
            app.AppTitle.FontColor = [1 1 1];
            app.AppTitle.Layout.Row = 1;
            app.AppTitle.Layout.Column = 2;
            app.AppTitle.Interpreter = 'html';
            app.AppTitle.Text = {'<font style="font-size: 16px; line-height: 16px;"><b>SCH</b></font>'; 'v.1.00.0'};

            % Create CloseButton
            app.CloseButton = uiimage(app.GridLayout);
            app.CloseButton.ScaleMethod = 'none';
            app.CloseButton.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.CloseButton.Visible = 'off';
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 3;
            app.CloseButton.ImageSource = 'close.svg';

            % Create ContainerAuxApps
            app.ContainerAuxApps = uipanel(app.GridLayout);
            app.ContainerAuxApps.Visible = 'off';
            app.ContainerAuxApps.Layout.Row = 2;
            app.ContainerAuxApps.Layout.Column = [1 3];

            % Create ContainerAuxAppsGrid
            app.ContainerAuxAppsGrid = uigridlayout(app.ContainerAuxApps);
            app.ContainerAuxAppsGrid.ColumnWidth = {'1x'};
            app.ContainerAuxAppsGrid.RowHeight = {'1x'};
            app.ContainerAuxAppsGrid.BackgroundColor = [0.9608 0.9686 0.9686];

            % Create ContainerAuxAppsContent
            app.ContainerAuxAppsContent = uiimage(app.ContainerAuxAppsGrid);
            app.ContainerAuxAppsContent.Layout.Row = 1;
            app.ContainerAuxAppsContent.Layout.Column = 1;

            % Create ContainerMainApp
            app.ContainerMainApp = uipanel(app.GridLayout);
            app.ContainerMainApp.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ContainerMainApp.Layout.Row = 2;
            app.ContainerMainApp.Layout.Column = [1 3];

            % Create ContainerMainAppGrid
            app.ContainerMainAppGrid = uigridlayout(app.ContainerMainApp);
            app.ContainerMainAppGrid.ColumnWidth = {'1x', 90, 10, 28, 28};
            app.ContainerMainAppGrid.RowHeight = {32, 6, 10, 22, 10, 322, '1x'};
            app.ContainerMainAppGrid.ColumnSpacing = 0;
            app.ContainerMainAppGrid.RowSpacing = 0;
            app.ContainerMainAppGrid.BackgroundColor = [0.9608 0.9686 0.9686];

            % Create SearchEntryPoint
            app.SearchEntryPoint = uieditfield(app.ContainerMainAppGrid, 'text');
            app.SearchEntryPoint.CharacterLimits = [0 128];
            app.SearchEntryPoint.ValueChangingFcn = createCallbackFcn(app, @onSearchEntryPointChanging, true);
            app.SearchEntryPoint.Tag = 'PROMPT';
            app.SearchEntryPoint.FontSize = 14;
            app.SearchEntryPoint.FontColor = [0 0.1294 0.2392];
            app.SearchEntryPoint.Placeholder = 'O que você quer pesquisar?';
            app.SearchEntryPoint.Layout.Row = [1 2];
            app.SearchEntryPoint.Layout.Column = [1 5];

            % Create SearchEntryButton
            app.SearchEntryButton = uiimage(app.ContainerMainAppGrid);
            app.SearchEntryButton.ScaleMethod = 'none';
            app.SearchEntryButton.ImageClickedFcn = createCallbackFcn(app, @onSearchEntryButtonPushed, true);
            app.SearchEntryButton.Enable = 'off';
            app.SearchEntryButton.Layout.Row = [1 2];
            app.SearchEntryButton.Layout.Column = 4;
            app.SearchEntryButton.ImageSource = 'search-20px.svg';

            % Create SearchSetupButton
            app.SearchSetupButton = uiimage(app.ContainerMainAppGrid);
            app.SearchSetupButton.ScaleMethod = 'none';
            app.SearchSetupButton.ImageClickedFcn = createCallbackFcn(app, @SearchSetupButtonImageClicked, true);
            app.SearchSetupButton.Layout.Row = [1 2];
            app.SearchSetupButton.Layout.Column = 5;
            app.SearchSetupButton.ImageSource = 'settings-20px.svg';

            % Create LastSearch
            app.LastSearch = uilabel(app.ContainerMainAppGrid);
            app.LastSearch.FontSize = 11;
            app.LastSearch.FontColor = [0.4588 0.5294 0.6];
            app.LastSearch.Layout.Row = 4;
            app.LastSearch.Layout.Column = 1;
            app.LastSearch.Text = '';

            % Create ViewRange
            app.ViewRange = uilabel(app.ContainerMainAppGrid);
            app.ViewRange.HorizontalAlignment = 'right';
            app.ViewRange.FontSize = 11;
            app.ViewRange.FontColor = [0.4588 0.5294 0.6];
            app.ViewRange.Layout.Row = 4;
            app.ViewRange.Layout.Column = 2;
            app.ViewRange.Text = '';

            % Create ViewPreviousRangeButton
            app.ViewPreviousRangeButton = uiimage(app.ContainerMainAppGrid);
            app.ViewPreviousRangeButton.ImageClickedFcn = createCallbackFcn(app, @onViewRangeButtonClicked, true);
            app.ViewPreviousRangeButton.Enable = 'off';
            app.ViewPreviousRangeButton.Visible = 'off';
            app.ViewPreviousRangeButton.Layout.Row = 4;
            app.ViewPreviousRangeButton.Layout.Column = 4;
            app.ViewPreviousRangeButton.ImageSource = 'chevron-left.svg';

            % Create ViewNextRangeButton
            app.ViewNextRangeButton = uiimage(app.ContainerMainAppGrid);
            app.ViewNextRangeButton.ImageClickedFcn = createCallbackFcn(app, @onViewRangeButtonClicked, true);
            app.ViewNextRangeButton.Enable = 'off';
            app.ViewNextRangeButton.Visible = 'off';
            app.ViewNextRangeButton.Layout.Row = 4;
            app.ViewNextRangeButton.Layout.Column = 5;
            app.ViewNextRangeButton.ImageSource = 'chevron-right.svg';

            % Create SearchResults
            app.SearchResults = uilabel(app.ContainerMainAppGrid);
            app.SearchResults.VerticalAlignment = 'top';
            app.SearchResults.WordWrap = 'on';
            app.SearchResults.FontSize = 11;
            app.SearchResults.Layout.Row = [6 7];
            app.SearchResults.Layout.Column = [1 5];
            app.SearchResults.Interpreter = 'html';
            app.SearchResults.Text = '';

            % Create SearchSuggestions
            app.SearchSuggestions = uilistbox(app.ContainerMainAppGrid);
            app.SearchSuggestions.Items = {''};
            app.SearchSuggestions.Tag = 'CAIXA DE BUSCA';
            app.SearchSuggestions.Visible = 'off';
            app.SearchSuggestions.FontSize = 14;
            app.SearchSuggestions.FontColor = [0 0.1294 0.2392];
            app.SearchSuggestions.Layout.Row = [3 6];
            app.SearchSuggestions.Layout.Column = [1 5];
            app.SearchSuggestions.Value = {};

            % Create TabNavigator
            app.TabNavigator = uigridlayout(app.GridLayout);
            app.TabNavigator.ColumnWidth = {28, '1x', '1x', '1x', 28};
            app.TabNavigator.RowHeight = {'1x', 22};
            app.TabNavigator.RowSpacing = 0;
            app.TabNavigator.Padding = [10 10 10 16];
            app.TabNavigator.Layout.Row = 3;
            app.TabNavigator.Layout.Column = [1 3];
            app.TabNavigator.BackgroundColor = [0.1294 0.2 0.2392];

            % Create Tab1Button
            app.Tab1Button = uiimage(app.TabNavigator);
            app.Tab1Button.ScaleMethod = 'none';
            app.Tab1Button.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab1Button.Layout.Row = [1 2];
            app.Tab1Button.Layout.Column = 2;
            app.Tab1Button.VerticalAlignment = 'top';
            app.Tab1Button.ImageSource = 'search-sparkle-24px-yellow.svg';

            % Create Tab1Label
            app.Tab1Label = uilabel(app.TabNavigator);
            app.Tab1Label.HorizontalAlignment = 'center';
            app.Tab1Label.FontSize = 11;
            app.Tab1Label.FontColor = [1 1 0.0667];
            app.Tab1Label.Layout.Row = 2;
            app.Tab1Label.Layout.Column = 2;
            app.Tab1Label.Text = 'Pesquisa';

            % Create Tab2Button
            app.Tab2Button = uiimage(app.TabNavigator);
            app.Tab2Button.ScaleMethod = 'none';
            app.Tab2Button.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Layout.Row = [1 2];
            app.Tab2Button.Layout.Column = 3;
            app.Tab2Button.VerticalAlignment = 'top';
            app.Tab2Button.ImageSource = 'checklist-24px-white.svg';

            % Create Tab2Label
            app.Tab2Label = uilabel(app.TabNavigator);
            app.Tab2Label.HorizontalAlignment = 'center';
            app.Tab2Label.FontSize = 11;
            app.Tab2Label.FontColor = [1 1 1];
            app.Tab2Label.Layout.Row = 2;
            app.Tab2Label.Layout.Column = 3;
            app.Tab2Label.Text = 'Produtos';

            % Create Tab3Button
            app.Tab3Button = uiimage(app.TabNavigator);
            app.Tab3Button.ScaleMethod = 'none';
            app.Tab3Button.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Layout.Row = [1 2];
            app.Tab3Button.Layout.Column = 4;
            app.Tab3Button.VerticalAlignment = 'top';
            app.Tab3Button.ImageSource = 'gear-24px-white.svg';

            % Create Tab3Label
            app.Tab3Label = uilabel(app.TabNavigator);
            app.Tab3Label.HorizontalAlignment = 'center';
            app.Tab3Label.FontSize = 11;
            app.Tab3Label.FontColor = [1 1 1];
            app.Tab3Label.Layout.Row = 2;
            app.Tab3Label.Layout.Column = 4;
            app.Tab3Label.Text = 'Configurações';

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
