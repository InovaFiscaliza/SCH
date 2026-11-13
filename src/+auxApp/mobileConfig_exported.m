classdef mobileConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        FiscalizaPanel            matlab.ui.container.Panel
        FiscalizaGrid             matlab.ui.container.GridLayout
        FileCompressionMode       matlab.ui.control.DropDown
        FileCompressionModeLabel  matlab.ui.control.Label
        MacrothemesList           matlab.ui.control.EditField
        MacrothemesButton         matlab.ui.control.Image
        MacrothemesLabel          matlab.ui.control.Label
        FiscalizaRefreshButton    matlab.ui.control.Image
        FiscalizaLabel            matlab.ui.control.Label
        SearchPanel               matlab.ui.container.Panel
        SearchGrid                matlab.ui.container.GridLayout
        NumMinWords               matlab.ui.control.DropDown
        NumMinWordsLabel          matlab.ui.control.Label
        NumMinCharacters          matlab.ui.control.Spinner
        NumMinCharactersLabel     matlab.ui.control.Label
        SearchRefreshButton       matlab.ui.control.Image
        SearchLabel               matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryAppMobile'
        Context = 'CONFIG'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        jsBackDoor

        mainApp
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        defaultValues
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)
                        
                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.SearchPanel;
                app.FiscalizaPanel;
                app.NumMinCharacters;
                app.NumMinWords;
                app.MacrothemesList;
                app.FileCompressionMode
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);
    
            try
                sendEventToHTMLSource(app.mainApp.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.SearchPanel.UserData.id, 'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.FiscalizaPanel.UserData.id,           'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.NumMinCharacters.UserData.id,     'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.NumMinWords.UserData.id,          'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.MacrothemesList.UserData.id,           'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.FileCompressionMode.UserData.id,    'generation', 1, 'style', struct('borderColor', '#AEBBC2')) ...
                });
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder   = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath = fullfile(projectFolder, 'GeneralSettings.json');
            projectGeneral  = jsondecode(fileread(projectFilePath));

            app.defaultValues = struct( ...
                'ANALYSIS', struct( ...
                    'minCharacters', projectGeneral.context.SEARCH.minCharacters, ...
                    'minDisplayedTokens', projectGeneral.context.SEARCH.minDisplayedTokens ...
                ), ...
                'REPORT', struct( ...
                    'allowedMacrothemes', {projectGeneral.reportLib.allowedMacrothemes}, ...
                    'outputCompressionMode', projectGeneral.reportLib.outputCompressionMode ...
                ) ...
            );
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            set([app.SearchPanel, app.FiscalizaPanel], 'BorderColor', '#D5DDE1')
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updatePanel(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel(app)
            app.NumMinCharacters.Value = app.mainApp.General.context.SEARCH.minCharacters;

            numDisplayedTokens = num2str(app.mainApp.General.context.SEARCH.minDisplayedTokens);
            if ismember(numDisplayedTokens, app.NumMinWords.Items)
                app.NumMinWords.Value = numDisplayedTokens;
            end

            app.MacrothemesButton.UserData.status = false;
            app.MacrothemesButton.ImageSource = 'Edit_32.png';
            set(app.MacrothemesList, 'Editable', 'off', 'FontColor', [0.65,0.65,0.65], 'Value', textFormatGUI.cellstr2ListWithQuotes(app.mainApp.General.reportLib.allowedMacrothemes, 'none'))

            if ismember(app.mainApp.General.reportLib.outputCompressionMode, app.FileCompressionMode.Items)
                app.FileCompressionMode.Value = app.mainApp.General.reportLib.outputCompressionMode;
            end

            app.SearchRefreshButton.Visible = checkEdition(app, 'ANALYSIS');
            app.FiscalizaRefreshButton.Visible = checkEdition(app, 'REPORT');
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app, fieldName)
            editionFlag = false;
            currentValues = struct( ...
                'ANALYSIS', struct( ...
                    'minCharacters', app.mainApp.General.context.SEARCH.minCharacters, ...
                    'minDisplayedTokens', app.mainApp.General.context.SEARCH.minDisplayedTokens ...
                ), ...
                'REPORT', struct( ...
                    'allowedMacrothemes', {app.mainApp.General.reportLib.allowedMacrothemes}, ...
                    'outputCompressionMode', app.mainApp.General.reportLib.outputCompressionMode ...
                ) ...
            );

            if ~isequal(currentValues.(fieldName), app.defaultValues.(fieldName))
                editionFlag = true;
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
            
            delete(app)
            
        end

        % Image clicked function: FiscalizaRefreshButton, 
        % ...and 1 other component
        function onRefreshButtonClicked(app, event)
            
            projectFolder   = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath = fullfile(projectFolder, 'GeneralSettings.json');
            projectGeneral  = jsondecode(fileread(projectFilePath));

            switch event.Source
                case app.SearchRefreshButton
                    app.mainApp.General.context.SEARCH = projectGeneral.context.SEARCH;
                    app.mainApp.General_I.context.SEARCH = app.mainApp.General.context.SEARCH;

                case app.FiscalizaRefreshButton
                    app.mainApp.General.reportLib.allowedMacrothemes = app.defaultValues.REPORT.allowedMacrothemes;
                    app.mainApp.General.reportLib.outputCompressionMode = app.defaultValues.REPORT.outputCompressionMode;
                    app.mainApp.General_I.reportLib = app.mainApp.General.reportLib;
            end

            updatePanel(app)
            saveGeneralSettings(app)

        end

        % Value changed function: NumMinCharacters, NumMinWords
        function onSearchParameterValueChanged(app, event)
            
            switch event.Source
                case app.NumMinCharacters
                    app.mainApp.General.context.SEARCH.minCharacters = app.NumMinCharacters.Value;

                case app.NumMinWords
                    app.mainApp.General.context.SEARCH.minDisplayedTokens = str2double(app.NumMinWords.Value);
            end

            app.mainApp.General_I.context.SEARCH = app.mainApp.General.context.SEARCH;
            
            updatePanel(app)
            saveGeneralSettings(app)

        end

        % Callback function: MacrothemesButton, MacrothemesList
        function onMacrothemeListChanged(app, event)
            
            switch event.Source
                case app.MacrothemesButton
                    app.MacrothemesButton.UserData.status = ~app.MacrothemesButton.UserData.status;
                    if app.MacrothemesButton.UserData.status
                        app.MacrothemesButton.ImageSource = 'Edit_32Filled.png';
                        set(app.MacrothemesList, 'Editable', 'on', 'FontColor', [0,0,0])
                    else
                        app.MacrothemesButton.ImageSource = 'Edit_32.png';
                        set(app.MacrothemesList, 'Editable', 'off', 'FontColor', [0.65,0.65,0.65])
                    end

                case app.MacrothemesList
                    parts = strsplit(event.Value, ',');
                    try
                        requiredMacrothemes = unique(strtrim(extractBetween(parts, '"', '"')));
                    catch
                        app.MacrothemesList.Value = event.PreviousValue;
                        return
                    end

                    currentMacrothemes = sort(app.mainApp.General.reportLib.allowedMacrothemes);

                    if numel(requiredMacrothemes) ~= numel(parts) || isequal(currentMacrothemes, requiredMacrothemes)
                        app.MacrothemesList.Value = event.PreviousValue;
                        return
                    end

                    msgQuestion = sprintf([ ...
                        'LISTA ATUAL:\n%s\n\nLISTA PROPOSTA:\n%s\n\n' ...
                        'Confirma a troca da lista de macrotemas?' ...
                    ], textFormatGUI.cellstr2ListWithQuotes(currentMacrothemes, 'none'), textFormatGUI.cellstr2ListWithQuotes(requiredMacrothemes, 'none'));

                    userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                    if userSelection == "Não"
                        app.MacrothemesList.Value = event.PreviousValue;
                        return
                    end

                    app.mainApp.General.reportLib.allowedMacrothemes = requiredMacrothemes;
                    app.mainApp.General_I.reportLib = app.mainApp.General.reportLib;

                    updatePanel(app)
                    saveGeneralSettings(app)
            end

        end

        % Value changed function: FileCompressionMode
        function onCompressionModeValueChanged(app, event)
            
            app.mainApp.General.reportLib.outputCompressionMode = event.Value;
            app.mainApp.General_I.reportLib = app.mainApp.General.reportLib;

            updatePanel(app)
            saveGeneralSettings(app)
            
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
                app.UIFigure.Position = [100 100 387 754];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_32.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

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
            app.GridLayout.ColumnWidth = {'1x', 22};
            app.GridLayout.RowHeight = {22, 158, 1, 22, '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [10 10 10 42];
            app.GridLayout.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create SearchLabel
            app.SearchLabel = uilabel(app.GridLayout);
            app.SearchLabel.VerticalAlignment = 'bottom';
            app.SearchLabel.FontWeight = 'bold';
            app.SearchLabel.FontColor = [0 0.1294 0.2392];
            app.SearchLabel.Layout.Row = 1;
            app.SearchLabel.Layout.Column = 1;
            app.SearchLabel.Text = 'Algoritmo de sugestão de tokens';

            % Create SearchRefreshButton
            app.SearchRefreshButton = uiimage(app.GridLayout);
            app.SearchRefreshButton.ScaleMethod = 'none';
            app.SearchRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onRefreshButtonClicked, true);
            app.SearchRefreshButton.Visible = 'off';
            app.SearchRefreshButton.Layout.Row = 1;
            app.SearchRefreshButton.Layout.Column = 2;
            app.SearchRefreshButton.ImageSource = 'Refresh_18.png';

            % Create SearchPanel
            app.SearchPanel = uipanel(app.GridLayout);
            app.SearchPanel.AutoResizeChildren = 'off';
            app.SearchPanel.Layout.Row = 2;
            app.SearchPanel.Layout.Column = [1 2];

            % Create SearchGrid
            app.SearchGrid = uigridlayout(app.SearchPanel);
            app.SearchGrid.ColumnWidth = {130, '1x'};
            app.SearchGrid.RowHeight = {22, 38, 22, 38};
            app.SearchGrid.RowSpacing = 5;
            app.SearchGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create NumMinCharactersLabel
            app.NumMinCharactersLabel = uilabel(app.SearchGrid);
            app.NumMinCharactersLabel.VerticalAlignment = 'bottom';
            app.NumMinCharactersLabel.FontColor = [0 0.1294 0.2392];
            app.NumMinCharactersLabel.Layout.Row = 1;
            app.NumMinCharactersLabel.Layout.Column = [1 2];
            app.NumMinCharactersLabel.Text = 'Qtd. mínima de caracteres para ativar sugestões:';

            % Create NumMinCharacters
            app.NumMinCharacters = uispinner(app.SearchGrid);
            app.NumMinCharacters.Limits = [2 4];
            app.NumMinCharacters.RoundFractionalValues = 'on';
            app.NumMinCharacters.ValueDisplayFormat = '%d';
            app.NumMinCharacters.ValueChangedFcn = createCallbackFcn(app, @onSearchParameterValueChanged, true);
            app.NumMinCharacters.FontColor = [0 0.1294 0.2392];
            app.NumMinCharacters.Layout.Row = 2;
            app.NumMinCharacters.Layout.Column = 1;
            app.NumMinCharacters.Value = 2;

            % Create NumMinWordsLabel
            app.NumMinWordsLabel = uilabel(app.SearchGrid);
            app.NumMinWordsLabel.VerticalAlignment = 'bottom';
            app.NumMinWordsLabel.FontColor = [0 0.1294 0.2392];
            app.NumMinWordsLabel.Layout.Row = 3;
            app.NumMinWordsLabel.Layout.Column = [1 2];
            app.NumMinWordsLabel.Text = 'Qtd. mínima de sugestões apresentadas para seleção:';

            % Create NumMinWords
            app.NumMinWords = uidropdown(app.SearchGrid);
            app.NumMinWords.Items = {'20', '50'};
            app.NumMinWords.ValueChangedFcn = createCallbackFcn(app, @onSearchParameterValueChanged, true);
            app.NumMinWords.FontColor = [0 0.1294 0.2392];
            app.NumMinWords.BackgroundColor = [1 1 1];
            app.NumMinWords.Layout.Row = 4;
            app.NumMinWords.Layout.Column = 1;
            app.NumMinWords.Value = '20';

            % Create FiscalizaLabel
            app.FiscalizaLabel = uilabel(app.GridLayout);
            app.FiscalizaLabel.VerticalAlignment = 'bottom';
            app.FiscalizaLabel.FontWeight = 'bold';
            app.FiscalizaLabel.FontColor = [0 0.1294 0.2392];
            app.FiscalizaLabel.Layout.Row = 4;
            app.FiscalizaLabel.Layout.Column = 1;
            app.FiscalizaLabel.Text = 'eFiscaliza';

            % Create FiscalizaRefreshButton
            app.FiscalizaRefreshButton = uiimage(app.GridLayout);
            app.FiscalizaRefreshButton.ScaleMethod = 'none';
            app.FiscalizaRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onRefreshButtonClicked, true);
            app.FiscalizaRefreshButton.Visible = 'off';
            app.FiscalizaRefreshButton.Layout.Row = 4;
            app.FiscalizaRefreshButton.Layout.Column = 2;
            app.FiscalizaRefreshButton.ImageSource = 'Refresh_18.png';

            % Create FiscalizaPanel
            app.FiscalizaPanel = uipanel(app.GridLayout);
            app.FiscalizaPanel.AutoResizeChildren = 'off';
            app.FiscalizaPanel.Layout.Row = 5;
            app.FiscalizaPanel.Layout.Column = [1 2];

            % Create FiscalizaGrid
            app.FiscalizaGrid = uigridlayout(app.FiscalizaPanel);
            app.FiscalizaGrid.ColumnWidth = {130, '1x', 22};
            app.FiscalizaGrid.RowHeight = {22, 38, 22, 38};
            app.FiscalizaGrid.RowSpacing = 5;
            app.FiscalizaGrid.BackgroundColor = [0.9686 0.9765 0.9804];

            % Create MacrothemesLabel
            app.MacrothemesLabel = uilabel(app.FiscalizaGrid);
            app.MacrothemesLabel.VerticalAlignment = 'bottom';
            app.MacrothemesLabel.FontColor = [0 0.1294 0.2392];
            app.MacrothemesLabel.Layout.Row = 1;
            app.MacrothemesLabel.Layout.Column = [1 2];
            app.MacrothemesLabel.Text = 'Macrotemas aceitos para fins de elaboração do relato:';

            % Create MacrothemesButton
            app.MacrothemesButton = uiimage(app.FiscalizaGrid);
            app.MacrothemesButton.ImageClickedFcn = createCallbackFcn(app, @onMacrothemeListChanged, true);
            app.MacrothemesButton.Layout.Row = 1;
            app.MacrothemesButton.Layout.Column = 3;
            app.MacrothemesButton.VerticalAlignment = 'bottom';
            app.MacrothemesButton.ImageSource = 'Edit_32.png';

            % Create MacrothemesList
            app.MacrothemesList = uieditfield(app.FiscalizaGrid, 'text');
            app.MacrothemesList.ValueChangedFcn = createCallbackFcn(app, @onMacrothemeListChanged, true);
            app.MacrothemesList.Editable = 'off';
            app.MacrothemesList.FontColor = [0.651 0.651 0.651];
            app.MacrothemesList.Layout.Row = 2;
            app.MacrothemesList.Layout.Column = [1 3];

            % Create FileCompressionModeLabel
            app.FileCompressionModeLabel = uilabel(app.FiscalizaGrid);
            app.FileCompressionModeLabel.VerticalAlignment = 'bottom';
            app.FileCompressionModeLabel.Layout.Row = 3;
            app.FileCompressionModeLabel.Layout.Column = [1 3];
            app.FileCompressionModeLabel.Text = 'Compressão aplicada ao arquivo de saída do projeto?';

            % Create FileCompressionMode
            app.FileCompressionMode = uidropdown(app.FiscalizaGrid);
            app.FileCompressionMode.Items = {'Não', 'Sim'};
            app.FileCompressionMode.ValueChangedFcn = createCallbackFcn(app, @onCompressionModeValueChanged, true);
            app.FileCompressionMode.BackgroundColor = [1 1 1];
            app.FileCompressionMode.Layout.Row = 4;
            app.FileCompressionMode.Layout.Column = 1;
            app.FileCompressionMode.Value = 'Sim';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobileConfig_exported(Container, varargin)

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
