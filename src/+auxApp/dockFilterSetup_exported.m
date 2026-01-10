classdef dockFilterSetup_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        Document                      matlab.ui.container.GridLayout
        columnFilterLabel_2           matlab.ui.control.Label
        config_SearchModePanel        matlab.ui.container.ButtonGroup
        config_SearchModeListOfWords  matlab.ui.control.RadioButton
        config_SearchModeTokenSuggestion  matlab.ui.control.RadioButton
        columnFilterPanel             matlab.ui.container.Panel
        columnFilterGrid              matlab.ui.container.GridLayout
        columnFilterList              matlab.ui.container.CheckBoxTree
        columnFilterAdd               matlab.ui.control.Image
        value2_TextFree               matlab.ui.control.EditField
        value2_TextList               matlab.ui.control.DropDown
        value2_Numeric                matlab.ui.control.NumericEditField
        value2_Date                   matlab.ui.control.DatePicker
        operation2_List               matlab.ui.control.DropDown
        operation2_LogicalGrid        matlab.ui.container.ButtonGroup
        operation2_LogicalOr          matlab.ui.control.RadioButton
        operation2_LogicalAnd         matlab.ui.control.RadioButton
        value1_TextFree               matlab.ui.control.EditField
        value1_TextList               matlab.ui.control.DropDown
        value1_Numeric                matlab.ui.control.NumericEditField
        value1_Date                   matlab.ui.control.DatePicker
        operation1_List               matlab.ui.control.DropDown
        symbolicNameList              matlab.ui.control.DropDown
        columnFilterLabel             matlab.ui.control.Label
        filteringStrategy             matlab.ui.control.DropDown
        filteringStrategyLabel        matlab.ui.control.Label
        btnClose                      matlab.ui.control.Image
        ContextMenu                   matlab.ui.container.ContextMenu
        columnFilterDel               matlab.ui.container.Menu
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
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialLayout(app)
            % DROPDOWN "COLUNAS"
            columnNames   = app.mainApp.schDataTable.Properties.VariableNames;
            columnTypes   = matlab.Compatibility.resolveTableVariableTypes(app.mainApp.schDataTable);
            
            columnCached  = ~startsWith(columnNames, '_');
            columnNames   = columnNames(columnCached);
            columnTypes   = columnTypes(columnCached);
            pseudoClasses = tableFiltering.getPseudoClasses(columnTypes);
            symbolicNames = tableFiltering.mergedSymbolWithColumnNames(columnNames, columnTypes);
            
            % Atualiza componente dropdown com os nomes símbolicos das
            % colunas, além de armazenar em "UserData" detalhes sobre os
            % tipos de dados (nome, tipo e pseudo classe de cada coluna).
            app.symbolicNameList.Items = [{''}; symbolicNames'];
            
            restartState(app)            
            app.symbolicNameList.UserData.columnNames   = columnNames;
            app.symbolicNameList.UserData.columnTypes   = columnTypes;
            app.symbolicNameList.UserData.pseudoClasses = pseudoClasses;
        end

        %-----------------------------------------------------------------%
        function restartState(app)
            % O componente de INPUT do valor do filtro pode ser uidatepicker,
            % uieditfield (numeric/text) ou uidropdown, a depender da pseudo 
            % classe da coluna. Guarda-se um handle p/ o elemento ativo.
            app.operation1_List.UserData.inputHandle = [];
            app.operation2_List.UserData.inputHandle = [];
        end

        %-----------------------------------------------------------------%
        function updateForm(app)
            switch app.mainApp.General.search.type
                case 'FreeText'
                    app.filteringStrategy.Value = 'Texto livre';
                case 'ColumnFilter'
                    app.filteringStrategy.Value = 'Filtro por coluna';
                otherwise % FreeText+ColumnFilter
                    app.filteringStrategy.Value = 'Texto livre + Filtro por coluna';
            end

            switch app.mainApp.General.search.mode
                case 'tokens'
                    app.config_SearchModeTokenSuggestion.Value = 1;
                otherwise % words
                    app.config_SearchModeListOfWords.Value = 1;
            end

            set(app.config_SearchModePanel.Children, 'Enable', contains(app.filteringStrategy.Value, 'Texto livre'))
            set(app.columnFilterPanel,               'Enable', contains(app.filteringStrategy.Value, 'Filtro por coluna'))

            updateTree(app)
        end

        %-----------------------------------------------------------------%
        function updateTree(app)
            if ~isempty(app.columnFilterList.Children)
                delete(app.columnFilterList.Children)
            end

            filterList = getFilterList(app.mainApp.filteringObj, 'SCH');
            if ~isempty(filterList)
                checkedNodes = [];
    
                for ii = 1:numel(filterList)
                    childNode = uitreenode(app.columnFilterList, 'Text', filterList{ii}, 'NodeData', ii);
    
                    if app.mainApp.filteringObj.filterRules.Enable(ii)
                        checkedNodes = [checkedNodes, childNode];
                    end
                end
    
                app.columnFilterList.CheckedNodes = checkedNodes;
            end
        end

        %-----------------------------------------------------------------%
        function [columName, pseudoClass] = inspectColumnData(app)
            symbolicName = app.symbolicNameList.Value;
            [~, symbolicIndex] = ismember(symbolicName, app.symbolicNameList.Items);
            columnIndex = symbolicIndex-1;

            if columnIndex == 0
                columName   = '';
                pseudoClass = '';
            else
                columName   = app.symbolicNameList.UserData.columnNames{columnIndex};
                pseudoClass = app.symbolicNameList.UserData.pseudoClasses{columnIndex};
            end
        end

        %-----------------------------------------------------------------%
        function categories = getCategories(app, columnName)
            categories = {};
            categoriesIndex = find(strcmp({app.mainApp.schDataCategories.columnName}, columnName), 1);
            if ~isempty(categoriesIndex)
                categories = app.mainApp.schDataCategories(categoriesIndex).categories;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                initialLayout(app)
                updateForm(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcnCallFromPopupApp', 'SEARCH', 'auxApp.dockFilterSetup')
            delete(app)
            
        end

        % Callback function: config_SearchModePanel, filteringStrategy
        function onSearchModeChanged(app, event)
            
            switch event.Source
                case app.filteringStrategy
                    switch app.filteringStrategy.Value
                        case 'Texto livre'
                            app.mainApp.General.search.type = 'FreeText';
                        case 'Filtro por coluna'
                            app.mainApp.General.search.type = 'ColumnFilter';
                        otherwise % 'Texto livre + Filtro por coluna'
                            app.mainApp.General.search.type = 'FreeText+ColumnFilter';
                    end

                case app.config_SearchModePanel            
                    switch app.config_SearchModePanel.SelectedObject
                        case app.config_SearchModeTokenSuggestion
                            app.mainApp.General.search.mode     = 'tokens';
                            app.mainApp.General.search.function = 'strcmp';
        
                        otherwise % app.config_SearchModeListOfWords
                            app.mainApp.General.search.mode     = 'words';
                            app.mainApp.General.search.function = 'contains';
                    end
            end

            app.mainApp.General_I.search = app.mainApp.General.search;
            appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onSearchModeChanged')
            updateForm(app)

        end

        % Value changed function: symbolicNameList
        function onFilterColumnChanged(app, event)
            
            restartState(app)

            [columnName, pseudoClass] = inspectColumnData(app);
            app.symbolicNameList.UserData.selected = struct('columnName', columnName, 'pseudoClass', pseudoClass);

            if isempty(pseudoClass)
                operations = {};
            else
                operations = tableFiltering.getFilterCapabilities(pseudoClass);
            end
            
            app.operation1_List.Items = operations;
            set(app.operation2_List, 'Items', [{''}, operations], 'Value', '')

            if ~isempty(operations)
                app.operation1_List.Value = app.operation1_List.Items{1};
                onFilterOperatorChanged(app, struct('Source', app.operation1_List))
                onFilterOperatorChanged(app, struct('Source', app.operation2_List))
            end

            app.columnFilterAdd.Enable = ~isempty(operations);

        end

        % Value changed function: operation1_List, operation2_List
        function onFilterOperatorChanged(app, event)
            
            switch event.Source
                case app.operation1_List
                    valueHandles = [ ...
                        app.value1_Date, ...
                        app.value1_Numeric, ...
                        app.value1_TextFree, ...
                        app.value1_TextList ...
                    ];
                    
                case app.operation2_List
                    valueHandles = [ ...
                        app.value2_Date, ...
                        app.value2_Numeric, ...
                        app.value2_TextFree, ...
                        app.value2_TextList ...
                    ];
            end
            tagHandles  = arrayfun(@(x) x.Tag, valueHandles, 'UniformOutput', false);

            columnName  = app.symbolicNameList.UserData.selected.columnName;
            pseudoClass = app.symbolicNameList.UserData.selected.pseudoClass;
            categories  = getCategories(app, columnName);

            switch pseudoClass
                case 'cellstr'
                    [~, tagIndex] = ismember('textFree', tagHandles);
                  % optionalArgs  = {'Value', ''};
                    optionalArgs  = {};

                case 'numeric'
                    [~, tagIndex] = ismember('numeric', tagHandles);
                    optionalArgs  = {};

                case 'datetime'
                    [~, tagIndex] = ismember('datePicker', tagHandles);
                    optionalArgs  = {};

                case 'categorical'
                    % Se a coluna tiver mais de 500 categorias, apresenta-se 
                    % como uieditfield (text) ao invés de dropdown.
                    if isempty(categories)
                        [~, tagIndex] = ismember('textFree', tagHandles);
                        optionalArgs  = {};
                    else
                        [~, tagIndex] = ismember('textList', tagHandles);
                        optionalArgs  = {'Items', [{''}; categories]};
                    end
            end

            event.Source.UserData.inputHandle = valueHandles(tagIndex);
            set(valueHandles(tagIndex), 'Visible', 1, optionalArgs{:})
            set(setdiff(valueHandles, valueHandles(tagIndex)), 'Visible', 0)
            
        end

        % Image clicked function: columnFilterAdd
        function onFilterAddImageClicked(app, event)
            
            columnName = app.symbolicNameList.UserData.selected.columnName;            
            operators  = {app.operation1_List.Value};
            values     = {app.operation1_List.UserData.inputHandle.Value};
            connector  = app.operation2_LogicalGrid.SelectedObject.Text;

            if ~isempty(app.operation2_List.Value) && (~strcmp(app.operation1_List.Value, app.operation2_List.Value) || ~isequal(app.operation1_List.UserData.inputHandle.Value, app.operation2_List.UserData.inputHandle.Value))
                operators = [operators, {app.operation2_List.Value}];
                values    = [values, {app.operation2_List.UserData.inputHandle.Value}];
            end

            try
                addFilterRule(app.mainApp.filteringObj, columnName, operators, values, connector);
            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
                return
            end
            updateTree(app)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onColumnFilterChanged')

        end

        % Menu selected function: columnFilterDel
        function onFilterDelImageClicked(app, event)
            
            selectedNodes = app.columnFilterList.SelectedNodes;

            if ~isempty(selectedNodes)
                removeFilterRule(app.mainApp.filteringObj, [selectedNodes.NodeData])
                updateTree(app)

                ipcMainMatlabCallsHandler(app.mainApp, app, 'onColumnFilterChanged')
            end

        end

        % Callback function: columnFilterList
        function onColumnFilterCheckedNodesChanged(app, event)

            checkedNodes = [];            
            if ~isempty(app.columnFilterList.CheckedNodes)
                checkedNodes = [app.columnFilterList.CheckedNodes.NodeData];
            end

            initialEnableArray = app.mainApp.filteringObj.filterRules.Enable;
            currentEnableArray = zeros(height(initialEnableArray), 1, 'logical');
            if ~isempty(checkedNodes)
                currentEnableArray(checkedNodes) = true;
            end

            if ~isequal(initialEnableArray, currentEnableArray)
                toogleFilterRule(app.mainApp.filteringObj, currentEnableArray)
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onColumnFilterChanged')
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
                app.UIFigure.Position = [100 100 460 486];
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
            app.GridLayout.ColumnWidth = {'1x', 30};
            app.GridLayout.RowHeight = {30, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.902 0.902 0.902];

            % Create btnClose
            app.btnClose = uiimage(app.GridLayout);
            app.btnClose.ScaleMethod = 'none';
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @closeFcn, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {217, 218};
            app.Document.RowHeight = {22, 22, 22, 64, 22, 264};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [10 10 10 5];
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [1 1 1];

            % Create filteringStrategyLabel
            app.filteringStrategyLabel = uilabel(app.Document);
            app.filteringStrategyLabel.VerticalAlignment = 'bottom';
            app.filteringStrategyLabel.FontSize = 10;
            app.filteringStrategyLabel.Layout.Row = 1;
            app.filteringStrategyLabel.Layout.Column = 1;
            app.filteringStrategyLabel.Text = 'ESTRATÉGIA DE FILTRAGEM';

            % Create filteringStrategy
            app.filteringStrategy = uidropdown(app.Document);
            app.filteringStrategy.Items = {'Texto livre', 'Filtro por coluna', 'Texto livre + Filtro por coluna'};
            app.filteringStrategy.ValueChangedFcn = createCallbackFcn(app, @onSearchModeChanged, true);
            app.filteringStrategy.FontSize = 11;
            app.filteringStrategy.BackgroundColor = [1 1 1];
            app.filteringStrategy.Layout.Row = 2;
            app.filteringStrategy.Layout.Column = 1;
            app.filteringStrategy.Value = 'Texto livre + Filtro por coluna';

            % Create columnFilterLabel
            app.columnFilterLabel = uilabel(app.Document);
            app.columnFilterLabel.VerticalAlignment = 'bottom';
            app.columnFilterLabel.FontSize = 10;
            app.columnFilterLabel.Layout.Row = 5;
            app.columnFilterLabel.Layout.Column = 1;
            app.columnFilterLabel.Text = 'FILTRO POR COLUNA';

            % Create columnFilterPanel
            app.columnFilterPanel = uipanel(app.Document);
            app.columnFilterPanel.Layout.Row = 6;
            app.columnFilterPanel.Layout.Column = [1 2];

            % Create columnFilterGrid
            app.columnFilterGrid = uigridlayout(app.columnFilterPanel);
            app.columnFilterGrid.ColumnWidth = {130, '1x', 22};
            app.columnFilterGrid.RowHeight = {22, 22, 22, 22, 18, '1x'};
            app.columnFilterGrid.ColumnSpacing = 5;
            app.columnFilterGrid.RowSpacing = 5;
            app.columnFilterGrid.BackgroundColor = [1 1 1];

            % Create symbolicNameList
            app.symbolicNameList = uidropdown(app.columnFilterGrid);
            app.symbolicNameList.Items = {};
            app.symbolicNameList.ValueChangedFcn = createCallbackFcn(app, @onFilterColumnChanged, true);
            app.symbolicNameList.FontSize = 11;
            app.symbolicNameList.BackgroundColor = [1 1 1];
            app.symbolicNameList.Layout.Row = 1;
            app.symbolicNameList.Layout.Column = [1 3];
            app.symbolicNameList.Value = {};

            % Create operation1_List
            app.operation1_List = uidropdown(app.columnFilterGrid);
            app.operation1_List.Items = {};
            app.operation1_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.operation1_List.FontSize = 11;
            app.operation1_List.BackgroundColor = [1 1 1];
            app.operation1_List.Layout.Row = 2;
            app.operation1_List.Layout.Column = 1;
            app.operation1_List.Value = {};

            % Create value1_Date
            app.value1_Date = uidatepicker(app.columnFilterGrid);
            app.value1_Date.Editable = 'off';
            app.value1_Date.Tag = 'datePicker';
            app.value1_Date.FontSize = 11;
            app.value1_Date.Visible = 'off';
            app.value1_Date.Layout.Row = 2;
            app.value1_Date.Layout.Column = [2 3];

            % Create value1_Numeric
            app.value1_Numeric = uieditfield(app.columnFilterGrid, 'numeric');
            app.value1_Numeric.Tag = 'numeric';
            app.value1_Numeric.FontSize = 11;
            app.value1_Numeric.Visible = 'off';
            app.value1_Numeric.Layout.Row = 2;
            app.value1_Numeric.Layout.Column = [2 3];
            app.value1_Numeric.Value = 1;

            % Create value1_TextList
            app.value1_TextList = uidropdown(app.columnFilterGrid);
            app.value1_TextList.Items = {''};
            app.value1_TextList.Editable = 'on';
            app.value1_TextList.Tag = 'textList';
            app.value1_TextList.Visible = 'off';
            app.value1_TextList.FontSize = 11;
            app.value1_TextList.BackgroundColor = [1 1 1];
            app.value1_TextList.Layout.Row = 2;
            app.value1_TextList.Layout.Column = [2 3];
            app.value1_TextList.Value = '';

            % Create value1_TextFree
            app.value1_TextFree = uieditfield(app.columnFilterGrid, 'text');
            app.value1_TextFree.Tag = 'textFree';
            app.value1_TextFree.FontSize = 11;
            app.value1_TextFree.FontColor = [0.149 0.149 0.149];
            app.value1_TextFree.Layout.Row = 2;
            app.value1_TextFree.Layout.Column = [2 3];

            % Create operation2_LogicalGrid
            app.operation2_LogicalGrid = uibuttongroup(app.columnFilterGrid);
            app.operation2_LogicalGrid.AutoResizeChildren = 'off';
            app.operation2_LogicalGrid.BorderType = 'none';
            app.operation2_LogicalGrid.BackgroundColor = [1 1 1];
            app.operation2_LogicalGrid.Layout.Row = 3;
            app.operation2_LogicalGrid.Layout.Column = 1;

            % Create operation2_LogicalAnd
            app.operation2_LogicalAnd = uiradiobutton(app.operation2_LogicalGrid);
            app.operation2_LogicalAnd.Text = 'E';
            app.operation2_LogicalAnd.FontSize = 11;
            app.operation2_LogicalAnd.Position = [20 1 51 22];
            app.operation2_LogicalAnd.Value = true;

            % Create operation2_LogicalOr
            app.operation2_LogicalOr = uiradiobutton(app.operation2_LogicalGrid);
            app.operation2_LogicalOr.Text = 'Ou';
            app.operation2_LogicalOr.FontSize = 11;
            app.operation2_LogicalOr.Position = [79 1 50 22];

            % Create operation2_List
            app.operation2_List = uidropdown(app.columnFilterGrid);
            app.operation2_List.Items = {};
            app.operation2_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.operation2_List.FontSize = 11;
            app.operation2_List.BackgroundColor = [1 1 1];
            app.operation2_List.Layout.Row = 4;
            app.operation2_List.Layout.Column = 1;
            app.operation2_List.Value = {};

            % Create value2_Date
            app.value2_Date = uidatepicker(app.columnFilterGrid);
            app.value2_Date.Editable = 'off';
            app.value2_Date.Tag = 'datePicker';
            app.value2_Date.FontSize = 11;
            app.value2_Date.Visible = 'off';
            app.value2_Date.Layout.Row = 4;
            app.value2_Date.Layout.Column = [2 3];

            % Create value2_Numeric
            app.value2_Numeric = uieditfield(app.columnFilterGrid, 'numeric');
            app.value2_Numeric.Tag = 'numeric';
            app.value2_Numeric.FontSize = 11;
            app.value2_Numeric.Visible = 'off';
            app.value2_Numeric.Layout.Row = 4;
            app.value2_Numeric.Layout.Column = [2 3];
            app.value2_Numeric.Value = 1;

            % Create value2_TextList
            app.value2_TextList = uidropdown(app.columnFilterGrid);
            app.value2_TextList.Items = {''};
            app.value2_TextList.Editable = 'on';
            app.value2_TextList.Tag = 'textList';
            app.value2_TextList.Visible = 'off';
            app.value2_TextList.FontSize = 11;
            app.value2_TextList.BackgroundColor = [1 1 1];
            app.value2_TextList.Layout.Row = 4;
            app.value2_TextList.Layout.Column = [2 3];
            app.value2_TextList.Value = '';

            % Create value2_TextFree
            app.value2_TextFree = uieditfield(app.columnFilterGrid, 'text');
            app.value2_TextFree.Tag = 'textFree';
            app.value2_TextFree.FontSize = 11;
            app.value2_TextFree.FontColor = [0.149 0.149 0.149];
            app.value2_TextFree.Layout.Row = 4;
            app.value2_TextFree.Layout.Column = [2 3];

            % Create columnFilterAdd
            app.columnFilterAdd = uiimage(app.columnFilterGrid);
            app.columnFilterAdd.ScaleMethod = 'none';
            app.columnFilterAdd.ImageClickedFcn = createCallbackFcn(app, @onFilterAddImageClicked, true);
            app.columnFilterAdd.Enable = 'off';
            app.columnFilterAdd.Layout.Row = 5;
            app.columnFilterAdd.Layout.Column = 3;
            app.columnFilterAdd.ImageSource = 'Add_16.png';

            % Create columnFilterList
            app.columnFilterList = uitree(app.columnFilterGrid, 'checkbox');
            app.columnFilterList.FontSize = 11;
            app.columnFilterList.Layout.Row = 6;
            app.columnFilterList.Layout.Column = [1 3];

            % Assign Checked Nodes
            app.columnFilterList.CheckedNodesChangedFcn = createCallbackFcn(app, @onColumnFilterCheckedNodesChanged, true);

            % Create config_SearchModePanel
            app.config_SearchModePanel = uibuttongroup(app.Document);
            app.config_SearchModePanel.AutoResizeChildren = 'off';
            app.config_SearchModePanel.SelectionChangedFcn = createCallbackFcn(app, @onSearchModeChanged, true);
            app.config_SearchModePanel.BackgroundColor = [1 1 1];
            app.config_SearchModePanel.Layout.Row = 4;
            app.config_SearchModePanel.Layout.Column = [1 2];

            % Create config_SearchModeTokenSuggestion
            app.config_SearchModeTokenSuggestion = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeTokenSuggestion.Text = 'Busca incremental com sugestão de tokens relacionados.';
            app.config_SearchModeTokenSuggestion.FontSize = 11;
            app.config_SearchModeTokenSuggestion.Position = [11 31 368 24];
            app.config_SearchModeTokenSuggestion.Value = true;

            % Create config_SearchModeListOfWords
            app.config_SearchModeListOfWords = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeListOfWords.Text = 'Busca por lista de termos (separados por vírgula, sem sugestões).';
            app.config_SearchModeListOfWords.FontSize = 11;
            app.config_SearchModeListOfWords.Position = [12 7 370 24];

            % Create columnFilterLabel_2
            app.columnFilterLabel_2 = uilabel(app.Document);
            app.columnFilterLabel_2.VerticalAlignment = 'bottom';
            app.columnFilterLabel_2.FontSize = 10;
            app.columnFilterLabel_2.Layout.Row = 3;
            app.columnFilterLabel_2.Layout.Column = 1;
            app.columnFilterLabel_2.Text = 'TEXTO LIVRE';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockFilterSetup';

            % Create columnFilterDel
            app.columnFilterDel = uimenu(app.ContextMenu);
            app.columnFilterDel.MenuSelectedFcn = createCallbackFcn(app, @onFilterDelImageClicked, true);
            app.columnFilterDel.Text = '❌ Excluir';

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
