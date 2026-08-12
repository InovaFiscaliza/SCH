classdef dockAddSelectedToBucket_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure    matlab.ui.Figure
        GridLayout  matlab.ui.container.GridLayout
        Button      matlab.ui.control.Button
        Tree        matlab.ui.container.CheckBoxTree
        Label       matlab.ui.control.Label
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

            app.Label.Text = sprintf([ ...
                '<p style="text-align: justify;">A homologação nº <font ' ...
                'style="font-size: 14px;"><b>%s</b></font> possui mais de ' ...
                'um registro de "Solicitante", "Fabricante", "Modelo" ou ' ...
                '"Nome Comercial". Selecione, na lista abaixo, os registros ' ...
                'que devem ser incluídos na lista de produtos sob análise.</p>' ...
            ], homologation);

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

                uitreenode(app.Tree, 'Text', nodeText, 'NodeData', idx);
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
                app.UIFigure.Position = [100 100 518 486];
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
            app.GridLayout.ColumnWidth = {'1x', 90};
            app.GridLayout.RowHeight = {56, '1x', 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.VerticalAlignment = 'top';
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 11;
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = [1 2];
            app.Label.Interpreter = 'html';
            app.Label.Text = '';

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
            app.Button.BackgroundColor = [0.9804 0.9804 0.9804];
            app.Button.Enable = 'off';
            app.Button.Layout.Row = 3;
            app.Button.Layout.Column = 2;
            app.Button.Text = 'OK';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockAddSelectedToBucket_exported(Container, varargin)

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
