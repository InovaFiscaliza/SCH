classdef winProducts_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        DockModule                matlab.ui.container.GridLayout
        dockModule_Undock         matlab.ui.control.Image
        dockModule_Close          matlab.ui.control.Image
        Document                  matlab.ui.container.GridLayout
        report_Table              matlab.ui.control.Table
        report_nRows              matlab.ui.control.Label
        report_ViewType           matlab.ui.container.ButtonGroup
        ADUANAButton              matlab.ui.control.RadioButton
        FORNECEDORUSURIOButton    matlab.ui.control.RadioButton
        SubTabGroup               matlab.ui.container.TabGroup
        SubTab1                   matlab.ui.container.Tab
        SubGrid1                  matlab.ui.container.GridLayout
        report_ProductInfo        matlab.ui.control.Label
        report_ProductInfoImage   matlab.ui.control.Image
        report_ProductInfoLabel   matlab.ui.control.Label
        SubTab2                   matlab.ui.container.Tab
        SubGrid2                  matlab.ui.container.GridLayout
        report_EntityPanel        matlab.ui.container.Panel
        report_EntityGrid         matlab.ui.container.GridLayout
        report_Entity             matlab.ui.control.EditField
        report_EntityLabel        matlab.ui.control.Label
        report_EntityID           matlab.ui.control.EditField
        report_EntityCheck        matlab.ui.control.Image
        report_EntityIDLabel      matlab.ui.control.Label
        report_EntityType         matlab.ui.control.DropDown
        report_EntityTypeLabel    matlab.ui.control.Label
        report_EntityPanelLabel   matlab.ui.control.Label
        report_ProjectName        matlab.ui.control.TextArea
        report_ProjectSave        matlab.ui.control.Image
        report_ProjectOpen        matlab.ui.control.Image
        report_ProjectNew         matlab.ui.control.Image
        report_ProjectLabel       matlab.ui.control.Label
        reportPanel               matlab.ui.container.Panel
        reportGrid                matlab.ui.container.GridLayout
        reportVersion             matlab.ui.control.DropDown
        reportVersionLabel        matlab.ui.control.Label
        report_ModelName          matlab.ui.control.DropDown
        reportModelNameLabel      matlab.ui.control.Label
        reportLabel               matlab.ui.control.Label
        eFiscalizaPanel           matlab.ui.container.Panel
        eFiscalizaGrid            matlab.ui.container.GridLayout
        reportIssue               matlab.ui.control.NumericEditField
        reportIssueLabel          matlab.ui.control.Label
        reportUnit                matlab.ui.control.DropDown
        reportUnitLabel           matlab.ui.control.Label
        reportSystem              matlab.ui.control.DropDown
        reportSystemLabel         matlab.ui.control.Label
        eFiscalizaLabel           matlab.ui.control.Label
        Toolbar                   matlab.ui.container.GridLayout
        tool_Separator            matlab.ui.control.Image
        report_FiscalizaUpdate    matlab.ui.control.Image
        report_ReportGeneration   matlab.ui.control.Image
        tool_EditSelectedProduct  matlab.ui.control.Image
        tool_AddNonCertificate    matlab.ui.control.Image
        tool_PanelVisibility      matlab.ui.control.Image
        ContextMenu               matlab.ui.container.ContextMenu
        ContextMenu_EditFcn       matlab.ui.container.Menu
        ContextMenu_DeleteFcn     matlab.ui.container.Menu
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
        projectData
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                report_uploadInfoController(app.mainApp, event.HTMLEventData, 'uploadDocument')

                            otherwise
                                error('UnexpectedEvent')
                        end

                    otherwise
                        error('UnexpectedEvent')
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
                            % winSCH >> auxApp.winProducts
                            case 'updateInspectedProducts'
                                report_UpdatingTable(app)
                                report_TableSelectionChanged(app)
                                report_ProjectWarnImageVisibility(app)

                            % auxApp.docProductInfo >> winSCH >> auxApp.winProducts
                            case 'closeFcnCallFromDockModule'
                                app.popupContainer.Parent.Visible = 0;

                            % auxApp.docProductInfo >> winSCH >> auxApp.winProducts
                            case 'TableCellEdit'
                                selectedRow = varargin{1};

                                report_UpdatingTable(app)
                                if isequal(selectedRow, app.report_ProductInfo.UserData.selectedRow)
                                    app.report_ProductInfo.UserData.selectedRow = [];
                                    report_TableSelectionChanged(app)
                                end
                                report_ProjectWarnImageVisibility(app)

                            % auxApp.docProductInfo >> winSCH >> auxApp.winProducts
                            case 'TableSelectionChanged'
                                selectedRow = varargin{1};

                                app.report_Table.Selection = selectedRow;
                                report_TableSelectionChanged(app)

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
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = zeros(1, numel(app.SubTabGroup.Children), 'logical');
            end

            if customizationStatus(tabIndex)
                return
            end
    
            customizationStatus(tabIndex) = true;
            switch tabIndex
                case 1
                    appName = class(app);
                    elToModify = { ...
                        app.report_ProductInfo, ...
                        app.report_ProductInfoImage ...
                    };
                    elDataTag = ui.CustomizationBase.getElementsDataTag(elToModify);
                    if ~isempty(elDataTag)
                        ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
                        ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName, 'SELECIONE UM REGISTRO<br>NA TABELA');
                    end
    
                case 2
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % Os painéis de metadados do registro selecionado nas tabelas já 
            % tem, na sua propriedade "UserData", a chave "id" que armazena 
            % o "data-tag" que identifica o componente no código HTML. 
            % Adicionam-se duas novas chaves: "showedRow" e "showedHom".
            app.report_ProductInfo.UserData.selectedRow = [];
            app.report_ProductInfo.UserData.showedHom   = '';
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.report_Table.RowName = 'numbered';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            report_UpdatingTable(app)
            report_TableSelectionChanged(app)
            report_ProjectWarnImageVisibility(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % ESPECIFICIDADES AUXAPP.WINPRODUCTS
        %-----------------------------------------------------------------%
        function relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom)
            annotationLogical      = strcmp(app.mainApp.annotationTable.("Homologação"), showedHom);
            relatedAnnotationTable = app.mainApp.annotationTable(annotationLogical, :);
        end

        %-----------------------------------------------------------------%
        function [listOfRows, idx, analyzedColumns] = report_ListOfProductsCheck(app)
            % É nessa função que são feitas as validações nos valores das 
            % células da tabela. Se algum valor não passar numa validação,
            % então não poderá ser gerada a versão definitiva do relatório
            % e a célula ficará destacada em vermelho.

            analyzedColumns = {                                                                                 ...
                'Tipo',                                                                                         ... #1
                'Fabricante',                                                                                   ... #2
                'Modelo',                                                                                       ... #3
                'Valor Unit. (R$)',                                                                             ... #4
                {'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada'},                          ... #5
                {'Qtd. uso', 'Qtd. estoque/aduana', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}, ... #6
                'Situação',                                                                                     ... #7
                {'Situação', 'Infração'}                                                                        ... #8
                {'Situação', 'Valor Unit. (R$)'},                                                               ... #9
                {'Situação', 'Fonte do valor'},                                                                 ... #10
                {'Situação', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'},                        ... #11
            };

            idx      = zeros(height(app.projectData.inspectedProducts), 11, 'logical');

            idx(:, 1) = string(app.projectData.inspectedProducts.("Tipo")) == "-";
            idx(:, 2) = string(app.projectData.inspectedProducts.("Fabricante")) == "";
            idx(:, 3) = string(app.projectData.inspectedProducts.("Modelo")) == "";
            idx(:, 4) = app.projectData.inspectedProducts.("Valor Unit. (R$)") < 0;
            idx(:, 5) = app.projectData.inspectedProducts.("Qtd. uso")            + ...
                        app.projectData.inspectedProducts.("Qtd. vendida")        + ...
                        app.projectData.inspectedProducts.("Qtd. estoque/aduana") + ...
                        app.projectData.inspectedProducts.("Qtd. anunciada") <= 0;
            idx(:, 6) = sum(app.projectData.inspectedProducts{:, {'Qtd. uso', 'Qtd. estoque/aduana'}}, 2) < ...
                        sum(app.projectData.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2);            
            idx(:, 7) =   string(app.projectData.inspectedProducts.("Situação")) == "-";
            idx(:, 8) = ((string(app.projectData.inspectedProducts.("Situação")) == "Regular")   & (string(app.projectData.inspectedProducts.("Infração")) ~= "-")) | ...
                        ((string(app.projectData.inspectedProducts.("Situação")) == "Irregular") & (string(app.projectData.inspectedProducts.("Infração")) == "-"));
            idx(:, 9) =  (string(app.projectData.inspectedProducts.("Situação")) == "Irregular") & (app.projectData.inspectedProducts.("Valor Unit. (R$)") <= 0);
            idx(:,10) =  (string(app.projectData.inspectedProducts.("Situação")) == "Irregular") & (string(app.projectData.inspectedProducts.("Fonte do valor")) == "");
            idx(:,11) =  (string(app.projectData.inspectedProducts.("Situação")) == "Regular")   & (sum(app.projectData.inspectedProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2) > 0);

            listOfRows = find(any(idx, 2));
        end

        %-----------------------------------------------------------------%
        function report_UpdatingTable(app)
            report_syncTableAndGui(app, 'dataToGuiSync')

            % LAYOUT
            misc_Table_NumberOfRows(app)

            if ~isempty(app.projectData.inspectedProducts)
                report_Table_AddStyle(app, 'Icon+BackgroundColor')
            else
                removeStyle(app.report_Table)
            end

            report_ModelNameValueChanged(app)
        end

        %-----------------------------------------------------------------%
        function report_syncTableAndGui(app, syncType)
            arguments
                app
                syncType char {mustBeMember(syncType, {'guiToDataSync', 'dataToGuiSync', 'tableViewChanged'})}
            end

            viewType    = app.report_ViewType.SelectedObject.Tag; % 'vendorView' | 'customsView'
            columnList  = app.mainApp.General.ui.reportTable.(viewType).name';
            columnIndex = cellfun(@(x) find(strcmp(app.projectData.inspectedProducts.Properties.VariableNames, x), 1), columnList);

            switch syncType
                case 'guiToDataSync'
                    updateInspectedProducts(app.projectData, 'edit', 1:height(app.projectData.inspectedProducts), columnIndex, app.report_Table.Data)

                case 'dataToGuiSync'
                    app.report_Table.Data = app.projectData.inspectedProducts(:, columnIndex);

                case 'tableViewChanged'
                    set(app.report_Table, 'Data',        app.projectData.inspectedProducts(:, columnIndex), ...
                                          'ColumnName',  app.mainApp.General.ui.reportTable.(viewType).label',   ...
                                          'ColumnWidth', app.mainApp.General.ui.reportTable.(viewType).columnWidth')

                    report_Table_AddStyle(app, 'Icon+BackgroundColor')
            end
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle(app, styleType)
            [listOfRows, idx, analyzedColumns] = report_ListOfProductsCheck(app);

            switch styleType
                case 'Icon'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                    end

                case 'BackgroundColor'
                    % O evento aqui é iniciado apenas do botão na barra de tarefas...
                    report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, false)

                case 'Icon+BackgroundColor'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                        report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, false)
                    end

                case 'Icon+TemporaryBackgroundColor'
                    removeStyle(app.report_Table)
                    if ~isempty(listOfRows)
                        report_Table_AddStyle_Icon(app, listOfRows)
                        report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, true)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle_Icon(app, listOfRows)
            s = class.Constants.configStyle6;
            addStyle(app.report_Table, s, "cell", [listOfRows, ones(numel(listOfRows), 1)])
        end

        %-----------------------------------------------------------------%
        function report_Table_AddStyle_BackgroundColor(app, idx, analyzedColumns, temporaryFlag)
            % Identifica o número de estilos aplicados à tabela...
            styleIndex = height(app.report_Table.StyleConfigurations);

            % Identifica as células...
            cellList = [];
            for ii = 1:numel(analyzedColumns)
                rowIndex = find(idx(:,ii));

                if ~isempty(rowIndex)
                    columnNames = analyzedColumns{ii};
                    columnIndex = find(ismember(app.report_Table.Data.Properties.VariableNames, columnNames));

                    for jj = 1:numel(columnIndex)
                        cellList = [cellList; [rowIndex, repmat(columnIndex(jj), numel(rowIndex), 1)]];
                    end
                end
            end

            % Aplica o estilo, o qual terá o index "styleIndex+1", e depois
            % de cerca de 300ms o estilo é excluído (caso temporaryFlag = true).
            s = class.Constants.configStyle7;
            addStyle(app.report_Table, s, "cell", cellList)

            if temporaryFlag
                drawnow
                pause(.3)

                % O bloco try/catch evita retorno de erro, caso o usuário
                % interaja com a tabela durante o pause de 300 ms.
                try
                    removeStyle(app.report_Table, styleIndex+1)
                catch
                end
            end
        end

        %-----------------------------------------------------------------%
        function [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app)
            selectedRow = app.report_Table.Selection;
            if ~isempty(selectedRow)
                selectedHom = unique(app.report_Table.Data.("Homologação")(selectedRow), 'stable');
            else
                selectedHom = {};
            end
            showedHom = app.report_ProductInfo.UserData.showedHom;
        end

        %-----------------------------------------------------------------%
        function misc_Table_NumberOfRows(app)
            nRows = height(app.report_Table.Data);
            app.report_nRows.Text = sprintf('%d <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>', nRows);
        end

        %-----------------------------------------------------------------%
        function htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable)
            if isempty(selected2showedHom)
                htmlSource = '';

            else
                if ~strcmp(selected2showedHom, '-')
                    selectedHomRawTableIndex = find(strcmp(app.mainApp.rawDataTable.("Homologação"), selected2showedHom));
                    htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoHomologado', app.mainApp.rawDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable, app.projectData.regulatronData);

                else
                    % Esse é um caso específico do modo "REPORT", quando é
                    % selecionado registro de um produto não homologado,
                    % cuja homologação é preenchido como "-". Nesse caso,
                    % deve-se identificar a linha selecionada da tabela (do
                    % modo "REPORT) pois podem existir mais de um registro
                    % com o número igual a "-".
                    %
                    % O bloco try/catch é apenas por precaução. Não foi
                    % evidenciado erro nos testes de uso do app.

                    try
                        selectedRow = app.report_Table.Selection(1);
                        htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoNãoHomologado', app.projectData.inspectedProducts(selectedRow, :));
                    catch
                        htmlSource = '';
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow, selected2showedHom)
            userData = struct('selectedRow', selectedRow, 'showedHom', selected2showedHom);
            ui.TextView.update(app.report_ProductInfo, htmlSource, userData, app.report_ProductInfoImage);
        end

        %-----------------------------------------------------------------%
        function layout_CNPJOrCPF(app, status)
            if status
                backgroundColor = [1,1,1];
                fontColor       = [0,0,0];
            else
                backgroundColor = [1,0,0];
                fontColor       = [1,1,1];
            end
            set(app.report_EntityID, 'BackgroundColor', backgroundColor, 'FontColor', fontColor)
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

        % Image clicked function: tool_PanelVisibility
        function Toolbar_InteractionImageClicked(app, event)
            
            switch event.Source
                case app.tool_PanelVisibility
                    if app.SubTabGroup.Visible
                        app.tool_PanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.SubTabGroup.Visible = 0;
                        app.Document.Layout.Column = [2 5];
                    else
                        app.tool_PanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.SubTabGroup.Visible = 1;
                        app.Document.Layout.Column = [4 5];
                    end

                case app.tool_TableVisibility
                    app.tool_TableVisibility.UserData = mod(app.tool_TableVisibility.UserData+1, 3);

                    switch app.tool_TableVisibility.UserData
                        case 0
                            app.UITable.Visible = 0;
                            app.Document.RowHeight = {24,'1x', 0, 0};
                        case 1
                            app.UITable.Visible = 1;
                            app.Document.RowHeight = {24, '1x', 10, 186};
                        case 2
                            app.UITable.Visible = 1;
                            app.Document.RowHeight = {0, 0, 0, '1x'};
                    end

                case app.tool_peakIcon
                    if ~isempty(app.tool_peakIcon.UserData)
                        ReferenceDistance_km = 1;
                        plot.zoom(app.UIAxes, app.tool_peakIcon.UserData.Latitude, app.tool_peakIcon.UserData.Longitude, ReferenceDistance_km)
                        plot.datatip.Create(app.UIAxes, 'Measures', app.tool_peakIcon.UserData.idxMax)
                    end
            end

        end

        % Image clicked function: report_ReportGeneration
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

        % Image clicked function: report_FiscalizaUpdate
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

        % Selection change function: SubTabGroup
        function SubTabGroupSelectionChanged(app, event)

            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Value changed function: report_ModelName
        function report_ModelNameValueChanged(app, event)
            
            if ~isempty(app.projectData.inspectedProducts) && ~isempty(app.report_ModelName.Value)
                app.report_ReportGeneration.Enable = 1;
            else
                app.report_ReportGeneration.Enable = 0;
            end

        end

        % Value changed function: reportIssue, reportSystem, reportUnit
        function reportInfoValueChanged(app, event)
            
            context = 'ExternalRequest';

            switch event.Source
                case app.reportSystem
                    updateUiInfo(app.projectData, context, 'system', app.reportSystem.Value)
                case app.reportUnit
                    updateUiInfo(app.projectData, context, 'unit',   app.reportUnit.Value)
                case app.reportIssue
                    updateUiInfo(app.projectData, context, 'issue',  app.reportIssue.Value)
            end

        end

        % Selection changed function: report_ViewType
        function report_ViewTypeSelectionChanged(app, event)
            
            report_syncTableAndGui(app, 'tableViewChanged')
            
        end

        % Image clicked function: tool_AddNonCertificate
        function tool_AddNonCertificateImageClicked(app, event)
            
            [productData, productHash] = model.projectLib.initializeInspectedProduct('NãoHomologado', app.mainApp.General);
            if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                ui.Dialog(app.UIFigure, 'warning', model.projectLib.WARNING_ENTRYEXIST.PRODUCTS);
                return
            end

            updateInspectedProducts(app.projectData, 'add', productData)

            % Atualizando a tabela e o número de linhas (do modo REPORT), nessa
            % ordem. E depois forçando uma atualização dos paineis.
            report_UpdatingTable(app)
            report_TableSelectionChanged(app)

            % Torna visível imagem de warning, caso aberto projeto.
            report_ProjectWarnImageVisibility(app)

        end

        % Callback function: ContextMenu_EditFcn, tool_EditSelectedProduct
        function search_FilterSetupClicked(app, event)
            
            % Por alguma razão desconhecida, inseri algumas validações
            % aqui! :)
            % Enfim... a possibilidade de editar um registro não deve
            % existir toda vez que a tabela esteja vazia ou que não
            % esteja selecionada uma linha.
            selectedRow = app.report_Table.Selection;

            if isempty(selectedRow)
                if isempty(app.report_Table.Data)
                    app.tool_EditSelectedProduct.Enable  = 0;
                    app.ContextMenu_EditFcn.Enable = 0;
                    return
                end

                app.report_Table.Selection = 1;
                report_TableSelectionChanged(app)
            elseif ~isscalar(selectedRow)
                app.report_Table.Selection = app.report_Table.Selection(1);
            end

            ipcMainMatlabOpenPopupApp(app.mainApp, app, 'ProductInfo')

        end

        % Menu selected function: ContextMenu_DeleteFcn
        function report_ContextMenu_DeleteFcnSelected(app, event)
            
            selectedTableIndex = app.report_Table.Selection;

            if ~isempty(selectedTableIndex)
                updateInspectedProducts(app.projectData, 'delete', selectedTableIndex)

                report_UpdatingTable(app)
                report_ProjectWarnImageVisibility(app)
            end

            report_TableSelectionChanged(app)

        end

        % Selection changed function: report_Table
        function report_TableSelectionChanged(app, event)
            
            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app);

            if ~isempty(selectedHom)
                updateFlag = false;
                if ~ismember(showedHom, selectedHom) || ~isequal(selectedRow, app.report_ProductInfo.UserData.selectedRow)
                    updateFlag = true;
                end

                if updateFlag
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow(1), selected2showedHom)
                end

                app.tool_EditSelectedProduct.Enable = 1;
                app.ContextMenu_EditFcn.Enable      = 1;
                app.ContextMenu_DeleteFcn.Enable    = 1;

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, htmlSource, [], '')

                app.tool_EditSelectedProduct.Enable = 0;
                app.ContextMenu_EditFcn.Enable      = 0;
                app.ContextMenu_DeleteFcn.Enable    = 0;
            end
            
        end

        % Cell edit callback: report_Table
        function report_TableCellEdit(app, event)
            
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

                    app.report_Table.Data.(editedRealColumn) = app.projectData.inspectedProducts.(editedRealColumn);
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

            report_syncTableAndGui(app, 'guiToDataSync')
            report_Table_AddStyle(app, 'Icon+BackgroundColor')

            report_ProjectWarnImageVisibility(app)

            % Atualizando o painel de metadados do registro selecionado...
            % (só pode ser editada uma célular por vez)
            [~, showedHom, selectedRow] = misc_Table_SelectedRow(app);
            if strcmp(showedHom, '-')
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, []);
                misc_SelectedHomPanel_InfoUpdate(app, htmlSource, selectedRow, showedHom)
            end
            
        end

        % Image clicked function: report_ProjectNew, report_ProjectOpen, 
        % ...and 1 other component
        function report_ProjectToolbarImageClicked(app, event)
            
        end

        % Value changed function: report_EntityType
        function report_EntityTypeValueChanged(app, event)
            
            switch app.report_EntityType.Value
                case {'Fornecedor', 'Usuário'}
                    app.report_Entity.Enable      = 1;
                    app.report_EntityID.Enable    = 1;
                    app.report_EntityCheck.Enable = 1;

                otherwise
                    app.report_Entity.Enable      = 0;
                    app.report_EntityID.Enable    = 0;
                    app.report_EntityCheck.Enable = 0;
            end

            report_ProjectWarnImageVisibility(app)
            
        end

        % Value changed function: report_EntityID
        function report_EntityIDValueChanged(app, event)
            
            try
                CNPJOrCPF = checkCNPJOrCPF(app.report_EntityID.Value, 'NumberValidation');
                set(app.report_EntityID, 'Value', CNPJOrCPF, 'UserData', CNPJOrCPF)
                layout_CNPJOrCPF(app, true)

            catch ME
                app.report_EntityID.UserData = [];
                layout_CNPJOrCPF(app, false)

            end

            report_ProjectWarnImageVisibility(app)
            
        end

        % Image clicked function: report_EntityCheck
        function report_EntityIDCheck(app, event)
            
            entityID = regexprep(app.report_EntityID.Value, '\D', '');
            if isempty(entityID)
                ui.Dialog(app.UIFigure, 'info', 'Consulta limitada a valores não nulos de CNPJ ou CPF');
                return
            end

            try
                % Pesquisa restrita ao CNPJ.
                CNPJInfo = checkCNPJOrCPF(app.report_EntityID.Value, 'PublicAPI');
                ui.Dialog(app.UIFigure, 'info', jsonencode(CNPJInfo, "PrettyPrint", true));

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

        end

        % Value changed function: report_Entity
        function report_ProjectWarnImageVisibility(app, event)
            
            if ~isempty(app.report_ProjectName.Value{1})
                app.report_ProjectWarnIcon.Visible = 1;
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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, '1x', 22, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [5 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];

            % Create tool_PanelVisibility
            app.tool_PanelVisibility = uiimage(app.Toolbar);
            app.tool_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @Toolbar_InteractionImageClicked, true);
            app.tool_PanelVisibility.Layout.Row = 2;
            app.tool_PanelVisibility.Layout.Column = 1;
            app.tool_PanelVisibility.ImageSource = 'ArrowLeft_32.png';

            % Create tool_AddNonCertificate
            app.tool_AddNonCertificate = uiimage(app.Toolbar);
            app.tool_AddNonCertificate.ImageClickedFcn = createCallbackFcn(app, @tool_AddNonCertificateImageClicked, true);
            app.tool_AddNonCertificate.Tooltip = {'Adiciona produto NÃO homologado à lista'};
            app.tool_AddNonCertificate.Layout.Row = [1 3];
            app.tool_AddNonCertificate.Layout.Column = 4;
            app.tool_AddNonCertificate.ImageSource = 'AddForbidden_32.png';

            % Create tool_EditSelectedProduct
            app.tool_EditSelectedProduct = uiimage(app.Toolbar);
            app.tool_EditSelectedProduct.ScaleMethod = 'none';
            app.tool_EditSelectedProduct.ImageClickedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.tool_EditSelectedProduct.Enable = 'off';
            app.tool_EditSelectedProduct.Tooltip = {'Edita lista de produtos sob análise'};
            app.tool_EditSelectedProduct.Layout.Row = [2 3];
            app.tool_EditSelectedProduct.Layout.Column = 2;
            app.tool_EditSelectedProduct.ImageSource = 'Variable_edit_16.png';

            % Create report_ReportGeneration
            app.report_ReportGeneration = uiimage(app.Toolbar);
            app.report_ReportGeneration.ScaleMethod = 'none';
            app.report_ReportGeneration.ImageClickedFcn = createCallbackFcn(app, @Toolbar_GenerateReportImageClicked, true);
            app.report_ReportGeneration.Enable = 'off';
            app.report_ReportGeneration.Tooltip = {'Gera relatório'};
            app.report_ReportGeneration.Layout.Row = [1 3];
            app.report_ReportGeneration.Layout.Column = 6;
            app.report_ReportGeneration.ImageSource = 'Publish_HTML_16.png';

            % Create report_FiscalizaUpdate
            app.report_FiscalizaUpdate = uiimage(app.Toolbar);
            app.report_FiscalizaUpdate.ImageClickedFcn = createCallbackFcn(app, @Toolbar_UploadFinalFileImageClicked, true);
            app.report_FiscalizaUpdate.Enable = 'off';
            app.report_FiscalizaUpdate.Tooltip = {'Upload relatório'};
            app.report_FiscalizaUpdate.Layout.Row = 2;
            app.report_FiscalizaUpdate.Layout.Column = 7;
            app.report_FiscalizaUpdate.ImageSource = 'Up_24.png';

            % Create tool_Separator
            app.tool_Separator = uiimage(app.Toolbar);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = [1 3];
            app.tool_Separator.Layout.Column = 3;
            app.tool_Separator.ImageSource = 'LineV.svg';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @SubTabGroupSelectionChanged, true);
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = 2;

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

            % Create eFiscalizaLabel
            app.eFiscalizaLabel = uilabel(app.SubGrid2);
            app.eFiscalizaLabel.VerticalAlignment = 'bottom';
            app.eFiscalizaLabel.FontSize = 10;
            app.eFiscalizaLabel.Layout.Row = 5;
            app.eFiscalizaLabel.Layout.Column = 1;
            app.eFiscalizaLabel.Text = 'eFISCALIZA';

            % Create eFiscalizaPanel
            app.eFiscalizaPanel = uipanel(app.SubGrid2);
            app.eFiscalizaPanel.AutoResizeChildren = 'off';
            app.eFiscalizaPanel.Layout.Row = 6;
            app.eFiscalizaPanel.Layout.Column = [1 4];

            % Create eFiscalizaGrid
            app.eFiscalizaGrid = uigridlayout(app.eFiscalizaPanel);
            app.eFiscalizaGrid.ColumnWidth = {'1x', 150};
            app.eFiscalizaGrid.RowHeight = {22, 22, 22, '1x'};
            app.eFiscalizaGrid.RowSpacing = 5;
            app.eFiscalizaGrid.BackgroundColor = [1 1 1];

            % Create reportSystemLabel
            app.reportSystemLabel = uilabel(app.eFiscalizaGrid);
            app.reportSystemLabel.FontSize = 11;
            app.reportSystemLabel.Layout.Row = 1;
            app.reportSystemLabel.Layout.Column = 1;
            app.reportSystemLabel.Text = 'Sistema:';

            % Create reportSystem
            app.reportSystem = uidropdown(app.eFiscalizaGrid);
            app.reportSystem.Items = {'eFiscaliza', 'eFiscaliza TS'};
            app.reportSystem.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportSystem.FontSize = 11;
            app.reportSystem.BackgroundColor = [1 1 1];
            app.reportSystem.Layout.Row = 1;
            app.reportSystem.Layout.Column = 2;
            app.reportSystem.Value = 'eFiscaliza';

            % Create reportUnitLabel
            app.reportUnitLabel = uilabel(app.eFiscalizaGrid);
            app.reportUnitLabel.FontSize = 11;
            app.reportUnitLabel.Layout.Row = 2;
            app.reportUnitLabel.Layout.Column = 1;
            app.reportUnitLabel.Text = 'Unidade responsável:';

            % Create reportUnit
            app.reportUnit = uidropdown(app.eFiscalizaGrid);
            app.reportUnit.Items = {};
            app.reportUnit.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportUnit.FontSize = 11;
            app.reportUnit.BackgroundColor = [1 1 1];
            app.reportUnit.Layout.Row = 2;
            app.reportUnit.Layout.Column = 2;
            app.reportUnit.Value = {};

            % Create reportIssueLabel
            app.reportIssueLabel = uilabel(app.eFiscalizaGrid);
            app.reportIssueLabel.FontSize = 11;
            app.reportIssueLabel.Layout.Row = [3 4];
            app.reportIssueLabel.Layout.Column = 1;
            app.reportIssueLabel.Text = {'Atividade de inspeção:'; '(# ID)'};

            % Create reportIssue
            app.reportIssue = uieditfield(app.eFiscalizaGrid, 'numeric');
            app.reportIssue.Limits = [-1 Inf];
            app.reportIssue.RoundFractionalValues = 'on';
            app.reportIssue.ValueDisplayFormat = '%d';
            app.reportIssue.ValueChangedFcn = createCallbackFcn(app, @reportInfoValueChanged, true);
            app.reportIssue.FontSize = 11;
            app.reportIssue.FontColor = [0.149 0.149 0.149];
            app.reportIssue.Layout.Row = 3;
            app.reportIssue.Layout.Column = 2;
            app.reportIssue.Value = -1;

            % Create reportLabel
            app.reportLabel = uilabel(app.SubGrid2);
            app.reportLabel.VerticalAlignment = 'bottom';
            app.reportLabel.FontSize = 10;
            app.reportLabel.Layout.Row = 7;
            app.reportLabel.Layout.Column = 1;
            app.reportLabel.Text = 'RELATÓRIO';

            % Create reportPanel
            app.reportPanel = uipanel(app.SubGrid2);
            app.reportPanel.AutoResizeChildren = 'off';
            app.reportPanel.BackgroundColor = [1 1 1];
            app.reportPanel.Layout.Row = 8;
            app.reportPanel.Layout.Column = [1 4];

            % Create reportGrid
            app.reportGrid = uigridlayout(app.reportPanel);
            app.reportGrid.ColumnWidth = {'1x', 150};
            app.reportGrid.RowHeight = {22, 22};
            app.reportGrid.RowSpacing = 5;
            app.reportGrid.BackgroundColor = [1 1 1];

            % Create reportModelNameLabel
            app.reportModelNameLabel = uilabel(app.reportGrid);
            app.reportModelNameLabel.FontSize = 11;
            app.reportModelNameLabel.Layout.Row = 1;
            app.reportModelNameLabel.Layout.Column = 1;
            app.reportModelNameLabel.Text = 'Modelo (.json):';

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.reportGrid);
            app.report_ModelName.Items = {''};
            app.report_ModelName.ValueChangedFcn = createCallbackFcn(app, @report_ModelNameValueChanged, true);
            app.report_ModelName.FontSize = 11;
            app.report_ModelName.BackgroundColor = [1 1 1];
            app.report_ModelName.Layout.Row = 1;
            app.report_ModelName.Layout.Column = 2;
            app.report_ModelName.Value = '';

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
            app.reportVersion.FontSize = 11;
            app.reportVersion.BackgroundColor = [1 1 1];
            app.reportVersion.Layout.Row = 2;
            app.reportVersion.Layout.Column = 2;
            app.reportVersion.Value = 'Preliminar';

            % Create report_ProjectLabel
            app.report_ProjectLabel = uilabel(app.SubGrid2);
            app.report_ProjectLabel.VerticalAlignment = 'bottom';
            app.report_ProjectLabel.FontSize = 10;
            app.report_ProjectLabel.Layout.Row = 1;
            app.report_ProjectLabel.Layout.Column = 1;
            app.report_ProjectLabel.Text = 'ARQUIVO';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.SubGrid2);
            app.report_ProjectNew.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 2;
            app.report_ProjectNew.VerticalAlignment = 'bottom';
            app.report_ProjectNew.ImageSource = 'AddFiles_36.png';

            % Create report_ProjectOpen
            app.report_ProjectOpen = uiimage(app.SubGrid2);
            app.report_ProjectOpen.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectOpen.Tooltip = {'Abre projeto'};
            app.report_ProjectOpen.Layout.Row = 1;
            app.report_ProjectOpen.Layout.Column = 3;
            app.report_ProjectOpen.VerticalAlignment = 'bottom';
            app.report_ProjectOpen.ImageSource = 'OpenFile_36x36.png';

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.SubGrid2);
            app.report_ProjectSave.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
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
            app.report_EntityType.ValueChangedFcn = createCallbackFcn(app, @report_EntityTypeValueChanged, true);
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
            app.report_EntityCheck.ImageClickedFcn = createCallbackFcn(app, @report_EntityIDCheck, true);
            app.report_EntityCheck.Enable = 'off';
            app.report_EntityCheck.Layout.Row = 1;
            app.report_EntityCheck.Layout.Column = 3;
            app.report_EntityCheck.VerticalAlignment = 'bottom';
            app.report_EntityCheck.ImageSource = 'Info_36.png';

            % Create report_EntityID
            app.report_EntityID = uieditfield(app.report_EntityGrid, 'text');
            app.report_EntityID.ValueChangedFcn = createCallbackFcn(app, @report_EntityIDValueChanged, true);
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
            app.report_Entity.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_Entity.FontSize = 11;
            app.report_Entity.Enable = 'off';
            app.report_Entity.Layout.Row = 4;
            app.report_Entity.Layout.Column = [1 3];

            % Create Document
            app.Document = uigridlayout(app.GridLayout);
            app.Document.ColumnWidth = {'1x', 100, 16, 16};
            app.Document.RowHeight = {4, 22, 17, '1x'};
            app.Document.ColumnSpacing = 2;
            app.Document.RowSpacing = 5;
            app.Document.Padding = [0 0 0 0];
            app.Document.Layout.Row = [3 4];
            app.Document.Layout.Column = [4 5];
            app.Document.BackgroundColor = [1 1 1];

            % Create report_ViewType
            app.report_ViewType = uibuttongroup(app.Document);
            app.report_ViewType.AutoResizeChildren = 'off';
            app.report_ViewType.SelectionChangedFcn = createCallbackFcn(app, @report_ViewTypeSelectionChanged, true);
            app.report_ViewType.BorderType = 'none';
            app.report_ViewType.Title = 'LISTA DE PRODUTOS SOB ANÁLISE';
            app.report_ViewType.BackgroundColor = [1 1 1];
            app.report_ViewType.Layout.Row = [2 3];
            app.report_ViewType.Layout.Column = [1 4];
            app.report_ViewType.FontSize = 10;

            % Create FORNECEDORUSURIOButton
            app.FORNECEDORUSURIOButton = uiradiobutton(app.report_ViewType);
            app.FORNECEDORUSURIOButton.Tag = 'vendorView';
            app.FORNECEDORUSURIOButton.Text = 'FORNECEDOR/USUÁRIO';
            app.FORNECEDORUSURIOButton.FontSize = 10;
            app.FORNECEDORUSURIOButton.Position = [2 1 148 23];
            app.FORNECEDORUSURIOButton.Value = true;

            % Create ADUANAButton
            app.ADUANAButton = uiradiobutton(app.report_ViewType);
            app.ADUANAButton.Tag = 'customsView';
            app.ADUANAButton.Text = 'ADUANA';
            app.ADUANAButton.FontSize = 10;
            app.ADUANAButton.Position = [156 1 180 22];

            % Create report_nRows
            app.report_nRows = uilabel(app.Document);
            app.report_nRows.HorizontalAlignment = 'right';
            app.report_nRows.VerticalAlignment = 'bottom';
            app.report_nRows.FontSize = 11;
            app.report_nRows.FontColor = [0.502 0.502 0.502];
            app.report_nRows.Layout.Row = 3;
            app.report_nRows.Layout.Column = [2 4];
            app.report_nRows.Interpreter = 'html';
            app.report_nRows.Text = '0 <font style="font-size: 9px; margin-right: 2px;">REGISTROS</font>';

            % Create report_Table
            app.report_Table = uitable(app.Document);
            app.report_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'FONTE|VALOR'; 'QTD.|VENDIDA'; 'QTD.|EM USO'; 'QTD.|ESTOQUE'; 'QTD.|ANUNCIADA'; 'QTD.|LACRADA'; 'QTD.|APREENDIDA'; 'QTD.|RETIDA (RFB)'; 'SITUAÇÃO'; 'INFRAÇÃO'};
            app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 42, 96, 90, 'auto', 90, 90, 90, 90, 90, 90, 90, 'auto', 'auto'};
            app.report_Table.RowName = {};
            app.report_Table.SelectionType = 'row';
            app.report_Table.ColumnEditable = [false true true true true true true true true true true true true true true true true true];
            app.report_Table.CellEditCallback = createCallbackFcn(app, @report_TableCellEdit, true);
            app.report_Table.SelectionChangedFcn = createCallbackFcn(app, @report_TableSelectionChanged, true);
            app.report_Table.Layout.Row = 4;
            app.report_Table.Layout.Column = [1 4];
            app.report_Table.FontSize = 10;

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [5 6];
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
            app.ContextMenu_EditFcn.MenuSelectedFcn = createCallbackFcn(app, @search_FilterSetupClicked, true);
            app.ContextMenu_EditFcn.Enable = 'off';
            app.ContextMenu_EditFcn.Text = '✏️ Editar';

            % Create ContextMenu_DeleteFcn
            app.ContextMenu_DeleteFcn = uimenu(app.ContextMenu);
            app.ContextMenu_DeleteFcn.MenuSelectedFcn = createCallbackFcn(app, @report_ContextMenu_DeleteFcnSelected, true);
            app.ContextMenu_DeleteFcn.Enable = 'off';
            app.ContextMenu_DeleteFcn.Text = '❌ Excluir';
            
            % Assign app.ContextMenu
            app.report_Table.ContextMenu = app.ContextMenu;

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
