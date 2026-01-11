classdef dockAnnotation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        Document             matlab.ui.container.GridLayout
        btnOK                matlab.ui.control.Button
        attributeValue       matlab.ui.control.TextArea
        attributeValueLabel  matlab.ui.control.Label
        attributeName        matlab.ui.control.DropDown
        attributeNameLabel   matlab.ui.control.Label
        homologationInfo     matlab.ui.control.Label
        btnClose             matlab.ui.control.Image
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
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updateForm(app, focusedHomologation)
            homMask = strcmp(app.mainApp.schDataTable.("Homologação"), focusedHomologation);
            annotationHomMask = strcmp(app.mainApp.annotationTable.("Homologação"), focusedHomologation);

            relatedSCHTable = app.mainApp.schDataTable(homMask, :);
            relatedAnnotationTable = app.mainApp.annotationTable(annotationHomMask, :);

            set( ...
                app.homologationInfo, ...
                'Text', util.HtmlTextGenerator.ProductInfoUnderAnnotation(relatedSCHTable, relatedAnnotationTable), ...
                'Tag', focusedHomologation ...
            )

            app.attributeName.Value  = '';
            app.attributeValue.Value = '';
            app.btnOK.Enable = false;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, focusedHomologation)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)
                updateForm(app, focusedHomologation)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end            
            
        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcnCallFromPopupApp', 'SEARCH', 'auxApp.dockAnnotation')
            delete(app)
            
        end

        % Value changing function: attributeValue
        function attributeValueChanged(app, event)

            currentValue = textFormatGUI.cellstr2TextField(event.Value);
            btnOKEnable  = ~isempty(currentValue);

            if app.btnOK.Enable ~= btnOKEnable
                app.btnOK.Enable = btnOKEnable;
            end

        end

        % Button pushed function: btnOK
        function btnOKPushed(app, event)
           
            currentValue = textFormatGUI.cellstr2TextField(app.attributeValue.Value);

            if ~isempty(currentValue)
                focusedHomologation = app.homologationInfo.Tag;
                currentAttribute = app.attributeName.Value;

                ipcMainMatlabCallsHandler(app.mainApp, app, 'onProductAnnotationAdded', focusedHomologation, currentAttribute, currentValue)
                updateForm(app, focusedHomologation)
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
                app.UIFigure.Position = [100 100 412 300];
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
            app.Document.ColumnWidth = {'1x', 90};
            app.Document.RowHeight = {'1x', 17, 22, 22, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create homologationInfo
            app.homologationInfo = uilabel(app.Document);
            app.homologationInfo.VerticalAlignment = 'top';
            app.homologationInfo.WordWrap = 'on';
            app.homologationInfo.Layout.Row = 1;
            app.homologationInfo.Layout.Column = [1 2];
            app.homologationInfo.Interpreter = 'html';
            app.homologationInfo.Text = '';

            % Create attributeNameLabel
            app.attributeNameLabel = uilabel(app.Document);
            app.attributeNameLabel.VerticalAlignment = 'bottom';
            app.attributeNameLabel.FontSize = 11;
            app.attributeNameLabel.Layout.Row = 2;
            app.attributeNameLabel.Layout.Column = [1 2];
            app.attributeNameLabel.Text = 'Atributo:';

            % Create attributeName
            app.attributeName = uidropdown(app.Document);
            app.attributeName.Items = {'', 'Fornecedor', 'Fabricante', 'Modelo', 'EAN', 'Outras informações'};
            app.attributeName.FontSize = 11;
            app.attributeName.BackgroundColor = [1 1 1];
            app.attributeName.Layout.Row = 3;
            app.attributeName.Layout.Column = [1 2];
            app.attributeName.Value = '';

            % Create attributeValueLabel
            app.attributeValueLabel = uilabel(app.Document);
            app.attributeValueLabel.VerticalAlignment = 'bottom';
            app.attributeValueLabel.FontSize = 11;
            app.attributeValueLabel.Layout.Row = 4;
            app.attributeValueLabel.Layout.Column = [1 2];
            app.attributeValueLabel.Text = 'Valor:';

            % Create attributeValue
            app.attributeValue = uitextarea(app.Document);
            app.attributeValue.ValueChangingFcn = createCallbackFcn(app, @attributeValueChanged, true);
            app.attributeValue.FontSize = 11;
            app.attributeValue.Layout.Row = 5;
            app.attributeValue.Layout.Column = [1 2];

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @btnOKPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 6;
            app.btnOK.Layout.Column = 2;
            app.btnOK.Text = 'OK';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockAnnotation_exported(Container, varargin)

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
