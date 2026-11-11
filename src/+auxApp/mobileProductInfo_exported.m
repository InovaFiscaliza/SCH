classdef mobileProductInfo_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        ProductStatusGrid     matlab.ui.container.GridLayout
        Note                  matlab.ui.control.TextArea
        NoteLabel             matlab.ui.control.Label
        Lacre                 matlab.ui.control.EditField
        LacreLabel            matlab.ui.control.Label
        PLAI                  matlab.ui.control.EditField
        PLAILabel             matlab.ui.control.Label
        ViolationType         matlab.ui.control.DropDown
        ViolationTypeLabel    matlab.ui.control.Label
        Corrigible            matlab.ui.control.DropDown
        CorrigibleLabel       matlab.ui.control.Label
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
        HomologationPanel     matlab.ui.container.Panel
        HomologationGrid      matlab.ui.container.GridLayout
        ProductNext           matlab.ui.control.Image
        ProductPrevious       matlab.ui.control.Image
        ProductPosition       matlab.ui.control.Label
        Homologation          matlab.ui.control.Label
        HomologationIcon      matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockAppMobile'
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


    methods
        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, eventName, varargin)
            try
                switch class(callingApp)
                    case {'mainApp.mobile', 'mainApp.mobile_exported'}
                        switch eventName
                            case 'updateForm'
                                currentProductIdx = varargin{1};
                                app.inputArgs.selectedProductIdx = currentProductIdx;
                                updateForm(app, currentProductIdx)

                            otherwise
                                error('auxApp:mobileProducts:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end
    
                    otherwise
                        error('auxApp:mobileProducts:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end
    end
    
    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.HomologationPanel;
                app.Type;
                app.Subtype;
                app.Manufacturer;
                app.Model;
                app.Importador;
                app.CodAduana;
                app.UnitPrice;
                app.UnitPriceSource;
                app.QtdVendida;
                app.QtdUso;
                app.QtdEstoque;
                app.QtdAnunciada;
                app.QtdLacrada;
                app.QtdApreendida;
                app.QtdRetida;
                app.Situation;
                app.ViolationType;
                app.Corrigible;
                app.Lacre;
                app.PLAI;
                app.Note
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);
    
            try
                sendEventToHTMLSource(app.mainApp.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.HomologationPanel.UserData.id, 'generation', 1, 'style', struct('borderRadius', '8px')), ...
                    struct('appName', appName, 'dataTag', app.Type.UserData.id,              'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Subtype.UserData.id,           'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Manufacturer.UserData.id,      'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Model.UserData.id,             'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Importador.UserData.id,        'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.CodAduana.UserData.id,         'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.UnitPrice.UserData.id,         'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.UnitPriceSource.UserData.id,   'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdVendida.UserData.id,        'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdUso.UserData.id,            'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdEstoque.UserData.id,        'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdAnunciada.UserData.id,      'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdLacrada.UserData.id,        'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdApreendida.UserData.id,     'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.QtdRetida.UserData.id,         'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Situation.UserData.id,         'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.ViolationType.UserData.id,     'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Corrigible.UserData.id,        'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Lacre.UserData.id,             'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.PLAI.UserData.id,              'generation', 1, 'style', struct('borderColor', '#AEBBC2')), ...
                    struct('appName', appName, 'dataTag', app.Note.UserData.id,              'generation', 1, 'style', struct('borderColor', '#AEBBC2')) ...
                });
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initialValues(app)
            app.HomologationPanel.BorderColor = '#c9d9ec';
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
            if strcmp(homologation, '-')
                homologation = 'Produto não homologado';
            end

            app.Homologation.Text = sprintf([ ...
                '<section>' ...
                    '<table style="width: 100%%;">' ...
                        '<tbody>' ...
                            '<tr>' ...
                                '<td><font style="font-size: 16px;"><b>%s</b></font><br>Caracterização do produto e levantamento de informações fiscalizatórias.</td>' ...
                                '<td style="width: 76px;"><section style="border: 1px solid #C3D9EC; border-radius: 5px; padding: 5px; margin-right: 2px; background-color: #DCEBFA; color: #245A7A">Em edição</section></td>' ...
                            '</tr>' ...
                        '</tbody>' ...
                    '</table>' ...
                '</section>' ...
            ], homologation);

            numProducts = height(app.projectData.inspectedProducts);
            app.ProductPosition.Text = sprintf('%d de %d', currentProductIdx, numProducts);
            set([app.ProductNext, app.ProductPrevious], 'Enable', numProducts > 1)

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
                applyJSCustomizations(app)
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
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onInspectedProductEdited', "PRODUCTS", currentProductIdx)
            
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
            updateForm(app, newProductIdx)
            focus(app.UIFigure)

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
                app.UIFigure.Position = [100 100 387 720];
                app.UIFigure.Name = 'SCH';
                app.UIFigure.Icon = 'icon_32.png';
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
            app.GridLayout.ColumnWidth = {'1x', 28, 28};
            app.GridLayout.RowHeight = {92, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [10 10 10 12];
            app.GridLayout.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create HomologationPanel
            app.HomologationPanel = uipanel(app.GridLayout);
            app.HomologationPanel.AutoResizeChildren = 'off';
            app.HomologationPanel.Layout.Row = 1;
            app.HomologationPanel.Layout.Column = [1 3];

            % Create HomologationGrid
            app.HomologationGrid = uigridlayout(app.HomologationPanel);
            app.HomologationGrid.ColumnWidth = {18, 5, '1x', 10, 28, 28};
            app.HomologationGrid.RowHeight = {22, '1x', 22};
            app.HomologationGrid.ColumnSpacing = 0;
            app.HomologationGrid.RowSpacing = 0;
            app.HomologationGrid.BackgroundColor = [0.9333 0.9569 0.9843];

            % Create HomologationIcon
            app.HomologationIcon = uiimage(app.HomologationGrid);
            app.HomologationIcon.ScaleMethod = 'none';
            app.HomologationIcon.Layout.Row = 1;
            app.HomologationIcon.Layout.Column = 1;
            app.HomologationIcon.ImageSource = 'package.svg';

            % Create Homologation
            app.Homologation = uilabel(app.HomologationGrid);
            app.Homologation.VerticalAlignment = 'top';
            app.Homologation.WordWrap = 'on';
            app.Homologation.FontSize = 11;
            app.Homologation.FontColor = [0 0.1294 0.2392];
            app.Homologation.Layout.Row = [1 2];
            app.Homologation.Layout.Column = [3 6];
            app.Homologation.Interpreter = 'html';
            app.Homologation.Text = '';

            % Create ProductPosition
            app.ProductPosition = uilabel(app.HomologationGrid);
            app.ProductPosition.HorizontalAlignment = 'right';
            app.ProductPosition.FontSize = 11;
            app.ProductPosition.FontColor = [0.4588 0.5294 0.6];
            app.ProductPosition.Layout.Row = 3;
            app.ProductPosition.Layout.Column = 3;
            app.ProductPosition.Text = '';

            % Create ProductPrevious
            app.ProductPrevious = uiimage(app.HomologationGrid);
            app.ProductPrevious.ImageClickedFcn = createCallbackFcn(app, @onProductsArrowButtonClicked, true);
            app.ProductPrevious.Layout.Row = 3;
            app.ProductPrevious.Layout.Column = 5;
            app.ProductPrevious.ImageSource = 'chevron-left.svg';

            % Create ProductNext
            app.ProductNext = uiimage(app.HomologationGrid);
            app.ProductNext.ImageClickedFcn = createCallbackFcn(app, @onProductsArrowButtonClicked, true);
            app.ProductNext.Layout.Row = 3;
            app.ProductNext.Layout.Column = 6;
            app.ProductNext.ImageSource = 'chevron-right.svg';

            % Create ProductStatusGrid
            app.ProductStatusGrid = uigridlayout(app.GridLayout);
            app.ProductStatusGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.ProductStatusGrid.RowHeight = {22, 38, 22, 38, 22, 38, 22, 38, 22, 28, 28, 28, 1, 22, 38, 22, 38, 22, 38, 22, 38, 22, 38, 22, 38, 22, 38, 22, 76, '1x'};
            app.ProductStatusGrid.RowSpacing = 5;
            app.ProductStatusGrid.Padding = [0 0 1 0];
            app.ProductStatusGrid.Layout.Row = 2;
            app.ProductStatusGrid.Layout.Column = [1 3];
            app.ProductStatusGrid.Scrollable = 'on';
            app.ProductStatusGrid.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create TypeLabel
            app.TypeLabel = uilabel(app.ProductStatusGrid);
            app.TypeLabel.VerticalAlignment = 'bottom';
            app.TypeLabel.FontWeight = 'bold';
            app.TypeLabel.FontColor = [0 0.1294 0.2392];
            app.TypeLabel.Layout.Row = 1;
            app.TypeLabel.Layout.Column = 1;
            app.TypeLabel.Text = 'Tipo:';

            % Create Type
            app.Type = uidropdown(app.ProductStatusGrid);
            app.Type.Items = {''};
            app.Type.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Type.FontColor = [0 0.1294 0.2392];
            app.Type.BackgroundColor = [1 1 1];
            app.Type.Layout.Row = 2;
            app.Type.Layout.Column = [1 3];
            app.Type.Value = '';

            % Create SubtypeLabel
            app.SubtypeLabel = uilabel(app.ProductStatusGrid);
            app.SubtypeLabel.VerticalAlignment = 'bottom';
            app.SubtypeLabel.FontWeight = 'bold';
            app.SubtypeLabel.FontColor = [0 0.1294 0.2392];
            app.SubtypeLabel.Layout.Row = 3;
            app.SubtypeLabel.Layout.Column = 1;
            app.SubtypeLabel.Text = 'Subtipo:';

            % Create Subtype
            app.Subtype = uidropdown(app.ProductStatusGrid);
            app.Subtype.Items = {''};
            app.Subtype.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Subtype.Enable = 'off';
            app.Subtype.FontColor = [0 0.1294 0.2392];
            app.Subtype.BackgroundColor = [1 1 1];
            app.Subtype.Layout.Row = 4;
            app.Subtype.Layout.Column = [1 3];
            app.Subtype.Value = '';

            % Create ManufacturerLabel
            app.ManufacturerLabel = uilabel(app.ProductStatusGrid);
            app.ManufacturerLabel.VerticalAlignment = 'bottom';
            app.ManufacturerLabel.FontWeight = 'bold';
            app.ManufacturerLabel.FontColor = [0 0.1294 0.2392];
            app.ManufacturerLabel.Layout.Row = 5;
            app.ManufacturerLabel.Layout.Column = [1 2];
            app.ManufacturerLabel.Text = 'Fabricante:';

            % Create Manufacturer
            app.Manufacturer = uieditfield(app.ProductStatusGrid, 'text');
            app.Manufacturer.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Manufacturer.FontColor = [0 0.1294 0.2392];
            app.Manufacturer.Layout.Row = 6;
            app.Manufacturer.Layout.Column = [1 2];

            % Create ModelLabel
            app.ModelLabel = uilabel(app.ProductStatusGrid);
            app.ModelLabel.VerticalAlignment = 'bottom';
            app.ModelLabel.FontWeight = 'bold';
            app.ModelLabel.FontColor = [0 0.1294 0.2392];
            app.ModelLabel.Layout.Row = 5;
            app.ModelLabel.Layout.Column = 3;
            app.ModelLabel.Text = 'Modelo:';

            % Create Model
            app.Model = uieditfield(app.ProductStatusGrid, 'text');
            app.Model.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Model.FontColor = [0 0.1294 0.2392];
            app.Model.Layout.Row = 6;
            app.Model.Layout.Column = 3;

            % Create ImportadorLabel
            app.ImportadorLabel = uilabel(app.ProductStatusGrid);
            app.ImportadorLabel.VerticalAlignment = 'bottom';
            app.ImportadorLabel.FontWeight = 'bold';
            app.ImportadorLabel.FontColor = [0 0.1294 0.2392];
            app.ImportadorLabel.Layout.Row = 7;
            app.ImportadorLabel.Layout.Column = [1 2];
            app.ImportadorLabel.Text = 'Importador:';

            % Create Importador
            app.Importador = uieditfield(app.ProductStatusGrid, 'text');
            app.Importador.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Importador.FontColor = [0 0.1294 0.2392];
            app.Importador.Layout.Row = 8;
            app.Importador.Layout.Column = [1 2];

            % Create CodAduanaLabel
            app.CodAduanaLabel = uilabel(app.ProductStatusGrid);
            app.CodAduanaLabel.VerticalAlignment = 'bottom';
            app.CodAduanaLabel.FontWeight = 'bold';
            app.CodAduanaLabel.FontColor = [0 0.1294 0.2392];
            app.CodAduanaLabel.Layout.Row = 7;
            app.CodAduanaLabel.Layout.Column = 3;
            app.CodAduanaLabel.Text = 'Código aduaneiro:';

            % Create CodAduana
            app.CodAduana = uieditfield(app.ProductStatusGrid, 'text');
            app.CodAduana.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.CodAduana.FontColor = [0 0.1294 0.2392];
            app.CodAduana.Layout.Row = 8;
            app.CodAduana.Layout.Column = 3;

            % Create EvidenceLabel
            app.EvidenceLabel = uilabel(app.ProductStatusGrid);
            app.EvidenceLabel.VerticalAlignment = 'bottom';
            app.EvidenceLabel.FontWeight = 'bold';
            app.EvidenceLabel.FontColor = [0 0.1294 0.2392];
            app.EvidenceLabel.Layout.Row = 9;
            app.EvidenceLabel.Layout.Column = [1 2];
            app.EvidenceLabel.Text = 'Evidências:';

            % Create RF
            app.RF = uicheckbox(app.ProductStatusGrid);
            app.RF.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.RF.Text = 'Produto usa RF';
            app.RF.FontColor = [0 0.1294 0.2392];
            app.RF.Layout.Row = 10;
            app.RF.Layout.Column = [1 3];

            % Create InUse
            app.InUse = uicheckbox(app.ProductStatusGrid);
            app.InUse.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.InUse.Text = 'Produto foi UTILIZADO';
            app.InUse.FontColor = [0 0.1294 0.2392];
            app.InUse.Layout.Row = 11;
            app.InUse.Layout.Column = [1 3];

            % Create Interference
            app.Interference = uicheckbox(app.ProductStatusGrid);
            app.Interference.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Interference.Text = 'Houve INTERFERÊNCIA decorrente do uso';
            app.Interference.WordWrap = 'on';
            app.Interference.FontColor = [0 0.1294 0.2392];
            app.Interference.Layout.Row = 12;
            app.Interference.Layout.Column = [1 3];

            % Create UnitPriceLabel
            app.UnitPriceLabel = uilabel(app.ProductStatusGrid);
            app.UnitPriceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceLabel.FontWeight = 'bold';
            app.UnitPriceLabel.FontColor = [0 0.1294 0.2392];
            app.UnitPriceLabel.Layout.Row = 14;
            app.UnitPriceLabel.Layout.Column = 1;
            app.UnitPriceLabel.Text = 'Valor unitário (R$):';

            % Create UnitPrice
            app.UnitPrice = uieditfield(app.ProductStatusGrid, 'numeric');
            app.UnitPrice.Limits = [0 Inf];
            app.UnitPrice.ValueDisplayFormat = '%.2f';
            app.UnitPrice.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.UnitPrice.FontColor = [0 0.1294 0.2392];
            app.UnitPrice.Layout.Row = 15;
            app.UnitPrice.Layout.Column = 1;

            % Create UnitPriceSourceLabel
            app.UnitPriceSourceLabel = uilabel(app.ProductStatusGrid);
            app.UnitPriceSourceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceSourceLabel.FontWeight = 'bold';
            app.UnitPriceSourceLabel.FontColor = [0 0.1294 0.2392];
            app.UnitPriceSourceLabel.Layout.Row = 14;
            app.UnitPriceSourceLabel.Layout.Column = [2 3];
            app.UnitPriceSourceLabel.Text = 'Fonte (nota fiscal, mostruário etc):';

            % Create UnitPriceSource
            app.UnitPriceSource = uieditfield(app.ProductStatusGrid, 'text');
            app.UnitPriceSource.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.UnitPriceSource.FontColor = [0 0.1294 0.2392];
            app.UnitPriceSource.Layout.Row = 15;
            app.UnitPriceSource.Layout.Column = [2 3];

            % Create QtdVendidaLabel
            app.QtdVendidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdVendidaLabel.VerticalAlignment = 'bottom';
            app.QtdVendidaLabel.FontWeight = 'bold';
            app.QtdVendidaLabel.FontColor = [0 0.1294 0.2392];
            app.QtdVendidaLabel.Layout.Row = 16;
            app.QtdVendidaLabel.Layout.Column = 1;
            app.QtdVendidaLabel.Text = 'Qtd. vendida:';

            % Create QtdVendida
            app.QtdVendida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdVendida.Limits = [0 Inf];
            app.QtdVendida.RoundFractionalValues = 'on';
            app.QtdVendida.ValueDisplayFormat = '%.0f';
            app.QtdVendida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdVendida.FontColor = [0 0.1294 0.2392];
            app.QtdVendida.Layout.Row = 17;
            app.QtdVendida.Layout.Column = 1;

            % Create QtdUsoLabel
            app.QtdUsoLabel = uilabel(app.ProductStatusGrid);
            app.QtdUsoLabel.VerticalAlignment = 'bottom';
            app.QtdUsoLabel.FontWeight = 'bold';
            app.QtdUsoLabel.FontColor = [0 0.1294 0.2392];
            app.QtdUsoLabel.Layout.Row = 16;
            app.QtdUsoLabel.Layout.Column = 2;
            app.QtdUsoLabel.Text = 'Qtd. em uso:';

            % Create QtdUso
            app.QtdUso = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdUso.Limits = [0 Inf];
            app.QtdUso.RoundFractionalValues = 'on';
            app.QtdUso.ValueDisplayFormat = '%.0f';
            app.QtdUso.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdUso.FontColor = [0 0.1294 0.2392];
            app.QtdUso.Layout.Row = 17;
            app.QtdUso.Layout.Column = 2;

            % Create QtdEstoqueLabel
            app.QtdEstoqueLabel = uilabel(app.ProductStatusGrid);
            app.QtdEstoqueLabel.VerticalAlignment = 'bottom';
            app.QtdEstoqueLabel.FontWeight = 'bold';
            app.QtdEstoqueLabel.FontColor = [0 0.1294 0.2392];
            app.QtdEstoqueLabel.Layout.Row = 16;
            app.QtdEstoqueLabel.Layout.Column = 3;
            app.QtdEstoqueLabel.Text = 'Qtd. estoque:';

            % Create QtdEstoque
            app.QtdEstoque = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdEstoque.Limits = [0 Inf];
            app.QtdEstoque.RoundFractionalValues = 'on';
            app.QtdEstoque.ValueDisplayFormat = '%.0f';
            app.QtdEstoque.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdEstoque.FontColor = [0 0.1294 0.2392];
            app.QtdEstoque.Layout.Row = 17;
            app.QtdEstoque.Layout.Column = 3;

            % Create QtdAnunciadaLabel
            app.QtdAnunciadaLabel = uilabel(app.ProductStatusGrid);
            app.QtdAnunciadaLabel.VerticalAlignment = 'bottom';
            app.QtdAnunciadaLabel.FontWeight = 'bold';
            app.QtdAnunciadaLabel.FontColor = [0 0.1294 0.2392];
            app.QtdAnunciadaLabel.Layout.Row = 18;
            app.QtdAnunciadaLabel.Layout.Column = 1;
            app.QtdAnunciadaLabel.Text = 'Qtd. anunciada:';

            % Create QtdAnunciada
            app.QtdAnunciada = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdAnunciada.Limits = [0 Inf];
            app.QtdAnunciada.RoundFractionalValues = 'on';
            app.QtdAnunciada.ValueDisplayFormat = '%.0f';
            app.QtdAnunciada.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdAnunciada.FontColor = [0 0.1294 0.2392];
            app.QtdAnunciada.Layout.Row = 19;
            app.QtdAnunciada.Layout.Column = 1;

            % Create QtdLacradaLabel
            app.QtdLacradaLabel = uilabel(app.ProductStatusGrid);
            app.QtdLacradaLabel.VerticalAlignment = 'bottom';
            app.QtdLacradaLabel.FontWeight = 'bold';
            app.QtdLacradaLabel.FontColor = [0 0.1294 0.2392];
            app.QtdLacradaLabel.Layout.Row = 18;
            app.QtdLacradaLabel.Layout.Column = 2;
            app.QtdLacradaLabel.Text = 'Qtd. lacrada:';

            % Create QtdLacrada
            app.QtdLacrada = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdLacrada.Limits = [0 Inf];
            app.QtdLacrada.RoundFractionalValues = 'on';
            app.QtdLacrada.ValueDisplayFormat = '%.0f';
            app.QtdLacrada.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdLacrada.FontColor = [0 0.1294 0.2392];
            app.QtdLacrada.Layout.Row = 19;
            app.QtdLacrada.Layout.Column = 2;

            % Create QtdApreendidaLabel
            app.QtdApreendidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdApreendidaLabel.VerticalAlignment = 'bottom';
            app.QtdApreendidaLabel.FontWeight = 'bold';
            app.QtdApreendidaLabel.FontColor = [0 0.1294 0.2392];
            app.QtdApreendidaLabel.Layout.Row = 18;
            app.QtdApreendidaLabel.Layout.Column = 3;
            app.QtdApreendidaLabel.Text = 'Qtd. apreendida:';

            % Create QtdApreendida
            app.QtdApreendida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdApreendida.Limits = [0 Inf];
            app.QtdApreendida.RoundFractionalValues = 'on';
            app.QtdApreendida.ValueDisplayFormat = '%.0f';
            app.QtdApreendida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdApreendida.FontColor = [0 0.1294 0.2392];
            app.QtdApreendida.Layout.Row = 19;
            app.QtdApreendida.Layout.Column = 3;

            % Create QtdRetidaLabel
            app.QtdRetidaLabel = uilabel(app.ProductStatusGrid);
            app.QtdRetidaLabel.VerticalAlignment = 'bottom';
            app.QtdRetidaLabel.FontWeight = 'bold';
            app.QtdRetidaLabel.FontColor = [0 0.1294 0.2392];
            app.QtdRetidaLabel.Layout.Row = 20;
            app.QtdRetidaLabel.Layout.Column = 1;
            app.QtdRetidaLabel.Text = 'Qtd. retida (RFB):';

            % Create QtdRetida
            app.QtdRetida = uieditfield(app.ProductStatusGrid, 'numeric');
            app.QtdRetida.Limits = [0 Inf];
            app.QtdRetida.RoundFractionalValues = 'on';
            app.QtdRetida.ValueDisplayFormat = '%.0f';
            app.QtdRetida.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.QtdRetida.FontColor = [0 0.1294 0.2392];
            app.QtdRetida.Layout.Row = 21;
            app.QtdRetida.Layout.Column = 1;

            % Create SituationLabel
            app.SituationLabel = uilabel(app.ProductStatusGrid);
            app.SituationLabel.VerticalAlignment = 'bottom';
            app.SituationLabel.FontWeight = 'bold';
            app.SituationLabel.FontColor = [0 0.1294 0.2392];
            app.SituationLabel.Layout.Row = 22;
            app.SituationLabel.Layout.Column = 1;
            app.SituationLabel.Text = 'Situação:';

            % Create Situation
            app.Situation = uidropdown(app.ProductStatusGrid);
            app.Situation.Items = {};
            app.Situation.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Situation.FontColor = [0 0.1294 0.2392];
            app.Situation.BackgroundColor = [1 1 1];
            app.Situation.Layout.Row = 23;
            app.Situation.Layout.Column = [1 2];
            app.Situation.Value = {};

            % Create CorrigibleLabel
            app.CorrigibleLabel = uilabel(app.ProductStatusGrid);
            app.CorrigibleLabel.VerticalAlignment = 'bottom';
            app.CorrigibleLabel.FontWeight = 'bold';
            app.CorrigibleLabel.FontColor = [0 0.1294 0.2392];
            app.CorrigibleLabel.Layout.Row = 22;
            app.CorrigibleLabel.Layout.Column = 3;
            app.CorrigibleLabel.Text = 'Sanável?';

            % Create Corrigible
            app.Corrigible = uidropdown(app.ProductStatusGrid);
            app.Corrigible.Items = {};
            app.Corrigible.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Corrigible.FontColor = [0 0.1294 0.2392];
            app.Corrigible.BackgroundColor = [1 1 1];
            app.Corrigible.Layout.Row = 23;
            app.Corrigible.Layout.Column = 3;
            app.Corrigible.Value = {};

            % Create ViolationTypeLabel
            app.ViolationTypeLabel = uilabel(app.ProductStatusGrid);
            app.ViolationTypeLabel.VerticalAlignment = 'bottom';
            app.ViolationTypeLabel.FontWeight = 'bold';
            app.ViolationTypeLabel.FontColor = [0 0.1294 0.2392];
            app.ViolationTypeLabel.Layout.Row = 24;
            app.ViolationTypeLabel.Layout.Column = [1 2];
            app.ViolationTypeLabel.Text = 'Infração:';

            % Create ViolationType
            app.ViolationType = uidropdown(app.ProductStatusGrid);
            app.ViolationType.Items = {};
            app.ViolationType.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.ViolationType.FontColor = [0 0.1294 0.2392];
            app.ViolationType.BackgroundColor = [1 1 1];
            app.ViolationType.Layout.Row = 25;
            app.ViolationType.Layout.Column = [1 3];
            app.ViolationType.Value = {};

            % Create PLAILabel
            app.PLAILabel = uilabel(app.ProductStatusGrid);
            app.PLAILabel.VerticalAlignment = 'bottom';
            app.PLAILabel.FontWeight = 'bold';
            app.PLAILabel.FontColor = [0 0.1294 0.2392];
            app.PLAILabel.Layout.Row = 26;
            app.PLAILabel.Layout.Column = [1 2];
            app.PLAILabel.Text = 'PLAI:';

            % Create PLAI
            app.PLAI = uieditfield(app.ProductStatusGrid, 'text');
            app.PLAI.CharacterLimits = [0 20];
            app.PLAI.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.PLAI.FontColor = [0 0.1294 0.2392];
            app.PLAI.Layout.Row = 27;
            app.PLAI.Layout.Column = [1 2];

            % Create LacreLabel
            app.LacreLabel = uilabel(app.ProductStatusGrid);
            app.LacreLabel.VerticalAlignment = 'bottom';
            app.LacreLabel.FontWeight = 'bold';
            app.LacreLabel.FontColor = [0 0.1294 0.2392];
            app.LacreLabel.Layout.Row = 26;
            app.LacreLabel.Layout.Column = 3;
            app.LacreLabel.Text = 'Lacre:';

            % Create Lacre
            app.Lacre = uieditfield(app.ProductStatusGrid, 'text');
            app.Lacre.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Lacre.FontColor = [0 0.1294 0.2392];
            app.Lacre.Layout.Row = 27;
            app.Lacre.Layout.Column = 3;

            % Create NoteLabel
            app.NoteLabel = uilabel(app.ProductStatusGrid);
            app.NoteLabel.VerticalAlignment = 'bottom';
            app.NoteLabel.FontWeight = 'bold';
            app.NoteLabel.FontColor = [0 0.1294 0.2392];
            app.NoteLabel.Layout.Row = 28;
            app.NoteLabel.Layout.Column = [1 3];
            app.NoteLabel.Text = 'Informações adicionais:';

            % Create Note
            app.Note = uitextarea(app.ProductStatusGrid);
            app.Note.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Note.FontColor = [0 0.1294 0.2392];
            app.Note.Layout.Row = [29 30];
            app.Note.Layout.Column = [1 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobileProductInfo_exported(Container, varargin)

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
