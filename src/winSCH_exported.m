classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure    matlab.ui.Figure
        GridLayout  matlab.ui.container.GridLayout
        Log         matlab.ui.control.Label
        jsBackDoor  matlab.ui.control.HTML
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'launcher'
    end


    properties
        %-----------------------------------------------------------------%
        mainApp
        rootFolder
        renderCount = 0
        
        navigatorBasicInformation
        executionMode = ''
        isMobile = []
        
        progressDialog

        General_I
        schData
        schDataCategories
        releasedData
        cacheData
        cacheColumns
        annotationTable
    end


    methods
        %-----------------------------------------------------------------%
        function ipcLauncherJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    % MATLAB-JS BRIDGE (matlabJSBridge.js)
                    case 'renderer'
                        MFilePath   = fileparts(mfilename('fullpath'));
                        parpoolFlag = true;

                        updateLog(app, 'Iniciando sessão do SCH...')
                        if parpoolFlag
                            updateLog(app, 'Inicializando workers para execução de operações em paralelo...')
                        end

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        else
                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        end

                        app.navigatorBasicInformation = event.HTMLEventData;
                        if isempty(app.isMobile)
                            app.isMobile = app.navigatorBasicInformation.mobile;
                        end
                        
                        app.renderCount = app.renderCount+1;

                        if isempty(app.mainApp) || ~isvalid(app.mainApp)
                            startMainApp(app)
                        end
                        ipcMainJSEventsHandler(app.mainApp, event)
    
                    case 'unload'
                        closeFcn(app)
    
                    otherwise
                        if isempty(app.mainApp) || ~isvalid(app.mainApp)
                            error('winSCH:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
                        end
                        ipcMainJSEventsHandler(app.mainApp, event)
                end
                drawnow

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function loadConfigurationFile(app, MFilePath)
            updateLog(app, 'Lendo arquivo de configuração "GeneralSettings.json"...')

            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appEngine.util.generalSettingsLoad(class.Constants.appName, app.rootFolder, {'Annotation.xlsx'});
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
        end

        %-----------------------------------------------------------------%
        function readDataBaseExternalFiles(app, generalSettings)
            if nargin < 2
                generalSettings = app.General_I;
            end

            updateLog(app, 'Lendo bases de dados de referência do SCH e Regulatron...')

            [app.schData, ...
             app.schDataCategories, ...
             app.releasedData, ...
             app.cacheData, ...
             app.cacheColumns]  = util.readExternalFile.SCHData(app.rootFolder, generalSettings.fileFolder.DataHub_GET, generalSettings);
            app.annotationTable = util.readExternalFile.Annotation(app.rootFolder, generalSettings.fileFolder.DataHub_GET);
        end

        %-----------------------------------------------------------------%
        function updateLog(app, msg)
            if ~isvalid(app.Log)
                return
            end

            if isempty(app.Log.Text)
                app.Log.Text = msg;
            else
                app.Log.Text = sprintf('%s\n%s', app.Log.Text, msg);
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function startMainApp(app)
            requestVisibilityChange(app.progressDialog, 'visible', 'locked')

            loadConfigurationFile(app, fileparts(mfilename('fullpath')))
            readDataBaseExternalFiles(app)

            if app.isMobile
                app.UIFigure.Position(3:4) = [393, 852];
                app.mainApp = mainApp.mobile_exported(app.UIFigure, app);
            else
                app.UIFigure.Position(3:4) = [1244, 660];
                app.mainApp = mainApp.desktop_exported(app.UIFigure, app);
            end

            requestVisibilityChange(app.progressDialog, 'visible', 'locked')
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            
            try
                if nargin > 1 && islogical(varargin{1})
                    app.isMobile = varargin{1};
                end

                appEngine.boot(app, app.Role)

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
 
            if ~isempty(app.mainApp) && isvalid(app.mainApp)
                ipcMainJSEventsHandler(app.mainApp, struct('Source', app.UIFigure, 'EventName', 'Close', 'HTMLEventName', 'unload'))

                % Mantém a figura se o mainApp não foi encerrado (usuário cancelou).
                if isvalid(app.mainApp)
                    return
                end
            end

            delete(app)

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
            app.UIFigure.Color = [0.9608 0.9686 0.9686];
            app.UIFigure.Position = [100 100 1244 660];
            app.UIFigure.Name = 'SCH';
            app.UIFigure.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'icon_32.png');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.UIFigure);
            app.jsBackDoor.Visible = 'off';
            app.jsBackDoor.Position = [408 603 28 56];

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [0.1294 0.2 0.2392];

            % Create Log
            app.Log = uilabel(app.GridLayout);
            app.Log.VerticalAlignment = 'bottom';
            app.Log.WordWrap = 'on';
            app.Log.FontColor = [1 1 1];
            app.Log.Layout.Row = 1;
            app.Log.Layout.Column = 1;
            app.Log.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winSCH_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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
