classdef dockReportLib_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        SubTabGroup              matlab.ui.container.TabGroup
        SubTab1                  matlab.ui.container.Tab
        SubGrid1                 matlab.ui.container.GridLayout
        report_ProductInfo       matlab.ui.control.Label
        report_ProductInfoImage  matlab.ui.control.Image
        report_ProductInfoLabel  matlab.ui.control.Label
        SubTab2                  matlab.ui.container.Tab
        SubGrid2                 matlab.ui.container.GridLayout
        report_EntityPanel       matlab.ui.container.Panel
        report_EntityGrid        matlab.ui.container.GridLayout
        report_Entity            matlab.ui.control.EditField
        report_EntityLabel       matlab.ui.control.Label
        report_EntityID          matlab.ui.control.EditField
        report_EntityCheck       matlab.ui.control.Image
        report_EntityIDLabel     matlab.ui.control.Label
        report_EntityType        matlab.ui.control.DropDown
        report_EntityTypeLabel   matlab.ui.control.Label
        report_EntityPanelLabel  matlab.ui.control.Label
        report_ProjectName       matlab.ui.control.TextArea
        report_ProjectSave       matlab.ui.control.Image
        report_ProjectOpen       matlab.ui.control.Image
        report_ProjectNew        matlab.ui.control.Image
        report_ProjectLabel      matlab.ui.control.Label
        reportPanel_2            matlab.ui.container.Panel
        reportGrid_2             matlab.ui.container.GridLayout
        reportVersion_2          matlab.ui.control.DropDown
        reportVersionLabel_2     matlab.ui.control.Label
        report_ModelName         matlab.ui.control.DropDown
        reportModelNameLabel_2   matlab.ui.control.Label
        reportLabel_2            matlab.ui.control.Label
        eFiscalizaPanel_2        matlab.ui.container.Panel
        eFiscalizaGrid_2         matlab.ui.container.GridLayout
        reportIssue_2            matlab.ui.control.NumericEditField
        reportIssueLabel_2       matlab.ui.control.Label
        reportUnit_2             matlab.ui.control.DropDown
        reportUnitLabel_2        matlab.ui.control.Label
        reportSystem_2           matlab.ui.control.DropDown
        reportSystemLabel_2      matlab.ui.control.Label
        eFiscalizaLabel_2        matlab.ui.control.Label
        GridLayout               matlab.ui.container.GridLayout
        Document                 matlab.ui.container.GridLayout
        eFiscalizaLabel          matlab.ui.control.Label
        eFiscalizaPanel          matlab.ui.container.Panel
        eFiscalizaGrid           matlab.ui.container.GridLayout
        Image                    matlab.ui.control.Image
        reportIssue              matlab.ui.control.NumericEditField
        reportIssueLabel         matlab.ui.control.Label
        reportUnit               matlab.ui.control.DropDown
        reportUnitLabel          matlab.ui.control.Label
        reportSystem             matlab.ui.control.DropDown
        reportSystemLabel        matlab.ui.control.Label
        reportLabel              matlab.ui.control.Label
        reportPanel              matlab.ui.container.Panel
        reportGrid               matlab.ui.container.GridLayout
        reportVersion            matlab.ui.control.DropDown
        reportVersionLabel       matlab.ui.control.Label
        reportModelName          matlab.ui.control.DropDown
        reportModelNameLabel     matlab.ui.control.Label
        btnOK                    matlab.ui.control.Button
        btnClose                 matlab.ui.control.Image
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


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
        projectData
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function updatePanel(app, context)
            % Inicialização do projectData:
            if isempty(app.projectData.modules.(context).ui.system) && ~isequal(app.projectData.modules.(context).ui.system, app.mainApp.General.Report.system)
                app.projectData.modules.(context).ui.system = app.mainApp.General.Report.system;
            end
            
            if isempty(app.projectData.modules.(context).ui.unit)   && ~isequal(app.projectData.modules.(context).ui.unit,   app.mainApp.General.Report.unit)
                app.projectData.modules.(context).ui.unit   = app.mainApp.General.Report.unit;
            end

            % Atualiza painel:
            app.reportSystem.Value     = app.projectData.modules.(context).ui.system;

            set(app.reportUnit, 'Items', app.mainApp.General.eFiscaliza.defaultValues.unit, ...
                                'Value', app.projectData.modules.(context).ui.unit)
            app.reportIssue.Value      = app.projectData.modules.(context).ui.issue;
            
            set(app.reportModelName, 'Items', app.projectData.modules.(context).ui.templates, ...
                                     'Value', app.projectData.modules.(context).ui.reportModel)
            app.reportVersion.Value    = app.projectData.modules.(context).ui.reportVersion;

            % Estado do botão:
            app.btnOK.Enable = ~isempty(app.reportUnit.Value)                               && ... % unit
                               (app.reportIssue.Value > 0) && ~isinf(app.reportIssue.Value) && ... % issue
                               ~isempty(app.reportModelName.Value);                                % reportModel

            if app.btnOK.Enable
                focus(app.btnOK)
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, indexes)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs   = struct('context', context, 'indexes', indexes);
                app.projectData = app.mainApp.projectData;    
                updatePanel(app, context)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)
            
            context = app.inputArgs.context;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', context)

            delete(app)
            
        end

        % Value changed function: reportIssue, reportModelName, 
        % ...and 3 other components
        function checkValues(app, event)

            context = app.inputArgs.context;

            switch event.Source
                case app.reportSystem;    fieldName = 'system';
                case app.reportUnit;      fieldName = 'unit';
                case app.reportIssue;     fieldName = 'issue';
                case app.reportModelName; fieldName = 'reportModel';
                case app.reportVersion;   fieldName = 'reportVersion';
            end
            updateUiInfo(app.projectData, context, fieldName, event.Value)
            updatePanel(app, context)
            
        end

        % Button pushed function: btnOK
        function btnOKButtonPushed(app, event)
            
            context = app.inputArgs.context;
            indexes = app.inputArgs.indexes;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'reportUserConfirmation', context, indexes)

        end

        % Image clicked function: Image
        function ImageClicked(app, event)
            
            % <VALIDAÇÕES>
            context = app.inputArgs.context;
            
            msg = '';
            if ~report_checkEFiscalizaIssueId(app.mainApp, app.projectData.modules.(context).ui.issue)
                msg = sprintf('O número da inspeção "%.0f" é inválido.', app.projectData.modules.(context).ui.issue);
            elseif isempty(app.projectData.modules.(context).ui.system)
                msg = 'Ambiente do eFiscaliza precisa ser selecionado.';
            end

            if ~isempty(msg)
                ui.Dialog(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            issueDetails = app.projectData.modules.(context).ui.issueDetails;
            if ~isempty(issueDetails) && (issueDetails.issueId == app.reportIssue.Value)
                report_showIssueDetails(app.mainApp, context)
            else
                if isempty(app.mainApp.eFiscalizaObj) || ~isvalid(app.mainApp.eFiscalizaObj)
                    dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                    dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                    sendEventToHTMLSource(app.callingApp.jsBackDoor, 'customForm', struct('UUID', 'eFiscalizaSignInPage:IssueQuery', 'Fields', dialogBox, 'Context', context))
                else                    
                    report_queryIssueDetails(app.mainApp, [], context)
                end
            end
            % </PROCESSO>

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
                app.UIFigure.Position = [100 100 460 308];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_16.png';
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
            app.Document.RowHeight = {17, 100, 22, 70, 1, 22};
            app.Document.RowSpacing = 5;
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [1 1 1];

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @btnOKButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 6;
            app.btnOK.Layout.Column = 2;
            app.btnOK.Text = 'OK';

            % Create reportPanel
            app.reportPanel = uipanel(app.Document);
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 4;
            app.reportPanel.Layout.Column = [1 2];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {'1x', 150, 150};
            app.reportGrid.RowHeight = {22, 22};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [1 1 1];

            % Create reportModelNameLabel
            app.reportModelNameLabel = uilabel(app.reportGrid);
            app.reportModelNameLabel.FontSize = 11;
            app.reportModelNameLabel.Layout.Row = 1;
            app.reportModelNameLabel.Layout.Column = 1;
            app.reportModelNameLabel.Text = 'Modelo (.json):';

            % Create reportModelName
            app.reportModelName = uidropdown(app.reportGrid);
            app.reportModelName.Items = {''};
            app.reportModelName.ValueChangedFcn = createCallbackFcn(app, @checkValues, true);
            app.reportModelName.FontSize = 11;
            app.reportModelName.BackgroundColor = [1 1 1];
            app.reportModelName.Layout.Row = 1;
            app.reportModelName.Layout.Column = [2 3];
            app.reportModelName.Value = '';

            % Create reportVersionLabel
            app.reportVersionLabel = uilabel(app.reportGrid);
            app.reportVersionLabel.WordWrap = 'on';
            app.reportVersionLabel.FontSize = 11;
            app.reportVersionLabel.Layout.Row = 2;
            app.reportVersionLabel.Layout.Column = 1;
            app.reportVersionLabel.Text = 'Versão do relatório:';

            % Create reportVersion
            app.reportVersion = uidropdown(app.reportGrid);
            app.reportVersion.Items = {'Preliminar', 'Definitiva'};
            app.reportVersion.ValueChangedFcn = createCallbackFcn(app, @checkValues, true);
            app.reportVersion.FontSize = 11;
            app.reportVersion.BackgroundColor = [1 1 1];
            app.reportVersion.Layout.Row = 2;
            app.reportVersion.Layout.Column = 3;
            app.reportVersion.Value = 'Preliminar';

            % Create reportLabel
            app.reportLabel = uilabel(app.Document);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 3;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.Document);
            app.eFiscalizaPanel.Layout.Row = 2;
            app.eFiscalizaPanel.Layout.Column = [1 2];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {'1x', 123, 22};
            app.eFiscalizaGrid.RowHeight = {22, 22, 22};
            app.eFiscalizaGrid.ColumnSpacing = 5;
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create reportSystemLabel
            app.reportSystemLabel = uilabel(app.eFiscalizaGrid);
            app.reportSystemLabel.FontSize = 11;
            app.reportSystemLabel.Layout.Row = 1;
            app.reportSystemLabel.Layout.Column = 1;
            app.reportSystemLabel.Text = 'Ambiente do sistema de gestão à fiscalização:';

            % Create reportSystem
            app.reportSystem = uidropdown(app.eFiscalizaGrid);
            app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS', 'eFiscaliza HM', 'eFiscaliza DS'};
            app.reportSystem.ValueChangedFcn = createCallbackFcn(app, @checkValues, true);
            app.reportSystem.FontSize = 11;
            app.reportSystem.BackgroundColor = [1 1 1];
            app.reportSystem.Layout.Row = 1;
            app.reportSystem.Layout.Column = [2 3];
            app.reportSystem.Value = 'eFiscaliza';

            % Create reportUnitLabel
            app.reportUnitLabel = uilabel(app.eFiscalizaGrid);
            app.reportUnitLabel.FontSize = 11;
            app.reportUnitLabel.Layout.Row = 2;
            app.reportUnitLabel.Layout.Column = 1;
            app.reportUnitLabel.Text = 'Unidade responsável pela fiscalização:';

            % Create reportUnit
            app.reportUnit = uidropdown(app.eFiscalizaGrid);
            app.reportUnit.Items = {};
            app.reportUnit.ValueChangedFcn = createCallbackFcn(app, @checkValues, true);
            app.reportUnit.FontSize = 11;
            app.reportUnit.BackgroundColor = [1 1 1];
            app.reportUnit.Layout.Row = 2;
            app.reportUnit.Layout.Column = [2 3];
            app.reportUnit.Value = {};

            % Create reportIssueLabel
            app.reportIssueLabel = uilabel(app.eFiscalizaGrid);
            app.reportIssueLabel.FontSize = 11;
            app.reportIssueLabel.Layout.Row = 3;
            app.reportIssueLabel.Layout.Column = 1;
            app.reportIssueLabel.Text = 'Atividade de inspeção (# ID):';

            % Create reportIssue
            app.reportIssue = uieditfield(app.eFiscalizaGrid, 'numeric');
            app.reportIssue.Limits = [-1 Inf];
            app.reportIssue.RoundFractionalValues = 'on';
            app.reportIssue.ValueDisplayFormat = '%d';
            app.reportIssue.ValueChangedFcn = createCallbackFcn(app, @checkValues, true);
            app.reportIssue.FontSize = 11;
            app.reportIssue.FontColor = [0.149 0.149 0.149];
            app.reportIssue.Layout.Row = 3;
            app.reportIssue.Layout.Column = 2;
            app.reportIssue.Value = -1;

            % Create Image
            app.Image = uiimage(app.eFiscalizaGrid);
            app.Image.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.Image.Tooltip = {'Detalhes da inspeção'};
            app.Image.Layout.Row = 3;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = 'Zoom_32.png';

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.Document);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 1;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'eFISCALIZA';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.UIFigure);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Position = [537 -383 320 560];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'INSPEÇÃO';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {'1x'};
            app.SubGrid1.RowHeight = {17, '1x'};
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create report_ProductInfoLabel
            app.report_ProductInfoLabel = uilabel(app.SubGrid1);
            app.report_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.report_ProductInfoLabel.FontSize = 10;
            app.report_ProductInfoLabel.Layout.Row = 1;
            app.report_ProductInfoLabel.Layout.Column = 1;
            app.report_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create report_ProductInfoImage
            app.report_ProductInfoImage = uiimage(app.SubGrid1);
            app.report_ProductInfoImage.ScaleMethod = 'none';
            app.report_ProductInfoImage.Layout.Row = 2;
            app.report_ProductInfoImage.Layout.Column = 1;
            app.report_ProductInfoImage.ImageSource = 'warning.svg';

            % Create report_ProductInfo
            app.report_ProductInfo = uilabel(app.SubGrid1);
            app.report_ProductInfo.VerticalAlignment = 'top';
            app.report_ProductInfo.WordWrap = 'on';
            app.report_ProductInfo.FontSize = 11;
            app.report_ProductInfo.Layout.Row = 2;
            app.report_ProductInfo.Layout.Column = 1;
            app.report_ProductInfo.Interpreter = 'html';
            app.report_ProductInfo.Text = '';

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'PROJETO';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {'1x', 22, 22, 22};
            app.SubGrid2.RowHeight = {17, 44, 22, 110, 22, 100, 22, '1x'};
            app.SubGrid2.ColumnSpacing = 5;
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create eFiscalizaLabel_2
            app.eFiscalizaLabel_2 = uilabel(app.SubGrid2);
            app.eFiscalizaLabel_2.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel_2.FontSize = 10;
            app.eFiscalizaLabel_2.Layout.Row = 5;
            app.eFiscalizaLabel_2.Layout.Column = 1;
            app.eFiscalizaLabel_2.Text = 'eFISCALIZA';

            % Create eFiscalizaPanel_2
            app.eFiscalizaPanel_2 = uipanel(app.SubGrid2);
            app.eFiscalizaPanel_2.AutoResizeChildren = 'off';
            app.eFiscalizaPanel_2.Layout.Row = 6;
            app.eFiscalizaPanel_2.Layout.Column = [1 4];

            % Create eFiscalizaGrid_2
            app.eFiscalizaGrid_2 = uigridlayout(app.eFiscalizaPanel_2);
            app.eFiscalizaGrid_2.ColumnWidth = {'1x', 150};
            app.eFiscalizaGrid_2.RowHeight = {22, 22, 22, '1x'};
            app.eFiscalizaGrid_2.RowSpacing = 5;
            app.eFiscalizaGrid_2.BackgroundColor = [1 1 1];

            % Create reportSystemLabel_2
            app.reportSystemLabel_2 = uilabel(app.eFiscalizaGrid_2);
            app.reportSystemLabel_2.FontSize = 11;
            app.reportSystemLabel_2.Layout.Row = 1;
            app.reportSystemLabel_2.Layout.Column = 1;
            app.reportSystemLabel_2.Text = 'Sistema:';

            % Create reportSystem_2
            app.reportSystem_2 = uidropdown(app.eFiscalizaGrid_2);
            app.reportSystem_2.Items = {'eFiscaliza', 'eFiscaliza TS'};
            app.reportSystem_2.FontSize = 11;
            app.reportSystem_2.BackgroundColor = [1 1 1];
            app.reportSystem_2.Layout.Row = 1;
            app.reportSystem_2.Layout.Column = 2;
            app.reportSystem_2.Value = 'eFiscaliza';

            % Create reportUnitLabel_2
            app.reportUnitLabel_2 = uilabel(app.eFiscalizaGrid_2);
            app.reportUnitLabel_2.FontSize = 11;
            app.reportUnitLabel_2.Layout.Row = 2;
            app.reportUnitLabel_2.Layout.Column = 1;
            app.reportUnitLabel_2.Text = 'Unidade responsável:';

            % Create reportUnit_2
            app.reportUnit_2 = uidropdown(app.eFiscalizaGrid_2);
            app.reportUnit_2.Items = {};
            app.reportUnit_2.FontSize = 11;
            app.reportUnit_2.BackgroundColor = [1 1 1];
            app.reportUnit_2.Layout.Row = 2;
            app.reportUnit_2.Layout.Column = 2;
            app.reportUnit_2.Value = {};

            % Create reportIssueLabel_2
            app.reportIssueLabel_2 = uilabel(app.eFiscalizaGrid_2);
            app.reportIssueLabel_2.FontSize = 11;
            app.reportIssueLabel_2.Layout.Row = [3 4];
            app.reportIssueLabel_2.Layout.Column = 1;
            app.reportIssueLabel_2.Text = {'Atividade de inspeção:'; '(# ID)'};

            % Create reportIssue_2
            app.reportIssue_2 = uieditfield(app.eFiscalizaGrid_2, 'numeric');
            app.reportIssue_2.Limits = [-1 Inf];
            app.reportIssue_2.RoundFractionalValues = 'on';
            app.reportIssue_2.ValueDisplayFormat = '%d';
            app.reportIssue_2.FontSize = 11;
            app.reportIssue_2.FontColor = [0.149 0.149 0.149];
            app.reportIssue_2.Layout.Row = 3;
            app.reportIssue_2.Layout.Column = 2;
            app.reportIssue_2.Value = -1;

            % Create reportLabel_2
            app.reportLabel_2 = uilabel(app.SubGrid2);
            app.reportLabel_2.VerticalAlignment = 'bottom';
            app.reportLabel_2.FontSize = 10;
            app.reportLabel_2.Layout.Row = 7;
            app.reportLabel_2.Layout.Column = 1;
            app.reportLabel_2.Text = 'RELATÓRIO';

            % Create reportPanel_2
            app.reportPanel_2 = uipanel(app.SubGrid2);
            app.reportPanel_2.AutoResizeChildren = 'off';
            app.reportPanel_2.BackgroundColor = [1 1 1];
            app.reportPanel_2.Layout.Row = 8;
            app.reportPanel_2.Layout.Column = [1 4];

            % Create reportGrid_2
            app.reportGrid_2 = uigridlayout(app.reportPanel_2);
            app.reportGrid_2.ColumnWidth = {'1x', 150};
            app.reportGrid_2.RowHeight = {22, 22};
            app.reportGrid_2.RowSpacing = 5;
            app.reportGrid_2.BackgroundColor = [1 1 1];

            % Create reportModelNameLabel_2
            app.reportModelNameLabel_2 = uilabel(app.reportGrid_2);
            app.reportModelNameLabel_2.FontSize = 11;
            app.reportModelNameLabel_2.Layout.Row = 1;
            app.reportModelNameLabel_2.Layout.Column = 1;
            app.reportModelNameLabel_2.Text = 'Modelo (.json):';

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.reportGrid_2);
            app.report_ModelName.Items = {''};
            app.report_ModelName.FontSize = 11;
            app.report_ModelName.BackgroundColor = [1 1 1];
            app.report_ModelName.Layout.Row = 1;
            app.report_ModelName.Layout.Column = 2;
            app.report_ModelName.Value = '';

            % Create reportVersionLabel_2
            app.reportVersionLabel_2 = uilabel(app.reportGrid_2);
            app.reportVersionLabel_2.WordWrap = 'on';
            app.reportVersionLabel_2.FontSize = 11;
            app.reportVersionLabel_2.Layout.Row = 2;
            app.reportVersionLabel_2.Layout.Column = 1;
            app.reportVersionLabel_2.Text = 'Versão do relatório:';

            % Create reportVersion_2
            app.reportVersion_2 = uidropdown(app.reportGrid_2);
            app.reportVersion_2.Items = {'Preliminar', 'Definitiva'};
            app.reportVersion_2.FontSize = 11;
            app.reportVersion_2.BackgroundColor = [1 1 1];
            app.reportVersion_2.Layout.Row = 2;
            app.reportVersion_2.Layout.Column = 2;
            app.reportVersion_2.Value = 'Preliminar';

            % Create report_ProjectLabel
            app.report_ProjectLabel = uilabel(app.SubGrid2);
            app.report_ProjectLabel.VerticalAlignment = 'bottom';
            app.report_ProjectLabel.FontSize = 10;
            app.report_ProjectLabel.Layout.Row = 1;
            app.report_ProjectLabel.Layout.Column = 1;
            app.report_ProjectLabel.Text = 'ARQUIVO';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.SubGrid2);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 2;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = 'AddFiles_36.png';

            % Create report_ProjectOpen
            app.report_ProjectOpen = uiimage(app.SubGrid2);
            app.report_ProjectOpen.Tooltip = {'Abre projeto'};
            app.report_ProjectOpen.Layout.Row = 1;
            app.report_ProjectOpen.Layout.Column = 3;
            app.report_ProjectOpen.VerticalAlignment = 'bottom';
            app.report_ProjectOpen.ImageSource = 'OpenFile_36x36.png';

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.SubGrid2);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 1;
            app.report_ProjectSave.Layout.Column = 4;
            app.report_ProjectSave.VerticalAlignment = 'bottom';
            app.report_ProjectSave.ImageSource = 'SaveFile_36.png';

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.SubGrid2);
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 2;
            app.report_ProjectName.Layout.Column = [1 4];

            % Create report_EntityPanelLabel
            app.report_EntityPanelLabel = uilabel(app.SubGrid2);
            app.report_EntityPanelLabel.VerticalAlignment = 'bottom';
            app.report_EntityPanelLabel.FontSize = 10;
            app.report_EntityPanelLabel.Layout.Row = 3;
            app.report_EntityPanelLabel.Layout.Column = 1;
            app.report_EntityPanelLabel.Text = 'FISCALIZADA';

            % Create report_EntityPanel
            app.report_EntityPanel = uipanel(app.SubGrid2);
            app.report_EntityPanel.AutoResizeChildren = 'off';
            app.report_EntityPanel.Layout.Row = 4;
            app.report_EntityPanel.Layout.Column = [1 4];

            % Create report_EntityGrid
            app.report_EntityGrid = uigridlayout(app.report_EntityPanel);
            app.report_EntityGrid.ColumnWidth = {'1x', 124, 16};
            app.report_EntityGrid.RowHeight = {17, 22, 17, 22};
            app.report_EntityGrid.RowSpacing = 5;
            app.report_EntityGrid.Padding = [10 10 10 5];
            app.report_EntityGrid.BackgroundColor = [1 1 1];

            % Create report_EntityTypeLabel
            app.report_EntityTypeLabel = uilabel(app.report_EntityGrid);
            app.report_EntityTypeLabel.VerticalAlignment = 'bottom';
            app.report_EntityTypeLabel.FontSize = 11;
            app.report_EntityTypeLabel.Layout.Row = 1;
            app.report_EntityTypeLabel.Layout.Column = 1;
            app.report_EntityTypeLabel.Text = 'Tipo:';

            % Create report_EntityType
            app.report_EntityType = uidropdown(app.report_EntityGrid);
            app.report_EntityType.Items = {'', 'Importador', 'Fornecedor', 'Usuário'};
            app.report_EntityType.FontSize = 11;
            app.report_EntityType.BackgroundColor = [1 1 1];
            app.report_EntityType.Layout.Row = 2;
            app.report_EntityType.Layout.Column = 1;
            app.report_EntityType.Value = '';

            % Create report_EntityIDLabel
            app.report_EntityIDLabel = uilabel(app.report_EntityGrid);
            app.report_EntityIDLabel.VerticalAlignment = 'bottom';
            app.report_EntityIDLabel.WordWrap = 'on';
            app.report_EntityIDLabel.FontSize = 11;
            app.report_EntityIDLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityIDLabel.Layout.Row = 1;
            app.report_EntityIDLabel.Layout.Column = 2;
            app.report_EntityIDLabel.Text = 'CNPJ/CPF:';

            % Create report_EntityCheck
            app.report_EntityCheck = uiimage(app.report_EntityGrid);
            app.report_EntityCheck.Enable = 'off';
            app.report_EntityCheck.Layout.Row = 1;
            app.report_EntityCheck.Layout.Column = 3;
            app.report_EntityCheck.VerticalAlignment = 'bottom';
            app.report_EntityCheck.ImageSource = 'Info_36.png';

            % Create report_EntityID
            app.report_EntityID = uieditfield(app.report_EntityGrid, 'text');
            app.report_EntityID.FontSize = 11;
            app.report_EntityID.Enable = 'off';
            app.report_EntityID.Layout.Row = 2;
            app.report_EntityID.Layout.Column = [2 3];

            % Create report_EntityLabel
            app.report_EntityLabel = uilabel(app.report_EntityGrid);
            app.report_EntityLabel.VerticalAlignment = 'bottom';
            app.report_EntityLabel.WordWrap = 'on';
            app.report_EntityLabel.FontSize = 11;
            app.report_EntityLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityLabel.Layout.Row = 3;
            app.report_EntityLabel.Layout.Column = 1;
            app.report_EntityLabel.Text = 'Nome:';

            % Create report_Entity
            app.report_Entity = uieditfield(app.report_EntityGrid, 'text');
            app.report_Entity.FontSize = 11;
            app.report_Entity.Enable = 'off';
            app.report_Entity.Layout.Row = 4;
            app.report_Entity.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockReportLib_exported(Container, varargin)

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
