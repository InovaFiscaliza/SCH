classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        config_Option2Grid              matlab.ui.container.GridLayout
        config_SearchModeLabel          matlab.ui.control.Label
        config_SearchModePanel          matlab.ui.container.ButtonGroup
        config_SearchModeListOfWords    matlab.ui.control.RadioButton
        config_SearchModeTokenSuggestion  matlab.ui.control.RadioButton
        config_SearchModeDefaultParameters  matlab.ui.control.Image
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
        config_MiscelaneousLabel1       matlab.ui.control.Label
        Folders_Grid                    matlab.ui.container.GridLayout
        FolderMapPanel                  matlab.ui.container.Panel
        FolderMapGrid                   matlab.ui.container.GridLayout
        userPathButton                  matlab.ui.control.Image
        userPath                        matlab.ui.control.EditField
        userPathLabel                   matlab.ui.control.Label
        DataHubPOSTButton               matlab.ui.control.Image
        DataHubPOST                     matlab.ui.control.EditField
        DataHubPOSTLabel                matlab.ui.control.Label
        DataHubGETButton                matlab.ui.control.Image
        DataHubGET                      matlab.ui.control.EditField
        DataHubGETLabel                 matlab.ui.control.Label
        config_FolderMapLabel           matlab.ui.control.Label
        General_Grid                    matlab.ui.container.GridLayout
        openAuxiliarApp2Debug           matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked         matlab.ui.control.CheckBox
        gpuType                         matlab.ui.control.DropDown
        gpuTypeLabel                    matlab.ui.control.Label
        versionInfo                     matlab.ui.control.Label
        versionInfoLabel                matlab.ui.control.Label
        LeftPanelRadioGroup             matlab.ui.container.ButtonGroup
        btnFolder                       matlab.ui.control.RadioButton
        btnAnalysis                     matlab.ui.control.RadioButton
        btnGeneral                      matlab.ui.control.RadioButton
        LeftPanel                       matlab.ui.container.Panel
        LeftPanelGrid                   matlab.ui.container.GridLayout
        menu_ButtonGrid                 matlab.ui.container.GridLayout
        menu_ButtonIcon                 matlab.ui.control.Image
        menu_ButtonLabel                matlab.ui.control.Label
        toolGrid                        matlab.ui.container.GridLayout
        exportTable                     matlab.ui.control.Image
        openDevTools                    matlab.ui.control.Image
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        mainApp
        rootFolder

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj
        jsBackDoor

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog

        stableVersion
    end


    methods
        %-----------------------------------------------------------------%
        % IPC: COMUNICAÇÃO ENTRE PROCESSOS
        %-----------------------------------------------------------------%
        function ipcSecundaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app)
                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                 ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app)
            if app.isDocked
                app.progressDialog = app.mainApp.progressDialog;
            else
                sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
            end

            elToModify = {app.versionInfo};
            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
            if ~isempty(elDataTag)
                appName = class(app);
                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
            end
        end
    end


    methods (Access = private)
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
            jsBackDoor_Customizations(app)

            startup_GUIComponents(app)
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            switch app.mainApp.executionMode
                case 'webApp'
                    delete(app.openDevTools)
                otherwise
                    app.btnFolder.Enable               = 1;
                    app.gpuType.Enable                 = 1;
                    app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable = 1;
            end

            General_updatePanel(app)
            Analysis_updatePanel(app)
            Folder_updatePanel(app)
        end

        %-----------------------------------------------------------------%
        function General_updatePanel(app)
            % Versão:
            ui.TextView.update(app.versionInfo, util.HtmlTextGenerator.AppInfo(app.mainApp.General, app.rootFolder, app.mainApp.executionMode, app.mainApp.rawDataTable, app.mainApp.releasedData, app.mainApp.cacheData, app.mainApp.annotationTable));

            % Renderizador:
            graphRender = opengl('data');
            switch graphRender.HardwareSupportLevel
                case 'basic'; graphRenderSupport = 'hardwarebasic';
                case 'full';  graphRenderSupport = 'hardware';
                case 'none';  graphRenderSupport = 'software';
                otherwise;    graphRenderSupport = graphRender.HardwareSupportLevel; % "driverissue"
            end

            if ~ismember(graphRenderSupport, app.gpuType.Items)
                app.gpuType.Items{end+1} = graphRenderSupport;
            end
            app.gpuType.Value = graphRenderSupport;

            % Modo de operação:
            app.openAuxiliarAppAsDocked.Value   = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value     = app.mainApp.General.operationMode.Debug;
        end

        %-----------------------------------------------------------------%
        function Analysis_updatePanel(app)
            % MODO
            switch app.mainApp.General.search.mode
                case 'tokens'
                    app.config_SearchModeTokenSuggestion.Value = 1;
                otherwise
                    app.config_SearchModeListOfWords.Value     = 1;
            end

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

            for ii = 1:height(app.mainApp.General.ui.SCHData)
                columnName     = app.mainApp.General.ui.SCHData.name{ii};
                columnVisible  = app.mainApp.General.ui.SCHData.visible(ii);
                columnPosition = app.mainApp.General.ui.SCHData.columnPosition(ii);

                treeNode       = uitreenode(app.config_SelectedTableColumns, 'Text', columnName);
                if columnPosition % static
                    columnStaticList(end+1)  = treeNode;
                end

                if columnVisible % visible
                    columnCheckedList(end+1) = treeNode;
                end
            end

            app.config_SelectedTableColumns.CheckedNodes = columnCheckedList;
            addStyle(app.config_SelectedTableColumns, class.Constants.configStyle5, 'node', columnStaticList)
        end

        %-----------------------------------------------------------------%
        function Folder_updatePanel(app)
            % Na versão webapp, a configuração das pastas não é habilitada.
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.btnFolder.Enable      = 1;

                DataHub_GET  = app.mainApp.General.fileFolder.DataHub_GET;
                if isfolder(DataHub_GET)
                    app.DataHubGET.Value  = DataHub_GET;
                end

                DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
                if isfolder(DataHub_POST)
                    app.DataHubPOST.Value = DataHub_POST;
                end

                app.userPath.Value        = app.mainApp.General.fileFolder.userPath;
            end
        end

        %-----------------------------------------------------------------%
        function columnInfo = search_Table_ColumnInfo(app, type)
            switch type
                case 'staticColumns'
                    staticLogical  = logical(app.mainApp.General.ui.SCHData.columnPosition);
                    staticIndex    = app.mainApp.General.ui.SCHData.columnPosition(staticLogical);
                    [~, idxOrder]  = sort(staticIndex);
                    columnList     = app.mainApp.General.ui.SCHData.name(staticLogical);
                    columnInfo     = columnList(idxOrder);

                case 'visibleColumns'
                    visibleLogical = logical(app.mainApp.General.ui.SCHData.visible);
                    columnInfo     = app.mainApp.General.ui.SCHData.name(visibleLogical);

                case 'allColumns'
                    columnInfo     = app.mainApp.General.ui.SCHData.name;

                case 'allColumnsWidths'
                    columnInfo     = app.mainApp.General.ui.SCHData.columnWidth;
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            % A razão de ser deste app é possibilitar visualização/edição 
            % de algumas das informações do arquivo "GeneralSettings.json".
            app.mainApp    = mainApp;
            app.rootFolder = mainApp.rootFolder;

            if app.isDocked
                app.GridLayout.Padding(4) = 21;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn')
            delete(app)
            
        end

        % Selection changed function: LeftPanelRadioGroup
        function RadioButtonGroupSelectionChanged(app, event)
            
            selectedButton = app.LeftPanelRadioGroup.SelectedObject;
            switch selectedButton
                case app.btnGeneral;  app.GridLayout.ColumnWidth(4:6) = {'1x',0,0};
                case app.btnAnalysis; app.GridLayout.ColumnWidth(4:6) = {0,'1x',0};
                case app.btnFolder;   app.GridLayout.ColumnWidth(4:6) = {0,0,'1x'};
            end
            
        end

        % Value changed function: gpuType, openAuxiliarApp2Debug, 
        % ...and 1 other component
        function Graphics_ParameterValueChanged(app, event)
            
            switch event.Source
                case app.gpuType
                    if ismember(app.gpuType.Value, {'software', 'hardware', 'hardwarebasic'})
                        eval(sprintf('opengl %s', app.gpuType.Value))

                        graphRender = opengl('data');
                        
                        app.mainApp.General.openGL = app.gpuType.Value;
                        app.mainApp.General.AppVersion.openGL = rmfield(graphRender, {'MaxTextureSize', 'Visual', 'SupportsGraphicsSmoothing', 'SupportsDepthPeelTransparency', 'SupportsAlignVertexCenters', 'Extensions', 'MaxFrameBufferSize'});
                    end

                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;
            end

            app.mainApp.General_I.openGL        = app.mainApp.General.openGL;
            app.mainApp.General_I.operationMode = app.mainApp.General.operationMode;
            saveGeneralSettings(app)

        end

        % Image clicked function: config_SearchModeDefaultParameters
        function Analysis_DefaultParametersClicked(app, event)
            
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder      = appUtil.Path(class.Constants.appName, app.rootFolder);
            projectFilePath    = fullfile(projectFolder, 'GeneralSettings.json');

            projectFileContent = jsondecode(fileread(projectFilePath));
            projectFileContent.ui.SCHData = struct2table(projectFileContent.ui.SCHData);

            if isequal(app.mainApp.General.search, projectFileContent.search) && isequal(app.mainApp.General.ui, projectFileContent.ui)
                msgWarning = 'Configurações atuais já coincidem com as iniciais.';
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return

            else
                ipcEventName = {};
                if ~isequal(app.mainApp.General.search.mode, projectFileContent.search.mode)
                    ipcEventName{end+1} = 'searchModeChanged';
                end

                if ~isequal(app.mainApp.General.search.wordCloud.algorithm, projectFileContent.search.wordCloud.algorithm)
                    ipcEventName{end+1} = 'wordCloudAlgorithmChanged';
                end

                if ~isequal(app.mainApp.General.ui.SCHData, projectFileContent.ui.SCHData)
                    ipcEventName{end+1} = 'searchVisibleColumnsChanged';
                end

                app.mainApp.General.search   = projectFileContent.search;
                app.mainApp.General.ui       = projectFileContent.ui;
                
                app.mainApp.General_I.search = app.mainApp.General.search;
                app.mainApp.General_I.ui     = app.mainApp.General.ui;                
                saveGeneralSettings(app)

                for ii = 1:numel(ipcEventName)
                    ipcMainMatlabCallsHandler(app.mainApp, app, ipcEventName{ii})
                end
                Analysis_updatePanel(app)
            end

        end

        % Callback function: config_SearchModePanel, 
        % ...and 5 other components
        function Analysis_ParameterValueChanged(app, event)

            ipcEventName = '';

            switch event.Source
                case app.config_SearchModePanel
                    ipcEventName = 'searchModeChanged';

                    switch app.config_SearchModePanel.SelectedObject
                        case app.config_SearchModeTokenSuggestion
                            app.mainApp.General.search.mode     = 'tokens';
                            app.mainApp.General.search.function = 'strcmp';
                        case app.config_SearchModeListOfWords
                            app.mainApp.General.search.mode     = 'words';
                            app.mainApp.General.search.function = 'contains';
                    end

                case app.config_nMinCharacters
                    app.mainApp.General.search.minCharacters = app.config_nMinCharacters.Value;

                case app.config_nMinWords
                    app.mainApp.General.search.minDisplayedTokens = str2double(app.config_nMinWords.Value);

                case app.config_WordCloudAlgorithm
                    ipcEventName = 'wordCloudAlgorithmChanged';
                    app.mainApp.General.search.wordCloud.algorithm = app.config_WordCloudAlgorithm.Value;

                case app.config_WordCloudColumn
                    app.mainApp.General.search.wordCloud.column = app.config_WordCloudColumn.Value;

                case app.config_SelectedTableColumns
                    ipcEventName = 'searchVisibleColumnsChanged';

                    % Inicialmente, certifica-se de que as colunas estáticas 
                    % se mantém selecionadas.
                    if ~isempty(app.config_SelectedTableColumns.CheckedNodes)
                        checkedColumns = {app.config_SelectedTableColumns.CheckedNodes.Text};
                    else
                        checkedColumns = {};
                    end
        
                    staticColumns = search_Table_ColumnInfo(app, 'staticColumns');
                    staticColumns(ismember(staticColumns, checkedColumns)) = [];
                    
                    if ~isempty(staticColumns)
                        for ii = 1:numel(staticColumns)
                            staticColumnName = staticColumns{ii};
                            staticTreeNodes  = findobj(app.config_SelectedTableColumns, 'Text', staticColumnName);
                            
                            app.config_SelectedTableColumns.CheckedNodes = [app.config_SelectedTableColumns.CheckedNodes; staticTreeNodes];
                        end
                    end

                    % E depois atualiza "GeneralSettings.json"...
                    finalCheckedColumns = {app.config_SelectedTableColumns.CheckedNodes.Text};
                    for jj = 1:height(app.mainApp.General.ui.SCHData)
                        app.mainApp.General.ui.SCHData.visible(jj) = ismember(app.mainApp.General.ui.SCHData.name{jj}, finalCheckedColumns);
                    end
            end

            app.mainApp.General_I.search = app.mainApp.General.search;
            app.mainApp.General_I.ui     = app.mainApp.General.ui;
            saveGeneralSettings(app)

            if ~isempty(ipcEventName)
                ipcMainMatlabCallsHandler(app.mainApp, app, ipcEventName)
            end
            
        end

        % Image clicked function: DataHubGETButton, DataHubPOSTButton, 
        % ...and 1 other component
        function Folder_ButtonPushed(app, event)
            
            try
                relatedFolder = eval(sprintf('app.config_Folder_%s.Value', event.Source.Tag));                    
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
            figure(app.UIFigure)

            if selectedFolder
                switch event.Source
                    case app.DataHubGETButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_GET, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.sch_get', {selectedFolderFiles.name})
                                appUtil.modalWindow(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - GET", do SCH.');
                                return
                            end

                            app.DataHubGET.Value = selectedFolder;
                            app.mainApp.General.fileFolder.DataHub_GET = selectedFolder;
    
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'checkDataHubLampStatus')
                        end

                    case app.DataHubPOSTButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_POST, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.sch_post', {selectedFolderFiles.name})
                                appUtil.modalWindow(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - POST", do SCH.');
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
                
                Folder_updatePanel(app)
            end

        end

        % Image clicked function: exportTable, openDevTools
        function ToolbarButtonPushed(app, event)
            
            switch event.Source
                case app.exportTable
                    nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
                    defaultName   = class.Constants.DefaultFileName(app.mainApp.General.fileFolder.userPath, 'SCH', -1);
                    fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                    if isempty(fileFullPath)
                        return
                    end
        
                    app.progressDialog.Visible = 'visible';
        
                    try
                        copyfile(fullfile(app.mainApp.General.fileFolder.DataHub_GET, replace(app.mainApp.General.fileName.SCHData, '.mat', '.xlsx')), fileFullPath, 'f')
                        ccTools.fcn.OperationSystem('openFile', fileFullPath)        
                    catch ME
                        appUtil.modalWindow(app.UIFigure, 'warning', getReport(ME));
                    end
        
                    app.progressDialog.Visible = 'hidden';

                case app.openDevTools
                    ipcMainMatlabCallsHandler(app.mainApp, app, 'openDevTools')
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
                app.UIFigure.Icon = 'icon_48.png';
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
            app.GridLayout.ColumnWidth = {5, 320, 10, '1x', 0, 0, 5};
            app.GridLayout.RowHeight = {5, 22, 5, 100, '1x', 5, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create toolGrid
            app.toolGrid = uigridlayout(app.GridLayout);
            app.toolGrid.ColumnWidth = {22, '1x', 22, 1};
            app.toolGrid.RowHeight = {4, 17, 2};
            app.toolGrid.ColumnSpacing = 5;
            app.toolGrid.RowSpacing = 0;
            app.toolGrid.Padding = [5 5 0 5];
            app.toolGrid.Layout.Row = 7;
            app.toolGrid.Layout.Column = [1 7];
            app.toolGrid.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create openDevTools
            app.openDevTools = uiimage(app.toolGrid);
            app.openDevTools.ScaleMethod = 'none';
            app.openDevTools.ImageClickedFcn = createCallbackFcn(app, @ToolbarButtonPushed, true);
            app.openDevTools.Tooltip = {'DevTools'};
            app.openDevTools.Layout.Row = 2;
            app.openDevTools.Layout.Column = 3;
            app.openDevTools.ImageSource = 'Debug_18.png';

            % Create exportTable
            app.exportTable = uiimage(app.toolGrid);
            app.exportTable.ImageClickedFcn = createCallbackFcn(app, @ToolbarButtonPushed, true);
            app.exportTable.Tooltip = {'Abre cópia de base dados no Excel'};
            app.exportTable.Layout.Row = 2;
            app.exportTable.Layout.Column = 1;
            app.exportTable.ImageSource = 'Sheet_32.png';

            % Create menu_ButtonGrid
            app.menu_ButtonGrid = uigridlayout(app.GridLayout);
            app.menu_ButtonGrid.ColumnWidth = {18, '1x', '1x'};
            app.menu_ButtonGrid.RowHeight = {'1x'};
            app.menu_ButtonGrid.ColumnSpacing = 3;
            app.menu_ButtonGrid.Padding = [2 0 0 0];
            app.menu_ButtonGrid.Layout.Row = 2;
            app.menu_ButtonGrid.Layout.Column = 2;
            app.menu_ButtonGrid.BackgroundColor = [0.749 0.749 0.749];

            % Create menu_ButtonLabel
            app.menu_ButtonLabel = uilabel(app.menu_ButtonGrid);
            app.menu_ButtonLabel.FontSize = 11;
            app.menu_ButtonLabel.Layout.Row = 1;
            app.menu_ButtonLabel.Layout.Column = 2;
            app.menu_ButtonLabel.Text = 'CONFIGURAÇÕES';

            % Create menu_ButtonIcon
            app.menu_ButtonIcon = uiimage(app.menu_ButtonGrid);
            app.menu_ButtonIcon.ScaleMethod = 'none';
            app.menu_ButtonIcon.Tag = '1';
            app.menu_ButtonIcon.Layout.Row = 1;
            app.menu_ButtonIcon.Layout.Column = 1;
            app.menu_ButtonIcon.HorizontalAlignment = 'left';
            app.menu_ButtonIcon.ImageSource = 'Settings_18.png';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.AutoResizeChildren = 'off';
            app.LeftPanel.Layout.Row = [4 5];
            app.LeftPanel.Layout.Column = 2;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {'1x'};
            app.LeftPanelGrid.RowHeight = {100, '1x'};
            app.LeftPanelGrid.Padding = [0 0 0 0];
            app.LeftPanelGrid.BackgroundColor = [1 1 1];

            % Create LeftPanelRadioGroup
            app.LeftPanelRadioGroup = uibuttongroup(app.GridLayout);
            app.LeftPanelRadioGroup.AutoResizeChildren = 'off';
            app.LeftPanelRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @RadioButtonGroupSelectionChanged, true);
            app.LeftPanelRadioGroup.BorderType = 'none';
            app.LeftPanelRadioGroup.BackgroundColor = [1 1 1];
            app.LeftPanelRadioGroup.Layout.Row = 4;
            app.LeftPanelRadioGroup.Layout.Column = 2;
            app.LeftPanelRadioGroup.FontSize = 11;

            % Create btnGeneral
            app.btnGeneral = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnGeneral.Text = 'Aspectos gerais';
            app.btnGeneral.FontSize = 11;
            app.btnGeneral.Position = [14 69 100 22];
            app.btnGeneral.Value = true;

            % Create btnAnalysis
            app.btnAnalysis = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnAnalysis.Text = 'Análise';
            app.btnAnalysis.FontSize = 11;
            app.btnAnalysis.Position = [14 47 58 22];

            % Create btnFolder
            app.btnFolder = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnFolder.Enable = 'off';
            app.btnFolder.Text = 'Mapeamento de pastas';
            app.btnFolder.FontSize = 11;
            app.btnFolder.Position = [14 25 195 22];

            % Create General_Grid
            app.General_Grid = uigridlayout(app.GridLayout);
            app.General_Grid.ColumnWidth = {'1x', 16};
            app.General_Grid.RowHeight = {22, 150, 22, '1x', 17, 22, 1, 22, 15};
            app.General_Grid.RowSpacing = 5;
            app.General_Grid.Padding = [0 0 0 0];
            app.General_Grid.Layout.Row = [2 5];
            app.General_Grid.Layout.Column = 4;
            app.General_Grid.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.General_Grid);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'ASPECTOS GERAIS';

            % Create versionInfo
            app.versionInfo = uilabel(app.General_Grid);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = [2 4];
            app.versionInfo.Layout.Column = [1 2];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create gpuTypeLabel
            app.gpuTypeLabel = uilabel(app.General_Grid);
            app.gpuTypeLabel.VerticalAlignment = 'bottom';
            app.gpuTypeLabel.FontSize = 10;
            app.gpuTypeLabel.FontColor = [0.149 0.149 0.149];
            app.gpuTypeLabel.Layout.Row = 5;
            app.gpuTypeLabel.Layout.Column = [1 2];
            app.gpuTypeLabel.Text = 'Unidade gráfica:';

            % Create gpuType
            app.gpuType = uidropdown(app.General_Grid);
            app.gpuType.Items = {'hardwarebasic', 'hardware', 'software'};
            app.gpuType.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.gpuType.Enable = 'off';
            app.gpuType.FontSize = 11;
            app.gpuType.BackgroundColor = [1 1 1];
            app.gpuType.Layout.Row = 6;
            app.gpuType.Layout.Column = [1 2];
            app.gpuType.Value = 'hardware';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.General_Grid);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.Layout.Row = 8;
            app.openAuxiliarAppAsDocked.Layout.Column = [1 2];

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.General_Grid);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Graphics_ParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.Layout.Row = 9;
            app.openAuxiliarApp2Debug.Layout.Column = [1 2];

            % Create Folders_Grid
            app.Folders_Grid = uigridlayout(app.GridLayout);
            app.Folders_Grid.ColumnWidth = {'1x'};
            app.Folders_Grid.RowHeight = {22, '1x'};
            app.Folders_Grid.RowSpacing = 5;
            app.Folders_Grid.Padding = [0 0 0 0];
            app.Folders_Grid.Layout.Row = [2 5];
            app.Folders_Grid.Layout.Column = 6;
            app.Folders_Grid.BackgroundColor = [1 1 1];

            % Create config_FolderMapLabel
            app.config_FolderMapLabel = uilabel(app.Folders_Grid);
            app.config_FolderMapLabel.VerticalAlignment = 'bottom';
            app.config_FolderMapLabel.FontSize = 10;
            app.config_FolderMapLabel.Layout.Row = 1;
            app.config_FolderMapLabel.Layout.Column = 1;
            app.config_FolderMapLabel.Text = 'MAPEAMENTO DE PASTAS';

            % Create FolderMapPanel
            app.FolderMapPanel = uipanel(app.Folders_Grid);
            app.FolderMapPanel.AutoResizeChildren = 'off';
            app.FolderMapPanel.Layout.Row = 2;
            app.FolderMapPanel.Layout.Column = 1;

            % Create FolderMapGrid
            app.FolderMapGrid = uigridlayout(app.FolderMapPanel);
            app.FolderMapGrid.ColumnWidth = {'1x', 20};
            app.FolderMapGrid.RowHeight = {17, 22, 17, 22, 17, 22, '1x'};
            app.FolderMapGrid.ColumnSpacing = 5;
            app.FolderMapGrid.RowSpacing = 5;
            app.FolderMapGrid.BackgroundColor = [1 1 1];

            % Create DataHubGETLabel
            app.DataHubGETLabel = uilabel(app.FolderMapGrid);
            app.DataHubGETLabel.VerticalAlignment = 'bottom';
            app.DataHubGETLabel.FontSize = 10;
            app.DataHubGETLabel.Layout.Row = 1;
            app.DataHubGETLabel.Layout.Column = 1;
            app.DataHubGETLabel.Text = 'DataHub - GET:';

            % Create DataHubGET
            app.DataHubGET = uieditfield(app.FolderMapGrid, 'text');
            app.DataHubGET.Editable = 'off';
            app.DataHubGET.FontSize = 11;
            app.DataHubGET.Layout.Row = 2;
            app.DataHubGET.Layout.Column = 1;

            % Create DataHubGETButton
            app.DataHubGETButton = uiimage(app.FolderMapGrid);
            app.DataHubGETButton.ImageClickedFcn = createCallbackFcn(app, @Folder_ButtonPushed, true);
            app.DataHubGETButton.Tag = 'DataHub_GET';
            app.DataHubGETButton.Layout.Row = 2;
            app.DataHubGETButton.Layout.Column = 2;
            app.DataHubGETButton.ImageSource = 'OpenFile_36x36.png';

            % Create DataHubPOSTLabel
            app.DataHubPOSTLabel = uilabel(app.FolderMapGrid);
            app.DataHubPOSTLabel.VerticalAlignment = 'bottom';
            app.DataHubPOSTLabel.FontSize = 10;
            app.DataHubPOSTLabel.Layout.Row = 3;
            app.DataHubPOSTLabel.Layout.Column = 1;
            app.DataHubPOSTLabel.Text = 'DataHub - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.FolderMapGrid, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.Layout.Row = 4;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.FolderMapGrid);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Folder_ButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Layout.Row = 4;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.FolderMapGrid);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 5;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'Pasta do usuário:';

            % Create userPath
            app.userPath = uieditfield(app.FolderMapGrid, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.Layout.Row = 6;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.FolderMapGrid);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Folder_ButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Layout.Row = 6;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Create config_Option2Grid
            app.config_Option2Grid = uigridlayout(app.GridLayout);
            app.config_Option2Grid.ColumnWidth = {'1x', 16};
            app.config_Option2Grid.RowHeight = {22, 5, 68, 5, 22, 5, 64, 5, 22, 5, 64, 5, 22, 5, '1x', 1};
            app.config_Option2Grid.RowSpacing = 0;
            app.config_Option2Grid.Padding = [0 0 0 0];
            app.config_Option2Grid.Layout.Row = [2 5];
            app.config_Option2Grid.Layout.Column = 5;
            app.config_Option2Grid.BackgroundColor = [1 1 1];

            % Create config_MiscelaneousLabel1
            app.config_MiscelaneousLabel1 = uilabel(app.config_Option2Grid);
            app.config_MiscelaneousLabel1.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel1.FontSize = 10;
            app.config_MiscelaneousLabel1.Layout.Row = 5;
            app.config_MiscelaneousLabel1.Layout.Column = 1;
            app.config_MiscelaneousLabel1.Text = 'ALGORITMO SUGESTÃO DE TOKENS';

            % Create config_MiscelaneousPanel1
            app.config_MiscelaneousPanel1 = uipanel(app.config_Option2Grid);
            app.config_MiscelaneousPanel1.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel1.Layout.Row = 7;
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
            app.config_nMinWords.Items = {'20', '50', '100'};
            app.config_nMinWords.ValueChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_nMinWords.FontSize = 11;
            app.config_nMinWords.BackgroundColor = [1 1 1];
            app.config_nMinWords.Layout.Row = 2;
            app.config_nMinWords.Layout.Column = 2;
            app.config_nMinWords.Value = '20';

            % Create config_MiscelaneousLabel2
            app.config_MiscelaneousLabel2 = uilabel(app.config_Option2Grid);
            app.config_MiscelaneousLabel2.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel2.FontSize = 10;
            app.config_MiscelaneousLabel2.Layout.Row = 9;
            app.config_MiscelaneousLabel2.Layout.Column = 1;
            app.config_MiscelaneousLabel2.Text = 'ANOTAÇÃO DO TIPO "WORDCLOUD"';

            % Create config_MiscelaneousPanel2
            app.config_MiscelaneousPanel2 = uipanel(app.config_Option2Grid);
            app.config_MiscelaneousPanel2.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel2.Layout.Row = 11;
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
            app.config_SelectedTableColumnsLabel = uilabel(app.config_Option2Grid);
            app.config_SelectedTableColumnsLabel.VerticalAlignment = 'bottom';
            app.config_SelectedTableColumnsLabel.FontSize = 10;
            app.config_SelectedTableColumnsLabel.Layout.Row = 13;
            app.config_SelectedTableColumnsLabel.Layout.Column = 1;
            app.config_SelectedTableColumnsLabel.Text = 'VISIBILIDADE DE COLUNAS';

            % Create config_SelectedTableColumns
            app.config_SelectedTableColumns = uitree(app.config_Option2Grid, 'checkbox');
            app.config_SelectedTableColumns.FontSize = 11;
            app.config_SelectedTableColumns.Layout.Row = 15;
            app.config_SelectedTableColumns.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.config_SelectedTableColumns.CheckedNodesChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);

            % Create config_SearchModeDefaultParameters
            app.config_SearchModeDefaultParameters = uiimage(app.config_Option2Grid);
            app.config_SearchModeDefaultParameters.ScaleMethod = 'none';
            app.config_SearchModeDefaultParameters.ImageClickedFcn = createCallbackFcn(app, @Analysis_DefaultParametersClicked, true);
            app.config_SearchModeDefaultParameters.Tooltip = {'Volta à configuração inicial'};
            app.config_SearchModeDefaultParameters.Layout.Row = 1;
            app.config_SearchModeDefaultParameters.Layout.Column = 2;
            app.config_SearchModeDefaultParameters.VerticalAlignment = 'bottom';
            app.config_SearchModeDefaultParameters.ImageSource = 'Refresh_18.png';

            % Create config_SearchModePanel
            app.config_SearchModePanel = uibuttongroup(app.config_Option2Grid);
            app.config_SearchModePanel.AutoResizeChildren = 'off';
            app.config_SearchModePanel.SelectionChangedFcn = createCallbackFcn(app, @Analysis_ParameterValueChanged, true);
            app.config_SearchModePanel.BackgroundColor = [1 1 1];
            app.config_SearchModePanel.Layout.Row = 3;
            app.config_SearchModePanel.Layout.Column = [1 2];

            % Create config_SearchModeTokenSuggestion
            app.config_SearchModeTokenSuggestion = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeTokenSuggestion.Text = '<p style="text-align:justify; line-height:1.1;">Pesquisa orientada à palavra que está sendo escrita, sugerindo <i>tokens</i> relacionados.</p>';
            app.config_SearchModeTokenSuggestion.WordWrap = 'on';
            app.config_SearchModeTokenSuggestion.FontSize = 11;
            app.config_SearchModeTokenSuggestion.Interpreter = 'html';
            app.config_SearchModeTokenSuggestion.Position = [10 33 840 29];
            app.config_SearchModeTokenSuggestion.Value = true;

            % Create config_SearchModeListOfWords
            app.config_SearchModeListOfWords = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeListOfWords.Text = '<p style="text-align:justify; line-height:1.1;">Pesquisa orientada à uma lista de palavras separadas por vírgulas. Não há sugestão de <i>tokens</i> relacionados.</p>';
            app.config_SearchModeListOfWords.WordWrap = 'on';
            app.config_SearchModeListOfWords.FontSize = 11;
            app.config_SearchModeListOfWords.Interpreter = 'html';
            app.config_SearchModeListOfWords.Position = [11 4 837 34];

            % Create config_SearchModeLabel
            app.config_SearchModeLabel = uilabel(app.config_Option2Grid);
            app.config_SearchModeLabel.VerticalAlignment = 'bottom';
            app.config_SearchModeLabel.FontSize = 10;
            app.config_SearchModeLabel.Layout.Row = 1;
            app.config_SearchModeLabel.Layout.Column = 1;
            app.config_SearchModeLabel.Text = 'MODO';

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
