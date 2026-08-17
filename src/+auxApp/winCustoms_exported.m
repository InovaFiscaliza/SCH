classdef winCustoms_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        DockModule                   matlab.ui.container.GridLayout
        dockModule_Close             matlab.ui.control.Image
        dockModule_Undock            matlab.ui.control.Image
        Hyperlink                    matlab.ui.control.Hyperlink
        NenhumarquivocarregadoLabel  matlab.ui.control.Label
        ToolbarSeparator1_2          matlab.ui.control.Image
        Toolbar                      matlab.ui.container.GridLayout
        UploadFinalFile              matlab.ui.control.Image
        GenerateReport               matlab.ui.control.Image
        OpenPopupProject             matlab.ui.control.Image
        AnalysisDetails              matlab.ui.control.Image
        ToolbarSeparator3            matlab.ui.control.Image
        AnalysisComparison           matlab.ui.control.Image
        AnalysisSummary              matlab.ui.control.Image
        ToolbarSeparator2            matlab.ui.control.Image
        RunAnalysis                  matlab.ui.control.Image
        ManageRules                  matlab.ui.control.Image
        ToolbarSeparator1            matlab.ui.control.Image
        OpenFile                     matlab.ui.control.Image
        ColumnWidthMode              matlab.ui.control.Hyperlink
        NumRows                      matlab.ui.control.Label
        UITable                      matlab.ui.control.Table
        FilterContext                matlab.ui.control.Label
        FilterSetup                  matlab.ui.control.Image
        FlowList                     matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'CUSTOMS'
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
                            % auxApp.dockCustomsAnalysisDetails >> winSCH >> auxApp.winCustoms
                            case 'onCustomsShipmentsTableChanged'
                                loadSelectedFlow(app)

                            % auxApp.dockReportLib >> winSCH >> auxApp.winCustoms
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
                        app.FlowList;
                        app.UITable;
                        app.OpenFile;
                        app.ManageRules;
                        app.RunAnalysis;
                        app.AnalysisSummary;
                        app.AnalysisComparison;
                        app.AnalysisDetails;
                        app.OpenPopupProject;
                        app.GenerateReport;
                        app.UploadFinalFile;
                        app.dockModule_Undock;
                        app.dockModule_Close
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.FlowList.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                            struct('appName', appName, 'dataTag', app.OpenFile.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Seleciona arquivos')), ...
                            struct('appName', appName, 'dataTag', app.ManageRules.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Gerencia regras')), ...
                            struct('appName', appName, 'dataTag', app.RunAnalysis.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Executa uma nova análise')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisSummary.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Mostra sumário da análise')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisComparison.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Compara com resultado obtido em ferramenta externa')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisDetails.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Abre formulário para edição de lista de produtos inspecionados')), ...
                            struct('appName', appName, 'dataTag', app.OpenPopupProject.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Edita informações do projeto<br>(fiscalizada, arquivo de backup etc)')), ...
                            struct('appName', appName, 'dataTag', app.GenerateReport.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Gera relatório')), ...
                            struct('appName', appName, 'dataTag', app.UploadFinalFile.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Upload relatório')), ...
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

            app.UITable.UserData.columnWidth = struct( ...
                'mode', 'initial', ...
                'value', {{110, 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'}} ...
            );

            % app.UITable.RowName = 'numbered';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            refreshFlowDropDown(app)
            loadSelectedFlow(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function refreshFlowDropDown(app)
            customsShipments = app.projectData.customsShipments;

            % Aberto, em 10/03/2026, reporte de BUG relacionado ao uidropdown, 
            % quando aplicado estilo "html". Ao apagar lista, o MATLAB não
            % apaga o valor atual do elemento na GUI. Assim que resolver
            % isso, basta inserir o addStyle uma única vez, não precisando
            % removê-lo.

            if ~isempty(customsShipments)
                if isempty(app.FlowList.StyleConfigurations)
                    addStyle(app.FlowList, uistyle('Interpreter', 'html'))
                end

                customsShipmentsIdx = app.FlowList.Value;
            
                items = {};
                itemsData = 1:numel(customsShipments);

                for ii = 1:numel(customsShipments)
                    fileName = customsShipments(ii).FileName;
                    
                    reportStatus = '';
                    if customsShipments(ii).ReportInclude
                        reportStatus = '&emsp;&#x1F7E2;';
                    end

                    numRows = height(customsShipments(ii).Data);
                    processedAt = customsShipments(ii).Analysis.ProcessedAt;
                
                    items{end+1} = sprintf('%s%s<br>└── %d registros • %s', fileName, reportStatus, numRows, processedAt);
                end
            
                currentValue = {};    
                if ~isempty(customsShipmentsIdx)
                    if isnumeric(customsShipmentsIdx) && ismember(customsShipmentsIdx, itemsData)
                        currentValue = {'Value', customsShipmentsIdx};
                    end
                end
            
                set(app.FlowList, 'Items', items, 'ItemsData', itemsData, currentValue{:})

            else             
                removeStyle(app.FlowList)
                app.FlowList.Items = {};
            end
        end
        

        %-----------------------------------------------------------------%
        function loadSelectedFlow(app)
            customsShipmentsIdx = app.FlowList.Value;

            if ~isempty(customsShipmentsIdx)
                customsShipments = app.projectData.customsShipments(customsShipmentsIdx);
                app.UITable.Data = customsShipments.Data(:, {'remessaCodigo', 'remessaDescricao', 'regraCategoria', 'regraDecisaoSugerida', 'estadoAmostragem', 'estadoRevisao', 'estadoVistoria', 'auditorDecisaoFinal', 'auditorNota'});
            else
                app.UITable.Data = [];
            end            
    
            app.UITable.UserData.columnWidth.mode = 'initial';
            app.ColumnWidthMode.Text = 'INICIAL ↔';

            updateTableStyle(app)
            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            invalidRowIndexes = [];
            removeStyle(app.UITable)

            if ~isempty(app.projectData.customsShipments)
                customsShipmentsIdx = app.FlowList.Value;
                [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateCustomsShipments(app.projectData, customsShipmentsIdx);

                if ~isempty(invalidRowIndexes)
                    applyRowStyle(invalidRowIndexes)
                    applyCellStyle(ruleViolationMatrix, ruleColumns)
                end
            end

            updateTableNumRows(invalidRowIndexes)

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

            function updateTableNumRows(invalidRowIndexes)
                numRows = height(app.UITable.Data);
                numInvalidRows = numel(invalidRowIndexes);

                if numRows == 0
                    numRowsText = '';
                elseif numRows == 1
                    numRowsText = '1 REGISTRO';
                else
                    numRowsText = sprintf('%d REGISTROS', numRows);
                end

                if numInvalidRows > 1
                    numRowsText = sprintf('%s  •  %d PENDENTES', numRowsText, numInvalidRows);
                elseif numInvalidRows == 1
                    numRowsText = sprintf('%s  •  1 PENDENTE', numRowsText);
                end

                app.NumRows.Text = numRowsText;
            end
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            nonEmptyCustomsShipments = ~isempty(app.projectData.customsShipments);
            nonEmptyTableSelection = ~isempty(app.UITable.Selection);

            set([ 
                app.RunAnalysis;
                app.AnalysisSummary;
                app.AnalysisComparison;
                app.AnalysisDetails;
                app.GenerateReport
            ], 'Enable', nonEmptyCustomsShipments)

            app.AnalysisDetails.Enable = nonEmptyCustomsShipments && nonEmptyTableSelection;

            app.UploadFinalFile.Enable = ~isempty(app.projectData.modules.(app.Context).generatedFiles.lastHTMLDocFullPath);

            if ~isempty(app.projectData.customsShipments)
                customsShipmentsIdx = app.FlowList.Value;
                customsShipments = app.projectData.customsShipments(customsShipmentsIdx);
                
                app.RunAnalysis.Enable = ~isequal(app.projectData.customsRules, customsShipments.Analysis.Rules);
            end
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

        % Value changed function: FlowList
        function onFlowListValueChanged(app, event)
            
            loadSelectedFlow(app)
            
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
            try
                if iscellstr(event.Source.Data{event.Indices(1), event.Indices(2)})
                    event.Source.Data{event.Indices(1), event.Indices(2)} = strtrim(event.Source.Data{event.Indices(1), event.Indices(2)});
                end
    
                if isequal(event.PreviousData, event.NewData)
                    return
    
                elseif ischar(event.NewData) && isequal(strtrim(event.NewData), event.PreviousData)
                    event.Source.Data{event.Indices(1), event.Indices(2)} = {event.PreviousData};
                    return
                    
                else
                    customsShipmentsIdx = app.FlowList.Value;

                    currentRow = event.Indices(1);
                    columnName = event.Source.Data.Properties.VariableNames{event.Indices(2)};                    
                    
                    updateCustomsShipments(app.projectData, 'annotationSingleEdit', customsShipmentsIdx, currentRow, columnName, event.NewData)
                    app.UITable.Data(currentRow, :) = app.projectData.customsShipments(customsShipmentsIdx).Data(currentRow, {'remessaCodigo', 'remessaDescricao', 'regraCategoria', 'regraDecisaoSugerida', 'estadoAmostragem', 'estadoRevisao', 'estadoVistoria', 'auditorDecisaoFinal', 'auditorNota'});
                    updateTableStyle(app)
                end

            catch ME
                applyInitialLayout(app)
            end
            
        end

        % Callback function: ColumnWidthMode
        function onTableColumnWidthModeChanged(app, event)
            
            app.ColumnWidthMode.Enable = "off";

            previousSelectedRow = app.UITable.Selection;
            app.UITable.Selection = [];
            
            switch app.UITable.UserData.columnWidth.mode
                case 'initial'
                    app.UITable.UserData.columnWidth.mode = 'fix';
                    app.UITable.ColumnWidth = '1x';
                    app.ColumnWidthMode.Text = 'FIXO ↔';
                case 'fix'
                    app.UITable.UserData.columnWidth.mode = 'auto';
                    app.UITable.ColumnWidth = 'auto';
                    app.ColumnWidthMode.Text = 'AUTO ↔';
                otherwise % 'auto'
                    app.UITable.UserData.columnWidth.mode = 'initial';
                    app.UITable.ColumnWidth = app.UITable.UserData.columnWidth.value;
                    app.ColumnWidthMode.Text = 'INICIAL ↔';
            end
            
            pause(.150)
            app.UITable.Selection = previousSelectedRow;            
            
            pause(1)
            app.ColumnWidthMode.Enable = "on";

        end

        % Image clicked function: OpenFile
        function onOpenFileButtonClicked(app, event)
            
            [~, filePath, ~, fileName] = ui.Dialog( ...
                app.UIFigure, ...
                'uigetfile', ...
                '', ...
                {'*.csv;*.mat', '(*.csv,*.mat)'}, ...
                app.mainApp.General.fileFolder.lastVisited, ...
                {'MultiSelect', 'on'} ...
            );

            if isempty(fileName)
                return
            elseif ~iscell(fileName)
                fileName = {fileName};
            end
            fileFullName = fullfile(filePath, fileName);
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', filePath)

            d = ui.Dialog(app.UIFigure, "progressdlg", "Em andamento...");
            filesError = struct('File', {}, 'Error', {});

            for ii = 1:numel(fileFullName)
                d.Message = textFormatGUI.HTMLParagraph(sprintf('Em andamento a leitura do arquivo %d de %d:<br>• <b>%s</b>', ii, numel(fileFullName), fileName{ii}));

                [~, ~, fileExt] = fileparts(fileFullName{ii});
                switch fileExt
                    case '.mat'
                        msg = load(app.projectData, 'file', fileFullName{ii});
                    
                    otherwise % '.txt', '.csv' etc
                        msg = updateCustomsShipments(app.projectData, 'add', fileFullName{ii}, app.mainApp.General, app.mainApp.rootFolder);
                end

                if ~isempty(msg)
                    filesError(end+1) = struct('File', sprintf('"%s"', fileName{ii}), 'Error', msg);
                    continue
                end
            end

            % LOG
            if ~isempty(filesError)
                msgWarning = sprintf('Arquivos que apresentaram erro na leitura:\n%s\n\n', strjoin(strcat({'•&thinsp;<b>'}, {filesError.File}, {'</b>: <i>'}, {filesError.Error}), '</i>\n\n'));
                ui.Dialog(app.UIFigure, "error", msgWarning);
            end
            
            % Atualiza app.FileTree.
            if numel(fileFullName) > numel(filesError)
                applyInitialLayout(app)
            end

            delete(d)

        end

        % Image clicked function: RunAnalysis
        function onRunAnalysisButtonClicked(app, event)
            
            uialert(app.UIFigure, 'Pendente', '')

        end

        % Image clicked function: AnalysisSummary
        function onAnalysisSummaryButtonClicked(app, event)
            
            customsShipmentsIdx = app.FlowList.Value;
            customsData = app.projectData.customsShipments(customsShipmentsIdx).Data;

            suggestionCategories = unique(customsData.("regraDecisaoSugerida"));
            suggestionCategoriesCount = countcats(customsData.("regraDecisaoSugerida"));

            ui.Dialog(app.UIFigure, "info", jsonencode(table(suggestionCategories, suggestionCategoriesCount, 'VariableNames', {'decisaoSugerida', 'quantidade'})));

        end

        % Image clicked function: AnalysisComparison
        function onAnalysisComparisonButtonClicked(app, event)
            
            uialert(app.UIFigure, 'Pendente', '')

        end

        % Image clicked function: AnalysisDetails, FilterSetup, 
        % ...and 2 other components
        function onOpenPopupApp(app, event)
            
            optionalArgs = {};

            switch event.Source
                case app.FilterSetup
                    dockAppTag = 'CustomsFilter';

                case app.ManageRules
                    dockAppTag = 'CustomsManageRules';

                case app.AnalysisDetails
                    dockAppTag = 'CustomsAnalysisDetails';
                    
                    customsShipmentsIdx = app.FlowList.Value;
                    customsDataIdxs = app.UITable.Selection;
                    optionalArgs = {customsShipmentsIdx, customsDataIdxs};

                case app.OpenPopupProject
                    dockAppTag = 'ReportLib';
            end

            ipcMainMatlabOpenPopupApp(app.mainApp, app, dockAppTag, app.Context, optionalArgs{:})

        end

        % Image clicked function: GenerateReport
        function onGeneralReportButtonClicked(app, event)
            
            % <VALIDAÇÕES>
            context = app.Context;

            issue = app.projectData.modules.(context).ui.issue;
            reportVersion = app.projectData.modules.(context).ui.reportVersion;

            if isempty(app.projectData.customsShipments)
                ui.Dialog(app.UIFigure, 'warning', 'A lista de produtos inspecionados está vazia.');
                return
            end
            customsShipmentsIdx = app.FlowList.Value;
            updateCustomsShipments(app.projectData, 'reportInclude', customsShipmentsIdx)

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

            invalidRowIndexes = validateCustomsShipments(app.projectData, customsShipmentsIdx);
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
            app.GridLayout.ColumnWidth = {20, 18, 5, 40, '1x', 412, 10, 5, 10, '1x', 38, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, 14, 6, 10, 10, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create FlowList
            app.FlowList = uidropdown(app.GridLayout);
            app.FlowList.Items = {};
            app.FlowList.ValueChangedFcn = createCallbackFcn(app, @onFlowListValueChanged, true);
            app.FlowList.FontSize = 11;
            app.FlowList.FontColor = [1 1 1];
            app.FlowList.BackgroundColor = [0.7176 0.1922 0.1725];
            app.FlowList.Layout.Row = [4 7];
            app.FlowList.Layout.Column = 6;
            app.FlowList.Value = {};

            % Create FilterSetup
            app.FilterSetup = uiimage(app.GridLayout);
            app.FilterSetup.ScaleMethod = 'none';
            app.FilterSetup.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.FilterSetup.Layout.Row = [6 8];
            app.FilterSetup.Layout.Column = 2;
            app.FilterSetup.ImageSource = 'settings.svg';

            % Create FilterContext
            app.FilterContext = uilabel(app.GridLayout);
            app.FilterContext.FontSize = 10;
            app.FilterContext.FontColor = [0.502 0.502 0.502];
            app.FilterContext.Layout.Row = [6 8];
            app.FilterContext.Layout.Column = [4 5];
            app.FilterContext.Interpreter = 'html';
            app.FilterContext.Text = {'[FC] '; 'Nenhum filtro por coluna ativo '};

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'REMESSA|CÓDIGO'; 'REMESSA|DESCRIÇÃO'; 'REGRA|CATEGORIA'; 'REGRA|DECISÃO SUGERIDA'; 'ESTADO|AMOSTRAGEM'; 'ESTADO|REVISÃO'; 'ESTADO|VISTORIA'; 'AUDITOR|DECISÃO FINAL'; 'AUDITOR|NOTA'};
            app.UITable.ColumnWidth = {110, 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false false false false false false false true true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @onTableCellEdited, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Layout.Row = 9;
            app.UITable.Layout.Column = [2 11];
            app.UITable.FontSize = 11;

            % Create NumRows
            app.NumRows = uilabel(app.GridLayout);
            app.NumRows.FontSize = 10;
            app.NumRows.FontColor = [0.502 0.502 0.502];
            app.NumRows.Layout.Row = 10;
            app.NumRows.Layout.Column = [2 6];
            app.NumRows.Text = '';

            % Create ColumnWidthMode
            app.ColumnWidthMode = uihyperlink(app.GridLayout);
            app.ColumnWidthMode.HyperlinkClickedFcn = createCallbackFcn(app, @onTableColumnWidthModeChanged, true);
            app.ColumnWidthMode.VisitedColor = [0.502 0.502 0.502];
            app.ColumnWidthMode.HorizontalAlignment = 'right';
            app.ColumnWidthMode.FontSize = 10;
            app.ColumnWidthMode.FontWeight = 'normal';
            app.ColumnWidthMode.FontColor = [0.502 0.502 0.502];
            app.ColumnWidthMode.Layout.Row = 10;
            app.ColumnWidthMode.Layout.Column = 11;
            app.ColumnWidthMode.Text = 'INICIAL ↔';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 5, 22, 22, 5, 22, '1x', 22, 22, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 11;
            app.Toolbar.Layout.Column = [1 14];
            app.Toolbar.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create OpenFile
            app.OpenFile = uiimage(app.Toolbar);
            app.OpenFile.ScaleMethod = 'none';
            app.OpenFile.ImageClickedFcn = createCallbackFcn(app, @onOpenFileButtonClicked, true);
            app.OpenFile.Layout.Row = [1 3];
            app.OpenFile.Layout.Column = 1;
            app.OpenFile.ImageSource = 'Import_16.png';

            % Create ToolbarSeparator1
            app.ToolbarSeparator1 = uiimage(app.Toolbar);
            app.ToolbarSeparator1.ScaleMethod = 'none';
            app.ToolbarSeparator1.Enable = 'off';
            app.ToolbarSeparator1.Layout.Row = [1 3];
            app.ToolbarSeparator1.Layout.Column = 2;
            app.ToolbarSeparator1.VerticalAlignment = 'bottom';
            app.ToolbarSeparator1.ImageSource = 'LineV.svg';

            % Create ManageRules
            app.ManageRules = uiimage(app.Toolbar);
            app.ManageRules.ScaleMethod = 'none';
            app.ManageRules.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.ManageRules.Layout.Row = [1 3];
            app.ManageRules.Layout.Column = 3;
            app.ManageRules.ImageSource = 'law.svg';

            % Create RunAnalysis
            app.RunAnalysis = uiimage(app.Toolbar);
            app.RunAnalysis.ScaleMethod = 'none';
            app.RunAnalysis.ImageClickedFcn = createCallbackFcn(app, @onRunAnalysisButtonClicked, true);
            app.RunAnalysis.Enable = 'off';
            app.RunAnalysis.Layout.Row = [1 3];
            app.RunAnalysis.Layout.Column = 4;
            app.RunAnalysis.ImageSource = 'Run_16.png';

            % Create ToolbarSeparator2
            app.ToolbarSeparator2 = uiimage(app.Toolbar);
            app.ToolbarSeparator2.ScaleMethod = 'none';
            app.ToolbarSeparator2.Enable = 'off';
            app.ToolbarSeparator2.Layout.Row = [1 3];
            app.ToolbarSeparator2.Layout.Column = 5;
            app.ToolbarSeparator2.VerticalAlignment = 'bottom';
            app.ToolbarSeparator2.ImageSource = 'LineV.svg';

            % Create AnalysisSummary
            app.AnalysisSummary = uiimage(app.Toolbar);
            app.AnalysisSummary.ScaleMethod = 'none';
            app.AnalysisSummary.ImageClickedFcn = createCallbackFcn(app, @onAnalysisSummaryButtonClicked, true);
            app.AnalysisSummary.Enable = 'off';
            app.AnalysisSummary.Layout.Row = [1 3];
            app.AnalysisSummary.Layout.Column = 6;
            app.AnalysisSummary.ImageSource = 'report.svg';

            % Create AnalysisComparison
            app.AnalysisComparison = uiimage(app.Toolbar);
            app.AnalysisComparison.ScaleMethod = 'none';
            app.AnalysisComparison.ImageClickedFcn = createCallbackFcn(app, @onAnalysisComparisonButtonClicked, true);
            app.AnalysisComparison.Enable = 'off';
            app.AnalysisComparison.Layout.Row = [1 3];
            app.AnalysisComparison.Layout.Column = 7;
            app.AnalysisComparison.ImageSource = 'git-compare.svg';

            % Create ToolbarSeparator3
            app.ToolbarSeparator3 = uiimage(app.Toolbar);
            app.ToolbarSeparator3.ScaleMethod = 'none';
            app.ToolbarSeparator3.Enable = 'off';
            app.ToolbarSeparator3.Layout.Row = [1 3];
            app.ToolbarSeparator3.Layout.Column = 8;
            app.ToolbarSeparator3.VerticalAlignment = 'bottom';
            app.ToolbarSeparator3.ImageSource = 'LineV.svg';

            % Create AnalysisDetails
            app.AnalysisDetails = uiimage(app.Toolbar);
            app.AnalysisDetails.ScaleMethod = 'none';
            app.AnalysisDetails.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.AnalysisDetails.Enable = 'off';
            app.AnalysisDetails.Layout.Row = [1 3];
            app.AnalysisDetails.Layout.Column = 9;
            app.AnalysisDetails.ImageSource = 'Variable_edit_16.png';

            % Create OpenPopupProject
            app.OpenPopupProject = uiimage(app.Toolbar);
            app.OpenPopupProject.ScaleMethod = 'none';
            app.OpenPopupProject.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.OpenPopupProject.Layout.Row = [1 3];
            app.OpenPopupProject.Layout.Column = 11;
            app.OpenPopupProject.ImageSource = 'organization-20px-black.svg';

            % Create GenerateReport
            app.GenerateReport = uiimage(app.Toolbar);
            app.GenerateReport.ScaleMethod = 'none';
            app.GenerateReport.ImageClickedFcn = createCallbackFcn(app, @onGeneralReportButtonClicked, true);
            app.GenerateReport.Enable = 'off';
            app.GenerateReport.Layout.Row = [1 3];
            app.GenerateReport.Layout.Column = 12;
            app.GenerateReport.ImageSource = 'Publish_HTML_16.png';

            % Create UploadFinalFile
            app.UploadFinalFile = uiimage(app.Toolbar);
            app.UploadFinalFile.ScaleMethod = 'none';
            app.UploadFinalFile.ImageClickedFcn = createCallbackFcn(app, @onUploadFinalFileButtonClicked, true);
            app.UploadFinalFile.Enable = 'off';
            app.UploadFinalFile.Layout.Row = [1 3];
            app.UploadFinalFile.Layout.Column = 13;
            app.UploadFinalFile.ImageSource = 'up-20px.png';

            % Create ToolbarSeparator1_2
            app.ToolbarSeparator1_2 = uiimage(app.GridLayout);
            app.ToolbarSeparator1_2.Enable = 'off';
            app.ToolbarSeparator1_2.Layout.Row = [4 7];
            app.ToolbarSeparator1_2.Layout.Column = 8;
            app.ToolbarSeparator1_2.VerticalAlignment = 'bottom';
            app.ToolbarSeparator1_2.ImageSource = 'LineV.svg';

            % Create NenhumarquivocarregadoLabel
            app.NenhumarquivocarregadoLabel = uilabel(app.GridLayout);
            app.NenhumarquivocarregadoLabel.FontSize = 11;
            app.NenhumarquivocarregadoLabel.Layout.Row = [4 5];
            app.NenhumarquivocarregadoLabel.Layout.Column = 10;
            app.NenhumarquivocarregadoLabel.Text = 'Nenhum arquivo carregado';

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.GridLayout);
            app.Hyperlink.VisitedColor = [0 0.4 0.8];
            app.Hyperlink.FontSize = 11;
            app.Hyperlink.FontColor = [0 0.4 0.8];
            app.Hyperlink.Layout.Row = [5 7];
            app.Hyperlink.Layout.Column = 10;
            app.Hyperlink.Text = 'Gerenciar arquivos';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [11 13];
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

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winCustoms_exported(Container, varargin)

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
