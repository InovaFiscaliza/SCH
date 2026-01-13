classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        NavBar                          matlab.ui.container.GridLayout
        AppInfo                         matlab.ui.control.Image
        FigurePosition                  matlab.ui.control.Image
        DataHubLamp                     matlab.ui.control.Image
        Tab3Button                      matlab.ui.control.StateButton
        ButtonsSeparator                matlab.ui.control.Image
        Tab2Button                      matlab.ui.control.StateButton
        Tab1Button                      matlab.ui.control.StateButton
        AppName                         matlab.ui.control.Label
        AppIcon                         matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        Tab1_Search                     matlab.ui.container.Tab
        Tab1Grid                        matlab.ui.container.GridLayout
        searchSuggestions               matlab.ui.control.ListBox
        searchEntryPointGrid            matlab.ui.container.GridLayout
        searchEntryButton               matlab.ui.control.Image
        searchEntryPoint                matlab.ui.control.EditField
        PopupTempWarning                matlab.ui.control.Label
        Document                        matlab.ui.container.GridLayout
        selectedProductPanelGrid        matlab.ui.container.GridLayout
        jsBackDoor                      matlab.ui.control.HTML
        wordCloudPanel                  matlab.ui.container.Panel
        selectedProductPanelInfo        matlab.ui.control.Label
        selectedProductPanelBackground  matlab.ui.control.Image
        UITable                         matlab.ui.control.Table
        UITable_NumRows                 matlab.ui.control.Label
        filterSpecification             matlab.ui.control.Label
        filterSpecificationIcon         matlab.ui.control.Image
        Toolbar                         matlab.ui.container.GridLayout
        tool_AddSelectedToBucket        matlab.ui.control.Image
        tool_Separator3                 matlab.ui.control.Image
        tool_ExportVisibleTable         matlab.ui.control.Image
        tool_OpenPopupFilter            matlab.ui.control.Image
        tool_Separator2                 matlab.ui.control.Image
        tool_WordCloudVisibility        matlab.ui.control.Image
        tool_OpenPopupAnnotation        matlab.ui.control.Hyperlink
        tool_Separator1                 matlab.ui.control.Image
        tool_PanelVisibility            matlab.ui.control.Image
        Tab2_Products                   matlab.ui.container.Tab
        Tab3_Config                     matlab.ui.container.Tab
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
        
        schDataTable
        schDataCategories
        releasedData
        cacheData
        cacheColumns
        annotationTable

        previousSuggestionIdx = 0
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
            % aos componentes app.searchEntryPoint (matlab.ui.control.EditField) e app.searchSuggestions
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

            % Quando altero o conteúdo de app.searchEntryPoint, sem alterar o seu foco, será executado
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
                            selection = app.UITable.Selection;
                            if ~isempty(selection)
                                app.UITable.Selection = [];
                                onTableSelectionChanged(app)
                            end

                            delete(app.wordCloudObj)

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.wordCloudPanel, app.General.search.wordCloud.algorithm);

                            if ~isempty(selection)
                                app.UITable.Selection = selection;
                                onTableSelectionChanged(app)
                            end
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
    
                    case 'mainApp.searchEntryPoint'
                        % HTMLEventData é uma estrutura com os campos "key" 
                        % (tecla pressionada) e "value" (valor atual do campo).
                        keydownPressed    = event.HTMLEventData.key;
                        currentInputValue = event.HTMLEventData.value;

                        % Força-se a atualização da propriedade "Value" porque, 
                        % apesar de na GUI já constar um valor novo, este ainda 
                        % não foi devidamente atualizado.
                        app.searchEntryPoint.Value = currentInputValue;    
                        switch keydownPressed
                            case {'Escape', 'Tab'}
                                if numel(currentInputValue) < app.General.search.minCharacters
                                    entryButtonInitialState(app)
                                end
    
                                if strcmp(keydownPressed, 'Tab') && app.searchEntryButton.Enable
                                    focus(app.searchEntryButton)
                                end
    
                                pause(.050)
                                set(app.searchSuggestions, Visible=0, Value={})
    
                            otherwise
                                if numel(currentInputValue) >= app.General.search.minCharacters
                                    switch keydownPressed
                                        case 'ArrowDown'
                                            if strcmp(app.General.search.mode, 'tokens')
                                                app.previousSuggestionIdx = 1;
    
                                                set(app.searchSuggestions, 'Visible', 1, 'Value', 1)
                                                scroll(app.searchSuggestions, "top")
                                                focus(app.searchSuggestions)
                                            end
    
                                        case 'ArrowUp'
                                            if strcmp(app.General.search.mode, 'tokens')
                                                nMaxValues = numel(app.searchSuggestions.Items);
    
                                                app.previousSuggestionIdx = nMaxValues;
                                                set(app.searchSuggestions, 'Visible', 1, 'Value', nMaxValues)
                                                scroll(app.searchSuggestions, "bottom")
                                                focus(app.searchSuggestions)
                                            end
    
                                        case 'Enter'
                                            drawnow
                                            onEntryButtonPushed(app)                                        
                                            set(app.searchSuggestions, Visible=0, Value={})
                                    end
                                end
                        end
    
                    case 'mainApp.searchSuggestions'
                        % HTMLEventData é uma string com a indicação da tecla
                        % pressionada.
                        switch event.HTMLEventData
                            case 'ArrowDown'
                                nMaxValues = numel(app.searchSuggestions.Items);
    
                                if (app.previousSuggestionIdx == nMaxValues) && (app.searchSuggestions.Value == nMaxValues)
                                    app.previousSuggestionIdx = 0;
    
                                    set(app.searchSuggestions, Visible=0, Value={})
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.searchEntryPoint.UserData.id));
                                else
                                    if isnumeric(app.searchSuggestions.Value)
                                        app.previousSuggestionIdx = app.searchSuggestions.Value;
                                    else
                                        app.previousSuggestionIdx = 0;
                                    end
                                end
    
                            case 'ArrowUp'
                                if (app.previousSuggestionIdx == 1) && (app.searchSuggestions.Value == 1)
                                    app.previousSuggestionIdx = 0;
    
                                    set(app.searchSuggestions, Visible=0, Value={})
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.searchEntryPoint.UserData.id));
                                else
                                    if isnumeric(app.searchSuggestions.Value)
                                        app.previousSuggestionIdx = app.searchSuggestions.Value;
                                    else
                                        app.previousSuggestionIdx = 0;
                                    end
                                end
    
                            case {'Enter', 'Tab'}
                                if isnumeric(app.searchSuggestions.Value)
                                    eventValue = app.searchSuggestions.Items{app.searchSuggestions.Value};
    
                                    app.searchEntryPoint.Value = eventValue;
                                    sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('dataTag', app.searchEntryPoint.UserData.id));
                                    app.searchSuggestions.Visible = "off";
                                    drawnow

                                    onEntryPointChanging(app, struct('Value', eventValue, 'ListBoxVisibility', false))
                                end
    
                            case 'Escape'
                                set(app.searchSuggestions, Visible=0, Value={})
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
                                            'Quantidade de produtos sob análise: <b>%d</b><br><br>' ...
                                            'Deseja continuar o trabalho com esses dados ou iniciar uma nova sessão?' ...
                                        ], prjData.timestamp, prjData.name, numel(prjData.inspectedProducts));
        
                                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Usar dados salvos', 'Apagar e iniciar nova sessão'}, 1, 2);
                                        switch userSelection
                                            case 'Usar dados salvos'
                                                msg = Load(app.projectData, "indexedDB", prjData);
    
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
                        varargout{1} = {app};

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch operationType        
                                    case 'checkDataHubLampStatus'
                                        updateWarningLampVisibility(app)
        
                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))
        
                                    case 'onWordCloudAlgorithmChanged'
                                        if ~isempty(app.wordCloudObj)
                                            onAlgorithmValueChanged(app.wordCloudObj, app.General.search.wordCloud.algorithm);
                                        end
        
                                    case 'onSearchVisibleColumnsChanged'
                                        updateTableColumnNames(app)

                                    case 'updateDataHubGetFolder'
                                        app.progressDialog.Visible = 'visible';
                                        readDataBaseExternalFiles(app)
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
                                  'auxApp.dockReportLib',   'auxApp.dockReportLib_exported',   ...
                                  'auxApp.dockFilterSetup', 'auxApp.dockFilterSetup_exported', ...
                                  'auxApp.dockAnnotation',  'auxApp.dockAnnotation_exported'}
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

                                    % auxApp.dockAnnotation
                                    case 'onProductAnnotationAdded'
                                        focusedHomologation = varargin{1};
                                        attributeName = varargin{2};
                                        attributeValue = varargin{3};

                                        annotationAddToCache(app, focusedHomologation, attributeName, attributeValue)                                        

                                    % auxApp.dockFilterSetup
                                    case 'onSearchModeChanged'
                                        searchComponentsInitialState(app)

                                    case 'onColumnFilterChanged'
                                        applyFiltering(app)
        
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
                auxAppName char {mustBeMember(auxAppName, {'ReportLib', 'FilterSetup', 'Annotation', 'ProductInfo'})}
            end

            arguments (Repeating)
                varargin 
            end

            switch auxAppName
                case 'ReportLib'
                    screenWidth  = 460;
                    screenHeight = 602;
                case 'FilterSetup'
                    screenWidth  = 518;
                    screenHeight = 486;
                case 'Annotation'
                    screenWidth  = 412;
                    screenHeight = 300;
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
                        app.searchEntryPoint;
                        app.selectedProductPanelInfo;                             % ui.TextView
                        app.selectedProductPanelBackground;                        % ui.TextView (Background image)
                        app.searchSuggestions;
                        app.PopupTempWarning;
                        app.wordCloudPanel;
                        app.Tab1Button;
                        app.Tab2Button;
                        app.Tab3Button;
                        app.searchEntryPointGrid
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', elToModify{1}.UserData.id,  'generation', 1, 'style',          struct('border', '0')), ...
                            struct('appName', appName, 'dataTag', elToModify{10}.UserData.id, 'generation', 0, 'styleImportant', struct('border', '1px solid #7d7d7d', 'borderRadius', '0')), ...
                            struct('appName', appName, 'dataTag', elToModify{1}.UserData.id,  'generation', 2, 'listener',       struct('componentName', 'mainApp.searchEntryPoint', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
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
                            struct('appName', appName, 'dataTag', elToModify{4}.UserData.id, 'generation', 1, 'listener', struct('componentName', 'mainApp.searchSuggestions', 'keyEvents', {{'ArrowUp', 'ArrowDown', 'Enter', 'Escape', 'Tab'}})) ...
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
            app.projectData = model.Project(app, app.rootFolder);
            app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.wordCloudPanel, app.General.search.wordCloud.algorithm);
            
            if ~strcmp(app.executionMode, 'desktopStandaloneApp') && app.General.Report.indexedDBCache.status
                appEngine.indexedDB.openDB(app.jsBackDoor, class.Constants.appName)
            end

            readDataBaseExternalFiles(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog);
            addComponent(app.tabGroupController, "Built-in", "",                   app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winProducts", app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",   app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            app.tabGroupController.inlineSVG = true;

            % Atualiza relação de colunas visíveis.
            updateTableColumnNames(app)

            % Salva na propriedade "UserData" as opções de ícone e o índice
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.tool_WordCloudVisibility.UserData = false;

            % Inicialização da propriedade "UserData" da tabela.
            app.UITable.UserData = struct('matchRowIdxs', []);
            app.UITable.RowName  = 'numbered';

            % Os painéis de metadados do registro selecionado nas tabelas já 
            % tem, na sua propriedade "UserData", a chave "id" que armazena 
            % o "data-tag" que identifica o componente no código HTML. 
            % Adicionam-se duas novas chaves: "showedRow" e "showedHom".
            app.selectedProductPanelInfo.UserData.focusedHomologation = '';

            % Armazena informação do valor textual buscado, no modo "FreeText" 
            % ou "FreeText+ColumnFilter".
            app.searchEntryButton.UserData = struct('valueToSearch', '', 'wordsToSearch', {{}});
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateWarningLampVisibility(app)

            searchComponentsInitialState(app)
            updateResultsContext(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % BASES DE DADOS: SCHDATA E ANNOTATIONTABLE
        %-----------------------------------------------------------------%
        function readDataBaseExternalFiles(app)
            [app.schDataTable, ...
             app.schDataCategories, ...
             app.releasedData, ...
             app.cacheData,    ...
             app.cacheColumns]  = util.readExternalFile.SCHData(app.rootFolder, app.General.fileFolder.DataHub_GET, app.General);
            app.annotationTable = util.readExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_GET);
        end

        %-----------------------------------------------------------------%
        % ANOTAÇÃO
        %-----------------------------------------------------------------%
        function relatedAnnotationTable = annotationRelatedTable(app, focusedHomologation)
            annotationLogical      = strcmp(app.annotationTable.("Homologação"), focusedHomologation);
            relatedAnnotationTable = app.annotationTable(annotationLogical, :);
        end

        %-----------------------------------------------------------------%
        function annotationAddToCache(app, focusedHomologation, attributeName, attributeValue)
            newRowTable = table( ...
                {char(matlab.lang.internal.uuid())}, ...
                {datestr(now, 'dd/mm/yyyy HH:MM:SS')}, ...
                {appEngine.util.OperationSystem('computerName')}, ...
                {appEngine.util.OperationSystem('userName')}, ...
                {focusedHomologation}, ...
                {attributeName}, ...
                {attributeValue}, ...
                1, ...
                'VariableNames', util.readExternalFile.annotationColumns ...
            );

            annotationHomIndexes = find(strcmp(app.annotationTable.("Homologação"), focusedHomologation));
            if ~isempty(annotationHomIndexes) && any(strcmp(app.annotationTable.("Atributo")(annotationHomIndexes), attributeName) & strcmpi(app.annotationTable.("Valor")(annotationHomIndexes), attributeValue))
                ui.Dialog(app.UIFigure, 'uiconfirm', sprintf('Conjunto atributo/valor já consta como anotação do registro %s.', focusedHomologation), {'OK'}, 1, 1, 'Icon', 'warning');
                return
            else
                app.annotationTable(end+1,:) = newRowTable;
            end

            % A cada nova inserção, gera-se uma planilha que é submetida à
            % pasta POST, ou é salva localmente em cache.
            [app.annotationTable, msgWarning] = util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            if ~isempty(msgWarning)
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
            end

            % Atualizando o painel com os metadados do registro selecionado...
            app.selectedProductPanelInfo.UserData.focusedHomologation = '';
            onTableSelectionChanged(app)
            updateTableStyle(app)
        end

        %-----------------------------------------------------------------%
        % FILTRAGEM
        %-----------------------------------------------------------------%
        function searchComponentsInitialState(app)
            switch app.General.search.type
                case {'FreeText', 'FreeText+ColumnFilter'}
                    enable = true;
                    value = app.searchEntryButton.UserData.valueToSearch;
                    placeholder = 'O que você quer pesquisar?';
                otherwise
                    enable = false;
                    value = '';
                    placeholder = 'Busca por texto indisponível neste modo';
            end

            set(app.searchEntryPoint, 'Enable', enable, 'Value', value, 'Placeholder', placeholder, 'FontColor', [0,0,0])
            app.searchSuggestions.Visible = 0;
            app.previousSuggestionIdx = 0;

            onEntryPointChanging(app, struct('Value', value, 'ListBoxVisibility', false))
            onEntryButtonPushed(app)           
        end

        %-----------------------------------------------------------------%
        function entryButtonInitialState(app)
            app.searchEntryButton.Enable = 0;
        end

        %-----------------------------------------------------------------%
        function searchSuggestionsInitialState(app)
            set(app.searchSuggestions, Visible=0, Items={}, ItemsData=[])
        end
        
        %-----------------------------------------------------------------%
        function applyFiltering(app)
            app.progressDialog.Visible = 'visible';

            hasWordsToSearch = ~isempty(app.searchEntryButton.UserData.wordsToSearch);
            hasColumnFilters = any(app.filteringObj.filterRules.Enable);

            matchRowIdxs = [];
            switch app.General.search.type
                case 'FreeText'
                    if hasWordsToSearch
                        matchRowIdxs = applyTextFilter(app);
                    end

                case 'ColumnFilter'
                    if hasColumnFilters
                        matchRowIdxs = (1:height(app.schDataTable))';
                        matchRowIdxs = applyColumnFilter(app, matchRowIdxs);
                    end
        
                case 'FreeText+ColumnFilter'
                    if hasWordsToSearch
                        matchRowIdxs = applyTextFilter(app);
                    end

                    if hasColumnFilters
                        if isempty(matchRowIdxs)
                            matchRowIdxs = (1:height(app.schDataTable))';
                        end
                        matchRowIdxs = applyColumnFilter(app, matchRowIdxs);
                    end
            end
            updateTable(app, matchRowIdxs)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function matchRowIdxs = applyTextFilter(app)
            switch app.General.search.mode
                case 'tokens'
                    sortOrder = 'stable';
                otherwise % 'words'
                    sortOrder = 'unstable';
            end

            cacheColumnNames = strcat({'_'}, strsplit(app.cacheColumns, ' | '));
            searchFunction   = app.General.search.function;
            wordsToSearch    = app.searchEntryButton.UserData.wordsToSearch;
            
            matchRowTempIdxs = run(app.filteringObj, 'wordsToSearch', app.schDataTable, cacheColumnNames, sortOrder, searchFunction, wordsToSearch);
            matchHomList     = unique(app.schDataTable(matchRowTempIdxs,:).("Homologação"), 'stable');
            matchRowIdxs     = run(app.filteringObj, 'wordsToSearch', app.schDataTable, {'Homologação'}, sortOrder, 'strcmp', matchHomList);
        end

        %-----------------------------------------------------------------%
        function matchRowIdxs = applyColumnFilter(app, matchRowIdxs)
            matchRowTempIdxs = run(app.filteringObj, 'filterRules', app.schDataTable(matchRowIdxs, :));
            matchRowIdxs = matchRowIdxs(matchRowTempIdxs);
        end

        %-----------------------------------------------------------------%
        function updateTable(app, matchRowIdxs)
            app.UITable.Data = app.schDataTable(matchRowIdxs, UITableColumnNames(app));
            app.UITable.UserData.matchRowIdxs = matchRowIdxs;

            UITableInitialSelection(app, true)

            updateTableStyle(app)
            updateResultsContext(app)
            updateTableNumRows(app)
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            removeStyle(app.UITable)

            % Row striping (by homologation group)
            [homValues, homFirstRowIdx, homGroupIdx] = unique(app.UITable.Data.("Homologação"), 'stable');            
            evenGroupRows = find(mod(homGroupIdx, 2) == 0);

            if ~isempty(evenGroupRows)
                s = app.rowStripingStyle;
                addStyle(app.UITable, s, 'row', evenGroupRows)
            end

            % Annotation indicator
            annotatedHomMask = ismember(homValues, unique(app.annotationTable.("Homologação")));
            annotatedRowIdx  = homFirstRowIdx(annotatedHomMask);            
            annotationCells  = [annotatedRowIdx, ones(numel(annotatedRowIdx), 1)];

            if ~isempty(annotationCells)
                s = app.annotationStyle;
                addStyle(app.UITable, s, "cell", annotationCells)
            end
        end

        %-----------------------------------------------------------------%
        function updateResultsContext(app)
            searchSpecInfo   = '';
            resultsContext   = '';
            columnFilterList = {};

            if ismember(app.General.search.type, {'FreeText', 'FreeText+ColumnFilter'})
                valueToSearch = app.searchEntryButton.UserData.valueToSearch;
                wordsToSearch = app.searchEntryButton.UserData.wordsToSearch;

                switch app.General.search.mode
                    case 'tokens'
                        searchSpecInfo = '[TS]';

                        if ~isempty(wordsToSearch)
                            resultsContext = sprintf('Resultados para "<b>%s</b>"', valueToSearch);
                        end

                    otherwise % 'words'
                        searchSpecInfo = '[TE]';

                        if ~isempty(wordsToSearch)
                            resultsContext = sprintf('Resultados para %s', strjoin("""<b>" + string(wordsToSearch) + "</b>""", ', '));
                        end
                end

                if isempty(resultsContext)
                    resultsContext = 'Nenhuma palavra';
                end
            end

            if ismember(app.General.search.type, {'ColumnFilter', 'FreeText+ColumnFilter'})
                if ~isempty(searchSpecInfo)
                    searchSpecInfo = [searchSpecInfo ' '];
                end
                searchSpecInfo = [searchSpecInfo '[FC]'];

                if ~isempty(resultsContext)
                    resultsContext = [resultsContext ' + '];
                end

                columnFilterList = getFilterList(app.filteringObj, 'SCH', 'on');
                numColumnFilter  = numel(columnFilterList);

                switch numColumnFilter
                    case 0
                        resultsContext = [resultsContext 'Nenhum filtro por coluna ativo'];
                    case 1
                        resultsContext = [resultsContext 'Um filtro por coluna ativo'];
                    otherwise
                        resultsContext = [resultsContext sprintf('%s filtros por coluna ativo', numColumnFilter)];
                end
            end

            set(app.filterSpecification, 'Text', sprintf('%s\n%s', searchSpecInfo, resultsContext), 'Tooltip', strjoin(columnFilterList, '\n'))
        end

        %-----------------------------------------------------------------%
        function updateTableColumnNames(app)
            [columnNames, columnWidth] = UITableColumnNames(app);
            set(app.UITable, 'ColumnName', upper(columnNames), 'ColumnWidth', columnWidth)

            if ~isempty(app.UITable.Data)
                if (numel(columnNames) ~= width(app.UITable.Data)) || any(~ismember(app.UITable.ColumnName, upper(columnNames)))
                    matchRowIdxs = app.UITable.UserData.matchRowIdxs;
                    app.UITable.Data = app.schDataTable(matchRowIdxs, columnNames);
                end
            end
        end

        %-----------------------------------------------------------------%
        function updateTableNumRows(app)
            numHomValues = numel(unique(app.UITable.Data.("Homologação")));
            numTableRows = height(app.UITable.Data);
            app.UITable_NumRows.Text = sprintf('%d <font style="font-size: 10px;">HOMOLOGAÇÕES </font><br>%d <font style="font-size: 10px;">REGISTROS </font>', numHomValues, numTableRows);
        end

        %-----------------------------------------------------------------%
        function [columnNames, columnWidths] = UITableColumnNames(app)
            checkedNodes = UITableColumnInfo(app, 'visibleColumns');
            staticColums = UITableColumnInfo(app, 'staticColumns');
            columnNames  = unique([staticColums; checkedNodes], 'stable');

            allColumns   = UITableColumnInfo(app, 'allColumns');
            widthColumns = UITableColumnInfo(app, 'allColumnsWidths');

            columnWidths = {};
            for ii = 1:numel(columnNames)
                columnName       = columnNames{ii};
                columnIndex      = find(strcmp(allColumns, columnName), 1);

                columnWidths{ii} = widthColumns{columnIndex};
            end
        end

        %-----------------------------------------------------------------%
        function columnInfo = UITableColumnInfo(app, type)
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
        function UITableInitialSelection(app, focusFlag)
            if isempty(app.UITable.Data)
                app.UITable.Selection = [];
            else
                app.UITable.Selection = [1, 1];
            end
            onTableSelectionChanged(app)

            if focusFlag
                focus(app.UITable)
            end
        end

        %-----------------------------------------------------------------%
        function [selectedHomologations, focusedHomologation, selectedTableRows] = checkTableSelection(app)
            if ~isempty(app.UITable.Selection)
                selectedTableRows     = unique(app.UITable.Selection(:,1));
                selectedHomologations = unique(app.UITable.Data.("Homologação")(selectedTableRows), 'stable');
            else
                selectedTableRows     = [];
                selectedHomologations = {};
            end

            focusedHomologation = app.selectedProductPanelInfo.UserData.focusedHomologation;
        end

        %-----------------------------------------------------------------%
        % PAINEL TEXTUAL À DIREITA
        %-----------------------------------------------------------------%
        function htmlSource = selectedProductPanelInfoCreate(app, selected2focusedHom, relatedAnnotationTable)
            if isempty(selected2focusedHom)
                htmlSource = '';
            else
                selectedHomRawTableIndex = find(strcmp(app.schDataTable.("Homologação"), selected2focusedHom));
                htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoHomologado', app.schDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable, app.projectData.regulatronData);
            end
        end

        %-----------------------------------------------------------------%
        function selectedProductPanelInfoUpdate(app, htmlSource, selected2focusedHomologation)
            userData = struct('focusedHomologation', selected2focusedHomologation);
            ui.TextView.update(app.selectedProductPanelInfo, htmlSource, userData, app.selectedProductPanelBackground);
        end

        %-----------------------------------------------------------------%
        % WORDCLOUD
        %-----------------------------------------------------------------%
        function wordCloudInitialize(app)
            if ~isempty(app.wordCloudObj) && ~isempty(app.wordCloudPanel.Tag)
                app.wordCloudObj.Table        = [];
                app.wordCloudPanel.Tag = '';
            end
        end

        %-----------------------------------------------------------------%
        function status = wordCloudCheckCache(app, selectedHom, relatedAnnotationTable)
            status = false;

            wordCloudMask = strcmp(relatedAnnotationTable.("Atributo"), 'WordCloud');
            relatedAnnotationTable = relatedAnnotationTable(wordCloudMask, :);

            if isempty(relatedAnnotationTable) || any(wordCloudMask) && ~strcmp(app.wordCloudPanel.Tag, selectedHom)
                status = true;
            end
        end

        %-----------------------------------------------------------------%
        function status = wordCloudUpdatePlot(app, showedHom)
            status = true;

            % O wordcloud, do MATLAB, é lento, demandando uma tela de progresso
            % que bloqueia a interação com o app.
            if strcmp(app.General.search.wordCloud.algorithm, 'MATLAB built-in')
                app.progressDialog.Visible = 'visible';
            end

            relatedAnnotationTable = annotationRelatedTable(app, showedHom);
            wordCloudIndex = find(strcmp(relatedAnnotationTable.("Atributo"), 'WordCloud'), 1);

            if ~isempty(wordCloudIndex)
                wordCloudAnnotation = relatedAnnotationTable.("Valor"){wordCloudIndex};
                wordCloudTable      = util.getWordCloudFromCache(wordCloudAnnotation);

            else
                app.progressDialog.Visible = 'visible';
                try
                    word2Search = wordCloudGetSearchWord(app, showedHom);
                    nMaxWords   = 25;

                    [wordCloudTable, wordCloudInfo] = util.getWordCloudFromWeb(word2Search, nMaxWords);
                    if ~isempty(wordCloudTable)
                        annotationAddToCache(app, showedHom, 'WordCloud', wordCloudInfo)
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
                app.wordCloudPanel.Tag = showedHom;
            end

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function word2Search = wordCloudGetSearchWord(app, showedHom)
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
        % MISCELÂNEAS
        %-----------------------------------------------------------------%
        function updateWarningLampVisibility(app)
            app.DataHubLamp.Visible = ~isfolder(app.General.fileFolder.DataHub_GET) || ~isfolder(app.General.fileFolder.DataHub_POST);
        end

        %-----------------------------------------------------------------%
        function showPopupTempWarning(app, msg)
            app.tool_AddSelectedToBucket.Enable = "off";
            set(app.PopupTempWarning, 'Text', msg, 'Visible', 'on')
            sendEventToHTMLSource(app.jsBackDoor, 'setBackgroundTransparent', struct('componentName', 'PopupTempWarning', 'componentDataTag', app.PopupTempWarning.UserData.id, 'interval_ms', 75));
            drawnow
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            nonEmptyTable = ~isempty(app.UITable.Data);
            nonEmptySelection = ~isempty(app.UITable.Selection);
            visibleSidePanel = app.selectedProductPanelGrid.Visible;

            app.tool_WordCloudVisibility.Enable = nonEmptyTable && visibleSidePanel;
            app.tool_OpenPopupAnnotation.Enable = nonEmptySelection;
            app.tool_ExportVisibleTable.Enable = nonEmptyTable;

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

            try
                IndexedDBCache(app.projectData, 'forceUpdate')
                util.writeExternalFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            catch
            end

            msgQuestion = '';
            if CheckIfUpdateNeeded(app.projectData)
                msgQuestion = sprintf([ ...
                    'O projeto "%s" foi modificado (nome, arquivo de saída ou ' ...
                    'lista de produtos sob análise). Caso o aplicativo seja encerrado ' ...
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
                case app.searchEntryPoint
                    if ~isempty(app.searchEntryPoint.Value)
                        if strcmp(app.General.search.mode, 'tokens')
                            if numel(app.searchEntryPoint.Value) >= app.General.search.minCharacters
                                app.searchSuggestions.Visible = 1;
                            end
                        end
                    end

                case app.searchSuggestions
                    if isempty(app.searchSuggestions.Value)
                        matlab.waitfor(app.searchSuggestions, 'Value', @(propValue) ~isempty(propValue), .075, 1, 'propValue')
                    end

                    ipcMainJSEventsHandler(app, struct('HTMLEventName', 'mainApp.searchSuggestions', 'HTMLEventData', 'Enter'))

                otherwise
                    set(app.searchSuggestions, Visible=0, Value={})
                    if isempty(app.searchEntryPoint.Value)
                        entryButtonInitialState(app)
                    end
            end

        end

        % Callback function: AppInfo, FigurePosition, Tab1Button, 
        % ...and 2 other components
        function onTabNavigatorButtonPushed(app, event)

            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button}
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, app)

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
                        app.schDataTable, ...
                        app.releasedData, ...
                        app.cacheData, ...
                        app.annotationTable, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end

        end

        % Value changing function: searchEntryPoint
        function onEntryPointChanging(app, event)

            valueToSearch = textAnalysis.preProcessedData(event.Value, false);

            if numel(valueToSearch) < app.General.search.minCharacters
                app.searchEntryButton.Enable = 0;
                searchSuggestionsInitialState(app)

            else
                app.searchEntryButton.Enable = 1;

                if strcmp(app.General.search.mode, 'tokens')
                    [similarStrings, idxFiltered, redFontFlag] = util.getSimilarStrings(app.cacheData, valueToSearch, app.General.search.minDisplayedTokens);
                    
                    set(app.searchSuggestions, ...
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
                    app.searchEntryPoint.FontColor = fontColor;
                end
            end
            
        end

        % Image clicked function: searchEntryButton
        function onEntryButtonPushed(app, event)
            
            valueToSearch = textAnalysis.preProcessedData(app.searchEntryPoint.Value, false);

            switch app.General.search.mode
                case 'tokens'
                    if isempty(app.searchSuggestions.Items)
                        onEntryPointChanging(app, struct('Value', app.searchEntryPoint.Value, 'ListBoxVisibility', false))
                    end
                    wordsToSearch = app.searchSuggestions.Items;

                otherwise % 'words'
                    wordsToSearch = textAnalysis.preProcessedData(strsplit(app.searchEntryPoint.Value, ','));
            end

            newSearchEntry = struct('valueToSearch', valueToSearch, 'wordsToSearch', {wordsToSearch});
            if isequal(app.searchEntryButton.UserData, newSearchEntry)
                return
            end
            app.searchEntryButton.UserData = newSearchEntry;

            applyFiltering(app)

        end

        % Selection changed function: UITable
        function onTableSelectionChanged(app, event)
            
            [selectedHomologations, focusedHomologation] = checkTableSelection(app);

            if ~isempty(selectedHomologations)
                if ~ismember(focusedHomologation, selectedHomologations)
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2focusedHom    = selectedHomologations{1};
                    relatedAnnotationTable = annotationRelatedTable(app, selected2focusedHom);

                    htmlSource = selectedProductPanelInfoCreate(app, selected2focusedHom, relatedAnnotationTable);
                    selectedProductPanelInfoUpdate(app, htmlSource, selected2focusedHom)

                    % Apresenta a nuvem de palavras apenas se visível...
                    if app.tool_WordCloudVisibility.UserData
                        if wordCloudCheckCache(app, selected2focusedHom, relatedAnnotationTable)
                            if ~wordCloudUpdatePlot(app, selected2focusedHom)
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
                htmlSource = selectedProductPanelInfoCreate(app, '', []);
                selectedProductPanelInfoUpdate(app, htmlSource, '')
                wordCloudInitialize(app)
            end

            updateToolbar(app)

        end

        % Image clicked function: tool_PanelVisibility
        function Toolbar_PanelVisibilityImageClicked(app, event)
            
            if app.selectedProductPanelGrid.Visible
                app.tool_PanelVisibility.ImageSource = 'layout-sidebar-right-off.svg';
                app.selectedProductPanelGrid.Visible = 0;
                app.UITable.Layout.Column = [1 6];

                if app.tool_WordCloudVisibility.UserData
                    wordCloudInitialize(app)
                    Toolbar_WordCloudVisibilityImageClicked(app)
                end
    
            else
                app.tool_PanelVisibility.ImageSource = 'layout-sidebar-right.svg';
                app.selectedProductPanelGrid.Visible = 1;
                app.UITable.Layout.Column = [1 4];
            end

            updateToolbar(app)

        end

        % Image clicked function: tool_WordCloudVisibility
        function Toolbar_WordCloudVisibilityImageClicked(app, event)
            
            app.tool_WordCloudVisibility.UserData = ~app.tool_WordCloudVisibility.UserData;
    
            if app.tool_WordCloudVisibility.UserData
                app.selectedProductPanelGrid.RowHeight{2} = 150;
                 % drawnow
                pause(0.010)

                % Esse drawnow abaixo (ou um pause mínimo) é ESSENCIAL, 
                % resolvendo BUG intermitente do MATLAB que se manifesta
                % quando:
                % (1) Abre-se painel do produto antes de qualquer pesquisa;
                % (2) Pesquisa-se algo, o que tornará o botão do wordcloud
                %     ativo;
                % (3) Clica-se nesse botão, o que mostrará o wordcloud.
                % (4) Fecha-se o painel do produto, o que tornará o botão
                %     wordcloud inativo, mudando-se a seleção em tabela.
                % (5) Abre-se painel de produto, clica-se no botão. Aqui
                %     o MATLAB congela, intermitentemente, a não ser que 
                %     exista o drawnow.
                
                app.tool_WordCloudVisibility.ImageSource = 'cloud-on.svg';

                focusedHomologation = app.selectedProductPanelInfo.UserData.focusedHomologation;
                if ~isempty(focusedHomologation)
                    relatedAnnotationTable = annotationRelatedTable(app, focusedHomologation);
        
                    if wordCloudCheckCache(app, focusedHomologation, relatedAnnotationTable)
                        wordCloudUpdatePlot(app, focusedHomologation);
                    end
                end
    
            else
                app.selectedProductPanelGrid.RowHeight{2} = 0;
                app.tool_WordCloudVisibility.ImageSource = 'cloud-off.svg';
            end

        end

        % Callback function: tool_OpenPopupAnnotation, tool_OpenPopupFilter
        function Toolbar_OpenPopupAppImageClicked(app, event)
            
            switch event.Source
                case app.tool_OpenPopupFilter
                    ipcMainMatlabOpenPopupApp(app, app, 'FilterSetup')

                case app.tool_OpenPopupAnnotation
                    selectedHomologation = app.selectedProductPanelInfo.UserData.focusedHomologation;
                    ipcMainMatlabOpenPopupApp(app, app, 'Annotation', selectedHomologation)
            end

        end

        % Image clicked function: tool_ExportVisibleTable
        function Toolbar_ExportVisibleTableImageClicked(app, event)
            
            nameFormatMap = {'*.xlsx', 'Excel'};
            defaultName   = appEngine.util.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1);
            fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                matchRowIdxs = app.UITable.UserData.matchRowIdxs;
                columnNames  = app.schDataTable.Properties.VariableNames(~startsWith(app.schDataTable.Properties.VariableNames, '_'));
                writetable(app.schDataTable(matchRowIdxs, columnNames), fileFullPath, 'WriteMode', 'overwritesheet')
                
            catch ME
                ui.Dialog(app.UIFigure, 'warning', getReport(ME));
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_AddSelectedToBucket
        function Toolbar_AddSelectedToBucketImageClicked(app, event)
            
            [~, ~, selectedTableRows] = checkTableSelection(app);
            if isempty(selectedTableRows)
                return
            end

            addedHom = 0;
            for selectedRow = selectedTableRows'
                [productData, productHash] = model.ProjectBase.initializeInspectedProduct('Homologado', app.General, app.schDataTable, app.UITable.UserData.matchRowIdxs(selectedRow));
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
                showPopupTempWarning(app, model.ProjectBase.WARNING_ENTRYEXIST.SEARCH)
            end

        end

        % Image clicked function: filterSpecificationIcon
        function filterSpecificationIconImageClicked(app, event)
            
            msg = [ ...
                'Estratégia de filtragem:<br>' ...
                '•&thinsp;[TS] Texto por Similaridade: apresenta sugestões conforme o texto é digitado e retorna resultados com base nos termos sugeridos.<br>' ...
                '•&thinsp;[TE] Texto Exato: busca um ou mais termos, separados por vírgulas, sem apresentação de sugestões.<br>' ...
                '•&thinsp;[FC] Filtro por Coluna: aplica filtros diretos sobre campos específicos.<br><br>' ...
                'A filtragem pode usar apenas texto, apenas filtros por coluna ou ambos em conjunto.' ...
            ];
            ui.Dialog(app.UIFigure, 'info', msg);

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

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1_Search);
            app.Tab1Grid.ColumnWidth = {10, '1x', 412, '1x', 10};
            app.Tab1Grid.RowHeight = {7, 27, 342, '1x', 34, 10, 34};
            app.Tab1Grid.ColumnSpacing = 0;
            app.Tab1Grid.RowSpacing = 0;
            app.Tab1Grid.Padding = [0 0 0 40];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Tab1Grid);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 5, 22, 22, 5, 22, '1x'};
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

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.Toolbar);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 4];
            app.tool_Separator1.Layout.Column = 2;
            app.tool_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_OpenPopupAnnotation
            app.tool_OpenPopupAnnotation = uihyperlink(app.Toolbar);
            app.tool_OpenPopupAnnotation.HyperlinkClickedFcn = createCallbackFcn(app, @Toolbar_OpenPopupAppImageClicked, true);
            app.tool_OpenPopupAnnotation.VisitedColor = [0 0 0];
            app.tool_OpenPopupAnnotation.FontSize = 14;
            app.tool_OpenPopupAnnotation.FontColor = [0 0 0];
            app.tool_OpenPopupAnnotation.Tooltip = {'Adiciona ao registro selecionado uma anotação textual'; '(fabricante, modelo etc)'};
            app.tool_OpenPopupAnnotation.Layout.Row = [1 4];
            app.tool_OpenPopupAnnotation.Layout.Column = 3;
            app.tool_OpenPopupAnnotation.Text = '✍️';

            % Create tool_WordCloudVisibility
            app.tool_WordCloudVisibility = uiimage(app.Toolbar);
            app.tool_WordCloudVisibility.ScaleMethod = 'scaleup';
            app.tool_WordCloudVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_WordCloudVisibilityImageClicked, true);
            app.tool_WordCloudVisibility.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.tool_WordCloudVisibility.Layout.Row = [1 4];
            app.tool_WordCloudVisibility.Layout.Column = 4;
            app.tool_WordCloudVisibility.ImageSource = 'cloud-off.svg';

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 4];
            app.tool_Separator2.Layout.Column = 5;
            app.tool_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_OpenPopupFilter
            app.tool_OpenPopupFilter = uiimage(app.Toolbar);
            app.tool_OpenPopupFilter.ScaleMethod = 'none';
            app.tool_OpenPopupFilter.ImageClickedFcn = createCallbackFcn(app, @Toolbar_OpenPopupAppImageClicked, true);
            app.tool_OpenPopupFilter.Tooltip = {'Configura estratégia de filtragem'};
            app.tool_OpenPopupFilter.Layout.Row = [1 4];
            app.tool_OpenPopupFilter.Layout.Column = 6;
            app.tool_OpenPopupFilter.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'filter-18px.png');

            % Create tool_ExportVisibleTable
            app.tool_ExportVisibleTable = uiimage(app.Toolbar);
            app.tool_ExportVisibleTable.ScaleMethod = 'none';
            app.tool_ExportVisibleTable.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ExportVisibleTableImageClicked, true);
            app.tool_ExportVisibleTable.Enable = 'off';
            app.tool_ExportVisibleTable.Tooltip = {'Exporta resultados de busca em arquivo Excel (.xlsx)'};
            app.tool_ExportVisibleTable.Layout.Row = [1 4];
            app.tool_ExportVisibleTable.Layout.Column = 7;
            app.tool_ExportVisibleTable.ImageSource = 'Export_16.png';

            % Create tool_Separator3
            app.tool_Separator3 = uiimage(app.Toolbar);
            app.tool_Separator3.ScaleMethod = 'none';
            app.tool_Separator3.Enable = 'off';
            app.tool_Separator3.Layout.Row = [1 4];
            app.tool_Separator3.Layout.Column = 8;
            app.tool_Separator3.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_AddSelectedToBucket
            app.tool_AddSelectedToBucket = uiimage(app.Toolbar);
            app.tool_AddSelectedToBucket.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AddSelectedToBucketImageClicked, true);
            app.tool_AddSelectedToBucket.Enable = 'off';
            app.tool_AddSelectedToBucket.Tooltip = {'Adiciona registros selecionados à lista de produtos sob análise'};
            app.tool_AddSelectedToBucket.Layout.Row = [1 4];
            app.tool_AddSelectedToBucket.Layout.Column = 9;
            app.tool_AddSelectedToBucket.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Picture1.png');

            % Create Document
            app.Document = uigridlayout(app.Tab1Grid);
            app.Document.ColumnWidth = {22, 4, '1x', 26, 10, 320};
            app.Document.RowHeight = {27, '1x', 1};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 3;
            app.Document.Padding = [0 0 0 9];
            app.Document.Layout.Row = [2 5];
            app.Document.Layout.Column = [2 4];
            app.Document.BackgroundColor = [1 1 1];

            % Create filterSpecificationIcon
            app.filterSpecificationIcon = uiimage(app.Document);
            app.filterSpecificationIcon.ScaleMethod = 'stretch';
            app.filterSpecificationIcon.ImageClickedFcn = createCallbackFcn(app, @filterSpecificationIconImageClicked, true);
            app.filterSpecificationIcon.Tooltip = {''};
            app.filterSpecificationIcon.Layout.Row = 1;
            app.filterSpecificationIcon.Layout.Column = 1;
            app.filterSpecificationIcon.VerticalAlignment = 'top';
            app.filterSpecificationIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'info-16px-gray.svg');

            % Create filterSpecification
            app.filterSpecification = uilabel(app.Document);
            app.filterSpecification.VerticalAlignment = 'bottom';
            app.filterSpecification.FontSize = 10;
            app.filterSpecification.FontColor = [0.502 0.502 0.502];
            app.filterSpecification.Layout.Row = 1;
            app.filterSpecification.Layout.Column = 3;
            app.filterSpecification.Interpreter = 'html';
            app.filterSpecification.Text = {'[TS] [FC]'; 'Nenhuma palavra + Nenhum filtro por coluna ativo'};

            % Create UITable_NumRows
            app.UITable_NumRows = uilabel(app.Document);
            app.UITable_NumRows.HorizontalAlignment = 'right';
            app.UITable_NumRows.VerticalAlignment = 'bottom';
            app.UITable_NumRows.FontSize = 11;
            app.UITable_NumRows.FontColor = [0.502 0.502 0.502];
            app.UITable_NumRows.Layout.Row = 1;
            app.UITable_NumRows.Layout.Column = [3 6];
            app.UITable_NumRows.Interpreter = 'html';
            app.UITable_NumRows.Text = {'0 <font style="font-size: 10px; margin-right: 2px;">HOMOLOGAÇÕES</font>'; '0 <font style="font-size: 10px;">REGISTROS </font>'};

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.UITable.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.UITable.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.UITable.RowName = {};
            app.UITable.RowStriping = 'off';
            app.UITable.ClickedFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Layout.Row = [2 3];
            app.UITable.Layout.Column = [1 4];
            app.UITable.FontSize = 10;

            % Create selectedProductPanelGrid
            app.selectedProductPanelGrid = uigridlayout(app.Document);
            app.selectedProductPanelGrid.ColumnWidth = {'1x', 18};
            app.selectedProductPanelGrid.RowHeight = {'1x', 0};
            app.selectedProductPanelGrid.ColumnSpacing = 5;
            app.selectedProductPanelGrid.RowSpacing = 5;
            app.selectedProductPanelGrid.Padding = [0 0 0 0];
            app.selectedProductPanelGrid.Layout.Row = [2 3];
            app.selectedProductPanelGrid.Layout.Column = 6;
            app.selectedProductPanelGrid.BackgroundColor = [1 1 1];

            % Create selectedProductPanelBackground
            app.selectedProductPanelBackground = uiimage(app.selectedProductPanelGrid);
            app.selectedProductPanelBackground.ScaleMethod = 'none';
            app.selectedProductPanelBackground.Layout.Row = 1;
            app.selectedProductPanelBackground.Layout.Column = [1 2];
            app.selectedProductPanelBackground.ImageSource = 'warning.svg';

            % Create selectedProductPanelInfo
            app.selectedProductPanelInfo = uilabel(app.selectedProductPanelGrid);
            app.selectedProductPanelInfo.VerticalAlignment = 'top';
            app.selectedProductPanelInfo.WordWrap = 'on';
            app.selectedProductPanelInfo.FontSize = 11;
            app.selectedProductPanelInfo.Layout.Row = 1;
            app.selectedProductPanelInfo.Layout.Column = [1 2];
            app.selectedProductPanelInfo.Interpreter = 'html';
            app.selectedProductPanelInfo.Text = '';

            % Create wordCloudPanel
            app.wordCloudPanel = uipanel(app.selectedProductPanelGrid);
            app.wordCloudPanel.AutoResizeChildren = 'off';
            app.wordCloudPanel.BackgroundColor = [1 1 1];
            app.wordCloudPanel.Layout.Row = 2;
            app.wordCloudPanel.Layout.Column = [1 2];

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.selectedProductPanelGrid);
            app.jsBackDoor.Layout.Row = 2;
            app.jsBackDoor.Layout.Column = [1 2];

            % Create PopupTempWarning
            app.PopupTempWarning = uilabel(app.Tab1Grid);
            app.PopupTempWarning.BackgroundColor = [0.2 0.2 0.2];
            app.PopupTempWarning.HorizontalAlignment = 'center';
            app.PopupTempWarning.WordWrap = 'on';
            app.PopupTempWarning.FontColor = [1 1 1];
            app.PopupTempWarning.Visible = 'off';
            app.PopupTempWarning.Layout.Row = 5;
            app.PopupTempWarning.Layout.Column = [2 4];
            app.PopupTempWarning.Text = '';

            % Create searchEntryPointGrid
            app.searchEntryPointGrid = uigridlayout(app.Tab1Grid);
            app.searchEntryPointGrid.ColumnWidth = {'1x', 28};
            app.searchEntryPointGrid.RowHeight = {'1x'};
            app.searchEntryPointGrid.ColumnSpacing = 0;
            app.searchEntryPointGrid.RowSpacing = 0;
            app.searchEntryPointGrid.Padding = [0 0 0 0];
            app.searchEntryPointGrid.Layout.Row = [1 2];
            app.searchEntryPointGrid.Layout.Column = 3;
            app.searchEntryPointGrid.BackgroundColor = [1 1 1];

            % Create searchEntryPoint
            app.searchEntryPoint = uieditfield(app.searchEntryPointGrid, 'text');
            app.searchEntryPoint.CharacterLimits = [0 128];
            app.searchEntryPoint.ValueChangingFcn = createCallbackFcn(app, @onEntryPointChanging, true);
            app.searchEntryPoint.Tag = 'PROMPT';
            app.searchEntryPoint.FontSize = 14;
            app.searchEntryPoint.Placeholder = 'O que você quer pesquisar?';
            app.searchEntryPoint.Layout.Row = 1;
            app.searchEntryPoint.Layout.Column = 1;

            % Create searchEntryButton
            app.searchEntryButton = uiimage(app.searchEntryPointGrid);
            app.searchEntryButton.ScaleMethod = 'scaledown';
            app.searchEntryButton.ImageClickedFcn = createCallbackFcn(app, @onEntryButtonPushed, true);
            app.searchEntryButton.Enable = 'off';
            app.searchEntryButton.Layout.Row = 1;
            app.searchEntryButton.Layout.Column = 2;
            app.searchEntryButton.ImageSource = 'Zoom_36x36.png';

            % Create searchSuggestions
            app.searchSuggestions = uilistbox(app.Tab1Grid);
            app.searchSuggestions.Items = {''};
            app.searchSuggestions.Tag = 'CAIXA DE BUSCA';
            app.searchSuggestions.Visible = 'off';
            app.searchSuggestions.FontSize = 14;
            app.searchSuggestions.Layout.Row = 3;
            app.searchSuggestions.Layout.Column = 3;
            app.searchSuggestions.Value = {};

            % Create Tab2_Products
            app.Tab2_Products = uitab(app.TabGroup);
            app.Tab2_Products.AutoResizeChildren = 'off';

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
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
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
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
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
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
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
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 12;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
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
