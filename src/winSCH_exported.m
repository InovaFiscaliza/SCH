classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        NavBar                  matlab.ui.container.GridLayout
        ButtonsSeparator_2      matlab.ui.control.Image
        AppInfo                 matlab.ui.control.Image
        FigurePosition          matlab.ui.control.Image
        DataHubLamp             matlab.ui.control.Image
        jsBackDoor              matlab.ui.control.HTML
        Tab4Button              matlab.ui.control.StateButton
        ButtonsSeparator        matlab.ui.control.Image
        Tab3Button              matlab.ui.control.StateButton
        Tab2Button              matlab.ui.control.StateButton
        Tab1Button              matlab.ui.control.StateButton
        AppName                 matlab.ui.control.Label
        TabGroup                matlab.ui.container.TabGroup
        Tab1_Search             matlab.ui.container.Tab
        Tab1Grid                matlab.ui.container.GridLayout
        SearchSuggestions       matlab.ui.control.ListBox
        SearchEntryPointGrid    matlab.ui.container.GridLayout
        SearchEntryButton       matlab.ui.control.Image
        SearchEntryPoint        matlab.ui.control.EditField
        Toolbar                 matlab.ui.container.GridLayout
        PanelVisibility         matlab.ui.control.Image
        ProductDetails          matlab.ui.control.Image
        AddSelectedToBucket     matlab.ui.control.Image
        ToolbarSeparator        matlab.ui.control.Image
        ExportVisibleTable      matlab.ui.control.Image
        PopupTempWarning        matlab.ui.control.Label
        UITableGrid             matlab.ui.container.GridLayout
        ProductDetailsGrid      matlab.ui.container.GridLayout
        AttributesCount         matlab.ui.control.Label
        AttributesImageZoom     matlab.ui.control.Image
        AttributesNext          matlab.ui.control.Image
        AttributesPrevious      matlab.ui.control.Image
        AttributesPanel         matlab.ui.container.Panel
        AttributesGrid          matlab.ui.container.GridLayout
        Ads                     matlab.ui.control.Label
        WordCloud               matlab.ui.container.GridLayout
        WordCloudNote           matlab.ui.control.Label
        Image                   matlab.ui.control.Image
        Homologation            matlab.ui.control.Label
        AttributesRightButton   matlab.ui.control.Image
        AttributesLeftButton    matlab.ui.control.Image
        AttributesVisibleIndex  matlab.ui.control.Label
        AttributesLabel         matlab.ui.control.Label
        ColumnWidthMode         matlab.ui.control.Hyperlink
        NumRows                 matlab.ui.control.Label
        UITable                 matlab.ui.control.Table
        SearchContext           matlab.ui.control.Label
        SearchSetup             matlab.ui.control.Image
        Tab2_Products           matlab.ui.container.Tab
        Tab3_Customs            matlab.ui.container.Tab
        Tab4_Config             matlab.ui.container.Tab
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainApp'
        Context = 'SEARCH'
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
        resultContext = struct( ...
            'SCH',        struct('data', [], 'isRendered', false), ...
            'Annotation', struct('data', [], 'isRendered', false), ...
            'WordCloud',  struct('data', [], 'index', [], 'isRendered', false), ...
            'Images',     struct('data', {{}}, 'index', [], 'isRendered', false), ...
            'Ads',        struct('data', [], 'index', [], 'isRendered', false) ...
        )
        adLastUpdate = ''
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
            % aos componentes app.SearchEntryPoint (matlab.ui.control.EditField) e app.SearchSuggestions
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

            % Quando altero o conteúdo de app.SearchEntryPoint, sem alterar o seu foco, será executado
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
                            selectedRow = app.UITable.Selection;
                            if ~isempty(selectedRow)
                                app.UITable.Selection = [];
                                onTableSelectionChanged(app)
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(selectedRow)
                                app.UITable.Selection = selectedRow;
                                onTableSelectionChanged(app)
                            end
                        end
                        
                        app.renderCount = app.renderCount+1;
    
                    case 'unload'
                        closeFcn(app)

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
                            case {'onFetchIssueDetails', 'onReportGenerate', 'onUploadArtifacts'}
                                eventName = event.HTMLEventData.uuid;
                                context = event.HTMLEventData.context;

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
                                jsonFileName = fullfile(app.General.fileFolder.DataHub_POST, sprintf('RegulatronRequest_%s_%s.json',  datestr(now, 'yyyymmdd'), requestKey));
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

                    case 'backgroundBecameTransparent'
                        switch event.HTMLEventData
                            case 'PopupTempWarning'
                                app.AddSelectedToBucket.Enable = "on";
                                app.PopupTempWarning.Visible = "off";

                            otherwise
                                error('UnexpectedEvent')
                        end
    
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
                                    entryButtonInitialState(app)
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
                                            onEntryButtonPushed(app)                                        
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

                                    onEntryPointChanging(app, struct('Value', eventValue, 'ListBoxVisibility', false))
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
                        error('winSCH:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
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
                switch eventName
                    case 'closeFcn'
                        auxAppTag = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        varargout{1} = {app};

                    case 'onUpdateLastVisitedFolder'
                        filePath = varargin{1};
                        updateLastVisitedFolder(app, filePath)

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch eventName        
                                    case 'checkDataHubLampStatus'
                                        updateWarningLampVisibility(app)
        
                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                                    case 'updateDataHubGetFolder'
                                        app.progressDialog.Visible = 'visible';
                                        readDataBaseExternalFiles(app)
                                        app.progressDialog.Visible = 'hidden';
        
                                    otherwise
                                        error('SCH:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end
        
                            % auxApp.winProducts (PRODUCTS)
                            case {'auxApp.winProducts', 'auxApp.winProducts_exported'}
                                switch eventName
                                    case {'onReportGenerate', 'onUploadArtifacts'}
                                        context = varargin{1};
                                        varargin = varargin(2:end);
                                        reportHandleOperation(app, eventName, context, [], varargin{:})

                                    otherwise
                                        error('SCH:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end
        
                            % DOCKS:OTHERS
                            case {'auxApp.dockCustomsAnalysisDetails', 'auxApp.dockCustomsAnalysisDetails_exported', ...
                                  'auxApp.dockCustomsFilter', 'auxApp.dockCustomsFilter_exported', ...
                                  'auxApp.dockCustomsManageRules', 'auxApp.dockCustomsManageRules_exported', ...
                                  'auxApp.dockProductInfo', 'auxApp.dockProductInfo_exported', ...
                                  'auxApp.dockReportLib', 'auxApp.dockReportLib_exported', ...
                                  'auxApp.dockSearchAddSelectedToBucket', 'auxApp.dockSearchAddSelectedToBucket_exported', ...
                                  'auxApp.dockSearchFilter', 'auxApp.dockSearchFilter_exported', ...
                                  'auxApp.dockSearchProductDetails', 'auxApp.dockSearchProductDetails_exported'}
                                switch eventName
                                    % auxApp.dockSearchAddSelectedToBucket
                                    case 'onAddSelectedToBucketRequest'
                                        schDetailedIdxs = varargin{1};
                                        addInspectedProducts(app, schDetailedIdxs)

                                        if callingApp.isDocked
                                            sendEventToHTMLSource(callingApp.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', callingApp.GridLayout.UserData.id))
                                        else
                                            delete(callingApp)
                                        end

                                    case 'onCustomsShipmentsTableChanged'
                                        ipcMainMatlabCallAuxiliarApp(app, 'CUSTOMS', 'MATLAB', eventName)

                                    % auxApp.dockSearchFilterSetup
                                    case 'onSearchModeChanged'
                                        searchComponentsInitialState(app)

                                    case 'onColumnFilterChanged'
                                        applyFiltering(app)

                                    % auxApp.dockSearchProductDetails
                                    case 'onSelectedRowChangeRequest'
                                        app.UITable.Selection = varargin{1};
                                        scroll(app.UITable, 'row', varargin{1})
                                        onTableSelectionChanged(app)
                                        varargout{1} = app.resultContext;

                                    case 'getAdLastUpdate'
                                        lastUpdate = getAdLastUpdate(app);
                                        varargout{1} = lastUpdate;

                                    case 'onGetImageUrl'
                                        if ~isfolder(app.General.fileFolder.DataHub_POST)
                                            warningMsg = 'Pendente mapear a pasta POST do SharePoint, de modo a viabilizar a obtenção do endereço de anúncio a raspar';
                                            ui.Dialog(app.UIFigure, 'warning', warningMsg);
                                            return
                                        end

                                        dialogBox = struct('id', 'url', 'label', 'URL: ', 'type', 'text');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'onGetImageUrl', 'Fields', {{dialogBox}}))

                                    % auxApp.dockProductInfo
                                    case {'onTableSelectionChanged', 'onTableCellEdited'}
                                        context  = varargin{1};
                                        varargin = [{eventName}, varargin(2:end)];
                                        ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})
        
                                    % auxApp.dockReportLib
                                    case {'onProjectRestart', 'onProjectLoad', 'onFinalReportFileChanged'}
                                        context  = varargin{1};
                                        varargin = [{eventName}, varargin(2:end)];
                                        ipcMainMatlabCallAuxiliarApp(app, context, 'MATLAB', varargin{:})

                                    case 'onFetchIssueDetails'
                                        context  = varargin{1};
                                        reportFetchIssueDetails(app, context, [])
        
                                    otherwise
                                        error('SCH:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end
        
                            otherwise
                                error('SCH:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
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
        function ipcMainMatlabOpenPopupApp(app, callingApp, auxAppName, context, varargin)
            arguments
                app
                callingApp
                auxAppName char {mustBeMember(auxAppName, {'CustomsAnalysisDetails', 'CustomsFilter', 'CustomsManageRules', 'ProductInfo', 'ReportLib', 'SearchAddSelectedToBucket', 'SearchFilter', 'SearchProductDetails'})}
                context char {mustBeMember(context, {'mainApp', 'SEARCH', 'PRODUCTS', 'CUSTOMS', 'CONFIG'})}
            end

            arguments (Repeating)
                varargin 
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')
            inputArguments = [{app, callingApp, context}, varargin];

            if app.General.operationMode.Debug
                app.popupCurrentApp = eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName));
                app.popupCurrentApp.isDocked = false;

            else
                popupSpecifications = table( ...
                    'Size', [15, 4], ...
                    'VariableTypes', {'string', 'double', 'double', 'logical'}, ...
                    'VariableNames', {'AuxAppName', 'Width', 'Height', 'IsFluid'} ...
                );
                popupSpecifications(1, :) = {"CustomsAnalysisDetails", 598, 592, false};
                popupSpecifications(2, :) = {"CustomsFilter", 518, 518, false}; % PENDENTE
                popupSpecifications(3, :) = {"CustomsManageRules", 1038, 628, false}; % PENDENTE
                popupSpecifications(4, :) = {"ProductInfo", 840, 628, false};
                popupSpecifications(5, :) = {"ReportLib", 460, 608, false};
                popupSpecifications(6, :) = {"SearchAddSelectedToBucket", 518, 518, false};
                popupSpecifications(7, :) = {"SearchFilter", 518, 518, false};
                popupSpecifications(8, :) = {"SearchProductDetails", 1038, 628, false};

                auxAppNameIdx = find(popupSpecifications.AuxAppName == string(auxAppName), 1);
                screenWidth = popupSpecifications.Width(auxAppNameIdx);
                screenHeight = popupSpecifications.Height(auxAppNameIdx);
                isFluid = popupSpecifications.IsFluid(auxAppNameIdx);

                ui.PopUpContainer(callingApp, screenWidth, screenHeight)
                auxDockAppName = sprintf('auxApp.dock%s', auxAppName);
                app.popupCurrentApp = feval([auxDockAppName '_exported'], callingApp.popupContainer, inputArguments{:});
                
                ui.CustomizationBase.getElementsDataTag({
                    callingApp.popupContainer;
                    app.popupCurrentApp.GridLayout
                });

                if isFluid
                    sizing = struct('type', 'fluid', 'width', 90, 'height', 80);
                else
                    sizing = struct('type', 'fixed', 'width', screenWidth, 'height', screenHeight+31);
                end

                sendEventToHTMLSource(callingApp.jsBackDoor, 'dockContainer', struct( ...
                    'dockAppName', auxDockAppName, ...
                    'dockAppDataTag', app.popupCurrentApp.GridLayout.UserData.id, ...
                    'dockAppContainerDataTag', callingApp.popupContainer.UserData.id, ...
                    'sizing', sizing, ...
                    'context', context, ...
                    'numCanvasElements', numel(findobj(app.popupCurrentApp.Container, 'Type', 'axes')) ...
                ))

                app.popupCurrentApp.GridLayout.UserData.auxDockAppName = auxDockAppName;
                callingApp.popupContainer.UserData.auxDockAppName = auxDockAppName;
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end
    end


    methods (Access = public)
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
                        app.Tab1Button;
                        app.Tab2Button;
                        app.Tab3Button;
                        app.Tab4Button;
                        app.SearchEntryPointGrid;
                        app.SearchEntryPoint;
                        app.SearchSuggestions;
                        app.AttributesLabel;
                        app.SearchSetup;
                        app.ExportVisibleTable;
                        app.AddSelectedToBucket;
                        app.ProductDetails;
                        app.PanelVisibility;
                        app.UITable;
                        app.PopupTempWarning;
                        app.Homologation;
                        app.Image;
                        app.Ads;
                        app.WordCloud
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id, 'generation', 1, 'style', struct('border', '0')), ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPointGrid.UserData.id, 'styleImportant', struct('border', '1px solid #7d7d7d', 'borderRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id, 'generation', 1, 'style', struct('borderTop', '0')), ...
                            struct('appName', appName, 'dataTag', app.AttributesLabel.UserData.id, 'styleImportant', struct('borderLeft', '3px solid #a6a6a6', 'paddingLeft', '8px')), ...
                            struct('appName', appName, 'dataTag', app.SearchSetup.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Configura estratégia de filtragem')), ...
                            struct('appName', appName, 'dataTag', app.ExportVisibleTable.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Exporta resultados de busca em arquivo Excel (.xlsx)')), ...
                            struct('appName', appName, 'dataTag', app.AddSelectedToBucket.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Adiciona registros à lista de produtos inspecionados')), ...
                            struct('appName', appName, 'dataTag', app.ProductDetails.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Abre painel de atributos em tela inteira')), ...
                            struct('appName', appName, 'dataTag', app.PanelVisibility.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Alterna visibilidade do painel')), ...
                            struct('appName', appName, 'dataTag', app.UITable.UserData.id, 'tableMultiline', true, 'tableSelectionStyle', struct('color', '#ffffff', 'backgroundColor', '#6B879D')), ...
                            struct('appName', appName, 'dataTag', app.Tab1Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab2Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab3Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.Tab4Button.UserData.id, 'generation', 1, 'class', 'tab-navigator-button'), ...
                            struct('appName', appName, 'dataTag', app.PopupTempWarning.UserData.id, 'style', struct('borderRadius', '8px', 'pointerEvents', 'none')), ...
                            struct('appName', appName, 'dataTag', app.SearchEntryPoint.UserData.id, 'generation', 2, 'listener', struct('componentName', 'mainApp.searchEntryPoint',  'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})), ...
                            struct('appName', appName, 'dataTag', app.SearchSuggestions.UserData.id, 'generation', 1, 'listener', struct('componentName', 'mainApp.searchSuggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
                        });
                    catch
                    end

                    try
                        ui.TextView.startup(app.jsBackDoor, app.Homologation, appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
                        ui.TextView.startup(app.jsBackDoor, app.Ads,          appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
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
                    if ~strcmp(app.General_I.context.SEARCH.wordCloud.algorithm, 'D3.js')
                        app.General_I.context.SEARCH.wordCloud.algorithm = 'D3.js';
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

            app.General = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')


            % Ideia é identificar URL de pasta estática servida pelo backend, de 
            % forma que possam ser inseridas imagens em uilabel (como ui.TextView).
            try
                [~, resourceName, resourceExt] = fileparts(app.SearchSetup.ImageSource);
                sendEventToHTMLSource(app.jsBackDoor, 'findResourceStaticURL', struct('resourceName', [resourceName resourceExt], 'resourceTag', 'img', 'resourceId', app.SearchSetup.UserData.id))
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = model.Project(app, app.rootFolder);
            
            if ~strcmp(app.executionMode, 'desktopStandaloneApp') && app.General.reportLib.indexedDBCache.status
                appEngine.indexedDB.openDB(app.jsBackDoor, class.Constants.appName)
            end

            readDataBaseExternalFiles(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog, app.jsBackDoor);
            addComponent(app.tabGroupController, "Built-in", "",                   app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winCustoms",  app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.Tab4Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      4)
            app.tabGroupController.inlineSVG = true;

            % Inicialização da propriedade "UserData" da tabela.
            app.UITable.UserData.matchRowIdxs = [];
            app.UITable.UserData.columnWidth = struct('mode', 'initial', 'value', {{110, 300, 'auto', 'auto', 'auto', 'auto'}});

            % Armazena informação do valor textual buscado, no modo "FreeText" 
            % ou "FreeText+ColumnFilter".
            app.SearchEntryButton.UserData = struct('valueToSearch', '', 'wordsToSearch', {{}});

            app.AttributesVisibleIndex.UserData.index = 1;
            app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.WordCloud);
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateWarningLampVisibility(app)

            searchComponentsInitialState(app)
            updateSearchContext(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % BASES DE DADOS: SCHDATA E ANNOTATIONTABLE
        %-----------------------------------------------------------------%
        function readDataBaseExternalFiles(app)
            [app.schData, ...
             app.schDataCategories, ...
             app.releasedData, ...
             app.cacheData,    ...
             app.cacheColumns]  = util.readExternalFile.SCHData(app.rootFolder, app.General.fileFolder.DataHub_GET, app.General);
            app.annotationTable = util.readExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_GET);
        end

        %-----------------------------------------------------------------%
        % PRODUTOS SOB ANÁLISE
        %-----------------------------------------------------------------%
        function addInspectedProducts(app, schDetailedIdxs)
            addedCount = 0;

            for ii = 1:numel(schDetailedIdxs)
                idx = schDetailedIdxs(ii);
                [productData, productHash] = model.ProjectBase.initializeInspectedProduct('Homologado', app.General, app.schData.detailed, idx);
    
                if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                    continue
                end
                
                addedCount = addedCount+1;
                updateInspectedProducts(app.projectData, 'add', productData)
            end

            if addedCount
                if addedCount == 1
                    showPopupTempWarning(app, 'Incluído um registro na lista de produtos inspecionados.')
                else
                    showPopupTempWarning(app, sprintf('Incluídos %d registros na lista de produtos inspecionados.', addedCount))
                end
                ipcMainMatlabCallAuxiliarApp(app, 'PRODUCTS', 'MATLAB', 'updateInspectedProducts')
            else
                showPopupTempWarning(app, model.ProjectBase.WARNING_ENTRYEXIST.SEARCH)
            end
        end

        %-----------------------------------------------------------------%
        % FILTRAGEM
        %-----------------------------------------------------------------%
        function searchComponentsInitialState(app)
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

            onEntryPointChanging(app, struct('Value', value, 'ListBoxVisibility', false))
            onEntryButtonPushed(app)           
        end

        %-----------------------------------------------------------------%
        function entryButtonInitialState(app)
            app.SearchEntryButton.Enable = 0;
        end

        %-----------------------------------------------------------------%
        function searchSuggestionsInitialState(app)
            set(app.SearchSuggestions, Visible=0, Items={}, ItemsData=[])
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
            updateTable(app, matchRowIdxs)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function matchRowIdxs = applyTextFilter(app)
            switch app.General.context.SEARCH.mode
                case 'tokens'
                    sortOrder = 'stable';
                otherwise % 'words'
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
        function updateTable(app, matchRowIdxs)
            homAggregatedIdxs = unique(app.schData.detailed.("Índice Homologação Agregada")(matchRowIdxs), 'stable');
            homAggregatedCount = numel(homAggregatedIdxs);

            set(app.UITable, 'Data', app.schData.aggregated(homAggregatedIdxs, :), 'Selection', [])
            app.UITable.UserData.matchRowIdxs = matchRowIdxs;

            updateSearchContext(app)
            updateTableNumRows(app, homAggregatedCount)

            if ~isempty(app.UITable.Data)
                app.UITable.Selection = 1;
            end
            onTableSelectionChanged(app)

            focus(app.jsBackDoor)
        end

        %-----------------------------------------------------------------%
        function updateTableNumRows(app, numRows)
            if numRows == 0
                numRowsText = '';
            elseif numRows == 1
                numRowsText = '1 REGISTRO';
            else
                numRowsText = sprintf('%d REGISTROS', numRows);
            end

            app.NumRows.Text = numRowsText;
        end

        %-----------------------------------------------------------------%
        function updateSearchContext(app)
            searchSpecification = '';
            searchContext = '';
            columnFilterList = {};

            if ismember(app.General.context.SEARCH.type, {'FreeText', 'FreeText+ColumnFilter'})
                valueToSearch = app.SearchEntryButton.UserData.valueToSearch;
                wordsToSearch = app.SearchEntryButton.UserData.wordsToSearch;

                switch app.General.context.SEARCH.mode
                    case 'tokens'
                        searchSpecification = '[TS]';

                        if ~isempty(wordsToSearch)
                            searchContext = sprintf('Resultados para "<b>%s</b>"', valueToSearch);
                        end

                    otherwise % 'words'
                        searchSpecification = '[TE]';

                        if ~isempty(wordsToSearch)
                            searchContext = sprintf('Resultados para %s', strjoin("""<b>" + string(wordsToSearch) + "</b>""", ', '));
                        end
                end

                if isempty(searchContext)
                    searchContext = 'Nenhuma palavra';
                end
            end

            if ismember(app.General.context.SEARCH.type, {'ColumnFilter', 'FreeText+ColumnFilter'})
                if ~isempty(searchSpecification)
                    searchSpecification = [searchSpecification ' '];
                end
                searchSpecification = [searchSpecification '[FC]'];

                if ~isempty(searchContext)
                    searchContext = [searchContext ' + '];
                end

                columnFilterList = getFilterList(app.filteringObj, 'SCH', 'on');
                numColumnFilter  = numel(columnFilterList);

                switch numColumnFilter
                    case 0
                        searchContext = [searchContext 'Nenhum filtro por coluna ativo'];
                    case 1
                        searchContext = [searchContext 'Um filtro por coluna ativo'];
                    otherwise
                        searchContext = [searchContext sprintf('%d filtros por coluna ativo', numColumnFilter)];
                end
            end

            if ~isempty(columnFilterList)
                columnFilterList = sprintf('Filtros por coluna:\n%s', strjoin(strcat('• ', columnFilterList), '\n'));
            end

            set(app.SearchContext, 'Text', sprintf('%s\n%s', searchSpecification, searchContext), 'Tooltip', char(columnFilterList))
        end

        %-----------------------------------------------------------------%
        % <dockSearchResultProduct>
        %-----------------------------------------------------------------%
        function updatePanel(app)
            % Cria o contexto do produto selecionado...
            homItems = app.UITable.Data.("Homologação");
            homIndex = app.UITable.Selection;

            if ~isempty(homItems) && ~isempty(homIndex)
                homValue = homItems{homIndex};

                relatedSCHMask = strcmp(app.schData.detailed.("Homologação"), homValue);
                annotationMask = strcmp(app.annotationTable.("Homologação"), homValue);
                adsMask = strcmp(app.projectData.regulatronData.adsTable.("certificado"), replace(homValue, '-', ''));
    
                relatedSCH = app.schData.detailed(relatedSCHMask, :);
                annotations = app.annotationTable(annotationMask, :);
                images = fullfile(app.General.fileFolder.DataHub_GET, 'Images', unique(annotations(strcmp(annotations.("Atributo"), 'Image'), :).Valor));
                wordclouds = annotations(strcmp(annotations.("Atributo"), 'WordCloud'), :);
                ads = app.projectData.regulatronData.adsTable(adsMask, :);

            else
                relatedSCH = [];
                annotations = [];
                images = {};
                wordclouds = [];
                ads = [];
            end

            app.resultContext = struct( ...
                'SCH',        struct('data', relatedSCH, 'isRendered', false), ...
                'Annotation', struct('data', annotations, 'isRendered', false), ...
                'Images',     struct('data', {images}, 'index', [], 'isRendered', false), ...
                'WordCloud',  struct('data', wordclouds, 'index', [], 'isRendered', false), ...
                'Ads',        struct('data', ads, 'index', [], 'isRendered', false) ...
            );

            % Identifica o painel aberto...
            currentIndex = app.AttributesVisibleIndex.UserData.index;

            updateSCH(app, currentIndex == 1)
            updateImages(app, currentIndex == 2)
            updateWordCloud(app, currentIndex == 3)
            updateAds(app, currentIndex == 4)
        end

        %-----------------------------------------------------------------%
        function updatePanelToolbar(app)
            % Identifica o painel aberto...
            currentIndex = app.AttributesVisibleIndex.UserData.index;

            switch currentIndex
                case 1
                    set([app.AttributesPrevious, app.AttributesNext, app.AttributesImageZoom], 'Enable', 'off', 'Visible', 'off')
                    app.AttributesCount.Text = '';

                case 2
                    imagesCount = numel(app.resultContext.Images.data);
                    imageIndex = app.resultContext.Images.index;

                    set([app.AttributesPrevious, app.AttributesNext, app.AttributesImageZoom], 'Enable', imagesCount, 'Visible', 'on')

                    if imagesCount
                        app.AttributesCount.Text = sprintf('%d / %d', imageIndex, imagesCount);
                    else
                        app.AttributesCount.Text = '0 / 0';
                    end

                case 3
                    adsCount = height(app.resultContext.WordCloud.data);
                    adsIndex = app.resultContext.WordCloud.index;

                    set([app.AttributesPrevious, app.AttributesNext], 'Enable', adsCount, 'Visible', 'on')
                    set(app.AttributesImageZoom, 'Enable', 'off', 'Visible', 'off')

                    if adsCount
                        app.AttributesCount.Text = sprintf('%d / %d', adsIndex, adsCount);
                    else
                        app.AttributesCount.Text = '0 / 0';
                    end

                case 4
                    adsCount = height(app.resultContext.Ads.data);
                    adsIndex = app.resultContext.Ads.index;

                    set([app.AttributesPrevious, app.AttributesNext], 'Enable', adsCount, 'Visible', 'on')
                    set(app.AttributesImageZoom, 'Enable', 'off', 'Visible', 'off')

                    if adsCount
                        app.AttributesCount.Text = sprintf('%d / %d', adsIndex, adsCount);
                    else
                        app.AttributesCount.Text = '0 / 0';
                    end
            end
        end

        %-----------------------------------------------------------------%
        function updateSCH(app, isActive)
            if ~isActive || app.resultContext.SCH.isRendered
                if ~app.resultContext.SCH.isRendered && ~strcmp(app.Homologation.Text, '')
                    app.Homologation.Text = '';
                end

                return
            end

            relatedSCH = app.resultContext.SCH.data;
            numWordClouds = height(app.resultContext.WordCloud.data);
            numImages = numel(app.resultContext.Images.data);
            ads = app.resultContext.Ads.data;

            if isempty(relatedSCH)
                app.Homologation.Text = '';
                return
            end

            htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoHomologado', relatedSCH, numWordClouds, numImages, ads);
            ui.TextView.update(app.Homologation, htmlSource);

            app.resultContext.SCH.isRendered = true;
        end

        %-----------------------------------------------------------------%
        function updateImages(app, isActive)
            if ~isActive || app.resultContext.Images.isRendered
                if ~app.resultContext.Images.isRendered && ~strcmp(app.Image.ImageSource, 'image-missing.svg')
                    app.Image.ImageSource = 'image-missing.svg';
                end

                return
            end

            images = app.resultContext.Images.data;
            imageIndex = app.resultContext.Images.index;
            if imageIndex >= numel(app.resultContext.Images.data)
                imageIndex = numel(app.resultContext.Images.data);
            end

            if isempty(images)
                if ~strcmp(app.Image.ImageSource, 'image-missing.svg')
                    app.Image.ImageSource = 'image-missing.svg';
                end
                return
            end

            if isempty(imageIndex)
                imageIndex = 1;
            end

            try
                app.Image.ImageSource = images{imageIndex};
            catch
                if numel(app.resultContext.Images.data) >= imageIndex
                    app.resultContext.Images.data(imageIndex) = [];
                    updateImages(app, isActive)
                end
                return
            end
            
            app.resultContext.Images.index = imageIndex;
            app.resultContext.Images.isRendered = true;
        end

        %-----------------------------------------------------------------%
        function updateWordCloud(app, isActive)
            if ~isActive || app.resultContext.WordCloud.isRendered
                if ~app.resultContext.WordCloud.isRendered && ~isempty(app.wordCloudObj) && isvalid(app.wordCloudObj) && ~isempty(app.wordCloudObj.Table)
                    app.wordCloudObj.Table(:, :) = [];
                    app.WordCloudNote.Text = '';
                end

                return
            end

            if isempty(app.wordCloudObj) || ~isvalid(app.wordCloudObj)
                app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.WordCloud);
            end

            wordClouds = app.resultContext.WordCloud.data;
            wordCloudIndex = app.resultContext.WordCloud.index;

            if isempty(wordClouds)
                if ~isempty(app.wordCloudObj.Table)
                    app.wordCloudObj.Table(:, :) = [];
                    app.WordCloudNote.Text = '';
                end
                return
            end

            if isempty(wordCloudIndex)
                wordCloudIndex = 1;
            end


            [wordCloudTable, wordCloudInfo] = util.getWordCloudFromCache(wordClouds.("Valor"){wordCloudIndex});

            app.wordCloudObj.Table = wordCloudTable;
            app.WordCloudNote.Text = sprintf('%s • %s\nTERMO PESQUISADO: "%s"', wordClouds.("DataHora"){wordCloudIndex}, wordCloudInfo.metaData.Source, wordCloudInfo.searchedWord);

            app.resultContext.WordCloud.index = wordCloudIndex;
            app.resultContext.WordCloud.isRendered = true;
        end

        %-----------------------------------------------------------------%
        function updateAds(app, isActive)
            if ~isActive || app.resultContext.Ads.isRendered
                if ~app.resultContext.Ads.isRendered && ~strcmp(app.Ads.Text, '')
                    app.Ads.Text = '';
                end

                return
            end

            relatedSCH = app.resultContext.SCH.data;
            if isempty(relatedSCH)
                app.Ads.Text = '';
                return
            end

            ads = app.resultContext.Ads.data;
            adsIndex = app.resultContext.Ads.index;

            if isempty(ads)
                homologation = app.resultContext.SCH.data.("Homologação"){1};
                lastUpdate = getAdLastUpdate(app);

                app.Ads.Text = sprintf([ ...
                    '<p style="padding: 10px;">' ...
                    'Nenhum anúncio foi identificado pelo Regulatron para o ' ...
                    'produto %s até %s, data da última consolidação dos dados ' ...
                    'pela presente ferramenta.</p>' ...
                ], homologation, lastUpdate);
                return
            end

            if isempty(adsIndex)
                adsIndex = 1;
            end

            app.Ads.Text = util.HtmlTextGenerator.generateAdCard(ads(adsIndex, :), app.projectData.regulatronData.urlPreffix);

            app.resultContext.Ads.index = adsIndex;
            app.resultContext.Ads.isRendered = true;
        end

        %-----------------------------------------------------------------%
        function lastUpdate = getAdLastUpdate(app)
            if ~isempty(app.adLastUpdate)
                lastUpdate = app.adLastUpdate;
            else
                adDatetime = sortrows(app.projectData.regulatronData.adsTable.data, 'descend');
                lastUpdate = datestr(datetime(adDatetime{1}, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss"), 'dd/mm/yyyy');
                app.adLastUpdate = lastUpdate;
            end
        end

        %-----------------------------------------------------------------%
        function updateWarningLampVisibility(app)
            app.DataHubLamp.Visible = ~isfolder(app.General.fileFolder.DataHub_GET) || ~isfolder(app.General.fileFolder.DataHub_POST);
        end

        %-----------------------------------------------------------------%
        function showPopupTempWarning(app, msg)
            app.AddSelectedToBucket.Enable = "off";
            set(app.PopupTempWarning, 'Text', msg, 'Visible', 'on')
            sendEventToHTMLSource(app.jsBackDoor, 'setBackgroundTransparent', struct('componentName', 'PopupTempWarning', 'componentDataTag', app.PopupTempWarning.UserData.id, 'interval_ms', 75));
            drawnow
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            nonEmptyTable = ~isempty(app.UITable.Data);
            nonEmptySelection = ~isempty(app.UITable.Selection);

            app.ExportVisibleTable.Enable = nonEmptyTable;
            app.ProductDetails.Enable = nonEmptyTable;

            if app.PopupTempWarning.Visible
                matlab.waitfor(app.PopupTempWarning, 'Visible', @(propValue) ~logical(propValue), .5, 5, 'propValue')
            end
            app.AddSelectedToBucket.Enable = nonEmptySelection;
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
        function reportHandleOperation(app, eventName, context, credentials, varargin)
            arguments
                app
                eventName {mustBeMember(eventName, {'onFetchIssueDetails', 'onReportGenerate', 'onUploadArtifacts'})}
                context {mustBeMember(context, {'PRODUCTS', 'CUSTOMS'})}
                credentials
            end

            arguments (Repeating)
                varargin
            end

            switch eventName
                case 'onFetchIssueDetails'
                    reportFetchIssueDetails(app, context, credentials)

                case 'onReportGenerate'
                    reportGenerate(app, context, credentials);
        
                case 'onUploadArtifacts'
                    reportUploadArtifacts(app, context, credentials, 'uploadDocument');
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

            else
                if isempty(msgError)
                    msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                    icon = 'info';
                else
                    app.eFiscalizaObj = [];
                    msg = msgError;
                    icon = 'error';
                end
                ui.Dialog(app.UIFigure, icon, msg);
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
            [status1, icon1, msg1, seiReport] = reportUploadToSEI(app, context, operation, true);
            ui.Dialog(callingApp.UIFigure, icon1, msg1);

            callingApp.progressDialog.Visible = 'hidden';

            if status1 && strcmp(app.projectData.modules.(context).ui.system, 'eFiscaliza')
                [status2, msg2] = reportUploadFilesToSharepoint(app, context, seiReport);

                if ~status2
                    ui.Dialog(callingApp.UIFigure, 'error', msg2);
                end
            end
        end

        %-------------------------------------------------------------------------%
        function [status, icon, msg, seiReport] = reportUploadToSEI(app, context, operation, updateUploadedFileList)
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
                        correlationKey = model.ProjectCommon.extractCorrelationKey(HTMLFile);

                        [~, modelIdx]   = ismember(app.projectData.modules.(context).ui.reportModel, {app.projectData.report.templates.Name});
                        docType         = app.projectData.report.templates(modelIdx).DocumentType;
                        [~, docTypeIdx] = ismember(docType, {app.General.eFiscaliza.internal.typeIdMapping.type});

                        docSpec = app.General.eFiscaliza;
                        docSpec.originId = docSpec.internal.originId;
                        docSpec.typeId = app.General.eFiscaliza.internal.typeIdMapping(docTypeIdx).id;
                        docSpec.nomeArvore = ['[' class.Constants.appName ']'];
                        docSpec.note = sprintf('%s\ncorrelationKey="%s"', docSpec.note, correlationKey);

                        if app.projectData.modules.(context).ui.entity.status
                            docSpec.interessados = {struct( ...
                                'sigla', app.projectData.modules.(context).ui.entity.id, ...
                                'nome', app.projectData.modules.(context).ui.entity.name ...
                            )};
                        end     

                        [response, seiReport] = run(app.eFiscalizaObj, env, operation, issueInfo, unit, docSpec, HTMLFile);

                    otherwise
                        error('Unexpected call')
                end

                if ~contains(response, 'Documento cadastrado no SEI', 'IgnoreCase', true)
                    error(response)
                end

                if updateUploadedFileList
                    updateUploadedFiles(app.projectData, context, system, issue, response)
                end

                status = true;
                icon = 'success';
                msg = response;

            catch ME
                app.eFiscalizaObj = [];
                
                status = false;
                icon = 'error';
                msg = ME.message;
                seiReport = '';
            end
        end

        %------------------------------------------------------------------------%
        function [status, msg] = reportUploadFilesToSharepoint(app, context, seiReport)
            sharepointFileList = { ...
                getGeneratedDocumentFileName(app.projectData, '.json',  context), ...
                getGeneratedDocumentFileName(app.projectData, '.teams', context)  ...
            };
            model.ProjectCommon.updateSeiReport(sharepointFileList{1}, seiReport)
        
            statusList = false(1, numel(sharepointFileList));
            msgList = {};
        
            for ii = 1:numel(sharepointFileList)
                [statusList(ii), msgWarning] = copyfile(sharepointFileList{ii}, app.General.fileFolder.DataHub_POST, 'f');
        
                if ~statusList(ii)
                    msgList{end+1} = msgWarning;
                end
            end
        
            status = all(statusList);
            msg = strjoin(msgList, '\n\n');
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

            IndexedDBCache(app.projectData)
            
            try
                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
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

            % Aspectos gerais (comum em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)

        end

        % Callback function: UIFigure, UITable
        function onFigureWindowButtonDown(app, event)

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
                        entryButtonInitialState(app)
                    end
            end

        end

        % Callback function: AppInfo, DataHubLamp, FigurePosition, 
        % ...and 4 other components
        function onTabNavigatorButtonPushed(app, event)

            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button, app.Tab4Button}
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, app)

                case app.DataHubLamp
                    msg = [ ...
                        'Pendente mapear as pastas GET/POST do SharePoint, de modo a viabilizar:<br>' ...
                        '•&thinsp;Consulta à base atualizada de produtos para telecomunicações com homologação expedida pela Anatel;<br>' ...
                        '•&thinsp;Upload do relatório final para o SEI.' ...
                    ];
                    ui.Dialog(app.UIFigure, 'error', msg);

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
                        app.schData.detailed, ...
                        app.releasedData, ...
                        app.cacheData, ...
                        app.annotationTable, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end

        end

        % Value changing function: SearchEntryPoint
        function onEntryPointChanging(app, event)

            valueToSearch = textAnalysis.preProcessedData(event.Value, false);

            if numel(valueToSearch) < app.General.context.SEARCH.minCharacters
                app.SearchEntryButton.Enable = 0;
                searchSuggestionsInitialState(app)

            else
                app.SearchEntryButton.Enable = 1;

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

        % Image clicked function: SearchEntryButton
        function onEntryButtonPushed(app, event)
            
            valueToSearch = textAnalysis.preProcessedData(app.SearchEntryPoint.Value, false);

            switch app.General.context.SEARCH.mode
                case 'tokens'
                    if isempty(app.SearchSuggestions.Items)
                        onEntryPointChanging(app, struct('Value', app.SearchEntryPoint.Value, 'ListBoxVisibility', false))
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

        % Selection changed function: UITable
        function onTableSelectionChanged(app, event)
            
            updatePanel(app)
            updatePanelToolbar(app)

            updateToolbar(app)

        end

        % Image clicked function: ProductDetails, SearchSetup
        function onOpenPopupApp(app, event)
            
            switch event.Source
                case app.SearchSetup
                    ipcMainMatlabOpenPopupApp(app, app, 'SearchFilter', app.Context)

                case app.ProductDetails
                    if isempty(app.UITable.Data)
                        return
                    end
        
                    if isempty(app.UITable.Selection)
                        app.UITable.Selection = 1;
                        onTableSelectionChanged(app)
                    end
        
                    homValues = struct( ...
                        'items', {app.UITable.Data.("Homologação")}, ...
                        'selectedIndex', app.UITable.Selection ...
                    );

                    ipcMainMatlabOpenPopupApp(app, app, 'SearchProductDetails', app.Context, homValues, app.resultContext)
            end

        end

        % Image clicked function: ExportVisibleTable
        function onExportVisibleTable(app, event)
            
            nameFormatMap = {'*.xlsx', 'Excel'};
            defaultName   = appEngine.util.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                matchRowIdxs = app.UITable.UserData.matchRowIdxs;
                columnNames  = app.schData.detailed.Properties.VariableNames(~startsWith(app.schData.detailed.Properties.VariableNames, '_'));
                writetable(app.schData.detailed(matchRowIdxs, columnNames), fileFullPath, 'WriteMode', 'overwritesheet')
                
            catch ME
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: AddSelectedToBucket
        function onAddSelectedToBucket(app, event)
            
            selectedRow = app.UITable.Selection;
            if isempty(selectedRow)
                return
            end

            matchRowIdxs = app.UITable.UserData.matchRowIdxs;
            schDetailedIdxs = matchRowIdxs(strcmp(app.schData.detailed.("Homologação")(matchRowIdxs), app.UITable.Data.("Homologação"){selectedRow}));

            schDetailed = app.schData.detailed(schDetailedIdxs, {'Homologação', 'Solicitante', 'Fabricante', 'Modelo', 'Nome Comercial'});
            [~, schDetailedUniqueFirstIdxs] = unique(schDetailed, "rows");
            schDetailedIdxs = schDetailedIdxs(schDetailedUniqueFirstIdxs);
            
            if numel(schDetailedIdxs) > 1
                ipcMainMatlabOpenPopupApp(app, app, 'SearchAddSelectedToBucket', app.Context, schDetailedIdxs)
                return
            end

            addInspectedProducts(app, schDetailedIdxs)

        end

        % Callback function: ColumnWidthMode
        function onColumnWidthModeChanged(app, event)
            
            app.ColumnWidthMode.Enable = "off";

            previousSelectedRow = app.UITable.Selection;
            app.UITable.Selection = [];
            
            switch app.UITable.UserData.columnWidth.mode
                case 'initial'
                    app.UITable.UserData.columnWidth.mode = 'fix';
                    app.UITable.ColumnWidth = '1x';
                    app.ColumnWidthMode.Text = 'FIXO ↔';
                case 'fix'
                    app.UITable.UserData.columnWidth.mode = 'auto';
                    app.UITable.ColumnWidth = 'auto';
                    app.ColumnWidthMode.Text = 'AUTO ↔';
                otherwise % 'auto'
                    app.UITable.UserData.columnWidth.mode = 'initial';
                    app.UITable.ColumnWidth = app.UITable.UserData.columnWidth.value;
                    app.ColumnWidthMode.Text = 'INICIAL ↔';
            end
            
            pause(.150)
            app.UITable.Selection = previousSelectedRow;            
            
            pause(1)
            app.ColumnWidthMode.Enable = "on";

        end

        % Image clicked function: AttributesLeftButton, 
        % ...and 1 other component
        function onPanelViewChanged(app, event)
            
            numPanels = 4;

            panelSubtitles = {'Homologação', 'Imagem', 'Nuvem de palavras', 'Anúncio'};
            panelBtnStatus = [false true; true true; true true; true false];
            columnWidths = {
                {'1x',0,0,0};
                {0,'1x',0,0};
                {0,0,'1x',0};
                {0,0,0,'1x'}
            };

            currentIndex = app.AttributesVisibleIndex.UserData.index;
            
            switch event.Source
                case app.AttributesLeftButton
                    step = -1;
                case app.AttributesRightButton
                    step = 1;
            end

            currentIndex = mod(currentIndex - 1 + step, numPanels) + 1;
            
            app.AttributesLeftButton.Enable  = panelBtnStatus(currentIndex, 1);
            app.AttributesRightButton.Enable = panelBtnStatus(currentIndex, 2);
            app.AttributesVisibleIndex.Text = sprintf('%d/%d', currentIndex, numPanels);
            app.AttributesVisibleIndex.UserData.index = currentIndex;

            app.AttributesGrid.ColumnWidth = columnWidths{currentIndex};
            app.AttributesLabel.Text = replace(app.AttributesLabel.Text, extractBetween(app.AttributesLabel.Text, '<i>', '</i>'), panelSubtitles{currentIndex});
            drawnow

            updateSCH(app, currentIndex == 1)
            updateImages(app, currentIndex == 2)
            updateWordCloud(app, currentIndex == 3)
            updateAds(app, currentIndex == 4)

            updatePanelToolbar(app)

        end

        % Image clicked function: PanelVisibility
        function onPanelVisibilityChanged(app, event)
            
            if app.UITableGrid.ColumnWidth{end} == 320
                app.UITableGrid.ColumnWidth{end} = 0;
                app.PanelVisibility.ImageSource = 'layout-sidebar-right-off.svg';

                % Simula ida para o painel principal...
                if app.AttributesVisibleIndex.UserData.index ~= 1
                    app.AttributesVisibleIndex.UserData.index = 2;
                    onPanelViewChanged(app, struct('Source', app.AttributesLeftButton))
                end

            else
                app.UITableGrid.ColumnWidth{end} = 320;
                app.PanelVisibility.ImageSource = 'layout-sidebar-right.svg';
            end            

        end

        % Image clicked function: AttributesNext, AttributesPrevious
        function onPanelPreviousOrNextElement(app, event)
            
            currentIndex = app.AttributesVisibleIndex.UserData.index;
            switch currentIndex
                case 2
                    images = app.resultContext.Images.data;
                    imageCurrentIndex = app.resultContext.Images.index;
        
                    numImages = numel(images);
                    if numImages > 1
                        app.resultContext.Images.isRendered = false;
                    end
        
                    switch event.Source
                        case app.AttributesPrevious
                            imageNewIndex = imageCurrentIndex - 1;
                        otherwise % app.AttributesNext
                            imageNewIndex = imageCurrentIndex + 1;
                    end
        
                    if imageNewIndex < 1
                        imageNewIndex = numImages;
                    elseif imageNewIndex > numImages
                        imageNewIndex = 1;
                    end
        
                    app.resultContext.Images.index = imageNewIndex;
                    updateImages(app, true)

                case 3
                    wordclouds = app.resultContext.WordCloud.data;
                    wordcloudCurrentIndex = app.resultContext.WordCloud.index;
        
                    numWordClouds = height(wordclouds);
                    if numWordClouds > 1
                        app.resultContext.WordCloud.isRendered = false;
                    end
        
                    switch event.Source
                        case app.AttributesPrevious
                            wordcloudNewIndex = wordcloudCurrentIndex - 1;
                        otherwise % app.AttributesNext
                            wordcloudNewIndex = wordcloudCurrentIndex + 1;
                    end
        
                    if wordcloudNewIndex < 1
                        wordcloudNewIndex = numWordClouds;
                    elseif wordcloudNewIndex > numWordClouds
                        wordcloudNewIndex = 1;
                    end
        
                    app.resultContext.WordCloud.index = wordcloudNewIndex;
                    updateWordCloud(app, true)

                case 4
                    adsTable = app.resultContext.Ads.data;
                    adsCurrentIndex = app.resultContext.Ads.index;
        
                    numAds = height(adsTable);
                    if numAds > 1
                        app.resultContext.Ads.isRendered = false;
                    end
        
                    switch event.Source
                        case app.AttributesPrevious
                            adsNewIndex = adsCurrentIndex - 1;
                        otherwise % app.AttributesNext
                            adsNewIndex = adsCurrentIndex + 1;
                    end
        
                    if adsNewIndex < 1
                        adsNewIndex = numAds;
                    elseif adsNewIndex > numAds
                        adsNewIndex = 1;
                    end
        
                    app.resultContext.Ads.index = adsNewIndex;
                    updateAds(app, true)
            end

            updatePanelToolbar(app)

        end

        % Image clicked function: AttributesImageZoom
        function onPanelImageZoom(app, event)
            
            currentIndex = app.AttributesVisibleIndex.UserData.index;
            if currentIndex ~= 2
                return
            end

            sendEventToHTMLSource(app.jsBackDoor, 'imageHighlight', struct('dataTag', app.Image.UserData.id))

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
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @onFigureWindowButtonDown, true);

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

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1_Search);
            app.Tab1Grid.ColumnWidth = {20, 18, 5, '1x', 412, '1x', 23, 20};
            app.Tab1Grid.RowHeight = {20, 28, 6, 20, 342, '1x', 34, 20, 34};
            app.Tab1Grid.ColumnSpacing = 0;
            app.Tab1Grid.RowSpacing = 0;
            app.Tab1Grid.Padding = [0 0 0 30];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create SearchSetup
            app.SearchSetup = uiimage(app.Tab1Grid);
            app.SearchSetup.ScaleMethod = 'none';
            app.SearchSetup.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.SearchSetup.Layout.Row = [3 4];
            app.SearchSetup.Layout.Column = 2;
            app.SearchSetup.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'settings.svg');

            % Create SearchContext
            app.SearchContext = uilabel(app.Tab1Grid);
            app.SearchContext.FontSize = 10;
            app.SearchContext.FontColor = [0.502 0.502 0.502];
            app.SearchContext.Layout.Row = [3 4];
            app.SearchContext.Layout.Column = [4 7];
            app.SearchContext.Interpreter = 'html';
            app.SearchContext.Text = {'[TS] [FC] '; 'Nenhuma palavra + Nenhum filtro por coluna ativo '};

            % Create UITableGrid
            app.UITableGrid = uigridlayout(app.Tab1Grid);
            app.UITableGrid.ColumnWidth = {'1x', 54, 320};
            app.UITableGrid.RowHeight = {'1x', 20};
            app.UITableGrid.ColumnSpacing = 20;
            app.UITableGrid.RowSpacing = 0;
            app.UITableGrid.Padding = [0 0 0 0];
            app.UITableGrid.Layout.Row = [5 8];
            app.UITableGrid.Layout.Column = [2 7];
            app.UITableGrid.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.UITableGrid);
            app.UITable.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'};
            app.UITable.ColumnWidth = {110, 300, 'auto', 'auto', 'auto', 'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.ClickedFcn = createCallbackFcn(app, @onFigureWindowButtonDown, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = [1 2];
            app.UITable.FontSize = 11;

            % Create NumRows
            app.NumRows = uilabel(app.UITableGrid);
            app.NumRows.FontSize = 10;
            app.NumRows.FontColor = [0.502 0.502 0.502];
            app.NumRows.Layout.Row = 2;
            app.NumRows.Layout.Column = 1;
            app.NumRows.Text = '';

            % Create ColumnWidthMode
            app.ColumnWidthMode = uihyperlink(app.UITableGrid);
            app.ColumnWidthMode.HyperlinkClickedFcn = createCallbackFcn(app, @onColumnWidthModeChanged, true);
            app.ColumnWidthMode.VisitedColor = [0.502 0.502 0.502];
            app.ColumnWidthMode.HorizontalAlignment = 'right';
            app.ColumnWidthMode.FontSize = 10;
            app.ColumnWidthMode.FontWeight = 'normal';
            app.ColumnWidthMode.FontColor = [0.502 0.502 0.502];
            app.ColumnWidthMode.Layout.Row = 2;
            app.ColumnWidthMode.Layout.Column = 2;
            app.ColumnWidthMode.Text = 'INICIAL ↔';

            % Create ProductDetailsGrid
            app.ProductDetailsGrid = uigridlayout(app.UITableGrid);
            app.ProductDetailsGrid.ColumnWidth = {18, 18, 18, '1x', 18, 10, 18};
            app.ProductDetailsGrid.RowHeight = {24, 5, '1x', 20};
            app.ProductDetailsGrid.ColumnSpacing = 5;
            app.ProductDetailsGrid.RowSpacing = 0;
            app.ProductDetailsGrid.Padding = [0 0 0 0];
            app.ProductDetailsGrid.Layout.Row = [1 2];
            app.ProductDetailsGrid.Layout.Column = 3;
            app.ProductDetailsGrid.BackgroundColor = [1 1 1];

            % Create AttributesLabel
            app.AttributesLabel = uilabel(app.ProductDetailsGrid);
            app.AttributesLabel.FontSize = 10;
            app.AttributesLabel.Layout.Row = 1;
            app.AttributesLabel.Layout.Column = [1 4];
            app.AttributesLabel.Interpreter = 'html';
            app.AttributesLabel.Text = 'ATRIBUTOS DO PRODUTO<br><font style="font-size: 11px;"><i>Homologação</i></font>';

            % Create AttributesVisibleIndex
            app.AttributesVisibleIndex = uilabel(app.ProductDetailsGrid);
            app.AttributesVisibleIndex.HorizontalAlignment = 'center';
            app.AttributesVisibleIndex.FontSize = 10;
            app.AttributesVisibleIndex.FontColor = [0.502 0.502 0.502];
            app.AttributesVisibleIndex.Layout.Row = 1;
            app.AttributesVisibleIndex.Layout.Column = [5 7];
            app.AttributesVisibleIndex.Text = '1/4';

            % Create AttributesLeftButton
            app.AttributesLeftButton = uiimage(app.ProductDetailsGrid);
            app.AttributesLeftButton.ImageClickedFcn = createCallbackFcn(app, @onPanelViewChanged, true);
            app.AttributesLeftButton.Enable = 'off';
            app.AttributesLeftButton.Layout.Row = 1;
            app.AttributesLeftButton.Layout.Column = 5;
            app.AttributesLeftButton.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'triangle-left.svg');

            % Create AttributesRightButton
            app.AttributesRightButton = uiimage(app.ProductDetailsGrid);
            app.AttributesRightButton.ImageClickedFcn = createCallbackFcn(app, @onPanelViewChanged, true);
            app.AttributesRightButton.Layout.Row = 1;
            app.AttributesRightButton.Layout.Column = 7;
            app.AttributesRightButton.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'triangle-right.svg');

            % Create AttributesPanel
            app.AttributesPanel = uipanel(app.ProductDetailsGrid);
            app.AttributesPanel.AutoResizeChildren = 'off';
            app.AttributesPanel.Layout.Row = 3;
            app.AttributesPanel.Layout.Column = [1 7];

            % Create AttributesGrid
            app.AttributesGrid = uigridlayout(app.AttributesPanel);
            app.AttributesGrid.ColumnWidth = {'1x', 0, 0, 0};
            app.AttributesGrid.RowHeight = {'1x'};
            app.AttributesGrid.ColumnSpacing = 0;
            app.AttributesGrid.RowSpacing = 0;
            app.AttributesGrid.Padding = [0 0 0 0];
            app.AttributesGrid.BackgroundColor = [1 1 1];

            % Create Homologation
            app.Homologation = uilabel(app.AttributesGrid);
            app.Homologation.BackgroundColor = [1 1 1];
            app.Homologation.VerticalAlignment = 'top';
            app.Homologation.WordWrap = 'on';
            app.Homologation.FontSize = 11;
            app.Homologation.Layout.Row = 1;
            app.Homologation.Layout.Column = 1;
            app.Homologation.Interpreter = 'html';
            app.Homologation.Text = '';

            % Create Image
            app.Image = uiimage(app.AttributesGrid);
            app.Image.BackgroundColor = [1 1 1];
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = 'image-missing.svg';

            % Create WordCloud
            app.WordCloud = uigridlayout(app.AttributesGrid);
            app.WordCloud.ColumnWidth = {'1x'};
            app.WordCloud.RowHeight = {'1x'};
            app.WordCloud.Padding = [5 5 5 5];
            app.WordCloud.Layout.Row = 1;
            app.WordCloud.Layout.Column = 3;
            app.WordCloud.BackgroundColor = [1 1 1];

            % Create WordCloudNote
            app.WordCloudNote = uilabel(app.WordCloud);
            app.WordCloudNote.VerticalAlignment = 'bottom';
            app.WordCloudNote.FontSize = 10;
            app.WordCloudNote.FontColor = [0.502 0.502 0.502];
            app.WordCloudNote.Layout.Row = 1;
            app.WordCloudNote.Layout.Column = 1;
            app.WordCloudNote.Text = '';

            % Create Ads
            app.Ads = uilabel(app.AttributesGrid);
            app.Ads.BackgroundColor = [1 1 1];
            app.Ads.VerticalAlignment = 'top';
            app.Ads.WordWrap = 'on';
            app.Ads.FontSize = 11;
            app.Ads.Layout.Row = 1;
            app.Ads.Layout.Column = 4;
            app.Ads.Interpreter = 'html';
            app.Ads.Text = '';

            % Create AttributesPrevious
            app.AttributesPrevious = uiimage(app.ProductDetailsGrid);
            app.AttributesPrevious.ScaleMethod = 'none';
            app.AttributesPrevious.ImageClickedFcn = createCallbackFcn(app, @onPanelPreviousOrNextElement, true);
            app.AttributesPrevious.Visible = 'off';
            app.AttributesPrevious.Layout.Row = 4;
            app.AttributesPrevious.Layout.Column = 1;
            app.AttributesPrevious.ImageSource = 'chevron-left.svg';

            % Create AttributesNext
            app.AttributesNext = uiimage(app.ProductDetailsGrid);
            app.AttributesNext.ScaleMethod = 'none';
            app.AttributesNext.ImageClickedFcn = createCallbackFcn(app, @onPanelPreviousOrNextElement, true);
            app.AttributesNext.Visible = 'off';
            app.AttributesNext.Layout.Row = 4;
            app.AttributesNext.Layout.Column = 2;
            app.AttributesNext.ImageSource = 'chevron-right.svg';

            % Create AttributesImageZoom
            app.AttributesImageZoom = uiimage(app.ProductDetailsGrid);
            app.AttributesImageZoom.ScaleMethod = 'none';
            app.AttributesImageZoom.ImageClickedFcn = createCallbackFcn(app, @onPanelImageZoom, true);
            app.AttributesImageZoom.Visible = 'off';
            app.AttributesImageZoom.Layout.Row = 4;
            app.AttributesImageZoom.Layout.Column = 3;
            app.AttributesImageZoom.ImageSource = 'screen-full.svg';

            % Create AttributesCount
            app.AttributesCount = uilabel(app.ProductDetailsGrid);
            app.AttributesCount.HorizontalAlignment = 'right';
            app.AttributesCount.FontSize = 10;
            app.AttributesCount.FontColor = [0.502 0.502 0.502];
            app.AttributesCount.Layout.Row = 4;
            app.AttributesCount.Layout.Column = [4 7];
            app.AttributesCount.Text = '';

            % Create PopupTempWarning
            app.PopupTempWarning = uilabel(app.Tab1Grid);
            app.PopupTempWarning.BackgroundColor = [0.2 0.2 0.2];
            app.PopupTempWarning.HorizontalAlignment = 'center';
            app.PopupTempWarning.WordWrap = 'on';
            app.PopupTempWarning.FontColor = [1 1 1];
            app.PopupTempWarning.Visible = 'off';
            app.PopupTempWarning.Layout.Row = 7;
            app.PopupTempWarning.Layout.Column = [2 7];
            app.PopupTempWarning.Text = '';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Tab1Grid);
            app.Toolbar.ColumnWidth = {22, 5, 22, '1x', 22, 22};
            app.Toolbar.RowHeight = {4, 17, '1x', '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 8];

            % Create ExportVisibleTable
            app.ExportVisibleTable = uiimage(app.Toolbar);
            app.ExportVisibleTable.ScaleMethod = 'none';
            app.ExportVisibleTable.ImageClickedFcn = createCallbackFcn(app, @onExportVisibleTable, true);
            app.ExportVisibleTable.Enable = 'off';
            app.ExportVisibleTable.Layout.Row = [1 4];
            app.ExportVisibleTable.Layout.Column = 1;
            app.ExportVisibleTable.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Export_16.png');

            % Create ToolbarSeparator
            app.ToolbarSeparator = uiimage(app.Toolbar);
            app.ToolbarSeparator.ScaleMethod = 'none';
            app.ToolbarSeparator.Enable = 'off';
            app.ToolbarSeparator.Layout.Row = [1 4];
            app.ToolbarSeparator.Layout.Column = 2;
            app.ToolbarSeparator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create AddSelectedToBucket
            app.AddSelectedToBucket = uiimage(app.Toolbar);
            app.AddSelectedToBucket.ImageClickedFcn = createCallbackFcn(app, @onAddSelectedToBucket, true);
            app.AddSelectedToBucket.Enable = 'off';
            app.AddSelectedToBucket.Layout.Row = [1 4];
            app.AddSelectedToBucket.Layout.Column = 3;
            app.AddSelectedToBucket.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Picture1.png');

            % Create ProductDetails
            app.ProductDetails = uiimage(app.Toolbar);
            app.ProductDetails.ScaleMethod = 'none';
            app.ProductDetails.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.ProductDetails.Enable = 'off';
            app.ProductDetails.Layout.Row = [1 4];
            app.ProductDetails.Layout.Column = 5;
            app.ProductDetails.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'open-in-window.svg');

            % Create PanelVisibility
            app.PanelVisibility = uiimage(app.Toolbar);
            app.PanelVisibility.ScaleMethod = 'none';
            app.PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @onPanelVisibilityChanged, true);
            app.PanelVisibility.Layout.Row = [1 4];
            app.PanelVisibility.Layout.Column = 6;
            app.PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout-sidebar-right.svg');

            % Create SearchEntryPointGrid
            app.SearchEntryPointGrid = uigridlayout(app.Tab1Grid);
            app.SearchEntryPointGrid.ColumnWidth = {'1x', 28};
            app.SearchEntryPointGrid.RowHeight = {'1x'};
            app.SearchEntryPointGrid.ColumnSpacing = 0;
            app.SearchEntryPointGrid.RowSpacing = 0;
            app.SearchEntryPointGrid.Padding = [0 0 0 0];
            app.SearchEntryPointGrid.Layout.Row = [2 3];
            app.SearchEntryPointGrid.Layout.Column = 5;
            app.SearchEntryPointGrid.BackgroundColor = [1 1 1];

            % Create SearchEntryPoint
            app.SearchEntryPoint = uieditfield(app.SearchEntryPointGrid, 'text');
            app.SearchEntryPoint.CharacterLimits = [0 128];
            app.SearchEntryPoint.ValueChangingFcn = createCallbackFcn(app, @onEntryPointChanging, true);
            app.SearchEntryPoint.Tag = 'PROMPT';
            app.SearchEntryPoint.FontSize = 14;
            app.SearchEntryPoint.Placeholder = 'O que você quer pesquisar?';
            app.SearchEntryPoint.Layout.Row = 1;
            app.SearchEntryPoint.Layout.Column = 1;

            % Create SearchEntryButton
            app.SearchEntryButton = uiimage(app.SearchEntryPointGrid);
            app.SearchEntryButton.ScaleMethod = 'scaledown';
            app.SearchEntryButton.ImageClickedFcn = createCallbackFcn(app, @onEntryButtonPushed, true);
            app.SearchEntryButton.Enable = 'off';
            app.SearchEntryButton.Layout.Row = 1;
            app.SearchEntryButton.Layout.Column = 2;
            app.SearchEntryButton.ImageSource = 'Zoom_36x36.png';

            % Create SearchSuggestions
            app.SearchSuggestions = uilistbox(app.Tab1Grid);
            app.SearchSuggestions.Items = {''};
            app.SearchSuggestions.Tag = 'CAIXA DE BUSCA';
            app.SearchSuggestions.Visible = 'off';
            app.SearchSuggestions.FontSize = 14;
            app.SearchSuggestions.Layout.Row = [4 5];
            app.SearchSuggestions.Layout.Column = 5;
            app.SearchSuggestions.Value = {};

            % Create Tab2_Products
            app.Tab2_Products = uitab(app.TabGroup);
            app.Tab2_Products.AutoResizeChildren = 'off';

            % Create Tab3_Customs
            app.Tab3_Customs = uitab(app.TabGroup);
            app.Tab3_Customs.AutoResizeChildren = 'off';

            % Create Tab4_Config
            app.Tab4_Config = uitab(app.TabGroup);

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {101, '1x', 34, 34, 5, 34, 5, 34, '1x', 20, 20, 1, 20, 20};
            app.NavBar.RowHeight = {5, 7, 20, 7, 5};
            app.NavBar.ColumnSpacing = 5;
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 5 5 5];
            app.NavBar.Tag = 'COLORLOCKED';
            app.NavBar.Layout.Row = 1;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.2 0.2 0.2];

            % Create AppName
            app.AppName = uilabel(app.NavBar);
            app.AppName.WordWrap = 'on';
            app.AppName.FontSize = 11;
            app.AppName.FontColor = [1 1 1];
            app.AppName.Layout.Row = [1 5];
            app.AppName.Layout.Column = [1 2];
            app.AppName.Interpreter = 'html';
            app.AppName.Text = {'SCH v. 1.10.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create Tab1Button
            app.Tab1Button = uibutton(app.NavBar, 'state');
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'SEARCH';
            app.Tab1Button.Tooltip = {'Pesquisa de produtos'};
            app.Tab1Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'search-sparkle-24px-yellow.svg');
            app.Tab1Button.IconAlignment = 'top';
            app.Tab1Button.Text = '';
            app.Tab1Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab1Button.Layout.Row = [2 4];
            app.Tab1Button.Layout.Column = 3;
            app.Tab1Button.Value = true;

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'PRODUCTS';
            app.Tab2Button.Tooltip = {'Produtos inspecionados'; '(Comércio/Aduana)'};
            app.Tab2Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'checklist-24px-white.svg');
            app.Tab2Button.IconAlignment = 'top';
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 4;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'CUSTOMS';
            app.Tab3Button.Tooltip = {'Remessa conforme'; '(Aduana)'};
            app.Tab3Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'group-by-ref-type-24px-white.svg');
            app.Tab3Button.IconAlignment = 'top';
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 6;

            % Create ButtonsSeparator
            app.ButtonsSeparator = uiimage(app.NavBar);
            app.ButtonsSeparator.ScaleMethod = 'none';
            app.ButtonsSeparator.Enable = 'off';
            app.ButtonsSeparator.Layout.Row = [2 4];
            app.ButtonsSeparator.Layout.Column = 7;
            app.ButtonsSeparator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'CONFIG';
            app.Tab4Button.Tooltip = {'Configurações gerais'};
            app.Tab4Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'gear-24px-white.svg');
            app.Tab4Button.IconAlignment = 'top';
            app.Tab4Button.Text = '';
            app.Tab4Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab4Button.Layout.Row = [2 4];
            app.Tab4Button.Layout.Column = 8;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.NavBar);
            app.jsBackDoor.Layout.Row = 3;
            app.jsBackDoor.Layout.Column = 10;

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.NavBar);
            app.DataHubLamp.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 11;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ScaleMethod = 'none';
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 13;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 14;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'kebab-vertical-24px-white.svg');

            % Create ButtonsSeparator_2
            app.ButtonsSeparator_2 = uiimage(app.NavBar);
            app.ButtonsSeparator_2.ScaleMethod = 'none';
            app.ButtonsSeparator_2.Enable = 'off';
            app.ButtonsSeparator_2.Layout.Row = [2 4];
            app.ButtonsSeparator_2.Layout.Column = 5;
            app.ButtonsSeparator_2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

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
