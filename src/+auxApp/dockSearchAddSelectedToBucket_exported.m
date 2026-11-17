classdef dockSearchAddSelectedToBucket_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        Button             matlab.ui.control.Button
        Tree               matlab.ui.container.CheckBoxTree
        TreeLabel          matlab.ui.control.Label
        HomologationPanel  matlab.ui.container.Panel
        HomologationGrid   matlab.ui.container.GridLayout
        Homologation       matlab.ui.control.Label
        HomologationIcon   matlab.ui.control.Image
        Title              matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
        alreadyIncludedIdxs = []
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
        function checkedIdxs = getCheckedIdxs(app)
            checkedIdxs = [];
            if ~isempty(app.Tree.CheckedNodes)
                checkedIdxs = [app.Tree.CheckedNodes.NodeData];
            end
        end

        %-----------------------------------------------------------------%
        function updateForm(app, schDetailedIdxs)
            app.alreadyIncludedIdxs = [];

            homologation = app.mainApp.schData.detailed.("Homologação"){schDetailedIdxs(1)};
            app.Homologation.Text = sprintf('%s', homologation);

            checkedNodes = matlab.ui.container.TreeNode.empty;

            for ii = 1:numel(schDetailedIdxs)
                idx = schDetailedIdxs(ii);

                nodeText = sprintf([ ...
                    '<br><font style="color: gray; font-size: 10px;">Solicitante:</font> %s<br>' ...
                    '<font style="color: gray; font-size: 10px;">Fabricante:</font> %s<br>' ...
                    '<font style="color: gray; font-size: 10px;">Modelo:</font> %s<br>' ...
                    '<font style="color: gray; font-size: 10px;">Nome comercial:</font> %s<br><br>', ...
                ], app.mainApp.schData.detailed.("Solicitante"){idx}, ...
                   app.mainApp.schData.detailed.("Fabricante"){idx}, ...
                   app.mainApp.schData.detailed.("Modelo"){idx}, ...
                   app.mainApp.schData.detailed.("Nome Comercial"){idx} ...
                );

                treeNode = uitreenode(app.Tree, 'Text', nodeText, 'NodeData', idx);

                [~, productHash] = model.ProjectBase.initializeInspectedProduct('Homologado', app.mainApp.General, app.mainApp.schData.detailed, idx);    
                if ismember(productHash, app.mainApp.projectData.inspectedProducts.("Hash"))
                    checkedNodes(end+1) = treeNode;
                    app.alreadyIncludedIdxs(end+1) = idx;
                end
            end

            if ~isempty(checkedNodes)
                app.Tree.CheckedNodes = checkedNodes;
            end

            if numel(app.Tree.Children) == numel(checkedNodes)
                app.Tree.Enable = 'off';
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, schDetailedIdxs)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                addStyle(app.Tree, uistyle('Interpreter', 'html'))
                updateForm(app, schDetailedIdxs)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: Tree
        function onTreeCheckedNodesChanged(app, event)
            
            nodes = app.Tree.Children;
            checkedIdxs = getCheckedIdxs(app);

            % Itens já incluídos na lista de produtos inspecionados não 
            % podem ser desmarcados: se isso ocorreu, restaura-se a marcação.
            if ~all(ismember(app.alreadyIncludedIdxs, checkedIdxs))
                restoredIdxs = union(checkedIdxs, app.alreadyIncludedIdxs);
                app.Tree.CheckedNodes = nodes(ismember([nodes.NodeData], restoredIdxs));
                return
            end

            app.Button.Enable = ~isempty(setdiff(checkedIdxs, app.alreadyIncludedIdxs));
            
        end

        % Button pushed function: Button
        function onButtonPushed(app, event)
            
            newIdxs = setdiff(getCheckedIdxs(app), app.alreadyIncludedIdxs);
            if isempty(newIdxs)
                app.Button.Enable = 'off';
                return
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onAddSelectedToBucketRequest', newIdxs)

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
                app.UIFigure.Position = [100 100 518 518];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_32.png';
                app.UIFigure.Resize = 'off';
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
            app.GridLayout.ColumnWidth = {303, 170};
            app.GridLayout.RowHeight = {40, 54, 22, 308, 34};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.VerticalAlignment = 'top';
            app.Title.WordWrap = 'on';
            app.Title.FontSize = 15;
            app.Title.FontColor = [0 0.1294 0.2392];
            app.Title.Layout.Row = 1;
            app.Title.Layout.Column = [1 2];
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Selecionar modelos inspecionados</b>'; '<font style="font-size: 11px;">Selecione os modelos deste certificado que devem ser incluídos na lista de produtos inspecionados</font>'};

            % Create HomologationPanel
            app.HomologationPanel = uipanel(app.GridLayout);
            app.HomologationPanel.AutoResizeChildren = 'off';
            app.HomologationPanel.Layout.Row = 2;
            app.HomologationPanel.Layout.Column = [1 2];

            % Create HomologationGrid
            app.HomologationGrid = uigridlayout(app.HomologationPanel);
            app.HomologationGrid.ColumnWidth = {26, '1x'};
            app.HomologationGrid.RowHeight = {32};
            app.HomologationGrid.BackgroundColor = [1 1 1];

            % Create HomologationIcon
            app.HomologationIcon = uiimage(app.HomologationGrid);
            app.HomologationIcon.Layout.Row = 1;
            app.HomologationIcon.Layout.Column = 1;
            app.HomologationIcon.ImageSource = 'package.svg';

            % Create Homologation
            app.Homologation = uilabel(app.HomologationGrid);
            app.Homologation.FontSize = 16;
            app.Homologation.FontWeight = 'bold';
            app.Homologation.FontColor = [0 0.1294 0.2392];
            app.Homologation.Layout.Row = 1;
            app.Homologation.Layout.Column = 2;
            app.Homologation.Text = '';

            % Create TreeLabel
            app.TreeLabel = uilabel(app.GridLayout);
            app.TreeLabel.VerticalAlignment = 'bottom';
            app.TreeLabel.FontSize = 11;
            app.TreeLabel.FontColor = [0 0.1294 0.2392];
            app.TreeLabel.Layout.Row = 3;
            app.TreeLabel.Layout.Column = 1;
            app.TreeLabel.Text = 'Registros encontrados';

            % Create Tree
            app.Tree = uitree(app.GridLayout, 'checkbox');
            app.Tree.FontSize = 11;
            app.Tree.Layout.Row = 4;
            app.Tree.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.Tree.CheckedNodesChangedFcn = createCallbackFcn(app, @onTreeCheckedNodesChanged, true);

            % Create Button
            app.Button = uibutton(app.GridLayout, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @onButtonPushed, true);
            app.Button.Tag = 'OK';
            app.Button.Icon = 'add-16px-white.svg';
            app.Button.BackgroundColor = [0 0.451 0.7412];
            app.Button.FontSize = 11;
            app.Button.FontColor = [1 1 1];
            app.Button.Enable = 'off';
            app.Button.Layout.Row = 5;
            app.Button.Layout.Column = 2;
            app.Button.Text = '   Confirma inclusão';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockSearchAddSelectedToBucket_exported(Container, varargin)

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
