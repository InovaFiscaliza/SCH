classdef dockCustomsAnalysisDetails_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        Button                      matlab.ui.control.Button
        EditionPanel                matlab.ui.container.Panel
        EditionGrid                 matlab.ui.container.GridLayout
        Note                        matlab.ui.control.TextArea
        NoteLabel                   matlab.ui.control.Label
        FinalDestinationGrid        matlab.ui.container.ButtonGroup
        UniqueDestination           matlab.ui.control.DropDown
        SetUniqueDestination        matlab.ui.control.RadioButton
        ImportSuggestedDestination  matlab.ui.control.RadioButton
        FinalDestinationLabel       matlab.ui.control.Label
        EditionLabel                matlab.ui.control.Label
        SummaryPanel                matlab.ui.container.Panel
        SummaryGrid                 matlab.ui.container.GridLayout
        CardText5                   matlab.ui.control.Label
        CardImage5                  matlab.ui.control.Image
        CardText4                   matlab.ui.control.Label
        CardImage4                  matlab.ui.control.Image
        CardText3                   matlab.ui.control.Label
        CardImage3                  matlab.ui.control.Image
        CardText2                   matlab.ui.control.Label
        CardImage2                  matlab.ui.control.Image
        CardInfo1                   matlab.ui.control.Label
        CardImage1                  matlab.ui.control.Image
        SummaryLabel                matlab.ui.control.Label
        Title                       matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true        
        mainApp
        callingApp
        jsBackDoor
        progressDialog
        projectData
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updateForm(app, customsShipmentsIdx, customsDataIdxs)
            customsData = app.projectData.customsShipments(customsShipmentsIdx).Data(customsDataIdxs, :);

            app.CardInfo1.Text = sprintf('<font style="color: gray; font-size: 10px;">Registros selecionados</font><br><b>%d</b>', numel(customsDataIdxs));
            app.CardText2.Text = sprintf('<font style="color: gray; font-size: 10px;">Importadores únicos</font><br><b>%d</b>', numel(unique(customsData.("remessaImportador"))));
            app.CardText3.Text = sprintf('<font style="color: gray; font-size: 10px;">Destinações sugeridas</font><br><b>%s</b>', summarizeCategoryCounts(app, customsData.("regraDecisaoSugerida")));
            app.CardText4.Text = sprintf('<font style="color: gray; font-size: 10px;">Destinações finais</font><br><b>%s</b>', summarizeCategoryCounts(app, customsData.("auditorDecisaoFinal")));
            app.CardText5.Text = sprintf('<font style="color: gray; font-size: 10px;">Palavras-chaves encontradas</font><br><b>%s</b>', summarizeFoundKeywords(app, customsData.("regraPalavrasEncontradas")));
        end

        %-----------------------------------------------------------------%
        function summary = summarizeCategoryCounts(~, categoricalColumn)
            % Resume uma coluna categórica em "Categoria1 (N1), Categoria2 (N2) e Categoria3 (N3)",
            % ordenada da mais para a menos frequente e ignorando categorias sem ocorrências.
            categoricalColumn = removecats(categoricalColumn(~ismissing(categoricalColumn)));
            labels = categories(categoricalColumn);
            counts = countcats(categoricalColumn);

            [counts, sortOrder] = sort(counts, 'descend');
            labels = labels(sortOrder);

            keepIdxs = counts > 0;
            labels = labels(keepIdxs);
            counts = counts(keepIdxs);

            entries = arrayfun(@(ii) sprintf('%s (%d)', labels{ii}, counts(ii)), 1:numel(labels), 'UniformOutput', false);

            if numel(entries) > 1
                summary = [strjoin(entries(1:end-1), ', '), ' e ', entries{end}];
            else
                summary = char(entries);
            end
        end

        %-----------------------------------------------------------------%
        function summary = summarizeFoundKeywords(~, rawKeywordCells)
            matches = regexp(strjoin(rawKeywordCells), '"([^"]*)"', 'tokens');
            keywords = unique(vertcat(matches{:}));

            if isempty(keywords)
                summary = '-';
                return
            end
            
            summary = textFormatGUI.cellstr2FriendlyListWithQuotes(keywords);
            
            if numel(summary) > 150
                delimiterIdxs = strfind(summary(1:150), '", ');
                if ~isempty(delimiterIdxs)
                    summary = [summary(1:delimiterIdxs(end)), ' ...'];
                else
                    summary = [summary(1:150), ' ...'];
                end
            end
        end

        %-----------------------------------------------------------------%
        function text = normalizeText(~, text)
            if ~iscellstr(text)
                text = cellstr(text);
            end
            text = regexprep(text, '\s+', ' ');
            text = strtrim(text);
            text(cellfun(@isempty, text)) = [];
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, customsShipmentsIdx, customsDataIdxs)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('customsShipmentsIdx', customsShipmentsIdx, 'customsDataIdxs', customsDataIdxs');
                updateForm(app, customsShipmentsIdx, customsDataIdxs)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end            
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            delete(app)
            
        end

        % Selection changed function: FinalDestinationGrid
        function onDestinationOptionChanged(app, event)
            
            switch app.FinalDestinationGrid.SelectedObject
                case app.ImportSuggestedDestination
                    set(app.UniqueDestination, 'Enable', 'off', 'Items', {})
                
                otherwise % app.UniqueDestination
                    set(app.UniqueDestination, 'Enable', 'on', 'Items', [{''}; app.mainApp.General.context.CUSTOMS.auditorDecisaoFinal.options])
            end
            
        end

        % Button pushed function: Button
        function onButtonPushed(app, event)
            
            customsShipmentsIdx = app.inputArgs.customsShipmentsIdx;
            customsDataIdxs = app.inputArgs.customsDataIdxs;
            customsData = app.projectData.customsShipments(customsShipmentsIdx).Data(customsDataIdxs, :);

            switch app.FinalDestinationGrid.SelectedObject
                case app.ImportSuggestedDestination
                    auditorDecisaoFinal = customsData.("regraDecisaoSugerida");

                otherwise % app.UniqueDestination
                    auditorDecisaoFinal = repmat(categorical(string(app.UniqueDestination.Value)), numel(customsDataIdxs), 1);
            end

            auditorNota = normalizeText(app, app.Note.Value);
            auditorNota = strjoin(auditorNota, ' ');

            updateCustomsShipments(app.projectData, 'annotationBatchEdit', customsShipmentsIdx, customsDataIdxs, auditorDecisaoFinal, auditorNota)
            updateForm(app, customsShipmentsIdx, customsDataIdxs)
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onCustomsShipmentsTableChanged')

        end

        % Value changed function: Note
        function NoteValueChanged(app, event)
            
            auditorNota = normalizeText(app, app.Note.Value);

            if ~isequal(app.Note.Value, auditorNota)
                app.Note.Value = auditorNota;
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
                app.UIFigure.Position = [100 100 598 592];
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
            app.GridLayout.ColumnWidth = {'1x', 110};
            app.GridLayout.RowHeight = {40, 22, 168, 22, 246, 1, 24};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.VerticalAlignment = 'top';
            app.Title.WordWrap = 'on';
            app.Title.FontSize = 15;
            app.Title.FontColor = [0 0.4471 0.7412];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = [1 2];
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Edição em lote de registros</b>'; '<font style="color: gray; font-size: 10px;">As alterações realizadas abaixo serão aplicadas a todos os registros selecionados</font>'};

            % Create SummaryLabel
            app.SummaryLabel = uilabel(app.GridLayout);
            app.SummaryLabel.VerticalAlignment = 'bottom';
            app.SummaryLabel.FontSize = 11;
            app.SummaryLabel.FontWeight = 'bold';
            app.SummaryLabel.FontColor = [0 0.4471 0.7412];
            app.SummaryLabel.Layout.Row = 2;
            app.SummaryLabel.Layout.Column = 1;
            app.SummaryLabel.Text = 'Resumo dos registros selecionados';

            % Create SummaryPanel
            app.SummaryPanel = uipanel(app.GridLayout);
            app.SummaryPanel.AutoResizeChildren = 'off';
            app.SummaryPanel.Layout.Row = 3;
            app.SummaryPanel.Layout.Column = [1 2];

            % Create SummaryGrid
            app.SummaryGrid = uigridlayout(app.SummaryPanel);
            app.SummaryGrid.ColumnWidth = {26, '1x', 26, '1x'};
            app.SummaryGrid.RowHeight = {'1x', '1x', '1x'};
            app.SummaryGrid.BackgroundColor = [1 1 1];

            % Create CardImage1
            app.CardImage1 = uiimage(app.SummaryGrid);
            app.CardImage1.Enable = 'off';
            app.CardImage1.Layout.Row = 1;
            app.CardImage1.Layout.Column = 1;
            app.CardImage1.ImageSource = 'repo-selected.svg';

            % Create CardInfo1
            app.CardInfo1 = uilabel(app.SummaryGrid);
            app.CardInfo1.WordWrap = 'on';
            app.CardInfo1.FontColor = [0 0.4471 0.7412];
            app.CardInfo1.Layout.Row = 1;
            app.CardInfo1.Layout.Column = 2;
            app.CardInfo1.Interpreter = 'html';
            app.CardInfo1.Text = '';

            % Create CardImage2
            app.CardImage2 = uiimage(app.SummaryGrid);
            app.CardImage2.Enable = 'off';
            app.CardImage2.Layout.Row = 1;
            app.CardImage2.Layout.Column = 3;
            app.CardImage2.ImageSource = 'globe.svg';

            % Create CardText2
            app.CardText2 = uilabel(app.SummaryGrid);
            app.CardText2.WordWrap = 'on';
            app.CardText2.FontColor = [0 0.4471 0.7412];
            app.CardText2.Layout.Row = 1;
            app.CardText2.Layout.Column = 4;
            app.CardText2.Interpreter = 'html';
            app.CardText2.Text = '';

            % Create CardImage3
            app.CardImage3 = uiimage(app.SummaryGrid);
            app.CardImage3.Enable = 'off';
            app.CardImage3.Layout.Row = 2;
            app.CardImage3.Layout.Column = 1;
            app.CardImage3.ImageSource = 'check.svg';

            % Create CardText3
            app.CardText3 = uilabel(app.SummaryGrid);
            app.CardText3.WordWrap = 'on';
            app.CardText3.FontSize = 11;
            app.CardText3.FontColor = [0 0.4471 0.7412];
            app.CardText3.Layout.Row = 2;
            app.CardText3.Layout.Column = 2;
            app.CardText3.Interpreter = 'html';
            app.CardText3.Text = '';

            % Create CardImage4
            app.CardImage4 = uiimage(app.SummaryGrid);
            app.CardImage4.Enable = 'off';
            app.CardImage4.Layout.Row = 2;
            app.CardImage4.Layout.Column = 3;
            app.CardImage4.ImageSource = 'check-all.svg';

            % Create CardText4
            app.CardText4 = uilabel(app.SummaryGrid);
            app.CardText4.WordWrap = 'on';
            app.CardText4.FontSize = 11;
            app.CardText4.FontColor = [0 0.4471 0.7412];
            app.CardText4.Layout.Row = 2;
            app.CardText4.Layout.Column = 4;
            app.CardText4.Interpreter = 'html';
            app.CardText4.Text = '';

            % Create CardImage5
            app.CardImage5 = uiimage(app.SummaryGrid);
            app.CardImage5.Enable = 'off';
            app.CardImage5.Layout.Row = 3;
            app.CardImage5.Layout.Column = 1;
            app.CardImage5.ImageSource = 'replace-all.svg';

            % Create CardText5
            app.CardText5 = uilabel(app.SummaryGrid);
            app.CardText5.WordWrap = 'on';
            app.CardText5.FontSize = 11;
            app.CardText5.FontColor = [0 0.4471 0.7412];
            app.CardText5.Layout.Row = 3;
            app.CardText5.Layout.Column = [2 4];
            app.CardText5.Interpreter = 'html';
            app.CardText5.Text = '';

            % Create EditionLabel
            app.EditionLabel = uilabel(app.GridLayout);
            app.EditionLabel.VerticalAlignment = 'bottom';
            app.EditionLabel.FontSize = 11;
            app.EditionLabel.FontWeight = 'bold';
            app.EditionLabel.FontColor = [0 0.4471 0.7412];
            app.EditionLabel.Layout.Row = 4;
            app.EditionLabel.Layout.Column = 1;
            app.EditionLabel.Text = 'Campos editáveis';

            % Create EditionPanel
            app.EditionPanel = uipanel(app.GridLayout);
            app.EditionPanel.AutoResizeChildren = 'off';
            app.EditionPanel.Layout.Row = 5;
            app.EditionPanel.Layout.Column = [1 2];

            % Create EditionGrid
            app.EditionGrid = uigridlayout(app.EditionPanel);
            app.EditionGrid.ColumnWidth = {'1x'};
            app.EditionGrid.RowHeight = {17, 126, 22, 44};
            app.EditionGrid.RowSpacing = 5;
            app.EditionGrid.BackgroundColor = [1 1 1];

            % Create FinalDestinationLabel
            app.FinalDestinationLabel = uilabel(app.EditionGrid);
            app.FinalDestinationLabel.VerticalAlignment = 'bottom';
            app.FinalDestinationLabel.FontSize = 11;
            app.FinalDestinationLabel.FontWeight = 'bold';
            app.FinalDestinationLabel.FontColor = [0 0.4471 0.7412];
            app.FinalDestinationLabel.Layout.Row = 1;
            app.FinalDestinationLabel.Layout.Column = 1;
            app.FinalDestinationLabel.Text = 'Destinação final';

            % Create FinalDestinationGrid
            app.FinalDestinationGrid = uibuttongroup(app.EditionGrid);
            app.FinalDestinationGrid.AutoResizeChildren = 'off';
            app.FinalDestinationGrid.SelectionChangedFcn = createCallbackFcn(app, @onDestinationOptionChanged, true);
            app.FinalDestinationGrid.BackgroundColor = [1 1 1];
            app.FinalDestinationGrid.Layout.Row = 2;
            app.FinalDestinationGrid.Layout.Column = 1;

            % Create ImportSuggestedDestination
            app.ImportSuggestedDestination = uiradiobutton(app.FinalDestinationGrid);
            app.ImportSuggestedDestination.Text = {'Importar a destinação sugerida pelo algoritmo'; '<font style="color: gray; font-size: 10px;">Será atribuída a cada registro a destinação sugerida pelo algoritmo.</font>'};
            app.ImportSuggestedDestination.FontSize = 11;
            app.ImportSuggestedDestination.Interpreter = 'html';
            app.ImportSuggestedDestination.Position = [11 83 433 29];
            app.ImportSuggestedDestination.Value = true;

            % Create SetUniqueDestination
            app.SetUniqueDestination = uiradiobutton(app.FinalDestinationGrid);
            app.SetUniqueDestination.Text = {'Definir uma única destinação para todos os registros'; '<font style="color: gray; font-size: 10px;">Selecione abaixo a destinação final que será aplicada a todos os registros selecionados.</font>'; ''};
            app.SetUniqueDestination.FontSize = 11;
            app.SetUniqueDestination.Interpreter = 'html';
            app.SetUniqueDestination.Position = [13 42 423 29];

            % Create UniqueDestination
            app.UniqueDestination = uidropdown(app.FinalDestinationGrid);
            app.UniqueDestination.Items = {};
            app.UniqueDestination.Enable = 'off';
            app.UniqueDestination.FontSize = 11;
            app.UniqueDestination.BackgroundColor = [1 1 1];
            app.UniqueDestination.Position = [32 12 220 22];
            app.UniqueDestination.Value = {};

            % Create NoteLabel
            app.NoteLabel = uilabel(app.EditionGrid);
            app.NoteLabel.VerticalAlignment = 'bottom';
            app.NoteLabel.FontSize = 11;
            app.NoteLabel.FontWeight = 'bold';
            app.NoteLabel.FontColor = [0 0.4471 0.7412];
            app.NoteLabel.Layout.Row = 3;
            app.NoteLabel.Layout.Column = 1;
            app.NoteLabel.Text = 'Nota';

            % Create Note
            app.Note = uitextarea(app.EditionGrid);
            app.Note.ValueChangedFcn = createCallbackFcn(app, @NoteValueChanged, true);
            app.Note.FontSize = 11;
            app.Note.Layout.Row = 4;
            app.Note.Layout.Column = 1;

            % Create Button
            app.Button = uibutton(app.GridLayout, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @onButtonPushed, true);
            app.Button.BackgroundColor = [0 0.451 0.7412];
            app.Button.FontSize = 11;
            app.Button.FontColor = [1 1 1];
            app.Button.Layout.Row = 7;
            app.Button.Layout.Column = 2;
            app.Button.Text = 'Aplica alterações';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockCustomsAnalysisDetails_exported(Container, varargin)

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
