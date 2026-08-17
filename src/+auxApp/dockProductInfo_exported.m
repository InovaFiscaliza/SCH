classdef dockProductInfo_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        ProductStatusPanel    matlab.ui.container.Panel
        ProductStatusGrid     matlab.ui.container.GridLayout
        Note                  matlab.ui.control.TextArea
        NoteLabel             matlab.ui.control.Label
        PLAI                  matlab.ui.control.EditField
        PLAILabel             matlab.ui.control.Label
        Lacre                 matlab.ui.control.EditField
        LacreLabel            matlab.ui.control.Label
        Corrigible            matlab.ui.control.DropDown
        CorrigibleLabel       matlab.ui.control.Label
        ViolationType         matlab.ui.control.DropDown
        ViolationTypeLabel    matlab.ui.control.Label
        Situation             matlab.ui.control.DropDown
        SituationLabel        matlab.ui.control.Label
        QtdRetida             matlab.ui.control.NumericEditField
        QtdRetidaLabel        matlab.ui.control.Label
        QtdApreendida         matlab.ui.control.NumericEditField
        QtdApreendidaLabel    matlab.ui.control.Label
        QtdLacrada            matlab.ui.control.NumericEditField
        QtdLacradaLabel       matlab.ui.control.Label
        QtdAnunciada          matlab.ui.control.NumericEditField
        QtdAnunciadaLabel     matlab.ui.control.Label
        QtdEstoque            matlab.ui.control.NumericEditField
        QtdEstoqueLabel       matlab.ui.control.Label
        QtdUso                matlab.ui.control.NumericEditField
        QtdUsoLabel           matlab.ui.control.Label
        QtdVendida            matlab.ui.control.NumericEditField
        QtdVendidaLabel       matlab.ui.control.Label
        UnitPriceSource       matlab.ui.control.EditField
        UnitPriceSourceLabel  matlab.ui.control.Label
        UnitPrice             matlab.ui.control.NumericEditField
        UnitPriceLabel        matlab.ui.control.Label
        EvidencePanel         matlab.ui.container.Panel
        EvidenceGrid          matlab.ui.container.GridLayout
        Interference          matlab.ui.control.CheckBox
        InUse                 matlab.ui.control.CheckBox
        RF                    matlab.ui.control.CheckBox
        EvidenceLabel         matlab.ui.control.Label
        CodAduana             matlab.ui.control.EditField
        CodAduanaLabel        matlab.ui.control.Label
        Importador            matlab.ui.control.EditField
        ImportadorLabel       matlab.ui.control.Label
        Model                 matlab.ui.control.EditField
        ModelLabel            matlab.ui.control.Label
        Manufacturer          matlab.ui.control.EditField
        ManufacturerLabel     matlab.ui.control.Label
        Subtype               matlab.ui.control.DropDown
        SubtypeLabel          matlab.ui.control.Label
        Type                  matlab.ui.control.DropDown
        TypeLabel             matlab.ui.control.Label
        ProductStatusLabel    matlab.ui.control.Label
        HomologationPanel     matlab.ui.container.Panel
        HomologationGrid      matlab.ui.container.GridLayout
        Homologation          matlab.ui.control.Label
        HomologationIcon      matlab.ui.control.Image
        ProductNext           matlab.ui.control.Image
        ProductPrevious       matlab.ui.control.Image
        ProductPosition       matlab.ui.control.Label
        Title                 matlab.ui.control.Label
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
        function initialValues(app)
            app.Type.Items = categories(app.projectData.inspectedProducts.("Tipo"));
            app.Subtype.Items = {};
            app.Situation.Items = categories(app.projectData.inspectedProducts.("Situação"));
            app.ViolationType.Items = categories(app.projectData.inspectedProducts.("Infração"));
            app.Corrigible.Items = categories(app.projectData.inspectedProducts.("Sanável?"));

            currentProductIdx = app.inputArgs.selectedProductIdx;
            updateForm(app, currentProductIdx)
        end

        %-----------------------------------------------------------------%
        function updateForm(app, currentProductIdx)
            homologation = app.projectData.inspectedProducts.("Homologação"){currentProductIdx};
            numProducts = height(app.projectData.inspectedProducts);
            
            if ~strcmp(homologation, '-')
                productInfo = sprintf('Homologação nº <font style="color: #0072bd;"><b>%s</b></font>', homologation);
            else
                productInfo = '<font style="color: red;">Produto não homologado</font>';
            end
            app.ProductPosition.Text = sprintf('%d / %d', currentProductIdx, numProducts);
            app.Homologation.Text = productInfo;

            app.Type.Value = char(app.projectData.inspectedProducts.("Tipo")(currentProductIdx));
            updateTypeSubtypeMapping(app, app.Type.Value, app.projectData.inspectedProducts.("Subtipo"){currentProductIdx})

            app.Manufacturer.Value = app.projectData.inspectedProducts.("Fabricante"){currentProductIdx};
            app.Model.Value = app.projectData.inspectedProducts.("Modelo"){currentProductIdx};
            app.Importador.Value = app.projectData.inspectedProducts.("Importador"){currentProductIdx};
            app.CodAduana.Value = app.projectData.inspectedProducts.("Código aduaneiro"){currentProductIdx};

            app.RF.Value = app.projectData.inspectedProducts.("RF?")(currentProductIdx);
            app.InUse.Value = app.projectData.inspectedProducts.("Em uso?")(currentProductIdx);
            app.Interference.Value = app.projectData.inspectedProducts.("Interferência?")(currentProductIdx);

            app.UnitPrice.Value = app.projectData.inspectedProducts.("Valor Unit. (R$)")(currentProductIdx);
            app.UnitPriceSource.Value = app.projectData.inspectedProducts.("Fonte do valor"){currentProductIdx};
            app.QtdUso.Value = double(app.projectData.inspectedProducts.("Qtd. uso")(currentProductIdx));
            app.QtdVendida.Value = double(app.projectData.inspectedProducts.("Qtd. vendida")(currentProductIdx));
            app.QtdEstoque.Value = double(app.projectData.inspectedProducts.("Qtd. estoque/aduana")(currentProductIdx));
            app.QtdAnunciada.Value = double(app.projectData.inspectedProducts.("Qtd. anunciada")(currentProductIdx));

            app.QtdLacrada.Value = double(app.projectData.inspectedProducts.("Qtd. lacradas")(currentProductIdx));
            app.QtdApreendida.Value = double(app.projectData.inspectedProducts.("Qtd. apreendidas")(currentProductIdx));
            app.QtdRetida.Value = double(app.projectData.inspectedProducts.("Qtd. retidas (RFB)")(currentProductIdx));

            app.Lacre.Value = app.projectData.inspectedProducts.("Lacre"){currentProductIdx};
            app.PLAI.Value = app.projectData.inspectedProducts.("PLAI"){currentProductIdx};

            app.Situation.Value = char(app.projectData.inspectedProducts.("Situação")(currentProductIdx));
            app.ViolationType.Value = char(app.projectData.inspectedProducts.("Infração")(currentProductIdx));
            app.Corrigible.Value = char(app.projectData.inspectedProducts.("Sanável?")(currentProductIdx));
            app.Note.Value = app.projectData.inspectedProducts.("Informações adicionais"){currentProductIdx};
        end

        %-----------------------------------------------------------------%
        function homologation = getHomolotation(app)
            currentProductIdx = app.inputArgs.selectedProductIdx;
            homologation = app.projectData.inspectedProducts.("Homologação"){currentProductIdx};
        end

        %-----------------------------------------------------------------%
        function updateTypeSubtypeMapping(app, type, subtype)
            [subtype, subtypeList] = checkTypeSubtypeProductsMapping(app.projectData, type, subtype);
            subtypeEnableList = ~isequal(subtypeList, {'-'});

            set(app.Subtype, 'Enable', subtypeEnableList, 'Items', subtypeList, 'Value', subtype)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, selectedProductIdx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'selectedProductIdx', selectedProductIdx);
                initialValues(app)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end            
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            delete(app)
            
        end

        % Value changed function: CodAduana, Corrigible, Importador, 
        % ...and 21 other components
        function onParameterValueChanged(app, event)
            
            % Trata dados textuais...
            srcClass = class(event.Source);
            switch srcClass
                case 'matlab.ui.control.EditField'
                    event.Source.Value = strtrim(event.Source.Value);
                case 'matlab.ui.control.TextArea'
                    event.Source.Value = textFormatGUI.cellstr2TextField(event.Source.Value, '\n');
            end

            optionalNotes = app.Note.Value;
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
                    if strcmp(getHomolotation(app), '-')
                        newNonCertificateHash = Hash.base64encode(strjoin({'-', app.Manufacturer.Value, app.Model.Value}, ' - '));
        
                        if ismember(newNonCertificateHash, app.projectData.inspectedProducts.("Hash"))
                            currentProductIdx = app.inputArgs.selectedProductIdx;
                            updateForm(app, currentProductIdx)

                            ui.Dialog(app.UIFigure, 'warning', model.ProjectBase.WARNING_ENTRYEXIST.PRODUCTS);
                            return
                        end
                    end
            end

            subtype = app.Subtype.Value;
            if isempty(app.Subtype.Value)
                subtype = '';
            end
            
            productData = {
                'Homologação',           getHomolotation(app);
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

            currentProductIdx = app.inputArgs.selectedProductIdx;
            updateInspectedProducts(app.projectData, 'edit', currentProductIdx, productData(:, 1), productData(:, 2)')
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTableCellEdited', "PRODUCTS", currentProductIdx)
            
        end

        % Image clicked function: ProductNext, ProductPrevious
        function onProductsArrowButtonClicked(app, event)
            
            currentProductIdx = app.inputArgs.selectedProductIdx;
            numProducts = height(app.projectData.inspectedProducts);

            switch event.Source
                case app.ProductPrevious
                    newProductIdx = currentProductIdx - 1;
                case app.ProductNext
                    newProductIdx = currentProductIdx + 1;
            end

            if newProductIdx < 1
                newProductIdx = numProducts;
            elseif newProductIdx > numProducts
                newProductIdx = 1;
            end

            app.inputArgs.selectedProductIdx = newProductIdx;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTableSelectionChanged', "PRODUCTS", newProductIdx)
            updateForm(app, newProductIdx)

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
                app.UIFigure.Position = [100 100 840 628];
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
            app.GridLayout.ColumnWidth = {670, 52, 24, 24};
            app.GridLayout.RowHeight = {40, 44, 22, 467};
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
            app.Title.Layout.Column = 1;
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Editar registro de produto inspecionado</b>'; '<font style="color: gray; font-size: 10px;">Revise e atualize as informações do produto, da remessa e da análise</font>'};

            % Create ProductPosition
            app.ProductPosition = uilabel(app.GridLayout);
            app.ProductPosition.FontSize = 14;
            app.ProductPosition.Layout.Row = 1;
            app.ProductPosition.Layout.Column = 2;
            app.ProductPosition.Text = '';

            % Create ProductPrevious
            app.ProductPrevious = uiimage(app.GridLayout);
            app.ProductPrevious.ImageClickedFcn = createCallbackFcn(app, @onProductsArrowButtonClicked, true);
            app.ProductPrevious.Tooltip = {'Navega para o produto anterior'};
            app.ProductPrevious.Layout.Row = 1;
            app.ProductPrevious.Layout.Column = 3;
            app.ProductPrevious.ImageSource = 'chevron-left.svg';

            % Create ProductNext
            app.ProductNext = uiimage(app.GridLayout);
            app.ProductNext.ImageClickedFcn = createCallbackFcn(app, @onProductsArrowButtonClicked, true);
            app.ProductNext.Tooltip = {'Navega para o produto posterior'};
            app.ProductNext.Layout.Row = 1;
            app.ProductNext.Layout.Column = 4;
            app.ProductNext.ImageSource = 'chevron-right.svg';

            % Create HomologationPanel
            app.HomologationPanel = uipanel(app.GridLayout);
            app.HomologationPanel.AutoResizeChildren = 'off';
            app.HomologationPanel.Layout.Row = 2;
            app.HomologationPanel.Layout.Column = [1 4];

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
            app.Homologation.FontColor = [0.502 0.502 0.502];
            app.Homologation.Layout.Row = 1;
            app.Homologation.Layout.Column = 2;
            app.Homologation.Interpreter = 'html';
            app.Homologation.Text = '';

            % Create ProductStatusLabel
            app.ProductStatusLabel = uilabel(app.GridLayout);
            app.ProductStatusLabel.VerticalAlignment = 'bottom';
            app.ProductStatusLabel.FontSize = 11;
            app.ProductStatusLabel.FontWeight = 'bold';
            app.ProductStatusLabel.FontColor = [0 0.451 0.7412];
            app.ProductStatusLabel.Layout.Row = 3;
            app.ProductStatusLabel.Layout.Column = 1;
            app.ProductStatusLabel.Text = 'Campos editáveis';

            % Create ProductStatusPanel
            app.ProductStatusPanel = uipanel(app.GridLayout);
            app.ProductStatusPanel.AutoResizeChildren = 'off';
            app.ProductStatusPanel.Layout.Row = 4;
            app.ProductStatusPanel.Layout.Column = [1 4];

            % Create ProductStatusGrid
            app.ProductStatusGrid = uigridlayout(app.ProductStatusPanel);
            app.ProductStatusGrid.ColumnWidth = {103, 103, 102, 103, 102, 103, 102};
            app.ProductStatusGrid.RowHeight = {15, 22, 20, 22, 20, 22, 20, 40, 20, 22, 20, 22, 20, 22, 20, 44};
            app.ProductStatusGrid.RowSpacing = 5;
            app.ProductStatusGrid.BackgroundColor = [1 1 1];

            % Create TypeLabel
            app.TypeLabel = uilabel(app.ProductStatusGrid);
            app.TypeLabel.VerticalAlignment = 'bottom';
            app.TypeLabel.FontSize = 11;
            app.TypeLabel.Layout.Row = 1;
            app.TypeLabel.Layout.Column = 1;
            app.TypeLabel.Text = 'Tipo:';

            % Create Type
            app.Type = uidropdown(app.ProductStatusGrid);
            app.Type.Items = {};
            app.Type.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Type.FontSize = 11;
            app.Type.BackgroundColor = [1 1 1];
            app.Type.Layout.Row = 2;
            app.Type.Layout.Column = [1 4];
            app.Type.Value = {};

            % Create SubtypeLabel
            app.SubtypeLabel = uilabel(app.ProductStatusGrid);
            app.SubtypeLabel.VerticalAlignment = 'bottom';
            app.SubtypeLabel.FontSize = 11;
            app.SubtypeLabel.Layout.Row = 1;
            app.SubtypeLabel.Layout.Column = 5;
            app.SubtypeLabel.Text = 'Subtipo:';

            % Create Subtype
            app.Subtype = uidropdown(app.ProductStatusGrid);
            app.Subtype.Items = {''};
            app.Subtype.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Subtype.Enable = 'off';
            app.Subtype.FontSize = 11;
            app.Subtype.BackgroundColor = [1 1 1];
            app.Subtype.Layout.Row = 2;
            app.Subtype.Layout.Column = [5 7];
            app.Subtype.Value = '';

            % Create ManufacturerLabel
            app.ManufacturerLabel = uilabel(app.ProductStatusGrid);
            app.ManufacturerLabel.VerticalAlignment = 'bottom';
            app.ManufacturerLabel.FontSize = 11;
            app.ManufacturerLabel.Layout.Row = 3;
            app.ManufacturerLabel.Layout.Column = [1 3];
            app.ManufacturerLabel.Text = 'Fabricante:';

            % Create Manufacturer
            app.Manufacturer = uieditfield(app.ProductStatusGrid, 'text');
            app.Manufacturer.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Manufacturer.FontSize = 11;
            app.Manufacturer.Layout.Row = 4;
            app.Manufacturer.Layout.Column = [1 4];

            % Create ModelLabel
            app.ModelLabel = uilabel(app.ProductStatusGrid);
            app.ModelLabel.VerticalAlignment = 'bottom';
            app.ModelLabel.FontSize = 11;
            app.ModelLabel.Layout.Row = 3;
            app.ModelLabel.Layout.Column = 5;
            app.ModelLabel.Text = 'Modelo:';

            % Create Model
            app.Model = uieditfield(app.ProductStatusGrid, 'text');
            app.Model.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Model.FontSize = 11;
            app.Model.Layout.Row = 4;
            app.Model.Layout.Column = [5 7];

            % Create ImportadorLabel
            app.ImportadorLabel = uilabel(app.ProductStatusGrid);
            app.ImportadorLabel.VerticalAlignment = 'bottom';
            app.ImportadorLabel.FontSize = 11;
            app.ImportadorLabel.Layout.Row = 5;
            app.ImportadorLabel.Layout.Column = [1 3];
            app.ImportadorLabel.Text = 'Importador:';

            % Create Importador
            app.Importador = uieditfield(app.ProductStatusGrid, 'text');
            app.Importador.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Importador.FontSize = 11;
            app.Importador.Layout.Row = 6;
            app.Importador.Layout.Column = [1 4];

            % Create CodAduanaLabel
            app.CodAduanaLabel = uilabel(app.ProductStatusGrid);
            app.CodAduanaLabel.VerticalAlignment = 'bottom';
            app.CodAduanaLabel.FontSize = 11;
            app.CodAduanaLabel.Layout.Row = 5;
            app.CodAduanaLabel.Layout.Column = [5 6];
            app.CodAduanaLabel.Text = 'Código aduaneiro:';

            % Create CodAduana
            app.CodAduana = uieditfield(app.ProductStatusGrid, 'text');
            app.CodAduana.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.CodAduana.FontSize = 11;
            app.CodAduana.Layout.Row = 6;
            app.CodAduana.Layout.Column = [5 7];

            % Create EvidenceLabel
            app.EvidenceLabel = uilabel(app.ProductStatusGrid);
            app.EvidenceLabel.VerticalAlignment = 'bottom';
            app.EvidenceLabel.FontSize = 11;
            app.EvidenceLabel.Layout.Row = 7;
            app.EvidenceLabel.Layout.Column = [1 2];
            app.EvidenceLabel.Text = 'Evidências:';

            % Create EvidencePanel
            app.EvidencePanel = uipanel(app.ProductStatusGrid);
            app.EvidencePanel.AutoResizeChildren = 'off';
            app.EvidencePanel.Layout.Row = 8;
            app.EvidencePanel.Layout.Column = [1 7];

            % Create EvidenceGrid
            app.EvidenceGrid = uigridlayout(app.EvidencePanel);
            app.EvidenceGrid.ColumnWidth = {206, 216, 314};
            app.EvidenceGrid.RowHeight = {28};
            app.EvidenceGrid.Padding = [10 5 10 5];
            app.EvidenceGrid.BackgroundColor = [1 1 1];

            % Create RF
            app.RF = uicheckbox(app.EvidenceGrid);
            app.RF.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.RF.Text = 'Produto usa RF';
            app.RF.FontSize = 11;
            app.RF.Layout.Row = 1;
            app.RF.Layout.Column = 1;

            % Create InUse
            app.InUse = uicheckbox(app.EvidenceGrid);
            app.InUse.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.InUse.Text = 'Produto foi UTILIZADO';
            app.InUse.FontSize = 11;
            app.InUse.Layout.Row = 1;
            app.InUse.Layout.Column = 2;

            % Create Interference
            app.Interference = uicheckbox(app.EvidenceGrid);
            app.Interference.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Interference.Text = 'Houve INTERFERÊNCIA decorrente do uso';
            app.Interference.WordWrap = 'on';
            app.Interference.FontSize = 11;
            app.Interference.Layout.Row = 1;
            app.Interference.Layout.Column = 3;

            % Create UnitPriceLabel
            app.UnitPriceLabel = uilabel(app.ProductStatusGrid);
            app.UnitPriceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceLabel.FontSize = 11;
            app.UnitPriceLabel.Layout.Row = 9;
            app.UnitPriceLabel.Layout.Column = [1 2];
            app.UnitPriceLabel.Text = 'Valor unitário (R$):';

            % Create UnitPrice
            app.UnitPrice = uieditfield(app.ProductStatusGrid, 'numeric');
            app.UnitPrice.Limits = [0 Inf];
            app.UnitPrice.ValueDisplayFormat = '%.2f';
            app.UnitPrice.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.UnitPrice.FontSize = 11;
            app.UnitPrice.Layout.Row = 10;
            app.UnitPrice.Layout.Column = [1 2];

            % Create UnitPriceSourceLabel
            app.UnitPriceSourceLabel = uilabel(app.ProductStatusGrid);
            app.UnitPriceSourceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceSourceLabel.FontSize = 11;
            app.UnitPriceSourceLabel.Layout.Row = 9;
            app.UnitPriceSourceLabel.Layout.Column = [3 7];
            app.UnitPriceSourceLabel.Text = 'Fonte do valor (nota fiscal, site na internet, mostruário de loja etc):';

            % Create UnitPriceSource
            app.UnitPriceSource = uieditfield(app.ProductStatusGrid, 'text');
            app.UnitPriceSource.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.UnitPriceSource.FontSize = 11;
            app.UnitPriceSource.Layout.Row = 10;
            app.UnitPriceSource.Layout.Column = [3 7];

            % Create QtdVendidaLabel
            app.QtdVendidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdVendidaLabel.VerticalAlignment = 'bottom';
            app.QtdVendidaLabel.FontSize = 11;
            app.QtdVendidaLabel.Layout.Row = 11;
            app.QtdVendidaLabel.Layout.Column = 1;
            app.QtdVendidaLabel.Text = 'Qtd. vendida:';

            % Create QtdVendida
            app.QtdVendida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdVendida.Limits = [0 Inf];
            app.QtdVendida.RoundFractionalValues = 'on';
            app.QtdVendida.ValueDisplayFormat = '%.0f';
            app.QtdVendida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdVendida.FontSize = 11;
            app.QtdVendida.Layout.Row = 12;
            app.QtdVendida.Layout.Column = 1;

            % Create QtdUsoLabel
            app.QtdUsoLabel = uilabel(app.ProductStatusGrid);
            app.QtdUsoLabel.VerticalAlignment = 'bottom';
            app.QtdUsoLabel.FontSize = 11;
            app.QtdUsoLabel.Layout.Row = 11;
            app.QtdUsoLabel.Layout.Column = 2;
            app.QtdUsoLabel.Text = 'Qtd. em uso:';

            % Create QtdUso
            app.QtdUso = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdUso.Limits = [0 Inf];
            app.QtdUso.RoundFractionalValues = 'on';
            app.QtdUso.ValueDisplayFormat = '%.0f';
            app.QtdUso.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdUso.FontSize = 11;
            app.QtdUso.Layout.Row = 12;
            app.QtdUso.Layout.Column = 2;

            % Create QtdEstoqueLabel
            app.QtdEstoqueLabel = uilabel(app.ProductStatusGrid);
            app.QtdEstoqueLabel.VerticalAlignment = 'bottom';
            app.QtdEstoqueLabel.FontSize = 11;
            app.QtdEstoqueLabel.Layout.Row = 11;
            app.QtdEstoqueLabel.Layout.Column = [3 4];
            app.QtdEstoqueLabel.Text = 'Qtd. estoque/aduana:';

            % Create QtdEstoque
            app.QtdEstoque = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdEstoque.Limits = [0 Inf];
            app.QtdEstoque.RoundFractionalValues = 'on';
            app.QtdEstoque.ValueDisplayFormat = '%.0f';
            app.QtdEstoque.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdEstoque.FontSize = 11;
            app.QtdEstoque.Layout.Row = 12;
            app.QtdEstoque.Layout.Column = 3;

            % Create QtdAnunciadaLabel
            app.QtdAnunciadaLabel = uilabel(app.ProductStatusGrid);
            app.QtdAnunciadaLabel.VerticalAlignment = 'bottom';
            app.QtdAnunciadaLabel.FontSize = 11;
            app.QtdAnunciadaLabel.Layout.Row = 11;
            app.QtdAnunciadaLabel.Layout.Column = 4;
            app.QtdAnunciadaLabel.Text = 'Qtd. anunciada:';

            % Create QtdAnunciada
            app.QtdAnunciada = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdAnunciada.Limits = [0 Inf];
            app.QtdAnunciada.RoundFractionalValues = 'on';
            app.QtdAnunciada.ValueDisplayFormat = '%.0f';
            app.QtdAnunciada.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdAnunciada.FontSize = 11;
            app.QtdAnunciada.Layout.Row = 12;
            app.QtdAnunciada.Layout.Column = 4;

            % Create QtdLacradaLabel
            app.QtdLacradaLabel = uilabel(app.ProductStatusGrid);
            app.QtdLacradaLabel.VerticalAlignment = 'bottom';
            app.QtdLacradaLabel.FontSize = 11;
            app.QtdLacradaLabel.Layout.Row = 11;
            app.QtdLacradaLabel.Layout.Column = 5;
            app.QtdLacradaLabel.Text = 'Qtd. lacrada:';

            % Create QtdLacrada
            app.QtdLacrada = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdLacrada.Limits = [0 Inf];
            app.QtdLacrada.RoundFractionalValues = 'on';
            app.QtdLacrada.ValueDisplayFormat = '%.0f';
            app.QtdLacrada.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdLacrada.FontSize = 11;
            app.QtdLacrada.Layout.Row = 12;
            app.QtdLacrada.Layout.Column = 5;

            % Create QtdApreendidaLabel
            app.QtdApreendidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdApreendidaLabel.VerticalAlignment = 'bottom';
            app.QtdApreendidaLabel.FontSize = 11;
            app.QtdApreendidaLabel.Layout.Row = 11;
            app.QtdApreendidaLabel.Layout.Column = 6;
            app.QtdApreendidaLabel.Text = 'Qtd. apreendida:';

            % Create QtdApreendida
            app.QtdApreendida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdApreendida.Limits = [0 Inf];
            app.QtdApreendida.RoundFractionalValues = 'on';
            app.QtdApreendida.ValueDisplayFormat = '%.0f';
            app.QtdApreendida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdApreendida.FontSize = 11;
            app.QtdApreendida.Layout.Row = 12;
            app.QtdApreendida.Layout.Column = 6;

            % Create QtdRetidaLabel
            app.QtdRetidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdRetidaLabel.VerticalAlignment = 'bottom';
            app.QtdRetidaLabel.FontSize = 11;
            app.QtdRetidaLabel.Layout.Row = 11;
            app.QtdRetidaLabel.Layout.Column = 7;
            app.QtdRetidaLabel.Text = 'Qtd. retida (RFB):';

            % Create QtdRetida
            app.QtdRetida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdRetida.Limits = [0 Inf];
            app.QtdRetida.RoundFractionalValues = 'on';
            app.QtdRetida.ValueDisplayFormat = '%.0f';
            app.QtdRetida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdRetida.FontSize = 11;
            app.QtdRetida.Layout.Row = 12;
            app.QtdRetida.Layout.Column = 7;

            % Create SituationLabel
            app.SituationLabel = uilabel(app.ProductStatusGrid);
            app.SituationLabel.VerticalAlignment = 'bottom';
            app.SituationLabel.FontSize = 11;
            app.SituationLabel.Layout.Row = 13;
            app.SituationLabel.Layout.Column = 1;
            app.SituationLabel.Text = 'Situação:';

            % Create Situation
            app.Situation = uidropdown(app.ProductStatusGrid);
            app.Situation.Items = {};
            app.Situation.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Situation.FontSize = 11;
            app.Situation.BackgroundColor = [1 1 1];
            app.Situation.Layout.Row = 14;
            app.Situation.Layout.Column = 1;
            app.Situation.Value = {};

            % Create ViolationTypeLabel
            app.ViolationTypeLabel = uilabel(app.ProductStatusGrid);
            app.ViolationTypeLabel.VerticalAlignment = 'bottom';
            app.ViolationTypeLabel.FontSize = 11;
            app.ViolationTypeLabel.Layout.Row = 13;
            app.ViolationTypeLabel.Layout.Column = [2 3];
            app.ViolationTypeLabel.Text = 'Infração:';

            % Create ViolationType
            app.ViolationType = uidropdown(app.ProductStatusGrid);
            app.ViolationType.Items = {};
            app.ViolationType.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.ViolationType.FontSize = 11;
            app.ViolationType.BackgroundColor = [1 1 1];
            app.ViolationType.Layout.Row = 14;
            app.ViolationType.Layout.Column = [2 3];
            app.ViolationType.Value = {};

            % Create CorrigibleLabel
            app.CorrigibleLabel = uilabel(app.ProductStatusGrid);
            app.CorrigibleLabel.VerticalAlignment = 'bottom';
            app.CorrigibleLabel.FontSize = 11;
            app.CorrigibleLabel.Layout.Row = 13;
            app.CorrigibleLabel.Layout.Column = 4;
            app.CorrigibleLabel.Text = 'Sanável?';

            % Create Corrigible
            app.Corrigible = uidropdown(app.ProductStatusGrid);
            app.Corrigible.Items = {};
            app.Corrigible.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Corrigible.FontSize = 11;
            app.Corrigible.BackgroundColor = [1 1 1];
            app.Corrigible.Layout.Row = 14;
            app.Corrigible.Layout.Column = 4;
            app.Corrigible.Value = {};

            % Create LacreLabel
            app.LacreLabel = uilabel(app.ProductStatusGrid);
            app.LacreLabel.VerticalAlignment = 'bottom';
            app.LacreLabel.FontSize = 11;
            app.LacreLabel.Layout.Row = 13;
            app.LacreLabel.Layout.Column = 5;
            app.LacreLabel.Text = 'Lacre:';

            % Create Lacre
            app.Lacre = uieditfield(app.ProductStatusGrid, 'text');
            app.Lacre.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Lacre.FontSize = 11;
            app.Lacre.Layout.Row = 14;
            app.Lacre.Layout.Column = 5;

            % Create PLAILabel
            app.PLAILabel = uilabel(app.ProductStatusGrid);
            app.PLAILabel.VerticalAlignment = 'bottom';
            app.PLAILabel.FontSize = 11;
            app.PLAILabel.Layout.Row = 13;
            app.PLAILabel.Layout.Column = [6 7];
            app.PLAILabel.Text = 'PLAI:';

            % Create PLAI
            app.PLAI = uieditfield(app.ProductStatusGrid, 'text');
            app.PLAI.CharacterLimits = [0 20];
            app.PLAI.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.PLAI.FontSize = 11;
            app.PLAI.Layout.Row = 14;
            app.PLAI.Layout.Column = [6 7];

            % Create NoteLabel
            app.NoteLabel = uilabel(app.ProductStatusGrid);
            app.NoteLabel.VerticalAlignment = 'bottom';
            app.NoteLabel.FontSize = 11;
            app.NoteLabel.Layout.Row = 15;
            app.NoteLabel.Layout.Column = [1 4];
            app.NoteLabel.Text = 'Informações adicionais:';

            % Create Note
            app.Note = uitextarea(app.ProductStatusGrid);
            app.Note.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Note.FontSize = 11;
            app.Note.Layout.Row = 16;
            app.Note.Layout.Column = [1 7];

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
