classdef dockProductInfo_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        Document                 matlab.ui.container.GridLayout
        NextProduct              matlab.ui.control.Image
        PreviousProduct          matlab.ui.control.Image
        ParametersPanel          matlab.ui.container.Panel
        report_EditableInfoGrid  matlab.ui.container.GridLayout
        optNotes                 matlab.ui.control.TextArea
        optNotesLabel            matlab.ui.control.Label
        Corrigible               matlab.ui.control.DropDown
        CorrigibleLabel          matlab.ui.control.Label
        ViolationType            matlab.ui.control.DropDown
        ViolationTypeLabel       matlab.ui.control.Label
        Situation                matlab.ui.control.DropDown
        SituationLabel           matlab.ui.control.Label
        PLAI                     matlab.ui.control.EditField
        PLAILabel                matlab.ui.control.Label
        Lacre                    matlab.ui.control.EditField
        LacreLabel               matlab.ui.control.Label
        QtdRetida                matlab.ui.control.NumericEditField
        QtdRetidaLabel           matlab.ui.control.Label
        QtdApreendida            matlab.ui.control.NumericEditField
        QtdApreendidaLabel       matlab.ui.control.Label
        QtdLacrada               matlab.ui.control.NumericEditField
        QtdLacradaLabel          matlab.ui.control.Label
        QtdAnunciada             matlab.ui.control.NumericEditField
        QtdAnunciadaLabel        matlab.ui.control.Label
        QtdEstoque               matlab.ui.control.NumericEditField
        QtdEstoqueLabel          matlab.ui.control.Label
        QtdUso                   matlab.ui.control.NumericEditField
        QtdUsoLabel              matlab.ui.control.Label
        QtdVendida               matlab.ui.control.NumericEditField
        QtdVendidaLabel          matlab.ui.control.Label
        UnitPriceSource          matlab.ui.control.EditField
        UnitPriceSourceLabel     matlab.ui.control.Label
        UnitPrice                matlab.ui.control.NumericEditField
        UnitPriceLabel           matlab.ui.control.Label
        Interference             matlab.ui.control.CheckBox
        InUse                    matlab.ui.control.CheckBox
        RF                       matlab.ui.control.CheckBox
        CodAduana                matlab.ui.control.EditField
        CodAduanaLabel           matlab.ui.control.Label
        Importador               matlab.ui.control.EditField
        ImportadorLabel          matlab.ui.control.Label
        Model                    matlab.ui.control.EditField
        ModelLabel               matlab.ui.control.Label
        Manufacturer             matlab.ui.control.EditField
        ManufacturerLabel        matlab.ui.control.Label
        Subtype                  matlab.ui.control.DropDown
        SubtypeLabel             matlab.ui.control.Label
        Type                     matlab.ui.control.DropDown
        TypeLabel                matlab.ui.control.Label
        nHom                     matlab.ui.control.EditField
        nHomLabel                matlab.ui.control.Label
        Index                    matlab.ui.control.NumericEditField
        IndexLabel               matlab.ui.control.Label
        btnClose                 matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Container
        isDocked = true

        mainApp
        callingApp
        projectData
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function initialValues(app)
            app.Type.Items          = categories(app.projectData.inspectedProducts.("Tipo"));
            app.Subtype.Items       = {};
            app.Situation.Items     = categories(app.projectData.inspectedProducts.("Situação"));
            app.ViolationType.Items = categories(app.projectData.inspectedProducts.("Infração"));
            app.Corrigible.Items    = categories(app.projectData.inspectedProducts.("Sanável?"));

            idx = app.callingApp.report_Table.Selection;
            updateForm(app, idx)

            % Customização de componentes, mas restrito ao modo "DOCK".
            jsBackDoor = [];
            switch app.UIFigure
                case app.mainApp.UIFigure
                    jsBackDoor = app.mainApp.jsBackDoor;
                case app.callingApp.UIFigure
                    jsBackDoor = app.callingApp.jsBackDoor;
            end

            if ~isempty(jsBackDoor)
                appName    = class(app);
                elToModify = { app.optNotes };    
                elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                if ~isempty(elDataTag)
                    sendEventToHTMLSource(jsBackDoor, 'initializeComponents', { ...
                        struct('appName', appName, 'dataTag', elDataTag{1}, 'generation', 2, 'style', struct('textAlign', 'justify')) ...
                    });
                end
            end
        end

        %-----------------------------------------------------------------%
        function updateForm(app, idx)
            app.Index.Value           = idx;

            app.nHom.Value            = app.projectData.inspectedProducts.("Homologação"){idx};
            app.Type.Value            = char(app.projectData.inspectedProducts.("Tipo")(idx));
            updateTypeSubtypeMapping(app, app.Type.Value, app.projectData.inspectedProducts.("Subtipo"){idx})

            app.Manufacturer.Value    = app.projectData.inspectedProducts.("Fabricante"){idx};
            app.Model.Value           = app.projectData.inspectedProducts.("Modelo"){idx};
            app.Importador.Value      = app.projectData.inspectedProducts.("Importador"){idx};
            app.CodAduana.Value       = app.projectData.inspectedProducts.("Código aduaneiro"){idx};

            app.RF.Value              = app.projectData.inspectedProducts.("RF?")(idx);
            app.InUse.Value           = app.projectData.inspectedProducts.("Em uso?")(idx);
            app.Interference.Value    = app.projectData.inspectedProducts.("Interferência?")(idx);

            app.UnitPrice.Value       = app.projectData.inspectedProducts.("Valor Unit. (R$)")(idx);
            app.UnitPriceSource.Value = app.projectData.inspectedProducts.("Fonte do valor"){idx};
            app.QtdUso.Value          = double(app.projectData.inspectedProducts.("Qtd. uso")(idx));
            app.QtdVendida.Value      = double(app.projectData.inspectedProducts.("Qtd. vendida")(idx));
            app.QtdEstoque.Value      = double(app.projectData.inspectedProducts.("Qtd. estoque/aduana")(idx));
            app.QtdAnunciada.Value    = double(app.projectData.inspectedProducts.("Qtd. anunciada")(idx));

            app.QtdLacrada.Value      = double(app.projectData.inspectedProducts.("Qtd. lacradas")(idx));
            app.QtdApreendida.Value   = double(app.projectData.inspectedProducts.("Qtd. apreendidas")(idx));
            app.QtdRetida.Value       = double(app.projectData.inspectedProducts.("Qtd. retidas (RFB)")(idx));

            app.Lacre.Value           = app.projectData.inspectedProducts.("Lacre"){idx};
            app.PLAI.Value            = app.projectData.inspectedProducts.("PLAI"){idx};

            app.Situation.Value       = char(app.projectData.inspectedProducts.("Situação")(idx));
            app.ViolationType.Value   = char(app.projectData.inspectedProducts.("Infração")(idx));
            app.Corrigible.Value      = char(app.projectData.inspectedProducts.("Sanável?")(idx));
            app.optNotes.Value        = app.projectData.inspectedProducts.("Informações adicionais"){idx};
        end

        %-----------------------------------------------------------------%
        function updateTypeSubtypeMapping(app, type, subtype)
            subtypeList = checkTypeSubtypeProductsMapping(app.projectData, type);

            if isempty(subtypeList)
                set(app.Subtype, 'Enable', 'off', 'Items', subtypeList)

            else
                if isempty(subtype) || ~ismember(subtype, subtypeList)
                    subtype = subtypeList{1};
                end
                set(app.Subtype, 'Enable', 'on', 'Items', subtypeList, 'Value', subtype)
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp)
            
            app.mainApp     = mainApp;
            app.callingApp  = callingApp;
            app.projectData = mainApp.projectData;
            
            initialValues(app)
            
        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', "PRODUCTS")
            delete(app)
            
        end

        % Value changed function: CodAduana, Corrigible, Importador, 
        % ...and 21 other components
        function ParameterValueChanged(app, event)
            
            % Trata dados textuais...
            srcClass = class(event.Source);
            switch srcClass
                case 'matlab.ui.control.EditField'
                    event.Source.Value = strtrim(event.Source.Value);
                case 'matlab.ui.control.TextArea'
                    event.Source.Value = textFormatGUI.cellstr2TextField(event.Source.Value, '\n');
            end

            optionalNotes = app.optNotes.Value;
            if iscellstr(optionalNotes)
                optionalNotes = strjoin(optionalNotes, '\n');
            end

            switch event.Source
                case app.Type
                    % Verifica se edição ocorreu no campo "TIPO", o que demanda
                    % atualização do "SUBTIPO".
                    updateTypeSubtypeMapping(app, app.Type.Value, app.Subtype.Value)

                case {app.Manufacturer, app.Model}
                    % Verifica se edição ocorreu em produto NÃO homologado, o que
                    % demanda recálculo do hash.
                    if strcmp(app.nHom.Value, '-')
                        newNonCertificateHash = Hash.base64encode(strjoin({'-', app.Manufacturer.Value, app.Model.Value}, ' - '));
        
                        if ismember(newNonCertificateHash, app.projectData.inspectedProducts.("Hash"))
                            updateForm(app, app.Index.Value)
                            ui.Dialog(app.UIFigure, 'warning', model.projectLib.WARNING_ENTRYEXIST.PRODUCTS);
                            return
                        end
                    end
            end

            subtype = app.Subtype.Value;
            if isempty(app.Subtype.Value)
                subtype = '';
            end
            
            productData = {
                'Homologação',           app.nHom.Value;
                'Importador',            app.Importador.Value;
                'Código aduaneiro',      app.CodAduana.Value;
                'Tipo',                  app.Type.Value;
                'Subtipo',               subtype;
                'Fabricante',            app.Manufacturer.Value;
                'Modelo',                app.Model.Value;
                'RF?',                   app.RF.Value;
                'Em uso?',               app.InUse.Value;
                'Interferência?',        app.Interference.Value;
                'Valor Unit. (R$)',      app.UnitPrice.Value;
                'Fonte do valor',        app.UnitPriceSource.Value;
                'Qtd. uso',              app.QtdUso.Value;
                'Qtd. vendida',          app.QtdVendida.Value;
                'Qtd. estoque/aduana',   app.QtdEstoque.Value;
                'Qtd. anunciada',        app.QtdAnunciada.Value;
                'Qtd. lacradas',         app.QtdLacrada.Value;
                'Qtd. apreendidas',      app.QtdApreendida.Value;
                'Qtd. retidas (RFB)',    app.QtdRetida.Value;
                'Lacre',                 app.Lacre.Value;
                'PLAI',                  app.PLAI.Value;
                'Situação',              app.Situation.Value;
                'Infração',              app.ViolationType.Value;
                'Sanável?',              app.Corrigible.Value;
                'Informações adicionais', optionalNotes
            };

            updateInspectedProducts(app.projectData, 'edit', app.Index.Value, productData(:, 1), productData(:, 2)')
            ipcMainMatlabCallsHandler(app.mainApp, app, 'TableCellEdit', "PRODUCTS", app.Index.Value)
            
        end

        % Image clicked function: NextProduct, PreviousProduct
        function PreviousProductImageClicked(app, event)
            
            idxMaxRow = height(app.projectData.inspectedProducts);

            switch event.Source
                case app.PreviousProduct
                    idxNewRowSelection = app.Index.Value - 1;
                case app.NextProduct
                    idxNewRowSelection = app.Index.Value + 1;
            end

            if idxNewRowSelection < 1
                idxNewRowSelection = idxMaxRow;
            elseif idxNewRowSelection > idxMaxRow
                idxNewRowSelection = 1;
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'TableSelectionChanged', "PRODUCTS", idxNewRowSelection)
            updateForm(app, idxNewRowSelection)

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
                app.UIFigure.Position = [100 100 580 660];
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
            app.Document.ColumnWidth = {22, 22, '1x'};
            app.Document.RowHeight = {'1x', 22};
            app.Document.ColumnSpacing = 5;
            app.Document.RowSpacing = 5;
            app.Document.Layout.Row = 2;
            app.Document.Layout.Column = [1 2];
            app.Document.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.Document);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 1;
            app.ParametersPanel.Layout.Column = [1 3];

            % Create report_EditableInfoGrid
            app.report_EditableInfoGrid = uigridlayout(app.ParametersPanel);
            app.report_EditableInfoGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.report_EditableInfoGrid.RowHeight = {17, 22, 17, 22, 17, 22, 17, 22, 1, 22, 22, 22, 17, 22, 26, 22, 17, 22, 17, 22, 17, '1x'};
            app.report_EditableInfoGrid.RowSpacing = 5;
            app.report_EditableInfoGrid.Padding = [10 10 10 5];
            app.report_EditableInfoGrid.BackgroundColor = [1 1 1];

            % Create IndexLabel
            app.IndexLabel = uilabel(app.report_EditableInfoGrid);
            app.IndexLabel.VerticalAlignment = 'bottom';
            app.IndexLabel.FontSize = 10;
            app.IndexLabel.Layout.Row = 1;
            app.IndexLabel.Layout.Column = 1;
            app.IndexLabel.Text = '#';

            % Create Index
            app.Index = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.Index.Limits = [-1 Inf];
            app.Index.RoundFractionalValues = 'on';
            app.Index.ValueDisplayFormat = '%.0f';
            app.Index.AllowEmpty = 'on';
            app.Index.Editable = 'off';
            app.Index.HorizontalAlignment = 'left';
            app.Index.FontSize = 11;
            app.Index.FontColor = [1 1 1];
            app.Index.BackgroundColor = [0 0 0];
            app.Index.Layout.Row = 2;
            app.Index.Layout.Column = 1;
            app.Index.Value = 1;

            % Create nHomLabel
            app.nHomLabel = uilabel(app.report_EditableInfoGrid);
            app.nHomLabel.VerticalAlignment = 'bottom';
            app.nHomLabel.FontSize = 10;
            app.nHomLabel.Layout.Row = 1;
            app.nHomLabel.Layout.Column = [2 3];
            app.nHomLabel.Text = 'Homologação:';

            % Create nHom
            app.nHom = uieditfield(app.report_EditableInfoGrid, 'text');
            app.nHom.CharacterLimits = [0 14];
            app.nHom.Editable = 'off';
            app.nHom.FontSize = 11;
            app.nHom.Layout.Row = 2;
            app.nHom.Layout.Column = [2 3];
            app.nHom.Value = '-';

            % Create TypeLabel
            app.TypeLabel = uilabel(app.report_EditableInfoGrid);
            app.TypeLabel.VerticalAlignment = 'bottom';
            app.TypeLabel.FontSize = 10;
            app.TypeLabel.Layout.Row = 1;
            app.TypeLabel.Layout.Column = [4 5];
            app.TypeLabel.Text = 'Tipo:';

            % Create Type
            app.Type = uidropdown(app.report_EditableInfoGrid);
            app.Type.Items = {};
            app.Type.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Type.FontSize = 11;
            app.Type.BackgroundColor = [1 1 1];
            app.Type.Layout.Row = 2;
            app.Type.Layout.Column = [4 7];
            app.Type.Value = {};

            % Create SubtypeLabel
            app.SubtypeLabel = uilabel(app.report_EditableInfoGrid);
            app.SubtypeLabel.VerticalAlignment = 'bottom';
            app.SubtypeLabel.FontSize = 10;
            app.SubtypeLabel.Layout.Row = 3;
            app.SubtypeLabel.Layout.Column = [1 2];
            app.SubtypeLabel.Text = 'Subtipo:';

            % Create Subtype
            app.Subtype = uidropdown(app.report_EditableInfoGrid);
            app.Subtype.Items = {''};
            app.Subtype.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Subtype.Enable = 'off';
            app.Subtype.FontSize = 11;
            app.Subtype.BackgroundColor = [1 1 1];
            app.Subtype.Layout.Row = 4;
            app.Subtype.Layout.Column = [1 7];
            app.Subtype.Value = '';

            % Create ManufacturerLabel
            app.ManufacturerLabel = uilabel(app.report_EditableInfoGrid);
            app.ManufacturerLabel.VerticalAlignment = 'bottom';
            app.ManufacturerLabel.FontSize = 10;
            app.ManufacturerLabel.Layout.Row = 5;
            app.ManufacturerLabel.Layout.Column = [1 2];
            app.ManufacturerLabel.Text = 'Fabricante:';

            % Create Manufacturer
            app.Manufacturer = uieditfield(app.report_EditableInfoGrid, 'text');
            app.Manufacturer.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Manufacturer.FontSize = 11;
            app.Manufacturer.Layout.Row = 6;
            app.Manufacturer.Layout.Column = [1 5];

            % Create ModelLabel
            app.ModelLabel = uilabel(app.report_EditableInfoGrid);
            app.ModelLabel.VerticalAlignment = 'bottom';
            app.ModelLabel.FontSize = 10;
            app.ModelLabel.Layout.Row = 5;
            app.ModelLabel.Layout.Column = 6;
            app.ModelLabel.Text = 'Modelo:';

            % Create Model
            app.Model = uieditfield(app.report_EditableInfoGrid, 'text');
            app.Model.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Model.FontSize = 11;
            app.Model.Layout.Row = 6;
            app.Model.Layout.Column = [6 7];

            % Create ImportadorLabel
            app.ImportadorLabel = uilabel(app.report_EditableInfoGrid);
            app.ImportadorLabel.VerticalAlignment = 'bottom';
            app.ImportadorLabel.FontSize = 10;
            app.ImportadorLabel.Layout.Row = 7;
            app.ImportadorLabel.Layout.Column = [1 3];
            app.ImportadorLabel.Text = 'Importador:';

            % Create Importador
            app.Importador = uieditfield(app.report_EditableInfoGrid, 'text');
            app.Importador.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Importador.FontSize = 11;
            app.Importador.Layout.Row = 8;
            app.Importador.Layout.Column = [1 5];

            % Create CodAduanaLabel
            app.CodAduanaLabel = uilabel(app.report_EditableInfoGrid);
            app.CodAduanaLabel.VerticalAlignment = 'bottom';
            app.CodAduanaLabel.FontSize = 10;
            app.CodAduanaLabel.Layout.Row = 7;
            app.CodAduanaLabel.Layout.Column = [6 7];
            app.CodAduanaLabel.Text = 'Código aduaneiro:';

            % Create CodAduana
            app.CodAduana = uieditfield(app.report_EditableInfoGrid, 'text');
            app.CodAduana.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.CodAduana.FontSize = 11;
            app.CodAduana.Layout.Row = 8;
            app.CodAduana.Layout.Column = [6 7];

            % Create RF
            app.RF = uicheckbox(app.report_EditableInfoGrid);
            app.RF.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.RF.Text = 'Evidenciado que se trata de produto que usa RF.';
            app.RF.FontSize = 11;
            app.RF.Layout.Row = 10;
            app.RF.Layout.Column = [1 4];

            % Create InUse
            app.InUse = uicheckbox(app.report_EditableInfoGrid);
            app.InUse.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.InUse.Text = 'Evidenciado USO do produto.';
            app.InUse.FontSize = 11;
            app.InUse.Layout.Row = 11;
            app.InUse.Layout.Column = [1 4];

            % Create Interference
            app.Interference = uicheckbox(app.report_EditableInfoGrid);
            app.Interference.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Interference.Text = 'Evidenciada INTERFERÊNCIA decorrente do uso do produto.';
            app.Interference.FontSize = 11;
            app.Interference.Layout.Row = 12;
            app.Interference.Layout.Column = [1 7];

            % Create UnitPriceLabel
            app.UnitPriceLabel = uilabel(app.report_EditableInfoGrid);
            app.UnitPriceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceLabel.FontSize = 10;
            app.UnitPriceLabel.Layout.Row = 13;
            app.UnitPriceLabel.Layout.Column = [1 2];
            app.UnitPriceLabel.Text = 'Valor unit. (R$):';

            % Create UnitPrice
            app.UnitPrice = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.UnitPrice.Limits = [0 Inf];
            app.UnitPrice.ValueDisplayFormat = '%.2f';
            app.UnitPrice.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.UnitPrice.FontSize = 11;
            app.UnitPrice.Layout.Row = 14;
            app.UnitPrice.Layout.Column = 1;

            % Create UnitPriceSourceLabel
            app.UnitPriceSourceLabel = uilabel(app.report_EditableInfoGrid);
            app.UnitPriceSourceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceSourceLabel.FontSize = 10;
            app.UnitPriceSourceLabel.Layout.Row = 13;
            app.UnitPriceSourceLabel.Layout.Column = [2 4];
            app.UnitPriceSourceLabel.Text = 'Fonte do valor:';

            % Create UnitPriceSource
            app.UnitPriceSource = uieditfield(app.report_EditableInfoGrid, 'text');
            app.UnitPriceSource.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.UnitPriceSource.FontSize = 11;
            app.UnitPriceSource.Layout.Row = 14;
            app.UnitPriceSource.Layout.Column = [2 7];

            % Create QtdVendidaLabel
            app.QtdVendidaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdVendidaLabel.VerticalAlignment = 'bottom';
            app.QtdVendidaLabel.FontSize = 10;
            app.QtdVendidaLabel.Layout.Row = 15;
            app.QtdVendidaLabel.Layout.Column = 1;
            app.QtdVendidaLabel.Text = {'Qtd.'; 'vendida:'};

            % Create QtdVendida
            app.QtdVendida = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdVendida.Limits = [0 Inf];
            app.QtdVendida.RoundFractionalValues = 'on';
            app.QtdVendida.ValueDisplayFormat = '%.0f';
            app.QtdVendida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdVendida.FontSize = 11;
            app.QtdVendida.Layout.Row = 16;
            app.QtdVendida.Layout.Column = 1;

            % Create QtdUsoLabel
            app.QtdUsoLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdUsoLabel.VerticalAlignment = 'bottom';
            app.QtdUsoLabel.FontSize = 10;
            app.QtdUsoLabel.Layout.Row = 15;
            app.QtdUsoLabel.Layout.Column = 2;
            app.QtdUsoLabel.Text = {'Qtd.'; 'em uso:'};

            % Create QtdUso
            app.QtdUso = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdUso.Limits = [0 Inf];
            app.QtdUso.RoundFractionalValues = 'on';
            app.QtdUso.ValueDisplayFormat = '%.0f';
            app.QtdUso.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdUso.FontSize = 11;
            app.QtdUso.Layout.Row = 16;
            app.QtdUso.Layout.Column = 2;

            % Create QtdEstoqueLabel
            app.QtdEstoqueLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdEstoqueLabel.VerticalAlignment = 'bottom';
            app.QtdEstoqueLabel.FontSize = 10;
            app.QtdEstoqueLabel.Layout.Row = 15;
            app.QtdEstoqueLabel.Layout.Column = [3 4];
            app.QtdEstoqueLabel.Text = {'Qtd.'; 'estoque/aduana:'};

            % Create QtdEstoque
            app.QtdEstoque = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdEstoque.Limits = [0 Inf];
            app.QtdEstoque.RoundFractionalValues = 'on';
            app.QtdEstoque.ValueDisplayFormat = '%.0f';
            app.QtdEstoque.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdEstoque.FontSize = 11;
            app.QtdEstoque.Layout.Row = 16;
            app.QtdEstoque.Layout.Column = 3;

            % Create QtdAnunciadaLabel
            app.QtdAnunciadaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdAnunciadaLabel.VerticalAlignment = 'bottom';
            app.QtdAnunciadaLabel.FontSize = 10;
            app.QtdAnunciadaLabel.Layout.Row = 15;
            app.QtdAnunciadaLabel.Layout.Column = 4;
            app.QtdAnunciadaLabel.Text = {'Qtd.'; 'anunciada:'};

            % Create QtdAnunciada
            app.QtdAnunciada = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdAnunciada.Limits = [0 Inf];
            app.QtdAnunciada.RoundFractionalValues = 'on';
            app.QtdAnunciada.ValueDisplayFormat = '%.0f';
            app.QtdAnunciada.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdAnunciada.FontSize = 11;
            app.QtdAnunciada.Layout.Row = 16;
            app.QtdAnunciada.Layout.Column = 4;

            % Create QtdLacradaLabel
            app.QtdLacradaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdLacradaLabel.VerticalAlignment = 'bottom';
            app.QtdLacradaLabel.FontSize = 10;
            app.QtdLacradaLabel.Layout.Row = 15;
            app.QtdLacradaLabel.Layout.Column = 5;
            app.QtdLacradaLabel.Text = {'Qtd.'; 'lacrada:'};

            % Create QtdLacrada
            app.QtdLacrada = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdLacrada.Limits = [0 Inf];
            app.QtdLacrada.RoundFractionalValues = 'on';
            app.QtdLacrada.ValueDisplayFormat = '%.0f';
            app.QtdLacrada.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdLacrada.FontSize = 11;
            app.QtdLacrada.Layout.Row = 16;
            app.QtdLacrada.Layout.Column = 5;

            % Create QtdApreendidaLabel
            app.QtdApreendidaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdApreendidaLabel.VerticalAlignment = 'bottom';
            app.QtdApreendidaLabel.FontSize = 10;
            app.QtdApreendidaLabel.Layout.Row = 15;
            app.QtdApreendidaLabel.Layout.Column = 6;
            app.QtdApreendidaLabel.Text = {'Qtd.'; 'apreendida:'};

            % Create QtdApreendida
            app.QtdApreendida = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdApreendida.Limits = [0 Inf];
            app.QtdApreendida.RoundFractionalValues = 'on';
            app.QtdApreendida.ValueDisplayFormat = '%.0f';
            app.QtdApreendida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdApreendida.FontSize = 11;
            app.QtdApreendida.Layout.Row = 16;
            app.QtdApreendida.Layout.Column = 6;

            % Create QtdRetidaLabel
            app.QtdRetidaLabel = uilabel(app.report_EditableInfoGrid);
            app.QtdRetidaLabel.VerticalAlignment = 'bottom';
            app.QtdRetidaLabel.FontSize = 10;
            app.QtdRetidaLabel.Layout.Row = 15;
            app.QtdRetidaLabel.Layout.Column = 7;
            app.QtdRetidaLabel.Text = {'Qtd.'; 'retida (RFB):'};

            % Create QtdRetida
            app.QtdRetida = uieditfield(app.report_EditableInfoGrid, 'numeric');
            app.QtdRetida.Limits = [0 Inf];
            app.QtdRetida.RoundFractionalValues = 'on';
            app.QtdRetida.ValueDisplayFormat = '%.0f';
            app.QtdRetida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdRetida.FontSize = 11;
            app.QtdRetida.Layout.Row = 16;
            app.QtdRetida.Layout.Column = 7;

            % Create LacreLabel
            app.LacreLabel = uilabel(app.report_EditableInfoGrid);
            app.LacreLabel.VerticalAlignment = 'bottom';
            app.LacreLabel.FontSize = 10;
            app.LacreLabel.Layout.Row = 17;
            app.LacreLabel.Layout.Column = [1 3];
            app.LacreLabel.Text = 'Lacre:';

            % Create Lacre
            app.Lacre = uieditfield(app.report_EditableInfoGrid, 'text');
            app.Lacre.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Lacre.FontSize = 11;
            app.Lacre.Layout.Row = 18;
            app.Lacre.Layout.Column = [1 5];

            % Create PLAILabel
            app.PLAILabel = uilabel(app.report_EditableInfoGrid);
            app.PLAILabel.VerticalAlignment = 'bottom';
            app.PLAILabel.FontSize = 10;
            app.PLAILabel.Layout.Row = 17;
            app.PLAILabel.Layout.Column = [6 7];
            app.PLAILabel.Text = 'PLAI:';

            % Create PLAI
            app.PLAI = uieditfield(app.report_EditableInfoGrid, 'text');
            app.PLAI.CharacterLimits = [0 20];
            app.PLAI.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.PLAI.FontSize = 11;
            app.PLAI.Layout.Row = 18;
            app.PLAI.Layout.Column = [6 7];

            % Create SituationLabel
            app.SituationLabel = uilabel(app.report_EditableInfoGrid);
            app.SituationLabel.VerticalAlignment = 'bottom';
            app.SituationLabel.FontSize = 10;
            app.SituationLabel.Layout.Row = 19;
            app.SituationLabel.Layout.Column = 1;
            app.SituationLabel.Text = 'Situação:';

            % Create Situation
            app.Situation = uidropdown(app.report_EditableInfoGrid);
            app.Situation.Items = {'Irregular', 'Regular'};
            app.Situation.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Situation.FontSize = 11;
            app.Situation.BackgroundColor = [1 1 1];
            app.Situation.Layout.Row = 20;
            app.Situation.Layout.Column = [1 2];
            app.Situation.Value = 'Irregular';

            % Create ViolationTypeLabel
            app.ViolationTypeLabel = uilabel(app.report_EditableInfoGrid);
            app.ViolationTypeLabel.VerticalAlignment = 'bottom';
            app.ViolationTypeLabel.FontSize = 10;
            app.ViolationTypeLabel.Layout.Row = 19;
            app.ViolationTypeLabel.Layout.Column = [3 6];
            app.ViolationTypeLabel.Text = 'Infração:';

            % Create ViolationType
            app.ViolationType = uidropdown(app.report_EditableInfoGrid);
            app.ViolationType.Items = {'Comercialização', 'Identificação homologação', 'Uso'};
            app.ViolationType.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.ViolationType.FontSize = 11;
            app.ViolationType.BackgroundColor = [1 1 1];
            app.ViolationType.Layout.Row = 20;
            app.ViolationType.Layout.Column = [3 5];
            app.ViolationType.Value = 'Comercialização';

            % Create CorrigibleLabel
            app.CorrigibleLabel = uilabel(app.report_EditableInfoGrid);
            app.CorrigibleLabel.VerticalAlignment = 'bottom';
            app.CorrigibleLabel.FontSize = 10;
            app.CorrigibleLabel.Layout.Row = 19;
            app.CorrigibleLabel.Layout.Column = [6 7];
            app.CorrigibleLabel.Text = 'Sanável?';

            % Create Corrigible
            app.Corrigible = uidropdown(app.report_EditableInfoGrid);
            app.Corrigible.Items = {'-', 'Sim', 'Não'};
            app.Corrigible.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Corrigible.FontSize = 11;
            app.Corrigible.BackgroundColor = [1 1 1];
            app.Corrigible.Layout.Row = 20;
            app.Corrigible.Layout.Column = [6 7];
            app.Corrigible.Value = '-';

            % Create optNotesLabel
            app.optNotesLabel = uilabel(app.report_EditableInfoGrid);
            app.optNotesLabel.VerticalAlignment = 'bottom';
            app.optNotesLabel.FontSize = 10;
            app.optNotesLabel.Layout.Row = 21;
            app.optNotesLabel.Layout.Column = [1 3];
            app.optNotesLabel.Text = 'Informações adicionais:';

            % Create optNotes
            app.optNotes = uitextarea(app.report_EditableInfoGrid);
            app.optNotes.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.optNotes.FontSize = 11;
            app.optNotes.Layout.Row = 22;
            app.optNotes.Layout.Column = [1 7];

            % Create PreviousProduct
            app.PreviousProduct = uiimage(app.Document);
            app.PreviousProduct.ImageClickedFcn = createCallbackFcn(app, @PreviousProductImageClicked, true);
            app.PreviousProduct.Tooltip = {'Navega para o produto anterior'};
            app.PreviousProduct.Layout.Row = 2;
            app.PreviousProduct.Layout.Column = 1;
            app.PreviousProduct.ImageSource = 'Previous_32.png';

            % Create NextProduct
            app.NextProduct = uiimage(app.Document);
            app.NextProduct.ImageClickedFcn = createCallbackFcn(app, @PreviousProductImageClicked, true);
            app.NextProduct.Tooltip = {'Navega para o produto posterior'};
            app.NextProduct.Layout.Row = 2;
            app.NextProduct.Layout.Column = 2;
            app.NextProduct.ImageSource = 'After_32.png';

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
