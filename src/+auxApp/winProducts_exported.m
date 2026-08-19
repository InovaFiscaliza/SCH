classdef winProducts_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModule                 matlab.ui.container.GridLayout
        dockModule_Close           matlab.ui.control.Image
        dockModule_Undock          matlab.ui.control.Image
        Toolbar                    matlab.ui.container.GridLayout
        ShowDataRules              matlab.ui.control.Image
        ToolbarSeparator           matlab.ui.control.Image
        UploadFinalFile            matlab.ui.control.Image
        GenerateReport             matlab.ui.control.Image
        OpenPopupProject           matlab.ui.control.Image
        AnalysisDetails            matlab.ui.control.Image
        AddNonCertificate          matlab.ui.control.Image
        FilterIconStatus           matlab.ui.control.Image
        NumRows                    matlab.ui.control.Label
        UITable                    matlab.ui.control.Table
        TableView                  matlab.ui.control.Hyperlink
        Title                      matlab.ui.control.Label
        ContextMenu                matlab.ui.container.ContextMenu
        AnalysisDetailsViaContext  matlab.ui.container.Menu
        TableRowDelete             matlab.ui.container.Menu
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'PRODUCTS'
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
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
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
        function ipcSecondaryMatlabCallsHandler(app, callingApp, eventName, varargin)
            try
                switch class(callingApp)
                    case {'winSCH', 'winSCH_exported'}
                        switch eventName                                
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

                            % winSCH >> auxApp.winProducts
                            % auxApp.dockReportLib >> winSCH >> auxApp.winProducts
                            case {'onReportGenerate', 'onFinalReportFileChanged'}
                                updateToolbar(app)

                            case 'onFetchIssueDetails'
                                system   = varargin{1};
                                issue    = varargin{2};
                                details  = varargin{3};
                                msgError = varargin{4};

                                if ~isempty(msgError)
                                    error(msgError)
                                end

                                msg = util.HtmlTextGenerator.issueDetails(system, issue, details);
                                ui.Dialog(app.UIFigure, 'info', msg);

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
                    appName = class(app);
                    elToModify = {
                        app.UITable;
                        app.AddNonCertificate;
                        app.AnalysisDetails;
                        app.OpenPopupProject;
                        app.GenerateReport;
                        app.UploadFinalFile;
                        app.ShowDataRules;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AddNonCertificate.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Adiciona produto NÃO homologado à lista')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisDetails.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Abre formulário para edição de lista de produtos inspecionados')), ...
                            struct('appName', appName, 'dataTag', app.OpenPopupProject.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Edita informações do projeto<br>(fiscalizada, arquivo de backup etc)')), ...
                            struct('appName', appName, 'dataTag', app.GenerateReport.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Gera relatório')), ...
                            struct('appName', appName, 'dataTag', app.UploadFinalFile.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Upload relatório')), ...
                            struct('appName', appName, 'dataTag', app.ShowDataRules.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Apresenta as regras de validação dos campos')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Undock.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.dockModule_Close.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.projectData = app.mainApp.projectData;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            app.UITable.UserData.viewType = struct( ...
                'valueData', 1, ...
                'options', {{'vendorView', 'customsView'}}, ...
                'labels', {{'FORNECEDOR-USUÁRIO 👁', 'ADUANA 👁'}} ...
            );

            % app.UITable.UserData.columnWidth = struct( ...
            %     'mode', 'initial', ...
            %     'value', struct( ...
            %         'vendorView',  {{120, 'auto', 'auto', 'auto', 'auto', 42, 42, 96, 90, 'auto', 66, 66, 66, 80, 70, 80, 80, 'auto', 'auto'}}, ...
            %         'customsView', {{120, 'auto', 'auto', 'auto', 'auto', 42, 'auto', 'auto', 90, 'auto', 66, 80, 'auto', 'auto', 70}} ...
            %     ) ...
            % );

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

            viewType = getViewType(app);
            columnList = app.mainApp.General.context.PRODUCTS.reportTable.(viewType).name';
            columnIndex = cellfun(@(x) find(strcmp(app.projectData.inspectedProducts.Properties.VariableNames, x), 1), columnList);

            switch syncType
                case 'guiToDataSync'
                    updateInspectedProducts(app.projectData, 'edit', 1:height(app.projectData.inspectedProducts), columnIndex, app.UITable.Data)

                case 'dataToGuiSync'
                    app.UITable.Data = app.projectData.inspectedProducts(:, columnIndex);

                case 'tableViewChanged'
                    set(app.UITable, 'Data',        app.projectData.inspectedProducts(:, columnIndex), ...
                                     'ColumnName',  app.mainApp.General.context.PRODUCTS.reportTable.(viewType).label', ...
                                     'ColumnWidth', app.mainApp.General.context.PRODUCTS.reportTable.(viewType).columnWidth')

                    % app.UITable.UserData.columnWidth.mode = 'initial';
                    % app.ColumnWidthMode.Text = 'INICIAL ↔';
            end

            updateTableStyle(app)
            updateRowStatusIndicators(app)
            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function viewType = getViewType(app)
            viewTypeIdx = app.UITable.UserData.viewType.valueData;
            viewType = app.UITable.UserData.viewType.options{viewTypeIdx};
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            removeStyle(app.UITable)

            if ~isempty(app.projectData.inspectedProducts)
                [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateInspectedProducts(app.projectData);

                if ~isempty(invalidRowIndexes)
                    applyRowStyle(invalidRowIndexes)
                    applyCellStyle(ruleViolationMatrix, ruleColumns)
                end
            end

            function applyRowStyle(invalidRowIndexes)
                s = app.warningIconStyle;
                addStyle(app.UITable, s, "cell", [invalidRowIndexes, ones(numel(invalidRowIndexes), 1)])
            end
    
            function applyCellStyle(ruleViolationMatrix, ruleColumns)
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
        end

        %-----------------------------------------------------------------%
        function updateRowStatusIndicators(app)
            numRows = height(app.UITable.Data);

            if numRows == 0
                numRowsText = '';
            elseif numRows == 1
                numRowsText = '1 LINHA';
            else
                numRowsText = sprintf('%d LINHAS', numRows);
            end

            app.NumRows.Text = numRowsText;
            app.FilterIconStatus.Visible = logical(numRows);
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            context = 'PRODUCTS';

            nonEmptyListOfProducts           = ~isempty(app.projectData.inspectedProducts);
            nonEmptyTableSelection           = ~isempty(app.UITable.Selection);            
            reportFinalVersionGenerated      = ~isempty(app.projectData.modules.(context).generatedFiles.lastHTMLDocFullPath);

            app.AnalysisDetails.Enable = nonEmptyListOfProducts;
            app.AnalysisDetailsViaContext.Enable   = nonEmptyListOfProducts;
            app.TableRowDelete.Enable = nonEmptyTableSelection;
            app.GenerateReport.Enable   = nonEmptyListOfProducts;
            app.UploadFinalFile.Enable  = reportFinalVersionGenerated;
        end

        %-----------------------------------------------------------------%
        function reportDispatchOperation(app, eventName)
            if isempty(app.mainApp.eFiscalizaObj) || ~isvalid(app.mainApp.eFiscalizaObj)
                dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', eventName, 'Fields', dialogBox, 'Context', app.Context))
            else
                ipcMainMatlabCallsHandler(app.mainApp, app, eventName, app.Context)
            end
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

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', "PRODUCTS")
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function onDockModuleGroupButtonClicked(app, event)
            
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

        % Callback function: not associated with a component
        function onTableColumnWidthModeChanged(app, event)
            
            % app.ColumnWidthMode.Enable = "off";
            % 
            % previousSelectedRow = app.UITable.Selection;
            % app.UITable.Selection = [];
            % 
            % switch app.UITable.UserData.columnWidth.mode
            %     case 'initial'
            %         app.UITable.UserData.columnWidth.mode = 'fix';
            %         app.UITable.ColumnWidth = '1x';
            %         app.ColumnWidthMode.Text = 'FIXO ↔';
            %     case 'fix'
            %         app.UITable.UserData.columnWidth.mode = 'auto';
            %         app.UITable.ColumnWidth = 'auto';
            %         app.ColumnWidthMode.Text = 'AUTO ↔';
            %     otherwise % 'auto'
            %         viewType = getViewType(app); % 'vendorView' | 'customsView'
            % 
            %         app.UITable.UserData.columnWidth.mode = 'initial';
            %         app.UITable.ColumnWidth = app.UITable.UserData.columnWidth.value.(viewType);
            %         app.ColumnWidthMode.Text = 'INICIAL ↔';
            % end
            % 
            % pause(.150)
            % app.UITable.Selection = previousSelectedRow;            
            % 
            % pause(1)
            % app.ColumnWidthMode.Enable = "on";

        end

        % Callback function: TableView
        function onTableViewChanged(app, event)
            
            newViewTypeIdx = setdiff([1, 2], app.UITable.UserData.viewType.valueData);
            app.UITable.UserData.viewType.valueData = newViewTypeIdx;
            app.TableView.Text = app.UITable.UserData.viewType.labels{newViewTypeIdx};

            syncInspectedTableWithUI(app, 'tableViewChanged')
            focus(app.jsBackDoor)
            
        end

        % Selection changed function: UITable
        function onTableSelectionChanged(app, event)
            
            updateToolbar(app)
            
        end

        % Cell edit callback: UITable
        function onTableCellEdited(app, event)
            
            % BUG "MATLAB R2024a Update 7"
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
                
            else
                editedGUIColumn = event.Source.ColumnName{event.Indices(2)};

                switch editedGUIColumn
                    case 'TIPO'
                        subtype = checkTypeSubtypeProductsMapping(app.projectData, event.Source.Data.("Tipo")(event.Indices(1)), event.Source.Data.("Subtipo"){event.Indices(1)});
                        event.Source.Data.("Subtipo"){event.Indices(1)} = subtype;

                    case {'FABRICANTE', 'MODELO'}
                        if strcmp(event.Source.Data.("Homologação"){event.Indices(1)}, '-')
                            newProductHash = model.ProjectBase.computeInspectedProductHash('-', event.Source.Data.("Fabricante"){event.Indices(1)}, event.Source.Data.("Modelo"){event.Indices(1)});
        
                            if ismember(newProductHash, app.projectData.inspectedProducts.("Hash"))
                                event.Source.Data{event.Indices(1), event.Indices(2)} = {event.PreviousData};                        
                                ui.Dialog(app.UIFigure, 'warning', model.ProjectBase.WARNING_ENTRYEXIST.PRODUCTS);
                                return
                            end
                        end
                end
            end

            syncInspectedTableWithUI(app, 'guiToDataSync')
            
        end

        % Menu selected function: TableRowDelete
        function onTableRowDeleteButtonClicked(app, event)
            
            selectedTableIndex = app.UITable.Selection;

            if ~isempty(selectedTableIndex)
                updateInspectedProducts(app.projectData, 'delete', selectedTableIndex)
                syncInspectedTableWithUI(app, 'dataToGuiSync')
            end

        end

        % Image clicked function: AddNonCertificate
        function onAddNonCertificateButtonClicked(app, event)
            
            [productData, productHash] = model.ProjectBase.initializeInspectedProduct('NãoHomologado', app.mainApp.General);
            if ismember(productHash, app.projectData.inspectedProducts.("Hash"))
                ui.Dialog(app.UIFigure, 'warning', model.ProjectBase.WARNING_ENTRYEXIST.PRODUCTS);
                return
            end

            updateInspectedProducts(app.projectData, 'add', productData)
            syncInspectedTableWithUI(app, 'dataToGuiSync')

        end

        % Callback function: AnalysisDetails, AnalysisDetailsViaContext, 
        % ...and 1 other component
        function onOpenPopupApp(app, event)
            
            switch event.Source
                case {app.AnalysisDetails, app.AnalysisDetailsViaContext}
                    if isempty(app.UITable.Data)
                        updateToolbar(app)
                        return
                    end
        
                    selectedRow = app.UITable.Selection;
        
                    if isempty(selectedRow)
                        selectedRow = 1;
                        app.UITable.Selection = selectedRow;
                        onTableSelectionChanged(app)
        
                    elseif ~isscalar(selectedRow)
                        selectedRow = selectedRow(1);
                        app.UITable.Selection = selectedRow;
                    end

                    dockAppTag = 'ProductInfo';
                    optionalArgs = {selectedRow};

                case app.OpenPopupProject
                    dockAppTag = 'ReportLib';
                    optionalArgs = {};
            end

            ipcMainMatlabOpenPopupApp(app.mainApp, app, dockAppTag, app.Context, optionalArgs{:})

        end

        % Image clicked function: GenerateReport
        function onGeneralReportButtonClicked(app, event)
            
            % <VALIDAÇÕES>
            context = 'PRODUCTS';
            issue = app.projectData.modules.(context).ui.issue;
            reportVersion = app.projectData.modules.(context).ui.reportVersion;

            if isempty(app.projectData.inspectedProducts)
                ui.Dialog(app.UIFigure, 'warning', 'A lista de produtos inspecionados está vazia.');
                return
            end

            if ~validateReportRequirements(app.projectData, context, 'reportModel')
                ui.Dialog(app.UIFigure, 'warning', 'Pendente escolha do modelo de relatório.');
                return
            end

            msgWarning = {};
            if ~validateReportRequirements(app.projectData, context, 'issue')
                msgWarning{end+1} = sprintf('• O número da inspeção "%.0f" é inválido.', issue);
            end

            if ~validateReportRequirements(app.projectData, context, 'unit')
                msgWarning{end+1} = '• Unidade geradora do documento precisa ser selecionada.';
            end

            if ~validateReportRequirements(app.projectData, context, 'entity')
                msgWarning{end+1} = '• Qualificação da fiscalizada ainda pendente.';
            end

            invalidRowIndexes = validateInspectedProducts(app.projectData);
            if ~isempty(invalidRowIndexes)
                msgWarning{end+1} = sprintf('• Os registros da(s) linha(s) %s estão incompletos.', strjoin(string(invalidRowIndexes), ', '));
            end

            if isempty(msgWarning)
                switch reportVersion
                    case 'Definitiva'
                        msgQuestion = sprintf('Confirma que se trata de monitoração relacionada à Atividade de Inspeção nº %.0f?', issue);
                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                        if userSelection == "Não"
                            return
                        end
                        
                    case 'Preliminar'
                        % ...
                end

            else
                msgInfo = model.ProjectBase.WARNING_VALIDATIONSRULES.PRODUCTS.entity;

                switch reportVersion
                    case 'Definitiva'
                        msgInfo = sprintf([ ...
                                'Foi(ram) identificada(s) a(s) pendência(s):<br>%s' ...
                                '<br><br>' ...
                                '<b>Essa(s) pendência(s) precisa(m) ser resolvida(s) ' ...
                                'antes de ser gerada a versão "Definitiva" do relatório</b>. ' ...
                                '<br><br>' ...
                                '<font style="color: gray; font-size: 11px;">%s</font></p>' ...
                            ], strjoin(msgWarning, '<br>'), msgInfo ...
                        );
                        ui.Dialog(app.UIFigure, 'warning', msgInfo);
                        return

                    case 'Preliminar'
                        msgQuestion = sprintf([ ...
                                'Foi(ram) identificado(s) a(s) pendência(s):<br>%s' ...
                                '<br><br>' ...
                                '<b>Continuar mesmo assim?</b>' ...
                                '<br><br>' ...
                                '<font style="color: gray; font-size: 11px;">%s</font></p>' ...
                            ], strjoin(msgWarning, '<br>'), msgInfo ...
                        );
                        selection = ui.Dialog(app.UIFigure, "uiconfirm", msgQuestion, {'Sim', 'Não'}, 1, 2);
                        if strcmp(selection, 'Não')
                            return
                        end
                end
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            reportDispatchOperation(app, 'onReportGenerate')
            % </PROCESSO>

        end

        % Image clicked function: UploadFinalFile
        function onUploadFinalFileButtonClicked(app, event)
            
            % <VALIDAÇÕES>
            context = app.Context;
            
            system = app.projectData.modules.(context).ui.system;
            issue = app.projectData.modules.(context).ui.issue;

            generatedHtmlFilePath = getGeneratedDocumentFileName(app.projectData, '.html', context);
            reportGenerationId = app.projectData.modules.(context).generatedFiles.id;
            currentProjectHash = model.ProjectBase.computeProjectHash('', '', app.projectData.inspectedProducts, [], []);            

            msg = '';
            if isempty(generatedHtmlFilePath)
                msg = 'A versão definitiva do relatório ainda não foi gerada.';
            elseif ~isfile(generatedHtmlFilePath)
                msg = sprintf('O arquivo "%s" não foi encontrado.', generatedHtmlFilePath);
            elseif ~strcmp(reportGenerationId, currentProjectHash)
                msg = [ ...
                    'A lista de produtos inspecionados foi modificada após a ' ...
                    'geração do relatório. Por essa razão, é necessário gerar ' ...
                    'novamente a versão definitiva do relatório antes do seu ' ...
                    '<i>upload</i> para o SEI' ...
                ];
            elseif ~isfolder(app.mainApp.General.fileFolder.DataHub_POST)
                msg = 'Pendente mapear pasta do Sharepoint';
            elseif ~validateReportRequirements(app.projectData, context, 'issue')
                msg = sprintf('O número da inspeção "%.0f" é inválido.', issue);
            elseif ~validateReportRequirements(app.projectData, context, 'unit')
                msg = 'Unidade geradora do documento precisa ser selecionada.';
            elseif isempty(system)
                msg = 'Ambiente do eFiscaliza precisa ser selecionado.';
            end

            if ~isempty(msg)
                ui.Dialog(app.UIFigure, 'warning', msg);
                return
            end

            uploadedFiles = getUploadedFiles(app.projectData, context, system, issue);
            if ~isempty(uploadedFiles)
                uploadedStatus = extractAfter({uploadedFiles.status}, 'Documento cadastrado no SEI sob o nº ');

                if isscalar(uploadedStatus)
                    uploadedStatus = uploadedStatus{1};
                else                    
                    uploadedStatus = strjoin([{strjoin(uploadedStatus(1:end-1), ', ')}, uploadedStatus(end)], ' e ');
                end

                msgQuestion = sprintf([ ...
                    'Já foi realizado <i>upload</i> para o SEI de relatório que engloba ' ...
                    'a presente lista de produtos inspecionados - SEI nº %s.<br><br>' ...
                    'Deseja realizar um novo <i>upload</i> para o SEI?' ...
                ], uploadedStatus);
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);

                if strcmp(userSelection, 'Não')
                    return
                end
            end
            % </VALIDAÇÕES>

            % <PROCESSO>
            reportDispatchOperation(app, 'onUploadArtifacts')
            % </PROCESSO>

        end

        % Image clicked function: ShowDataRules
        function onShowRulesImageClicked(app, event)
            
            msg = model.ProjectBase.WARNING_VALIDATIONSRULES.PRODUCTS.inspectedProducts;
            ui.Dialog(app.UIFigure, 'info', msg);

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
            app.GridLayout.ColumnWidth = {20, '1x', 96, 16, 22, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, 20, 20, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Title
            app.Title = uilabel(app.GridLayout);
            app.Title.VerticalAlignment = 'top';
            app.Title.WordWrap = 'on';
            app.Title.FontSize = 15;
            app.Title.FontColor = [0 0.4471 0.7412];
            app.Title.Layout.Row = [4 5];
            app.Title.Layout.Column = 2;
            app.Title.Interpreter = 'html';
            app.Title.Text = {'<b>Produtos inspecionados</b>'; '<font style="color: gray; font-size: 10px;">Visualize e edite informações dos produtos inspecionados. Homologação somente para consulta; subtipo, lacre e PLAI editáveis apenas pelo formulário.</font>'};

            % Create TableView
            app.TableView = uihyperlink(app.GridLayout);
            app.TableView.HyperlinkClickedFcn = createCallbackFcn(app, @onTableViewChanged, true);
            app.TableView.VisitedColor = [0.502 0.502 0.502];
            app.TableView.HorizontalAlignment = 'right';
            app.TableView.FontSize = 10;
            app.TableView.FontWeight = 'normal';
            app.TableView.FontColor = [0.502 0.502 0.502];
            app.TableView.Layout.Row = 6;
            app.TableView.Layout.Column = [3 5];
            app.TableView.Text = 'FORNECEDOR-USUÁRIO 👁';

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SUBTIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'FONTE|VALOR'; 'QTD.|VENDIDA'; 'QTD.|EM USO'; 'QTD.|ESTOQUE'; 'QTD.|ANUNCIADA'; 'QTD.|LACRADA'; 'QTD.|APREENDIDA'; 'QTD.|RETIDA (RFB)'; 'SITUAÇÃO'; 'INFRAÇÃO'};
            app.UITable.ColumnWidth = {120, 'auto', 'auto', 'auto', 'auto', 42, 42, 96, 90, 'auto', 66, 66, 66, 80, 70, 80, 80, 'auto', 'auto'};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false true false true true true true true true true true true true true true true true true true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @onTableCellEdited, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Layout.Row = 7;
            app.UITable.Layout.Column = [2 5];
            app.UITable.FontSize = 11;

            % Create NumRows
            app.NumRows = uilabel(app.GridLayout);
            app.NumRows.HorizontalAlignment = 'right';
            app.NumRows.FontSize = 10;
            app.NumRows.FontColor = [0.502 0.502 0.502];
            app.NumRows.Layout.Row = 8;
            app.NumRows.Layout.Column = [2 4];
            app.NumRows.Text = '';

            % Create FilterIconStatus
            app.FilterIconStatus = uiimage(app.GridLayout);
            app.FilterIconStatus.ScaleMethod = 'none';
            app.FilterIconStatus.Enable = 'off';
            app.FilterIconStatus.Visible = 'off';
            app.FilterIconStatus.Layout.Row = 8;
            app.FilterIconStatus.Layout.Column = 5;
            app.FilterIconStatus.HorizontalAlignment = 'right';
            app.FilterIconStatus.ImageSource = 'filter.svg';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, '1x', 22, 22, 22, 5, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 8];
            app.Toolbar.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create AddNonCertificate
            app.AddNonCertificate = uiimage(app.Toolbar);
            app.AddNonCertificate.ImageClickedFcn = createCallbackFcn(app, @onAddNonCertificateButtonClicked, true);
            app.AddNonCertificate.Layout.Row = [1 3];
            app.AddNonCertificate.Layout.Column = 1;
            app.AddNonCertificate.ImageSource = 'AddForbidden_32.png';

            % Create AnalysisDetails
            app.AnalysisDetails = uiimage(app.Toolbar);
            app.AnalysisDetails.ScaleMethod = 'none';
            app.AnalysisDetails.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.AnalysisDetails.Enable = 'off';
            app.AnalysisDetails.Layout.Row = [1 3];
            app.AnalysisDetails.Layout.Column = 2;
            app.AnalysisDetails.ImageSource = 'Variable_edit_16.png';

            % Create OpenPopupProject
            app.OpenPopupProject = uiimage(app.Toolbar);
            app.OpenPopupProject.ScaleMethod = 'none';
            app.OpenPopupProject.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.OpenPopupProject.Layout.Row = [1 3];
            app.OpenPopupProject.Layout.Column = 4;
            app.OpenPopupProject.ImageSource = 'organization-20px-black.svg';

            % Create GenerateReport
            app.GenerateReport = uiimage(app.Toolbar);
            app.GenerateReport.ScaleMethod = 'none';
            app.GenerateReport.ImageClickedFcn = createCallbackFcn(app, @onGeneralReportButtonClicked, true);
            app.GenerateReport.Enable = 'off';
            app.GenerateReport.Layout.Row = [1 3];
            app.GenerateReport.Layout.Column = 5;
            app.GenerateReport.ImageSource = 'Publish_HTML_16.png';

            % Create UploadFinalFile
            app.UploadFinalFile = uiimage(app.Toolbar);
            app.UploadFinalFile.ScaleMethod = 'none';
            app.UploadFinalFile.ImageClickedFcn = createCallbackFcn(app, @onUploadFinalFileButtonClicked, true);
            app.UploadFinalFile.Enable = 'off';
            app.UploadFinalFile.Layout.Row = [1 3];
            app.UploadFinalFile.Layout.Column = 6;
            app.UploadFinalFile.ImageSource = 'up-20px.png';

            % Create ToolbarSeparator
            app.ToolbarSeparator = uiimage(app.Toolbar);
            app.ToolbarSeparator.ScaleMethod = 'none';
            app.ToolbarSeparator.Enable = 'off';
            app.ToolbarSeparator.Layout.Row = [1 3];
            app.ToolbarSeparator.Layout.Column = 7;
            app.ToolbarSeparator.ImageSource = 'LineV.svg';

            % Create ShowDataRules
            app.ShowDataRules = uiimage(app.Toolbar);
            app.ShowDataRules.ImageClickedFcn = createCallbackFcn(app, @onShowRulesImageClicked, true);
            app.ShowDataRules.Layout.Row = [1 3];
            app.ShowDataRules.Layout.Column = 8;
            app.ShowDataRules.ImageSource = 'Info_36.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [4 7];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winProducts';

            % Create AnalysisDetailsViaContext
            app.AnalysisDetailsViaContext = uimenu(app.ContextMenu);
            app.AnalysisDetailsViaContext.MenuSelectedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.AnalysisDetailsViaContext.Enable = 'off';
            app.AnalysisDetailsViaContext.Text = '✏️ Editar';

            % Create TableRowDelete
            app.TableRowDelete = uimenu(app.ContextMenu);
            app.TableRowDelete.MenuSelectedFcn = createCallbackFcn(app, @onTableRowDeleteButtonClicked, true);
            app.TableRowDelete.Enable = 'off';
            app.TableRowDelete.Text = '❌ Excluir';
            
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
