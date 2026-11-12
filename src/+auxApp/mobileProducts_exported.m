classdef mobileProducts_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        ViewRange           matlab.ui.control.Label
        CurrentFilterPanel  matlab.ui.container.Panel
        CurrentFilterGrid   matlab.ui.container.GridLayout
        SaveButton          matlab.ui.control.Button
        CurrentFilterLabel  matlab.ui.control.Label
        CurrentFilterIcon   matlab.ui.control.Image
        Products            matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryAppMobile'
        Context = 'PRODUCTS'
        AppHandleNameInBase = ''
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        jsBackDoor

        mainApp
        progressDialog
        projectData
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)                        

                    case 'onMobileProductEditRequested'
                        productIdx = str2double(event.HTMLEventData);
                        ipcMainMatlabOpenPopupApp(app.mainApp, app, 'ProductInfo', app.Context, productIdx)

                    case 'onMobileProductDeleteRequested'
                        deleteInspectedProduct(app, str2double(event.HTMLEventData))

                    case 'onMobileProductWarningRequested'
                        showInspectedProductWarnings(app, str2double(event.HTMLEventData))

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, eventName, varargin)
            try
                switch class(callingApp)
                    case {'mainApp.mobile', 'mainApp.mobile_exported'}
                        switch eventName
                            case {'updateInspectedProducts', ...
                                  'onProjectRestart',        ...
                                  'onProjectLoad',           ...
                                  'onInspectedProductEdited'}
                                renderInspectedProducts(app)

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

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            appName = class(app);
            elToModify = {
                app.CurrentFilterPanel;
                app.Products
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', app.CurrentFilterPanel.UserData.id, 'generation', 1, 'style', struct('borderRadius', '8px')) ...
                });
            catch
            end

            try
                ui.TextView.startup(app.jsBackDoor, app.Products, appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = app.mainApp.projectData;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.CurrentFilterPanel.BorderColor = '#c9d9ec';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            renderInspectedProducts(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function renderInspectedProducts(app)
            inspectedProducts = app.projectData.inspectedProducts;
            nProducts = height(inspectedProducts);

            if nProducts == 0
                app.ViewRange.Text = '';
                app.Products.Text = createWarningPlaceholder(app);
                return

            elseif nProducts == 1
                app.ViewRange.Text = 'Um único produto na lista  ';

            else
                app.ViewRange.Text = sprintf('%d produtos na lista  ', nProducts);
            end

            if isempty(app.AppHandleNameInBase) || ~evalin('base', sprintf('exist("%s", "var") && isa(%s, "%s") && isvalid(%s)', app.AppHandleNameInBase, app.AppHandleNameInBase, class(app), app.AppHandleNameInBase))
                app.AppHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);
            end

            invalidRowIdxs = validateInspectedProducts(app.projectData);

            cards = strings(nProducts, 1);
            for ii = 1:nProducts
                cards(ii) = createProductCard(app, inspectedProducts, ii, ismember(ii, invalidRowIdxs));
            end
            app.Products.Text = char(join(cards, newline));
        end

        %-----------------------------------------------------------------%
        function htmlPlaceholder = createWarningPlaceholder(app)
            title = 'Nenhum produto adicionado';
            message = 'Adicione um produto para iniciar<br>o preenchimento das informações';
            htmlPlaceholder = util.HtmlTextGenerator.createWarningPlaceholder(app.mainApp.General, title, message);
        end

        %-----------------------------------------------------------------%
        function htmlCard = createProductCard(app, inspectedProducts, rowIdx, isInvalid)
            homologation = char(string(inspectedProducts.('Homologação'){rowIdx}));
            if strcmp(homologation, '-')
                homologation = 'Produto não homologado';
            end

            situationColor = getSituationColor(app, homologation);

            manufacturer = char(string(inspectedProducts.('Fabricante'){rowIdx}));
            modelName    = char(string(inspectedProducts.('Modelo'){rowIdx}));
            if isempty(manufacturer)
                manufacturer = '(fabricante não informado)';
            end
            if isempty(modelName)
                modelName = '(modelo não informado)';
            end

            editButton   = createProductActionLink(app, 'onMobileProductEditRequested',   rowIdx, 'edit', '', 'Editar produto');
            deleteButton = createProductActionLink(app, 'onMobileProductDeleteRequested', rowIdx, 'customImage', 'close-16px-red.svg', 'Excluir produto');

            warningButton = '';
            if isInvalid
                warningButton = ['&nbsp;' createProductActionLink(app, 'onMobileProductWarningRequested', rowIdx, 'customImage', 'warning-20px-red.svg', 'Ver pendências do registro')];
            end

            htmlCard = sprintf([ ...
                '<section style="background-color: white; margin: 0 2px 0 0; padding: 10px; border: 1px solid #d7dce0; border-radius: 8px;">' ...
                    '<table style="width: 100%%;"><tbody><tr>' ...
                        '<td style="background-color: %s; width: 5px;"></td>' ...
                        '<td style="padding-left: 10px;"><p>' ...
                            '<font style="color: rgb(32, 32, 32); font-size: 16px;"><b>%s</b>%s</font><br>' ...
                            '<font style="color: rgb(96, 96, 96);">%s</font><br>' ...
                            '<font style="color: rgb(96, 96, 96);">%s</font>' ...
                        '</p></td>' ...
                        '<td style="width: 34px;"><font style="font-size: 13px;">%s</font></td>' ...
                        '<td style="width: 24px;">%s</td>' ...
                    '</tr></tbody></table>' ...
                '</section>' ...
            ], ...
                situationColor, ...
                escapeHtml(app, homologation), ...
                warningButton, ...
                escapeHtml(app, manufacturer), ...
                escapeHtml(app, modelName), ...
                editButton, ...
                deleteButton ...
            );
        end

        %-----------------------------------------------------------------%
        function htmlLink = createProductActionLink(app, eventName, rowIdx, linkType, iconName, tooltip)
            switch linkType
                case 'edit'
                    htmlLink = ui.TextView.createHTMLLink('edit', app.AppHandleNameInBase, eventName, num2str(rowIdx));
                otherwise
                    htmlLink = ui.TextView.createHTMLLink('customImage', app.AppHandleNameInBase, eventName, num2str(rowIdx), iconName, 20, 20, app.mainApp.General);
            end
            htmlLink = sprintf('<span title="%s">%s</span>', tooltip, htmlLink);
        end

        %-----------------------------------------------------------------%
        function showInspectedProductWarnings(app, rowIdx)
            if ~isscalar(rowIdx) || ~isfinite(rowIdx) || rowIdx < 1 || rowIdx > height(app.projectData.inspectedProducts)
                return
            end

            [~, ruleViolationMatrix] = validateInspectedProducts(app.projectData);
            if ~any(ruleViolationMatrix(rowIdx, :))
                return
            end

            html = util.HtmlTextGenerator.createInspectedProductWarnings(ruleViolationMatrix(rowIdx, :));

            sendEventToHTMLSource(app.jsBackDoor, 'textHighlight', struct( ...
                'dataTag',  'productWarnings', ...
                'imageUrl', 'warning-20px-red.svg', ...
                'title',    'Registro com pendências', ...
                'width',    85, ...
                'height',   60, ...
                'html',     html ...
            ));
        end

        %-----------------------------------------------------------------%
        function editInspectedProduct(app, rowIdx)
            if ~isscalar(rowIdx) || ~isfinite(rowIdx) || rowIdx < 1 || rowIdx > height(app.projectData.inspectedProducts)
                return
            end

            ui.Dialog(app.UIFigure, 'info', 'Edição de produto ainda não disponível nesta versão.');
        end

        %-----------------------------------------------------------------%
        function deleteInspectedProduct(app, rowIdx)
            if ~isscalar(rowIdx) || ~isfinite(rowIdx) || rowIdx < 1 || rowIdx > height(app.projectData.inspectedProducts)
                return
            end

            msgQuestion = 'Deseja excluir o produto da lista de produtos inspecionados?';
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            if strcmp(userSelection, 'Não')
                return
            end

            updateInspectedProducts(app.projectData, 'delete', rowIdx)
            renderInspectedProducts(app)
        end

        %-----------------------------------------------------------------%
        function color = getSituationColor(~, situation)
            switch string(situation)
                case 'Produto não homologado'
                    color = '#ea6071'; % 'rgb(192, 57, 43)';
                otherwise
                    color = '#84939d'; % 'rgb(128, 128, 128)';
            end
        end

        %-----------------------------------------------------------------%
        function escapedValue = escapeHtml(~, value)
            escapedValue = char(value);
            escapedValue = replace(escapedValue, {'&', '<', '>', '"', ''''}, {'&amp;', '&lt;', '&gt;', '&quot;', '&#39;'});
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                appEngine.boot(app, app.Role, mainApp)   

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            delete(app)
            
        end

        % Button pushed function: SaveButton
        function onAddNonCertificateButtonClicked(app, event)
            
            [productData, productHash] = model.ProjectBase.initializeInspectedProduct('NãoHomologado', app.mainApp.General);
            if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                ui.Dialog(app.UIFigure, 'warning', model.ProjectBase.WARNING_ENTRYEXIST.PRODUCTS);
                return
            end

            updateInspectedProducts(app.projectData, 'add', productData)
            renderInspectedProducts(app)

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
                app.UIFigure.Position = [100 100 387 754];
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
            app.GridLayout.RowHeight = {22, '1x', 97};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [10 10 10 42];
            app.GridLayout.BackgroundColor = [0.9451 0.9569 0.9608];

            % Create Products
            app.Products = uilabel(app.GridLayout);
            app.Products.VerticalAlignment = 'top';
            app.Products.WordWrap = 'on';
            app.Products.FontSize = 11;
            app.Products.Layout.Row = 2;
            app.Products.Layout.Column = [1 2];
            app.Products.Interpreter = 'html';
            app.Products.Text = '';

            % Create CurrentFilterPanel
            app.CurrentFilterPanel = uipanel(app.GridLayout);
            app.CurrentFilterPanel.Layout.Row = 3;
            app.CurrentFilterPanel.Layout.Column = [1 2];

            % Create CurrentFilterGrid
            app.CurrentFilterGrid = uigridlayout(app.CurrentFilterPanel);
            app.CurrentFilterGrid.ColumnWidth = {18, '1x', 18};
            app.CurrentFilterGrid.RowHeight = {22, '1x', 38};
            app.CurrentFilterGrid.ColumnSpacing = 5;
            app.CurrentFilterGrid.RowSpacing = 5;
            app.CurrentFilterGrid.BackgroundColor = [0.9333 0.9569 0.9843];

            % Create CurrentFilterIcon
            app.CurrentFilterIcon = uiimage(app.CurrentFilterGrid);
            app.CurrentFilterIcon.ScaleMethod = 'none';
            app.CurrentFilterIcon.Layout.Row = 1;
            app.CurrentFilterIcon.Layout.Column = 1;
            app.CurrentFilterIcon.ImageSource = 'package.svg';

            % Create CurrentFilterLabel
            app.CurrentFilterLabel = uilabel(app.CurrentFilterGrid);
            app.CurrentFilterLabel.VerticalAlignment = 'top';
            app.CurrentFilterLabel.WordWrap = 'on';
            app.CurrentFilterLabel.FontColor = [0 0.1294 0.2392];
            app.CurrentFilterLabel.Layout.Row = [1 2];
            app.CurrentFilterLabel.Layout.Column = 2;
            app.CurrentFilterLabel.Interpreter = 'html';
            app.CurrentFilterLabel.Text = {'<b>Produto não encontrado?</b>'; '<font style="font-size: 11px;">Você pode adicionar um produto não homologado à lista.</font>'};

            % Create SaveButton
            app.SaveButton = uibutton(app.CurrentFilterGrid, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @onAddNonCertificateButtonClicked, true);
            app.SaveButton.Icon = 'add-16px-white.svg';
            app.SaveButton.BackgroundColor = [0.0314 0.4902 0.7294];
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Layout.Row = 3;
            app.SaveButton.Layout.Column = 2;
            app.SaveButton.Text = 'Adicionar produto não homologado';

            % Create ViewRange
            app.ViewRange = uilabel(app.GridLayout);
            app.ViewRange.HorizontalAlignment = 'right';
            app.ViewRange.FontSize = 11;
            app.ViewRange.FontColor = [0.4588 0.5294 0.6];
            app.ViewRange.Layout.Row = 1;
            app.ViewRange.Layout.Column = [1 2];
            app.ViewRange.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mobileProducts_exported(Container, varargin)

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
