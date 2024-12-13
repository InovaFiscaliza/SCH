classdef dockFilterSetup_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        Document                    matlab.ui.container.GridLayout
        SecundaryPanelLabel         matlab.ui.control.Label
        SecundaryPanel              matlab.ui.container.Panel
        SecundaryGrid               matlab.ui.container.GridLayout
        SecundaryTextListValue      matlab.ui.control.DropDown
        SecundaryTextFreeValue      matlab.ui.control.EditField
        SecundaryDateTime2          matlab.ui.control.EditField
        SecundaryDateTimeSeparator  matlab.ui.control.Label
        SecundaryDateTime1          matlab.ui.control.EditField
        SecundaryOperation          matlab.ui.control.DropDown
        SecundaryColumn             matlab.ui.control.DropDown
        SecundaryAddFilter          matlab.ui.control.Image
        SecundaryListOfFilters      matlab.ui.control.ListBox
        btnOK                       matlab.ui.control.Button
        btnClose                    matlab.ui.control.Image
        ContextMenu                 matlab.ui.container.ContextMenu
        ExcluirMenu                 matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true

        CallingApp
        General
        filteringObj
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            allColumns      = app.General.SCHDataInfo.Column;
            [~, sortIndex]  = sort(lower(allColumns));
            GUIAllColumns   = allColumns(sortIndex);

            app.SecundaryColumn.Items = GUIAllColumns;
            SecundaryColumnValueChanged(app)

            app.SecundaryListOfFilters.Items = FilterList(app.filteringObj, 'SCH');
        end

       %-----------------------------------------------------------------%
        function [Value, msgWarning] = SecundaryFilterValue(app)
            Value       = [];
            msgWarning  = '';

            columnName  = app.SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            selectedOperation = app.SecundaryOperation.Value;
            switch filterType
                case 'datetime'
                    switch selectedOperation
                        case {'=', '≠', '<', '≤', '>', '≥'}
                            Value = datetime(app.SecundaryDateTime1.Value, 'InputFormat', 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy');
                            
                        case {'><', '<>'}
                            Value = datetime({app.SecundaryDateTime1.Value, app.SecundaryDateTime2.Value}, 'InputFormat', 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy');

                        case {'⊃', '⊅'}
                            try
                                Value = cellfun(@(x) datetime(x, "InputFormat", 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy'), strtrim(strsplit(app.SecundaryTextFreeValue.Value, ',')));
                            catch ME
                                app.SecundaryTextFreeValue.Value = '';

                                msgWarning = ME.message;
                                return
                            end
                    end

                case 'freeText'
                    Value = strtrim(strsplit(app.SecundaryTextFreeValue.Value, ','));
                    if isscalar(Value)
                        Value = char(Value);
                    end

                case 'listOfText'
                    Value = app.SecundaryTextListValue.Value;
            end

            if isempty(Value)
                msgWarning = 'Valor inválido.';
            end
        end

        %-----------------------------------------------------------------%
        function CallingMainApp(app, updateFlag, returnFlag)
            appBackDoor(app.CallingApp, app, 'SEARCH:FILTERSETUP', updateFlag, returnFlag)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainapp)
            
            app.CallingApp   = mainapp;
            app.General      = mainapp.General;
            app.filteringObj = mainapp.filteringObj;

            initialValues(app)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Value changed function: SecundaryColumn
        function SecundaryColumnValueChanged(app, event)
            
            columnName  = app.SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            switch filterType
                case 'datetime'
                    Operations = {'=', '≠', '<', '≤', '>', '≥', '><', '<>'};

                case 'freeText'
                    Operations = {'=', '≠', '⊃', '⊅'};

                case 'listOfText'
                    Operations = {'=', '≠'};
            end
            app.SecundaryOperation.Items = Operations;

            app.SecundaryOperation.Value = app.SecundaryOperation.Items{1};
            SecundaryOperationValueChanged(app)
            
        end

        % Value changed function: SecundaryOperation
        function SecundaryOperationValueChanged(app, event)

            columnName  = app.SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            selectedOperation = app.SecundaryOperation.Value;
            switch filterType
                case 'datetime'
                    switch selectedOperation
                        case {'=', '≠', '<', '≤', '>', '≥'}
                            set(app.SecundaryDateTime1,         'Visible', 1)
                            set(app.SecundaryDateTimeSeparator, 'Visible', 0)
                            set(app.SecundaryDateTime2,         'Visible', 0)
                            set(app.SecundaryTextFreeValue,     'Visible', 0)
                            set(app.SecundaryTextListValue,     'Visible', 0, 'Items', {})
                            
                        case {'><', '<>'}
                            set(app.SecundaryDateTime1,         'Visible', 1)
                            set(app.SecundaryDateTimeSeparator, 'Visible', 1)
                            set(app.SecundaryDateTime2,         'Visible', 1)
                            set(app.SecundaryTextFreeValue,     'Visible', 0)
                            set(app.SecundaryTextListValue,     'Visible', 0, 'Items', {})
                    end

                case 'freeText'
                    set(app.SecundaryDateTime1,         'Visible', 0)
                    set(app.SecundaryDateTimeSeparator, 'Visible', 0)
                    set(app.SecundaryDateTime2,         'Visible', 0)
                    set(app.SecundaryTextFreeValue,     'Visible', 1)
                    set(app.SecundaryTextListValue,     'Visible', 0, 'Items', {})

                case 'listOfText'
                    try
                        primaryIndex = app.CallingApp.search_Table.UserData.primaryIndex;
                        columnItems  = [{''}; cellstr(unique(app.CallingApp.rawDataTable{primaryIndex, columnName}))];
                    catch
                        columnItems = {};
                    end

                    set(app.SecundaryDateTime1,         'Visible', 0)
                    set(app.SecundaryDateTimeSeparator, 'Visible', 0)
                    set(app.SecundaryDateTime2,         'Visible', 0)
                    set(app.SecundaryTextFreeValue,     'Visible', 0)
                    set(app.SecundaryTextListValue,     'Visible', 1, 'Items', columnItems)
            end

        end

        % Image clicked function: SecundaryAddFilter
        function SecundaryAddFilterImageClicked(app, event)
            
            primaryIndex = app.CallingApp.search_Table.UserData.primaryIndex;
            if isempty(primaryIndex)
                appUtil.modalWindow(app.UIFigure, 'warning', 'A filtragem secundária é aplicável apenas após a realização de uma pesquisa (filtragem primária), e desde que tenha retornado algum registro dessa pesquisa.');
                return
            end

            % Afere os valores do novo filtro, validando-os.
            Column    = app.SecundaryColumn.Value;
            Operation = app.SecundaryOperation.Value;
            
            [Value, msgWarning] = SecundaryFilterValue(app);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return
            end

            % Adiciona um novo filtro à lista de filtros secundários.
            msgWarning = addFilterRule(app.filteringObj, Column, Operation, Value);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return
            end

            % Filtra...
            CallingMainApp(app, true, true)
            initialValues(app)

        end

        % Callback function: btnClose, btnOK
        function ButtonPushed(app, event)
            
            CallingMainApp(app, false, false)
            closeFcn(app)

        end

        % Menu selected function: ExcluirMenu
        function ExcluirMenuSelected(app, event)
            
            selectedFilter = app.SecundaryListOfFilters.Value;

            if ~isempty(selectedFilter)
                idxFilter = find(ismember(app.SecundaryListOfFilters.Items, selectedFilter));
                removeFilterRule(app.filteringObj, idxFilter);
                
                CallingMainApp(app, true, true)
                initialValues(app)
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
                app.UIFigure.Position = [100 100 412 464];
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
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {'1x', 30};
            app.GridLayout.RowHeight = {30, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.902 0.902 0.902];

            % Create btnClose
            app.btnClose = uiimage(app.GridLayout);
            app.btnClose.ScaleMethod = 'none';
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 63, 22};
            app.Document.RowHeight = {22, 69, 17, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Layout.Row = 5;
            app.btnOK.Layout.Column = [2 3];
            app.btnOK.Text = 'OK';

            % Create SecundaryListOfFilters
            app.SecundaryListOfFilters = uilistbox(app.Document);
            app.SecundaryListOfFilters.Items = {};
            app.SecundaryListOfFilters.Multiselect = 'on';
            app.SecundaryListOfFilters.FontSize = 11;
            app.SecundaryListOfFilters.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryListOfFilters.Layout.Row = 4;
            app.SecundaryListOfFilters.Layout.Column = [1 3];
            app.SecundaryListOfFilters.Value = {};

            % Create SecundaryAddFilter
            app.SecundaryAddFilter = uiimage(app.Document);
            app.SecundaryAddFilter.ImageClickedFcn = createCallbackFcn(app, @SecundaryAddFilterImageClicked, true);
            app.SecundaryAddFilter.Layout.Row = 3;
            app.SecundaryAddFilter.Layout.Column = 3;
            app.SecundaryAddFilter.ImageSource = 'Sum_36.png';

            % Create SecundaryPanel
            app.SecundaryPanel = uipanel(app.Document);
            app.SecundaryPanel.Layout.Row = 2;
            app.SecundaryPanel.Layout.Column = [1 3];

            % Create SecundaryGrid
            app.SecundaryGrid = uigridlayout(app.SecundaryPanel);
            app.SecundaryGrid.ColumnWidth = {55, '1x', 10, '1x'};
            app.SecundaryGrid.RowHeight = {22, 22};
            app.SecundaryGrid.ColumnSpacing = 5;
            app.SecundaryGrid.RowSpacing = 5;
            app.SecundaryGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create SecundaryColumn
            app.SecundaryColumn = uidropdown(app.SecundaryGrid);
            app.SecundaryColumn.Items = {};
            app.SecundaryColumn.ValueChangedFcn = createCallbackFcn(app, @SecundaryColumnValueChanged, true);
            app.SecundaryColumn.FontSize = 11;
            app.SecundaryColumn.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryColumn.Layout.Row = 1;
            app.SecundaryColumn.Layout.Column = [1 4];
            app.SecundaryColumn.Value = {};

            % Create SecundaryOperation
            app.SecundaryOperation = uidropdown(app.SecundaryGrid);
            app.SecundaryOperation.Items = {'=', '≠', '⊃', '⊅', '<', '≤', '>', '≥', '><', '<>'};
            app.SecundaryOperation.ValueChangedFcn = createCallbackFcn(app, @SecundaryOperationValueChanged, true);
            app.SecundaryOperation.FontName = 'Consolas';
            app.SecundaryOperation.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryOperation.Layout.Row = 2;
            app.SecundaryOperation.Layout.Column = 1;
            app.SecundaryOperation.Value = '=';

            % Create SecundaryDateTime1
            app.SecundaryDateTime1 = uieditfield(app.SecundaryGrid, 'text');
            app.SecundaryDateTime1.CharacterLimits = [10 10];
            app.SecundaryDateTime1.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryDateTime1.Visible = 'off';
            app.SecundaryDateTime1.Placeholder = 'dd/mm/yyyy';
            app.SecundaryDateTime1.Layout.Row = 2;
            app.SecundaryDateTime1.Layout.Column = 2;

            % Create SecundaryDateTimeSeparator
            app.SecundaryDateTimeSeparator = uilabel(app.SecundaryGrid);
            app.SecundaryDateTimeSeparator.HorizontalAlignment = 'center';
            app.SecundaryDateTimeSeparator.Visible = 'off';
            app.SecundaryDateTimeSeparator.Layout.Row = 2;
            app.SecundaryDateTimeSeparator.Layout.Column = 3;
            app.SecundaryDateTimeSeparator.Text = '-';

            % Create SecundaryDateTime2
            app.SecundaryDateTime2 = uieditfield(app.SecundaryGrid, 'text');
            app.SecundaryDateTime2.CharacterLimits = [10 10];
            app.SecundaryDateTime2.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryDateTime2.Visible = 'off';
            app.SecundaryDateTime2.Placeholder = 'dd/mm/yyyy';
            app.SecundaryDateTime2.Layout.Row = 2;
            app.SecundaryDateTime2.Layout.Column = 4;

            % Create SecundaryTextFreeValue
            app.SecundaryTextFreeValue = uieditfield(app.SecundaryGrid, 'text');
            app.SecundaryTextFreeValue.FontSize = 10;
            app.SecundaryTextFreeValue.FontColor = [0.149 0.149 0.149];
            app.SecundaryTextFreeValue.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryTextFreeValue.Visible = 'off';
            app.SecundaryTextFreeValue.Layout.Row = 2;
            app.SecundaryTextFreeValue.Layout.Column = [2 4];

            % Create SecundaryTextListValue
            app.SecundaryTextListValue = uidropdown(app.SecundaryGrid);
            app.SecundaryTextListValue.Items = {};
            app.SecundaryTextListValue.Visible = 'off';
            app.SecundaryTextListValue.FontSize = 10;
            app.SecundaryTextListValue.BackgroundColor = [0.9804 0.9804 0.9804];
            app.SecundaryTextListValue.Layout.Row = 2;
            app.SecundaryTextListValue.Layout.Column = [2 4];
            app.SecundaryTextListValue.Value = {};

            % Create SecundaryPanelLabel
            app.SecundaryPanelLabel = uilabel(app.Document);
            app.SecundaryPanelLabel.VerticalAlignment = 'bottom';
            app.SecundaryPanelLabel.FontSize = 10;
            app.SecundaryPanelLabel.Layout.Row = 1;
            app.SecundaryPanelLabel.Layout.Column = 1;
            app.SecundaryPanelLabel.Text = 'Filtragem secundária:';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create ExcluirMenu
            app.ExcluirMenu = uimenu(app.ContextMenu);
            app.ExcluirMenu.MenuSelectedFcn = createCallbackFcn(app, @ExcluirMenuSelected, true);
            app.ExcluirMenu.Text = 'Excluir';
            
            % Assign app.ContextMenu
            app.SecundaryListOfFilters.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockFilterSetup_exported(Container, varargin)

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
