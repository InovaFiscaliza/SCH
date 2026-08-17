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
        function updateForm(app, schDetailedIdxs)
            homologation = app.mainApp.schData.detailed.("Homologação"){schDetailedIdxs(1)};
            app.Homologation.Text = sprintf('<font style="color:gray;">Homologação nº</font> <b>%s</b>', homologation);

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
            
            app.Button.Enable = ~isempty(app.Tree.CheckedNodes);
            
        end

        % Button pushed function: Button
        function onButtonPushed(app, event)
            
            if isempty(app.Tree.CheckedNodes)
                onTreeCheckedNodesChanged(app)
                return
            end

            homDetailedIdxs = [app.Tree.CheckedNodes.NodeData];
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onAddSelectedToBucketRequest', homDetailedIdxs)

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
            app.GridLayout.ColumnWidth = {363, 110};
            app.GridLayout.RowHeight = {40, 44, 22, 322, 1, 24};
            app.GridLayout.ColumnSpacing = 5;
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
            app.Title.Text = {'<b>Selecionar modelos inspecionados</b>'; '<font style="color: gray; font-size: 10px;">Selecione os modelos deste certificado que devem ser incluídos na lista de produtos inspecionados</font>'};

            % Create HomologationPanel
            app.HomologationPanel = uipanel(app.GridLayout);
            app.HomologationPanel.AutoResizeChildren = 'off';
            app.HomologationPanel.Layout.Row = 2;
            app.HomologationPanel.Layout.Column = [1 2];

            % Create HomologationGrid
            app.HomologationGrid = uigridlayout(app.HomologationPanel);
            app.HomologationGrid.ColumnWidth = {26, '1x'};
            app.HomologationGrid.RowHeight = {'1x'};
            app.HomologationGrid.BackgroundColor = [1 1 1];

            % Create HomologationIcon
            app.HomologationIcon = uiimage(app.HomologationGrid);
            app.HomologationIcon.Enable = 'off';
            app.HomologationIcon.Layout.Row = 1;
            app.HomologationIcon.Layout.Column = 1;
            app.HomologationIcon.ImageSource = 'circuit-board.svg';

            % Create Homologation
            app.Homologation = uilabel(app.HomologationGrid);
            app.Homologation.WordWrap = 'on';
            app.Homologation.FontColor = [0 0.4471 0.7412];
            app.Homologation.Layout.Row = 1;
            app.Homologation.Layout.Column = 2;
            app.Homologation.Interpreter = 'html';
            app.Homologation.Text = '<font style="color:gray;">Homologação nº</font>';

            % Create TreeLabel
            app.TreeLabel = uilabel(app.GridLayout);
            app.TreeLabel.VerticalAlignment = 'bottom';
            app.TreeLabel.FontSize = 11;
            app.TreeLabel.FontColor = [0 0.451 0.7412];
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
            app.Button.IconAlignment = 'right';
            app.Button.BackgroundColor = [0 0.451 0.7412];
            app.Button.FontSize = 11;
            app.Button.FontColor = [1 1 1];
            app.Button.Enable = 'off';
            app.Button.Layout.Row = 6;
            app.Button.Layout.Column = 2;
            app.Button.Text = 'Confirma inclusão';

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
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
