classdef winCustoms_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModule                 matlab.ui.container.GridLayout
        dockModule_Close           matlab.ui.control.Image
        dockModule_Undock          matlab.ui.control.Image
        Toolbar                    matlab.ui.container.GridLayout
        ShowDataRules              matlab.ui.control.Image
        ToolbarSeparator3          matlab.ui.control.Image
        UploadFinalFile            matlab.ui.control.Image
        GenerateReport             matlab.ui.control.Image
        OpenPopupProject           matlab.ui.control.Image
        ToolbarSeparator2          matlab.ui.control.Image
        AnalysisComparison         matlab.ui.control.Image
        AnalysisSummary            matlab.ui.control.Image
        ManageFilesSummary         matlab.ui.control.Label
        ManageFiles                matlab.ui.control.Image
        OpenFile                   matlab.ui.control.Image
        ToolbarSeparator1          matlab.ui.control.Image
        AnalysisDetails            matlab.ui.control.Image
        FilterSetup                matlab.ui.control.Image
        FilterIconStatus           matlab.ui.control.Image
        NumRows                    matlab.ui.control.Label
        UITable                    matlab.ui.control.Table
        Title                      matlab.ui.control.Label
        ContextMenu                matlab.ui.container.ContextMenu
        AnalysisDetailsViaContext  matlab.ui.container.Menu
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
        customsShipmentsIndex
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        COLUMNS_VISIBLE = {'remessaCodigo', 'remessaDescricao', 'numRegrasAvaliadas', 'regraCategoria', 'regraDecisaoSugerida', 'estadoAmostragem', 'estadoRevisao', 'estadoVistoria', 'auditorDecisaoFinal', 'auditorNota'}
        STYLE_ROW_ICON = uistyle('Icon', 'warning-20px-red.svg', 'IconAlignment', 'rightmargin')
        STYLE_CELL_HIGHLIGHT = uistyle('BackgroundColor', '#c80b0f', 'FontColor', 'white')
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
                                loadSelectedFile(app)

                            % audApp.dockCustomsFilter >> winSCH >> auxApp.winCustoms
                            case 'onCustomsColumnFilterChanged'
                                loadSelectedFile(app)

                            % audApp.dockCustomsManageFiles >> winSCH >> auxApp.winCustoms
                            case 'onCustomsShipmentsFileChangeRequest'
                                app.customsShipmentsIndex = varargin{1};
                                applyInitialLayout(app)

                            case 'onCustomsShipmentsFileDeleteRequest'
                                app.customsShipmentsIndex = [];
                                applyInitialLayout(app)

                            % auxApp.dockReportLib >> winSCH >> auxApp.winCustoms
                            case {'onProjectLoad', 'onProjectRestart'}
                                app.customsShipmentsIndex = [];
                                applyInitialLayout(app)

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
                                error('auxApp:winCustoms:UnexpectedCall', 'Unexpected call "%s"', eventName)
                        end
    
                    otherwise
                        error('auxApp:winCustoms:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
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
                        app.FilterIconStatus;
                        app.FilterSetup;
                        app.AnalysisDetails;
                        app.OpenFile;
                        app.ManageFiles;
                        app.AnalysisSummary;
                        app.AnalysisComparison;
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
                            struct('appName', appName, 'dataTag', app.FilterIconStatus.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', '')), ...
                            struct('appName', appName, 'dataTag', app.FilterSetup.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Configura filtros')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisDetails.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Abre formulário para edição em lote de registros')), ...
                            struct('appName', appName, 'dataTag', app.OpenFile.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Seleciona arquivos')), ...
                            struct('appName', appName, 'dataTag', app.ManageFiles.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Gerencia arquivos')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisSummary.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Mostra sumário da análise')), ...
                            struct('appName', appName, 'dataTag', app.AnalysisComparison.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Compara com resultado obtido em ferramenta externa')), ...
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

            app.UITable.UserData.visibleRows = [];
            app.FilterIconStatus.UserData.tooltip = '';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            refreshFileSummary(app)
            loadSelectedFile(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function refreshFileSummary(app)
            customsShipments = app.projectData.customsShipments;

            if ~isempty(customsShipments)
                if isempty(app.customsShipmentsIndex)
                    app.customsShipmentsIndex = 1;
                end

                customsShipmentsIdx = app.customsShipmentsIndex;
                [~, fileName, fileExt] = fileparts(customsShipments(customsShipmentsIdx).FileName);
                fileName = [fileName, fileExt];

                numFiles = numel(customsShipments);
                if numFiles == 1
                    numFilesText = '1 arquivo carregado';
                else
                    numFilesText = sprintf('%d arquivos carregados', numFiles);
                end

                fileSummary = sprintf([ ...
                    '<font style="color: gray;">%s </font>' ...
                    '<br><b>%s </b>' ...
                ], numFilesText, fileName);

            else
                fileSummary = '<font style="color: gray;">Nenhum arquivo carregado </font>';
            end

            app.ManageFilesSummary.Text = fileSummary;
        end

        %-----------------------------------------------------------------%
        function loadSelectedFile(app)
            customsShipmentsIdx = app.customsShipmentsIndex;

            if ~isempty(customsShipmentsIdx)
                customsShipments = app.projectData.customsShipments(customsShipmentsIdx);
                customsData = customsShipments.Data;
                
                % Filtra os dados, caso aplicável.
                filterObj = customsShipments.UserData.Filter;
                filterStatus = ~isempty(filterObj) && ~isempty(filterObj.filterRules(filterObj.filterRules.Enable, :));
    
                if filterStatus
                    displayDataIdxs = find(run(filterObj, 'filterRules', customsData));                
                    filterIconTooltip = strjoin(getFilterList(filterObj, 'tbl', 'on'), '<br>');
                else
                    displayDataIdxs = (1:height(customsData))';                
                    filterIconTooltip = '';
                end

                rowNames = cellstr(string(displayDataIdxs));

                % Número total de linhas da tabela e número de linhas visíveis.
                numRows = height(customsData);
                numVisibleRows = numel(displayDataIdxs);

                set(app.UITable, 'RowName', rowNames, 'Data', customsData(displayDataIdxs, app.COLUMNS_VISIBLE))
                app.UITable.UserData.visibleRows = displayDataIdxs;
                updateRowStatusIndicators(app, numRows, numVisibleRows, filterIconTooltip)

            else
                app.UITable.Data = [];
                app.UITable.UserData.visibleRow = [];
                updateRowStatusIndicators(app)
            end

            updateTableStyle(app)
            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function updateRowStatusIndicators(app, numRows, numVisibleRows, filterIconTooltip)
            if nargin < 4
                app.NumRows.Text = '';
                app.FilterIconStatus.Visible = 'off';
                return
            end

            if ~strcmp(app.FilterIconStatus.UserData.tooltip, filterIconTooltip)
                app.FilterIconStatus.UserData.tooltip = filterIconTooltip;
                try
                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                        struct('appName', class.Constants.appName, 'dataTag', app.FilterIconStatus.UserData.id, 'tooltipUpdate', struct('textContent', filterIconTooltip)) ...
                    });
                catch
                end
            end

            if numVisibleRows == numRows
                numberOfRowsText = sprintf('%d LINHAS ', numRows);
                filterIconImageSource = 'filter.svg';
                filterIconEnable = 'off';
                textColor = [0.65,0.65,0.65];
            else
                numberOfRowsText = sprintf('%d DE %d LINHAS ', numVisibleRows, numRows);
                filterIconImageSource = 'filter-filled.svg';
                filterIconEnable = 'on';
                textColor = [0,0,0];
            end

            if numRows == 1
                numberOfRowsText = replace(numberOfRowsText, 'LINHAS', 'LINHA');                
            end

            set(app.NumRows, 'Text', numberOfRowsText, 'FontColor', textColor)
            set(app.FilterIconStatus, 'ImageSource', filterIconImageSource, 'Enable', filterIconEnable)
            if ~app.FilterIconStatus.Visible
                app.FilterIconStatus.Visible = 'on';
            end
        end

        %-----------------------------------------------------------------%
        function updateTableStyle(app)
            removeStyle(app.UITable)

            if ~isempty(app.projectData.customsShipments)
                customsShipmentsIdx = app.customsShipmentsIndex;
                visibleRows = app.UITable.UserData.visibleRows;
                customsData = app.projectData.customsShipments(customsShipmentsIdx).Data(visibleRows, :);

                [invalidRowIndexes, ruleViolationMatrix, ruleColumns] = validateCustomsShipments(app.projectData, customsData);

                if ~isempty(invalidRowIndexes)
                    applyRowStyle(invalidRowIndexes)
                    applyCellStyle(ruleViolationMatrix, ruleColumns)
                end
            end

            function applyRowStyle(invalidRowIndexes)
                s = app.STYLE_ROW_ICON;
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
    
                s = app.STYLE_CELL_HIGHLIGHT;
                addStyle(app.UITable, s, "cell", cellList)
            end
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            nonEmptyCustomsShipments = ~isempty(app.projectData.customsShipments);
            nonEmptyTableSelection = ~isempty(app.UITable.Selection);

            set([ 
                app.FilterSetup;
                app.ManageFiles;
                app.AnalysisSummary;
                app.AnalysisComparison;
                app.GenerateReport
            ], 'Enable', nonEmptyCustomsShipments)

            set([
                app.AnalysisDetails;
                app.AnalysisDetailsViaContext
            ], 'Enable', nonEmptyCustomsShipments && nonEmptyTableSelection)

            app.UploadFinalFile.Enable = ~isempty(app.projectData.modules.(app.Context).generatedFiles.lastHTMLDocFullPath);
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

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', app.Context)
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
                    customsShipmentsIdx = app.customsShipmentsIndex;

                    displayRow = event.Indices(1);
                    currentRow = app.UITable.UserData.visibleRows(displayRow);
                    columnName = event.Source.Data.Properties.VariableNames{event.Indices(2)};                    
                    
                    updateCustomsShipments(app.projectData, 'annotationSingleEdit', customsShipmentsIdx, currentRow, columnName, event.NewData)

                    % Atualiza toda a linha para garantir sincronismo com
                    % a tabela "customsData", o que se faz necessário por
                    % conta da atualização automática das colunas "situacaoVistoria" 
                    % e "situacaoRevisao". Além disso, deve-se atualizar 
                    % toda a tabela sempre que houver filtro pois o novo
                    % valor da célula pode não mais atender aos critérios 
                    % de filtragem.
                    customsShipments = app.projectData.customsShipments(customsShipmentsIdx);
                    customsData = customsShipments.Data;

                    filterObj = customsShipments.UserData.Filter;
                    filterStatus = false;
                    if ~isempty(filterObj)
                        filterRules = filterObj.filterRules(filterObj.filterRules.Enable, :);
                        filterStatus = any(ismember(filterRules.Field, {'estadoRevisao', 'estadoVistoria', 'auditorDecisaoFinal', 'auditorNota'}));
                    end
                    
                    if filterStatus
                        loadSelectedFile(app)
                    else
                        app.UITable.Data(displayRow, :) = customsData(currentRow, app.COLUMNS_VISIBLE);
                        updateTableStyle(app)
                    end
                end

            catch ME
                applyInitialLayout(app)
            end
            
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

        % Image clicked function: AnalysisSummary
        function onAnalysisSummaryButtonClicked(app, event)
            
            customsShipmentsIdx = app.customsShipmentsIndex; 
            customsData = app.projectData.customsShipments(customsShipmentsIdx).Data;

            htmlContent = util.HtmlTextGenerator.createCustomsAnalysisSummary(customsData);
            ui.Dialog(app.UIFigure, "info", htmlContent);

        end

        % Image clicked function: AnalysisComparison
        function onAnalysisComparisonButtonClicked(app, event)
            
            [fileFullName, filePath, ~, fileName] = ui.Dialog( ...
                app.UIFigure, ...
                'uigetfile', ...
                '', ...
                {'*.csv', '(*.csv)'}, ...
                app.mainApp.General.fileFolder.lastVisited ...
            );

            if isempty(fileName)
                return
            end

            ipcMainMatlabCallsHandler(app.mainApp, app, 'onUpdateLastVisitedFolder', filePath)

            d = ui.Dialog(app.UIFigure, "progressdlg", "Em andamento...");

            customsShipmentsIdx = app.customsShipmentsIndex;
            customsShipments = app.projectData.customsShipments(customsShipmentsIdx);
            customsData = customsShipments.Data;

            try
                externalDecisions = readtable(fileFullName, "VariableNamingRule", "preserve");
                externalDecisions = sortrows(externalDecisions(:, {'Codigo da Remessa', 'Sugestao do Sistema'}), 'Codigo da Remessa');

                externalToInternalDecisionMap = dictionary( ...
                    ["DEVOLUÇÃO", "LIBERADO", "PERDIMENTO", "PRAZO", "REVISÃO MANUAL"], ...
                    ["Devolução", "Liberado", "Perdimento", "Prazo", "Vistoria"] ...
                );

                externalShipmentsHash = Hash.sha1(strjoin(sort(externalDecisions.("Codigo da Remessa")), ' - '));
                if ~strcmp(externalShipmentsHash, customsShipments.Hash)
                    error('onAnalysisComparisonButtonClicked:shipmentsMismatch', 'O arquivo selecionado não corresponde às remessas do arquivo atualmente carregado.')
                end

                externalDecisions.("regraDecisaoSugerida") = categorical(externalToInternalDecisionMap(externalDecisions.("Sugestao do Sistema")));
                customsData = sortrows(customsData, 'remessaCodigo');
                
                matchingSuggestionPercentage = 100 * sum(externalDecisions.("regraDecisaoSugerida") == customsData.("regraDecisaoSugerida")) / height(customsData);
                msg = sprintf('Percentual de registros que possuem a mesma destinação sugerida: <b>%.1f%%</b><br><br>%s<br><br>%s', ...
                    matchingSuggestionPercentage, ...
                    util.HtmlTextGenerator.createCustomsAnalysisSummary(customsData, 'Algoritmo executado internamente:', false), ...
                    util.HtmlTextGenerator.createCustomsAnalysisSummary(externalDecisions, 'Algoritmo executado externamente:', false) ...                    
                );

            catch ME
                msg = ME.message;
            end

            ui.Dialog(app.UIFigure, "info", msg);
            delete(d)

        end

        % Callback function: AnalysisDetails, AnalysisDetailsViaContext, 
        % ...and 3 other components
        function onOpenPopupApp(app, event)
            
            customsShipmentsIdx = app.customsShipmentsIndex;
            customsDataIdxs = app.UITable.UserData.visibleRows(app.UITable.Selection);

            switch event.Source
                case {app.AnalysisDetails, app.AnalysisDetailsViaContext}
                    dockAppTag = 'CustomsAnalysisDetails';
                    optionalArgs = {customsShipmentsIdx, customsDataIdxs};

                case app.FilterSetup
                    dockAppTag = 'CustomsFilter';
                    optionalArgs = {customsShipmentsIdx};

                case app.ManageFiles
                    dockAppTag = 'CustomsManageFiles';
                    optionalArgs = {customsShipmentsIdx};

                case app.OpenPopupProject
                    dockAppTag = 'ReportLib';
                    optionalArgs = {};
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
                ui.Dialog(app.UIFigure, 'warning', 'A lista de remessas está vazia.');
                return
            end
            customsShipmentsIdx = app.customsShipmentsIndex;
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

            customsData = app.projectData.customsShipments(customsShipmentsIdx).Data;
            invalidRowIndexes = validateCustomsShipments(app.projectData, customsData);
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
                msgInfo = model.ProjectBase.WARNING_VALIDATIONSRULES.CUSTOMS.entity;

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
            
            msg = model.ProjectBase.WARNING_VALIDATIONSRULES.CUSTOMS.customsShipments;
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
            app.GridLayout.ColumnWidth = {20, '1x', 16, 22, 10, 8, 2};
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
            app.Title.Text = {'<b>Análise e destinação das remessas</b>'; '<font style="color: gray; font-size: 10px;">Analise as remessas de produtos importados e avalie a destinação final sugerida para cada uma.</font>'};

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'REMESSA|CÓDIGO'; 'REMESSA|DESCRIÇÃO'; 'REGRAS|AVALIADAS'; 'REGRA|CATEGORIA'; 'REGRA|DECISÃO SUGERIDA'; 'ESTADO|AMOSTRAGEM'; 'ESTADO|REVISÃO'; 'ESTADO|VISTORIA'; 'AUDITOR|DECISÃO FINAL'; 'AUDITOR|NOTA'};
            app.UITable.ColumnWidth = {110, 'auto', 80, 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = true;
            app.UITable.SelectionType = 'row';
            app.UITable.ColumnEditable = [false false false false false false false false true true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @onTableCellEdited, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Layout.Row = 7;
            app.UITable.Layout.Column = [2 4];
            app.UITable.FontSize = 11;

            % Create NumRows
            app.NumRows = uilabel(app.GridLayout);
            app.NumRows.HorizontalAlignment = 'right';
            app.NumRows.FontSize = 10;
            app.NumRows.FontColor = [0.651 0.651 0.651];
            app.NumRows.Layout.Row = 8;
            app.NumRows.Layout.Column = [2 3];
            app.NumRows.Text = '';

            % Create FilterIconStatus
            app.FilterIconStatus = uiimage(app.GridLayout);
            app.FilterIconStatus.ScaleMethod = 'none';
            app.FilterIconStatus.Enable = 'off';
            app.FilterIconStatus.Visible = 'off';
            app.FilterIconStatus.Layout.Row = 8;
            app.FilterIconStatus.Layout.Column = 4;
            app.FilterIconStatus.HorizontalAlignment = 'right';
            app.FilterIconStatus.ImageSource = 'filter.svg';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, 22, '1x', 22, 22, 5, 22, 22, 22, 5, 22};
            app.Toolbar.RowHeight = {'1x', 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create FilterSetup
            app.FilterSetup = uiimage(app.Toolbar);
            app.FilterSetup.ScaleMethod = 'none';
            app.FilterSetup.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.FilterSetup.Enable = 'off';
            app.FilterSetup.Layout.Row = [1 3];
            app.FilterSetup.Layout.Column = 1;
            app.FilterSetup.ImageSource = 'settings.svg';

            % Create AnalysisDetails
            app.AnalysisDetails = uiimage(app.Toolbar);
            app.AnalysisDetails.ScaleMethod = 'none';
            app.AnalysisDetails.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.AnalysisDetails.Enable = 'off';
            app.AnalysisDetails.Layout.Row = [1 3];
            app.AnalysisDetails.Layout.Column = 2;
            app.AnalysisDetails.ImageSource = 'Variable_edit_16.png';

            % Create ToolbarSeparator1
            app.ToolbarSeparator1 = uiimage(app.Toolbar);
            app.ToolbarSeparator1.ScaleMethod = 'none';
            app.ToolbarSeparator1.Enable = 'off';
            app.ToolbarSeparator1.Layout.Row = [1 3];
            app.ToolbarSeparator1.Layout.Column = 3;
            app.ToolbarSeparator1.VerticalAlignment = 'bottom';
            app.ToolbarSeparator1.ImageSource = 'LineV.svg';

            % Create OpenFile
            app.OpenFile = uiimage(app.Toolbar);
            app.OpenFile.ScaleMethod = 'none';
            app.OpenFile.ImageClickedFcn = createCallbackFcn(app, @onOpenFileButtonClicked, true);
            app.OpenFile.Layout.Row = [1 3];
            app.OpenFile.Layout.Column = 4;
            app.OpenFile.ImageSource = 'Import_16.png';

            % Create ManageFiles
            app.ManageFiles = uiimage(app.Toolbar);
            app.ManageFiles.ScaleMethod = 'none';
            app.ManageFiles.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.ManageFiles.Enable = 'off';
            app.ManageFiles.Layout.Row = [1 3];
            app.ManageFiles.Layout.Column = 5;
            app.ManageFiles.ImageSource = 'files-18px.svg';

            % Create ManageFilesSummary
            app.ManageFilesSummary = uilabel(app.Toolbar);
            app.ManageFilesSummary.FontSize = 10;
            app.ManageFilesSummary.Layout.Row = [1 3];
            app.ManageFilesSummary.Layout.Column = 6;
            app.ManageFilesSummary.Interpreter = 'html';
            app.ManageFilesSummary.Text = '<font style="color: gray;">Nenhum arquivo carregado </font>';

            % Create AnalysisSummary
            app.AnalysisSummary = uiimage(app.Toolbar);
            app.AnalysisSummary.ScaleMethod = 'none';
            app.AnalysisSummary.ImageClickedFcn = createCallbackFcn(app, @onAnalysisSummaryButtonClicked, true);
            app.AnalysisSummary.Enable = 'off';
            app.AnalysisSummary.Layout.Row = [1 3];
            app.AnalysisSummary.Layout.Column = 7;
            app.AnalysisSummary.ImageSource = 'report.svg';

            % Create AnalysisComparison
            app.AnalysisComparison = uiimage(app.Toolbar);
            app.AnalysisComparison.ScaleMethod = 'none';
            app.AnalysisComparison.ImageClickedFcn = createCallbackFcn(app, @onAnalysisComparisonButtonClicked, true);
            app.AnalysisComparison.Enable = 'off';
            app.AnalysisComparison.Layout.Row = [1 3];
            app.AnalysisComparison.Layout.Column = 8;
            app.AnalysisComparison.ImageSource = 'git-compare.svg';

            % Create ToolbarSeparator2
            app.ToolbarSeparator2 = uiimage(app.Toolbar);
            app.ToolbarSeparator2.ScaleMethod = 'none';
            app.ToolbarSeparator2.Enable = 'off';
            app.ToolbarSeparator2.Layout.Row = [1 3];
            app.ToolbarSeparator2.Layout.Column = 9;
            app.ToolbarSeparator2.VerticalAlignment = 'bottom';
            app.ToolbarSeparator2.ImageSource = 'LineV.svg';

            % Create OpenPopupProject
            app.OpenPopupProject = uiimage(app.Toolbar);
            app.OpenPopupProject.ScaleMethod = 'none';
            app.OpenPopupProject.ImageClickedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.OpenPopupProject.Layout.Row = [1 3];
            app.OpenPopupProject.Layout.Column = 10;
            app.OpenPopupProject.ImageSource = 'organization-20px-black.svg';

            % Create GenerateReport
            app.GenerateReport = uiimage(app.Toolbar);
            app.GenerateReport.ScaleMethod = 'none';
            app.GenerateReport.ImageClickedFcn = createCallbackFcn(app, @onGeneralReportButtonClicked, true);
            app.GenerateReport.Enable = 'off';
            app.GenerateReport.Layout.Row = [1 3];
            app.GenerateReport.Layout.Column = 11;
            app.GenerateReport.ImageSource = 'Publish_HTML_16.png';

            % Create UploadFinalFile
            app.UploadFinalFile = uiimage(app.Toolbar);
            app.UploadFinalFile.ScaleMethod = 'none';
            app.UploadFinalFile.ImageClickedFcn = createCallbackFcn(app, @onUploadFinalFileButtonClicked, true);
            app.UploadFinalFile.Enable = 'off';
            app.UploadFinalFile.Layout.Row = [1 3];
            app.UploadFinalFile.Layout.Column = 12;
            app.UploadFinalFile.ImageSource = 'up-20px.png';

            % Create ToolbarSeparator3
            app.ToolbarSeparator3 = uiimage(app.Toolbar);
            app.ToolbarSeparator3.ScaleMethod = 'none';
            app.ToolbarSeparator3.Enable = 'off';
            app.ToolbarSeparator3.Layout.Row = [1 3];
            app.ToolbarSeparator3.Layout.Column = 13;
            app.ToolbarSeparator3.ImageSource = 'LineV.svg';

            % Create ShowDataRules
            app.ShowDataRules = uiimage(app.Toolbar);
            app.ShowDataRules.ImageClickedFcn = createCallbackFcn(app, @onShowRulesImageClicked, true);
            app.ShowDataRules.Layout.Row = [1 3];
            app.ShowDataRules.Layout.Column = 14;
            app.ShowDataRules.ImageSource = 'Info_36.png';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [3 6];
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

            % Create AnalysisDetailsViaContext
            app.AnalysisDetailsViaContext = uimenu(app.ContextMenu);
            app.AnalysisDetailsViaContext.MenuSelectedFcn = createCallbackFcn(app, @onOpenPopupApp, true);
            app.AnalysisDetailsViaContext.Enable = 'off';
            app.AnalysisDetailsViaContext.Text = '✏️ Editar';
            
            % Assign app.ContextMenu
            app.UITable.ContextMenu = app.ContextMenu;

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
