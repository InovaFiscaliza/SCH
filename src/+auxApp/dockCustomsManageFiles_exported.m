classdef dockCustomsManageFiles_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure    matlab.ui.Figure
        GridLayout  matlab.ui.container.GridLayout
        Button      matlab.ui.control.Button
        Delete      matlab.ui.control.Image
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

            if ~isempty(app.Tree.Children)
                delete(app.Tree.Children)
            end

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

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            app.Delete.Enable = ~isempty(app.Tree.CheckedNodes);
            app.Button.Enable = ~isempty(app.Tree.CheckedNodes) && ~isequal(app.Tree.CheckedNodes, app.inputArgs.customsShipmentsTreeNode);
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
                updateToolbar(app)
                
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
            updateToolbar(app)
            
        end

        % Button pushed function: Button
        function onButtonPushed(app, event)
            
            customsShipmentsIdx = app.inputArgs.customsShipmentsIdx;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onCustomsShipmentsFileChangeRequest', customsShipmentsIdx)
            
            % Atualiza gui...
            updateForm(app, customsShipmentsIdx)
            updateToolbar(app)

        end

        % Image clicked function: Delete
        function DeleteClicked(app, event)
            
            % Confirma e apaga fluxo...
            questionMsg = 'Confirma a exclusão do arquivo de remessa selecionado?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
            if userSelection == "Não"
                return
            end

            customsShipmentsIdx = app.inputArgs.customsShipmentsIdx;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onCustomsShipmentsFileDeleteRequest', customsShipmentsIdx)

            % Define o primeiro como novo fluxo, caso exista.
            customsShipments = app.projectData.customsShipments;
            customsShipmentsIdx = [];
            if ~isempty(customsShipments)
                customsShipmentsIdx = 1;
            end
            app.inputArgs.customsShipmentsIdx = customsShipmentsIdx;

            % Atualiza gui...
            updateForm(app, customsShipmentsIdx)
            updateToolbar(app)

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
            app.GridLayout.ColumnWidth = {22, 336, 110};
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
            app.Title.Layout.Column = [1 3];
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Arquivos da remessa</b>'; '<font style="color: gray; font-size: 10px;">Selecione o arquivo que deseja visualizar</font>'};

            % Create Tree
            app.Tree = uitree(app.GridLayout, 'checkbox');
            app.Tree.FontSize = 11;
            app.Tree.Layout.Row = 2;
            app.Tree.Layout.Column = [1 3];

            % Assign Checked Nodes
            app.Tree.CheckedNodesChangedFcn = createCallbackFcn(app, @onTreeCheckedNodesChanged, true);

            % Create Delete
            app.Delete = uiimage(app.GridLayout);
            app.Delete.ImageClickedFcn = createCallbackFcn(app, @DeleteClicked, true);
            app.Delete.Enable = 'off';
            app.Delete.Layout.Row = 4;
            app.Delete.Layout.Column = 1;
            app.Delete.ImageSource = 'Delete_32Red.png';

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
            app.Button.Layout.Column = 3;
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
