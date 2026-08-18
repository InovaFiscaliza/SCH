classdef dockCustomsManageFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure    matlab.ui.Figure
        GridLayout  matlab.ui.container.GridLayout
        Button      matlab.ui.control.Button
        Tree        matlab.ui.container.CheckBoxTree
        Title       matlab.ui.control.Label
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
        projectData
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updateForm(app, customsShipmentsIdx)
            customsShipments = app.projectData.customsShipments;
            checkedNodes = matlab.ui.container.TreeNode.empty;

            for ii = 1:numel(customsShipments)
                [~, fileName, fileExt] = fileparts(customsShipments(ii).FileName);
                fileName = [fileName, fileExt];

                fileType = customsShipments(ii).Type;
                numRows = height(customsShipments(ii).Data);

                nodeText = sprintf([ ...
                    '<br><font style="color: gray; font-size: 10px;">Arquivo:</font> %s<br>' ...
                    '<font style="color: gray; font-size: 10px;">Tipo:</font> %s<br>' ...
                    '<font style="color: gray; font-size: 10px;">Número de registros:</font> %d<br>' ...
                ], fileName, fileType, numRows);

                treeNode = uitreenode(app.Tree, 'Text', nodeText, 'NodeData', ii);

                if ii == customsShipmentsIdx
                    checkedNodes(end+1) = treeNode;
                    app.inputArgs.customsShipmentsTreeNode = treeNode;
                end
            end

            if ~isempty(checkedNodes)
                app.Tree.CheckedNodes = checkedNodes;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, customsShipmentsIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                
                addStyle(app.Tree, uistyle('Interpreter', 'html'))
                app.inputArgs = struct('context', context, 'customsShipmentsIdx', customsShipmentsIdx, 'customsShipmentsTreeNode', []);
                updateForm(app, customsShipmentsIdx)
                
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
            
            if isempty(event.CheckedNodes)
                event.Source.CheckedNodes = event.PreviousCheckedNodes;
                return
            end

            app.Tree.CheckedNodes = setdiff(event.Source.CheckedNodes, event.PreviousCheckedNodes);
            if numel(app.Tree.CheckedNodes) > 1
                app.Tree.CheckedNodes = app.Tree.CheckedNodes(1);
            end

            app.inputArgs.customsShipmentsIdx = find(arrayfun(@(x) isequal(x, app.Tree.CheckedNodes), app.Tree.Children), 1);
            app.Button.Enable = ~isequal(app.Tree.CheckedNodes, app.inputArgs.customsShipmentsTreeNode);
            
        end

        % Button pushed function: Button
        function onButtonPushed(app, event)
            
            customsShipmentsIdx = app.inputArgs.customsShipmentsIdx;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onCustomsShipmentsFileChangeRequest', customsShipmentsIdx)

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
            app.GridLayout.RowHeight = {40, 398, 1, 24};
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
            app.Title.Text = {'<b>Arquivos da remessa</b>'; '<font style="color: gray; font-size: 10px;">Selecione o arquivo que deseja visualizar</font>'};

            % Create Tree
            app.Tree = uitree(app.GridLayout, 'checkbox');
            app.Tree.FontSize = 11;
            app.Tree.Layout.Row = 2;
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
            app.Button.Layout.Row = 4;
            app.Button.Layout.Column = 2;
            app.Button.Text = 'Confirma troca';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockCustomsManageFiles_exported(Container, varargin)

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
