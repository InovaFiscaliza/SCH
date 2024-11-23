classdef dockProductInfo_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        Document                      matlab.ui.container.GridLayout
        report_NewProduct             matlab.ui.control.Image
        Image_2                       matlab.ui.control.Image
        Image                         matlab.ui.control.Image
        report_nRows                  matlab.ui.control.Label
        btnOK                         matlab.ui.control.Button
        ParametersPanel               matlab.ui.container.Panel
        report_EditableInfoGrid       matlab.ui.container.GridLayout
        report_Violation_3            matlab.ui.control.DropDown
        report_ViolationLabel_3       matlab.ui.control.Label
        report_Violation              matlab.ui.control.DropDown
        report_ViolationLabel         matlab.ui.control.Label
        report_Situation              matlab.ui.control.DropDown
        report_SituationLabel         matlab.ui.control.Label
        report_IDAduanaLabel          matlab.ui.control.Label
        report_IDAduana               matlab.ui.control.EditField
        ImportadorEditField           matlab.ui.control.EditField
        ImportadorEditFieldLabel      matlab.ui.control.Label
        report_Violation_2            matlab.ui.control.DropDown
        report_ViolationLabel_2       matlab.ui.control.Label
        FabricanteEditField           matlab.ui.control.EditField
        FabricanteEditFieldLabel      matlab.ui.control.Label
        QtdretidasRFBEditField        matlab.ui.control.NumericEditField
        QtdretidasRFBLabel            matlab.ui.control.Label
        QtdapreendidasEditField       matlab.ui.control.NumericEditField
        QtdapreendidasEditFieldLabel  matlab.ui.control.Label
        QtdlacradasEditField          matlab.ui.control.NumericEditField
        QtdlacradasEditFieldLabel     matlab.ui.control.Label
        QtdestoqueaduanaEditField     matlab.ui.control.NumericEditField
        QtdestoqueaduanaLabel         matlab.ui.control.Label
        QtdusovendidaEditField        matlab.ui.control.NumericEditField
        QtdusovendidaLabel            matlab.ui.control.Label
        ValorunitrioREditField        matlab.ui.control.NumericEditField
        ValorunitrioRLabel            matlab.ui.control.Label
        EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox  matlab.ui.control.CheckBox
        EvidenciadoUSOdoprodutoCheckBox  matlab.ui.control.CheckBox
        EvidenciadoquesetratadeprodutoqueusaRFCheckBox  matlab.ui.control.CheckBox
        FabricanteEditFieldLabel_2    matlab.ui.control.Label
        FabricanteEditField_2         matlab.ui.control.EditField
        report_Notes                  matlab.ui.control.TextArea
        report_NotesLabel             matlab.ui.control.Label
        report_nHom                   matlab.ui.control.EditField
        report_nHomLabel              matlab.ui.control.Label
        btnClose                      matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true

        CallingApp
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            % idxThread = app.CallingApp.play_PlotPanel.UserData.NodeData;
            
            % if ~isempty(selected2showedHom)
            %     % Primeiro ajusta o painel com botões de rádio...
            %     if ~strcmp(selected2showedHom, '-1')
            %         app.report_productSituation1.Value = 1; % HOMOLOGADO
            %     else
            %         app.report_productSituation2.Value = 1; % NÃO HOMOLOGADO
            %     end
            %     set(app.report_productSituationPanel.Children, 'Enable', 0)
            % 
            %     % O título do painel e a imagem para confirmar alteração...
            %     app.report_EditableInfoLabel.Text      = 'EDIÇÃO COMPLEMENTAR À DA TABELA';
            %     app.report_EditOrAddButton.ImageSource = app.report_EditOrAddButton.UserData.iconOptions{1};
            % 
            %     % E depois as caixas de edição abaixo...
            %     idx = selectedRow;
            %     set(app.report_nHom, 'Enable', 0, 'Value', app.projectData.listOfProducts.("Homologação"){idx})
            %     app.ImportadorEditField.Value = app.projectData.listOfProducts.("Importador"){idx};
            %     app.report_IDAduana.Value   = app.projectData.listOfProducts.("Código aduaneiro"){idx};
            %     app.report_Situation.Value  = app.projectData.listOfProducts.("Situação"){idx};
            %     report_SituationValueChanged(app)
            % 
            %     app.report_Violation.Value  = app.projectData.listOfProducts.("Infração"){idx};
            %     app.report_Corrigible.Value = app.projectData.listOfProducts.("Sanável?"){idx};
            %     app.report_Notes.Value      = app.projectData.listOfProducts.("Informações adicionais"){idx};
            % 
            % else
            %     app.report_productSituation2.Value = 1;
            %     set(app.report_productSituationPanel.Children, 'Enable', 1)
            %     report_productSituationPanelSelectionChanged(app)
            % 
            %     app.report_EditableInfoLabel.Text      = 'INCLUSÃO';
            %     app.report_EditOrAddButton.ImageSource = app.report_EditOrAddButton.UserData.iconOptions{2};
            % 
            %     app.ImportadorEditField.Value = '';
            %     app.report_IDAduana.Value = '';
            % 
            %     app.report_Situation.Value = 'Irregular';
            %     report_SituationValueChanged(app)
            % 
            %     app.report_Violation.Value = app.General.defaultTypeOfViolation;
            %     app.report_Corrigible.Value = 'Não';
            %     app.report_Notes.Value     = '';
            % end
        end

        %-----------------------------------------------------------------%
        function CallingMainApp(app, updateFlag, returnFlag)
            appBackDoor(app.CallingApp, app, 'REPORT:PRODUCTINFO', updateFlag, returnFlag)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainapp)
            
            app.CallingApp = mainapp;

            initialValues(app)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            delete(app)
            
        end

        % Callback function: btnClose, btnOK
        function ButtonPushed(app, event)
            
            pushedButtonTag = event.Source.Tag;
            switch pushedButtonTag
                case 'OK'
                    updateFlag = true;
                case 'Close'
                    updateFlag = false;
            end

            CallingMainApp(app, updateFlag, false)
            closeFcn(app)

        end

        % Value changed function: report_Situation
        function report_SituationValueChanged(app, event)
            
            selectedButton = app.report_productSituationPanel.SelectedObject;
            
            switch selectedButton
                case app.report_productSituation1 % HOMOLOGADO
                    set(app.report_nHom, 'Enable', 1, 'Value', '')

                case app.report_productSituation2 % NÃO HOMOLOGADO
                    set(app.report_nHom, 'Enable', 0, 'Value', '-1')
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
                app.UIFigure.Position = [100 100 474 588];
                app.UIFigure.Name = 'appAnalise';
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
            app.Document.ColumnWidth = {22, 22, '1x', 90};
            app.Document.RowHeight = {22, '1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.Document);
            app.ParametersPanel.Layout.Row = 2;
            app.ParametersPanel.Layout.Column = [1 4];

            % Create report_EditableInfoGrid
            app.report_EditableInfoGrid = uigridlayout(app.ParametersPanel);
            app.report_EditableInfoGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.report_EditableInfoGrid.RowHeight = {17, 22, 17, 22, 17, 22, 1, 22, 22, 22, 1, 26, 22, 26, 22, 17, 22, 17, '1x'};
            app.report_EditableInfoGrid.RowSpacing = 5;
            app.report_EditableInfoGrid.Padding = [10 10 10 5];
            app.report_EditableInfoGrid.BackgroundColor = [1 1 1];

            % Create report_nHomLabel
            app.report_nHomLabel = uilabel(app.report_EditableInfoGrid);
            app.report_nHomLabel.VerticalAlignment = 'bottom';
            app.report_nHomLabel.FontSize = 10;
            app.report_nHomLabel.Layout.Row = 1;
            app.report_nHomLabel.Layout.Column = [1 2];
            app.report_nHomLabel.Text = 'Homologação:';

            % Create report_nHom
            app.report_nHom = uieditfield(app.report_EditableInfoGrid, 'text');
            app.report_nHom.CharacterLimits = [0 14];
            app.report_nHom.FontSize = 11;
            app.report_nHom.Enable = 'off';
            app.report_nHom.Layout.Row = 2;
            app.report_nHom.Layout.Column = [1 2];
            app.report_nHom.Value = '-1';

            % Create report_NotesLabel
            app.report_NotesLabel = uilabel(app.report_EditableInfoGrid);
            app.report_NotesLabel.VerticalAlignment = 'bottom';
            app.report_NotesLabel.FontSize = 10;
            app.report_NotesLabel.Layout.Row = 18;
            app.report_NotesLabel.Layout.Column = [1 3];
            app.report_NotesLabel.Text = 'Informações adicionais:';

            % Create report_Notes
            app.report_Notes = uitextarea(app.report_EditableInfoGrid);
            app.report_Notes.FontSize = 11;
            app.report_Notes.Layout.Row = 19;
            app.report_Notes.Layout.Column = [1 5];

            % Create FabricanteEditField_2
            app.FabricanteEditField_2 = uieditfield(app.report_EditableInfoGrid, 'text');
            app.FabricanteEditField_2.FontSize = 11;
            app.FabricanteEditField_2.Layout.Row = 4;
            app.FabricanteEditField_2.Layout.Column = [4 5];

            % Create FabricanteEditFieldLabel_2
            app.FabricanteEditFieldLabel_2 = uilabel(app.report_EditableInfoGrid);
            app.FabricanteEditFieldLabel_2.VerticalAlignment = 'bottom';
            app.FabricanteEditFieldLabel_2.FontSize = 10;
            app.FabricanteEditFieldLabel_2.Layout.Row = 3;
            app.FabricanteEditFieldLabel_2.Layout.Column = [4 5];
            app.FabricanteEditFieldLabel_2.Text = 'Modelo:';

            % Create EvidenciadoquesetratadeprodutoqueusaRFCheckBox
            app.EvidenciadoquesetratadeprodutoqueusaRFCheckBox = uicheckbox(app.report_EditableInfoGrid);
            app.EvidenciadoquesetratadeprodutoqueusaRFCheckBox.Text = 'Evidenciado que se trata de produto que usa RF.';
            app.EvidenciadoquesetratadeprodutoqueusaRFCheckBox.FontSize = 11;
            app.EvidenciadoquesetratadeprodutoqueusaRFCheckBox.Layout.Row = 8;
            app.EvidenciadoquesetratadeprodutoqueusaRFCheckBox.Layout.Column = [1 4];

            % Create EvidenciadoUSOdoprodutoCheckBox
            app.EvidenciadoUSOdoprodutoCheckBox = uicheckbox(app.report_EditableInfoGrid);
            app.EvidenciadoUSOdoprodutoCheckBox.Text = 'Evidenciado USO do produto.';
            app.EvidenciadoUSOdoprodutoCheckBox.FontSize = 11;
            app.EvidenciadoUSOdoprodutoCheckBox.Layout.Row = 9;
            app.EvidenciadoUSOdoprodutoCheckBox.Layout.Column = [1 4];

            % Create EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox
            app.EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox = uicheckbox(app.report_EditableInfoGrid);
            app.EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox.Text = 'Evidenciada INTERFERÊNCIA decorrente do uso do produto.';
            app.EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox.FontSize = 11;
            app.EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox.Layout.Row = 10;
            app.EvidenciadaINTERFERNCIAdecorrentedousodoprodutoCheckBox.Layout.Column = [1 4];

            % Create ValorunitrioRLabel
            app.ValorunitrioRLabel = uilabel(app.report_EditableInfoGrid);
            app.ValorunitrioRLabel.VerticalAlignment = 'bottom';
            app.ValorunitrioRLabel.FontSize = 10;
            app.ValorunitrioRLabel.Layout.Row = 12;
            app.ValorunitrioRLabel.Layout.Column = 1;
            app.ValorunitrioRLabel.Text = {'Valor unitário'; '(R$):'};

            % Create ValorunitrioREditField
            app.ValorunitrioREditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.ValorunitrioREditField.ValueDisplayFormat = '%.2f';
            app.ValorunitrioREditField.FontSize = 11;
            app.ValorunitrioREditField.Layout.Row = 13;
            app.ValorunitrioREditField.Layout.Column = 1;

            % Create QtdusovendidaLabel
            app.QtdusovendidaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdusovendidaLabel.VerticalAlignment = 'bottom';
            app.QtdusovendidaLabel.FontSize = 10;
            app.QtdusovendidaLabel.Layout.Row = 14;
            app.QtdusovendidaLabel.Layout.Column = 1;
            app.QtdusovendidaLabel.Text = {'Qtd.'; 'uso/vendida:'};

            % Create QtdusovendidaEditField
            app.QtdusovendidaEditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdusovendidaEditField.ValueDisplayFormat = '%.2f';
            app.QtdusovendidaEditField.FontSize = 11;
            app.QtdusovendidaEditField.Layout.Row = 15;
            app.QtdusovendidaEditField.Layout.Column = 1;

            % Create QtdestoqueaduanaLabel
            app.QtdestoqueaduanaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdestoqueaduanaLabel.VerticalAlignment = 'bottom';
            app.QtdestoqueaduanaLabel.FontSize = 10;
            app.QtdestoqueaduanaLabel.Layout.Row = 14;
            app.QtdestoqueaduanaLabel.Layout.Column = 2;
            app.QtdestoqueaduanaLabel.Text = {'Qtd.'; 'estoque/aduana:'};

            % Create QtdestoqueaduanaEditField
            app.QtdestoqueaduanaEditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdestoqueaduanaEditField.ValueDisplayFormat = '%.2f';
            app.QtdestoqueaduanaEditField.FontSize = 11;
            app.QtdestoqueaduanaEditField.Layout.Row = 15;
            app.QtdestoqueaduanaEditField.Layout.Column = 2;

            % Create QtdlacradasEditFieldLabel
            app.QtdlacradasEditFieldLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdlacradasEditFieldLabel.VerticalAlignment = 'bottom';
            app.QtdlacradasEditFieldLabel.FontSize = 10;
            app.QtdlacradasEditFieldLabel.Layout.Row = 14;
            app.QtdlacradasEditFieldLabel.Layout.Column = 3;
            app.QtdlacradasEditFieldLabel.Text = {'Qtd.'; 'lacradas:'};

            % Create QtdlacradasEditField
            app.QtdlacradasEditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdlacradasEditField.ValueDisplayFormat = '%.2f';
            app.QtdlacradasEditField.FontSize = 11;
            app.QtdlacradasEditField.Layout.Row = 15;
            app.QtdlacradasEditField.Layout.Column = 3;

            % Create QtdapreendidasEditFieldLabel
            app.QtdapreendidasEditFieldLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdapreendidasEditFieldLabel.VerticalAlignment = 'bottom';
            app.QtdapreendidasEditFieldLabel.FontSize = 10;
            app.QtdapreendidasEditFieldLabel.Layout.Row = 14;
            app.QtdapreendidasEditFieldLabel.Layout.Column = 4;
            app.QtdapreendidasEditFieldLabel.Text = {'Qtd.'; 'apreendidas:'};

            % Create QtdapreendidasEditField
            app.QtdapreendidasEditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdapreendidasEditField.ValueDisplayFormat = '%.2f';
            app.QtdapreendidasEditField.FontSize = 11;
            app.QtdapreendidasEditField.Layout.Row = 15;
            app.QtdapreendidasEditField.Layout.Column = 4;

            % Create QtdretidasRFBLabel
            app.QtdretidasRFBLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdretidasRFBLabel.VerticalAlignment = 'bottom';
            app.QtdretidasRFBLabel.FontSize = 10;
            app.QtdretidasRFBLabel.Layout.Row = 14;
            app.QtdretidasRFBLabel.Layout.Column = 5;
            app.QtdretidasRFBLabel.Text = {'Qtd.'; 'retidas (RFB):'};

            % Create QtdretidasRFBEditField
            app.QtdretidasRFBEditField = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdretidasRFBEditField.ValueDisplayFormat = '%.2f';
            app.QtdretidasRFBEditField.FontSize = 11;
            app.QtdretidasRFBEditField.Layout.Row = 15;
            app.QtdretidasRFBEditField.Layout.Column = 5;

            % Create FabricanteEditFieldLabel
            app.FabricanteEditFieldLabel = uilabel(app.report_EditableInfoGrid);
            app.FabricanteEditFieldLabel.VerticalAlignment = 'bottom';
            app.FabricanteEditFieldLabel.FontSize = 10;
            app.FabricanteEditFieldLabel.Layout.Row = 3;
            app.FabricanteEditFieldLabel.Layout.Column = [1 2];
            app.FabricanteEditFieldLabel.Text = 'Fabricante:';

            % Create FabricanteEditField
            app.FabricanteEditField = uieditfield(app.report_EditableInfoGrid, 'text');
            app.FabricanteEditField.FontSize = 11;
            app.FabricanteEditField.Layout.Row = 4;
            app.FabricanteEditField.Layout.Column = [1 3];

            % Create report_ViolationLabel_2
            app.report_ViolationLabel_2 = uilabel(app.report_EditableInfoGrid);
            app.report_ViolationLabel_2.VerticalAlignment = 'bottom';
            app.report_ViolationLabel_2.FontSize = 10;
            app.report_ViolationLabel_2.Layout.Row = 1;
            app.report_ViolationLabel_2.Layout.Column = [3 5];
            app.report_ViolationLabel_2.Text = 'Tipo:';

            % Create report_Violation_2
            app.report_Violation_2 = uidropdown(app.report_EditableInfoGrid);
            app.report_Violation_2.Items = {};
            app.report_Violation_2.FontSize = 11;
            app.report_Violation_2.BackgroundColor = [1 1 1];
            app.report_Violation_2.Layout.Row = 2;
            app.report_Violation_2.Layout.Column = [3 5];
            app.report_Violation_2.Value = {};

            % Create ImportadorEditFieldLabel
            app.ImportadorEditFieldLabel = uilabel(app.report_EditableInfoGrid);
            app.ImportadorEditFieldLabel.VerticalAlignment = 'bottom';
            app.ImportadorEditFieldLabel.FontSize = 10;
            app.ImportadorEditFieldLabel.Layout.Row = 5;
            app.ImportadorEditFieldLabel.Layout.Column = [1 3];
            app.ImportadorEditFieldLabel.Text = 'Importador:';

            % Create ImportadorEditField
            app.ImportadorEditField = uieditfield(app.report_EditableInfoGrid, 'text');
            app.ImportadorEditField.FontSize = 11;
            app.ImportadorEditField.Layout.Row = 6;
            app.ImportadorEditField.Layout.Column = [1 3];

            % Create report_IDAduana
            app.report_IDAduana = uieditfield(app.report_EditableInfoGrid, 'text');
            app.report_IDAduana.FontSize = 11;
            app.report_IDAduana.Layout.Row = 6;
            app.report_IDAduana.Layout.Column = [4 5];

            % Create report_IDAduanaLabel
            app.report_IDAduanaLabel = uilabel(app.report_EditableInfoGrid);
            app.report_IDAduanaLabel.VerticalAlignment = 'bottom';
            app.report_IDAduanaLabel.FontSize = 10;
            app.report_IDAduanaLabel.Layout.Row = 5;
            app.report_IDAduanaLabel.Layout.Column = [4 5];
            app.report_IDAduanaLabel.Text = 'Código aduaneiro:';

            % Create report_SituationLabel
            app.report_SituationLabel = uilabel(app.report_EditableInfoGrid);
            app.report_SituationLabel.VerticalAlignment = 'bottom';
            app.report_SituationLabel.FontSize = 10;
            app.report_SituationLabel.Layout.Row = 16;
            app.report_SituationLabel.Layout.Column = 1;
            app.report_SituationLabel.Text = 'Situação:';

            % Create report_Situation
            app.report_Situation = uidropdown(app.report_EditableInfoGrid);
            app.report_Situation.Items = {'Irregular', 'Regular'};
            app.report_Situation.ValueChangedFcn = createCallbackFcn(app, @report_SituationValueChanged, true);
            app.report_Situation.FontSize = 11;
            app.report_Situation.BackgroundColor = [1 1 1];
            app.report_Situation.Layout.Row = 17;
            app.report_Situation.Layout.Column = 1;
            app.report_Situation.Value = 'Irregular';

            % Create report_ViolationLabel
            app.report_ViolationLabel = uilabel(app.report_EditableInfoGrid);
            app.report_ViolationLabel.VerticalAlignment = 'bottom';
            app.report_ViolationLabel.FontSize = 10;
            app.report_ViolationLabel.Layout.Row = 16;
            app.report_ViolationLabel.Layout.Column = 2;
            app.report_ViolationLabel.Text = 'Infração:';

            % Create report_Violation
            app.report_Violation = uidropdown(app.report_EditableInfoGrid);
            app.report_Violation.Items = {'Comercialização', 'Identificação homologação', 'Uso'};
            app.report_Violation.FontSize = 11;
            app.report_Violation.BackgroundColor = [1 1 1];
            app.report_Violation.Layout.Row = 17;
            app.report_Violation.Layout.Column = [2 4];
            app.report_Violation.Value = 'Comercialização';

            % Create report_ViolationLabel_3
            app.report_ViolationLabel_3 = uilabel(app.report_EditableInfoGrid);
            app.report_ViolationLabel_3.VerticalAlignment = 'bottom';
            app.report_ViolationLabel_3.FontSize = 10;
            app.report_ViolationLabel_3.Layout.Row = 16;
            app.report_ViolationLabel_3.Layout.Column = 5;
            app.report_ViolationLabel_3.Text = 'Sanável?';

            % Create report_Violation_3
            app.report_Violation_3 = uidropdown(app.report_EditableInfoGrid);
            app.report_Violation_3.Items = {'-1', 'Sim', 'Não'};
            app.report_Violation_3.FontSize = 11;
            app.report_Violation_3.BackgroundColor = [1 1 1];
            app.report_Violation_3.Layout.Row = 17;
            app.report_Violation_3.Layout.Column = 5;
            app.report_Violation_3.Value = '-1';

            % Create btnOK
            app.btnOK = uibutton(app.Document, 'push');
            app.btnOK.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.btnOK.Tag = 'OK';
            app.btnOK.IconAlignment = 'right';
            app.btnOK.BackgroundColor = [0.9804 0.9804 0.9804];
            app.btnOK.Enable = 'off';
            app.btnOK.Layout.Row = 3;
            app.btnOK.Layout.Column = 4;
            app.btnOK.Text = 'OK';

            % Create report_nRows
            app.report_nRows = uilabel(app.Document);
            app.report_nRows.HorizontalAlignment = 'right';
            app.report_nRows.FontColor = [0.502 0.502 0.502];
            app.report_nRows.Layout.Row = 1;
            app.report_nRows.Layout.Column = 4;
            app.report_nRows.Interpreter = 'html';
            app.report_nRows.Text = '1 de 5';

            % Create Image
            app.Image = uiimage(app.Document);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = 'Previous_32.png';

            % Create Image_2
            app.Image_2 = uiimage(app.Document);
            app.Image_2.Layout.Row = 1;
            app.Image_2.Layout.Column = 2;
            app.Image_2.ImageSource = 'After_32.png';

            % Create report_NewProduct
            app.report_NewProduct = uiimage(app.Document);
            app.report_NewProduct.Tooltip = {'Adiciona produto à lista'};
            app.report_NewProduct.Layout.Row = 3;
            app.report_NewProduct.Layout.Column = 1;
            app.report_NewProduct.VerticalAlignment = 'bottom';
            app.report_NewProduct.ImageSource = 'NewFile_36.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockProductInfo_exported(Container, varargin)

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
