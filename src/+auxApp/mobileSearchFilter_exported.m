classdef mobileSearchFilter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        SaveButton               matlab.ui.control.Button
        RefreshButton            matlab.ui.control.Button
        ColumnFilterPanel        matlab.ui.container.Panel
        ColumnFilterGrid         matlab.ui.container.GridLayout
        ColumnFilterList         matlab.ui.container.CheckBoxTree
        ColumnFilterAdd          matlab.ui.control.Image
        Value2_TextFree          matlab.ui.control.EditField
        Value2_TextList          matlab.ui.control.DropDown
        Value2_Numeric           matlab.ui.control.NumericEditField
        Value2_Date              matlab.ui.control.DatePicker
        Operation2_List          matlab.ui.control.DropDown
        Operation2_LogicalGrid   matlab.ui.container.ButtonGroup
        Operation2_LogicalOr     matlab.ui.control.RadioButton
        Operation2_LogicalAnd    matlab.ui.control.RadioButton
        Value1_TextFree          matlab.ui.control.EditField
        Value1_TextList          matlab.ui.control.DropDown
        Value1_Numeric           matlab.ui.control.NumericEditField
        Value1_Date              matlab.ui.control.DatePicker
        Operation1_List          matlab.ui.control.DropDown
        SymbolicNameList         matlab.ui.control.DropDown
        ColumnFilterLabel        matlab.ui.control.Label
        FreeTextRadioGroup       matlab.ui.container.ButtonGroup
        FreeTextByMatch          matlab.ui.control.RadioButton
        FreeTextBySimilatiry     matlab.ui.control.RadioButton
        FreeTextLabel            matlab.ui.control.Label
        FilterStrategy           matlab.ui.control.DropDown
        FilterStrategyLabel      matlab.ui.control.Label
        CurrentFilterPanel       matlab.ui.container.Panel
        CurrentFilterGrid        matlab.ui.container.GridLayout
        CurrentFilterColumn      matlab.ui.control.Label
        CurrentFilterSeparator2  matlab.ui.control.Image
        CurrentFilterText        matlab.ui.control.Label
        CurrentFilterSeparator1  matlab.ui.control.Image
        CurrentFilterStrategy    matlab.ui.control.Label
        CurrentFilterLabel       matlab.ui.control.Label
        CurrentFilterIcon        matlab.ui.control.Image
        ContextMenu              matlab.ui.container.ContextMenu
        ColumnFilterDel          matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryAppMobile'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true        
        mainApp
        callingApp
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
        draftSearch
        draftFilteringObj
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialLayout(app)
            app.CurrentFilterPanel.BorderColor = [0.8275 0.8275 0.8275];
            app.FreeTextRadioGroup.BorderColor = [0.8275 0.8275 0.8275];
            app.ColumnFilterPanel.BorderColor = [0.8275 0.8275 0.8275];
            addStyle(app.ColumnFilterList, uistyle('Interpreter', 'html'))

            % DROPDOWN "COLUNAS"
            columnRawNames = app.mainApp.schData.detailed.Properties.VariableNames;
            columnRawTypes = matlab.Compatibility.resolveTableVariableTypes(app.mainApp.schData.detailed);

            filterableMask = ~startsWith(columnRawNames, '_');
            columnRawNames = columnRawNames(filterableMask);
            columnRawTypes = columnRawTypes(filterableMask);

            [columnNames, sortedIdxs] = textAnalysis.sort(columnRawNames);
            columnTypes = columnRawTypes(sortedIdxs);
            
            pseudoClasses = tableFiltering.getPseudoClasses(columnTypes);
            symbolicNames = tableFiltering.mergedSymbolWithColumnNames(columnNames, columnTypes);
            
            % Atualiza componente dropdown com os nomes símbolicos das
            % colunas, além de armazenar em "UserData" detalhes sobre os
            % tipos de dados (nome, tipo e pseudo classe de cada coluna).
            app.SymbolicNameList.Items = [{''}; symbolicNames'];
            
            restartState(app)            
            app.SymbolicNameList.UserData.columnNames   = columnNames;
            app.SymbolicNameList.UserData.columnTypes   = columnTypes;
            app.SymbolicNameList.UserData.pseudoClasses = pseudoClasses;
        end

        %-----------------------------------------------------------------%
        function restartState(app)
            % O componente de INPUT do valor do filtro pode ser uidatepicker,
            % uieditfield (numeric/text) ou uidropdown, a depender da pseudo 
            % classe da coluna. Guarda-se um handle p/ o elemento ativo.
            app.Operation1_List.UserData.inputHandle = [];
            app.Operation2_List.UserData.inputHandle = [];
        end

        %-----------------------------------------------------------------%
        function refreshModule(app)
            app.draftSearch = struct( ...
                'type', app.mainApp.General.context.SEARCH.type, ...
                'mode', app.mainApp.General.context.SEARCH.mode ...
            );
            app.draftFilteringObj = tableFiltering;
            app.draftFilteringObj.filterRules = app.mainApp.filteringObj.filterRules;

            updateCurrentFilterPanel(app)
            updateForm(app)
            updateButtonsState(app)
        end

        %-----------------------------------------------------------------%
        function updateCurrentFilterPanel(app)
            searchType = app.mainApp.General.context.SEARCH.type;
            searchMode = app.mainApp.General.context.SEARCH.mode;

            strategyTypes = {'FreeText', 'ColumnFilter', 'FreeText+ColumnFilter'};
            strategyText  = app.FilterStrategy.Items{strcmp(strategyTypes, searchType)};

            if ~contains(searchType, 'FreeText')
                textModeText = 'Não utilizada';
            elseif strcmp(searchMode, 'tokens')
                textModeText = 'Similaridade';
            else
                textModeText = 'Texto exato';
            end

            nActiveFilters = numel(getFilterList(app.mainApp.filteringObj, 'SCH', 'on'));
            if ~contains(searchType, 'ColumnFilter')
                columnText = 'Não utilizados';
            elseif nActiveFilters == 0
                columnText = 'Nenhum aplicado';
            elseif nActiveFilters == 1
                columnText = '1 aplicado';
            else
                columnText = sprintf('%d aplicados', nActiveFilters);
            end

            htmlTemplate = '%s<br><font style="font-size:11px; color: #00213d;">%s</font>';
            app.CurrentFilterStrategy.Text = sprintf(htmlTemplate, 'Estratégia:',         strategyText);
            app.CurrentFilterText.Text     = sprintf(htmlTemplate, 'Pesquisa textual:',    textModeText);
            app.CurrentFilterColumn.Text   = sprintf(htmlTemplate, 'Filtros por coluna:',  columnText);
        end

        %-----------------------------------------------------------------%
        function [modeChanged, columnFilterChanged] = getPendingChanges(app)
            searchSettings = app.mainApp.General.context.SEARCH;

            modeChanged = ~strcmp(app.draftSearch.type, searchSettings.type) || ~strcmp(app.draftSearch.mode, searchSettings.mode);
            columnFilterChanged = ~isequal(app.draftFilteringObj.filterRules, app.mainApp.filteringObj.filterRules);
        end

        %-----------------------------------------------------------------%
        function updateButtonsState(app)
            [modeChanged, columnFilterChanged] = getPendingChanges(app);
            set([app.RefreshButton, app.SaveButton], 'Enable', modeChanged || columnFilterChanged)
        end

        %-----------------------------------------------------------------%
        function updateForm(app)
            switch app.draftSearch.type
                case 'FreeText'
                    app.FilterStrategy.Value = 'Texto livre';
                case 'ColumnFilter'
                    app.FilterStrategy.Value = 'Filtro por coluna';
                otherwise % FreeText+ColumnFilter
                    app.FilterStrategy.Value = 'Texto livre + Filtro por coluna';
            end

            switch app.draftSearch.mode
                case 'tokens'
                    app.FreeTextBySimilatiry.Value = 1;
                otherwise % words
                    app.FreeTextByMatch.Value = 1;
            end

            set(app.FreeTextRadioGroup.Children, 'Enable', contains(app.FilterStrategy.Value, 'Texto livre'))
            set(app.ColumnFilterPanel,           'Enable', contains(app.FilterStrategy.Value, 'Filtro por coluna'))

            updateTree(app)
        end

        %-----------------------------------------------------------------%
        function updateTree(app)
            if ~isempty(app.ColumnFilterList.Children)
                delete(app.ColumnFilterList.Children)
            end

            filterList = getFilterList(app.draftFilteringObj, 'SCH');
            if ~isempty(filterList)
                checkedNodes = [];
    
                for ii = 1:numel(filterList)
                    childNodeText = replace(filterList{ii}, {' && ', ' || '}, {' && ...<br>', ' || ...<br>'});
                    childNode = uitreenode(app.ColumnFilterList, 'Text', childNodeText, 'NodeData', ii, 'ContextMenu', app.ContextMenu);
    
                    if app.draftFilteringObj.filterRules.Enable(ii)
                        checkedNodes = [checkedNodes, childNode];
                    end
                end
    
                app.ColumnFilterList.CheckedNodes = checkedNodes;
            end
        end

        %-----------------------------------------------------------------%
        function [columName, pseudoClass] = inspectColumnData(app)
            symbolicName = app.SymbolicNameList.Value;
            [~, symbolicIndex] = ismember(symbolicName, app.SymbolicNameList.Items);
            columnIndex = symbolicIndex-1;

            if columnIndex == 0
                columName   = '';
                pseudoClass = '';
            else
                columName   = app.SymbolicNameList.UserData.columnNames{columnIndex};
                pseudoClass = app.SymbolicNameList.UserData.pseudoClasses{columnIndex};
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
        function startupFcn(app, mainApp, callingApp, context)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                app.inputArgs = struct('context', context);
                initialLayout(app)
                refreshModule(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: FilterStrategy, FreeTextRadioGroup
        function onSearchModeChanged(app, event)
            
            switch event.Source
                case app.FilterStrategy
                    switch app.FilterStrategy.Value
                        case 'Texto livre'
                            app.draftSearch.type = 'FreeText';
                        case 'Filtro por coluna'
                            app.draftSearch.type = 'ColumnFilter';
                        otherwise % 'Texto livre + Filtro por coluna'
                            app.draftSearch.type = 'FreeText+ColumnFilter';
                    end

                case app.FreeTextRadioGroup            
                    switch app.FreeTextRadioGroup.SelectedObject
                        case app.FreeTextBySimilatiry
                            app.draftSearch.mode = 'tokens';
        
                        otherwise % app.FreeTextByMatch
                            app.draftSearch.mode = 'words';
                    end
            end

            updateForm(app)
            updateButtonsState(app)

        end

        % Value changed function: SymbolicNameList
        function onFilterColumnChanged(app, event)
            
            restartState(app)

            [columnName, pseudoClass] = inspectColumnData(app);
            app.SymbolicNameList.UserData.selected = struct('columnName', columnName, 'pseudoClass', pseudoClass);

            if isempty(pseudoClass)
                operations = {};
            else
                operations = tableFiltering.getFilterCapabilities(pseudoClass);
            end
            
            app.Operation1_List.Items = operations;
            set(app.Operation2_List, 'Items', [{''}, operations], 'Value', '')

            if ~isempty(operations)
                app.Operation1_List.Value = app.Operation1_List.Items{1};
                onFilterOperatorChanged(app, struct('Source', app.Operation1_List))
                onFilterOperatorChanged(app, struct('Source', app.Operation2_List))
            end

            app.ColumnFilterAdd.Enable = ~isempty(operations);

        end

        % Value changed function: Operation1_List, Operation2_List
        function onFilterOperatorChanged(app, event)
            
            switch event.Source
                case app.Operation1_List
                    valueHandles = [ ...
                        app.Value1_Date, ...
                        app.Value1_Numeric, ...
                        app.Value1_TextFree, ...
                        app.Value1_TextList ...
                    ];
                    
                case app.Operation2_List
                    valueHandles = [ ...
                        app.Value2_Date, ...
                        app.Value2_Numeric, ...
                        app.Value2_TextFree, ...
                        app.Value2_TextList ...
                    ];
            end
            tagHandles  = arrayfun(@(x) x.Tag, valueHandles, 'UniformOutput', false);

            columnName  = app.SymbolicNameList.UserData.selected.columnName;
            pseudoClass = app.SymbolicNameList.UserData.selected.pseudoClass;
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

        % Image clicked function: ColumnFilterAdd
        function onFilterAddImageClicked(app, event)
            
            columnName = app.SymbolicNameList.UserData.selected.columnName;            
            operators  = {app.Operation1_List.Value};
            values     = {app.Operation1_List.UserData.inputHandle.Value};
            connector  = app.Operation2_LogicalGrid.SelectedObject.Text;

            if ~isempty(app.Operation2_List.Value) && (~strcmp(app.Operation1_List.Value, app.Operation2_List.Value) || ~isequal(app.Operation1_List.UserData.inputHandle.Value, app.Operation2_List.UserData.inputHandle.Value))
                operators = [operators, {app.Operation2_List.Value}];
                values    = [values, {app.Operation2_List.UserData.inputHandle.Value}];
            end

            try
                addFilterRule(app.draftFilteringObj, columnName, operators, values, connector);
            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
                return
            end
            updateTree(app)
            updateButtonsState(app)

        end

        % Menu selected function: ColumnFilterDel
        function onFilterDelImageClicked(app, event)
            
            selectedNodes = app.ColumnFilterList.SelectedNodes;

            if ~isempty(selectedNodes)
                removeFilterRule(app.draftFilteringObj, [selectedNodes.NodeData])
                updateTree(app)
                updateButtonsState(app)
            end

        end

        % Callback function: ColumnFilterList
        function onColumnFilterCheckedNodesChanged(app, event)

            checkedNodes = [];            
            if ~isempty(app.ColumnFilterList.CheckedNodes)
                checkedNodes = [app.ColumnFilterList.CheckedNodes.NodeData];
            end

            initialEnableArray = app.draftFilteringObj.filterRules.Enable;
            currentEnableArray = zeros(height(initialEnableArray), 1, 'logical');
            if ~isempty(checkedNodes)
                currentEnableArray(checkedNodes) = true;
            end

            if ~isequal(initialEnableArray, currentEnableArray)
                toogleFilterRule(app.draftFilteringObj, currentEnableArray)
                updateButtonsState(app)
            end
            
        end

        % Button pushed function: RefreshButton
        function onRefreshButtonPushed(app, event)
            
            refreshModule(app)

        end

        % Button pushed function: SaveButton
        function onSaveButtonPushed(app, event)
            
            [modeChanged, columnFilterChanged] = getPendingChanges(app);

            if modeChanged
                searchSettings = app.mainApp.General.context.SEARCH;
                searchSettings.type = app.draftSearch.type;
                searchSettings.mode = app.draftSearch.mode;

                switch searchSettings.mode
                    case 'tokens'
                        searchSettings.function = 'strcmp';
                    otherwise % words
                        searchSettings.function = 'contains';
                end

                app.mainApp.General.context.SEARCH   = searchSettings;
                app.mainApp.General_I.context.SEARCH = searchSettings;
                appEngine.util.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
            end

            app.mainApp.filteringObj.filterRules = app.draftFilteringObj.filterRules;

            if modeChanged
                ipcMainMatlabCallsHandler(app.mainApp, app, 'onSearchModeChanged')
            elseif columnFilterChanged
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
                app.UIFigure.Position = [100 100 387 720];
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
            app.GridLayout.ColumnWidth = {28, '1x', '1x', 28};
            app.GridLayout.RowHeight = {102, 22, 38, 22, 94, 22, '1x', 1, 38};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.BackgroundColor = [0.9608 0.9686 0.9686];

            % Create CurrentFilterPanel
            app.CurrentFilterPanel = uipanel(app.GridLayout);
            app.CurrentFilterPanel.Layout.Row = 1;
            app.CurrentFilterPanel.Layout.Column = [1 4];

            % Create CurrentFilterGrid
            app.CurrentFilterGrid = uigridlayout(app.CurrentFilterPanel);
            app.CurrentFilterGrid.ColumnWidth = {18, '1x', 1, 18, '1x', 1, 18, '1x'};
            app.CurrentFilterGrid.RowHeight = {22, '1x'};
            app.CurrentFilterGrid.ColumnSpacing = 5;
            app.CurrentFilterGrid.RowSpacing = 5;
            app.CurrentFilterGrid.BackgroundColor = [0.9608 0.9686 0.9686];

            % Create CurrentFilterIcon
            app.CurrentFilterIcon = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterIcon.ScaleMethod = 'none';
            app.CurrentFilterIcon.Layout.Row = 1;
            app.CurrentFilterIcon.Layout.Column = 1;
            app.CurrentFilterIcon.ImageSource = 'filter-filled.svg';

            % Create CurrentFilterLabel
            app.CurrentFilterLabel = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterLabel.FontSize = 14;
            app.CurrentFilterLabel.FontWeight = 'bold';
            app.CurrentFilterLabel.FontColor = [0 0.1294 0.2392];
            app.CurrentFilterLabel.Layout.Row = 1;
            app.CurrentFilterLabel.Layout.Column = 2;
            app.CurrentFilterLabel.Text = 'Filtro atual';

            % Create CurrentFilterStrategy
            app.CurrentFilterStrategy = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterStrategy.VerticalAlignment = 'top';
            app.CurrentFilterStrategy.WordWrap = 'on';
            app.CurrentFilterStrategy.FontSize = 10;
            app.CurrentFilterStrategy.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterStrategy.Layout.Row = 2;
            app.CurrentFilterStrategy.Layout.Column = [1 2];
            app.CurrentFilterStrategy.Interpreter = 'html';
            app.CurrentFilterStrategy.Text = 'Estratégia:<br><font style="font-size:11px; color: #00213d;">Texto livre + Filtro por coluna</font>';

            % Create CurrentFilterSeparator1
            app.CurrentFilterSeparator1 = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterSeparator1.ScaleMethod = 'fill';
            app.CurrentFilterSeparator1.Enable = 'off';
            app.CurrentFilterSeparator1.Layout.Row = 2;
            app.CurrentFilterSeparator1.Layout.Column = 3;
            app.CurrentFilterSeparator1.ImageSource = 'LineV.svg';

            % Create CurrentFilterText
            app.CurrentFilterText = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterText.VerticalAlignment = 'top';
            app.CurrentFilterText.WordWrap = 'on';
            app.CurrentFilterText.FontSize = 10;
            app.CurrentFilterText.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterText.Layout.Row = 2;
            app.CurrentFilterText.Layout.Column = [4 5];
            app.CurrentFilterText.Interpreter = 'html';
            app.CurrentFilterText.Text = 'Pesquisa textual:<br><font style="font-size:11px; color: #00213d;">Similaridade</font>';

            % Create CurrentFilterSeparator2
            app.CurrentFilterSeparator2 = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterSeparator2.ScaleMethod = 'fill';
            app.CurrentFilterSeparator2.Enable = 'off';
            app.CurrentFilterSeparator2.Layout.Row = 2;
            app.CurrentFilterSeparator2.Layout.Column = 6;
            app.CurrentFilterSeparator2.ImageSource = 'LineV.svg';

            % Create CurrentFilterColumn
            app.CurrentFilterColumn = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterColumn.VerticalAlignment = 'top';
            app.CurrentFilterColumn.WordWrap = 'on';
            app.CurrentFilterColumn.FontSize = 10;
            app.CurrentFilterColumn.FontColor = [0.4588 0.5294 0.6];
            app.CurrentFilterColumn.Layout.Row = 2;
            app.CurrentFilterColumn.Layout.Column = [7 8];
            app.CurrentFilterColumn.Interpreter = 'html';
            app.CurrentFilterColumn.Text = 'Filtros por coluna:<br><font style="font-size:11px; color: #00213d;">Nenhum aplicado</font>';

            % Create FilterStrategyLabel
            app.FilterStrategyLabel = uilabel(app.GridLayout);
            app.FilterStrategyLabel.VerticalAlignment = 'bottom';
            app.FilterStrategyLabel.FontSize = 11;
            app.FilterStrategyLabel.FontWeight = 'bold';
            app.FilterStrategyLabel.FontColor = [0.0314 0.4902 0.7294];
            app.FilterStrategyLabel.Layout.Row = 2;
            app.FilterStrategyLabel.Layout.Column = [1 2];
            app.FilterStrategyLabel.Text = 'Estratégia de filtragem';

            % Create FilterStrategy
            app.FilterStrategy = uidropdown(app.GridLayout);
            app.FilterStrategy.Items = {'Texto livre', 'Filtro por coluna', 'Texto livre + Filtro por coluna'};
            app.FilterStrategy.ValueChangedFcn = createCallbackFcn(app, @onSearchModeChanged, true);
            app.FilterStrategy.FontColor = [0 0.1294 0.2392];
            app.FilterStrategy.BackgroundColor = [1 1 1];
            app.FilterStrategy.Layout.Row = 3;
            app.FilterStrategy.Layout.Column = [1 4];
            app.FilterStrategy.Value = 'Texto livre + Filtro por coluna';

            % Create FreeTextLabel
            app.FreeTextLabel = uilabel(app.GridLayout);
            app.FreeTextLabel.VerticalAlignment = 'bottom';
            app.FreeTextLabel.FontSize = 11;
            app.FreeTextLabel.FontWeight = 'bold';
            app.FreeTextLabel.FontColor = [0.0314 0.4902 0.7294];
            app.FreeTextLabel.Layout.Row = 4;
            app.FreeTextLabel.Layout.Column = [1 2];
            app.FreeTextLabel.Text = 'Pesquisa textual';

            % Create FreeTextRadioGroup
            app.FreeTextRadioGroup = uibuttongroup(app.GridLayout);
            app.FreeTextRadioGroup.AutoResizeChildren = 'off';
            app.FreeTextRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @onSearchModeChanged, true);
            app.FreeTextRadioGroup.BackgroundColor = [1 1 1];
            app.FreeTextRadioGroup.Layout.Row = 5;
            app.FreeTextRadioGroup.Layout.Column = [1 4];

            % Create FreeTextBySimilatiry
            app.FreeTextBySimilatiry = uiradiobutton(app.FreeTextRadioGroup);
            app.FreeTextBySimilatiry.Text = {'Similaridade'; '<font style="color: gray; font-size:11px">Apresenta sugestões conforme o texto é digitado</font>'};
            app.FreeTextBySimilatiry.FontColor = [0 0.1294 0.2392];
            app.FreeTextBySimilatiry.Interpreter = 'html';
            app.FreeTextBySimilatiry.Position = [11 53 352 32];
            app.FreeTextBySimilatiry.Value = true;

            % Create FreeTextByMatch
            app.FreeTextByMatch = uiradiobutton(app.FreeTextRadioGroup);
            app.FreeTextByMatch.Text = {'Texto Exato'; '<font style="color: gray; font-size:11px">Busca termos, separados por vírgulas, sem apresentar sugestões</font>'};
            app.FreeTextByMatch.WordWrap = 'on';
            app.FreeTextByMatch.FontColor = [0 0.1294 0.2392];
            app.FreeTextByMatch.Interpreter = 'html';
            app.FreeTextByMatch.Position = [12 12 352 32];

            % Create ColumnFilterLabel
            app.ColumnFilterLabel = uilabel(app.GridLayout);
            app.ColumnFilterLabel.VerticalAlignment = 'bottom';
            app.ColumnFilterLabel.FontSize = 11;
            app.ColumnFilterLabel.FontWeight = 'bold';
            app.ColumnFilterLabel.FontColor = [0.0314 0.4902 0.7294];
            app.ColumnFilterLabel.Layout.Row = 6;
            app.ColumnFilterLabel.Layout.Column = [1 2];
            app.ColumnFilterLabel.Text = 'Filtro por coluna';

            % Create ColumnFilterPanel
            app.ColumnFilterPanel = uipanel(app.GridLayout);
            app.ColumnFilterPanel.AutoResizeChildren = 'off';
            app.ColumnFilterPanel.Layout.Row = 7;
            app.ColumnFilterPanel.Layout.Column = [1 4];

            % Create ColumnFilterGrid
            app.ColumnFilterGrid = uigridlayout(app.ColumnFilterPanel);
            app.ColumnFilterGrid.ColumnWidth = {130, '1x', 22};
            app.ColumnFilterGrid.RowHeight = {38, 38, 22, 38, 22, '1x'};
            app.ColumnFilterGrid.ColumnSpacing = 5;
            app.ColumnFilterGrid.RowSpacing = 5;
            app.ColumnFilterGrid.BackgroundColor = [1 1 1];

            % Create SymbolicNameList
            app.SymbolicNameList = uidropdown(app.ColumnFilterGrid);
            app.SymbolicNameList.Items = {};
            app.SymbolicNameList.ValueChangedFcn = createCallbackFcn(app, @onFilterColumnChanged, true);
            app.SymbolicNameList.FontColor = [0 0.1294 0.2392];
            app.SymbolicNameList.BackgroundColor = [1 1 1];
            app.SymbolicNameList.Placeholder = 'Selecione uma coluna';
            app.SymbolicNameList.Layout.Row = 1;
            app.SymbolicNameList.Layout.Column = [1 3];
            app.SymbolicNameList.Value = {};

            % Create Operation1_List
            app.Operation1_List = uidropdown(app.ColumnFilterGrid);
            app.Operation1_List.Items = {};
            app.Operation1_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.Operation1_List.FontColor = [0 0.1294 0.2392];
            app.Operation1_List.BackgroundColor = [1 1 1];
            app.Operation1_List.Placeholder = 'Selecione';
            app.Operation1_List.Layout.Row = 2;
            app.Operation1_List.Layout.Column = 1;
            app.Operation1_List.Value = {};

            % Create Value1_Date
            app.Value1_Date = uidatepicker(app.ColumnFilterGrid);
            app.Value1_Date.Editable = 'off';
            app.Value1_Date.Tag = 'datePicker';
            app.Value1_Date.FontColor = [0 0.1294 0.2392];
            app.Value1_Date.BackgroundColor = [0.96 0.96 0.96];
            app.Value1_Date.Visible = 'off';
            app.Value1_Date.Placeholder = 'Informe a data';
            app.Value1_Date.Layout.Row = 2;
            app.Value1_Date.Layout.Column = [2 3];

            % Create Value1_Numeric
            app.Value1_Numeric = uieditfield(app.ColumnFilterGrid, 'numeric');
            app.Value1_Numeric.Tag = 'numeric';
            app.Value1_Numeric.FontColor = [0 0.1294 0.2392];
            app.Value1_Numeric.Visible = 'off';
            app.Value1_Numeric.Placeholder = 'Informe o valor';
            app.Value1_Numeric.Layout.Row = 2;
            app.Value1_Numeric.Layout.Column = [2 3];
            app.Value1_Numeric.Value = 1;

            % Create Value1_TextList
            app.Value1_TextList = uidropdown(app.ColumnFilterGrid);
            app.Value1_TextList.Items = {''};
            app.Value1_TextList.Editable = 'on';
            app.Value1_TextList.Tag = 'textList';
            app.Value1_TextList.Visible = 'off';
            app.Value1_TextList.FontColor = [0 0.1294 0.2392];
            app.Value1_TextList.BackgroundColor = [1 1 1];
            app.Value1_TextList.Placeholder = 'Informe o valor';
            app.Value1_TextList.Layout.Row = 2;
            app.Value1_TextList.Layout.Column = [2 3];
            app.Value1_TextList.Value = '';

            % Create Value1_TextFree
            app.Value1_TextFree = uieditfield(app.ColumnFilterGrid, 'text');
            app.Value1_TextFree.Tag = 'textFree';
            app.Value1_TextFree.FontColor = [0 0.1294 0.2392];
            app.Value1_TextFree.Placeholder = 'Informe o valor';
            app.Value1_TextFree.Layout.Row = 2;
            app.Value1_TextFree.Layout.Column = [2 3];

            % Create Operation2_LogicalGrid
            app.Operation2_LogicalGrid = uibuttongroup(app.ColumnFilterGrid);
            app.Operation2_LogicalGrid.AutoResizeChildren = 'off';
            app.Operation2_LogicalGrid.BorderType = 'none';
            app.Operation2_LogicalGrid.BackgroundColor = [1 1 1];
            app.Operation2_LogicalGrid.Layout.Row = 3;
            app.Operation2_LogicalGrid.Layout.Column = 1;

            % Create Operation2_LogicalAnd
            app.Operation2_LogicalAnd = uiradiobutton(app.Operation2_LogicalGrid);
            app.Operation2_LogicalAnd.Text = 'E';
            app.Operation2_LogicalAnd.FontColor = [0 0.1294 0.2392];
            app.Operation2_LogicalAnd.Position = [1 1 51 22];
            app.Operation2_LogicalAnd.Value = true;

            % Create Operation2_LogicalOr
            app.Operation2_LogicalOr = uiradiobutton(app.Operation2_LogicalGrid);
            app.Operation2_LogicalOr.Text = 'Ou';
            app.Operation2_LogicalOr.FontColor = [0 0.1294 0.2392];
            app.Operation2_LogicalOr.Position = [60 1 50 22];

            % Create Operation2_List
            app.Operation2_List = uidropdown(app.ColumnFilterGrid);
            app.Operation2_List.Items = {};
            app.Operation2_List.ValueChangedFcn = createCallbackFcn(app, @onFilterOperatorChanged, true);
            app.Operation2_List.FontColor = [0 0.1294 0.2392];
            app.Operation2_List.BackgroundColor = [1 1 1];
            app.Operation2_List.Layout.Row = 4;
            app.Operation2_List.Layout.Column = 1;
            app.Operation2_List.Value = {};

            % Create Value2_Date
            app.Value2_Date = uidatepicker(app.ColumnFilterGrid);
            app.Value2_Date.Editable = 'off';
            app.Value2_Date.Tag = 'datePicker';
            app.Value2_Date.FontColor = [0 0.1294 0.2392];
            app.Value2_Date.BackgroundColor = [0.96 0.96 0.96];
            app.Value2_Date.Visible = 'off';
            app.Value2_Date.Layout.Row = 4;
            app.Value2_Date.Layout.Column = [2 3];

            % Create Value2_Numeric
            app.Value2_Numeric = uieditfield(app.ColumnFilterGrid, 'numeric');
            app.Value2_Numeric.Tag = 'numeric';
            app.Value2_Numeric.FontColor = [0 0.1294 0.2392];
            app.Value2_Numeric.Visible = 'off';
            app.Value2_Numeric.Layout.Row = 4;
            app.Value2_Numeric.Layout.Column = [2 3];
            app.Value2_Numeric.Value = 1;

            % Create Value2_TextList
            app.Value2_TextList = uidropdown(app.ColumnFilterGrid);
            app.Value2_TextList.Items = {''};
            app.Value2_TextList.Editable = 'on';
            app.Value2_TextList.Tag = 'textList';
            app.Value2_TextList.Visible = 'off';
            app.Value2_TextList.FontColor = [0 0.1294 0.2392];
            app.Value2_TextList.BackgroundColor = [1 1 1];
            app.Value2_TextList.Layout.Row = 4;
            app.Value2_TextList.Layout.Column = [2 3];
            app.Value2_TextList.Value = '';

            % Create Value2_TextFree
            app.Value2_TextFree = uieditfield(app.ColumnFilterGrid, 'text');
            app.Value2_TextFree.Tag = 'textFree';
            app.Value2_TextFree.FontColor = [0 0.1294 0.2392];
            app.Value2_TextFree.Layout.Row = 4;
            app.Value2_TextFree.Layout.Column = [2 3];

            % Create ColumnFilterAdd
            app.ColumnFilterAdd = uiimage(app.ColumnFilterGrid);
            app.ColumnFilterAdd.ScaleMethod = 'none';
            app.ColumnFilterAdd.ImageClickedFcn = createCallbackFcn(app, @onFilterAddImageClicked, true);
            app.ColumnFilterAdd.Enable = 'off';
            app.ColumnFilterAdd.Layout.Row = 5;
            app.ColumnFilterAdd.Layout.Column = 3;
            app.ColumnFilterAdd.ImageSource = 'Add_16.png';

            % Create ColumnFilterList
            app.ColumnFilterList = uitree(app.ColumnFilterGrid, 'checkbox');
            app.ColumnFilterList.FontColor = [0 0.1294 0.2392];
            app.ColumnFilterList.Layout.Row = 6;
            app.ColumnFilterList.Layout.Column = [1 3];

            % Assign Checked Nodes
            app.ColumnFilterList.CheckedNodesChangedFcn = createCallbackFcn(app, @onColumnFilterCheckedNodesChanged, true);

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @onRefreshButtonPushed, true);
            app.RefreshButton.Icon = 'discard.svg';
            app.RefreshButton.BackgroundColor = [0.9608 0.9686 0.9686];
            app.RefreshButton.FontColor = [0 0.1294 0.2392];
            app.RefreshButton.Enable = 'off';
            app.RefreshButton.Layout.Row = 9;
            app.RefreshButton.Layout.Column = [1 2];
            app.RefreshButton.Text = 'Limpar alterações';

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @onSaveButtonPushed, true);
            app.SaveButton.Icon = 'save-white.svg';
            app.SaveButton.BackgroundColor = [0.0314 0.4902 0.7294];
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Enable = 'off';
            app.SaveButton.Layout.Row = 9;
            app.SaveButton.Layout.Column = [3 4];
            app.SaveButton.Text = 'Salvar alterações';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.dockFilterSetup';

            % Create ColumnFilterDel
            app.ColumnFilterDel = uimenu(app.ContextMenu);
            app.ColumnFilterDel.MenuSelectedFcn = createCallbackFcn(app, @onFilterDelImageClicked, true);
            app.ColumnFilterDel.Text = '❌ Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobileSearchFilter_exported(Container, varargin)

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
