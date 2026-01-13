classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        DockModule                      matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        SubTabGroup                     matlab.ui.container.TabGroup
        SubTab1                         matlab.ui.container.Tab
        SubGrid1                        matlab.ui.container.GridLayout
        openAuxiliarApp2Debug           matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked         matlab.ui.control.CheckBox
        versionInfo                     matlab.ui.control.Label
        tool_versionInfoRefresh         matlab.ui.control.Image
        versionInfoLabel                matlab.ui.control.Label
        SubTab2                         matlab.ui.container.Tab
        SubGrid2                        matlab.ui.container.GridLayout
        config_SelectedTableColumns     matlab.ui.container.CheckBoxTree
        config_SelectedTableColumnsLabel  matlab.ui.control.Label
        config_MiscelaneousPanel2       matlab.ui.container.Panel
        config_MiscelaneousGrid2        matlab.ui.container.GridLayout
        config_WordCloudColumn          matlab.ui.control.DropDown
        config_WordCloudColumnLabel     matlab.ui.control.Label
        config_WordCloudAlgorithm       matlab.ui.control.DropDown
        config_WordCloudAlgorithmLabel  matlab.ui.control.Label
        config_MiscelaneousLabel2       matlab.ui.control.Label
        config_MiscelaneousPanel1       matlab.ui.container.Panel
        config_MiscelaneousGrid1        matlab.ui.container.GridLayout
        config_nMinWords                matlab.ui.control.DropDown
        config_nMinWordsLabel           matlab.ui.control.Label
        config_nMinCharacters           matlab.ui.control.Spinner
        config_nMinCharactersLabel      matlab.ui.control.Label
        config_SearchModeDefaultParameters  matlab.ui.control.Image
        config_MiscelaneousLabel1       matlab.ui.control.Label
        SubTab3                         matlab.ui.container.Tab
        SubGrid3                        matlab.ui.container.GridLayout
        reportPanel                     matlab.ui.container.Panel
        reportGrid                      matlab.ui.container.GridLayout
        reportDocType                   matlab.ui.control.DropDown
        reportDocTypeLabel              matlab.ui.control.Label
        reportLabel                     matlab.ui.control.Label
        eFiscalizaPanel                 matlab.ui.container.Panel
        eFiscalizaGrid                  matlab.ui.container.GridLayout
        reportUnit                      matlab.ui.control.DropDown
        reportUnitLabel                 matlab.ui.control.Label
        reportSystem                    matlab.ui.control.DropDown
        reportSystemLabel               matlab.ui.control.Label
        eFiscalizaRefresh               matlab.ui.control.Image
        eFiscalizaLabel                 matlab.ui.control.Label
        SubTab4                         matlab.ui.container.Tab
        SubGrid4                        matlab.ui.container.GridLayout
        userPathButton                  matlab.ui.control.Image
        userPath                        matlab.ui.control.EditField
        userPathLabel                   matlab.ui.control.Label
        DataHubPOSTButton               matlab.ui.control.Image
        DataHubPOST                     matlab.ui.control.EditField
        DATAHUBPOSTLabel                matlab.ui.control.Label
        DataHubGETButton                matlab.ui.control.Image
        DataHubGET                      matlab.ui.control.EditField
        DATAHUBGETLabel                 matlab.ui.control.Label
        Toolbar                         matlab.ui.container.GridLayout
        exportTable                     matlab.ui.control.Image
        openDevTools                    matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        defaultValues
        lockColumnStyle = uistyle('Icon', 'lock_20Gray.svg', 'FontColor', [.65,.65,.65], 'IconAlignment', 'leftmargin')
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)
                        
                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;
            
            switch tabIndex
                case 1
                    elDataTag = ui.CustomizationBase.getElementsDataTag({app.versionInfo});
                    if ~isempty(elDataTag)
                        ui.TextView.startup(app.jsBackDoor, app.versionInfo, class(app));
                    end

                case 2
                    if ~strcmp(app.mainApp.executionMode, 'webApp')
                        app.config_WordCloudAlgorithm.Enable = 1;
                    end
                    updatePanel_Analysis(app)

                case 3
                    if ~isdeployed()
                        app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS', 'eFiscaliza HM', 'eFiscaliza DS'};
                    end
                    updatePanel_Report(app)

                case 4
                    if ~strcmp(app.mainApp.executionMode, 'webApp')
                        set([app.DataHubGETButton, app.DataHubPOSTButton, app.userPathButton], 'Enable', 1)
                    end
                    updatePanel_Folder(app)
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder     = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath   = fullfile(projectFolder, 'GeneralSettings.json');
            projectGeneral    = jsondecode(fileread(projectFilePath));

            app.defaultValues = struct('Search',   struct('search', projectGeneral.search, 'ui', projectGeneral.ui), ...
                                       'Products', projectGeneral.products, ...
                                       'Report',   projectGeneral.Report);
            app.defaultValues.Search.ui.searchTable = struct2table(app.defaultValues.Search.ui.searchTable);
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable       = 1;
                app.openDevTools.Enable            = 1;
                app.tool_versionInfoRefresh.Enable = 1;
                app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable   = 1;
            end

            if isfolder(app.mainApp.General.fileFolder.DataHub_GET)
                app.exportTable.Enable = 'on';
            end
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            % Versão:
            appInfo = util.HtmlTextGenerator.AppInfo( ...
                app.mainApp.General, ...
                app.mainApp.rootFolder, ...
                app.mainApp.executionMode, ...
                app.mainApp.renderCount, ...
                app.mainApp.schDataTable, ...
                app.mainApp.releasedData, ...
                app.mainApp.cacheData, ...
                app.mainApp.annotationTable, ...
                'textview' ...
            );
            ui.TextView.update(app.versionInfo, appInfo);

            % Modo de operação:
            app.openAuxiliarAppAsDocked.Value = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value   = app.mainApp.General.operationMode.Debug;
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel_Analysis(app)
            % ALGORITMO SUGESTÃO DE TOKENS
            app.config_nMinCharacters.Value     = app.mainApp.General.search.minCharacters;

            numDisplayedTokens = num2str(app.mainApp.General.search.minDisplayedTokens);
            if ismember(numDisplayedTokens, app.config_nMinWords.Items)
                app.config_nMinWords.Value      = numDisplayedTokens;
            end

            % ANOTAÇÃO DO TIPO "WORDCLOUD"
            app.config_WordCloudAlgorithm.Value = app.mainApp.General.search.wordCloud.algorithm;
            app.config_WordCloudColumn.Value    = app.mainApp.General.search.wordCloud.column;

            % VISIBILIDADE DE COLUNAS
            columnCheckedList = matlab.ui.container.TreeNode.empty;
            columnStaticList  = matlab.ui.container.TreeNode.empty;

            if ~isempty(app.config_SelectedTableColumns.Children)
                delete(app.config_SelectedTableColumns.Children)
            end

            for ii = 1:height(app.mainApp.General.ui.searchTable)
                columnName     = app.mainApp.General.ui.searchTable.name{ii};
                columnVisible  = app.mainApp.General.ui.searchTable.visible(ii);
                columnPosition = app.mainApp.General.ui.searchTable.columnPosition(ii);

                treeNode       = uitreenode(app.config_SelectedTableColumns, 'Text', columnName);
                if columnPosition % static
                    columnStaticList(end+1)  = treeNode;
                end

                if columnVisible % visible
                    columnCheckedList(end+1) = treeNode;
                end
            end
            app.config_SelectedTableColumns.CheckedNodes = columnCheckedList;

            s = app.lockColumnStyle;
            addStyle(app.config_SelectedTableColumns, s, 'node', columnStaticList)

            app.config_SearchModeDefaultParameters.Visible = checkEdition(app, 'SEARCH');
        end

        %-----------------------------------------------------------------%
        function updatePanel_Report(app)
            app.reportSystem.Value  = app.mainApp.General.Report.system;
            set(app.reportUnit, 'Items', app.mainApp.General.eFiscaliza.defaultValues.unit, 'Value', app.mainApp.General.Report.unit)
            app.reportDocType.Value = app.mainApp.General.Report.Document;

            app.eFiscalizaRefresh.Visible = checkEdition(app, 'REPORT');
        end

        %-----------------------------------------------------------------%
        function updatePanel_Folder(app)
            DataHub_GET  = app.mainApp.General.fileFolder.DataHub_GET;
            if isfolder(DataHub_GET)
                app.DataHubGET.Value = DataHub_GET;
            end

            DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
            if isfolder(DataHub_POST)
                app.DataHubPOST.Value = DataHub_POST;
            end

            app.userPath.Value = app.mainApp.General.fileFolder.userPath;                
        end

        %-----------------------------------------------------------------%
        function columnInfo = search_Table_ColumnInfo(app, type)
            switch type
                case 'staticColumns'
                    staticLogical  = logical(app.mainApp.General.ui.searchTable.columnPosition);
                    staticIndex    = app.mainApp.General.ui.searchTable.columnPosition(staticLogical);
                    [~, idxOrder]  = sort(staticIndex);
                    columnList     = app.mainApp.General.ui.searchTable.name(staticLogical);
                    columnInfo     = columnList(idxOrder);

                case 'visibleColumns'
                    visibleLogical = logical(app.mainApp.General.ui.searchTable.visible);
                    columnInfo     = app.mainApp.General.ui.searchTable.name(visibleLogical);

                case 'allColumns'
                    columnInfo     = app.mainApp.General.ui.searchTable.name;

                case 'allColumnsWidths'
                    columnInfo     = app.mainApp.General.ui.searchTable.columnWidth;
            end
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app, tabName)
            editionFlag   = false;
            currentValues = struct('Search',   struct('search', app.mainApp.General.search, 'ui', app.mainApp.General.ui), ...
                                   'Produtcs', app.mainApp.General.products, ...
                                   'Report',   app.mainApp.General.Report);

            switch tabName
                case 'SEARCH'
                    if ~isequal(currentValues.Search, app.defaultValues.Search)
                        editionFlag = true;
                    end
                case 'PRODUCTS'
                    if ~isequal(currentValues.Produtcs, app.defaultValues.Produtcs)
                        editionFlag = true;
                    end
                case 'REPORT'
                    if ~isequal(currentValues.Report, app.defaultValues.Report)
                        editionFlag = true;
                    end
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                appEngine.boot(app, app.Role, mainApp)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', "CONFIG")
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Selection change function: SubTabGroup
        function SubTabGroup_TabSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)
            
        end

        % Image clicked function: tool_versionInfoRefresh
        function Toolbar_AppEnvRefreshButtonPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            htmlContent = util.HtmlTextGenerator.checkUpdate(app.mainApp.General, app.mainApp.rootFolder);
            ui.Dialog(app.UIFigure, "info", htmlContent);       

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: exportTable, openDevTools
        function ToolbarButtonPushed(app, event)
            
            switch event.Source
                case app.exportTable
                    nameFormatMap = {'*.xlsx', 'Excel'};
                    defaultName   = appEngine.util.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'SCH', -1);
                    fileFullPath  = ui.Dialog(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                    if isempty(fileFullPath)
                        return
                    end
        
                    app.progressDialog.Visible = 'visible';
        
                    try
                        fileName = sprintf('SCHData%s.xlsx', app.mainApp.General.search.dataBaseVersion);
                        copyfile(fullfile(app.mainApp.General.fileFolder.DataHub_GET, fileName), fileFullPath, 'f')

                        if ~strcmp(app.mainApp.executionMode, 'webApp')
                            appEngine.util.OperationSystem('openFile', fileFullPath)
                        end
                    catch ME
                        ui.Dialog(app.UIFigure, 'warning', getReport(ME));
                    end
        
                    app.progressDialog.Visible = 'hidden';

                case app.openDevTools
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'openDevTools')
            end

        end

        % Image clicked function: config_SearchModeDefaultParameters
        function Analysis_DefaultParametersClicked(app, event)
            
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder      = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath    = fullfile(projectFolder, 'GeneralSettings.json');

            projectFileContent = jsondecode(fileread(projectFilePath));
            projectFileContent.ui.searchTable = struct2table(projectFileContent.ui.searchTable);

            if isequal(app.mainApp.General.search, projectFileContent.search) && isequal(app.mainApp.General.ui, projectFileContent.ui)
                msgWarning = 'Configurações atuais já coincidem com as iniciais.';
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
                return

            else
                ipcEventName = {};
                if ~isequal(app.mainApp.General.search.wordCloud.algorithm, projectFileContent.search.wordCloud.algorithm)
                    ipcEventName{end+1} = 'onWordCloudAlgorithmChanged';
                end

                if ~isequal(app.mainApp.General.ui.searchTable, projectFileContent.ui.searchTable)
                    ipcEventName{end+1} = 'onSearchVisibleColumnsChanged';
                end

                app.mainApp.General.search   = projectFileContent.search;
                app.mainApp.General.ui       = projectFileContent.ui;
                
                app.mainApp.General_I.search = app.mainApp.General.search;
                app.mainApp.General_I.ui     = app.mainApp.General.ui;                
                
                updatePanel_Analysis(app)
                saveGeneralSettings(app)

                for ii = 1:numel(ipcEventName)
                    ipcMainMatlabCallsHandler(app.mainApp, app, ipcEventName{ii})
                end
            end

        end

        % Callback function: config_SelectedTableColumns, 
        % ...and 4 other components
        function Analysis_ParameterValueChanged(app, event)
            
            ipcEventName = '';

            switch event.Source
                case app.config_nMinCharacters
                    app.mainApp.General.search.minCharacters = app.config_nMinCharacters.Value;

                case app.config_nMinWords
                    app.mainApp.General.search.minDisplayedTokens = str2double(app.config_nMinWords.Value);

                case app.config_WordCloudAlgorithm
                    ipcEventName = 'onWordCloudAlgorithmChanged';
                    app.mainApp.General.search.wordCloud.algorithm = app.config_WordCloudAlgorithm.Value;

                case app.config_WordCloudColumn
                    app.mainApp.General.search.wordCloud.column = app.config_WordCloudColumn.Value;

                case app.config_SelectedTableColumns
                    ipcEventName = 'onSearchVisibleColumnsChanged';

                    previousCheckedNodes = event.PreviousCheckedNodes;
                    currentCheckedNodes  = event.CheckedNodes;

                    if isequal(previousCheckedNodes, currentCheckedNodes)
                        return
                    end

                    if numel(currentCheckedNodes) >= numel(previousCheckedNodes)
                        triggedCheckedNode = setdiff(currentCheckedNodes, previousCheckedNodes);
                    else
                        triggedCheckedNode = setdiff(previousCheckedNodes, currentCheckedNodes);
                    end
                    
                    checkedNodesText = {triggedCheckedNode.Text};
                    staticColumns = search_Table_ColumnInfo(app, 'staticColumns');

                    onlyStaticColumnChanged = true;
                    for ii = 1:numel(checkedNodesText)
                        if ismember(checkedNodesText{ii}, staticColumns)
                            checkedTreeNode = findobj(app.config_SelectedTableColumns, 'Text', checkedNodesText{ii});
                            app.config_SelectedTableColumns.CheckedNodes = [app.config_SelectedTableColumns.CheckedNodes; checkedTreeNode];
                            drawnow
                        else
                            onlyStaticColumnChanged = false;
                        end
                    end
                    checkedColumns = {app.config_SelectedTableColumns.CheckedNodes.Text};

                    if onlyStaticColumnChanged
                        return
                    end

                    for jj = 1:height(app.mainApp.General.ui.searchTable)
                        app.mainApp.General.ui.searchTable.visible(jj) = ismember(app.mainApp.General.ui.searchTable.name{jj}, checkedColumns);
                    end
            end

            app.progressDialog.Visible = 'visible';

            app.mainApp.General_I.search = app.mainApp.General.search;
            app.mainApp.General_I.ui     = app.mainApp.General.ui;
            
            updatePanel_Analysis(app)
            saveGeneralSettings(app)

            if ~isempty(ipcEventName)
                ipcMainMatlabCallsHandler(app.mainApp, app, ipcEventName)
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Value changed function: openAuxiliarApp2Debug, 
        % ...and 1 other component
        function Config_GeneralParameterValueChanged(app, event)
            
            switch event.Source
                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;
            end

            app.mainApp.General_I.operationMode = app.mainApp.General.operationMode;
            saveGeneralSettings(app)
            
        end

        % Image clicked function: eFiscalizaRefresh
        function Config_ProjectRefreshImageClicked(app, event)
            
            if ~checkEdition(app, 'REPORT')
                app.eFiscalizaRefresh.Visible = 0;
                return
            
            else
                app.mainApp.General.Report   = app.defaultValues.Report;
                app.mainApp.General_I.Report = app.mainApp.General.Report;
                
                updatePanel_Report(app)
                saveGeneralSettings(app)
            end

        end

        % Value changed function: reportDocType, reportSystem, reportUnit
        function Config_ProjectParameterValueChanged(app, event)
            
            switch event.Source
                case app.reportSystem
                    app.mainApp.General.Report.system   = event.Value;

                case app.reportUnit
                    app.mainApp.General.Report.unit     = event.Value;

                case app.reportDocType
                    app.mainApp.General.Report.Document = event.Value;
            end

            app.mainApp.General_I.Report = app.mainApp.General.Report;

            updatePanel_Report(app)
            saveGeneralSettings(app)
            
        end

        % Image clicked function: DataHubGETButton, DataHubPOSTButton, 
        % ...and 1 other component
        function Config_FolderButtonPushed(app, event)
            
            try
                relatedFolder = eval(sprintf('app.%s.Value', event.Source.Tag));                    
            catch
                relatedFolder = app.mainApp.General.fileFolder.(event.Source.Tag);
            end
            
            if isfolder(relatedFolder)
                initialFolder = relatedFolder;
            elseif isfile(relatedFolder)
                initialFolder = fileparts(relatedFolder);
            else
                initialFolder = app.userPath.Value;
            end
            
            selectedFolder = uigetdir(initialFolder);
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                figure(app.UIFigure)
            end

            if selectedFolder
                switch event.Source
                    case app.DataHubGETButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_GET, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.sch_get', {selectedFolderFiles.name})
                                ui.Dialog(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - GET", do SCH.');
                                return
                            end

                            app.DataHubGET.Value = selectedFolder;
                            app.mainApp.General.fileFolder.DataHub_GET = selectedFolder;
    
                            initializeUIComponents(app)
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'updateDataHubGetFolder')
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'checkDataHubLampStatus')
                        end

                    case app.DataHubPOSTButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_POST, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.sch_post', {selectedFolderFiles.name})
                                ui.Dialog(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - POST", do SCH.');
                                return
                            end

                            app.DataHubPOST.Value = selectedFolder;
                            app.mainApp.General.fileFolder.DataHub_POST = selectedFolder;
    
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'checkDataHubLampStatus')
                        end

                    case app.userPathButton
                        app.userPath.Value = selectedFolder;
                        app.mainApp.General.fileFolder.userPath = selectedFolder;
                end

                app.mainApp.General_I.fileFolder = app.mainApp.General.fileFolder;
                saveGeneralSettings(app)
                updatePanel_Folder(app)
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
                app.UIFigure.Icon = 'icon_32.png';
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
            app.GridLayout.ColumnWidth = {10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, '1x', 22};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.96078431372549 0.96078431372549 0.96078431372549];

            % Create openDevTools
            app.openDevTools = uiimage(app.Toolbar);
            app.openDevTools.ScaleMethod = 'none';
            app.openDevTools.ImageClickedFcn = createCallbackFcn(app, @ToolbarButtonPushed, true);
            app.openDevTools.Enable = 'off';
            app.openDevTools.Tooltip = {'Abre DevTools'};
            app.openDevTools.Layout.Row = 2;
            app.openDevTools.Layout.Column = 3;
            app.openDevTools.ImageSource = 'Debug_18.png';

            % Create exportTable
            app.exportTable = uiimage(app.Toolbar);
            app.exportTable.ImageClickedFcn = createCallbackFcn(app, @ToolbarButtonPushed, true);
            app.exportTable.Enable = 'off';
            app.exportTable.Tooltip = {'Abre cópia de base dados no Excel'};
            app.exportTable.Layout.Row = 2;
            app.exportTable.Layout.Column = 1;
            app.exportTable.ImageSource = 'Sheet_32.png';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @SubTabGroup_TabSelectionChanged, true);
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = [2 3];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'ASPECTOS GERAIS';
            app.SubTab1.BackgroundColor = 'none';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x', 22};
            app.SubGrid1.RowHeight = {17, 150, 22, '1x', 1, 22, 15};
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.SubGrid1);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'AMBIENTE:';

            % Create tool_versionInfoRefresh
            app.tool_versionInfoRefresh = uiimage(app.SubGrid1);
            app.tool_versionInfoRefresh.ScaleMethod = 'none';
            app.tool_versionInfoRefresh.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AppEnvRefreshButtonPushed, true);
            app.tool_versionInfoRefresh.Enable = 'off';
            app.tool_versionInfoRefresh.Tooltip = {'Verifica atualizações'};
            app.tool_versionInfoRefresh.Layout.Row = 1;
            app.tool_versionInfoRefresh.Layout.Column = 2;
            app.tool_versionInfoRefresh.VerticalAlignment = 'bottom';
            app.tool_versionInfoRefresh.ImageSource = 'Refresh_18.png';

            % Create versionInfo
            app.versionInfo = uilabel(app.SubGrid1);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = [2 4];
            app.versionInfo.Layout.Column = [1 2];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.SubGrid1);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.Layout.Row = 6;
            app.openAuxiliarAppAsDocked.Layout.Column = [1 2];

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.SubGrid1);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.Layout.Row = 7;
            app.openAuxiliarApp2Debug.Layout.Column = [1 2];

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'ANÁLISE';
            app.SubTab2.BackgroundColor = 'none';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {'1x', 22};
            app.SubGrid2.RowHeight = {17, 64, 22, 64, 22, '1x', 1};
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create config_MiscelaneousLabel1
            app.config_MiscelaneousLabel1 = uilabel(app.SubGrid2);
            app.config_MiscelaneousLabel1.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel1.FontSize = 10;
            app.config_MiscelaneousLabel1.Layout.Row = 1;
            app.config_MiscelaneousLabel1.Layout.Column = 1;
            app.config_MiscelaneousLabel1.Text = 'ALGORITMO SUGESTÃO DE TOKENS';

            % Create config_SearchModeDefaultParameters
            app.config_SearchModeDefaultParameters = uiimage(app.SubGrid2);
            app.config_SearchModeDefaultParameters.ScaleMethod = 'none';
            app.config_SearchModeDefaultParameters.ImageClickedFcn = createCallbackFcn(app, @Analysis_DefaultParametersClicked, true);
            app.config_SearchModeDefaultParameters.Visible = 'off';
            app.config_SearchModeDefaultParameters.Tooltip = {'Retorna às configurações iniciais'};
            app.config_SearchModeDefaultParameters.Layout.Row = 1;
            app.config_SearchModeDefaultParameters.Layout.Column = 2;
            app.config_SearchModeDefaultParameters.VerticalAlignment = 'bottom';
            app.config_SearchModeDefaultParameters.ImageSource = 'Refresh_18.png';

            % Create config_MiscelaneousPanel1
            app.config_MiscelaneousPanel1 = uipanel(app.SubGrid2);
            app.config_MiscelaneousPanel1.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel1.Layout.Row = 2;
            app.config_MiscelaneousPanel1.Layout.Column = [1 2];

            % Create config_MiscelaneousGrid1
            app.config_MiscelaneousGrid1 = uigridlayout(app.config_MiscelaneousPanel1);
            app.config_MiscelaneousGrid1.ColumnWidth = {150, 150};
            app.config_MiscelaneousGrid1.RowHeight = {17, 22};
            app.config_MiscelaneousGrid1.RowSpacing = 5;
            app.config_MiscelaneousGrid1.Padding = [10 10 10 5];
            app.config_MiscelaneousGrid1.BackgroundColor = [1 1 1];

            % Create config_nMinCharactersLabel
            app.config_nMinCharactersLabel = uilabel(app.config_MiscelaneousGrid1);
            app.config_nMinCharactersLabel.VerticalAlignment = 'bottom';
            app.config_nMinCharactersLabel.WordWrap = 'on';
            app.config_nMinCharactersLabel.FontSize = 10;
            app.config_nMinCharactersLabel.Layout.Row = 1;
            app.config_nMinCharactersLabel.Layout.Column = 1;
            app.config_nMinCharactersLabel.Text = 'Qtd. mínima caracteres:';

            % Create config_nMinCharacters
            app.config_nMinCharacters = uispinner(app.config_MiscelaneousGrid1);
            app.config_nMinCharacters.Limits = [2 4];
            app.config_nMinCharacters.RoundFractionalValues = 'on';
            app.config_nMinCharacters.ValueDisplayFormat = '%d';
            app.config_nMinCharacters.ValueChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_nMinCharacters.FontSize = 11;
            app.config_nMinCharacters.Layout.Row = 2;
            app.config_nMinCharacters.Layout.Column = 1;
            app.config_nMinCharacters.Value = 2;

            % Create config_nMinWordsLabel
            app.config_nMinWordsLabel = uilabel(app.config_MiscelaneousGrid1);
            app.config_nMinWordsLabel.VerticalAlignment = 'bottom';
            app.config_nMinWordsLabel.WordWrap = 'on';
            app.config_nMinWordsLabel.FontSize = 10;
            app.config_nMinWordsLabel.Layout.Row = 1;
            app.config_nMinWordsLabel.Layout.Column = 2;
            app.config_nMinWordsLabel.Interpreter = 'html';
            app.config_nMinWordsLabel.Text = 'Qtd. mínima <i>tokens</i>:';

            % Create config_nMinWords
            app.config_nMinWords = uidropdown(app.config_MiscelaneousGrid1);
            app.config_nMinWords.Items = {'20', '50'};
            app.config_nMinWords.ValueChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_nMinWords.FontSize = 11;
            app.config_nMinWords.BackgroundColor = [1 1 1];
            app.config_nMinWords.Layout.Row = 2;
            app.config_nMinWords.Layout.Column = 2;
            app.config_nMinWords.Value = '20';

            % Create config_MiscelaneousLabel2
            app.config_MiscelaneousLabel2 = uilabel(app.SubGrid2);
            app.config_MiscelaneousLabel2.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel2.FontSize = 10;
            app.config_MiscelaneousLabel2.Layout.Row = 3;
            app.config_MiscelaneousLabel2.Layout.Column = 1;
            app.config_MiscelaneousLabel2.Text = 'ANOTAÇÃO DO TIPO "WORDCLOUD"';

            % Create config_MiscelaneousPanel2
            app.config_MiscelaneousPanel2 = uipanel(app.SubGrid2);
            app.config_MiscelaneousPanel2.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel2.Layout.Row = 4;
            app.config_MiscelaneousPanel2.Layout.Column = [1 2];

            % Create config_MiscelaneousGrid2
            app.config_MiscelaneousGrid2 = uigridlayout(app.config_MiscelaneousPanel2);
            app.config_MiscelaneousGrid2.ColumnWidth = {150, 150};
            app.config_MiscelaneousGrid2.RowHeight = {17, 22};
            app.config_MiscelaneousGrid2.RowSpacing = 5;
            app.config_MiscelaneousGrid2.Padding = [10 10 10 5];
            app.config_MiscelaneousGrid2.BackgroundColor = [1 1 1];

            % Create config_WordCloudAlgorithmLabel
            app.config_WordCloudAlgorithmLabel = uilabel(app.config_MiscelaneousGrid2);
            app.config_WordCloudAlgorithmLabel.VerticalAlignment = 'bottom';
            app.config_WordCloudAlgorithmLabel.WordWrap = 'on';
            app.config_WordCloudAlgorithmLabel.FontSize = 10;
            app.config_WordCloudAlgorithmLabel.Layout.Row = 1;
            app.config_WordCloudAlgorithmLabel.Layout.Column = 1;
            app.config_WordCloudAlgorithmLabel.Text = 'Algoritmo gráfico:';

            % Create config_WordCloudAlgorithm
            app.config_WordCloudAlgorithm = uidropdown(app.config_MiscelaneousGrid2);
            app.config_WordCloudAlgorithm.Items = {'D3.js', 'MATLAB built-in'};
            app.config_WordCloudAlgorithm.ValueChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_WordCloudAlgorithm.Enable = 'off';
            app.config_WordCloudAlgorithm.FontSize = 11;
            app.config_WordCloudAlgorithm.BackgroundColor = [1 1 1];
            app.config_WordCloudAlgorithm.Layout.Row = 2;
            app.config_WordCloudAlgorithm.Layout.Column = 1;
            app.config_WordCloudAlgorithm.Value = 'D3.js';

            % Create config_WordCloudColumnLabel
            app.config_WordCloudColumnLabel = uilabel(app.config_MiscelaneousGrid2);
            app.config_WordCloudColumnLabel.VerticalAlignment = 'bottom';
            app.config_WordCloudColumnLabel.WordWrap = 'on';
            app.config_WordCloudColumnLabel.FontSize = 10;
            app.config_WordCloudColumnLabel.Layout.Row = 1;
            app.config_WordCloudColumnLabel.Layout.Column = 2;
            app.config_WordCloudColumnLabel.Text = 'Pesquisa orientada à coluna:';

            % Create config_WordCloudColumn
            app.config_WordCloudColumn = uidropdown(app.config_MiscelaneousGrid2);
            app.config_WordCloudColumn.Items = {'Modelo', 'Nome Comercial'};
            app.config_WordCloudColumn.ValueChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_WordCloudColumn.FontSize = 11;
            app.config_WordCloudColumn.BackgroundColor = [1 1 1];
            app.config_WordCloudColumn.Layout.Row = 2;
            app.config_WordCloudColumn.Layout.Column = 2;
            app.config_WordCloudColumn.Value = 'Modelo';

            % Create config_SelectedTableColumnsLabel
            app.config_SelectedTableColumnsLabel = uilabel(app.SubGrid2);
            app.config_SelectedTableColumnsLabel.VerticalAlignment = 'bottom';
            app.config_SelectedTableColumnsLabel.FontSize = 10;
            app.config_SelectedTableColumnsLabel.Layout.Row = 5;
            app.config_SelectedTableColumnsLabel.Layout.Column = 1;
            app.config_SelectedTableColumnsLabel.Text = 'VISIBILIDADE DE COLUNAS';

            % Create config_SelectedTableColumns
            app.config_SelectedTableColumns = uitree(app.SubGrid2, 'checkbox');
            app.config_SelectedTableColumns.FontSize = 11;
            app.config_SelectedTableColumns.Layout.Row = 6;
            app.config_SelectedTableColumns.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.config_SelectedTableColumns.CheckedNodesChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.AutoResizeChildren = 'off';
            app.SubTab3.Title = 'PROJETO';

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {'1x', 22};
            app.SubGrid3.RowHeight = {17, 70, 22, '1x'};
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.SubGrid3);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 1;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'INICIALIZAÇÃO eFISCALIZA';

            % Create eFiscalizaRefresh
            app.eFiscalizaRefresh = uiimage(app.SubGrid3);
            app.eFiscalizaRefresh.ScaleMethod = 'none';
            app.eFiscalizaRefresh.ImageClickedFcn = createCallbackFcn(app, @Config_ProjectRefreshImageClicked, true);
            app.eFiscalizaRefresh.Visible = 'off';
            app.eFiscalizaRefresh.Tooltip = {'Retorna às configurações iniciais'};
            app.eFiscalizaRefresh.Layout.Row = 1;
            app.eFiscalizaRefresh.Layout.Column = 2;
            app.eFiscalizaRefresh.VerticalAlignment = 'bottom';
            app.eFiscalizaRefresh.ImageSource = 'Refresh_18.png';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.SubGrid3);
            app.eFiscalizaPanel.AutoResizeChildren = 'off';
            app.eFiscalizaPanel.Layout.Row = 2;
            app.eFiscalizaPanel.Layout.Column = [1 2];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {350, 110, 110};
            app.eFiscalizaGrid.RowHeight = {22, 22};
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create reportSystemLabel
            app.reportSystemLabel = uilabel(app.eFiscalizaGrid);
            app.reportSystemLabel.WordWrap = 'on';
            app.reportSystemLabel.FontSize = 11;
            app.reportSystemLabel.Layout.Row = 1;
            app.reportSystemLabel.Layout.Column = 1;
            app.reportSystemLabel.Text = 'Ambiente do sistema de gestão à fiscalização:';

            % Create reportSystem
            app.reportSystem = uidropdown(app.eFiscalizaGrid);
            app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS'};
            app.reportSystem.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportSystem.FontSize = 11;
            app.reportSystem.BackgroundColor = [1 1 1];
            app.reportSystem.Layout.Row = 1;
            app.reportSystem.Layout.Column = [2 3];
            app.reportSystem.Value = 'eFiscaliza';

            % Create reportUnitLabel
            app.reportUnitLabel = uilabel(app.eFiscalizaGrid);
            app.reportUnitLabel.WordWrap = 'on';
            app.reportUnitLabel.FontSize = 11;
            app.reportUnitLabel.Layout.Row = 2;
            app.reportUnitLabel.Layout.Column = 1;
            app.reportUnitLabel.Text = 'Unidade responsável pela fiscalização:';

            % Create reportUnit
            app.reportUnit = uidropdown(app.eFiscalizaGrid);
            app.reportUnit.Items = {};
            app.reportUnit.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportUnit.FontSize = 11;
            app.reportUnit.BackgroundColor = [1 1 1];
            app.reportUnit.Layout.Row = 2;
            app.reportUnit.Layout.Column = 2;
            app.reportUnit.Value = {};

            % Create reportLabel
            app.reportLabel = uilabel(app.SubGrid3);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 3;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO';

            % Create reportPanel
            app.reportPanel = uipanel(app.SubGrid3);
            app.reportPanel.AutoResizeChildren = 'off';
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 4;
            app.reportPanel.Layout.Column = [1 2];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {350, 110, 110};
            app.reportGrid.RowHeight = {22};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [1 1 1];

            % Create reportDocTypeLabel
            app.reportDocTypeLabel = uilabel(app.reportGrid);
            app.reportDocTypeLabel.WordWrap = 'on';
            app.reportDocTypeLabel.FontSize = 11;
            app.reportDocTypeLabel.Layout.Row = 1;
            app.reportDocTypeLabel.Layout.Column = 1;
            app.reportDocTypeLabel.Text = 'Tipo de documento a gerar:';

            % Create reportDocType
            app.reportDocType = uidropdown(app.reportGrid);
            app.reportDocType.Items = {'Relatório de Atividades'};
            app.reportDocType.ValueChangedFcn = createCallbackFcn(app, @Config_ProjectParameterValueChanged, true);
            app.reportDocType.FontSize = 11;
            app.reportDocType.BackgroundColor = [1 1 1];
            app.reportDocType.Layout.Row = 1;
            app.reportDocType.Layout.Column = [2 3];
            app.reportDocType.Value = 'Relatório de Atividades';

            % Create SubTab4
            app.SubTab4 = uitab(app.SubTabGroup);
            app.SubTab4.AutoResizeChildren = 'off';
            app.SubTab4.Title = 'MAPEAMENTO DE PASTAS';
            app.SubTab4.BackgroundColor = 'none';

            % Create SubGrid4
            app.SubGrid4 = uigridlayout(app.SubTab4);
            app.SubGrid4.ColumnWidth = {'1x', 20};
            app.SubGrid4.RowHeight = {17, 22, 22, 22, 22, 22, '1x'};
            app.SubGrid4.ColumnSpacing = 5;
            app.SubGrid4.RowSpacing = 5;
            app.SubGrid4.BackgroundColor = [1 1 1];

            % Create DATAHUBGETLabel
            app.DATAHUBGETLabel = uilabel(app.SubGrid4);
            app.DATAHUBGETLabel.VerticalAlignment = 'bottom';
            app.DATAHUBGETLabel.FontSize = 10;
            app.DATAHUBGETLabel.Layout.Row = 1;
            app.DATAHUBGETLabel.Layout.Column = 1;
            app.DATAHUBGETLabel.Text = 'DATAHUB - GET:';

            % Create DataHubGET
            app.DataHubGET = uieditfield(app.SubGrid4, 'text');
            app.DataHubGET.Editable = 'off';
            app.DataHubGET.FontSize = 11;
            app.DataHubGET.Layout.Row = 2;
            app.DataHubGET.Layout.Column = 1;

            % Create DataHubGETButton
            app.DataHubGETButton = uiimage(app.SubGrid4);
            app.DataHubGETButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.DataHubGETButton.Tag = 'DataHub_POST';
            app.DataHubGETButton.Enable = 'off';
            app.DataHubGETButton.Layout.Row = 2;
            app.DataHubGETButton.Layout.Column = 2;
            app.DataHubGETButton.ImageSource = 'OpenFile_36x36.png';

            % Create DATAHUBPOSTLabel
            app.DATAHUBPOSTLabel = uilabel(app.SubGrid4);
            app.DATAHUBPOSTLabel.VerticalAlignment = 'bottom';
            app.DATAHUBPOSTLabel.FontSize = 10;
            app.DATAHUBPOSTLabel.Layout.Row = 3;
            app.DATAHUBPOSTLabel.Layout.Column = 1;
            app.DATAHUBPOSTLabel.Text = 'DATAHUB - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.SubGrid4, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.Layout.Row = 4;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.SubGrid4);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Enable = 'off';
            app.DataHubPOSTButton.Layout.Row = 4;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.SubGrid4);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 5;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'PASTA DO USUÁRIO:';

            % Create userPath
            app.userPath = uieditfield(app.SubGrid4, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.Layout.Row = 6;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.SubGrid4);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Enable = 'off';
            app.userPathButton.Layout.Row = 6;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [3 4];
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

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winConfig_exported(Container, varargin)

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
