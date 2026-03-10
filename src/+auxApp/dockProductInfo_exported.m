classdef dockProductInfo_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        NextProduct           matlab.ui.control.Image
        PreviousProduct       matlab.ui.control.Image
        optNotes              matlab.ui.control.TextArea
        optNotesLabel         matlab.ui.control.Label
        Corrigible            matlab.ui.control.DropDown
        CorrigibleLabel       matlab.ui.control.Label
        ViolationType         matlab.ui.control.DropDown
        ViolationTypeLabel    matlab.ui.control.Label
        Situation             matlab.ui.control.DropDown
        SituationLabel        matlab.ui.control.Label
        PLAI                  matlab.ui.control.EditField
        PLAILabel             matlab.ui.control.Label
        Lacre                 matlab.ui.control.EditField
        LacreLabel            matlab.ui.control.Label
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
        nHom                  matlab.ui.control.EditField
        nHomLabel             matlab.ui.control.Label
        Index                 matlab.ui.control.NumericEditField
        IndexLabel            matlab.ui.control.Label
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
            app.Type.Items          = categories(app.projectData.inspectedProducts.("Tipo"));
            app.Subtype.Items       = {};
            app.Situation.Items     = categories(app.projectData.inspectedProducts.("Situação"));
            app.ViolationType.Items = categories(app.projectData.inspectedProducts.("Infração"));
            app.Corrigible.Items    = categories(app.projectData.inspectedProducts.("Sanável?"));

            idx = app.callingApp.UITable.Selection;
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
            [subtype, subtypeList] = checkTypeSubtypeProductsMapping(app.projectData, type, subtype);
            subtypeEnableList = ~isequal(subtypeList, {'-'});

            set(app.Subtype, 'Enable', subtypeEnableList, 'Items', subtypeList, 'Value', subtype)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context);
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
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTableCellEdited', "PRODUCTS", app.Index.Value)
            
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

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTableSelectionChanged', "PRODUCTS", idxNewRowSelection)
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
                app.UIFigure.Position = [100 100 580 640];
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
            app.GridLayout.ColumnWidth = {22, 22, '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout.RowHeight = {17, 22, 18, 22, 18, 22, 18, 22, 1, 17, 17, 17, 32, 22, 26, 22, 18, 22, 18, 22, 18, '1x', 22};
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create IndexLabel
            app.IndexLabel = uilabel(app.GridLayout);
            app.IndexLabel.VerticalAlignment = 'bottom';
            app.IndexLabel.FontSize = 10.5;
            app.IndexLabel.Layout.Row = 1;
            app.IndexLabel.Layout.Column = [1 2];
            app.IndexLabel.Text = '#';

            % Create Index
            app.Index = uieditfield(app.GridLayout, 'numeric');
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
            app.Index.Layout.Column = [1 2];
            app.Index.Value = 1;

            % Create nHomLabel
            app.nHomLabel = uilabel(app.GridLayout);
            app.nHomLabel.VerticalAlignment = 'bottom';
            app.nHomLabel.FontSize = 10.5;
            app.nHomLabel.Layout.Row = 1;
            app.nHomLabel.Layout.Column = [3 4];
            app.nHomLabel.Text = 'Homologação:';

            % Create nHom
            app.nHom = uieditfield(app.GridLayout, 'text');
            app.nHom.CharacterLimits = [0 14];
            app.nHom.Editable = 'off';
            app.nHom.FontSize = 11;
            app.nHom.Layout.Row = 2;
            app.nHom.Layout.Column = [3 4];
            app.nHom.Value = '-';

            % Create TypeLabel
            app.TypeLabel = uilabel(app.GridLayout);
            app.TypeLabel.VerticalAlignment = 'bottom';
            app.TypeLabel.FontSize = 10.5;
            app.TypeLabel.Layout.Row = 1;
            app.TypeLabel.Layout.Column = [5 6];
            app.TypeLabel.Text = 'Tipo:';

            % Create Type
            app.Type = uidropdown(app.GridLayout);
            app.Type.Items = {};
            app.Type.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Type.FontSize = 11;
            app.Type.BackgroundColor = [1 1 1];
            app.Type.Layout.Row = 2;
            app.Type.Layout.Column = [5 8];
            app.Type.Value = {};

            % Create SubtypeLabel
            app.SubtypeLabel = uilabel(app.GridLayout);
            app.SubtypeLabel.VerticalAlignment = 'bottom';
            app.SubtypeLabel.FontSize = 10.5;
            app.SubtypeLabel.Layout.Row = 3;
            app.SubtypeLabel.Layout.Column = [1 4];
            app.SubtypeLabel.Text = 'Subtipo:';

            % Create Subtype
            app.Subtype = uidropdown(app.GridLayout);
            app.Subtype.Items = {''};
            app.Subtype.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Subtype.Enable = 'off';
            app.Subtype.FontSize = 11;
            app.Subtype.BackgroundColor = [1 1 1];
            app.Subtype.Layout.Row = 4;
            app.Subtype.Layout.Column = [1 8];
            app.Subtype.Value = '';

            % Create ManufacturerLabel
            app.ManufacturerLabel = uilabel(app.GridLayout);
            app.ManufacturerLabel.VerticalAlignment = 'bottom';
            app.ManufacturerLabel.FontSize = 10.5;
            app.ManufacturerLabel.Layout.Row = 5;
            app.ManufacturerLabel.Layout.Column = [1 4];
            app.ManufacturerLabel.Text = 'Fabricante:';

            % Create Manufacturer
            app.Manufacturer = uieditfield(app.GridLayout, 'text');
            app.Manufacturer.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Manufacturer.FontSize = 11;
            app.Manufacturer.Layout.Row = 6;
            app.Manufacturer.Layout.Column = [1 6];

            % Create ModelLabel
            app.ModelLabel = uilabel(app.GridLayout);
            app.ModelLabel.VerticalAlignment = 'bottom';
            app.ModelLabel.FontSize = 10.5;
            app.ModelLabel.Layout.Row = 5;
            app.ModelLabel.Layout.Column = 7;
            app.ModelLabel.Text = 'Modelo:';

            % Create Model
            app.Model = uieditfield(app.GridLayout, 'text');
            app.Model.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Model.FontSize = 11;
            app.Model.Layout.Row = 6;
            app.Model.Layout.Column = [7 8];

            % Create ImportadorLabel
            app.ImportadorLabel = uilabel(app.GridLayout);
            app.ImportadorLabel.VerticalAlignment = 'bottom';
            app.ImportadorLabel.FontSize = 10.5;
            app.ImportadorLabel.Layout.Row = 7;
            app.ImportadorLabel.Layout.Column = [1 4];
            app.ImportadorLabel.Text = 'Importador:';

            % Create Importador
            app.Importador = uieditfield(app.GridLayout, 'text');
            app.Importador.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Importador.FontSize = 11;
            app.Importador.Layout.Row = 8;
            app.Importador.Layout.Column = [1 6];

            % Create CodAduanaLabel
            app.CodAduanaLabel = uilabel(app.GridLayout);
            app.CodAduanaLabel.VerticalAlignment = 'bottom';
            app.CodAduanaLabel.FontSize = 10.5;
            app.CodAduanaLabel.Layout.Row = 7;
            app.CodAduanaLabel.Layout.Column = [7 8];
            app.CodAduanaLabel.Text = 'Código aduaneiro:';

            % Create CodAduana
            app.CodAduana = uieditfield(app.GridLayout, 'text');
            app.CodAduana.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.CodAduana.FontSize = 11;
            app.CodAduana.Layout.Row = 8;
            app.CodAduana.Layout.Column = [7 8];

            % Create RF
            app.RF = uicheckbox(app.GridLayout);
            app.RF.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.RF.Text = 'Evidenciado que se trata de produto que usa RF.';
            app.RF.FontSize = 11;
            app.RF.Layout.Row = 10;
            app.RF.Layout.Column = [1 5];

            % Create InUse
            app.InUse = uicheckbox(app.GridLayout);
            app.InUse.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.InUse.Text = 'Evidenciado USO do produto.';
            app.InUse.FontSize = 11;
            app.InUse.Layout.Row = 11;
            app.InUse.Layout.Column = [1 5];

            % Create Interference
            app.Interference = uicheckbox(app.GridLayout);
            app.Interference.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Interference.Text = 'Evidenciada INTERFERÊNCIA decorrente do uso do produto.';
            app.Interference.FontSize = 11;
            app.Interference.Layout.Row = 12;
            app.Interference.Layout.Column = [1 8];

            % Create UnitPriceLabel
            app.UnitPriceLabel = uilabel(app.GridLayout);
            app.UnitPriceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceLabel.FontSize = 10.5;
            app.UnitPriceLabel.Layout.Row = 13;
            app.UnitPriceLabel.Layout.Column = [1 2];
            app.UnitPriceLabel.Text = {'Valor unit.'; '(R$):'};

            % Create UnitPrice
            app.UnitPrice = uieditfield(app.GridLayout, 'numeric');
            app.UnitPrice.Limits = [0 Inf];
            app.UnitPrice.ValueDisplayFormat = '%.2f';
            app.UnitPrice.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.UnitPrice.FontSize = 11;
            app.UnitPrice.Layout.Row = 14;
            app.UnitPrice.Layout.Column = [1 2];

            % Create UnitPriceSourceLabel
            app.UnitPriceSourceLabel = uilabel(app.GridLayout);
            app.UnitPriceSourceLabel.VerticalAlignment = 'bottom';
            app.UnitPriceSourceLabel.FontSize = 10.5;
            app.UnitPriceSourceLabel.Layout.Row = 13;
            app.UnitPriceSourceLabel.Layout.Column = [3 8];
            app.UnitPriceSourceLabel.Text = {'Fonte do valor:'; '(nota fiscal, site na internet, mostruário de loja etc)'};

            % Create UnitPriceSource
            app.UnitPriceSource = uieditfield(app.GridLayout, 'text');
            app.UnitPriceSource.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.UnitPriceSource.FontSize = 11;
            app.UnitPriceSource.Layout.Row = 14;
            app.UnitPriceSource.Layout.Column = [3 8];

            % Create QtdVendidaLabel
            app.QtdVendidaLabel = uilabel(app.GridLayout);
            app.QtdVendidaLabel.VerticalAlignment = 'bottom';
            app.QtdVendidaLabel.FontSize = 10.5;
            app.QtdVendidaLabel.Layout.Row = 15;
            app.QtdVendidaLabel.Layout.Column = [1 2];
            app.QtdVendidaLabel.Text = {'Qtd.'; 'vendida:'};

            % Create QtdVendida
            app.QtdVendida = uieditfield(app.GridLayout, 'numeric');
            app.QtdVendida.Limits = [0 Inf];
            app.QtdVendida.RoundFractionalValues = 'on';
            app.QtdVendida.ValueDisplayFormat = '%.0f';
            app.QtdVendida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdVendida.FontSize = 11;
            app.QtdVendida.Layout.Row = 16;
            app.QtdVendida.Layout.Column = [1 2];

            % Create QtdUsoLabel
            app.QtdUsoLabel = uilabel(app.GridLayout);
            app.QtdUsoLabel.VerticalAlignment = 'bottom';
            app.QtdUsoLabel.FontSize = 10.5;
            app.QtdUsoLabel.Layout.Row = 15;
            app.QtdUsoLabel.Layout.Column = 3;
            app.QtdUsoLabel.Text = {'Qtd.'; 'em uso:'};

            % Create QtdUso
            app.QtdUso = uieditfield(app.GridLayout, 'numeric');
            app.QtdUso.Limits = [0 Inf];
            app.QtdUso.RoundFractionalValues = 'on';
            app.QtdUso.ValueDisplayFormat = '%.0f';
            app.QtdUso.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdUso.FontSize = 11;
            app.QtdUso.Layout.Row = 16;
            app.QtdUso.Layout.Column = 3;

            % Create QtdEstoqueLabel
            app.QtdEstoqueLabel = uilabel(app.GridLayout);
            app.QtdEstoqueLabel.VerticalAlignment = 'bottom';
            app.QtdEstoqueLabel.FontSize = 10.5;
            app.QtdEstoqueLabel.Layout.Row = 15;
            app.QtdEstoqueLabel.Layout.Column = [4 5];
            app.QtdEstoqueLabel.Text = {'Qtd.'; 'estoque/aduana:'};

            % Create QtdEstoque
            app.QtdEstoque = uieditfield(app.GridLayout, 'numeric');
            app.QtdEstoque.Limits = [0 Inf];
            app.QtdEstoque.RoundFractionalValues = 'on';
            app.QtdEstoque.ValueDisplayFormat = '%.0f';
            app.QtdEstoque.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdEstoque.FontSize = 11;
            app.QtdEstoque.Layout.Row = 16;
            app.QtdEstoque.Layout.Column = 4;

            % Create QtdAnunciadaLabel
            app.QtdAnunciadaLabel = uilabel(app.GridLayout);
            app.QtdAnunciadaLabel.VerticalAlignment = 'bottom';
            app.QtdAnunciadaLabel.FontSize = 10.5;
            app.QtdAnunciadaLabel.Layout.Row = 15;
            app.QtdAnunciadaLabel.Layout.Column = 5;
            app.QtdAnunciadaLabel.Text = {'Qtd.'; 'anunciada:'};

            % Create QtdAnunciada
            app.QtdAnunciada = uieditfield(app.GridLayout, 'numeric');
            app.QtdAnunciada.Limits = [0 Inf];
            app.QtdAnunciada.RoundFractionalValues = 'on';
            app.QtdAnunciada.ValueDisplayFormat = '%.0f';
            app.QtdAnunciada.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdAnunciada.FontSize = 11;
            app.QtdAnunciada.Layout.Row = 16;
            app.QtdAnunciada.Layout.Column = 5;

            % Create QtdLacradaLabel
            app.QtdLacradaLabel = uilabel(app.GridLayout);
            app.QtdLacradaLabel.VerticalAlignment = 'bottom';
            app.QtdLacradaLabel.FontSize = 10.5;
            app.QtdLacradaLabel.Layout.Row = 15;
            app.QtdLacradaLabel.Layout.Column = 6;
            app.QtdLacradaLabel.Text = {'Qtd.'; 'lacrada:'};

            % Create QtdLacrada
            app.QtdLacrada = uieditfield(app.GridLayout, 'numeric');
            app.QtdLacrada.Limits = [0 Inf];
            app.QtdLacrada.RoundFractionalValues = 'on';
            app.QtdLacrada.ValueDisplayFormat = '%.0f';
            app.QtdLacrada.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdLacrada.FontSize = 11;
            app.QtdLacrada.Layout.Row = 16;
            app.QtdLacrada.Layout.Column = 6;

            % Create QtdApreendidaLabel
            app.QtdApreendidaLabel = uilabel(app.GridLayout);
            app.QtdApreendidaLabel.VerticalAlignment = 'bottom';
            app.QtdApreendidaLabel.FontSize = 10.5;
            app.QtdApreendidaLabel.Layout.Row = 15;
            app.QtdApreendidaLabel.Layout.Column = 7;
            app.QtdApreendidaLabel.Text = {'Qtd.'; 'apreendida:'};

            % Create QtdApreendida
            app.QtdApreendida = uieditfield(app.GridLayout, 'numeric');
            app.QtdApreendida.Limits = [0 Inf];
            app.QtdApreendida.RoundFractionalValues = 'on';
            app.QtdApreendida.ValueDisplayFormat = '%.0f';
            app.QtdApreendida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdApreendida.FontSize = 11;
            app.QtdApreendida.Layout.Row = 16;
            app.QtdApreendida.Layout.Column = 7;

            % Create QtdRetidaLabel
            app.QtdRetidaLabel = uilabel(app.GridLayout);
            app.QtdRetidaLabel.VerticalAlignment = 'bottom';
            app.QtdRetidaLabel.FontSize = 10.5;
            app.QtdRetidaLabel.Layout.Row = 15;
            app.QtdRetidaLabel.Layout.Column = 8;
            app.QtdRetidaLabel.Text = {'Qtd.'; 'retida (RFB):'};

            % Create QtdRetida
            app.QtdRetida = uieditfield(app.GridLayout, 'numeric');
            app.QtdRetida.Limits = [0 Inf];
            app.QtdRetida.RoundFractionalValues = 'on';
            app.QtdRetida.ValueDisplayFormat = '%.0f';
            app.QtdRetida.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.QtdRetida.FontSize = 11;
            app.QtdRetida.Layout.Row = 16;
            app.QtdRetida.Layout.Column = 8;

            % Create LacreLabel
            app.LacreLabel = uilabel(app.GridLayout);
            app.LacreLabel.VerticalAlignment = 'bottom';
            app.LacreLabel.FontSize = 10.5;
            app.LacreLabel.Layout.Row = 17;
            app.LacreLabel.Layout.Column = [1 4];
            app.LacreLabel.Text = 'Lacre:';

            % Create Lacre
            app.Lacre = uieditfield(app.GridLayout, 'text');
            app.Lacre.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Lacre.FontSize = 11;
            app.Lacre.Layout.Row = 18;
            app.Lacre.Layout.Column = [1 6];

            % Create PLAILabel
            app.PLAILabel = uilabel(app.GridLayout);
            app.PLAILabel.VerticalAlignment = 'bottom';
            app.PLAILabel.FontSize = 10.5;
            app.PLAILabel.Layout.Row = 17;
            app.PLAILabel.Layout.Column = [7 8];
            app.PLAILabel.Text = 'PLAI:';

            % Create PLAI
            app.PLAI = uieditfield(app.GridLayout, 'text');
            app.PLAI.CharacterLimits = [0 20];
            app.PLAI.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.PLAI.FontSize = 11;
            app.PLAI.Layout.Row = 18;
            app.PLAI.Layout.Column = [7 8];

            % Create SituationLabel
            app.SituationLabel = uilabel(app.GridLayout);
            app.SituationLabel.VerticalAlignment = 'bottom';
            app.SituationLabel.FontSize = 10.5;
            app.SituationLabel.Layout.Row = 19;
            app.SituationLabel.Layout.Column = [1 3];
            app.SituationLabel.Text = 'Situação:';

            % Create Situation
            app.Situation = uidropdown(app.GridLayout);
            app.Situation.Items = {'Irregular', 'Regular'};
            app.Situation.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Situation.FontSize = 11;
            app.Situation.BackgroundColor = [1 1 1];
            app.Situation.Layout.Row = 20;
            app.Situation.Layout.Column = [1 3];
            app.Situation.Value = 'Irregular';

            % Create ViolationTypeLabel
            app.ViolationTypeLabel = uilabel(app.GridLayout);
            app.ViolationTypeLabel.VerticalAlignment = 'bottom';
            app.ViolationTypeLabel.FontSize = 10.5;
            app.ViolationTypeLabel.Layout.Row = 19;
            app.ViolationTypeLabel.Layout.Column = [4 7];
            app.ViolationTypeLabel.Text = 'Infração:';

            % Create ViolationType
            app.ViolationType = uidropdown(app.GridLayout);
            app.ViolationType.Items = {'Comercialização', 'Identificação homologação', 'Uso'};
            app.ViolationType.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.ViolationType.FontSize = 11;
            app.ViolationType.BackgroundColor = [1 1 1];
            app.ViolationType.Layout.Row = 20;
            app.ViolationType.Layout.Column = [4 6];
            app.ViolationType.Value = 'Comercialização';

            % Create CorrigibleLabel
            app.CorrigibleLabel = uilabel(app.GridLayout);
            app.CorrigibleLabel.VerticalAlignment = 'bottom';
            app.CorrigibleLabel.FontSize = 10.5;
            app.CorrigibleLabel.Layout.Row = 19;
            app.CorrigibleLabel.Layout.Column = [7 8];
            app.CorrigibleLabel.Text = 'Sanável?';

            % Create Corrigible
            app.Corrigible = uidropdown(app.GridLayout);
            app.Corrigible.Items = {'-', 'Sim', 'Não'};
            app.Corrigible.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.Corrigible.FontSize = 11;
            app.Corrigible.BackgroundColor = [1 1 1];
            app.Corrigible.Layout.Row = 20;
            app.Corrigible.Layout.Column = [7 8];
            app.Corrigible.Value = '-';

            % Create optNotesLabel
            app.optNotesLabel = uilabel(app.GridLayout);
            app.optNotesLabel.VerticalAlignment = 'bottom';
            app.optNotesLabel.FontSize = 10.5;
            app.optNotesLabel.Layout.Row = 21;
            app.optNotesLabel.Layout.Column = [1 4];
            app.optNotesLabel.Text = 'Informações adicionais:';

            % Create optNotes
            app.optNotes = uitextarea(app.GridLayout);
            app.optNotes.ValueChangedFcn = createCallbackFcn(app, @ParameterValueChanged, true);
            app.optNotes.FontSize = 11;
            app.optNotes.Layout.Row = 22;
            app.optNotes.Layout.Column = [1 8];

            % Create PreviousProduct
            app.PreviousProduct = uiimage(app.GridLayout);
            app.PreviousProduct.ImageClickedFcn = createCallbackFcn(app, @PreviousProductImageClicked, true);
            app.PreviousProduct.Tooltip = {'Navega para o produto anterior'};
            app.PreviousProduct.Layout.Row = 23;
            app.PreviousProduct.Layout.Column = 1;
            app.PreviousProduct.ImageSource = 'Previous_32.png';

            % Create NextProduct
            app.NextProduct = uiimage(app.GridLayout);
            app.NextProduct.ImageClickedFcn = createCallbackFcn(app, @PreviousProductImageClicked, true);
            app.NextProduct.Tooltip = {'Navega para o produto posterior'};
            app.NextProduct.Layout.Row = 23;
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
