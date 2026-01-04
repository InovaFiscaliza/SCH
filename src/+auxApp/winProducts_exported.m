classdef winProducts_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        DockModule               matlab.ui.container.GridLayout
        dockModule_Undock        matlab.ui.control.Image
        dockModule_Close         matlab.ui.control.Image
        UITable_ViewType         matlab.ui.container.ButtonGroup
        UITable_CustomsView      matlab.ui.control.RadioButton
        UITable_VendorView       matlab.ui.control.RadioButton
        UITable_NumRows          matlab.ui.control.Label
        UITable                  matlab.ui.control.Table
        Toolbar                  matlab.ui.container.GridLayout
        tool_Separator           matlab.ui.control.Image
        tool_OpenPopupEdition_2  matlab.ui.control.Image
        tool_UploadFinalFile     matlab.ui.control.Image
        tool_GenerateReport      matlab.ui.control.Image
        tool_OpenPopupProject    matlab.ui.control.Image
        tool_AddNonCertificate   matlab.ui.control.Image
        tool_OpenPopupEdition    matlab.ui.control.Image
        ContextMenu              matlab.ui.container.ContextMenu
        ContextMenu_EditFcn      matlab.ui.container.Menu
        ContextMenu_DeleteFcn    matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog
        popupContainer
        SubTabGroup = struct('Children', -1, 'UserData', [])
        projectData
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        warningIconStyle      = uistyle('Icon', 'warning-20px-red.svg', 'IconAlignment', 'rightmargin')
        warningHighlightStyle = uistyle('BackgroundColor', '#c80b0f', 'FontColor', 'white')
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)                        

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function ipcSecondaryMatlabCallsHandler(app, callingApp, operationType, varargin)
            try
                switch class(callingApp)
                    case {'winSCH', 'winSCH_exported'}
                        switch operationType
                            % auxApp.dockProductInfo >> winSCH >> auxApp.winProducts
                            % auxApp.dockReportLib >> winSCH >> auxApp.winProducts
                            case 'closeFcnCallFromPopupApp'
                                app.popupContainer.Parent.Visible = 0;
                                
                            % winSCH >> auxApp.winProducts
                            % auxApp.dockReportLib >> winSCH >> auxApp.winProducts
                            % auxApp.dockProductInfo >> winSCH >> auxApp.winProducts                            
                            case {'updateInspectedProducts', ...
                                  'onProjectRestart',        ...
                                  'onProjectLoad',           ...
                                  'onTableCellEdited'}
                                syncInspectedTableWithUI(app, 'dataToGuiSync')

                            % auxApp.dockProductInfo >> winSCH >> auxApp.winProducts
                            case 'onTableSelectionChanged'
                                selectedRow = varargin{1};

                                app.UITable.Selection = selectedRow;
                                onTableSelectionChanged(app)

                            % auxApp.dockReportLib >> winSCH >> auxApp.winProducts
                            case 'onFinalReportFileChanged'
                                updateToolbar(app)

                            otherwise
                                error('UnexpectedCall')
                        end
    
                    otherwise
                        error('UnexpectedCall')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;
            
            switch tabIndex
                case 1
                    ui.CustomizationBase.getElementsDataTag({app.UITable});

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.UITable.RowName = 'numbered';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            syncInspectedTableWithUI(app, 'dataToGuiSync')
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function syncInspectedTableWithUI(app, syncType)
            arguments
                app
                syncType char {mustBeMember(syncType, {'guiToDataSync', 'dataToGuiSync', 'tableViewChanged'})}
            end

            viewType    = app.UITable_ViewType.SelectedObject.Tag; % 'vendorView' | 'customsView'
            columnList  = app.mainApp.General.ui.reportTable.(viewType).name';
            columnIndex = cellfun(@(x) find(strcmp(app.projectData.inspectedProducts.Properties.VariableNames, x), 1), columnList);

            switch syncType
                case 'guiToDataSync'
                    updateInspectedProducts(app.projectData, 'edit', 1:height(app.projectData.inspectedProducts), columnIndex, app.UITable.Data)

                case 'dataToGuiSync'
                    app.UITable.Data = app.projectData.inspectedProducts(:, columnIndex);

                case 'tableViewChanged'
                    set(app.UITable, 'Data',        app.projectData.inspectedProducts(:, columnIndex),    ...
                                     'ColumnName',  app.mainApp.General.ui.reportTable.(viewType).label', ...
                                     'ColumnWidth', app.mainApp.General.ui.reportTable.(viewType).columnWidth')
            end

            updateTableStyle(app)
            updateTableNumRows(app)
            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function updateTableNumRows(app)
            nRows = height(app.UITable.Data);
            app.UITable_NumRows.Text = sprintf('%d <font style="font-size: 10px;">REGISTROS </font>', nRows);
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            removeStyle(app.UITable)

            if ~isempty(app.projectData.inspectedProducts)
                [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateInspectedProducts(app.projectData);

                if ~isempty(invalidRowIndexes)
                    applyRowStyle(app, invalidRowIndexes)
                    applyCellStyle(app, ruleViolationMatrix, ruleColumns)
                end
            end
        end

        %-----------------------------------------------------------------%
        function applyRowStyle(app, invalidRowIndexes)
            s = app.warningIconStyle;
            addStyle(app.UITable, s, "cell", [invalidRowIndexes, ones(numel(invalidRowIndexes), 1)])
        end

        %-----------------------------------------------------------------%
        function applyCellStyle(app, ruleViolationMatrix, ruleColumns)
            cellList = [];
            for ii = 1:numel(ruleColumns)
                rowIndex = find(ruleViolationMatrix(:,ii));

                if ~isempty(rowIndex)
                    columnNames = ruleColumns{ii};
                    columnIndex = find(ismember(app.UITable.Data.Properties.VariableNames, columnNames));

                    for jj = 1:numel(columnIndex)
                        cellList = [cellList; [rowIndex, repmat(columnIndex(jj), numel(rowIndex), 1)]];
                    end
                end
            end

            s = app.warningHighlightStyle;
            addStyle(app.UITable, s, "cell", cellList)
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            context = 'PRODUCTS';

            nonEmptyListOfProducts           = ~isempty(app.projectData.inspectedProducts);
            nonEmptyTableSelection           = ~isempty(app.UITable.Selection);            
            reportFinalVersionGenerated      = ~isempty(app.projectData.modules.(context).generatedFiles.lastHTMLDocFullPath);

            app.tool_OpenPopupEdition.Enable = nonEmptyListOfProducts;
            app.ContextMenu_EditFcn.Enable   = nonEmptyListOfProducts;
            app.ContextMenu_DeleteFcn.Enable = nonEmptyTableSelection;
            app.tool_GenerateReport.Enable   = nonEmptyListOfProducts;
            app.tool_UploadFinalFile.Enable  = reportFinalVersionGenerated;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            try
                app.projectData = mainApp.projectData;
                appEngine.boot(app, app.Role, mainApp)                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', "PRODUCTS")
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;
                    
                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];
                    
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Callback function: ContextMenu_EditFcn, tool_OpenPopupEdition
        function Toolbar_EditSelectedImageClicked(app, event)
            
            % Por alguma razão desconhecida, inseri algumas validações
            % aqui! :)
            
            % Enfim... a possibilidade de editar um registro não deve
            % existir toda vez que a tabela esteja vazia ou que não
            % esteja selecionada uma linha.
            selectedRow = app.UITable.Selection;

            if isempty(selectedRow)
                if isempty(app.UITable.Data)
                    updateToolbar(app)
                    return
                end

                app.UITable.Selection = 1;
                onTableSelectionChanged(app)
            elseif ~isscalar(selectedRow)
                app.UITable.Selection = app.UITable.Selection(1);
            end

            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'ProductInfo')

        end

        % Image clicked function: tool_AddNonCertificate
        function Toolbar_AddNonCertificateImageClicked(app, event)
            
            [productData, productHash] = model.projectLib.initializeInspectedProduct('NãoHomologado', app.mainApp.General);
            if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                ui.Dialog(app.UIFigure, 'warning', model.projectLib.WARNING_ENTRYEXIST.PRODUCTS);
                return
            end

            updateInspectedProducts(app.projectData, 'add', productData)
            syncInspectedTableWithUI(app, 'dataToGuiSync')

        end

        % Image clicked function: tool_GenerateReport
        function Toolbar_GenerateReportImageClicked(app, event)
            
            % context = 'ExternalRequest';
            % indexes = FileIndex(app);
            % 
            % if ~isempty(indexes)
            %     % <VALIDAÇÕES>
            %     if numel(indexes) < numel(app.measData)
            %         initialQuestion  = 'Deseja gerar relatório que contemple informações de TODAS as localidades de agrupamento, ou apenas da SELECIONADA?';
            %         initialSelection = ui.Dialog(app.UIFigure, 'uiconfirm', initialQuestion, {'Todas', 'Selecionada', 'Cancelar'}, 1, 3);
            % 
            %         switch initialSelection
            %             case 'Cancelar'
            %                 return
            %             case 'Todas'
            %                 indexes = 1:numel(app.measData);
            %         end
            %     end
            % 
            %     warningMessages = {};
            %     if ~report_checkEFiscalizaIssueId(app.mainApp, app.projectData.modules.(context).ui.issue)
            %         warningMessages{end+1} = sprintf('O número da inspeção "%.0f" é inválido.', app.projectData.modules.(context).ui.issue);
            %     end
            % 
            %     if ~isempty(layout_searchUnexpectedTableValues(app))
            %         warningMessages{end+1} = ['Há registro de pontos críticos localizados na(s) localidade(s) sob análise para os quais '     ...
            %                                   'não foram identificadas medidas no entorno. Nesse caso específico, deve-se preencher ' ...
            %                                   'o campo "Justificativa" e anotar os registros, caso aplicável.'];
            %     end
            % 
            %     if ~isempty(warningMessages)
            %         warningMessages = strjoin(warningMessages, '<br><br>');
            % 
            %         switch app.reportVersion.Value
            %             case 'Definitiva'
            %                 warningMessages = [warningMessages, '<br><br>Isso impossibilita a geração da versão DEFINITIVA do relatório.'];
            %                 ui.Dialog(app.UIFigure, "warning", warningMessages);
            %                 return
            % 
            %             otherwise % 'Preliminar'
            %                 warningMessages = [warningMessages, '<br><br>Deseja ignorar esse alerta, gerando a versão PRÉVIA do relatório?'];
            %                 userSelection   = ui.Dialog(app.UIFigure, 'uiconfirm', warningMessages, {'Sim', 'Não'}, 2, 2);
            %                 if userSelection == "Não"
            %                     return
            %                 end
            %         end
            %     end
            %     % </VALIDAÇÕES>
            % 
            %     % <PROCESSO>
            %     app.progressDialog.Visible = 'visible';
            % 
            %     try
            %         reportSettings = struct('system',        app.reportSystem.Value, ...
            %                                 'unit',          app.reportUnit.Value, ...
            %                                 'issue',         app.reportIssue.Value, ...
            %                                 'model',         app.report_ModelName.Value, ...
            %                                 'reportVersion', app.reportVersion.Value);
            %         reportLibConnection.Controller.Run(app, app.projectData, app.measData(indexes), reportSettings, app.mainApp.General)
            %     catch ME
            %         ui.Dialog(app.UIFigure, 'error', getReport(ME));
            %     end
            % 
            %     updateToolbar(app)
            % 
            %     app.progressDialog.Visible = 'hidden';
            %     % </PROCESSO>
            % end

        end

        % Image clicked function: tool_UploadFinalFile
        function Toolbar_UploadFinalFileImageClicked(app, event)
            
            % <VALIDAÇÕES>
            context = 'Products';
            lastHTMLDocFullPath = getGeneratedDocumentFileName(app.projectData, '.html', context);

            msg = '';
            if isempty(lastHTMLDocFullPath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(lastHTMLDocFullPath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', lastHTMLDocFullPath);
            elseif ~isfolder(app.mainApp.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            elseif ~report_checkEFiscalizaIssueId(app.mainApp, app.projectData.modules.(context).ui.issue)
                msg = sprintf('O número da inspeção "%.0f" é inválido.', app.projectData.modules.(context).ui.issue);
            elseif isempty(app.projectData.modules.(context).ui.system)
                msg = 'Ambiente do eFiscaliza precisa ser selecionado.';
            elseif isempty(app.projectData.modules.(context).ui.unit)
                msg = 'Unidade geradora do documento precisa ser selecionada.';
            end

            if ~isempty(msg)
                ui.Dialog(app.UIFigure, 'warning', msg);
                return
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            if isempty(app.mainApp.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'eFiscalizaSignInPage', 'Fields', dialogBox, 'Context', context))
            else
                report_uploadInfoController(app.mainApp, [], 'uploadDocument', context)
            end
            % </PROCESSO>

        end

        % Selection changed function: UITable_ViewType
        function TableViewChanged(app, event)
            
            syncInspectedTableWithUI(app, 'tableViewChanged')
            
        end

        % Selection changed function: UITable
        function onTableSelectionChanged(app, event)
            
            updateToolbar(app)
            
        end

        % Cell edit callback: UITable
        function onTableCellEdited(app, event)
            
            % BUG "MATLAB R2024a Update 7":
            % Ao clicar no dropdown (colunas categóricas) e clicar fora do
            % painel (do dropdown) ou selecionar o valor já selecionado, o
            % MATLAB dispara esse callback. A primeira validação evita fazer
            % atualizações desnessárias.
            if iscellstr(event.Source.Data{event.Indices(1), event.Indices(2)})
                event.Source.Data{event.Indices(1), event.Indices(2)} = strtrim(event.Source.Data{event.Indices(1), event.Indices(2)});
            end

            if isequal(event.PreviousData, event.NewData)
                return

            elseif isnumeric(event.NewData) && ((event.NewData < 0) || isnan(event.NewData))
                event.Source.Data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                return

            elseif ischar(event.NewData) && isequal(strtrim(event.NewData), event.PreviousData)
                event.Source.Data{event.Indices(1), event.Indices(2)} = {event.PreviousData};
                return

            % Outro comportamento inesperado é a possibilidade de editar as
            % categorias das colunas categóricas. Para evitar isso, afere-se
            % se o nome valor é membro da lista de valores esperados.
            else
                editedGUIColumn = event.Source.ColumnName{event.Indices(2)};

                if (strcmpi(editedGUIColumn, 'TIPO')     && ~ismember(event.NewData, app.mainApp.General.ui.typeOfProduct.options))   || ...
                   (strcmpi(editedGUIColumn, 'SITUAÇÃO') && ~ismember(event.NewData, app.mainApp.General.ui.typeOfSituation.options)) || ...
                   (strcmpi(editedGUIColumn, 'INFRAÇÃO') && ~ismember(event.NewData, app.mainApp.General.ui.typeOfViolation.options)) || ...
                   (strcmpi(editedGUIColumn, 'SANÁVEL?') && ~ismember(event.NewData, {'-', 'Sim', 'Não'}))

                    columnNames      = app.projectData.inspectedProducts.Properties.VariableNames;
                    editedRealColumn = columnNames{find(strcmpi(editedGUIColumn, columnNames), 1)};

                    app.UITable.Data.(editedRealColumn) = app.projectData.inspectedProducts.(editedRealColumn);
                    return
                end

                if strcmp(event.Source.Data.("Homologação"){event.Indices(1)}, '-') && ismember(editedGUIColumn, {'FABRICANTE', 'MODELO'})
                    newProductHash = model.projectLib.computeInspectedProductHash('-', event.Source.Data.("Fabricante"){event.Indices(1)}, event.Source.Data.("Modelo"){event.Indices(1)});

                    if ismember(newProductHash, app.projectData.inspectedProducts.("Hash"))
                        event.Source.Data{event.Indices(1), event.Indices(2)} = {event.PreviousData};                        
                        ui.Dialog(app.UIFigure, 'warning', model.projectLib.WARNING_ENTRYEXIST.PRODUCTS);
                        return
                    end
                end
            end

            syncInspectedTableWithUI(app, 'guiToDataSync')
            
        end

        % Menu selected function: ContextMenu_DeleteFcn
        function ContextMenu_Delete(app, event)
            
            selectedTableIndex = app.UITable.Selection;

            if ~isempty(selectedTableIndex)
                updateInspectedProducts(app.projectData, 'delete', selectedTableIndex)
                syncInspectedTableWithUI(app, 'dataToGuiSync')
            end

        end

        % Image clicked function: tool_OpenPopupEdition_2
        function tool_OpenPopupEdition_2ImageClicked(app, event)
            
            msg = [ ...
                'As informações de tipo, fabricante, modelo e situação são obrigatórias. Além disso, a soma das quantidades em uso, vendida, em estoque/aduana e anunciada deve ser maior que zero.' ...
                '<br><br>' ...
                'Caso evidenciada situação <b>REGULAR</b>:<br>' ...
                '•&thinsp;Não admite infração.<br>' ...
                '•&thinsp;Não pode haver quantidades lacradas, apreendidas ou retidas.' ...    
                '<br><br>' ...
                'Caso evidenciada situação <b>IRREGULAR</b>:<br>' ...
                '•&thinsp;A infração é obrigatória.<br>' ...
                '•&thinsp;A soma das quantidades lacradas, apreendidas e retidas não pode exceder a soma das quantidades em uso e em estoque/aduana.<br>' ...
                '•&thinsp;É obrigatória a estimativa do valor unitário, além da indicação da fonte da estimativa, como, por exemplo, nota fiscal, sistema de controle de estoque ou pesquisa de mercado.' ...
            ];

            ui.Dialog(app.UIFigure, 'none', msg);

        end

        % Image clicked function: tool_OpenPopupProject
        function tool_OpenPopupProjectImageClicked(app, event)
            
            context = 'PRODUCTS';
            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'ReportLib', context)

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
                app.UIFigure.Position = [100 100 1244 660];
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
            app.GridLayout.ColumnWidth = {10, 48, '1x', 412, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, 19, 3, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, '1x', 22, 22, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 8;
            app.Toolbar.Layout.Column = [1 8];

            % Create tool_OpenPopupEdition
            app.tool_OpenPopupEdition = uiimage(app.Toolbar);
            app.tool_OpenPopupEdition.ScaleMethod = 'none';
            app.tool_OpenPopupEdition.ImageClickedFcn = createCallbackFcn(app, @Toolbar_EditSelectedImageClicked, true);
            app.tool_OpenPopupEdition.Enable = 'off';
            app.tool_OpenPopupEdition.Tooltip = {'Edita lista de produtos sob análise'};
            app.tool_OpenPopupEdition.Layout.Row = [1 3];
            app.tool_OpenPopupEdition.Layout.Column = 3;
            app.tool_OpenPopupEdition.ImageSource = 'Variable_edit_16.png';

            % Create tool_AddNonCertificate
            app.tool_AddNonCertificate = uiimage(app.Toolbar);
            app.tool_AddNonCertificate.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AddNonCertificateImageClicked, true);
            app.tool_AddNonCertificate.Tooltip = {'Adiciona produto NÃO homologado à lista'};
            app.tool_AddNonCertificate.Layout.Row = [1 3];
            app.tool_AddNonCertificate.Layout.Column = 4;
            app.tool_AddNonCertificate.ImageSource = 'AddForbidden_32.png';

            % Create tool_OpenPopupProject
            app.tool_OpenPopupProject = uiimage(app.Toolbar);
            app.tool_OpenPopupProject.ScaleMethod = 'none';
            app.tool_OpenPopupProject.ImageClickedFcn = createCallbackFcn(app, @tool_OpenPopupProjectImageClicked, true);
            app.tool_OpenPopupProject.Tooltip = {'Projeto (fiscalizada, arquivo de backup etc)'};
            app.tool_OpenPopupProject.Layout.Row = [1 3];
            app.tool_OpenPopupProject.Layout.Column = 6;
            app.tool_OpenPopupProject.ImageSource = 'organization-20px-black.svg';

            % Create tool_GenerateReport
            app.tool_GenerateReport = uiimage(app.Toolbar);
            app.tool_GenerateReport.ScaleMethod = 'none';
            app.tool_GenerateReport.ImageClickedFcn = createCallbackFcn(app, @Toolbar_GenerateReportImageClicked, true);
            app.tool_GenerateReport.Enable = 'off';
            app.tool_GenerateReport.Tooltip = {'Gera relatório'};
            app.tool_GenerateReport.Layout.Row = [1 3];
            app.tool_GenerateReport.Layout.Column = 7;
            app.tool_GenerateReport.ImageSource = 'Publish_HTML_16.png';

            % Create tool_UploadFinalFile
            app.tool_UploadFinalFile = uiimage(app.Toolbar);
            app.tool_UploadFinalFile.ImageClickedFcn = createCallbackFcn(app, @Toolbar_UploadFinalFileImageClicked, true);
            app.tool_UploadFinalFile.Enable = 'off';
            app.tool_UploadFinalFile.Tooltip = {'Upload relatório'};
            app.tool_UploadFinalFile.Layout.Row = 2;
            app.tool_UploadFinalFile.Layout.Column = 8;
            app.tool_UploadFinalFile.ImageSource = 'Up_24.png';

            % Create tool_OpenPopupEdition_2
            app.tool_OpenPopupEdition_2 = uiimage(app.Toolbar);
            app.tool_OpenPopupEdition_2.ScaleMethod = 'fill';
            app.tool_OpenPopupEdition_2.ImageClickedFcn = createCallbackFcn(app, @tool_OpenPopupEdition_2ImageClicked, true);
            app.tool_OpenPopupEdition_2.Tooltip = {'Apresenta regras de validação'};
            app.tool_OpenPopupEdition_2.Layout.Row = 2;
            app.tool_OpenPopupEdition_2.Layout.Column = 1;
            app.tool_OpenPopupEdition_2.ImageSource = 'warning-20px-red.svg';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 2;
            app.tool_Separator.ImageSource = 'LineV.svg';

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.UITable.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'FONTE|VALOR'; 'QTD.|VENDIDA'; 'QTD.|EM USO'; 'QTD.|ESTOQUE'; 'QTD.|ANUNCIADA'; 'QTD.|LACRADA'; 'QTD.|APREENDIDA'; 'QTD.|RETIDA (RFB)'; 'SITUAÇÃO'; 'INFRAÇÃO'};
            app.UITable.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 42, 96, 90, 'auto', 90, 90, 90, 90, 90, 90, 90, 'auto', 'auto'};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false true true true true true true true true true true true true true true true true true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @onTableCellEdited, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Tooltip = {''};
            app.UITable.Layout.Row = 6;
            app.UITable.Layout.Column = [2 6];
            app.UITable.FontSize = 10;

            % Create UITable_NumRows
            app.UITable_NumRows = uilabel(app.GridLayout);
            app.UITable_NumRows.HorizontalAlignment = 'right';
            app.UITable_NumRows.VerticalAlignment = 'bottom';
            app.UITable_NumRows.FontSize = 11;
            app.UITable_NumRows.FontColor = [0.502 0.502 0.502];
            app.UITable_NumRows.Layout.Row = 4;
            app.UITable_NumRows.Layout.Column = [5 6];
            app.UITable_NumRows.Interpreter = 'html';
            app.UITable_NumRows.Text = '0 <font style="font-size: 10px;">REGISTROS </font>';

            % Create UITable_ViewType
            app.UITable_ViewType = uibuttongroup(app.GridLayout);
            app.UITable_ViewType.AutoResizeChildren = 'off';
            app.UITable_ViewType.SelectionChangedFcn = createCallbackFcn(app, @TableViewChanged, true);
            app.UITable_ViewType.BorderType = 'none';
            app.UITable_ViewType.TitlePosition = 'centertop';
            app.UITable_ViewType.Title = 'LISTA DE PRODUTOS SOB ANÁLISE';
            app.UITable_ViewType.BackgroundColor = [1 1 1];
            app.UITable_ViewType.Layout.Row = [3 4];
            app.UITable_ViewType.Layout.Column = 4;
            app.UITable_ViewType.FontWeight = 'bold';
            app.UITable_ViewType.FontSize = 10;

            % Create UITable_VendorView
            app.UITable_VendorView = uiradiobutton(app.UITable_ViewType);
            app.UITable_VendorView.Tag = 'vendorView';
            app.UITable_VendorView.Text = 'Fornecedor | Usuário';
            app.UITable_VendorView.FontSize = 10;
            app.UITable_VendorView.Position = [120 2 121 22];
            app.UITable_VendorView.Value = true;

            % Create UITable_CustomsView
            app.UITable_CustomsView = uiradiobutton(app.UITable_ViewType);
            app.UITable_CustomsView.Tag = 'customsView';
            app.UITable_CustomsView.Text = 'Aduana';
            app.UITable_CustomsView.FontSize = 10;
            app.UITable_CustomsView.Position = [244 2 72 22];

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [6 7];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winProducts';

            % Create ContextMenu_EditFcn
            app.ContextMenu_EditFcn = uimenu(app.ContextMenu);
            app.ContextMenu_EditFcn.MenuSelectedFcn = createCallbackFcn(app, @Toolbar_EditSelectedImageClicked, true);
            app.ContextMenu_EditFcn.Enable = 'off';
            app.ContextMenu_EditFcn.Text = '✏️ Editar';

            % Create ContextMenu_DeleteFcn
            app.ContextMenu_DeleteFcn = uimenu(app.ContextMenu);
            app.ContextMenu_DeleteFcn.MenuSelectedFcn = createCallbackFcn(app, @ContextMenu_Delete, true);
            app.ContextMenu_DeleteFcn.Enable = 'off';
            app.ContextMenu_DeleteFcn.Text = '❌ Excluir';
            
            % Assign app.ContextMenu
            app.UITable.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winProducts_exported(Container, varargin)

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
