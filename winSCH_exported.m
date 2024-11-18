classdef winSCH_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        menu_Grid                       matlab.ui.container.GridLayout
        dockModule_Undock               matlab.ui.control.Image
        dockModule_Close                matlab.ui.control.Image
        menu_Separator2                 matlab.ui.control.Image
        AppInfo                         matlab.ui.control.Image
        FigurePosition                  matlab.ui.control.Image
        DataHubLamp                     matlab.ui.control.Lamp
        jsBackDoor                      matlab.ui.control.HTML
        menu_Button3                    matlab.ui.control.StateButton
        menu_Button2                    matlab.ui.control.StateButton
        menu_Button1                    matlab.ui.control.StateButton
        popupContainerGrid              matlab.ui.container.GridLayout
        SplashScreen                    matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        Tab1_Search                     matlab.ui.container.Tab
        GridLayout3                     matlab.ui.container.GridLayout
        file_toolGrid                   matlab.ui.container.GridLayout
        search_ExportTable              matlab.ui.control.Image
        search_PanelVisibility          matlab.ui.control.Image
        search_mainGrid                 matlab.ui.container.GridLayout
        search_Control                  matlab.ui.container.GridLayout
        search_ControlMenu              matlab.ui.container.GridLayout
        search_menuBtn2Grid             matlab.ui.container.GridLayout
        search_menuBtn2Icon             matlab.ui.control.Image
        search_menuBtn2Label            matlab.ui.control.Label
        search_menuBtn1Grid             matlab.ui.container.GridLayout
        search_menuBtn1Icon             matlab.ui.control.Image
        search_menuBtn1Label            matlab.ui.control.Label
        search_menuUnderline            matlab.ui.control.Image
        search_ControlTabGroup          matlab.ui.container.TabGroup
        search_Tab1                     matlab.ui.container.Tab
        search_Tab1Grid                 matlab.ui.container.GridLayout
        search_ToolbarAnnotation        matlab.ui.control.Image
        search_ListOfProducts           matlab.ui.control.ListBox
        search_ListOfProductsAdd        matlab.ui.control.Image
        search_ListOfProductsLabel      matlab.ui.control.Label
        search_WordCloudRefreshGrid     matlab.ui.container.GridLayout
        search_WordCloudRefresh         matlab.ui.control.Image
        search_WordCloudPanel           matlab.ui.container.Panel
        search_AnnotationPanel          matlab.ui.container.Panel
        search_AnnotationGrid           matlab.ui.container.GridLayout
        search_AnnotationPanelAdd       matlab.ui.control.Image
        search_AnnotationValue          matlab.ui.control.TextArea
        search_AnnotationValueLabel     matlab.ui.control.Label
        search_AnnotationAttribute      matlab.ui.control.DropDown
        search_AnnotationAttributeLabel  matlab.ui.control.Label
        search_AnnotationPanelLabel     matlab.ui.control.Label
        search_ProductInfoPanel         matlab.ui.container.Panel
        search_ProductInfoGrid          matlab.ui.container.GridLayout
        search_ProductInfo              matlab.ui.control.HTML
        search_ToolbarListOfProducts    matlab.ui.control.Image
        search_ToolbarWordCloud         matlab.ui.control.Image
        search_ProductInfoLabel         matlab.ui.control.Label
        search_Tab2                     matlab.ui.container.Tab
        search_Tab2Grid                 matlab.ui.container.GridLayout
        search_SecundaryListOfFilters   matlab.ui.control.ListBox
        search_SecundaryAddFilter       matlab.ui.control.Image
        search_SecundaryPanel           matlab.ui.container.Panel
        search_SecundaryGrid            matlab.ui.container.GridLayout
        search_SecundaryTextListValue   matlab.ui.control.DropDown
        search_SecundaryTextFreeValue   matlab.ui.control.EditField
        search_SecundaryDateTime2       matlab.ui.control.EditField
        search_SecundaryDateTimeSeparator  matlab.ui.control.Label
        search_SecundaryDateTime1       matlab.ui.control.EditField
        search_SecundaryOperation       matlab.ui.control.DropDown
        search_SecundaryColumn          matlab.ui.control.DropDown
        search_SecundaryPanelLabel      matlab.ui.control.Label
        search_PrimaryPanel             matlab.ui.container.ButtonGroup
        search_PrimaryOption3           matlab.ui.control.RadioButton
        search_PrimaryOption2           matlab.ui.control.RadioButton
        search_PrimaryOption1           matlab.ui.control.RadioButton
        search_PrimaryPanelLabel        matlab.ui.control.Label
        search_Document                 matlab.ui.container.GridLayout
        search_Suggestions              matlab.ui.control.ListBox
        search_nRows                    matlab.ui.control.Label
        search_Metadata                 matlab.ui.control.Label
        search_entryPointPanel          matlab.ui.container.Panel
        search_entryPointGrid           matlab.ui.container.GridLayout
        search_entryPointImage          matlab.ui.control.Image
        search_entryPoint               matlab.ui.control.EditField
        search_Table                    matlab.ui.control.Table
        Tab2_Report                     matlab.ui.container.Tab
        GridLayout4                     matlab.ui.container.GridLayout
        report_mainGrid                 matlab.ui.container.GridLayout
        report_Control                  matlab.ui.container.GridLayout
        report_ControlMenu              matlab.ui.container.GridLayout
        report_menuBtn3Grid             matlab.ui.container.GridLayout
        report_menuBtn3Icon             matlab.ui.control.Image
        report_menuBtn3Label            matlab.ui.control.Label
        report_menuBtn2Grid             matlab.ui.container.GridLayout
        report_menuBtn2Icon             matlab.ui.control.Image
        report_menuBtn2Label            matlab.ui.control.Label
        report_menuBtn1Grid             matlab.ui.container.GridLayout
        report_menuBtn1Icon             matlab.ui.control.Image
        report_menuBtn1Label            matlab.ui.control.Label
        report_menuUnderline            matlab.ui.control.Image
        report_ControlTabGroup          matlab.ui.container.TabGroup
        report_Tab1                     matlab.ui.container.Tab
        report_Tab1Grid                 matlab.ui.container.GridLayout
        report_ToolbarEditOrAdd         matlab.ui.control.Image
        report_EditableInfoPanel        matlab.ui.container.Panel
        report_EditableInfoGrid         matlab.ui.container.GridLayout
        report_Corrigible               matlab.ui.control.DropDown
        report_CorrigibleLabel          matlab.ui.control.Label
        ImportadorEditField             matlab.ui.control.EditField
        ImportadorEditFieldLabel        matlab.ui.control.Label
        report_EditOrAddButton          matlab.ui.control.Image
        report_Notes                    matlab.ui.control.TextArea
        report_NotesLabel               matlab.ui.control.Label
        report_Violation                matlab.ui.control.DropDown
        report_ViolationLabel           matlab.ui.control.Label
        report_Situation                matlab.ui.control.DropDown
        report_SituationLabel           matlab.ui.control.Label
        report_IDAduana                 matlab.ui.control.EditField
        report_IDAduanaLabel            matlab.ui.control.Label
        report_nHom                     matlab.ui.control.EditField
        report_nHomLabel                matlab.ui.control.Label
        report_productSituationPanel    matlab.ui.container.ButtonGroup
        report_productSituation2        matlab.ui.control.RadioButton
        report_productSituation1        matlab.ui.control.RadioButton
        report_EditableInfoLabel        matlab.ui.control.Label
        report_ProductInfoPanel         matlab.ui.container.Panel
        report_ProductInfoGrid          matlab.ui.container.GridLayout
        report_ProductInfo              matlab.ui.control.HTML
        report_ProductInfoLabel         matlab.ui.control.Label
        report_Tab2                     matlab.ui.container.Tab
        report_Tab2Grid                 matlab.ui.container.GridLayout
        report_ProjectWarnIcon          matlab.ui.control.Image
        report_IssuePanel               matlab.ui.container.Panel
        report_IssueGrid                matlab.ui.container.GridLayout
        report_DocumentPanel            matlab.ui.container.Panel
        report_DocumentGrid             matlab.ui.container.GridLayout
        report_Version                  matlab.ui.control.DropDown
        report_VersionLabel             matlab.ui.control.Label
        report_ModelName                matlab.ui.control.DropDown
        report_ModelNameLabel           matlab.ui.control.Label
        report_DocumentLabel            matlab.ui.control.Label
        report_EntityPanel              matlab.ui.container.Panel
        report_EntityGrid               matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        report_EntityType               matlab.ui.control.DropDown
        report_EntityTypeLabel          matlab.ui.control.Label
        report_EntityID                 matlab.ui.control.EditField
        report_EntityIDLabel            matlab.ui.control.Label
        report_Entity                   matlab.ui.control.EditField
        report_EntityLabel              matlab.ui.control.Label
        report_EntityPanelLabel         matlab.ui.control.Label
        report_Issue                    matlab.ui.control.NumericEditField
        report_IssueLabel               matlab.ui.control.Label
        report_IssuePanelLabel          matlab.ui.control.Label
        report_ProjectPanel             matlab.ui.container.Panel
        report_ProjectGrid              matlab.ui.container.GridLayout
        report_ProjectName              matlab.ui.control.TextArea
        report_ProjectSave              matlab.ui.control.Image
        report_ProjectOpen              matlab.ui.control.Image
        report_ProjectNew               matlab.ui.control.Image
        report_ProjectNameLabel         matlab.ui.control.Label
        report_ProjectLabel             matlab.ui.control.Label
        report_Tab3                     matlab.ui.container.Tab
        report_Tab3Grid                 matlab.ui.container.GridLayout
        report_FiscalizaPanel           matlab.ui.container.Panel
        report_FiscalizaGrid            matlab.ui.container.GridLayout
        report_FiscalizaIcon            matlab.ui.control.Image
        report_FiscalizaRefresh         matlab.ui.control.Image
        report_Fiscaliza_PanelLabel     matlab.ui.control.Label
        report_Document                 matlab.ui.container.GridLayout
        report_Table                    matlab.ui.control.Table
        report_nRows                    matlab.ui.control.Label
        report_TableLabel               matlab.ui.control.Label
        file_toolGrid_2                 matlab.ui.container.GridLayout
        report_FiscalizaUpdateImage     matlab.ui.control.Image
        report_FiscalizaAutoFillImage   matlab.ui.control.Image
        report_ReportGeneration         matlab.ui.control.Image
        report_ShowCells2Edit           matlab.ui.control.Image
        report_PanelVisibility          matlab.ui.control.Image
        Tab3_Config                     matlab.ui.container.Tab
        GridLayout5                     matlab.ui.container.GridLayout
        config_mainGrid                 matlab.ui.container.GridLayout
        config_Option3Grid              matlab.ui.container.GridLayout
        config_DefaultIssueValuesPanel  matlab.ui.container.Panel
        config_DefaultIssueValuesGrid   matlab.ui.container.GridLayout
        config_ServicoInspecao          matlab.ui.container.CheckBoxTree
        config_ServicoInspecaoLabel     matlab.ui.control.Label
        config_MotivoLAI                matlab.ui.container.CheckBoxTree
        config_MotivoLAILabel           matlab.ui.control.Label
        config_TipoPLAI                 matlab.ui.control.DropDown
        config_TipoPLAILabel            matlab.ui.control.Label
        config_GerarPLAI                matlab.ui.control.DropDown
        config_GerarPLAILabel           matlab.ui.control.Label
        config_CadastroSTEL             matlab.ui.control.DropDown
        config_CadastroSTELLabel        matlab.ui.control.Label
        config_DefaultIssueValuesLock   matlab.ui.control.Image
        config_DefaultIssueValuesLabel  matlab.ui.control.Label
        config_FiscalizaVersion         matlab.ui.container.ButtonGroup
        config_FiscalizaHM              matlab.ui.control.RadioButton
        config_FiscalizaPD              matlab.ui.control.RadioButton
        config_FiscalizaVersionLabel    matlab.ui.control.Label
        config_Option2Grid              matlab.ui.container.GridLayout
        Image2                          matlab.ui.control.Image
        config_SelectedTableColumns     matlab.ui.container.CheckBoxTree
        config_SelectedTableColumnsLabel  matlab.ui.control.Label
        config_MiscelaneousPanel2       matlab.ui.container.Panel
        config_MiscelaneousGrid2        matlab.ui.container.GridLayout
        config_WordCloudColumn          matlab.ui.control.DropDown
        config_WordCloudColumnLabel     matlab.ui.control.Label
        config_WordCloudAlgorithm       matlab.ui.control.DropDown
        config_WordCloudAlgorithmLabel  matlab.ui.control.Label
        config_MiscelaneousLabel2       matlab.ui.control.Label
        config_MiscelaneousPanel1       matlab.ui.container.Panel
        config_MiscelaneousGrid1        matlab.ui.container.GridLayout
        config_nMinWords                matlab.ui.control.DropDown
        config_nMinWordsLabel           matlab.ui.control.Label
        config_nMinCharacters           matlab.ui.control.Spinner
        config_nMinCharactersLabel      matlab.ui.control.Label
        config_MiscelaneousLabel1       matlab.ui.control.Label
        config_SearchModePanel          matlab.ui.container.ButtonGroup
        config_SearchModeListOfWords    matlab.ui.control.RadioButton
        config_SearchModeTokenSuggestion  matlab.ui.control.RadioButton
        config_SearchModeLabel          matlab.ui.control.Label
        config_Option1Grid              matlab.ui.container.GridLayout
        config_FolderMapPanel           matlab.ui.container.Panel
        config_FolderMapGrid            matlab.ui.container.GridLayout
        config_Folder_tempPath          matlab.ui.control.EditField
        config_Folder_tempPathLabel     matlab.ui.control.Label
        config_Folder_userPathButton    matlab.ui.control.Image
        config_Folder_userPath          matlab.ui.control.DropDown
        config_Folder_userPathLabel     matlab.ui.control.Label
        config_Folder_pythonPathButton  matlab.ui.control.Image
        config_Folder_pythonPath        matlab.ui.control.EditField
        config_Folder_pythonPathLabel   matlab.ui.control.Label
        config_Folder_DataHubPOSTButton  matlab.ui.control.Image
        config_Folder_DataHubPOST       matlab.ui.control.EditField
        config_Folder_DataHubPOSTLabel  matlab.ui.control.Label
        config_Folder_DataHubGETButton  matlab.ui.control.Image
        config_Folder_DataHubGET        matlab.ui.control.EditField
        config_Folder_DataHubGETLabel   matlab.ui.control.Label
        config_FolderMapLabel           matlab.ui.control.Label
        config_Control                  matlab.ui.container.GridLayout
        Panel                           matlab.ui.container.Panel
        GridLayout2                     matlab.ui.container.GridLayout
        config_ButtonGroup              matlab.ui.container.ButtonGroup
        config_Option_Folder            matlab.ui.control.RadioButton
        config_Option_Fiscaliza         matlab.ui.control.RadioButton
        config_Option_Search            matlab.ui.control.RadioButton
        config_Label                    matlab.ui.control.Label
        config_ControlMenu              matlab.ui.container.GridLayout
        config_menuBtn1Grid             matlab.ui.container.GridLayout
        config_menuBtn1Icon             matlab.ui.control.Image
        config_menuBtn1Label            matlab.ui.control.Label
        config_menuUnderline            matlab.ui.control.Image
        file_toolGrid_3                 matlab.ui.container.GridLayout
        config_PanelVisibility          matlab.ui.control.Image
        ContextMenu                     matlab.ui.container.ContextMenu
        ContextMenu_DeleteFcn           matlab.ui.container.Menu
    end

    
    properties (Access = public)
        %-----------------------------------------------------------------%
        % PROPRIEDADES COMUNS A TODOS OS APPS
        %-----------------------------------------------------------------%
        General
        General_I
        rootFolder

        % Essa propriedade registra o tipo de execução da aplicação, podendo
        % ser: 'built-in', 'desktopApp' ou 'webApp'.
        executionMode        

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj_startup

        % O MATLAB não renderiza alguns dos componentes de abas (do TabGroup) 
        % não visíveis. E a customização de componentes, usando a lib ccTools, 
        % somente é possível após a sua renderização. Controla-se a aplicação 
        % da customizaçao por meio dessa propriedade jsBackDoorFlag.
        jsBackDoorFlag = {[true, true],       ...
                          [true, true, true], ...
                          true};

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog

        % Objeto que possibilita integração com o FISCALIZA, consumindo lib
        % escrita em Python (fiscaliza).
        fiscalizaObj

        %-----------------------------------------------------------------%
        % PROPRIEDADES ESPECÍFICAS
        %-----------------------------------------------------------------%
        projectData

        rawDataTable
        releasedData
        cacheData

        annotationTable
        
        previousSearch   = ''
        previousItemData = 0
        filteringObj     = tableFiltering
        wordCloudObj
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor.HTMLSource           = ccTools.fcn.jsBackDoorHTMLSource();
            app.jsBackDoor.HTMLEventReceivedFcn = @(~, evt)jsBackDoor_Listener(app, evt);
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Listener(app, event)
            % Foi adicionado o evento JS-keydown das teclas ["ArrowUp", "ArrowDown", "Enter", "Escape"]
            % aos componentes app.search_entryPoint (matlab.ui.control.EditField) e app.search_Suggestions
            % (matlab.ui.control.ListBox) usando o JS-backdoor app.jsBackDoor (matlab.ui.control.HTML).
    
            % Em relação aos callbacks configuráveis no próprio MATLAB:
            % - matlab.ui.control.EditField 
            %   (a) Possui os eventos "ValueChangedFcn" e "ValueChangingFcn".
            %   (b) Não responde à tecla "Escape".
            %   (c) Responde às teclas "ArrowUp" e "ArrowDown", controlando a posição 
            %       do cursor (início e fim, respectivamente)
            %   (d) Reponde à tecla "Enter", executando "ValueChangingFcn" e "ValueChangedFcn", 
            %       nesse ordem.
    
            % - matlab.ui.control.ListBox
            %   (a) possui os eventos "ValueChangedFcn", "ClickedFcn" e "DoubleClickedFcn".
            %   (b) Responde às teclas "ArrowUp" e "ArrowDown", executando "ValueChangedFcn", 
            %       desde que não estejam selecionadas as suas "bordas" (valor 1 e "ArrowUp", 
            %       ou valor n e "ArrowDown", por exemplo).
    
            % Num eventual clique de uma das teclas ["ArrowUp", "ArrowDown", "Enter", "Escape"],
            % o trigger do evento JS-keydown ocorre antes do trigger dos eventos padrões dos 
            % componentes matlab.ui.control.EditField e matlab.ui.control.ListBox.
    
            % Isso é bom, mas ruim por criar uma complexidade extra! :(
    
            % Quando altero o conteúdo de app.search_entryPoint, sem alterar o seu foco, será executado 
            % o evento "ValueChangingFcn". Se pressiono a tecla "Enter", será executada essa função 
            % (jsBackDoor_Listener) antes de atualizar a propriedade "Value" do app.search_entryPoint.
    
            % Por conta disso, é essencial inserir waitfor(app.search_entryPoint, 'Value')
            % Isso é conseguido alterando o objeto em foco, de app.search_entryPoint para app.jsBackDoor
            % Ao fazer isso, o MATLAB "executa" a seguinte operação:
            % app.search_entryPoint.Value = app.search_entryPoint.ChangingValue

            switch event.HTMLEventName
                case 'app.search_entryPoint'
                    focus(app.jsBackDoor)

                    switch event.HTMLEventData
                        case {'Escape', 'Tab'}
                            search_EntryPoint_CheckIfNeedsUpdate(app)
                            if numel(app.search_entryPoint.Value) < app.config_nMinCharacters.Value
                                search_EntryPoint_InitialValue(app)
                            end

                            if strcmp(event.HTMLEventData, 'Tab') && app.search_entryPointImage.Enable
                                focus(app.search_entryPointImage)
                            end

                            pause(.050)
                            set(app.search_Suggestions, Visible=0, Value={})

                        otherwise
                            search_EntryPoint_CheckIfNeedsUpdate(app)
                            if numel(app.search_entryPoint.Value) < app.config_nMinCharacters.Value
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('componentName', 'app.search_entryPoint', 'componentDataTag', app.search_entryPoint.UserData));

                            else
                                switch event.HTMLEventData
                                    case 'ArrowDown'
                                        if app.config_SearchModeTokenSuggestion.Value
                                            app.previousItemData = 1;
                
                                            set(app.search_Suggestions, 'Visible', 1, 'Value', 1)
                                            scroll(app.search_Suggestions, "top")
                                            focus(app.search_Suggestions)
                                        end
                    
                                    case 'ArrowUp'
                                        if app.config_SearchModeTokenSuggestion.Value
                                            nMaxValues = numel(app.search_Suggestions.Items);
    
                                            app.previousItemData = nMaxValues;            
                                            set(app.search_Suggestions, 'Visible', 1, 'Value', nMaxValues)
                                            scroll(app.search_Suggestions, "bottom")
                                            focus(app.search_Suggestions)
                                        end

                                    case 'Enter'                                      
                                        search_EntryPoint_ImageClicked(app)

                                        pause(.050)
                                        set(app.search_Suggestions, Visible=0, Value={})
                                end
                            end
                    end

                %---------------------------------------------------------%
                case 'app.search_Suggestions'
                    switch event.HTMLEventData
                        case 'ArrowDown'
                            nMaxValues = numel(app.search_Suggestions.Items);

                            if (app.previousItemData == nMaxValues) && (app.search_Suggestions.Value == nMaxValues)
                                app.previousItemData = 0;
                                
                                set(app.search_Suggestions, Visible=0, Value={})
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('componentName', 'app.search_entryPoint', 'componentDataTag', app.search_entryPoint.UserData));
                            else
                                if isnumeric(app.search_Suggestions.Value)
                                    app.previousItemData = app.search_Suggestions.Value;
                                else
                                    app.previousItemData = 0;
                                end
                            end
        
                        case 'ArrowUp'
                            if (app.previousItemData == 1) && (app.search_Suggestions.Value == 1)
                                app.previousItemData = 0;

                                set(app.search_Suggestions, Visible=0, Value={})
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('componentName', 'app.search_entryPoint', 'componentDataTag', app.search_entryPoint.UserData));
                            else
                                if isnumeric(app.search_Suggestions.Value)
                                    app.previousItemData = app.search_Suggestions.Value;
                                else
                                    app.previousItemData = 0;
                                end
                            end
        
                        case {'Enter', 'Tab'}
                            if isnumeric(app.search_Suggestions.Value)
                                eventValue = app.search_Suggestions.Items{app.search_Suggestions.Value};
    
                                app.search_entryPoint.Value = eventValue;
                                search_SuggestionAlgorithm(app, eventValue, false)
                                
                                sendEventToHTMLSource(app.jsBackDoor, 'setFocus', struct('componentName', 'app.search_entryPoint', 'componentDataTag', app.search_entryPoint.UserData));
                            end

                        case 'Escape'
                            set(app.search_Suggestions, Visible=0, Value={})
                    end

                %---------------------------------------------------------%
                case 'credentialDialog'
                    report_FiscalizaConnect(app, event.HTMLEventData, 'OpenConnection')

                %---------------------------------------------------------%
                case 'BackgroundColorTurnedInvisible'
                    if isvalid(app.popupContainerGrid)
                        delete(app.popupContainerGrid)
                    end
            end
            drawnow
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            % O menu gráfico controla, programaticamente, qual das abas de
            % app.TabGroup estará visível. Na versão do app em 19/07/2024
            % duas dessas abas possuíam dentre os seus componentes um próprio
            % "uitabgroup".
            % - Aba "SEARCH": app.search_ControlTabGroup
            % - Aba "REPORT": app.report_ControlTabGroup

            % Lembrando que o MATLAB renderiza em tela apenas as abas visíveis.
            % Por isso as customizações de abas e suas subabas somente é possível 
            % após a renderização da aba.

            switch tabIndex
                case 0 % STARTUP
                    % Cria um ProgressDialog...
                    app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);

                    % .mw-default-header-cell {
                    %    font-size: 10px; white-space: pre-wrap; margin-bottom: 5px;       /* UITABLE TABLE HEADER                                      */ 
                    % }
                    %
                    % .mw-theme-light {
                    %    --mw-backgroundColor-dataWidget-selected: rgb(180 222 255 / 45%); /* UITABLE BACKGROUND SELECTED CELL (WITHOUT FOCUS)          */
                    %    --mw-backgroundColor-selected: rgb(180 222 255 / 45%);            /* UILISTBOX BACKGROUND SELECTED CELL (WITHOUT FOCUS)        */
                    %    --mw-backgroundColor-selectedFocus: rgb(180 222 255 / 45%);       /* UILISTBOX BACKGROUND SELECTED CELL                        */
                    %    --mw-borderColor-focus: #7d7d7d;                                  /* UIBUTTON, UITABLE, UILISTBOX, UIIMAGE BORDER COLOR        */
                    %    --mw-borderColor-primary: var(--mw-color-gray600);                /* UIBUTTON, UITABLE, UILISTBOX BORDER COLOR (WITHOUT FOCUS) */
                    % }
                    %
                    % TABGROUP: 
                    % (a) Background: --mw-backgroundColor-tab e --mw-backgroundColor-primary
                    % (b) Border: --tabButton-border-color e --tabContainer-border-color

                    sendEventToHTMLSource(app.jsBackDoor, 'htmlClassCustomization', struct('className',        'body',                           ...
                                                                                           'classAttributes', ['--tabButton-border-color: #fff;' ...
                                                                                                               '--tabContainer-border-color: #fff;']));

                    sendEventToHTMLSource(app.jsBackDoor, 'htmlClassCustomization', struct('className',        '.mw-theme-light',                                                   ...
                                                                                           'classAttributes', ['--mw-backgroundColor-dataWidget-selected: rgb(180 222 255 / 45%); ' ...
                                                                                                               '--mw-backgroundColor-selected: rgb(180 222 255 / 45%); '            ...
                                                                                                               '--mw-backgroundColor-selectedFocus: rgb(180 222 255 / 45%);'        ...
                                                                                                               '--mw-backgroundColor-tab: #fff;']));

                    sendEventToHTMLSource(app.jsBackDoor, 'htmlClassCustomization', struct('className',        '.mw-default-header-cell', ...
                                                                                           'classAttributes',  'font-size: 10px; white-space: pre-wrap; margin-bottom: 5px;'));
                    
                    ccTools.compCustomizationV2(app.jsBackDoor, app.popupContainerGrid, 'backgroundColor', 'rgba(255,255,255,0.65')

                case 1 % SEARCH
                    if any(app.jsBackDoorFlag{tabIndex})
                        subIndex = find(app.search_ControlTabGroup.Children == app.search_ControlTabGroup.SelectedTab, 1);
                        app.jsBackDoorFlag{tabIndex}(subIndex) = false;

                        switch subIndex
                            case 1                    
                                % Aplica customizações estéticas ao(s) componente(s).
                                ccTools.compCustomizationV2(app.jsBackDoor, app.search_entryPoint,           'borderWidth', '0px')
                                ccTools.compCustomizationV2(app.jsBackDoor, app.search_ControlTabGroup,      'transparentHeader', 'transparent')
                                ccTools.compCustomizationV2(app.jsBackDoor, app.search_WordCloudRefreshGrid, 'backgroundColor', 'transparent')
                                                                                                
                                % Cria keydown listeners, em JS, para os componentes descritos
                                % em objList.
                                objList = {app.search_entryPoint, app.search_Suggestions};
                                for ii = 1:numel(objList)
                                    objList{ii}.UserData = struct(objList{ii}).Controller.ViewModel.Id;
                                end
                                sendEventToHTMLSource(app.jsBackDoor, "addKeyDownListener", struct('componentName', 'app.search_entryPoint',  'componentDataTag', app.search_entryPoint.UserData,  'keyEvents', ["ArrowUp", "ArrowDown", "Enter", "Escape", "Tab"]))
                                sendEventToHTMLSource(app.jsBackDoor, "addKeyDownListener", struct('componentName', 'app.search_Suggestions', 'componentDataTag', app.search_Suggestions.UserData, 'keyEvents', ["ArrowUp", "ArrowDown", "Enter", "Escape", "Tab"]))
                                drawnow

                            case 2
                                % ...
                        end
                    end

                case 2 % REPORT
                    if any(app.jsBackDoorFlag{tabIndex})
                        subIndex = find(app.report_ControlTabGroup.Children == app.report_ControlTabGroup.SelectedTab, 1);
                        app.jsBackDoorFlag{tabIndex}(subIndex) = false;

                        switch subIndex
                            case 1
                                % Aplica customizações estéticas ao(s) componente(s).
                                ccTools.compCustomizationV2(app.jsBackDoor, app.report_ControlTabGroup, 'transparentHeader', 'transparent')
                                ccTools.compCustomizationV2(app.jsBackDoor, app.report_Notes,           'textAlign', 'justify')

                            case 2
                                ccTools.compCustomizationV2(app.jsBackDoor, app.report_ProjectName,     'textAlign', 'justify')
                                
                            case 3
                                % ...
                        end                        
                    end

                case 3 % CONFIG
                    if app.jsBackDoorFlag{tabIndex}
                        app.jsBackDoorFlag{tabIndex} = false;
                        % ...
                    end
            end
        end
    end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        function startup_timerCreation(app)            
            % A criação desse timer tem como objetivo garantir uma renderização 
            % mais rápida dos componentes principais da GUI, possibilitando a 
            % visualização da sua tela inicial pelo usuário. Trata-se de aspecto 
            % essencial quando o app é compilado como webapp.

            app.timerObj_startup = timer("ExecutionMode", "fixedSpacing", ...
                                         "StartDelay",    1.5,            ...
                                         "Period",        .1,             ...
                                         "TimerFcn",      @(~,~)app.startup_timerFcn);
            start(app.timerObj_startup)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app)
            if ccTools.fcn.UIFigureRenderStatus(app.UIFigure)
                stop(app.timerObj_startup)
                drawnow

                app.executionMode = appUtil.ExecutionMode(app.UIFigure);
                switch app.executionMode
                    case 'webApp'
                        % ...
                    otherwise
                        % Configura o tamanho mínimo da janela.
                        app.FigurePosition.Visible = 1;
                        appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
                end

                appName        = class.Constants.appName;
                MFilePath      = fileparts(mfilename('fullpath'));
                app.rootFolder = appUtil.RootFolder(appName, MFilePath);
                
                % Customiza as aspectos estéticos de alguns dos componentes da GUI 
                % (diretamente em JS).
                jsBackDoor_Customizations(app, 0)
                jsBackDoor_Customizations(app, 1)

                % Leitura do arquivo "GeneralSettings.json".
                startup_ConfigFileRead(app)
                startup_AppProperties(app)
                startup_GUIComponents(app)

                % Inicia módulo de operação paralelo...
                parpoolCheck()

                % Para criação de arquivos temporários, cria-se uma pasta da 
                % sessão.
                tempDir = tempname;
                mkdir(tempDir)
                app.General_I.fileFolder.tempPath = tempDir;

                switch app.executionMode
                    case 'webApp'
                        % Força a exclusão do SplashScreen do MATLAB WebDesigner.
                        sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");

                        % Bloqueia a troca do gerador do WordCloud, restringindo à biblioteca 
                        % em JS D3.
                        app.config_WordCloudAlgorithm.Enable = 0;
    
                        % Webapp também não suporta outras janelas, de forma que os 
                        % módulos auxiliares devem ser abertos na própria janela
                        % do appAnalise.
                        app.dockModule_Undock.Visible     = 0;

                        app.General_I.operationMode.Debug = false;
                        app.General_I.operationMode.Dock  = true;
                        
                        % A pasta do usuário não é configurável, mas obtida por 
                        % meio de chamada a uiputfile. 
                        app.General_I.fileFolder.userPath = tempDir;
    
                    otherwise    
                        % Resgata a pasta de trabalho do usuário (configurável).
                        userPaths = appUtil.UserPaths(app.General_I.fileFolder.userPath);
                        app.General_I.fileFolder.userPath = userPaths{end};

                        switch app.executionMode
                            case 'desktopStandaloneApp'
                                app.General_I.operationMode.Debug = false;
                            case 'MATLABEnvironment'
                                app.General_I.operationMode.Debug = true;
                        end
                end
                app.General.operationMode = app.General_I.operationMode;
                app.General.fileFolder    = app.General_I.fileFolder;

                app.config_Folder_userPath.Value = app.General.fileFolder.userPath;
                app.config_Folder_tempPath.Value = app.General.fileFolder.tempPath;

                % Diminui a opacidade do SplashScreen. Esse processo dura
                % cerca de 1250 ms. São 50 iterações em que em cada uma 
                % delas a opacidade da imagem diminuir em 0.02. Entre cada 
                % iteração, 25 ms. E executa drawnow, forçando a renderização 
                % em tela dos componentes.
                sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
                set(findobj(app.menu_Grid.Children, '-not', 'Type', 'uihtml'), 'Enable', 1)
                drawnow

                % Força a exclusão do SplashScreen.
                app.TabGroup.Visible = 1;
                if isvalid(app.popupContainerGrid)
                    pause(1)
                    delete(app.popupContainerGrid)
                end
            end
        end        

        %-----------------------------------------------------------------%
        function startup_ConfigFileRead(app)
            % Verifica se a pasta de configuração já foi criada e se lá tem 
            % o arquivo de configuração "GeneralSettings.json".
            %
            % Compara-se a versão dos arquivos hospedados nas pastas local e 
            % de configuração.
            % - Local:  fullfile(ctfroot, 'Settings')
            % - Config: fullfile(getenv('PROGRAMDATA'), 'ANATEL', 'SCH') (Windows)
            %
            % Caso o arquivo hospedado na pasta local possua uma versão mais 
            % recente, substitui-se o hospedado na pasta de configuração,
            % mantendo, contudo, os mapeamentos de pastas (usuário, Python,
            % DataHub_GETm DataHub_POST etc).
            %
            % Isso é especialmente importante para os webapps, cujo arquivo
            % executado pelo MATLAB WEBSERVER não é um executável, com seu
            % conjunto de subpastas e arquivos de suporte, mas um CTF.
            %
            % Logo, qualquer alteração num arquivo relacionado a um CTF será 
            % perdida quando for encerrada a sessão do webapp.

            % app.General
            [app.General_I, msgWarning] = appUtil.generalSettingsLoad(class.Constants.appName, app.rootFolder, {'Annotation.xlsx'});
            app.General_I.SCHDataInfo   = struct2table(app.General_I.SCHDataInfo);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'error', msgWarning);
            end
            app.General = app.General_I;
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.projectData = projectLib(app, app.General.typeOfProduct);
            startup_mainVariables(app)            
        end

        %-----------------------------------------------------------------%
        function startup_mainVariables(app)
            DataHub_GET     = app.General.fileFolder.DataHub_GET;
            SCHDataFileName = app.General.fileName.SCHData;
            SCHDataFullFile = fullfile(DataHub_GET, SCHDataFileName);

            try
                if ~isfolder(DataHub_GET)
                    error('Pendente mapear a pasta "SCH" do repositório "DataHub - GET".')
                elseif isfolder(DataHub_GET) && ~isfile(SCHDataFullFile)
                    error('Apesar de mapeada a pasta "SCH" do repositório "DataHub - GET", não foi encontrado o arquivo %s. Favor relatar isso ao Escritório de inovação da SFI.', SCHDataFileName)
                end
                startup_ReadSCHDataFile(app, SCHDataFullFile)
                
            catch ME
                SCHDataFullFile = fullfile(app.rootFolder, 'DataBase', SCHDataFileName);
                startup_ReadSCHDataFile(app, SCHDataFullFile)

                msgWarning = ME.message;
            end

            app.annotationTable = readFile.Annotation(app.rootFolder, DataHub_GET);

            if exist('msgWarning', 'var')
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end
        end

        %-----------------------------------------------------------------%
        function startup_ReadSCHDataFile(app, SCHDataFullFile)
            [app.rawDataTable, ...
             app.releasedData, ...
             app.cacheData] = readFile.SCHData(SCHDataFullFile);
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            % Salva na propriedade "UserData" as opções de ícone e o índice 
            % da aba, simplificando os ajustes decorrentes de uma alteração...
            app.menu_Button1.UserData                 = struct('iconOptions', {{'Zoom_32White.png',      'Zoom_32Yellow.png'}},      'tabGroup', 1);
            app.menu_Button2.UserData                 = struct('iconOptions', {{'Detection_32White.png', 'Detection_32Yellow.png'}}, 'tabGroup', 2);
            app.menu_Button3.UserData                 = struct('iconOptions', {{'Settings_36White.png',  'Settings_36Yellow.png'}},  'tabGroup', 3);

            app.search_ToolbarAnnotation.UserData     = struct('iconOptions', {{'Edit_18x18Gray.png',    'Edit_18x18Blue.png'}});
            app.search_ToolbarWordCloud.UserData      = struct('iconOptions', {{'Cloud_32x32Gray.png',   'Cloud_32x32Blue.png'}});
            app.search_ToolbarListOfProducts.UserData = struct('iconOptions', {{'Box_32x32Gray.png',     'Box_32x32Blue.png'}});

            app.report_ToolbarEditOrAdd.UserData      = struct('iconOptions', {{'Edit_18x18Gray.png',    'Edit_18x18Blue.png'}});
            app.report_EditOrAddButton.UserData       = struct('iconOptions', {{'Edit_36.png',           'NewFile_36.png'}});

            % Inicialização da propriedade "UserData" da tabela.
            app.search_Table.UserData = struct('primaryIndex', [], 'secundaryIndex', [], 'cacheColumns', {{}});

            % Inicialização dos painéis de metadados do registro selecionado 
            % em uma das tabelas.
            app.search_ProductInfo.UserData = struct('selectedRow', [], 'showedHom', '');
            app.report_ProductInfo.UserData = struct('selectedRow', [], 'showedHom', '');

            if strcmp(app.executionMode, 'webApp')
                % Webapps não suporta uigetdir, então o mapeamento das pastas
                % POST/GET deve ser feito em arquivo externo de configuração...
                app.config_Option_Folder.Enable = 0;
            else
                userPaths = appUtil.UserPaths(app.General.fileFolder.userPath);
                set(app.config_Folder_userPath, 'Items', userPaths, 'Value', userPaths{end})
                app.General.fileFolder.userPath = userPaths{end};
            end

            % FOLDERS
            DataHub_GET  = app.General.fileFolder.DataHub_GET;
            DataHub_POST = app.General.fileFolder.DataHub_POST;
            if isfolder(DataHub_GET)
                app.config_Folder_DataHubGET.Value  = DataHub_GET;
            end

            if isfolder(DataHub_POST)
                app.config_Folder_DataHubPOST.Value = DataHub_POST;
            end
            config_DataHubWarningLamp(app)

            % Painel "CONFIG >> PYTHON"
            pythonPath = app.General.fileFolder.pythonPath;
            if isfile(pythonPath)
                try
                    pyenv('Version', pythonPath);
                    app.config_Folder_pythonPath.Value = pythonPath;
                catch ME
                    appUtil.modalWindow(app.UIFigure, 'warning', ME.message);
                end
            end

            % TABLE VISIBLE COLUMNS (TREE)
            allColumns      = search_Table_ColumnInfo(app, 'allColumns');
            staticColumns   = search_Table_ColumnInfo(app, 'staticColumns');

            [~, sortIndex]  = sort(lower(allColumns));
            GUIAllColumns   = allColumns(sortIndex);

            listOfTreeNodes = cellfun(@(x) uitreenode(app.config_SelectedTableColumns, 'Text', x), GUIAllColumns);
            isStaticColumn  = ismember(GUIAllColumns, staticColumns);

            app.config_SelectedTableColumns.CheckedNodes = listOfTreeNodes(isStaticColumn);
            addStyle(app.config_SelectedTableColumns, class.Constants.configStyle5, 'node', listOfTreeNodes(isStaticColumn))

            % FILTROS SECUNDÁRIOS
            app.search_SecundaryColumn.Items = GUIAllColumns;
            search_SecundaryColumnValueChanged(app)

            % RELATÓRIO
            app.report_Violation.Items = app.General.typeOfViolation;
            app.report_Violation.Value = app.General.defaultTypeOfViolation;
            app.report_ModelName.Items = [{''}, {reportLibConnection.Controller.Read(app.rootFolder).Name}];

            % CONFIG
            switch app.General.fiscaliza.systemVersion
                case 'PROD'
                    app.config_FiscalizaPD.Value = 1;
                case 'HOM'
                    app.config_FiscalizaHM.Value = 1;
            end
            config_FiscalizaModeLayout(app)
            config_FiscalizaDefaultValues(app)

            config_ButtonGroupSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function menu_LayoutControl(app, tabIndex)
            % Função reservada para ajustar a visibilidade de componentes,
            % ao trocar o modo de operação do app. (clique nos botões do
            % menu gráfico principal)

            switch tabIndex
                case {1, 3} % SEARCH | CONFIG
                    switch tabIndex
                        case 1
                            app.search_PanelVisibility.Visible = 1;
                            app.config_PanelVisibility.Visible = 0;
                        case 3
                            app.search_PanelVisibility.Visible = 0;
                            app.config_PanelVisibility.Visible = 1;
                    end

                    app.report_PanelVisibility.Visible         = 0;                    
                    app.report_ShowCells2Edit.Visible          = 0;
                    app.report_FiscalizaAutoFillImage.Visible  = 0;
                    app.report_ReportGeneration.Visible        = 0;
                    app.report_FiscalizaUpdateImage.Visible    = 0;

                case 2 % REPORT
                    app.search_PanelVisibility.Visible         = 0;
                    app.report_PanelVisibility.Visible         = 1;
                    app.config_PanelVisibility.Visible         = 0;
                    app.report_ShowCells2Edit.Visible          = 1;
                    app.report_FiscalizaAutoFillImage.Visible  = 1;
                    app.report_ReportGeneration.Visible        = 1;
                    app.report_FiscalizaUpdateImage.Visible    = 1;
            end
        end

        %-----------------------------------------------------------------%
        function search_SuggestionAlgorithm(app, eventValue, panelVisibility)
            value2Search = textAnalysis.preProcessedData(eventValue);
            search_EntryPointImage_Status(app, value2Search)

            if app.config_SearchModeTokenSuggestion.Value 
                if numel(value2Search) >= app.config_nMinCharacters.Value
                    listOfColumns = search_Filtering_PrimaryTableColumns(app);
                    nMinValues    = str2double(app.config_nMinWords.Value);
    
                    [similarStrings, idxFiltered, redFontFlag] = suggestion.getSimilarStrings(app.cacheData, value2Search, listOfColumns, nMinValues);
    
                    set(app.search_Suggestions, 'Visible', panelVisibility, 'Value', {}, 'Items', similarStrings, 'ItemsData', 1:numel(idxFiltered))
                    search_EntryPoint_Color(app, redFontFlag)
    
                    app.previousSearch = eventValue;
                end
            end            
        end

        %-----------------------------------------------------------------%
        function relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom)
            annotationLogical      = strcmp(app.annotationTable.("Homologação"), showedHom);
            relatedAnnotationTable = app.annotationTable(annotationLogical, :);
        end


        %-----------------------------------------------------------------%
        function search_Annotation_Add2Cache(app, selectedRow, showedHom, attributeName, attributeValue, wourdCloudRefreshTag)
            % !! PONTO DE EVOLUÇÃO !!
            % IMPLEMENTADA INCLUSÃO DE ANOTAÇÃO, ALÉM DE EDIÇÃO DE ANOTAÇÃO 
            % DO WORDCLOUD. PENDENTE EXCLUSÃO DE ANOTAÇÃO, ALÉM DA EDIÇÃO
            % DOS OUTROS TIPOS DE ANOTAÇÃO.
            newRowTable = table({char(matlab.lang.internal.uuid())},           ...
                                {datestr(now, 'dd/mm/yyyy HH:MM:SS')},         ...
                                {ccTools.fcn.OperationSystem('computerName')}, ...
                                {ccTools.fcn.OperationSystem('userName')},     ...
                                {showedHom},                                   ...
                                {attributeName},                               ...
                                {attributeValue},                              ...
                                1, 'VariableNames', class.Constants.annotationTableColumns);

            idx1 = find(strcmp(app.annotationTable.("Homologação"), showedHom))';            
            if isempty(idx1) || wourdCloudRefreshTag
                app.annotationTable(end+1,:) = newRowTable;

            else
                if any(strcmp(app.annotationTable.("Atributo")(idx1), attributeName) & strcmp(app.annotationTable.("Valor")(idx1), attributeValue))
                    appUtil.modalWindow(app.UIFigure, 'warning', sprintf('Conjunto atributo/valor já consta como anotação do registro %s.', showedHom));
                    return

                else
                    app.annotationTable(end+1,:) = newRowTable;
                end
            end

            if wourdCloudRefreshTag
                idx2 = find(strcmp(app.annotationTable.("Homologação"), showedHom) & strcmp(app.annotationTable.("Atributo"), 'WordCloud'));
                app.annotationTable(idx2(1:end-1), :) = [];
            end

            % A cada nova inserção, gera-se uma planilha que é submetida à
            % pasta POST, ou é salva localmente em cache.
            [app.annotationTable, msgWarning] = writeFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
            end

            % Atualizando o painel com os metadados do registro selecionado...
            relatedAnnotationTable   = search_Annotation_RelatedTable(app, showedHom);
            htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, relatedAnnotationTable);
            misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, selectedRow, showedHom);

            % Ajusta apenas o estilo de anotação do registro.
            search_Table_RemoveStyle(app, 'cell')
            search_Table_AnnotationIcon(app)
            % !! PONTO DE EVOLUÇÃO !!
        end


        %-----------------------------------------------------------------%
        function search_Filtering_primaryFilter(app, words2Search)
            app.progressDialog.Visible = 'visible';
            
            % Rotina de inicialização dos objetos relacionados aos filtros 
            % secundários.
            app.filteringObj.filterRules(:,:)       = [];
            app.search_SecundaryListOfFilters.Items = {};

            % O "primaryTempIndex" retorna os registros da tabela que deram match
            % com "words2Search". Uma homologação, contudo, pode estar relacionada 
            % a vários registros da base de dados, por isso devem ser buscados
            % os demais.
            
            % A order dos registros é importante APENAS se foi usado o algoritmo 
            % Levenshtein p/ cálculo da distância entre as strings. 
            if app.config_SearchModeTokenSuggestion.Value && (numel(words2Search) <= str2double(app.config_nMinWords.Value))
                sortOrder = 'stable';
            else
                sortOrder = 'unstable';
            end

            cacheColumnNames   = search_Table_PrimaryColumnNames(app);
            listOfCacheColumns = cellfun(@(x) sprintf('_%s', x), cacheColumnNames, 'UniformOutput', false);
            searchFunction     = app.config_SearchModePanel.SelectedObject.Tag;

            primaryTempIndex   = run(app.filteringObj, 'words2Search', app.rawDataTable, listOfCacheColumns, sortOrder, searchFunction, words2Search);
            primaryHomProducts = unique(app.rawDataTable(primaryTempIndex,:).("Homologação"), 'stable');          
            
            primaryIndex       = run(app.filteringObj, 'words2Search', app.rawDataTable, {'Homologação'}, sortOrder, 'strcmp', primaryHomProducts);
            GUIColumns         = search_Table_ColumnNames(app);

            set(app.search_Table, 'Data',      app.rawDataTable(primaryIndex, GUIColumns), ...
                                  'UserData',  struct('primaryIndex', primaryIndex, 'secundaryIndex', primaryIndex, 'cacheColumns', {cacheColumnNames}))

            % Cria chart para a nuvem de palavras...
            if isempty(app.wordCloudObj)
                app.wordCloudObj = wordCloud(app.search_WordCloudPanel, app.config_WordCloudAlgorithm.Value);
            end

            % Torna visível a tabela e outros elementos relacionados à tabela...
            search_Table_Visibility(app)
                        
            % Renderiza em tela o número de linhas, além de selecionar a primeira 
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app, 'search')
            search_Table_InitialSelection(app, true)

            % Aplica estilo na tabela e verifica se a tabela está visível...
            search_Table_AddStyle(app)

            % Reinicia painel de filtragem secundária...
            search_SecundaryColumnValueChanged(app)

            app.progressDialog.Visible = 'hidden';
        end
 

        %-----------------------------------------------------------------%
        function search_Filtering_secundaryFilter(app)
            primaryIndex = app.search_Table.UserData.primaryIndex;
            GUIColumns   = search_Table_ColumnNames(app);

            if ~isempty(app.filteringObj.filterRules)
                logicalArray   = run(app.filteringObj, 'filterRules', app.rawDataTable(primaryIndex,:));
                secundaryIndex = primaryIndex(logicalArray);
            else
                secundaryIndex = primaryIndex;
            end

            app.search_Table.Data = app.rawDataTable(secundaryIndex, GUIColumns);
            app.search_Table.UserData.secundaryIndex = secundaryIndex;

            % Renderiza em tela o número de linhas, além de selecionar a primeira 
            % linha da tabela, caso a pesquisa retorne algo.
            misc_Table_NumberOfRows(app, 'search')
            search_Table_InitialSelection(app, false)

            % Aplica estilo na tabela...
            search_Table_AddStyle(app)
        end


        %-----------------------------------------------------------------%
        function listOfColumns = search_Filtering_PrimaryTableColumns(app)
            selectedButton = app.search_PrimaryPanel.SelectedObject;
            listOfColumns  = selectedButton.Text;
        end


       %-----------------------------------------------------------------%
        function [Value, msgWarning] = search_Filtering_SecundaryFilterValue(app)
            Value       = [];
            msgWarning  = '';

            columnName  = app.search_SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            selectedOperation = app.search_SecundaryOperation.Value;
            switch filterType
                case 'datetime'
                    switch selectedOperation
                        case {'=', '≠', '<', '≤', '>', '≥'}
                            Value = datetime(app.search_SecundaryDateTime1.Value, 'InputFormat', 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy');
                            
                        case {'><', '<>'}
                            Value = datetime({app.search_SecundaryDateTime1.Value, app.search_SecundaryDateTime2.Value}, 'InputFormat', 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy');

                        case {'⊃', '⊅'}
                            try
                                Value = cellfun(@(x) datetime(x, "InputFormat", 'dd/MM/yyyy', 'Format', 'dd/MM/yyyy'), strtrim(strsplit(app.search_SecundaryTextFreeValue.Value, ',')));
                            catch ME
                                app.search_SecundaryTextFreeValue.Value = '';

                                msgWarning = ME.message;
                                return
                            end
                    end

                case 'freeText'
                    Value = strtrim(strsplit(app.search_SecundaryTextFreeValue.Value, ','));
                    if isscalar(Value)
                        Value = char(Value);
                    end

                case 'listOfText'
                    Value = app.search_SecundaryTextListValue.Value;
            end

            if isempty(Value)
                msgWarning = 'Valor inválido.';
            end
        end


        %-----------------------------------------------------------------%
        function search_Filtering_SecundaryFilterLayout(app)
            configValue = {};
            for ii = 1:height(app.filteringObj.filterRules)
                Value = app.filteringObj.filterRules.Value{ii};

                if isnumeric(Value)
                    configValue{ii,1} = sprintf('[%s]', strjoin(string(Value), ', '));

                elseif iscellstr(Value)
                    configValue{ii,1} = textAnalysis.cellstrGUIStyle(Value);

                else %ischar(Value)
                    configValue{ii,1} = sprintf('"%s"', Value);
                end
            end
            
            filterList = cellstr("SCH.(""" + string(app.filteringObj.filterRules.Column) + """) " + string(app.filteringObj.filterRules.Operation) + " " + string(configValue));
            app.search_SecundaryListOfFilters.Items = filterList;
        end


        %-----------------------------------------------------------------%
        function search_SuggestionPanel_InitialValues(app)
            set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
        end


        %-----------------------------------------------------------------%
        function search_EntryPoint_InitialValue(app)
            set(app.search_entryPoint, 'FontColor', [.8,.8,.8], 'Value', 'O que você quer pesquisar?')
            app.search_entryPointImage.Enable = 0;
        end


        %-----------------------------------------------------------------%
        function search_EntryPoint_CheckIfNeedsUpdate(app)
            % Conforme exposto nos comentários da função "jsBackDoor_Listener", quando altero o conteúdo 
            % de app.search_entryPoint, sem alterar o seu foco, será executado o evento "ValueChangingFcn". 
            % Se pressiono a tecla "Enter", será executada a função "jsBackDoor_Listener" antes de atualizar 
            % a propriedade "Value" do app.search_entryPoint.

            % Por conta disso, é essencial inserir WAITFOR. O problema é que eventualmente o MATLAB
            % perde o momento exato da alteração da propriedade "Value" de app.search_entryPoint
            % e isso trava a execução do app.

            % Evidenciado que em condições normais o WAITFOR demora entre 25 e 50 milisegundos
            % para atualizar a citada propriedade. Consequentemente, foi substituído o WAITFOR por 
            % um LOOP+PAUSE.

            % waitfor(app.search_entryPoint, 'Value')

            tWaitFor = tic;
            while toc(tWaitFor) < .050
                if strcmp(app.search_entryPoint.Value, app.previousSearch)
                    break
                end
                pause(.010)
            end
        end


        %-----------------------------------------------------------------%
        function search_EntryPoint_Color(app, redFlag)
            if redFlag
                fontColor = [1,0,0];
            else
                fontColor = [0,0,0];
            end
            app.search_entryPoint.FontColor = fontColor;
            drawnow
        end


        %-----------------------------------------------------------------%
        function search_EntryPointImage_Status(app, value2Search)
            if numel(value2Search) < app.config_nMinCharacters.Value
                app.search_entryPointImage.Enable = 0;
                search_SuggestionPanel_InitialValues(app)
            else
                app.search_entryPointImage.Enable = 1;
            end
        end


        %-----------------------------------------------------------------%
        function search_Panel_Visibility(app)
            showedHom = app.search_ProductInfo.UserData.showedHom;
            if ~isempty(showedHom) && app.search_Tab1Grid.RowHeight{6}
                app.search_AnnotationPanelAdd.Enable = 1;
            else
                app.search_AnnotationPanelAdd.Enable = 0;
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_Visibility(app)
            if ~app.search_Table.Visible
                app.search_Table.Visible    = 1;
                app.search_Metadata.Visible = 1;                
                app.search_nRows.Visible    = 1;
            end
        end


        %-----------------------------------------------------------------%
        function columnInfo = search_Table_ColumnInfo(app, Type)
            switch Type
                case 'staticColumns'
                    staticLogical = logical(app.General.SCHDataInfo.GUI_Static);
                    staticIndex   = app.General.SCHDataInfo.GUI_Static(staticLogical);
                    [~, columnOrder] = sort(staticIndex);
                    columnList = app.General.SCHDataInfo.Column(staticLogical);
                    columnInfo = columnList(columnOrder);

                case 'allColumns'
                    columnInfo = app.General.SCHDataInfo.Column;
                    
                case 'allColumnsWidths'
                    columnInfo = app.General.SCHDataInfo.GUI_Width;
            end
        end


        %-----------------------------------------------------------------%
        function cacheColumns = search_Table_PrimaryColumnNames(app)
            cacheColumns = strsplit(search_Filtering_PrimaryTableColumns(app), ' | ');
        end


        %-----------------------------------------------------------------%
        function [columnNames, columnWidth] = search_Table_ColumnNames(app)
            checkedNodes = app.config_SelectedTableColumns.CheckedNodes;
            staticColums = search_Table_ColumnInfo(app, 'staticColumns');
            columnNames  = unique([staticColums; arrayfun(@(x) x.Text, checkedNodes, 'UniformOutput', false)], 'stable');

            allColumns   = search_Table_ColumnInfo(app, 'allColumns');
            widthColumns = search_Table_ColumnInfo(app, 'allColumnsWidths');

            columnWidth  = {};
            for ii = 1:numel(columnNames)
                columnName      = columnNames{ii};
                columnIndex     = find(strcmp(allColumns, columnName), 1);
                
                columnWidth{ii} = widthColumns{columnIndex};
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_InitialSelection(app, focusFlag)
            if isempty(app.search_Table.Data)
                app.search_Table.Selection    = [];
                app.search_ExportTable.Enable = 0;
            else
                app.search_Table.Selection    = 1;
                app.search_ExportTable.Enable = 1;
            end            
            search_Table_SelectionChanged(app)

            if focusFlag
                focus(app.search_Table)
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_AddStyle(app)
            search_Table_RemoveStyle(app, 'all')

            % Row striping
            [~, ~, uniqueHomIndex] = unique(app.search_Table.Data.("Homologação"), 'stable');
            listOfRows             = find(~mod(uniqueHomIndex, 2));
            if ~isempty(listOfRows)
                addStyle(app.search_Table, class.Constants.configStyle1, 'row', listOfRows)
            end

            % Table primary columns background
            cacheColumns = app.search_Table.UserData.cacheColumns;
            addStyle(app.search_Table, class.Constants.configStyle2, 'column', cacheColumns)
            
            % Table annotation icon
            search_Table_AnnotationIcon(app)
            drawnow nocallbacks
        end


        %-----------------------------------------------------------------%
        function search_Table_RemoveStyle(app, styleType)
            switch styleType
                case 'all'
                    removeStyle(app.search_Table)

                otherwise
                styleTypeIndex  = find(strcmp(cellstr(app.search_Table.StyleConfigurations.Target), styleType));
                if ~isempty(styleTypeIndex)
                    removeStyle(app.search_Table, styleTypeIndex)
                end
            end
        end


        %-----------------------------------------------------------------%
        function search_Table_AnnotationIcon(app)
            % Posição da coluna "Homologação".
            homColumnIndex    = find(strcmp(app.search_Table.Data.Properties.VariableNames, 'Homologação'), 1);

            % Valores únicos de homologação e seus índices...
            [listOfHom, ...
             lisOfHomIndex]   = unique(app.search_Table.Data.("Homologação"), 'stable');
            
            % Identifica registros para os quais existe anotação registrada, 
            % aplicando o estilo.
            annotationLogical = ismember(listOfHom, unique(app.annotationTable.("Homologação")));
            annotationIndex   = lisOfHomIndex(annotationLogical);
            listOfCells       = [annotationIndex, repmat(homColumnIndex, numel(annotationIndex), 1)];

            if ~isempty(listOfCells)
                if app.search_PrimaryOption1.Value
                    s = class.Constants.configStyle3;
                else
                    s = class.Constants.configStyle4;
                end
                addStyle(app.search_Table, s, "cell", listOfCells)
            end
        end


        %-----------------------------------------------------------------%
        function status = search_WordCloud_CheckCache(app, selectedHom, relatedTable)
            status = false;

            wordCloudLogical = strcmp(relatedTable.("Atributo"), 'WordCloud');
            relatedTable     = relatedTable(wordCloudLogical, :);

            if isempty(relatedTable) || any(wordCloudLogical) && ~strcmp(app.search_WordCloudPanel.Tag, selectedHom)
                status = true;
            end
        end


        %-----------------------------------------------------------------%
        function status = search_WordCloud_PlotUpdate(app, selectedRow, showedHom, wourdCloudRefreshTag)
            status = true;

            % O wordcloud, do MATLAB, é lento, demandando uma tela de progresso 
            % que bloqueia a interação com o app.
            if app.config_WordCloudAlgorithm.Value == "MATLAB built-in"
                app.progressDialog.Visible = 'visible';
            end
            
            if wourdCloudRefreshTag
                wordCloudIndex = [];
            else
                relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);
                wordCloudIndex = find(strcmp(relatedAnnotationTable.("Atributo"), 'WordCloud'), 1);
            end

            if ~isempty(wordCloudIndex)
                wordCloudAnnotation = relatedAnnotationTable.("Valor"){wordCloudIndex};
                wordCloudTable      = fcn.getWordCloudFromCache(wordCloudAnnotation);

            else
                app.progressDialog.Visible = 'visible';
                try
                    word2Search = search_WordCloud_Word2Search(app, showedHom);
                    nMaxWords   = 25;

                    [wordCloudTable, wordCloudInfo] = fcn.getWordCloudFromWeb(word2Search, nMaxWords);
                    if ~isempty(wordCloudTable)
                        search_Annotation_Add2Cache(app, selectedRow, showedHom, 'WordCloud', wordCloudInfo, wourdCloudRefreshTag)
                    end

                catch ME
                    app.progressDialog.Visible = 'hidden';
                    appUtil.modalWindow(app.UIFigure, 'warning', ME.message);

                    status = false;                    
                    return
                end
            end

            if ~isempty(wordCloudTable)
                app.wordCloudObj.Table        = wordCloudTable;
                app.search_WordCloudPanel.Tag = showedHom;
            end

            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        function word2Search = search_WordCloud_Word2Search(app, showedHom)
            selectedRow = find(strcmp(app.search_Table.Data.("Homologação"), showedHom), 1);
            listOfWords = {char(app.search_Table.Data.("Modelo")(selectedRow)), ...
                           char(app.search_Table.Data.("Nome Comercial")(selectedRow))};

            switch app.config_WordCloudColumn.Value
                case 'Modelo';         idx1 = 1;
                case 'Nome Comercial'; idx1 = 2;
            end
            word2Search = listOfWords{idx1};

            if isempty(word2Search)
                idx2 = setdiff([1 2], idx1);
                word2Search = listOfWords{idx2};

                if isempty(word2Search)
                    error('Registro %s não possui cadastrado "Modelo" ou "Nome Comercial", inviabilizando consulta à internet.', showedHom)
                else
                    listOfColumns = {'Modelo', 'Nome Comercial'};
                    appUtil.modalWindow(app.UIFigure, 'warning', sprintf('O registro %s não possui cadastrado "%s". Dessa forma, consulta à internet foi realizada usando o seu "%s".', showedHom, listOfColumns{idx1}, listOfColumns{idx2}));
                end
            end
        end


        %-----------------------------------------------------------------%
        function report_SelectedHomPanel_InfoUpdate(app, selected2showedHom, selectedRow)
            if ~isempty(selected2showedHom)
                % Primeiro ajusta o painel com botões de rádio...
                if ~strcmp(selected2showedHom, '-1')
                    app.report_productSituation1.Value = 1; % HOMOLOGADO
                else
                    app.report_productSituation2.Value = 1; % NÃO HOMOLOGADO
                end
                set(app.report_productSituationPanel.Children, 'Enable', 0)

                % O título do painel e a imagem para confirmar alteração...
                app.report_EditableInfoLabel.Text      = 'EDIÇÃO COMPLEMENTAR À DA TABELA';
                app.report_EditOrAddButton.ImageSource = app.report_EditOrAddButton.UserData.iconOptions{1};

                % E depois as caixas de edição abaixo...
                idx = selectedRow;
                set(app.report_nHom, 'Enable', 0, 'Value', app.projectData.listOfProducts.("Homologação"){idx})
                app.ImportadorEditField.Value = app.projectData.listOfProducts.("Importador"){idx};
                app.report_IDAduana.Value   = app.projectData.listOfProducts.("Código aduaneiro"){idx};
                app.report_Situation.Value  = app.projectData.listOfProducts.("Situação"){idx};
                report_SituationValueChanged(app)

                app.report_Violation.Value  = app.projectData.listOfProducts.("Infração"){idx};
                app.report_Corrigible.Value = app.projectData.listOfProducts.("Sanável?"){idx};
                app.report_Notes.Value      = app.projectData.listOfProducts.("Informações adicionais"){idx};

            else
                app.report_productSituation2.Value = 1;
                set(app.report_productSituationPanel.Children, 'Enable', 1)
                report_productSituationPanelSelectionChanged(app)

                app.report_EditableInfoLabel.Text      = 'INCLUSÃO';
                app.report_EditOrAddButton.ImageSource = app.report_EditOrAddButton.UserData.iconOptions{2};

                app.ImportadorEditField.Value = '';
                app.report_IDAduana.Value = '';

                app.report_Situation.Value = 'Irregular';
                report_SituationValueChanged(app)

                app.report_Violation.Value = app.General.defaultTypeOfViolation;
                app.report_Corrigible.Value = 'Não';
                app.report_Notes.Value     = '';
            end
        end


        %-----------------------------------------------------------------%
        function report_ListOfProductsAdd(app, srcMode, listOfHom2Add)
            for ii = 1:numel(listOfHom2Add)
                selectedHom2Add = listOfHom2Add{ii};                

                switch srcMode
                    case 'search'
                        if ~ismember(selectedHom2Add, app.projectData.listOfProducts.("Homologação"))
                            newRow2Add = report_newRow2Add(app, selectedHom2Add);
                            app.projectData.listOfProducts(end+1, [1:6,16:19]) = newRow2Add;
                            app.projectData.listOfProducts = sortrows(app.projectData.listOfProducts, 'Homologação');
                        end

                    otherwise % 'report - addRow' | 'report - edit'
                        Importador     = app.ImportadorEditField.Value;
                        CodAduaneiro   = app.report_IDAduana.Value;                        
                        Situacao       = app.report_Situation.Value;
                        typeViolation  = app.report_Violation.Value;
                        Sanavel        = app.report_Corrigible.Value;
                        optionalNote   = strjoin(strtrim(app.report_Notes.Value), '\n');

                        if strcmp(srcMode, 'report - addRow')
                            switch selectedHom2Add
                                case '-1'
                                    newRow2Add = {'-1', Importador, CodAduaneiro, '-1', '', '', Situacao, typeViolation, Sanavel, optionalNote};

                                otherwise
                                    newRow2Add = report_newRow2Add(app, selectedHom2Add);
                                    newRow2Add([2:3, 7:10]) = {Importador, CodAduaneiro, Situacao, typeViolation, Sanavel, optionalNote};
                            end

                            idx = height(app.projectData.listOfProducts) + 1;                            
                            app.projectData.listOfProducts(idx, [1:6, 16:19]) = newRow2Add;
                            app.projectData.listOfProducts = sortrows(app.projectData.listOfProducts, 'Homologação');

                        else % 'report - edit'
                            [~, ~, selectedRow] = misc_Table_SelectedRow(app, 'report');
                            app.projectData.listOfProducts(selectedRow, [2:3, 16:19]) = {Importador, CodAduaneiro, Situacao, typeViolation, Sanavel, optionalNote};
                        end
                end
            end

            % Atualizando a lista de produtos homologados sob análise (do 
            % modo SEARCH).
            report_ListOfHomProductsUpdating(app)

            % Evidencia células que tiveram os seus valores editados...
            if exist('selectedRow', 'var')
                hComp = [app.report_IDAduana, app.report_Situation, app.report_Violation, app.report_Notes];
                set(hComp, 'BackgroundColor', [0.75,0.75,0.75])
                drawnow
                pause(.3)
            end

            % Atualizando a tabela e o número de linhas (do modo REPORT), nessa 
            % ordem. E depois forçando uma atualização dos paineis.
            report_UpdatingTable(app)

            % Torna visível imagem de warning, caso aberto projeto.
            report_ProjectWarnImageVisibility(app)
            
            % Retira evidência às supracitadas células.
            if exist('selectedRow', 'var')
                set(hComp, 'BackgroundColor', [1,1,1])
            end

            report_TableSelectionChanged(app)
        end


        %-----------------------------------------------------------------%
        function report_ListOfHomProductsUpdating(app)
            homLogical = ~strcmp(app.projectData.listOfProducts.("Homologação"), '-1');
            app.search_ListOfProducts.Items = app.projectData.listOfProducts.("Homologação")(homLogical);
        end


        %-----------------------------------------------------------------%
        function [listOfRows, idx, analyzedColumns] = report_ListOfProductsCheck(app)
            % Condições para que o registro seja considerado incompleto...
            analyzedColumns = {'Tipo',             ...
                               'Fabricante',       ...
                               'Modelo',           ...
                               'Valor Unit. (R$)', ...
                               {'Qtd. uso/vendida', 'Qtd. estoque/aduana'}, ...
                               {'Qtd. uso/vendida', 'Qtd. estoque/aduana', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}};

            idx      = zeros(height(app.projectData.listOfProducts), 6, 'logical');
            idx(:,1) = string(app.projectData.listOfProducts.Tipo)       == "-1";
            idx(:,2) = string(app.projectData.listOfProducts.Fabricante) == "";
            idx(:,3) = string(app.projectData.listOfProducts.Modelo)     == "";
            idx(:,4) = app.projectData.listOfProducts.("Valor Unit. (R$)") <= 0;
            idx(:,5) = app.projectData.listOfProducts.("Qtd. uso/vendida") + app.projectData.listOfProducts.("Qtd. estoque/aduana") <= 0;
            idx(:,6) = sum(app.projectData.listOfProducts{:, {'Qtd. uso/vendida', 'Qtd. estoque/aduana'}}, 2) < sum(app.projectData.listOfProducts{:, {'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}}, 2);

            listOfRows = find(any(idx, 2));
        end


        %-----------------------------------------------------------------%
        function report_UpdatingTable(app)
            app.report_Table.Data = app.projectData.listOfProducts(:, [1, 4:15]);

            % LAYOUT
            misc_Table_NumberOfRows(app, 'report')

            if ~isempty(app.projectData.listOfProducts)
                app.report_ShowCells2Edit.Enable = 1;
                
                style2Apply = report_Table_Style2Apply(app);
                report_Table_AddStyle(app, style2Apply)

            else
                removeStyle(app.report_Table)
                set(app.report_ShowCells2Edit, 'Enable', 0, 'Tag', 'off')
            end

            report_ModelNameValueChanged(app)
        end


        %-----------------------------------------------------------------%
        function style2Apply = report_Table_Style2Apply(app)
            switch app.report_ShowCells2Edit.Tag
                case 'on'
                    style2Apply = 'Icon+BackgroundColor';
                case 'off'
                    style2Apply = 'Icon+TemporaryBackgroundColor';
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
        function newRow2Add = report_newRow2Add(app, selectedHom2Add)
            selectedHomRawTableIndex = find(strcmp(app.rawDataTable.("Homologação"), selectedHom2Add));
            relatedSCHTable = app.rawDataTable(selectedHomRawTableIndex, :);

            Importador    = '';
            CodAduaneiro  = '';
            typeValue     = '-1';
            typeList      = unique(cellstr(relatedSCHTable.("Tipo")));

            Fabricante    = upper(char(relatedSCHTable.("Fabricante")(1)));
            modelValue    = char(relatedSCHTable.("Modelo")(1));
            modelList     = unique([relatedSCHTable.("Modelo"); relatedSCHTable.("Nome Comercial")]);
            modelList(cellfun(@(x) isempty(x), modelList)) = [];
            
            Situacao      = 'Irregular';
            typeViolation = app.General.defaultTypeOfViolation;
            Sanavel       = 'Não';
            optionalNote  = sprintf('TIPO: %s\nMODELO: %s', ccTools.fcn.FormatString(typeList), ccTools.fcn.FormatString(modelList));
            
            newRow2Add    = {selectedHom2Add, Importador, CodAduaneiro, typeValue, Fabricante, modelValue, Situacao, typeViolation, Sanavel, optionalNote};
        end


        %-----------------------------------------------------------------%
        function status = report_checkValidIssueID(app)
            status = (app.report_Issue.Value > 0) && (app.report_Issue.Value < inf);
        end

        %-----------------------------------------------------------------%
        % REPORT >> FISCALIZA
        %-----------------------------------------------------------------%
        function report_FiscalizaConnect(app, credentials, connectionType)
            app.progressDialog.Visible = 'visible';
            try
                switch connectionType
                    case 'OpenConnection'
                        if app.config_FiscalizaPD.Value
                            homFlag = false;
                        else
                            homFlag = true;
                        end        
                        app.fiscalizaObj = fiscalizaGUI(credentials.login, credentials.password, homFlag, app.report_FiscalizaGrid, app.report_Issue.Value);
    
                    case 'GetIssue'
                        getIssue(app.fiscalizaObj, app.report_Issue.Value)
                        Data2GUI(app.fiscalizaObj)

                    case 'RefreshIssue'
                        RefreshGUI(app.fiscalizaObj)
                end

                misc_Panel_menuButtonPushed(app, 'report', 2, 3)
                report_FiscalizaToolbarStatus(app)

            catch ME
                % Se a operação registrar um erro, faz-se necessária a realização
                % de três operações:
                % (1) Apagar algum componente renderizado em tela, caso o objeto
                %     app.fiscalizaObj exista;
                % (2) Apresentar o ícone do REDMINE como placeholder; e
                % (3) Desabilitar o botão que possibilita o relato.
                report_FiscalizaResetGUI(app)
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        function report_FiscalizaToolbarStatus(app)
            % Habilita botões de "AutoFill" e "Update" apenas se a
            % inspeção estiver num estado relatável. Lembrando que se der 
            % algum erro no processo, o grid app.report_Fiscaliza.Grid
            % terá um único filho - a imagem do Redmine (placeholder).
            if numel(app.report_FiscalizaGrid.Children) <= 1
                app.report_FiscalizaAutoFillImage.Enable = 0;
                app.report_FiscalizaUpdateImage.Enable   = 0;
            else
                app.report_FiscalizaAutoFillImage.Enable = 1;
                app.report_FiscalizaUpdateImage.Enable   = 1;
            end
        end


        %-----------------------------------------------------------------%
        function report_FiscalizaResetGUI(app)
            if ~isempty(app.fiscalizaObj)
                GridInitialization(app.fiscalizaObj, false)
                app.fiscalizaObj.issueID = [];
            end
            set(app.report_FiscalizaIcon, 'Parent', app.report_FiscalizaGrid, 'Visible', 1)

            app.report_FiscalizaAutoFillImage.Enable = 0;
            app.report_FiscalizaUpdateImage.Enable   = 0;
        end


        %-----------------------------------------------------------------%
        function report_FiscalizaAutoFill(app)
            app.progressDialog.Visible = 'visible';
            try
                automaticData = report_FiscalizaInfo2AutoFill(app);
                AutoFillFields(app.fiscalizaObj, automaticData, 1)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        function report_FiscalizaUpdate(app)
            msgQuestion = '<p style="font-size: 12px; text-align: justify;">Confirma a tentativa de atualizar informações da inspeção?</p>';            
            selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',     ...
                                                                   'Options', {'SIM', 'NÃO'}, ...
                                                                   'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
            if strcmp(selection, 'NÃO')
                return
            end

            app.progressDialog.Visible = 'visible';
            try
                UploadFiscaliza(app.fiscalizaObj)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
            app.progressDialog.Visible = 'hidden';
        end


        %-----------------------------------------------------------------%
        function automaticData = report_FiscalizaInfo2AutoFill(app)
            automaticData = struct('tipo_de_inspecao',           'Certificação', ...
                                   'entidade_com_cadastro_stel', app.config_CadastroSTEL.Value);

            % RELATÓRIO (VERSÃO DEFINITIVA)
            if ~isempty(app.General.fiscaliza.lastHTMLDocFullPath)
                automaticData.html_path = app.General.fiscaliza.lastHTMLDocFullPath;
            end

            % QUALIFICAÇÃO DA FISCALIZADA
            nEntity = strtrim(app.report_Entity.Value);
            if ~isempty(nEntity)
                automaticData.nome_da_entidade = nEntity;
            end

            try
                [~, nCNPJ] = checkCNPJ(app.report_EntityID.Value, false);
                
                automaticData.entidade_da_inspecao = {nCNPJ};
                automaticData.cnpjcpf_da_entidade  = nCNPJ;
            catch
            end

            % FISCAL RESPONSÁVEL E FISCAIS
            hDropDown   = findobj(app.report_FiscalizaGrid, 'Type', 'uidropdown',     'Tag', 'fiscal_responsavel');
            hTree       = findobj(app.report_FiscalizaGrid, 'Type', 'uicheckboxtree', 'Tag', 'fiscais');
            currentUser = getCurrentUser(app.fiscalizaObj);
            try                
                if ~isempty(currentUser)
                    if ~isempty(hDropDown) && ~isempty(hDropDown.Items)
                        idxFiscal1 = find(strcmp(hDropDown.Items, currentUser), 1);
                        if ~isempty(idxFiscal1)
                            automaticData.fiscal_responsavel = currentUser;
                        end
                    end
                end
            catch
            end

            try
                if ~isempty(currentUser)
                    if ~isempty(hTree) && ~isempty(hTree.Children)
                        idxFiscal2 = find(strcmp({hTree.Children.Text}, currentUser), 1);
                        if ~isempty(idxFiscal2)
                            automaticData.fiscais = {currentUser};
                        end
                    end
                end
            catch
            end

            % MEDIDA CAUTELAR
            qtdLacrados    = sum(app.projectData.listOfProducts{:, 'Qtd. lacradas'});
            qtdApreendidas = sum(app.projectData.listOfProducts{:, 'Qtd. apreendidas'});
            
            procedimentos = {};
            if qtdLacrados
                procedimentos = [procedimentos, {'Lacração'}];
            end

            if qtdApreendidas
                procedimentos = [procedimentos, {'Apreensão'}];
            end

            if ~isempty(procedimentos)
                automaticData.procedimentos = procedimentos;
            end

            automaticData.qnt_produt_lacradosapreend = qtdLacrados + qtdApreendidas;
            if qtdLacrados || qtdApreendidas
                if ~isempty(app.config_MotivoLAI.CheckedNodes)
                    automaticData.motivo_de_lai = {app.config_MotivoLAI.CheckedNodes.Text};
                end

                if strcmp(app.config_GerarPLAI.Value, '1')
                    automaticData.gerar_plai = '1';
                    automaticData.tipo_do_processo_plai = app.config_TipoPLAI.Value;

                    hComponent = findobj(app.report_FiscalizaGrid, 'Tag', 'coordenacao_responsavel');
                    if ~isempty(hComponent)
                        automaticData.coord_fi_plai = hComponent.Value;
                    end
                end
            end

            % SERVIÇOS
            if ~isempty(app.config_ServicoInspecao.CheckedNodes)
                automaticData.servicos_da_inspecao = {app.config_ServicoInspecao.CheckedNodes.Text};
            end

            % SITUAÇÃO
            if ismember('Irregular', app.projectData.listOfProducts.('Situação'))
                automaticData.situacao_constatada = 'Irregular';

                irregularidade = {};
                if ismember('Comercialização', app.projectData.listOfProducts.('Infração'))
                    irregularidade = [irregularidade, {'Comercialização de produtos'}];
                end

                if ismember('Uso', app.projectData.listOfProducts.('Infração'))
                    irregularidade = [irregularidade, {'Utilização de produtos'}];
                end

                if ~isempty(irregularidade)
                    automaticData.irregularidade = irregularidade;
                end
            else
                automaticData.situacao_constatada = 'Regular';
            end
        end


        %-----------------------------------------------------------------%
        % MISCELÂNEAS
        %-----------------------------------------------------------------%

        %-----------------------------------------------------------------%
        % Aqui ficarão as funções relacionadas à GUI que são chamadas por 
        % módulos diferentes do app.
        %
        % Por exemplo, as funções relacionadas às tabelas dos modos SEARCH
        % e REPORT. São operações logicalmente idênticas, mas com componentes
        % diferentess.
        %
        % Em relação à nomenclatura de linha(s) selecionada(s) em uma das
        % tabelas, tem-se:
        % - selectedHom.......: Lista de homologações selecionados (cell array).
        % - showedHom.........: Homologação apresentada em painel de metadados.
        % - selected2showedHom: Em processo de atualização do painel de metadados.
        %                       De selectedHom{1} para showedHom...
        %-----------------------------------------------------------------%
        function misc_Panel_menuButtonPushed(app, operationMode, tabIndex, subIndex)
            NN = eval(sprintf('numel(app.%s_ControlMenu.ColumnWidth)', operationMode));

            for ii = 1:NN
                switch ii
                    case subIndex
                        eval(sprintf('app.%s_menuBtn%dGrid.ColumnWidth{2} = "1x";', operationMode, ii))
                    otherwise
                        eval(sprintf('app.%s_menuBtn%dGrid.ColumnWidth{2} = 0;',    operationMode, ii))
                end
            end

            columnWidth           = repmat({22}, 1, NN);
            columnWidth(subIndex) = {'1x'};

            eval(sprintf('app.%s_ControlMenu.ColumnWidth     = columnWidth;', operationMode))
            eval(sprintf('app.%s_menuUnderline.Layout.Column = subIndex;',    operationMode))
            eval(sprintf('app.%s_ControlTabGroup.SelectedTab = app.%s_ControlTabGroup.Children(subIndex);', operationMode, operationMode))

            jsBackDoor_Customizations(app, tabIndex)

            focus(app.jsBackDoor)
        end


        %-----------------------------------------------------------------%
        function [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, operationMode)
            switch operationMode
                case 'search'
                    table2Search = app.search_Table;
                    panel2Search = app.search_ProductInfo;
                case 'report'
                    table2Search = app.report_Table;
                    panel2Search = app.report_ProductInfo;
            end

            selectedRow = table2Search.Selection;
            if ~isempty(selectedRow)
                selectedHom = unique(table2Search.Data.("Homologação")(selectedRow), 'stable');
            else
                selectedHom = {};
            end        
            showedHom = panel2Search.UserData.showedHom;
        end


        %-----------------------------------------------------------------%
        function misc_Table_NumberOfRows(app, operationMode)
            switch operationMode
                case 'search'
                    nRows = height(app.search_Table.Data);
                    app.search_nRows.Text = sprintf('# %d ', nRows);
                case 'report'
                    nRows = height(app.report_Table.Data);
                    app.report_nRows.Text = sprintf('# %d ', nRows);
            end
        end


        %-----------------------------------------------------------------%
        function htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable)
            if isempty(selected2showedHom)
                htmlSource = 'Warning.html';

            else
                if ~strcmp(selected2showedHom, '-1')
                    selectedHomRawTableIndex = find(strcmp(app.rawDataTable.("Homologação"), selected2showedHom));
                    htmlSource = fcn.htmlCode_rowTableInfo('ProdutoHomologado', app.rawDataTable(selectedHomRawTableIndex, :), relatedAnnotationTable);

                else
                    % Esse é um caso específico do modo "REPORT", quando é
                    % selecionado registro de um produto não homologado,
                    % cuja homologação é preenchido como -1. Nesse caso,
                    % deve-se identificar a linha selecionada da tabela (do 
                    % modo "REPORT) pois podem existir mais de um registro 
                    % com o número igual a -1.
                    %
                    % O bloco try/catch é apenas por precaução. Não foi 
                    % evidenciado erro nos testes de uso do app.

                    try
                        selectedRow = app.report_Table.Selection(1);
                        htmlSource = fcn.htmlCode_rowTableInfo('ProdutoNãoHomologado', app.projectData.listOfProducts(selectedRow, :));
                    catch
                        htmlSource = 'Warning.html';
                    end
                end
            end
        end


        %-----------------------------------------------------------------%
        function misc_SelectedHomPanel_InfoUpdate(app, operationMode, htmlSource, selectedRow, selected2showedHom)
            userData = struct('selectedRow', selectedRow, 'showedHom', selected2showedHom);
            switch operationMode
                case 'search'
                    set(app.search_ProductInfo, 'HTMLSource', htmlSource, 'UserData', userData)
                case 'report'
                    set(app.report_ProductInfo, 'HTMLSource', htmlSource, 'UserData', userData)
            end
        end


        %-----------------------------------------------------------------%
        function config_DataHubWarningLamp(app)
            DataHub_GET  = app.General.fileFolder.DataHub_GET;
            DataHub_POST = app.General.fileFolder.DataHub_POST;

            if isfolder(DataHub_GET) && isfolder(DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end


        %-----------------------------------------------------------------%
        function config_FiscalizaModeLayout(app)
            selectedButton = app.config_FiscalizaVersion.SelectedObject;
            switch selectedButton
                case app.config_FiscalizaPD
                    app.report_Fiscaliza_PanelLabel.Text = 'API FISCALIZA';
                    app.General.fiscaliza.systemVersion  = 'PROD';

                case app.config_FiscalizaHM
                    app.report_Fiscaliza_PanelLabel.Text = 'API FISCALIZA HOMOLOGAÇÃO';
                    app.General.fiscaliza.systemVersion  = 'HOM';
            end
        end


        %-----------------------------------------------------------------%
        function config_FiscalizaDefaultValues(app)
            set(app.config_CadastroSTEL, 'Items', app.General.fiscaliza.defaultValues.entidade_com_cadastro_stel.options, ...
                                         'Value', app.General.fiscaliza.defaultValues.entidade_com_cadastro_stel.value)

            set(app.config_GerarPLAI,    'Items', app.General.fiscaliza.defaultValues.gerar_plai.options, ...
                                         'Value', app.General.fiscaliza.defaultValues.gerar_plai.value)

            set(app.config_TipoPLAI,     'Items', app.General.fiscaliza.defaultValues.tipo_do_processo_plai.options, ...
                                         'Value', app.General.fiscaliza.defaultValues.tipo_do_processo_plai.value)

            % app.config_MotivoLAI
            config_FiscalizaFillTree(app, 'config_MotivoLAI',       'motivo_de_lai')
            config_FiscalizaFillTree(app, 'config_ServicoInspecao', 'servicos_da_inspecao')
        end


        %-----------------------------------------------------------------%
        function config_FiscalizaFillTree(app, componentName, fieldName)
            fieldOptions = app.General.fiscaliza.defaultValues.(fieldName).options;
            fieldValue   = app.General.fiscaliza.defaultValues.(fieldName).value;
            for ii = 1:numel(fieldOptions)
                childNode = uitreenode(app.(componentName), 'Text', fieldOptions{ii});
                if ismember(fieldOptions{ii}, fieldValue)
                    app.(componentName).CheckedNodes = [app.(componentName).CheckedNodes; childNode];
                end
            end
        end
end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            try
                % WARNING MESSAGES
                appUtil.disablingWarningMessages()

                % <GUI>
                app.UIFigure.Position(4) = 660;
                app.popupContainerGrid.Layout.Row = [1,2];
                app.GridLayout.RowHeight = {44, '1x'};

                app.search_mainGrid.ColumnWidth{1}  = 0;

                app.search_Tab1Grid.RowHeight(4:14) = repmat({0}, 1, 11);
                app.report_Tab1Grid.RowHeight(4:7)  = {0,0,0,0};
                
                config_ButtonGroupSelectionChanged(app)
                % </GUI>

                appUtil.winPosition(app.UIFigure)
                jsBackDoor_Initialization(app)
                startup_timerCreation(app)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            % BASE DE ANOTAÇÕES
            writeFile.Annotation(app.rootFolder, app.General.fileFolder.DataHub_POST, app.annotationTable);
    
            % TIMER
            h = timerfindall;
            if ~isempty(h)
                stop(h); delete(h); clear h
            end

            % PROGRESS DIALOG
            delete(app.progressDialog)

            % MATLAB RUNTIME
            % Ao fechar um webapp, o MATLAB WebServer demora uns 10 segundos para
            % fechar o Runtime que suportava a sessão do webapp. Dessa forma, a 
            % liberação do recurso, que ocorre com a inicialização de uma nova 
            % sessão do Runtime, fica comprometida.
            appUtil.killingMATLABRuntime(app.executionMode)

            delete(app)
            
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            
            % O listener que captura cliques do mouse só é aplicável no
            % modo SEARCH.
            if app.TabGroup.SelectedTab ~= app.TabGroup.Children(1)
                return
            end

            hitObject = struct(event).HitObject;
            switch hitObject
                case app.search_entryPoint
                    switch app.search_entryPoint.Value
                        case 'O que você quer pesquisar?'
                            set(app.search_entryPoint, 'FontColor', [0,0,0], 'Value', '')

                        otherwise
                            if app.config_SearchModeTokenSuggestion.Value 
                                if numel(app.search_entryPoint.Value) >= app.config_nMinCharacters.Value
                                    app.search_Suggestions.Visible = 1;
                                end
                            end
                    end

                case app.search_Suggestions
                    if isempty(app.search_Suggestions.Value)
                        waitfor(app.search_Suggestions, 'Value')
                    end

                    jsBackDoor_Listener(app, struct('HTMLEventName', 'app.search_Suggestions', 'HTMLEventData', 'Enter'))

                otherwise
                    set(app.search_Suggestions, Visible=0, Value={})
                    if isempty(app.search_entryPoint.Value)
                        search_EntryPoint_InitialValue(app)
                    end
            end

        end

        % Value changed function: menu_Button1, menu_Button2, menu_Button3
        function menu_mainButtonPushed(app, event)
            
            clickedButton = event.Source;

            if event.PreviousValue
                clickedButton.Value = true;
                return
            end

            if ~app.TabGroup.Visible
                app.TabGroup.Visible = 1;
            end

            tabIndex      = clickedButton.UserData.tabGroup;
          % tabIndex      = str2double(clickedButton.Tag);

            nonClickedButtons = findobj(app.menu_Grid, 'Type', 'uistatebutton', '-not', 'Tag', clickedButton.Tag);
            arrayfun(@(x) set(x, 'Value', 0, 'Icon', x.UserData.iconOptions{1}), nonClickedButtons)
            set(clickedButton, 'Icon', clickedButton.UserData.iconOptions{2})
            
            app.TabGroup.SelectedTab = app.TabGroup.Children(tabIndex);
            drawnow

            % A customização somente pode tem efeito se os componentes
            % já tiverem sido renderizados no HTML. Por essa razão, inclui-se 
            % um drawnow após a mudança da aba.
            jsBackDoor_Customizations(app, tabIndex)
            menu_LayoutControl(app, tabIndex)

        end

        % Image clicked function: AppInfo, FigurePosition
        function menu_auxiliarButtonPushed(app, event)
            
            switch event.Source
                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appUtil.winPosition(app.UIFigure)

                case app.AppInfo
                    if isempty(app.AppInfo.Tag)
                        app.progressDialog.Visible = 'visible';
                        app.AppInfo.Tag = fcn.htmlCode_appInfo(app.General, app.rootFolder, app.executionMode, app.rawDataTable, app.releasedData, app.cacheData);
                        app.progressDialog.Visible = 'hidden';
                    end

                    msgInfo = app.AppInfo.Tag;
                    appUtil.modalWindow(app.UIFigure, 'info', msgInfo);
            end

            focus(app.jsBackDoor)

        end

        % Value changing function: search_entryPoint
        function search_EntryPoint_ValueChanging(app, event)

            search_SuggestionAlgorithm(app, event.Value, true)

        end

        % Image clicked function: search_entryPointImage
        function search_EntryPoint_ImageClicked(app, event)
            
            listOfColumns = search_Filtering_PrimaryTableColumns(app);
            selectedMode  = fcn.extractHTMLText(app.config_SearchModePanel.SelectedObject.Text, 'P');            

            if app.config_SearchModeTokenSuggestion.Value
                value2Search = textAnalysis.preProcessedData(app.search_entryPoint.Value);
                words2Search = app.search_Suggestions.Items;
                
                if ~isempty(words2Search)
                    nWords2Search  = numel(words2Search);
                    nWordsContains = sum(contains(words2Search, value2Search));
                    
                    % Criando uma amostra da lista para mostrar em tela, mas 
                    % limitando a lista em 400 caracteres...
                    sizeOfWords    = cellfun(@(x) numel(x), words2Search);
                    
                    for ii = 0:nWords2Search-1
                        if sum(sizeOfWords(1:nWords2Search-ii)) < 256
                            listOfWords = words2Search(1:nWords2Search-ii);
                            break
                        end
                    end
    
                    % Inserindo o texto "e similiares" caso exista alguma
                    % palavra-chave que não contenha o termo a procurar.
                    if nWordsContains < nWords2Search
                        searchNote = ' e similares';
                    else
                        searchNote = '';
                    end
        
                    app.search_Metadata.Text = sprintf('Exibindo resultados para "<b>%s</b>"%s\n<p style="color: #808080; font-size:10px; text-align:justify;">Parâmetros de pesquisa: %s</p>', ...
                                                       app.search_entryPoint.Value, searchNote, jsonencode(struct('Modo', selectedMode, 'Coluna', {listOfColumns}, 'Qtd', sprintf('%d de %d', nWordsContains, nWords2Search), 'Amostra', {listOfWords})));
                    search_Filtering_primaryFilter(app, words2Search)
                end

            else
                words2Search = textAnalysis.preProcessedData(strsplit(app.search_entryPoint.Value, ','));

                if ~isempty(words2Search)
                    app.search_Metadata.Text = sprintf('Exibindo resultados para %s\n<p style="color: #808080; font-size:10px;">Parâmetros de pesquisa: %s</p>', ...
                                                       strjoin("""<b>" + string(words2Search) + "</b>""", ', '), jsonencode(struct('Modo', selectedMode, 'Coluna', {listOfColumns})));
                    search_Filtering_primaryFilter(app, words2Search)
                end
            end

        end

        % Selection changed function: search_Table
        function search_Table_SelectionChanged(app, event)
            
            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'search');

            if ~isempty(selectedHom)
                if ~ismember(showedHom, selectedHom)
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, selectedRow(1), selected2showedHom)
    
                    % Apresenta a nuvem de palavras apenas se visível...
                    if app.search_Tab1Grid.RowHeight{8}
                        if search_WordCloud_CheckCache(app, selected2showedHom, relatedAnnotationTable)        
                            search_WordCloud_PlotUpdate(app, selectedRow(1), selected2showedHom, false);
                        end
                    end
    
                    app.search_ToolbarAnnotation.Enable     = 1;
                    app.search_ToolbarListOfProducts.Enable = 1;
                    app.search_ToolbarWordCloud.Enable      = 1;
                    app.search_WordCloudRefresh.Enable      = 1;
                end

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, 'search', htmlSource, [], '')

                if ~isempty(app.wordCloudObj) && ~isempty(app.search_WordCloudPanel.Tag)
                    app.wordCloudObj.Table        = [];
                    app.search_WordCloudPanel.Tag = '';
                end

                app.search_ToolbarAnnotation.Enable     = 0;
                app.search_ToolbarWordCloud.Enable      = 0;
                app.search_ToolbarListOfProducts.Enable = 0;
                app.search_WordCloudRefresh.Enable      = 0;                
            end

            search_Panel_Visibility(app)
            
        end

        % Selection changed function: search_PrimaryPanel
        function search_Filtering_primaryTableColumnsChanged(app, event)
            
            app.previousSearch = '';

            search_EntryPoint_InitialValue(app)
            search_SuggestionPanel_InitialValues(app)

        end

        % Image clicked function: search_ToolbarAnnotation, 
        % ...and 2 other components
        function search_Panel_ToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.search_ToolbarAnnotation
                    if app.search_Tab1Grid.RowHeight{6}
                        app.search_ToolbarAnnotation.ImageSource = app.search_ToolbarAnnotation.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(6:7)       = {0,0};
                        
                        if ~app.search_Tab1Grid.RowHeight{8}
                            app.search_Tab1Grid.RowHeight(4:5)   = {0,0};
                        end

                    else
                        app.search_ToolbarAnnotation.ImageSource = app.search_ToolbarAnnotation.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight(4:7)       = {5,22,5,148};
                    end
                    search_Panel_Visibility(app)

                case app.search_ToolbarWordCloud
                    %app.search_Tab1Grid.RowHeight = {22, 5, '1x', 5, 22, 5, 148, 5, 44, 5, 5, 22, 5, 44, 1};
                    if app.search_Tab1Grid.RowHeight{8}
                        app.search_ToolbarWordCloud.ImageSource   = app.search_ToolbarWordCloud.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(8:10)       = {0,0,0};

                        if ~app.search_Tab1Grid.RowHeight{6}
                            app.search_Tab1Grid.RowHeight(4:5)    = {0,0};
                        end

                    else
                        % O "drawnow nocallbacks" aqui é ESSENCIAL porque o
                        % MATLAB precisa renderizar em tela o container do
                        % WordCloud (um objeto uihtml).
                        app.search_ToolbarWordCloud.ImageSource   = app.search_ToolbarWordCloud.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight([4:5,8:10]) = {5,22,5,121,22};
                        drawnow nocallbacks

                        selectedRow = app.search_ProductInfo.UserData.selectedRow;
                        showedHom   = app.search_ProductInfo.UserData.showedHom;
                        relatedAnnotationTable = search_Annotation_RelatedTable(app, showedHom);

                        if search_WordCloud_CheckCache(app, showedHom, relatedAnnotationTable)
                            search_WordCloud_PlotUpdate(app, selectedRow, showedHom, false);
                        end
                    end

                case app.search_ToolbarListOfProducts
                    if app.search_Tab1Grid.RowHeight{11}
                        app.search_ToolbarListOfProducts.ImageSource = app.search_ToolbarListOfProducts.UserData.iconOptions{1};
                        app.search_Tab1Grid.RowHeight(11:14)         = {0,0,0,0};

                    else
                        app.search_ToolbarListOfProducts.ImageSource = app.search_ToolbarListOfProducts.UserData.iconOptions{2};
                        app.search_Tab1Grid.RowHeight(11:14)         = {5,22,5,148};
                    end
            end

            focus(app.jsBackDoor)

        end

        % Image clicked function: search_AnnotationPanelAdd
        function search_Annotation_AddImageClicked(app, event)
            
            % O valor de um objeto "uitextarea" será sempre um cellstr.
            % O arranjo a seguir elimina linhas vazias, concatenando as
            % outras.
            app.search_AnnotationValue.Value = strtrim(app.search_AnnotationValue.Value);
            app.search_AnnotationValue.Value(cellfun(@(x) isempty(x), app.search_AnnotationValue.Value)) = [];
            app.search_AnnotationValue.Value = strjoin(app.search_AnnotationValue.Value, ' ');

            selectedRow    = app.search_ProductInfo.UserData.selectedRow;
            showedHom      = app.search_ProductInfo.UserData.showedHom;
            
            attributeName  = app.search_AnnotationAttribute.Value;
            attributeValue = char(app.search_AnnotationValue.Value);

            if ~isempty(attributeValue)
                search_Annotation_Add2Cache(app, selectedRow, showedHom, attributeName, attributeValue, false)

            else
                appUtil.modalWindow(app.UIFigure, 'warning', 'Deve ser informado o valor do atributo.');
            end

        end

        % Image clicked function: search_WordCloudRefresh
        function search_WordCloud_RefreshImageClicked(app, event)
            
            % Primeiro tenta atualizar a nuvem de palavras...
            selectedRow = app.search_ProductInfo.UserData.selectedRow;
            showedHom   = app.search_ProductInfo.UserData.showedHom;
            search_WordCloud_PlotUpdate(app, selectedRow, showedHom, true);

            focus(app.jsBackDoor)

        end

        % Image clicked function: search_ListOfProductsAdd
        function search_Report_ListOfProductsAddImageClicked(app, event)
            
            [selectedHom, showedHom] = misc_Table_SelectedRow(app, 'search');
            
            if isempty(selectedHom)
                msgWarning = 'Selecione ao menos um registro na tabela.';
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return

            else
                if ~isequal(selectedHom, {showedHom})
                    msgQuestion = sprintf(['<p style="font-size: 12px; text-align: justify;">Homologação apresentada no <b>PAINEL</b> à esquerda:\n• %s\n\n' ...
                                           'Homologações selecionadas em <b>TABELA</b>:\n%s\n\n'                                          ...
                                           'Quais os registros devem ser adicionados à lista de produtos sob análise?</p>'], showedHom, strjoin("• " + string(selectedHom), '\n'));
                    
                    selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',                           ...
                                                                           'Options', {' PAINEL ', ' TABELA ', 'CANCELAR'}, ...
                                                                           'DefaultOption', 1, 'CancelOption', 3, 'Icon', 'question');
        
                    switch selection
                        case ' PAINEL '
                            listOfHom2Add = {showedHom};
                        case ' TABELA '
                            listOfHom2Add = selectedHom;
                        case 'CANCELAR'
                            return
                    end

                else
                    listOfHom2Add = selectedHom;
                end

                % Certificando que não será incluído um registro que já
                % consta em base...
                listOfHom2Add = setdiff(listOfHom2Add, app.projectData.listOfProducts.("Homologação"));
                report_ListOfProductsAdd(app, 'search', listOfHom2Add)
            end

            focus(app.jsBackDoor)

        end

        % Value changed function: search_SecundaryColumn
        function search_SecundaryColumnValueChanged(app, event)
            
            columnName  = app.search_SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            switch filterType
                case 'datetime'
                    Operations = {'=', '≠', '<', '≤', '>', '≥', '><', '<>', '⊃', '⊅'};

                case 'freeText'
                    Operations = {'=', '≠', '⊃', '⊅'};

                case 'listOfText'
                    Operations = {'=', '≠'};
            end
            app.search_SecundaryOperation.Items = Operations;

            app.search_SecundaryOperation.Value = app.search_SecundaryOperation.Items{1};
            search_SecundaryOperationValueChanged(app)


        end

        % Value changed function: search_SecundaryOperation
        function search_SecundaryOperationValueChanged(app, event)
            
            columnName  = app.search_SecundaryColumn.Value;
            columnIndex = find(strcmp(app.General.SCHDataInfo.Column, columnName), 1);

            filterType  = app.General.SCHDataInfo.FilterType{columnIndex};
            selectedOperation = app.search_SecundaryOperation.Value;
            switch filterType
                case 'datetime'
                    switch selectedOperation
                        case {'=', '≠', '<', '≤', '>', '≥'}
                            set(app.search_SecundaryDateTime1,         'Visible', 1)
                            set(app.search_SecundaryDateTimeSeparator, 'Visible', 0)
                            set(app.search_SecundaryDateTime2,         'Visible', 0)
                            set(app.search_SecundaryTextFreeValue,     'Visible', 0)
                            set(app.search_SecundaryTextListValue,     'Visible', 0, 'Items', {})
                            
                        case {'><', '<>'}
                            set(app.search_SecundaryDateTime1,         'Visible', 1)
                            set(app.search_SecundaryDateTimeSeparator, 'Visible', 1)
                            set(app.search_SecundaryDateTime2,         'Visible', 1)
                            set(app.search_SecundaryTextFreeValue,     'Visible', 0)
                            set(app.search_SecundaryTextListValue,     'Visible', 0, 'Items', {})

                        case {'⊃', '⊅'}
                            set(app.search_SecundaryDateTime1,         'Visible', 0)
                            set(app.search_SecundaryDateTimeSeparator, 'Visible', 0)
                            set(app.search_SecundaryDateTime2,         'Visible', 0)
                            set(app.search_SecundaryTextFreeValue,     'Visible', 1)
                            set(app.search_SecundaryTextListValue,     'Visible', 0, 'Items', {})
                    end

                case 'freeText'
                    set(app.search_SecundaryDateTime1,         'Visible', 0)
                    set(app.search_SecundaryDateTimeSeparator, 'Visible', 0)
                    set(app.search_SecundaryDateTime2,         'Visible', 0)
                    set(app.search_SecundaryTextFreeValue,     'Visible', 1)
                    set(app.search_SecundaryTextListValue,     'Visible', 0, 'Items', {})

                case 'listOfText'
                    try
                        primaryIndex = app.search_Table.UserData.primaryIndex;
                        columnItems  = [{''}; cellstr(unique(app.rawDataTable{primaryIndex, columnName}))];
                    catch
                        columnItems = {};
                    end

                    set(app.search_SecundaryDateTime1,         'Visible', 0)
                    set(app.search_SecundaryDateTimeSeparator, 'Visible', 0)
                    set(app.search_SecundaryDateTime2,         'Visible', 0)
                    set(app.search_SecundaryTextFreeValue,     'Visible', 0)
                    set(app.search_SecundaryTextListValue,     'Visible', 1, 'Items', columnItems)
            end
            
        end

        % Image clicked function: search_SecundaryAddFilter
        function search_SecundaryAddFilterImageClicked(app, event)
            
            primaryIndex = app.search_Table.UserData.primaryIndex;
            if isempty(primaryIndex)
                appUtil.modalWindow(app.UIFigure, 'warning', 'A filtragem secundária é aplicável apenas após a realização de uma pesquisa (filtragem primária), e desde que tenha retornado algum registro dessa pesquisa.');
                return
            end

            % Afere os valores do novo filtro, validando-os.
            Column    = app.search_SecundaryColumn.Value;
            Operation = app.search_SecundaryOperation.Value;
            
            [Value, msgWarning] = search_Filtering_SecundaryFilterValue(app);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return
            end

            % Adiciona um novo filtro à lista de filtros secundários.
            msgWarning = addFilterRule(app.filteringObj, Column, Operation, Value);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'warning', msgWarning);
                return
            end

            % Atualiza lista de filtros.
            search_Filtering_SecundaryFilterLayout(app)

            % Aplica estilo nos desabilitados...
            pause(1)

            % Filtra...
            search_Filtering_secundaryFilter(app)

        end

        % Image clicked function: report_ReportGeneration
        function report_ReportGenerationImageClicked(app, event)
            
            % VALIDAÇÕES
            if isempty(app.projectData.listOfProducts)
                appUtil.modalWindow(app.UIFigure, 'warning', 'A lista de produtos sob análise está vazia!');
                return
            end

            msgWarning = {};
            if ~report_checkValidIssueID(app)
                msgWarning{end+1} = sprintf('• O número da inspeção "%.0f" é inválido.', app.report_Issue.Value);
            end

            nEntity = strtrim(app.report_Entity.Value);
            try
                [~, nCNPJ] = checkCNPJ(app.report_EntityID.Value, false);
            catch
                nCNPJ = '';
            end

            if isempty(nEntity) || isempty(nCNPJ) || isempty(app.report_EntityType.Value)
                msgWarning{end+1} = '• Qualificação da fiscalizada ainda pendente.';
            end

            listOfRows = report_ListOfProductsCheck(app);
            if ~isempty(listOfRows)
                msgWarning{end+1} = sprintf('• Os registros da(s) linha(s) %s estão incompletos.', strjoin(string(listOfRows), ', '));
            end

            if ~isempty(msgWarning)
                msgInfo     = ['____________<br>VALIDAÇÕES<br>(a) Em relação à <b>INSPEÇÃO</b>:<br>'  ...
                               '• O número deve ser válido (inteiro, positivo e finito).<br>' ...
                               '(b) Em relação à qualificação da <b>FISCALIZADA</b>:<br>'  ...
                               '• O nome deve ser preenchido;<br>' ...
                               '• O número do CPF/CNPJ deve ser válido; e<br>' ...
                               '• O tipo não pode ser vazio.<br>' ...
                               '(c) Em relação à <b>TABELA</b> com a lista de produtos sob análise:<br>'  ...
                               '• O "Tipo" não pode ter valor igual a -1;<br>' ...
                               '• O "Fabricante" e o "Modelo" não podem ter valores vazios;<br>' ...
                               '• O "Valor Unit. (R$)" não pode ser igual a zero;<br>' ...
                               '• A soma de "Qtd. uso/vendida" e "Qtd. estoque/aduana" não pode ser igual a zero;<br>' ...
                               '• A soma de "Qtd. uso/vendida" e "Qtd. estoque/aduana" não pode ser menor do que a soma de "Qtd. lacradas", "Qtd. apreendidas", Qtd. retidas (RFB)".'];

                switch app.report_Version.Value
                    case 'Definitiva'
                        msgInfo     = sprintf(['<p style="font-size: 12px; text-align: justify;">Foi(ram) identificado(s) a(s) pendência(s):\n%s\n\n' ...
                                               '<b>Essas pendências precisam ser resolvidas antes de ser gerada a versão "Definitiva" do relatório.</b><br><br><font style="color: gray; font-size: 11px;">%s</font></p>'], strjoin(msgWarning, '<br>'), msgInfo);
                        appUtil.modalWindow(app.UIFigure, 'warning', msgInfo);
                        return


                    case 'Preliminar'
                        msgQuestion = sprintf(['<p style="font-size: 12px; text-align: justify;">Foi(ram) identificado(s) a(s) pendência(s):\n%s\n\n' ...
                                               '<b>Continuar mesmo assim?</b><br><br><font style="color: gray; font-size: 11px;">%s</font></p>'], strjoin(msgWarning, '<br>'), msgInfo);
                        selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',     ...
                                                                               'Options', {'SIM', 'NÃO'}, ...
                                                                               'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
            
                        if strcmp(selection, 'NÃO')
                            return
                        end
                end
            end

            app.progressDialog.Visible = 'visible';
            try
                [HTMLDocFullPath, CSVDocFullPath] = reportLibConnection.Controller.Run(app, true);
                
                switch app.report_Version.Value
                    case 'Definitiva'
                        app.General.fiscaliza.lastHTMLDocFullPath = HTMLDocFullPath;
                        app.General.fiscaliza.lastTableFullPath   = CSVDocFullPath;
                    case 'Preliminar'
                        app.General.fiscaliza.lastHTMLDocFullPath = '';
                        app.General.fiscaliza.lastTableFullPath   = '';
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'warning', getReport(ME));
            end
            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: report_ShowCells2Edit
        function report_ShowCells2EditClicked(app, event)

            if ~isempty(app.projectData.listOfProducts)
                listOfRows = report_ListOfProductsCheck(app);
                if isempty(listOfRows)
                    appUtil.modalWindow(app.UIFigure, 'warning', 'Não foi identificada pendência na lista de produtos sob análise.');
                    return
                end

                switch app.report_ShowCells2Edit.Tag
                    case 'on'
                        app.report_ShowCells2Edit.Tag = 'off';
                        report_Table_AddStyle(app, 'Icon')
    
                    case 'off'
                        app.report_ShowCells2Edit.Tag = 'on';
                        report_Table_AddStyle(app, 'BackgroundColor')
                end

            else
                % Não evidenciei essa condição... mas, por precaução,
                % inserido esse estado p/ evitar cliques desnecessários.
                app.report_ShowCells2Edit.Enable = 0;
            end
            
            focus(app.jsBackDoor)

        end

        % Image clicked function: report_ToolbarEditOrAdd
        function report_ToolbarEditOrAddImageClicked(app, event)
            
            if app.report_Tab1Grid.RowHeight{4}
                app.report_ToolbarEditOrAdd.ImageSource = app.report_ToolbarEditOrAdd.UserData.iconOptions{1};
                app.report_Tab1Grid.RowHeight(4:7)      = {0,0,0,0};

            else
                app.report_ToolbarEditOrAdd.ImageSource = app.report_ToolbarEditOrAdd.UserData.iconOptions{2};
                app.report_Tab1Grid.RowHeight(4:7)      = {5,22,5,292};
            end

            focus(app.jsBackDoor)

        end

        % Selection changed function: report_Table
        function report_TableSelectionChanged(app, event)
            
            [selectedHom, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'report');

            if ~isempty(selectedHom)
                updateFlag = false;

                if ~strcmp(selectedHom, '-1')
                    if ~ismember(showedHom, selectedHom)
                        updateFlag = true;
                    end                    
                else
                    if ~isequal(selectedRow, app.report_ProductInfo.UserData.selectedRow)
                        updateFlag = true;
                    end
                end

                if updateFlag
                    % Escolhe o primeiro registro da lista de homologações selecionadas
                    % em tabela.
                    selected2showedHom     = selectedHom{1};
                    relatedAnnotationTable = search_Annotation_RelatedTable(app, selected2showedHom);

                    htmlSource = misc_SelectedHomPanel_InfoCreation(app, selected2showedHom, relatedAnnotationTable);
                    misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, selectedRow(1), selected2showedHom)
                    report_SelectedHomPanel_InfoUpdate(app, selected2showedHom, selectedRow(1))
                end                

            else
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, '', []);
                misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, [], '')
                report_SelectedHomPanel_InfoUpdate(app, '', [])
            end

            app.report_EditOrAddButton.Enable = 0;

        end

        % Cell edit callback: report_Table
        function report_TableCellEdit(app, event)
            
            if isequal(event.PreviousData, event.NewData)
                return

            elseif isnumeric(event.NewData) 
                if (event.NewData < 0) || isnan(event.NewData)
                    event.Source.Data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                    return
                end
            end

            % Grosseria! :)
            app.projectData.listOfProducts(:, [1, 4:15]) = app.report_Table.Data;
            
            style2Apply = report_Table_Style2Apply(app);
            report_Table_AddStyle(app, style2Apply)

            report_ProjectWarnImageVisibility(app)

            % Atualizando o painel de metadados do registro selecionado...
            % (só pode ser editada uma célular por vez)
            [~, showedHom, selectedRow] = misc_Table_SelectedRow(app, 'report');
            if strcmp(showedHom, '-1')    
                htmlSource = misc_SelectedHomPanel_InfoCreation(app, showedHom, []);
                misc_SelectedHomPanel_InfoUpdate(app, 'report', htmlSource, selectedRow, showedHom)
            end

        end

        % Selection changed function: report_productSituationPanel
        function report_productSituationPanelSelectionChanged(app, event)
            
            selectedButton = app.report_productSituationPanel.SelectedObject;
            
            switch selectedButton
                case app.report_productSituation1 % HOMOLOGADO
                    set(app.report_nHom, 'Enable', 1, 'Value', '')

                case app.report_productSituation2 % NÃO HOMOLOGADO
                    set(app.report_nHom, 'Enable', 0, 'Value', '-1')
            end
            
        end

        % Image clicked function: report_EditOrAddButton
        function report_EditOrAddButtonImageClicked(app, event)
            
            app.report_EditOrAddButton.Enable = 0;

            [~, showedHom] = misc_Table_SelectedRow(app, 'report');
            selectedHom = app.report_nHom.Value;

            if isempty(showedHom)
                srcMode = 'report - addRow';

                if ~strcmp(selectedHom, '-1')
                    if ismember(selectedHom, app.projectData.listOfProducts.("Homologação"))
                        appUtil.modalWindow(app.UIFigure, 'warning', sprintf('O número de homologação "%s" já foi incluído à lista de produtos sob análise.', selectedHom));
                        return
    
                    elseif ~ismember(selectedHom, app.rawDataTable.("Homologação"))
                        appUtil.modalWindow(app.UIFigure, 'warning', sprintf('O número de homologação "%s" não foi encontrado na base de dados. O formato esperado para esse campo é XXXXX-XX-XXXXX.', selectedHom));
                        return
                    end
                end      

            else
                srcMode = 'report - edit';
            end
      
            report_ListOfProductsAdd(app, srcMode, {selectedHom})

            focus(app.jsBackDoor)

        end

        % Value changed function: report_Situation
        function report_SituationValueChanged(app, event)
            
            switch app.report_Situation.Value
                case 'Irregular'
                    set(app.report_Violation,  'Enable', 1, 'Items', app.General.typeOfViolation)
                    set(app.report_Corrigible, 'Enable', 1, 'Items', {'Sim', 'Não'})
                case 'Regular'
                    set(app.report_Violation,  'Enable', 0, 'Items', {''})
                    set(app.report_Corrigible, 'Enable', 0, 'Items', {''})
            end
            report_EnablingEditOrAddImage(app)
            
        end

        % Value changed function: report_ModelName
        function report_ModelNameValueChanged(app, event)
            
            if ~isempty(app.projectData.listOfProducts) && ~isempty(app.report_ModelName.Value)
                app.report_ReportGeneration.Enable = 1;
            else
                app.report_ReportGeneration.Enable = 0;
            end

        end

        % Callback function: ImportadorEditField, report_Corrigible, 
        % ...and 4 other components
        function report_EnablingEditOrAddImage(app, event)
            
            app.report_EditOrAddButton.Enable = 1;
            
        end

        % Image clicked function: report_ProjectNew, report_ProjectOpen, 
        % ...and 1 other component
        function report_ProjectToolbarImageClicked(app, event)
            
            switch event.Source
                case app.report_ProjectNew
                    if isempty(app.projectData.listOfProducts)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de produtos a analisar não está vazia.');
                        return
                    end

                    msgQuestion = '<p style="font-size:12px; text-align:justify;">Deseja excluir a lista de produtos sob análise, iniciando um novo projeto?</p>';
                    selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',               ...
                                                                           'Options', {'   OK   ', 'CANCELAR'}, ...
                                                                           'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
                    if strcmp(selection, 'CANCELAR')
                        return
                    end

                    app.search_ListOfProducts.Items = {};
                    app.projectData.listOfProducts(:,:)         = [];
                    
                    report_UpdatingTable(app)
                    report_TableSelectionChanged(app)

                    app.report_ProjectName.Value = '';
                    app.report_Issue.Value       = -1;
                    app.report_Entity.Value      = '';
                    app.report_EntityID.Value    = '';
                    app.report_EntityType.Value  = '';

                    app.report_ProjectWarnIcon.Visible = 0;

                    report_FiscalizaResetGUI(app)

                %---------------------------------------------------------%
                case app.report_ProjectOpen
                    if ~isempty(app.projectData.listOfProducts)
                        msgQuestion = '<p style="font-size:12px; text-align:justify;">Ao abrir um projeto, a lista de produtos sob análise será sobrescrita. Confirma a operação?</p>';
                        selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',               ...
                                                                               'Options', {'   OK   ', 'CANCELAR'}, ...
                                                                               'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
                        if strcmp(selection, 'CANCELAR')
                            return
                        end
                    end

                    [fileName, filePath] = uigetfile({'*.mat', 'SCH (*.mat)'}, '', app.General.fileFolder.lastVisited);
                    figure(app.UIFigure)
                    
                    if fileName
                        fileFullPath = fullfile(filePath, fileName);

                        try
                            [~, ~, variables, ~]         = readFile.MAT(fileFullPath);
                            app.projectData.listOfProducts           = variables.listOfProducts;
    
                            % Atualizando os componentes da GUI...
                            app.report_ProjectName.Value = fileFullPath;
                            app.report_Issue.Value       = variables.projectIssue;
                            app.report_Entity.Value      = variables.entityName;
                            app.report_EntityID.Value    = variables.entityID;
                            app.report_EntityType.Value  = variables.entityType;
    
                            report_UpdatingTable(app)
                            report_TableSelectionChanged(app)
    
                            report_ListOfHomProductsUpdating(app)
                            app.report_ProjectWarnIcon.Visible = 0;

                            app.General.fileFolder.lastVisited = filePath;
                            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General, app.executionMode)
    
                        catch ME
                            appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                        end
                    end

                %---------------------------------------------------------%
                case app.report_ProjectSave
                    if isempty(app.projectData.listOfProducts)
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Operação aplicável apenas quando a lista de produtos a analisar não está vazia.');
                        return
                    end

                    if ~isempty(app.report_ProjectName.Value{1})
                        defaultFilename = app.report_ProjectName.Value{1};
                    else
                        defaultFilename = class.Constants.DefaultFileName(app.config_Folder_userPath.Value, 'SCH', app.report_Issue.Value);
                    end

                    [fileName, filePath] = uiputfile({'*.mat', 'SCH (*.mat)'}, '', defaultFilename);
                    figure(app.UIFigure)
                    
                    if fileName
                        variables = struct('listOfProducts', app.projectData.listOfProducts,           ...
                                           'projectName',    fullfile(filePath, fileName), ...
                                           'projectIssue',   app.report_Issue.Value,       ...
                                           'entityName',     app.report_Entity.Value,      ...
                                           'entityID',       app.report_EntityID.Value,    ...
                                           'entityType',     app.report_EntityType.Value);
                        userData  = [];

                        msgError  = writeFile.MAT(fullfile(filePath, fileName), 'ProjectData', 'SCH', variables, userData);
                        if ~isempty(msgError)
                            appUtil.modalWindow(app.UIFigure, 'error', msgError);
                            return
                        end

                        app.report_ProjectName.Value = fullfile(filePath, fileName);
                        app.report_ProjectWarnIcon.Visible = 0;
                    end
            end
            
        end

        % Value changed function: report_Entity, report_EntityID, 
        % ...and 2 other components
        function report_ProjectWarnImageVisibility(app, event)

            if ~isempty(app.report_ProjectName.Value{1})
                app.report_ProjectWarnIcon.Visible = 1;
            end

        end

        % Image clicked function: Image
        function report_EntityIDCheck(app, event)
            
            entityID = regexprep(app.report_EntityID.Value, '\D', '');
            if isempty(entityID)
                appUtil.modalWindow(app.UIFigure, 'info', 'Consulta limitada a valores não nulos de CNPJ.');
                return
            end

            if ~isempty(app.report_EntityID.UserData) && isequal(regexprep(app.report_EntityID.UserData.cnpj, '\D', ''), entityID)
                CNPJ = app.report_EntityID.UserData;
                appUtil.modalWindow(app.UIFigure, 'info', jsonencode(CNPJ, "PrettyPrint", true));

            else
                try                
                    CNPJ = checkCNPJ(app.report_EntityID.Value);
    
                    app.report_EntityID.UserData = CNPJ;
                    appUtil.modalWindow(app.UIFigure, 'info', jsonencode(CNPJ, "PrettyPrint", true));
                
                catch ME
                    appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                end
            end

        end

        % Image clicked function: report_FiscalizaAutoFillImage, 
        % ...and 2 other components
        function report_FiscalizaCallbacks(app, event)
            
            switch event.Source
                case app.report_FiscalizaRefresh
                    report_FiscalizaConnect(app, [], 'RefreshIssue')

                case app.report_FiscalizaAutoFillImage
                    report_FiscalizaAutoFill(app)

                case app.report_FiscalizaUpdateImage
                    report_FiscalizaUpdate(app)
            end


        end

        % Image clicked function: config_Folder_DataHubGETButton, 
        % ...and 3 other components
        function config_getFolder(app, event)
            
            try
                relatedFolder = eval(sprintf('app.config_Folder_%s.Value', event.Source.Tag));                    
            catch
                relatedFolder = app.General.fileFolder.(event.Source.Tag);
            end
            
            if isfolder(relatedFolder)
                initialFolder = relatedFolder;
            elseif isfile(relatedFolder)
                initialFolder = fileparts(relatedFolder);
            else
                initialFolder = app.config_Folder_userPath.Value;
            end
            
            selectedFolder = uigetdir(initialFolder);
            figure(app.UIFigure)

            if selectedFolder
                switch event.Source
                    case app.config_Folder_DataHubGETButton
                        appName  = class.Constants.appName;
                        repoName = 'DataHub - GET';

                        if strcmp(app.General.fileFolder.DataHub_GET, selectedFolder) 
                            return
                        elseif all(cellfun(@(x) contains(selectedFolder, x), {repoName, appName}))
                            app.progressDialog.Visible = 'visible';

                            app.config_Folder_DataHubGET.Value = selectedFolder;
                            app.General.fileFolder.DataHub_GET = selectedFolder;
    
                            startup_mainVariables(app)
                            app.AppInfo.Tag = '';
    
                            config_DataHubWarningLamp(app)
                        else
                            appUtil.modalWindow(app.UIFigure, 'error', sprintf('Não identificado se tratar da pasta "%s" do repositório "%s".', appName, repoName));
                        end

                    case app.config_Folder_DataHubPOSTButton
                        appName  = class.Constants.appName;
                        repoName = 'DataHub - POST';

                        if strcmp(app.General.fileFolder.DataHub_POST, selectedFolder) 
                            return
                        elseif all(cellfun(@(x) contains(selectedFolder, x), {repoName, appName}))
                            app.config_Folder_DataHubPOST.Value = selectedFolder;
                            app.General.fileFolder.DataHub_POST = selectedFolder;
    
                            config_DataHubWarningLamp(app)
                        else
                            appUtil.modalWindow(app.UIFigure, 'error', sprintf('Não identificado se tratar da pasta "%s" do repositório "%s".', appName, repoName));
                        end

                    case app.config_Folder_userPathButton
                        set(app.config_Folder_userPath, 'Items', unique([app.config_Folder_userPath.Items, selectedFolder]), ...
                                                        'Value', selectedFolder)
                        app.General.fileFolder.userPath     = selectedFolder;

                    case app.config_Folder_pythonPathButton
                        pythonPath = fullfile(selectedFolder, ccTools.fcn.OperationSystem('pythonExecutable'));
                        if isfile(pythonPath)
                            app.progressDialog.Visible = 'visible';

                            app.config_Folder_pythonPath.Value = pythonPath;
                            app.General.fileFolder.pythonPath  = pythonPath;
                            
                            try
                                pyenv('Version', pythonPath);
                            catch ME
                                appUtil.modalWindow(app.UIFigure, 'error', 'O <i>app</i> deverá ser reinicializado para que a alteração tenha efeito.');
                            end

                        else
                            appUtil.modalWindow(app.UIFigure, 'error', 'Não encontrado o arquivo executável do Python.');
                            return
                        end
                end

                appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General, app.executionMode)
                app.progressDialog.Visible = 'hidden';
            end

        end

        % Selection changed function: config_SearchModePanel
        function config_SearchModeChanged(app, event)
            
            selectedButton = app.config_SearchModePanel.SelectedObject;
            switch selectedButton
                case app.config_SearchModeTokenSuggestion
                    app.search_Document.ColumnWidth = {400, '1x'};

                case app.config_SearchModeListOfWords
                    app.search_Document.ColumnWidth = {'1x', 0};

                    app.previousSearch   = '';
                    app.previousItemData = 0;
                    
                    set(app.search_Suggestions, Visible=0, Items={}, ItemsData=[])
            end

            search_EntryPoint_InitialValue(app)
            
        end

        % Callback function: config_SelectedTableColumns
        function config_ListOfColumns2ShowChanged(app, event)
            
            if ~isempty(app.config_SelectedTableColumns.CheckedNodes)
                checkedColumns = {app.config_SelectedTableColumns.CheckedNodes.Text}';
            else
                checkedColumns = {};
            end

            staticColumns  = search_Table_ColumnInfo(app, 'staticColumns');
            staticColumns(ismember(staticColumns, checkedColumns)) = [];
            
            if ~isempty(staticColumns)
                for ii = 1:numel(staticColumns)
                    staticColumnName = staticColumns{ii};
                    staticTreeNodes  = findobj(app.config_SelectedTableColumns, 'Text', staticColumnName);
                    
                    app.config_SelectedTableColumns.CheckedNodes = [app.config_SelectedTableColumns.CheckedNodes; staticTreeNodes];
                end
            end
            [columnNames, columnWidth] = search_Table_ColumnNames(app);
            set(app.search_Table, 'ColumnName', upper(columnNames), 'ColumnWidth', columnWidth)

            if ~isempty(app.search_Table.Data)
                if (numel(columnNames) ~= width(app.search_Table.Data)) || any(~ismember(app.search_Table.ColumnName, upper(columnNames)))
                    secundaryIndex = app.search_Table.UserData.secundaryIndex;
                    app.search_Table.Data = app.rawDataTable(secundaryIndex, columnNames);
                end
            end
            
        end

        % Value changed function: config_WordCloudAlgorithm
        function config_WordCloudAlgorithmValueChanged(app, event)
            
            if ~isempty(app.wordCloudObj)
                if ~strcmp(app.wordCloudObj.Algorithm, app.config_WordCloudAlgorithm.Value)
                    delete(app.wordCloudObj.Chart.Parent)
                    drawnow nocallbacks

                    app.wordCloudObj = wordCloud(app.search_WordCloudPanel, app.config_WordCloudAlgorithm.Value);
                    app.search_WordCloudPanel.Tag = '';
                    
                    userData = struct('selectedRow', [], 'showedHom', '');
                    app.search_ProductInfo.UserData = userData;

                    search_Table_SelectionChanged(app)
                end
            end

        end

        % Selection changed function: config_FiscalizaVersion
        function config_FiscalizaMode(app, event)
            
            config_FiscalizaModeLayout(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General, app.executionMode)

            % Reinicia o objeto, caso necessário...
            if ~isempty(app.fiscalizaObj)
                delete(app.fiscalizaObj)
                app.fiscalizaObj = [];

                misc_Panel_TabControlButtonPushed(app, struct('Source', app.report_menuBtn1Icon))
                app.report_FiscalizaAutoFillImage.Enable = 0;
                app.report_FiscalizaUpdateImage.Enable   = 0;
            end

        end

        % Callback function: config_CadastroSTEL, config_GerarPLAI, 
        % ...and 3 other components
        function config_FiscalizaDefaultValueChanged(app, event)

            app.General.fiscaliza.defaultValues.entidade_com_cadastro_stel.value = app.config_CadastroSTEL.Value;
            app.General.fiscaliza.defaultValues.gerar_plai.value                 = app.config_GerarPLAI.Value;
            app.General.fiscaliza.defaultValues.tipo_do_processo_plai.value      = app.config_TipoPLAI.Value;

            if ~isempty(app.config_MotivoLAI.CheckedNodes)
                app.General.fiscaliza.defaultValues.motivo_de_lai.value          = {app.config_MotivoLAI.CheckedNodes.Text};
            else
                app.General.fiscaliza.defaultValues.motivo_de_lai.value          = {};
            end

            if ~isempty(app.config_ServicoInspecao.CheckedNodes)
                app.General.fiscaliza.defaultValues.servicos_da_inspecao.value   = {app.config_ServicoInspecao.CheckedNodes.Text};
            else
                app.General.fiscaliza.defaultValues.servicos_da_inspecao.value   = {};
            end
            
            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General, app.executionMode)

        end

        % Image clicked function: report_menuBtn1Icon, 
        % ...and 4 other components
        function misc_Panel_TabControlButtonPushed(app, event)
            
            switch event.Source
                case {app.search_menuBtn1Icon, app.search_menuBtn2Icon}
                    operationMode = 'search';
                    tabIndex = 1;

                case {app.report_menuBtn1Icon, app.report_menuBtn2Icon, app.report_menuBtn3Icon}
                    operationMode = 'report';
                    tabIndex = 2;
            end
            subIndex = str2double(event.Source.Tag);

            % Validação relacionado à API Fiscaliza...
            if ~isequal([tabIndex, subIndex], [2, 3])
                misc_Panel_menuButtonPushed(app, operationMode, tabIndex, subIndex)
                app.report_FiscalizaAutoFillImage.Enable = 0;
                app.report_FiscalizaUpdateImage.Enable   = 0;

            else
                if ~report_checkValidIssueID(app)
                    appUtil.modalWindow(app.UIFigure, 'warning', 'Pendente inserir o número da Inspeção.');
                    return
                end

                if ~isempty(app.fiscalizaObj) && strcmp(app.fiscalizaObj.issueID, num2str(app.report_Issue.Value))
                    misc_Panel_menuButtonPushed(app, operationMode, tabIndex, subIndex)

                else
                    msgQuestion = sprintf('<p style="font-size:12px; text-align:justify;">Deseja obter informações da Inspeção nº %.0f?</p>', app.report_Issue.Value);
                    selection   = uiconfirm(app.UIFigure, msgQuestion, '', 'Interpreter', 'html',               ...
                                                                           'Options', {'   OK   ', 'CANCELAR'}, ...
                                                                           'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'question');
                    if strcmp(selection, 'CANCELAR')
                        return
                    end
    
                    if isempty(app.fiscalizaObj)
                        sendEventToHTMLSource(app.jsBackDoor, 'credentialDialog', struct('UUID', char(matlab.lang.internal.uuid())));
                    else
                        report_FiscalizaConnect(app, [], 'GetIssue')
                    end
                end

                report_FiscalizaToolbarStatus(app)
            end

        end

        % Image clicked function: config_PanelVisibility, 
        % ...and 2 other components
        function misc_Panel_VisibilityImageClicked(app, event)
            
            switch event.Source
                case app.search_PanelVisibility
                    if app.search_mainGrid.ColumnWidth{1}
                        app.search_PanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.search_mainGrid.ColumnWidth{1}     = 0;        
                    else
                        app.search_PanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.search_mainGrid.ColumnWidth{1}     = 330;
                    end

                case app.report_PanelVisibility
                    if app.report_mainGrid.ColumnWidth{1}
                        app.report_PanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.report_mainGrid.ColumnWidth{1}     = 0;        
                    else
                        app.report_PanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.report_mainGrid.ColumnWidth{1}     = 330;
                    end

                case app.config_PanelVisibility
                    if app.config_mainGrid.ColumnWidth{1}
                        app.config_PanelVisibility.ImageSource = 'ArrowRight_32.png';
                        app.config_mainGrid.ColumnWidth{1}     = 0;        
                    else
                        app.config_PanelVisibility.ImageSource = 'ArrowLeft_32.png';
                        app.config_mainGrid.ColumnWidth{1}     = 330;
                    end
            end

            focus(app.jsBackDoor)

        end

        % Menu selected function: ContextMenu_DeleteFcn
        function ContextMenu_DeleteFcnSelected(app, event)
            
            selectedTableIndex = [];
            selectedProduct    = {};

            switch event.ContextObject
                % Relacionado à exclusão de registros de produtos homologados 
                % a analisar.
                case app.search_ListOfProducts
                    selectedProduct = app.search_ListOfProducts.Value;

                    if ~isempty(selectedProduct)
                        selectedTableIndex = find(ismember(app.report_Table.Data.("Homologação"), selectedProduct));
                    end

                case app.report_Table
                    selectedTableIndex = app.report_Table.Selection;

                    if ~isempty(selectedTableIndex)
                        idx = selectedTableIndex(~strcmp(app.report_Table.Data.("Homologação")(selectedTableIndex), '-1'));
                        selectedProduct = app.report_Table.Data.("Homologação")(idx);
                    end

                % Relacionado à exclusão de filtro secundário.
                case app.search_SecundaryListOfFilters
                    selectedFilter = app.search_SecundaryListOfFilters.Value;

                    if ~isempty(selectedFilter)
                        idx = find(ismember(app.search_SecundaryListOfFilters.Items, selectedFilter));
                        removeFilterRule(app.filteringObj, idx);
                        
                        search_Filtering_SecundaryFilterLayout(app)
                        search_Filtering_secundaryFilter(app)
                    end
                    return
            end

            if ~isempty(selectedTableIndex)                        
                app.projectData.listOfProducts(selectedTableIndex,:) = [];
                report_UpdatingTable(app)
                report_ProjectWarnImageVisibility(app)
            end

            if ~isempty(selectedProduct)
                app.search_ListOfProducts.Items = setdiff(app.search_ListOfProducts.Items, selectedProduct);
            end

            report_TableSelectionChanged(app)

        end

        % Image clicked function: config_DefaultIssueValuesLock
        function config_DefaultIssueValuesLockClicked(app, event)
            
            hComponents = findobj(app.config_DefaultIssueValuesGrid, 'Type', 'uidropdown', '-or', 'Type', 'uicheckboxtree');
            if ~isempty(hComponents)
                if hComponents(1).Enable
                    app.config_DefaultIssueValuesLock.ImageSource = 'Lock1_18Gray.png';
                    set(hComponents, 'Enable', 0)                    
                else
                    app.config_DefaultIssueValuesLock.ImageSource = 'Lock2_18Gray.png';
                    set(hComponents, 'Enable', 1)
                end
            end

            focus(app.jsBackDoor)

        end

        % Selection changed function: config_ButtonGroup
        function config_ButtonGroupSelectionChanged(app, event)
            
            selectedButton = app.config_ButtonGroup.SelectedObject;
            switch selectedButton
                case app.config_Option_Search
                    app.config_mainGrid.ColumnWidth(2:4) = {'1x',0,0};
                case app.config_Option_Fiscaliza
                    app.config_mainGrid.ColumnWidth(2:4) = {0,'1x',0};
                case app.config_Option_Folder
                    app.config_mainGrid.ColumnWidth(2:4) = {0,0,'1x'};
            end
            
        end

        % Image clicked function: Image2
        function Image2Clicked(app, event)
            
            app.config_SelectedTableColumns.CheckedNodes = [];
            config_ListOfColumns2ShowChanged(app)

        end

        % Image clicked function: search_ExportTable
        function search_ExportTableClicked(app, event)
            
                nameFormatMap = {'*.xlsx', 'Excel (*.xlsx)'};
                defaultName   = class.Constants.DefaultFileName(app.General.fileFolder.userPath, 'SCH', -1); 
                fileFullPath  = appUtil.modalWindow(app.UIFigure, 'uiputfile', '', nameFormatMap, defaultName);
                if isempty(fileFullPath)
                    return
                end
                
                app.progressDialog.Visible = 'visible';

                try
                    idxSCH = app.search_Table.UserData.secundaryIndex;
                    writetable(app.rawDataTable(idxSCH, 1:19), fileFullPath, 'WriteMode', 'overwritesheet')
                catch ME
                    appUtil.modalWindow(app.UIFigure, 'warning', getReport(ME));
                end

                app.progressDialog.Visible = 'hidden';

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [93 93 1244 660];
            app.UIFigure.Name = 'SCH R2024a';
            app.UIFigure.Icon = fullfile(pathToMLAPP, 'Icons', 'icon_48.png');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {44, '1x', 44};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1_Search
            app.Tab1_Search = uitab(app.TabGroup);
            app.Tab1_Search.AutoResizeChildren = 'off';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.Tab1_Search);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {'1x', 34};
            app.GridLayout3.RowSpacing = 0;
            app.GridLayout3.Padding = [0 0 0 26];
            app.GridLayout3.BackgroundColor = [1 1 1];

            % Create search_mainGrid
            app.search_mainGrid = uigridlayout(app.GridLayout3);
            app.search_mainGrid.ColumnWidth = {330, '1x'};
            app.search_mainGrid.RowHeight = {'1x'};
            app.search_mainGrid.Padding = [5 5 5 0];
            app.search_mainGrid.Layout.Row = 1;
            app.search_mainGrid.Layout.Column = 1;
            app.search_mainGrid.BackgroundColor = [1 1 1];

            % Create search_Document
            app.search_Document = uigridlayout(app.search_mainGrid);
            app.search_Document.ColumnWidth = {400, '1x'};
            app.search_Document.RowHeight = {35, 1, 5, 67, 329, '1x', 1};
            app.search_Document.ColumnSpacing = 5;
            app.search_Document.RowSpacing = 0;
            app.search_Document.Padding = [0 0 0 0];
            app.search_Document.Layout.Row = 1;
            app.search_Document.Layout.Column = 2;
            app.search_Document.BackgroundColor = [1 1 1];

            % Create search_Table
            app.search_Table = uitable(app.search_Document);
            app.search_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.search_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'SOLICITANTE'; 'FABRICANTE'; 'MODELO'; 'NOME COMERCIAL'; 'SITUAÇÃO'};
            app.search_Table.ColumnWidth = {110, 300, 'auto', 'auto', 150, 150, 150};
            app.search_Table.RowName = {};
            app.search_Table.SelectionType = 'row';
            app.search_Table.RowStriping = 'off';
            app.search_Table.SelectionChangedFcn = createCallbackFcn(app, @search_Table_SelectionChanged, true);
            app.search_Table.Visible = 'off';
            app.search_Table.Layout.Row = [5 6];
            app.search_Table.Layout.Column = [1 2];
            app.search_Table.FontSize = 10;

            % Create search_entryPointPanel
            app.search_entryPointPanel = uipanel(app.search_Document);
            app.search_entryPointPanel.AutoResizeChildren = 'off';
            app.search_entryPointPanel.BackgroundColor = [1 1 1];
            app.search_entryPointPanel.Layout.Row = 1;
            app.search_entryPointPanel.Layout.Column = 1;

            % Create search_entryPointGrid
            app.search_entryPointGrid = uigridlayout(app.search_entryPointPanel);
            app.search_entryPointGrid.ColumnWidth = {'1x', 28};
            app.search_entryPointGrid.RowHeight = {'1x'};
            app.search_entryPointGrid.ColumnSpacing = 0;
            app.search_entryPointGrid.RowSpacing = 0;
            app.search_entryPointGrid.Padding = [0 0 0 0];
            app.search_entryPointGrid.BackgroundColor = [1 1 1];

            % Create search_entryPoint
            app.search_entryPoint = uieditfield(app.search_entryPointGrid, 'text');
            app.search_entryPoint.CharacterLimits = [0 128];
            app.search_entryPoint.ValueChangingFcn = createCallbackFcn(app, @search_EntryPoint_ValueChanging, true);
            app.search_entryPoint.Tag = 'PROMPT';
            app.search_entryPoint.FontSize = 14;
            app.search_entryPoint.FontColor = [0.8 0.8 0.8];
            app.search_entryPoint.Layout.Row = 1;
            app.search_entryPoint.Layout.Column = 1;
            app.search_entryPoint.Value = 'O que você quer pesquisar?';

            % Create search_entryPointImage
            app.search_entryPointImage = uiimage(app.search_entryPointGrid);
            app.search_entryPointImage.ScaleMethod = 'scaledown';
            app.search_entryPointImage.ImageClickedFcn = createCallbackFcn(app, @search_EntryPoint_ImageClicked, true);
            app.search_entryPointImage.Enable = 'off';
            app.search_entryPointImage.Layout.Row = 1;
            app.search_entryPointImage.Layout.Column = 2;
            app.search_entryPointImage.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Zoom_36x36.png');

            % Create search_Metadata
            app.search_Metadata = uilabel(app.search_Document);
            app.search_Metadata.VerticalAlignment = 'top';
            app.search_Metadata.WordWrap = 'on';
            app.search_Metadata.FontSize = 14;
            app.search_Metadata.Visible = 'off';
            app.search_Metadata.Layout.Row = 4;
            app.search_Metadata.Layout.Column = [1 2];
            app.search_Metadata.Interpreter = 'html';
            app.search_Metadata.Text = {'Exibindo resultados para "<b>apple iphone</b>"'; '<p style="color: #808080; font-size:10px;">Pesquisa realizada nas colunas "Nome do Produto" e "Modelo Comercial".</p><p style="color: #808080; font-size:10px;">Pesquisa realizada nas colunas "Nome do Produto" e "Modelo Comercial".</p>'};

            % Create search_nRows
            app.search_nRows = uilabel(app.search_Document);
            app.search_nRows.HorizontalAlignment = 'right';
            app.search_nRows.VerticalAlignment = 'bottom';
            app.search_nRows.FontSize = 10;
            app.search_nRows.Visible = 'off';
            app.search_nRows.Layout.Row = 4;
            app.search_nRows.Layout.Column = [1 2];
            app.search_nRows.Text = '# 0 ';

            % Create search_Suggestions
            app.search_Suggestions = uilistbox(app.search_Document);
            app.search_Suggestions.Items = {''};
            app.search_Suggestions.Tag = 'CAIXA DE BUSCA';
            app.search_Suggestions.Visible = 'off';
            app.search_Suggestions.FontSize = 14;
            app.search_Suggestions.Layout.Row = [2 5];
            app.search_Suggestions.Layout.Column = 1;
            app.search_Suggestions.Value = {};

            % Create search_Control
            app.search_Control = uigridlayout(app.search_mainGrid);
            app.search_Control.ColumnWidth = {'1x'};
            app.search_Control.RowHeight = {2, 24, '1x'};
            app.search_Control.ColumnSpacing = 0;
            app.search_Control.RowSpacing = 0;
            app.search_Control.Padding = [0 0 0 0];
            app.search_Control.Layout.Row = 1;
            app.search_Control.Layout.Column = 1;
            app.search_Control.BackgroundColor = [1 1 1];

            % Create search_ControlTabGroup
            app.search_ControlTabGroup = uitabgroup(app.search_Control);
            app.search_ControlTabGroup.AutoResizeChildren = 'off';
            app.search_ControlTabGroup.Layout.Row = [2 3];
            app.search_ControlTabGroup.Layout.Column = 1;

            % Create search_Tab1
            app.search_Tab1 = uitab(app.search_ControlTabGroup);
            app.search_Tab1.AutoResizeChildren = 'off';

            % Create search_Tab1Grid
            app.search_Tab1Grid = uigridlayout(app.search_Tab1);
            app.search_Tab1Grid.ColumnWidth = {'1x', 18, 18, 18};
            app.search_Tab1Grid.RowHeight = {22, 5, '1x', 5, 22, 5, 148, 5, 44, 5, 5, 22, 5, 44, 1};
            app.search_Tab1Grid.ColumnSpacing = 2;
            app.search_Tab1Grid.RowSpacing = 0;
            app.search_Tab1Grid.Padding = [0 0 0 0];
            app.search_Tab1Grid.BackgroundColor = [1 1 1];

            % Create search_ProductInfoLabel
            app.search_ProductInfoLabel = uilabel(app.search_Tab1Grid);
            app.search_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.search_ProductInfoLabel.FontSize = 10;
            app.search_ProductInfoLabel.Layout.Row = 1;
            app.search_ProductInfoLabel.Layout.Column = 1;
            app.search_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create search_ToolbarWordCloud
            app.search_ToolbarWordCloud = uiimage(app.search_Tab1Grid);
            app.search_ToolbarWordCloud.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarWordCloud.Enable = 'off';
            app.search_ToolbarWordCloud.Tooltip = {'Nuvem de palavras'; '(Google/Bing)'};
            app.search_ToolbarWordCloud.Layout.Row = [1 2];
            app.search_ToolbarWordCloud.Layout.Column = 3;
            app.search_ToolbarWordCloud.VerticalAlignment = 'bottom';
            app.search_ToolbarWordCloud.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Cloud_32x32Gray.png');

            % Create search_ToolbarListOfProducts
            app.search_ToolbarListOfProducts = uiimage(app.search_Tab1Grid);
            app.search_ToolbarListOfProducts.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarListOfProducts.Enable = 'off';
            app.search_ToolbarListOfProducts.Tooltip = {'Lista de produtos homologados sob anáilse'};
            app.search_ToolbarListOfProducts.Layout.Row = [1 2];
            app.search_ToolbarListOfProducts.Layout.Column = 4;
            app.search_ToolbarListOfProducts.VerticalAlignment = 'bottom';
            app.search_ToolbarListOfProducts.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Box_32x32Gray.png');

            % Create search_ProductInfoPanel
            app.search_ProductInfoPanel = uipanel(app.search_Tab1Grid);
            app.search_ProductInfoPanel.AutoResizeChildren = 'off';
            app.search_ProductInfoPanel.Layout.Row = 3;
            app.search_ProductInfoPanel.Layout.Column = [1 4];

            % Create search_ProductInfoGrid
            app.search_ProductInfoGrid = uigridlayout(app.search_ProductInfoPanel);
            app.search_ProductInfoGrid.ColumnWidth = {'1x'};
            app.search_ProductInfoGrid.RowHeight = {'1x'};
            app.search_ProductInfoGrid.Padding = [0 0 0 0];
            app.search_ProductInfoGrid.BackgroundColor = [1 1 1];

            % Create search_ProductInfo
            app.search_ProductInfo = uihtml(app.search_ProductInfoGrid);
            app.search_ProductInfo.HTMLSource = 'Warning.html';
            app.search_ProductInfo.Layout.Row = 1;
            app.search_ProductInfo.Layout.Column = 1;

            % Create search_AnnotationPanelLabel
            app.search_AnnotationPanelLabel = uilabel(app.search_Tab1Grid);
            app.search_AnnotationPanelLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelLabel.FontSize = 10;
            app.search_AnnotationPanelLabel.Layout.Row = 5;
            app.search_AnnotationPanelLabel.Layout.Column = [1 2];
            app.search_AnnotationPanelLabel.Text = 'ANOTAÇÃO';

            % Create search_AnnotationPanel
            app.search_AnnotationPanel = uipanel(app.search_Tab1Grid);
            app.search_AnnotationPanel.AutoResizeChildren = 'off';
            app.search_AnnotationPanel.Layout.Row = 7;
            app.search_AnnotationPanel.Layout.Column = [1 4];

            % Create search_AnnotationGrid
            app.search_AnnotationGrid = uigridlayout(app.search_AnnotationPanel);
            app.search_AnnotationGrid.ColumnWidth = {'1x', 20};
            app.search_AnnotationGrid.RowHeight = {17, 22, 17, '1x', 20};
            app.search_AnnotationGrid.ColumnSpacing = 3;
            app.search_AnnotationGrid.RowSpacing = 5;
            app.search_AnnotationGrid.Padding = [10 10 5 5];
            app.search_AnnotationGrid.BackgroundColor = [1 1 1];

            % Create search_AnnotationAttributeLabel
            app.search_AnnotationAttributeLabel = uilabel(app.search_AnnotationGrid);
            app.search_AnnotationAttributeLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationAttributeLabel.FontSize = 10;
            app.search_AnnotationAttributeLabel.Layout.Row = 1;
            app.search_AnnotationAttributeLabel.Layout.Column = 1;
            app.search_AnnotationAttributeLabel.Text = 'Atributo:';

            % Create search_AnnotationAttribute
            app.search_AnnotationAttribute = uidropdown(app.search_AnnotationGrid);
            app.search_AnnotationAttribute.Items = {'Fornecedor', 'Fabricante', 'Modelo', 'EAN', 'Outras informações'};
            app.search_AnnotationAttribute.FontSize = 11;
            app.search_AnnotationAttribute.BackgroundColor = [1 1 1];
            app.search_AnnotationAttribute.Layout.Row = 2;
            app.search_AnnotationAttribute.Layout.Column = 1;
            app.search_AnnotationAttribute.Value = 'Fornecedor';

            % Create search_AnnotationValueLabel
            app.search_AnnotationValueLabel = uilabel(app.search_AnnotationGrid);
            app.search_AnnotationValueLabel.VerticalAlignment = 'bottom';
            app.search_AnnotationValueLabel.FontSize = 10;
            app.search_AnnotationValueLabel.Layout.Row = 3;
            app.search_AnnotationValueLabel.Layout.Column = 1;
            app.search_AnnotationValueLabel.Text = 'Valor:';

            % Create search_AnnotationValue
            app.search_AnnotationValue = uitextarea(app.search_AnnotationGrid);
            app.search_AnnotationValue.FontSize = 11;
            app.search_AnnotationValue.Layout.Row = [4 5];
            app.search_AnnotationValue.Layout.Column = 1;

            % Create search_AnnotationPanelAdd
            app.search_AnnotationPanelAdd = uiimage(app.search_AnnotationGrid);
            app.search_AnnotationPanelAdd.ImageClickedFcn = createCallbackFcn(app, @search_Annotation_AddImageClicked, true);
            app.search_AnnotationPanelAdd.Enable = 'off';
            app.search_AnnotationPanelAdd.Layout.Row = 5;
            app.search_AnnotationPanelAdd.Layout.Column = 2;
            app.search_AnnotationPanelAdd.VerticalAlignment = 'bottom';
            app.search_AnnotationPanelAdd.ImageSource = fullfile(pathToMLAPP, 'Icons', 'NewFile_36.png');

            % Create search_WordCloudPanel
            app.search_WordCloudPanel = uipanel(app.search_Tab1Grid);
            app.search_WordCloudPanel.AutoResizeChildren = 'off';
            app.search_WordCloudPanel.BackgroundColor = [1 1 1];
            app.search_WordCloudPanel.Layout.Row = [9 10];
            app.search_WordCloudPanel.Layout.Column = [1 4];

            % Create search_WordCloudRefreshGrid
            app.search_WordCloudRefreshGrid = uigridlayout(app.search_Tab1Grid);
            app.search_WordCloudRefreshGrid.ColumnWidth = {18, '1x'};
            app.search_WordCloudRefreshGrid.RowHeight = {'1x'};
            app.search_WordCloudRefreshGrid.ColumnSpacing = 2;
            app.search_WordCloudRefreshGrid.RowSpacing = 2;
            app.search_WordCloudRefreshGrid.Padding = [2 3 3 1];
            app.search_WordCloudRefreshGrid.Layout.Row = 10;
            app.search_WordCloudRefreshGrid.Layout.Column = 1;
            app.search_WordCloudRefreshGrid.BackgroundColor = [1 1 1];

            % Create search_WordCloudRefresh
            app.search_WordCloudRefresh = uiimage(app.search_WordCloudRefreshGrid);
            app.search_WordCloudRefresh.ImageClickedFcn = createCallbackFcn(app, @search_WordCloud_RefreshImageClicked, true);
            app.search_WordCloudRefresh.Enable = 'off';
            app.search_WordCloudRefresh.Layout.Row = 1;
            app.search_WordCloudRefresh.Layout.Column = 1;
            app.search_WordCloudRefresh.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Refresh_18Gray.png');

            % Create search_ListOfProductsLabel
            app.search_ListOfProductsLabel = uilabel(app.search_Tab1Grid);
            app.search_ListOfProductsLabel.VerticalAlignment = 'bottom';
            app.search_ListOfProductsLabel.FontSize = 10;
            app.search_ListOfProductsLabel.Layout.Row = 12;
            app.search_ListOfProductsLabel.Layout.Column = [1 3];
            app.search_ListOfProductsLabel.Text = 'LISTA DE PRODUTOS HOMOLOGADOS SOB ANÁLISE';

            % Create search_ListOfProductsAdd
            app.search_ListOfProductsAdd = uiimage(app.search_Tab1Grid);
            app.search_ListOfProductsAdd.ImageClickedFcn = createCallbackFcn(app, @search_Report_ListOfProductsAddImageClicked, true);
            app.search_ListOfProductsAdd.Layout.Row = [12 13];
            app.search_ListOfProductsAdd.Layout.Column = 4;
            app.search_ListOfProductsAdd.VerticalAlignment = 'bottom';
            app.search_ListOfProductsAdd.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Sum_36.png');

            % Create search_ListOfProducts
            app.search_ListOfProducts = uilistbox(app.search_Tab1Grid);
            app.search_ListOfProducts.Items = {};
            app.search_ListOfProducts.Multiselect = 'on';
            app.search_ListOfProducts.FontSize = 11;
            app.search_ListOfProducts.Layout.Row = 14;
            app.search_ListOfProducts.Layout.Column = [1 4];
            app.search_ListOfProducts.Value = {};

            % Create search_ToolbarAnnotation
            app.search_ToolbarAnnotation = uiimage(app.search_Tab1Grid);
            app.search_ToolbarAnnotation.ImageClickedFcn = createCallbackFcn(app, @search_Panel_ToolbarButtonClicked, true);
            app.search_ToolbarAnnotation.Enable = 'off';
            app.search_ToolbarAnnotation.Tooltip = {'Anotação textual'};
            app.search_ToolbarAnnotation.Layout.Row = [1 2];
            app.search_ToolbarAnnotation.Layout.Column = 2;
            app.search_ToolbarAnnotation.VerticalAlignment = 'bottom';
            app.search_ToolbarAnnotation.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Edit_18x18Gray.png');

            % Create search_Tab2
            app.search_Tab2 = uitab(app.search_ControlTabGroup);
            app.search_Tab2.AutoResizeChildren = 'off';
            app.search_Tab2.BackgroundColor = [1 1 1];

            % Create search_Tab2Grid
            app.search_Tab2Grid = uigridlayout(app.search_Tab2);
            app.search_Tab2Grid.ColumnWidth = {'1x', 18};
            app.search_Tab2Grid.RowHeight = {22, 5, 88, 5, 22, 5, 69, 22, '1x', 1};
            app.search_Tab2Grid.ColumnSpacing = 5;
            app.search_Tab2Grid.RowSpacing = 0;
            app.search_Tab2Grid.Padding = [0 0 0 0];
            app.search_Tab2Grid.BackgroundColor = [1 1 1];

            % Create search_PrimaryPanelLabel
            app.search_PrimaryPanelLabel = uilabel(app.search_Tab2Grid);
            app.search_PrimaryPanelLabel.VerticalAlignment = 'bottom';
            app.search_PrimaryPanelLabel.FontSize = 10;
            app.search_PrimaryPanelLabel.Layout.Row = 1;
            app.search_PrimaryPanelLabel.Layout.Column = 1;
            app.search_PrimaryPanelLabel.Text = 'PRIMÁRIA';

            % Create search_PrimaryPanel
            app.search_PrimaryPanel = uibuttongroup(app.search_Tab2Grid);
            app.search_PrimaryPanel.AutoResizeChildren = 'off';
            app.search_PrimaryPanel.SelectionChangedFcn = createCallbackFcn(app, @search_Filtering_primaryTableColumnsChanged, true);
            app.search_PrimaryPanel.BackgroundColor = [1 1 1];
            app.search_PrimaryPanel.Layout.Row = 3;
            app.search_PrimaryPanel.Layout.Column = [1 2];

            % Create search_PrimaryOption1
            app.search_PrimaryOption1 = uiradiobutton(app.search_PrimaryPanel);
            app.search_PrimaryOption1.Text = 'Homologação';
            app.search_PrimaryOption1.FontSize = 11;
            app.search_PrimaryOption1.Position = [11 58 90 22];

            % Create search_PrimaryOption2
            app.search_PrimaryOption2 = uiradiobutton(app.search_PrimaryPanel);
            app.search_PrimaryOption2.Text = 'Solicitante | Fabricante';
            app.search_PrimaryOption2.FontSize = 11;
            app.search_PrimaryOption2.Position = [11 33 134 22];

            % Create search_PrimaryOption3
            app.search_PrimaryOption3 = uiradiobutton(app.search_PrimaryPanel);
            app.search_PrimaryOption3.Text = 'Modelo | Nome Comercial';
            app.search_PrimaryOption3.FontSize = 11;
            app.search_PrimaryOption3.Position = [11 8 149 22];
            app.search_PrimaryOption3.Value = true;

            % Create search_SecundaryPanelLabel
            app.search_SecundaryPanelLabel = uilabel(app.search_Tab2Grid);
            app.search_SecundaryPanelLabel.VerticalAlignment = 'bottom';
            app.search_SecundaryPanelLabel.FontSize = 10;
            app.search_SecundaryPanelLabel.Layout.Row = 5;
            app.search_SecundaryPanelLabel.Layout.Column = 1;
            app.search_SecundaryPanelLabel.Text = 'SECUNDÁRIA';

            % Create search_SecundaryPanel
            app.search_SecundaryPanel = uipanel(app.search_Tab2Grid);
            app.search_SecundaryPanel.Layout.Row = 7;
            app.search_SecundaryPanel.Layout.Column = [1 2];

            % Create search_SecundaryGrid
            app.search_SecundaryGrid = uigridlayout(app.search_SecundaryPanel);
            app.search_SecundaryGrid.ColumnWidth = {55, '1x', 10, '1x'};
            app.search_SecundaryGrid.RowHeight = {22, 22};
            app.search_SecundaryGrid.ColumnSpacing = 5;
            app.search_SecundaryGrid.RowSpacing = 5;
            app.search_SecundaryGrid.BackgroundColor = [1 1 1];

            % Create search_SecundaryColumn
            app.search_SecundaryColumn = uidropdown(app.search_SecundaryGrid);
            app.search_SecundaryColumn.Items = {};
            app.search_SecundaryColumn.ValueChangedFcn = createCallbackFcn(app, @search_SecundaryColumnValueChanged, true);
            app.search_SecundaryColumn.FontSize = 11;
            app.search_SecundaryColumn.BackgroundColor = [1 1 1];
            app.search_SecundaryColumn.Layout.Row = 1;
            app.search_SecundaryColumn.Layout.Column = [1 4];
            app.search_SecundaryColumn.Value = {};

            % Create search_SecundaryOperation
            app.search_SecundaryOperation = uidropdown(app.search_SecundaryGrid);
            app.search_SecundaryOperation.Items = {'=', '≠', '⊃', '⊅', '<', '≤', '>', '≥', '><', '<>'};
            app.search_SecundaryOperation.ValueChangedFcn = createCallbackFcn(app, @search_SecundaryOperationValueChanged, true);
            app.search_SecundaryOperation.FontName = 'Consolas';
            app.search_SecundaryOperation.BackgroundColor = [1 1 1];
            app.search_SecundaryOperation.Layout.Row = 2;
            app.search_SecundaryOperation.Layout.Column = 1;
            app.search_SecundaryOperation.Value = '=';

            % Create search_SecundaryDateTime1
            app.search_SecundaryDateTime1 = uieditfield(app.search_SecundaryGrid, 'text');
            app.search_SecundaryDateTime1.CharacterLimits = [10 10];
            app.search_SecundaryDateTime1.Visible = 'off';
            app.search_SecundaryDateTime1.Placeholder = 'dd/mm/yyyy';
            app.search_SecundaryDateTime1.Layout.Row = 2;
            app.search_SecundaryDateTime1.Layout.Column = 2;

            % Create search_SecundaryDateTimeSeparator
            app.search_SecundaryDateTimeSeparator = uilabel(app.search_SecundaryGrid);
            app.search_SecundaryDateTimeSeparator.HorizontalAlignment = 'center';
            app.search_SecundaryDateTimeSeparator.Visible = 'off';
            app.search_SecundaryDateTimeSeparator.Layout.Row = 2;
            app.search_SecundaryDateTimeSeparator.Layout.Column = 3;
            app.search_SecundaryDateTimeSeparator.Text = '-';

            % Create search_SecundaryDateTime2
            app.search_SecundaryDateTime2 = uieditfield(app.search_SecundaryGrid, 'text');
            app.search_SecundaryDateTime2.CharacterLimits = [10 10];
            app.search_SecundaryDateTime2.Visible = 'off';
            app.search_SecundaryDateTime2.Placeholder = 'dd/mm/yyyy';
            app.search_SecundaryDateTime2.Layout.Row = 2;
            app.search_SecundaryDateTime2.Layout.Column = 4;

            % Create search_SecundaryTextFreeValue
            app.search_SecundaryTextFreeValue = uieditfield(app.search_SecundaryGrid, 'text');
            app.search_SecundaryTextFreeValue.FontSize = 10;
            app.search_SecundaryTextFreeValue.FontColor = [0.149 0.149 0.149];
            app.search_SecundaryTextFreeValue.Visible = 'off';
            app.search_SecundaryTextFreeValue.Layout.Row = 2;
            app.search_SecundaryTextFreeValue.Layout.Column = [2 4];

            % Create search_SecundaryTextListValue
            app.search_SecundaryTextListValue = uidropdown(app.search_SecundaryGrid);
            app.search_SecundaryTextListValue.Items = {};
            app.search_SecundaryTextListValue.Visible = 'off';
            app.search_SecundaryTextListValue.FontSize = 10;
            app.search_SecundaryTextListValue.BackgroundColor = [1 1 1];
            app.search_SecundaryTextListValue.Layout.Row = 2;
            app.search_SecundaryTextListValue.Layout.Column = [2 4];
            app.search_SecundaryTextListValue.Value = {};

            % Create search_SecundaryAddFilter
            app.search_SecundaryAddFilter = uiimage(app.search_Tab2Grid);
            app.search_SecundaryAddFilter.ImageClickedFcn = createCallbackFcn(app, @search_SecundaryAddFilterImageClicked, true);
            app.search_SecundaryAddFilter.Layout.Row = 8;
            app.search_SecundaryAddFilter.Layout.Column = 2;
            app.search_SecundaryAddFilter.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Sum_36.png');

            % Create search_SecundaryListOfFilters
            app.search_SecundaryListOfFilters = uilistbox(app.search_Tab2Grid);
            app.search_SecundaryListOfFilters.Items = {};
            app.search_SecundaryListOfFilters.Multiselect = 'on';
            app.search_SecundaryListOfFilters.FontSize = 11;
            app.search_SecundaryListOfFilters.Layout.Row = 9;
            app.search_SecundaryListOfFilters.Layout.Column = [1 2];
            app.search_SecundaryListOfFilters.Value = {};

            % Create search_ControlMenu
            app.search_ControlMenu = uigridlayout(app.search_Control);
            app.search_ControlMenu.ColumnWidth = {'1x', 22};
            app.search_ControlMenu.RowHeight = {'1x', 3};
            app.search_ControlMenu.ColumnSpacing = 1;
            app.search_ControlMenu.RowSpacing = 0;
            app.search_ControlMenu.Padding = [0 0 0 0];
            app.search_ControlMenu.Layout.Row = [1 2];
            app.search_ControlMenu.Layout.Column = 1;
            app.search_ControlMenu.BackgroundColor = [1 1 1];

            % Create search_menuUnderline
            app.search_menuUnderline = uiimage(app.search_ControlMenu);
            app.search_menuUnderline.ScaleMethod = 'scaleup';
            app.search_menuUnderline.Layout.Row = 2;
            app.search_menuUnderline.Layout.Column = 1;
            app.search_menuUnderline.ImageSource = fullfile(pathToMLAPP, 'Icons', 'LineH.png');

            % Create search_menuBtn1Grid
            app.search_menuBtn1Grid = uigridlayout(app.search_ControlMenu);
            app.search_menuBtn1Grid.ColumnWidth = {18, '1x'};
            app.search_menuBtn1Grid.RowHeight = {'1x'};
            app.search_menuBtn1Grid.ColumnSpacing = 3;
            app.search_menuBtn1Grid.Padding = [2 0 0 0];
            app.search_menuBtn1Grid.Layout.Row = 1;
            app.search_menuBtn1Grid.Layout.Column = 1;
            app.search_menuBtn1Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create search_menuBtn1Label
            app.search_menuBtn1Label = uilabel(app.search_menuBtn1Grid);
            app.search_menuBtn1Label.FontSize = 11;
            app.search_menuBtn1Label.Layout.Row = 1;
            app.search_menuBtn1Label.Layout.Column = 2;
            app.search_menuBtn1Label.Text = 'ASPECTOS GERAIS';

            % Create search_menuBtn1Icon
            app.search_menuBtn1Icon = uiimage(app.search_menuBtn1Grid);
            app.search_menuBtn1Icon.ScaleMethod = 'none';
            app.search_menuBtn1Icon.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_TabControlButtonPushed, true);
            app.search_menuBtn1Icon.Tag = '1';
            app.search_menuBtn1Icon.Layout.Row = 1;
            app.search_menuBtn1Icon.Layout.Column = [1 2];
            app.search_menuBtn1Icon.HorizontalAlignment = 'left';
            app.search_menuBtn1Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Classification_18.png');

            % Create search_menuBtn2Grid
            app.search_menuBtn2Grid = uigridlayout(app.search_ControlMenu);
            app.search_menuBtn2Grid.ColumnWidth = {18, 0};
            app.search_menuBtn2Grid.RowHeight = {'1x'};
            app.search_menuBtn2Grid.ColumnSpacing = 3;
            app.search_menuBtn2Grid.Padding = [2 0 0 0];
            app.search_menuBtn2Grid.Layout.Row = 1;
            app.search_menuBtn2Grid.Layout.Column = 2;
            app.search_menuBtn2Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create search_menuBtn2Label
            app.search_menuBtn2Label = uilabel(app.search_menuBtn2Grid);
            app.search_menuBtn2Label.FontSize = 11;
            app.search_menuBtn2Label.FontWeight = 'bold';
            app.search_menuBtn2Label.Layout.Row = 1;
            app.search_menuBtn2Label.Layout.Column = 2;
            app.search_menuBtn2Label.Text = 'FILTRAGEM';

            % Create search_menuBtn2Icon
            app.search_menuBtn2Icon = uiimage(app.search_menuBtn2Grid);
            app.search_menuBtn2Icon.ScaleMethod = 'none';
            app.search_menuBtn2Icon.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_TabControlButtonPushed, true);
            app.search_menuBtn2Icon.Tag = '2';
            app.search_menuBtn2Icon.Layout.Row = 1;
            app.search_menuBtn2Icon.Layout.Column = [1 2];
            app.search_menuBtn2Icon.HorizontalAlignment = 'left';
            app.search_menuBtn2Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Filter_18x18.png');

            % Create file_toolGrid
            app.file_toolGrid = uigridlayout(app.GridLayout3);
            app.file_toolGrid.ColumnWidth = {22, 22, '1x'};
            app.file_toolGrid.RowHeight = {4, 17, '1x'};
            app.file_toolGrid.ColumnSpacing = 5;
            app.file_toolGrid.RowSpacing = 0;
            app.file_toolGrid.Padding = [0 5 0 5];
            app.file_toolGrid.Layout.Row = 2;
            app.file_toolGrid.Layout.Column = 1;

            % Create search_PanelVisibility
            app.search_PanelVisibility = uiimage(app.file_toolGrid);
            app.search_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.search_PanelVisibility.Layout.Row = 2;
            app.search_PanelVisibility.Layout.Column = 1;
            app.search_PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'Icons', 'ArrowRight_32.png');

            % Create search_ExportTable
            app.search_ExportTable = uiimage(app.file_toolGrid);
            app.search_ExportTable.ScaleMethod = 'none';
            app.search_ExportTable.ImageClickedFcn = createCallbackFcn(app, @search_ExportTableClicked, true);
            app.search_ExportTable.Enable = 'off';
            app.search_ExportTable.Tooltip = {'Exporta resultados de busca em arquivo XLSX'};
            app.search_ExportTable.Layout.Row = 2;
            app.search_ExportTable.Layout.Column = 2;
            app.search_ExportTable.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Export_16.png');

            % Create Tab2_Report
            app.Tab2_Report = uitab(app.TabGroup);
            app.Tab2_Report.AutoResizeChildren = 'off';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.Tab2_Report);
            app.GridLayout4.ColumnWidth = {'1x'};
            app.GridLayout4.RowHeight = {'1x', 34};
            app.GridLayout4.RowSpacing = 0;
            app.GridLayout4.Padding = [0 0 0 26];
            app.GridLayout4.BackgroundColor = [1 1 1];

            % Create file_toolGrid_2
            app.file_toolGrid_2 = uigridlayout(app.GridLayout4);
            app.file_toolGrid_2.ColumnWidth = {22, 22, 22, 22, 22, '1x', 110};
            app.file_toolGrid_2.RowHeight = {'1x', 17, '1x'};
            app.file_toolGrid_2.ColumnSpacing = 5;
            app.file_toolGrid_2.RowSpacing = 0;
            app.file_toolGrid_2.Padding = [0 5 0 5];
            app.file_toolGrid_2.Layout.Row = 2;
            app.file_toolGrid_2.Layout.Column = 1;

            % Create report_PanelVisibility
            app.report_PanelVisibility = uiimage(app.file_toolGrid_2);
            app.report_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.report_PanelVisibility.Layout.Row = 2;
            app.report_PanelVisibility.Layout.Column = 1;
            app.report_PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'Icons', 'ArrowLeft_32.png');

            % Create report_ShowCells2Edit
            app.report_ShowCells2Edit = uiimage(app.file_toolGrid_2);
            app.report_ShowCells2Edit.ImageClickedFcn = createCallbackFcn(app, @report_ShowCells2EditClicked, true);
            app.report_ShowCells2Edit.Tag = 'off';
            app.report_ShowCells2Edit.Tooltip = {'Destaca células pendentes de edição'};
            app.report_ShowCells2Edit.Layout.Row = 2;
            app.report_ShowCells2Edit.Layout.Column = 2;
            app.report_ShowCells2Edit.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Warn_32.png');

            % Create report_ReportGeneration
            app.report_ReportGeneration = uiimage(app.file_toolGrid_2);
            app.report_ReportGeneration.ImageClickedFcn = createCallbackFcn(app, @report_ReportGenerationImageClicked, true);
            app.report_ReportGeneration.Enable = 'off';
            app.report_ReportGeneration.Tooltip = {'Gera relatório'};
            app.report_ReportGeneration.Layout.Row = 2;
            app.report_ReportGeneration.Layout.Column = 3;
            app.report_ReportGeneration.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Publish_HTML_16-8792a26e8b38d73b8ffe54ffae928360.png');

            % Create report_FiscalizaAutoFillImage
            app.report_FiscalizaAutoFillImage = uiimage(app.file_toolGrid_2);
            app.report_FiscalizaAutoFillImage.ImageClickedFcn = createCallbackFcn(app, @report_FiscalizaCallbacks, true);
            app.report_FiscalizaAutoFillImage.Enable = 'off';
            app.report_FiscalizaAutoFillImage.Tooltip = {'Preenche campos automaticamente'};
            app.report_FiscalizaAutoFillImage.Layout.Row = 2;
            app.report_FiscalizaAutoFillImage.Layout.Column = 4;
            app.report_FiscalizaAutoFillImage.ImageSource = fullfile(pathToMLAPP, 'Icons', 'AutoFill_36Blue.png');

            % Create report_FiscalizaUpdateImage
            app.report_FiscalizaUpdateImage = uiimage(app.file_toolGrid_2);
            app.report_FiscalizaUpdateImage.ImageClickedFcn = createCallbackFcn(app, @report_FiscalizaCallbacks, true);
            app.report_FiscalizaUpdateImage.Enable = 'off';
            app.report_FiscalizaUpdateImage.Tooltip = {'Atualiza inspeção no FISCALIZA'};
            app.report_FiscalizaUpdateImage.Layout.Row = 2;
            app.report_FiscalizaUpdateImage.Layout.Column = 5;
            app.report_FiscalizaUpdateImage.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Up_24.png');

            % Create report_mainGrid
            app.report_mainGrid = uigridlayout(app.GridLayout4);
            app.report_mainGrid.ColumnWidth = {330, '1x'};
            app.report_mainGrid.RowHeight = {'1x'};
            app.report_mainGrid.Padding = [5 5 5 0];
            app.report_mainGrid.Layout.Row = 1;
            app.report_mainGrid.Layout.Column = 1;
            app.report_mainGrid.BackgroundColor = [1 1 1];

            % Create report_Document
            app.report_Document = uigridlayout(app.report_mainGrid);
            app.report_Document.ColumnWidth = {'1x'};
            app.report_Document.RowHeight = {22, 5, '1x', 1};
            app.report_Document.ColumnSpacing = 5;
            app.report_Document.RowSpacing = 0;
            app.report_Document.Padding = [0 0 0 0];
            app.report_Document.Layout.Row = 1;
            app.report_Document.Layout.Column = 2;
            app.report_Document.BackgroundColor = [1 1 1];

            % Create report_TableLabel
            app.report_TableLabel = uilabel(app.report_Document);
            app.report_TableLabel.VerticalAlignment = 'bottom';
            app.report_TableLabel.FontSize = 10;
            app.report_TableLabel.Layout.Row = 1;
            app.report_TableLabel.Layout.Column = 1;
            app.report_TableLabel.Text = 'LISTA DE PRODUTOS SOB ANÁLISE';

            % Create report_nRows
            app.report_nRows = uilabel(app.report_Document);
            app.report_nRows.HorizontalAlignment = 'right';
            app.report_nRows.VerticalAlignment = 'bottom';
            app.report_nRows.FontSize = 10;
            app.report_nRows.Layout.Row = [1 2];
            app.report_nRows.Layout.Column = 1;
            app.report_nRows.Text = '# 0 ';

            % Create report_Table
            app.report_Table = uitable(app.report_Document);
            app.report_Table.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.report_Table.ColumnName = {'HOMOLOGAÇÃO'; 'TIPO'; 'FABRICANTE'; 'MODELO'; 'RF?'; 'EM USO?'; 'INTERFERÊNCIA?'; 'VALOR|UNITÁRIO (R$)'; 'QTD.|USO/VENDIDA'; 'QTD.|ESTOQUE/ADUANA'; 'QTD.|LACRADAS'; 'QTD.|APREENDIDAS'; 'QTD.|RETIDAS (RFB)'};
            app.report_Table.ColumnWidth = {110, 'auto', 'auto', 'auto', 42, 58, 96, 90, 90, 90, 90, 90, 90};
            app.report_Table.RowName = {};
            app.report_Table.SelectionType = 'row';
            app.report_Table.ColumnEditable = [false true true true true true true true true true true true true];
            app.report_Table.CellEditCallback = createCallbackFcn(app, @report_TableCellEdit, true);
            app.report_Table.SelectionChangedFcn = createCallbackFcn(app, @report_TableSelectionChanged, true);
            app.report_Table.Layout.Row = 3;
            app.report_Table.Layout.Column = 1;
            app.report_Table.FontSize = 10;

            % Create report_Control
            app.report_Control = uigridlayout(app.report_mainGrid);
            app.report_Control.ColumnWidth = {'1x'};
            app.report_Control.RowHeight = {2, 24, '1x'};
            app.report_Control.ColumnSpacing = 0;
            app.report_Control.RowSpacing = 0;
            app.report_Control.Padding = [0 0 0 0];
            app.report_Control.Layout.Row = 1;
            app.report_Control.Layout.Column = 1;
            app.report_Control.BackgroundColor = [1 1 1];

            % Create report_ControlTabGroup
            app.report_ControlTabGroup = uitabgroup(app.report_Control);
            app.report_ControlTabGroup.AutoResizeChildren = 'off';
            app.report_ControlTabGroup.Layout.Row = [2 3];
            app.report_ControlTabGroup.Layout.Column = 1;

            % Create report_Tab1
            app.report_Tab1 = uitab(app.report_ControlTabGroup);
            app.report_Tab1.AutoResizeChildren = 'off';

            % Create report_Tab1Grid
            app.report_Tab1Grid = uigridlayout(app.report_Tab1);
            app.report_Tab1Grid.ColumnWidth = {'1x', 18};
            app.report_Tab1Grid.RowHeight = {22, 5, '1x', 5, 22, 5, 292, 1};
            app.report_Tab1Grid.ColumnSpacing = 2;
            app.report_Tab1Grid.RowSpacing = 0;
            app.report_Tab1Grid.Padding = [0 0 0 0];
            app.report_Tab1Grid.BackgroundColor = [1 1 1];

            % Create report_ProductInfoLabel
            app.report_ProductInfoLabel = uilabel(app.report_Tab1Grid);
            app.report_ProductInfoLabel.VerticalAlignment = 'bottom';
            app.report_ProductInfoLabel.FontSize = 10;
            app.report_ProductInfoLabel.Layout.Row = 1;
            app.report_ProductInfoLabel.Layout.Column = 1;
            app.report_ProductInfoLabel.Text = 'PRODUTO SELECIONADO';

            % Create report_ProductInfoPanel
            app.report_ProductInfoPanel = uipanel(app.report_Tab1Grid);
            app.report_ProductInfoPanel.AutoResizeChildren = 'off';
            app.report_ProductInfoPanel.Layout.Row = 3;
            app.report_ProductInfoPanel.Layout.Column = [1 2];

            % Create report_ProductInfoGrid
            app.report_ProductInfoGrid = uigridlayout(app.report_ProductInfoPanel);
            app.report_ProductInfoGrid.ColumnWidth = {'1x'};
            app.report_ProductInfoGrid.RowHeight = {'1x'};
            app.report_ProductInfoGrid.Padding = [0 0 0 0];
            app.report_ProductInfoGrid.BackgroundColor = [1 1 1];

            % Create report_ProductInfo
            app.report_ProductInfo = uihtml(app.report_ProductInfoGrid);
            app.report_ProductInfo.HTMLSource = 'Warning.html';
            app.report_ProductInfo.Layout.Row = 1;
            app.report_ProductInfo.Layout.Column = 1;

            % Create report_EditableInfoLabel
            app.report_EditableInfoLabel = uilabel(app.report_Tab1Grid);
            app.report_EditableInfoLabel.VerticalAlignment = 'bottom';
            app.report_EditableInfoLabel.FontSize = 10;
            app.report_EditableInfoLabel.Layout.Row = 5;
            app.report_EditableInfoLabel.Layout.Column = 1;
            app.report_EditableInfoLabel.Text = 'INCLUSÃO';

            % Create report_EditableInfoPanel
            app.report_EditableInfoPanel = uipanel(app.report_Tab1Grid);
            app.report_EditableInfoPanel.AutoResizeChildren = 'off';
            app.report_EditableInfoPanel.Layout.Row = 7;
            app.report_EditableInfoPanel.Layout.Column = [1 2];

            % Create report_EditableInfoGrid
            app.report_EditableInfoGrid = uigridlayout(app.report_EditableInfoPanel);
            app.report_EditableInfoGrid.ColumnWidth = {80, 10, '1x', 10, 60, 20, 5};
            app.report_EditableInfoGrid.RowHeight = {36, 17, 22, 17, 22, 17, 22, 17, '1x', 20};
            app.report_EditableInfoGrid.ColumnSpacing = 0;
            app.report_EditableInfoGrid.RowSpacing = 5;
            app.report_EditableInfoGrid.Padding = [10 10 5 10];
            app.report_EditableInfoGrid.BackgroundColor = [1 1 1];

            % Create report_productSituationPanel
            app.report_productSituationPanel = uibuttongroup(app.report_EditableInfoGrid);
            app.report_productSituationPanel.AutoResizeChildren = 'off';
            app.report_productSituationPanel.SelectionChangedFcn = createCallbackFcn(app, @report_productSituationPanelSelectionChanged, true);
            app.report_productSituationPanel.BackgroundColor = [1 1 1];
            app.report_productSituationPanel.Layout.Row = 1;
            app.report_productSituationPanel.Layout.Column = [1 5];

            % Create report_productSituation1
            app.report_productSituation1 = uiradiobutton(app.report_productSituationPanel);
            app.report_productSituation1.Text = 'HOMOLOGADO';
            app.report_productSituation1.FontSize = 11;
            app.report_productSituation1.Interpreter = 'html';
            app.report_productSituation1.Position = [11 7 103 22];

            % Create report_productSituation2
            app.report_productSituation2 = uiradiobutton(app.report_productSituationPanel);
            app.report_productSituation2.Text = '<font style="color:red;">NÃO</font> HOMOLOGADO';
            app.report_productSituation2.FontSize = 11;
            app.report_productSituation2.Interpreter = 'html';
            app.report_productSituation2.Position = [147 7 132 22];
            app.report_productSituation2.Value = true;

            % Create report_nHomLabel
            app.report_nHomLabel = uilabel(app.report_EditableInfoGrid);
            app.report_nHomLabel.VerticalAlignment = 'bottom';
            app.report_nHomLabel.FontSize = 10;
            app.report_nHomLabel.Layout.Row = 2;
            app.report_nHomLabel.Layout.Column = 1;
            app.report_nHomLabel.Text = 'Homologação:';

            % Create report_nHom
            app.report_nHom = uieditfield(app.report_EditableInfoGrid, 'text');
            app.report_nHom.CharacterLimits = [0 14];
            app.report_nHom.ValueChangingFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.report_nHom.FontSize = 11;
            app.report_nHom.Enable = 'off';
            app.report_nHom.Layout.Row = 3;
            app.report_nHom.Layout.Column = 1;
            app.report_nHom.Value = '-1';

            % Create report_IDAduanaLabel
            app.report_IDAduanaLabel = uilabel(app.report_EditableInfoGrid);
            app.report_IDAduanaLabel.VerticalAlignment = 'bottom';
            app.report_IDAduanaLabel.FontSize = 10;
            app.report_IDAduanaLabel.Layout.Row = 2;
            app.report_IDAduanaLabel.Layout.Column = 3;
            app.report_IDAduanaLabel.Text = 'Código aduaneiro:';

            % Create report_IDAduana
            app.report_IDAduana = uieditfield(app.report_EditableInfoGrid, 'text');
            app.report_IDAduana.ValueChangingFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.report_IDAduana.FontSize = 11;
            app.report_IDAduana.Layout.Row = 3;
            app.report_IDAduana.Layout.Column = [3 5];

            % Create report_SituationLabel
            app.report_SituationLabel = uilabel(app.report_EditableInfoGrid);
            app.report_SituationLabel.VerticalAlignment = 'bottom';
            app.report_SituationLabel.FontSize = 10;
            app.report_SituationLabel.Layout.Row = 6;
            app.report_SituationLabel.Layout.Column = 1;
            app.report_SituationLabel.Text = 'Situação:';

            % Create report_Situation
            app.report_Situation = uidropdown(app.report_EditableInfoGrid);
            app.report_Situation.Items = {'Irregular', 'Regular'};
            app.report_Situation.ValueChangedFcn = createCallbackFcn(app, @report_SituationValueChanged, true);
            app.report_Situation.FontSize = 11;
            app.report_Situation.BackgroundColor = [1 1 1];
            app.report_Situation.Layout.Row = 7;
            app.report_Situation.Layout.Column = 1;
            app.report_Situation.Value = 'Irregular';

            % Create report_ViolationLabel
            app.report_ViolationLabel = uilabel(app.report_EditableInfoGrid);
            app.report_ViolationLabel.VerticalAlignment = 'bottom';
            app.report_ViolationLabel.FontSize = 10;
            app.report_ViolationLabel.Layout.Row = 6;
            app.report_ViolationLabel.Layout.Column = 3;
            app.report_ViolationLabel.Text = 'Infração:';

            % Create report_Violation
            app.report_Violation = uidropdown(app.report_EditableInfoGrid);
            app.report_Violation.Items = {'Comercialização', 'Identificação homologação', 'Uso'};
            app.report_Violation.ValueChangedFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.report_Violation.FontSize = 11;
            app.report_Violation.BackgroundColor = [1 1 1];
            app.report_Violation.Layout.Row = 7;
            app.report_Violation.Layout.Column = 3;
            app.report_Violation.Value = 'Comercialização';

            % Create report_NotesLabel
            app.report_NotesLabel = uilabel(app.report_EditableInfoGrid);
            app.report_NotesLabel.VerticalAlignment = 'bottom';
            app.report_NotesLabel.FontSize = 10;
            app.report_NotesLabel.Layout.Row = 8;
            app.report_NotesLabel.Layout.Column = [1 3];
            app.report_NotesLabel.Text = 'Informações adicionais:';

            % Create report_Notes
            app.report_Notes = uitextarea(app.report_EditableInfoGrid);
            app.report_Notes.ValueChangingFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.report_Notes.FontSize = 11;
            app.report_Notes.Layout.Row = [9 10];
            app.report_Notes.Layout.Column = [1 5];

            % Create report_EditOrAddButton
            app.report_EditOrAddButton = uiimage(app.report_EditableInfoGrid);
            app.report_EditOrAddButton.ImageClickedFcn = createCallbackFcn(app, @report_EditOrAddButtonImageClicked, true);
            app.report_EditOrAddButton.Enable = 'off';
            app.report_EditOrAddButton.Layout.Row = 10;
            app.report_EditOrAddButton.Layout.Column = [6 7];
            app.report_EditOrAddButton.VerticalAlignment = 'bottom';
            app.report_EditOrAddButton.ImageSource = 'NewFile_36.png';

            % Create ImportadorEditFieldLabel
            app.ImportadorEditFieldLabel = uilabel(app.report_EditableInfoGrid);
            app.ImportadorEditFieldLabel.VerticalAlignment = 'bottom';
            app.ImportadorEditFieldLabel.FontSize = 10;
            app.ImportadorEditFieldLabel.Layout.Row = 4;
            app.ImportadorEditFieldLabel.Layout.Column = 1;
            app.ImportadorEditFieldLabel.Text = 'Importador:';

            % Create ImportadorEditField
            app.ImportadorEditField = uieditfield(app.report_EditableInfoGrid, 'text');
            app.ImportadorEditField.ValueChangingFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.ImportadorEditField.FontSize = 11;
            app.ImportadorEditField.Layout.Row = 5;
            app.ImportadorEditField.Layout.Column = [1 5];

            % Create report_CorrigibleLabel
            app.report_CorrigibleLabel = uilabel(app.report_EditableInfoGrid);
            app.report_CorrigibleLabel.VerticalAlignment = 'bottom';
            app.report_CorrigibleLabel.FontSize = 10;
            app.report_CorrigibleLabel.Layout.Row = 6;
            app.report_CorrigibleLabel.Layout.Column = 5;
            app.report_CorrigibleLabel.Text = 'Sanável?';

            % Create report_Corrigible
            app.report_Corrigible = uidropdown(app.report_EditableInfoGrid);
            app.report_Corrigible.Items = {'Sim', 'Não'};
            app.report_Corrigible.ValueChangedFcn = createCallbackFcn(app, @report_EnablingEditOrAddImage, true);
            app.report_Corrigible.FontSize = 11;
            app.report_Corrigible.BackgroundColor = [1 1 1];
            app.report_Corrigible.Layout.Row = 7;
            app.report_Corrigible.Layout.Column = 5;
            app.report_Corrigible.Value = 'Não';

            % Create report_ToolbarEditOrAdd
            app.report_ToolbarEditOrAdd = uiimage(app.report_Tab1Grid);
            app.report_ToolbarEditOrAdd.ImageClickedFcn = createCallbackFcn(app, @report_ToolbarEditOrAddImageClicked, true);
            app.report_ToolbarEditOrAdd.Tooltip = {'Edita produto selecionado, ou adiciona não homologado'};
            app.report_ToolbarEditOrAdd.Layout.Row = [1 2];
            app.report_ToolbarEditOrAdd.Layout.Column = 2;
            app.report_ToolbarEditOrAdd.VerticalAlignment = 'bottom';
            app.report_ToolbarEditOrAdd.ImageSource = 'Edit_18x18Gray.png';

            % Create report_Tab2
            app.report_Tab2 = uitab(app.report_ControlTabGroup);
            app.report_Tab2.AutoResizeChildren = 'off';

            % Create report_Tab2Grid
            app.report_Tab2Grid = uigridlayout(app.report_Tab2);
            app.report_Tab2Grid.ColumnWidth = {'1x', 16};
            app.report_Tab2Grid.RowHeight = {22, 5, 88, 5, 22, 5, '1x', 1};
            app.report_Tab2Grid.ColumnSpacing = 5;
            app.report_Tab2Grid.RowSpacing = 0;
            app.report_Tab2Grid.Padding = [0 0 0 0];
            app.report_Tab2Grid.BackgroundColor = [1 1 1];

            % Create report_ProjectLabel
            app.report_ProjectLabel = uilabel(app.report_Tab2Grid);
            app.report_ProjectLabel.VerticalAlignment = 'bottom';
            app.report_ProjectLabel.FontSize = 10;
            app.report_ProjectLabel.Layout.Row = 1;
            app.report_ProjectLabel.Layout.Column = 1;
            app.report_ProjectLabel.Text = 'PROJETO';

            % Create report_ProjectPanel
            app.report_ProjectPanel = uipanel(app.report_Tab2Grid);
            app.report_ProjectPanel.AutoResizeChildren = 'off';
            app.report_ProjectPanel.Layout.Row = 3;
            app.report_ProjectPanel.Layout.Column = [1 2];

            % Create report_ProjectGrid
            app.report_ProjectGrid = uigridlayout(app.report_ProjectPanel);
            app.report_ProjectGrid.ColumnWidth = {'1x', 20, 20, 20};
            app.report_ProjectGrid.RowHeight = {17, 44};
            app.report_ProjectGrid.ColumnSpacing = 5;
            app.report_ProjectGrid.RowSpacing = 5;
            app.report_ProjectGrid.BackgroundColor = [1 1 1];

            % Create report_ProjectNameLabel
            app.report_ProjectNameLabel = uilabel(app.report_ProjectGrid);
            app.report_ProjectNameLabel.VerticalAlignment = 'bottom';
            app.report_ProjectNameLabel.FontSize = 10;
            app.report_ProjectNameLabel.Layout.Row = 1;
            app.report_ProjectNameLabel.Layout.Column = 1;
            app.report_ProjectNameLabel.Text = 'Arquivo:';

            % Create report_ProjectNew
            app.report_ProjectNew = uiimage(app.report_ProjectGrid);
            app.report_ProjectNew.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectNew.Tooltip = {'Cria novo projeto'};
            app.report_ProjectNew.Layout.Row = 1;
            app.report_ProjectNew.Layout.Column = 2;
            app.report_ProjectNew.ImageSource = fullfile(pathToMLAPP, 'Icons', 'AddFiles_36.png');

            % Create report_ProjectOpen
            app.report_ProjectOpen = uiimage(app.report_ProjectGrid);
            app.report_ProjectOpen.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectOpen.Tooltip = {'Abre projeto'};
            app.report_ProjectOpen.Layout.Row = 1;
            app.report_ProjectOpen.Layout.Column = 3;
            app.report_ProjectOpen.ImageSource = fullfile(pathToMLAPP, 'Icons', 'OpenFile_36x36.png');

            % Create report_ProjectSave
            app.report_ProjectSave = uiimage(app.report_ProjectGrid);
            app.report_ProjectSave.ImageClickedFcn = createCallbackFcn(app, @report_ProjectToolbarImageClicked, true);
            app.report_ProjectSave.Tooltip = {'Salva projeto'};
            app.report_ProjectSave.Layout.Row = 1;
            app.report_ProjectSave.Layout.Column = 4;
            app.report_ProjectSave.ImageSource = fullfile(pathToMLAPP, 'Icons', 'SaveFile_36.png');

            % Create report_ProjectName
            app.report_ProjectName = uitextarea(app.report_ProjectGrid);
            app.report_ProjectName.Editable = 'off';
            app.report_ProjectName.FontSize = 11;
            app.report_ProjectName.Layout.Row = 2;
            app.report_ProjectName.Layout.Column = [1 4];

            % Create report_IssuePanelLabel
            app.report_IssuePanelLabel = uilabel(app.report_Tab2Grid);
            app.report_IssuePanelLabel.VerticalAlignment = 'bottom';
            app.report_IssuePanelLabel.FontSize = 10;
            app.report_IssuePanelLabel.Layout.Row = 5;
            app.report_IssuePanelLabel.Layout.Column = 1;
            app.report_IssuePanelLabel.Text = 'ATIVIDADE DE INSPEÇÃO';

            % Create report_IssuePanel
            app.report_IssuePanel = uipanel(app.report_Tab2Grid);
            app.report_IssuePanel.AutoResizeChildren = 'off';
            app.report_IssuePanel.Layout.Row = 7;
            app.report_IssuePanel.Layout.Column = [1 2];

            % Create report_IssueGrid
            app.report_IssueGrid = uigridlayout(app.report_IssuePanel);
            app.report_IssueGrid.ColumnWidth = {110, '1x'};
            app.report_IssueGrid.RowHeight = {17, 22, 17, 110, 17, '1x'};
            app.report_IssueGrid.RowSpacing = 5;
            app.report_IssueGrid.Padding = [10 10 10 5];
            app.report_IssueGrid.BackgroundColor = [1 1 1];

            % Create report_IssueLabel
            app.report_IssueLabel = uilabel(app.report_IssueGrid);
            app.report_IssueLabel.VerticalAlignment = 'bottom';
            app.report_IssueLabel.WordWrap = 'on';
            app.report_IssueLabel.FontSize = 10;
            app.report_IssueLabel.FontColor = [0.149 0.149 0.149];
            app.report_IssueLabel.Layout.Row = 1;
            app.report_IssueLabel.Layout.Column = 1;
            app.report_IssueLabel.Text = 'Inspeção:';

            % Create report_Issue
            app.report_Issue = uieditfield(app.report_IssueGrid, 'numeric');
            app.report_Issue.Limits = [-1 Inf];
            app.report_Issue.RoundFractionalValues = 'on';
            app.report_Issue.ValueDisplayFormat = '%d';
            app.report_Issue.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_Issue.FontSize = 11;
            app.report_Issue.FontColor = [0.149 0.149 0.149];
            app.report_Issue.Layout.Row = 2;
            app.report_Issue.Layout.Column = 1;
            app.report_Issue.Value = -1;

            % Create report_EntityPanelLabel
            app.report_EntityPanelLabel = uilabel(app.report_IssueGrid);
            app.report_EntityPanelLabel.VerticalAlignment = 'bottom';
            app.report_EntityPanelLabel.FontSize = 10;
            app.report_EntityPanelLabel.Layout.Row = 3;
            app.report_EntityPanelLabel.Layout.Column = 1;
            app.report_EntityPanelLabel.Text = 'Fiscalizada';

            % Create report_EntityPanel
            app.report_EntityPanel = uipanel(app.report_IssueGrid);
            app.report_EntityPanel.Layout.Row = 4;
            app.report_EntityPanel.Layout.Column = [1 2];

            % Create report_EntityGrid
            app.report_EntityGrid = uigridlayout(app.report_EntityPanel);
            app.report_EntityGrid.ColumnWidth = {'1x', 16, 110};
            app.report_EntityGrid.RowHeight = {17, 22, 17, 22};
            app.report_EntityGrid.RowSpacing = 5;
            app.report_EntityGrid.Padding = [10 10 10 5];
            app.report_EntityGrid.BackgroundColor = [1 1 1];

            % Create report_EntityLabel
            app.report_EntityLabel = uilabel(app.report_EntityGrid);
            app.report_EntityLabel.VerticalAlignment = 'bottom';
            app.report_EntityLabel.WordWrap = 'on';
            app.report_EntityLabel.FontSize = 10;
            app.report_EntityLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityLabel.Layout.Row = 1;
            app.report_EntityLabel.Layout.Column = 1;
            app.report_EntityLabel.Text = 'Nome:';

            % Create report_Entity
            app.report_Entity = uieditfield(app.report_EntityGrid, 'text');
            app.report_Entity.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_Entity.FontSize = 11;
            app.report_Entity.Layout.Row = 2;
            app.report_Entity.Layout.Column = [1 3];

            % Create report_EntityIDLabel
            app.report_EntityIDLabel = uilabel(app.report_EntityGrid);
            app.report_EntityIDLabel.VerticalAlignment = 'bottom';
            app.report_EntityIDLabel.WordWrap = 'on';
            app.report_EntityIDLabel.FontSize = 10;
            app.report_EntityIDLabel.FontColor = [0.149 0.149 0.149];
            app.report_EntityIDLabel.Layout.Row = 3;
            app.report_EntityIDLabel.Layout.Column = 1;
            app.report_EntityIDLabel.Text = 'CNPJ/CPF:';

            % Create report_EntityID
            app.report_EntityID = uieditfield(app.report_EntityGrid, 'text');
            app.report_EntityID.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_EntityID.FontSize = 11;
            app.report_EntityID.Layout.Row = 4;
            app.report_EntityID.Layout.Column = [1 2];

            % Create report_EntityTypeLabel
            app.report_EntityTypeLabel = uilabel(app.report_EntityGrid);
            app.report_EntityTypeLabel.VerticalAlignment = 'bottom';
            app.report_EntityTypeLabel.FontSize = 10;
            app.report_EntityTypeLabel.Layout.Row = 3;
            app.report_EntityTypeLabel.Layout.Column = 3;
            app.report_EntityTypeLabel.Text = 'Tipo:';

            % Create report_EntityType
            app.report_EntityType = uidropdown(app.report_EntityGrid);
            app.report_EntityType.Items = {'', 'Importador', 'Fornecedor', 'Usuário'};
            app.report_EntityType.ValueChangedFcn = createCallbackFcn(app, @report_ProjectWarnImageVisibility, true);
            app.report_EntityType.FontSize = 11;
            app.report_EntityType.BackgroundColor = [1 1 1];
            app.report_EntityType.Layout.Row = 4;
            app.report_EntityType.Layout.Column = 3;
            app.report_EntityType.Value = '';

            % Create Image
            app.Image = uiimage(app.report_EntityGrid);
            app.Image.ImageClickedFcn = createCallbackFcn(app, @report_EntityIDCheck, true);
            app.Image.Layout.Row = 3;
            app.Image.Layout.Column = 2;
            app.Image.VerticalAlignment = 'bottom';
            app.Image.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Info_36.png');

            % Create report_DocumentLabel
            app.report_DocumentLabel = uilabel(app.report_IssueGrid);
            app.report_DocumentLabel.VerticalAlignment = 'bottom';
            app.report_DocumentLabel.FontSize = 10;
            app.report_DocumentLabel.Layout.Row = 5;
            app.report_DocumentLabel.Layout.Column = 1;
            app.report_DocumentLabel.Text = 'Documento';

            % Create report_DocumentPanel
            app.report_DocumentPanel = uipanel(app.report_IssueGrid);
            app.report_DocumentPanel.AutoResizeChildren = 'off';
            app.report_DocumentPanel.Layout.Row = 6;
            app.report_DocumentPanel.Layout.Column = [1 2];

            % Create report_DocumentGrid
            app.report_DocumentGrid = uigridlayout(app.report_DocumentPanel);
            app.report_DocumentGrid.ColumnWidth = {'1x', 110};
            app.report_DocumentGrid.RowHeight = {17, 22};
            app.report_DocumentGrid.RowSpacing = 5;
            app.report_DocumentGrid.Padding = [10 10 10 5];
            app.report_DocumentGrid.BackgroundColor = [1 1 1];

            % Create report_ModelNameLabel
            app.report_ModelNameLabel = uilabel(app.report_DocumentGrid);
            app.report_ModelNameLabel.VerticalAlignment = 'bottom';
            app.report_ModelNameLabel.WordWrap = 'on';
            app.report_ModelNameLabel.FontSize = 10;
            app.report_ModelNameLabel.Layout.Row = 1;
            app.report_ModelNameLabel.Layout.Column = 1;
            app.report_ModelNameLabel.Text = 'Modelo:';

            % Create report_ModelName
            app.report_ModelName = uidropdown(app.report_DocumentGrid);
            app.report_ModelName.Items = {};
            app.report_ModelName.ValueChangedFcn = createCallbackFcn(app, @report_ModelNameValueChanged, true);
            app.report_ModelName.FontSize = 11;
            app.report_ModelName.BackgroundColor = [1 1 1];
            app.report_ModelName.Layout.Row = 2;
            app.report_ModelName.Layout.Column = 1;
            app.report_ModelName.Value = {};

            % Create report_VersionLabel
            app.report_VersionLabel = uilabel(app.report_DocumentGrid);
            app.report_VersionLabel.VerticalAlignment = 'bottom';
            app.report_VersionLabel.WordWrap = 'on';
            app.report_VersionLabel.FontSize = 10;
            app.report_VersionLabel.Layout.Row = 1;
            app.report_VersionLabel.Layout.Column = 2;
            app.report_VersionLabel.Text = 'Versão:';

            % Create report_Version
            app.report_Version = uidropdown(app.report_DocumentGrid);
            app.report_Version.Items = {'Preliminar', 'Definitiva'};
            app.report_Version.FontSize = 11;
            app.report_Version.BackgroundColor = [1 1 1];
            app.report_Version.Layout.Row = 2;
            app.report_Version.Layout.Column = 2;
            app.report_Version.Value = 'Preliminar';

            % Create report_ProjectWarnIcon
            app.report_ProjectWarnIcon = uiimage(app.report_Tab2Grid);
            app.report_ProjectWarnIcon.Visible = 'off';
            app.report_ProjectWarnIcon.Tooltip = {'Pendente salvar projeto'};
            app.report_ProjectWarnIcon.Layout.Row = [1 2];
            app.report_ProjectWarnIcon.Layout.Column = 2;
            app.report_ProjectWarnIcon.VerticalAlignment = 'bottom';
            app.report_ProjectWarnIcon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Warn_18.png');

            % Create report_Tab3
            app.report_Tab3 = uitab(app.report_ControlTabGroup);

            % Create report_Tab3Grid
            app.report_Tab3Grid = uigridlayout(app.report_Tab3);
            app.report_Tab3Grid.ColumnWidth = {'1x', 16};
            app.report_Tab3Grid.RowHeight = {22, 5, '1x', 1};
            app.report_Tab3Grid.ColumnSpacing = 5;
            app.report_Tab3Grid.RowSpacing = 0;
            app.report_Tab3Grid.Padding = [0 0 0 0];
            app.report_Tab3Grid.BackgroundColor = [1 1 1];

            % Create report_Fiscaliza_PanelLabel
            app.report_Fiscaliza_PanelLabel = uilabel(app.report_Tab3Grid);
            app.report_Fiscaliza_PanelLabel.VerticalAlignment = 'bottom';
            app.report_Fiscaliza_PanelLabel.FontSize = 10;
            app.report_Fiscaliza_PanelLabel.Layout.Row = 1;
            app.report_Fiscaliza_PanelLabel.Layout.Column = 1;
            app.report_Fiscaliza_PanelLabel.Text = 'API FISCALIZA';

            % Create report_FiscalizaRefresh
            app.report_FiscalizaRefresh = uiimage(app.report_Tab3Grid);
            app.report_FiscalizaRefresh.ImageClickedFcn = createCallbackFcn(app, @report_FiscalizaCallbacks, true);
            app.report_FiscalizaRefresh.Tooltip = {'Atualiza informações da inspeção'};
            app.report_FiscalizaRefresh.Layout.Row = [1 2];
            app.report_FiscalizaRefresh.Layout.Column = 2;
            app.report_FiscalizaRefresh.VerticalAlignment = 'bottom';
            app.report_FiscalizaRefresh.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Refresh_18.png');

            % Create report_FiscalizaPanel
            app.report_FiscalizaPanel = uipanel(app.report_Tab3Grid);
            app.report_FiscalizaPanel.AutoResizeChildren = 'off';
            app.report_FiscalizaPanel.Layout.Row = 3;
            app.report_FiscalizaPanel.Layout.Column = [1 2];

            % Create report_FiscalizaGrid
            app.report_FiscalizaGrid = uigridlayout(app.report_FiscalizaPanel);
            app.report_FiscalizaGrid.ColumnWidth = {'1x'};
            app.report_FiscalizaGrid.RowHeight = {'1x'};
            app.report_FiscalizaGrid.BackgroundColor = [1 1 1];

            % Create report_FiscalizaIcon
            app.report_FiscalizaIcon = uiimage(app.report_FiscalizaGrid);
            app.report_FiscalizaIcon.Tag = 'FiscalizaPlaceHolder';
            app.report_FiscalizaIcon.Enable = 'off';
            app.report_FiscalizaIcon.Layout.Row = 1;
            app.report_FiscalizaIcon.Layout.Column = 1;
            app.report_FiscalizaIcon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Redmine_512.png');

            % Create report_ControlMenu
            app.report_ControlMenu = uigridlayout(app.report_Control);
            app.report_ControlMenu.ColumnWidth = {'1x', 22, 22};
            app.report_ControlMenu.RowHeight = {'1x', 3};
            app.report_ControlMenu.ColumnSpacing = 1;
            app.report_ControlMenu.RowSpacing = 0;
            app.report_ControlMenu.Padding = [0 0 0 0];
            app.report_ControlMenu.Layout.Row = [1 2];
            app.report_ControlMenu.Layout.Column = 1;
            app.report_ControlMenu.BackgroundColor = [1 1 1];

            % Create report_menuUnderline
            app.report_menuUnderline = uiimage(app.report_ControlMenu);
            app.report_menuUnderline.ScaleMethod = 'scaleup';
            app.report_menuUnderline.Layout.Row = 2;
            app.report_menuUnderline.Layout.Column = 1;
            app.report_menuUnderline.HorizontalAlignment = 'right';
            app.report_menuUnderline.ImageSource = fullfile(pathToMLAPP, 'Icons', 'LineH.png');

            % Create report_menuBtn1Grid
            app.report_menuBtn1Grid = uigridlayout(app.report_ControlMenu);
            app.report_menuBtn1Grid.ColumnWidth = {18, '1x'};
            app.report_menuBtn1Grid.RowHeight = {'1x'};
            app.report_menuBtn1Grid.ColumnSpacing = 3;
            app.report_menuBtn1Grid.Padding = [2 0 0 0];
            app.report_menuBtn1Grid.Layout.Row = 1;
            app.report_menuBtn1Grid.Layout.Column = 1;
            app.report_menuBtn1Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create report_menuBtn1Label
            app.report_menuBtn1Label = uilabel(app.report_menuBtn1Grid);
            app.report_menuBtn1Label.FontSize = 11;
            app.report_menuBtn1Label.Layout.Row = 1;
            app.report_menuBtn1Label.Layout.Column = 2;
            app.report_menuBtn1Label.Text = 'ASPECTOS GERAIS';

            % Create report_menuBtn1Icon
            app.report_menuBtn1Icon = uiimage(app.report_menuBtn1Grid);
            app.report_menuBtn1Icon.ScaleMethod = 'none';
            app.report_menuBtn1Icon.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_TabControlButtonPushed, true);
            app.report_menuBtn1Icon.Tag = '1';
            app.report_menuBtn1Icon.Layout.Row = 1;
            app.report_menuBtn1Icon.Layout.Column = [1 2];
            app.report_menuBtn1Icon.HorizontalAlignment = 'left';
            app.report_menuBtn1Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Classification_18.png');

            % Create report_menuBtn2Grid
            app.report_menuBtn2Grid = uigridlayout(app.report_ControlMenu);
            app.report_menuBtn2Grid.ColumnWidth = {18, 0};
            app.report_menuBtn2Grid.RowHeight = {'1x'};
            app.report_menuBtn2Grid.ColumnSpacing = 3;
            app.report_menuBtn2Grid.Padding = [2 0 0 0];
            app.report_menuBtn2Grid.Layout.Row = 1;
            app.report_menuBtn2Grid.Layout.Column = 2;
            app.report_menuBtn2Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create report_menuBtn2Label
            app.report_menuBtn2Label = uilabel(app.report_menuBtn2Grid);
            app.report_menuBtn2Label.FontSize = 11;
            app.report_menuBtn2Label.Layout.Row = 1;
            app.report_menuBtn2Label.Layout.Column = 2;
            app.report_menuBtn2Label.Text = 'PROJETO';

            % Create report_menuBtn2Icon
            app.report_menuBtn2Icon = uiimage(app.report_menuBtn2Grid);
            app.report_menuBtn2Icon.ScaleMethod = 'none';
            app.report_menuBtn2Icon.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_TabControlButtonPushed, true);
            app.report_menuBtn2Icon.Tag = '2';
            app.report_menuBtn2Icon.Layout.Row = 1;
            app.report_menuBtn2Icon.Layout.Column = [1 2];
            app.report_menuBtn2Icon.HorizontalAlignment = 'left';
            app.report_menuBtn2Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Report_18x18.png');

            % Create report_menuBtn3Grid
            app.report_menuBtn3Grid = uigridlayout(app.report_ControlMenu);
            app.report_menuBtn3Grid.ColumnWidth = {18, 0};
            app.report_menuBtn3Grid.RowHeight = {'1x'};
            app.report_menuBtn3Grid.ColumnSpacing = 3;
            app.report_menuBtn3Grid.Padding = [2 0 0 0];
            app.report_menuBtn3Grid.Layout.Row = 1;
            app.report_menuBtn3Grid.Layout.Column = 3;
            app.report_menuBtn3Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create report_menuBtn3Label
            app.report_menuBtn3Label = uilabel(app.report_menuBtn3Grid);
            app.report_menuBtn3Label.FontSize = 11;
            app.report_menuBtn3Label.Layout.Row = 1;
            app.report_menuBtn3Label.Layout.Column = 2;
            app.report_menuBtn3Label.Text = 'API FISCALIZA HOMOLOGAÇÃO';

            % Create report_menuBtn3Icon
            app.report_menuBtn3Icon = uiimage(app.report_menuBtn3Grid);
            app.report_menuBtn3Icon.ScaleMethod = 'none';
            app.report_menuBtn3Icon.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_TabControlButtonPushed, true);
            app.report_menuBtn3Icon.Tag = '3';
            app.report_menuBtn3Icon.Layout.Row = 1;
            app.report_menuBtn3Icon.Layout.Column = [1 2];
            app.report_menuBtn3Icon.HorizontalAlignment = 'left';
            app.report_menuBtn3Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Redmine_18.png');

            % Create Tab3_Config
            app.Tab3_Config = uitab(app.TabGroup);
            app.Tab3_Config.AutoResizeChildren = 'off';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.Tab3_Config);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'1x', 34};
            app.GridLayout5.RowSpacing = 0;
            app.GridLayout5.Padding = [0 0 0 26];
            app.GridLayout5.BackgroundColor = [1 1 1];

            % Create file_toolGrid_3
            app.file_toolGrid_3 = uigridlayout(app.GridLayout5);
            app.file_toolGrid_3.ColumnWidth = {22, 22, 110, '1x', 110};
            app.file_toolGrid_3.RowHeight = {'1x', 17, '1x'};
            app.file_toolGrid_3.ColumnSpacing = 5;
            app.file_toolGrid_3.RowSpacing = 0;
            app.file_toolGrid_3.Padding = [5 6 5 6];
            app.file_toolGrid_3.Layout.Row = 2;
            app.file_toolGrid_3.Layout.Column = 1;

            % Create config_PanelVisibility
            app.config_PanelVisibility = uiimage(app.file_toolGrid_3);
            app.config_PanelVisibility.ImageClickedFcn = createCallbackFcn(app, @misc_Panel_VisibilityImageClicked, true);
            app.config_PanelVisibility.Visible = 'off';
            app.config_PanelVisibility.Layout.Row = 2;
            app.config_PanelVisibility.Layout.Column = 1;
            app.config_PanelVisibility.ImageSource = fullfile(pathToMLAPP, 'Icons', 'ArrowLeft_32.png');

            % Create config_mainGrid
            app.config_mainGrid = uigridlayout(app.GridLayout5);
            app.config_mainGrid.ColumnWidth = {330, '1x', '1x', '1x'};
            app.config_mainGrid.RowHeight = {'1x'};
            app.config_mainGrid.Padding = [5 5 5 0];
            app.config_mainGrid.Layout.Row = 1;
            app.config_mainGrid.Layout.Column = 1;
            app.config_mainGrid.BackgroundColor = [1 1 1];

            % Create config_Control
            app.config_Control = uigridlayout(app.config_mainGrid);
            app.config_Control.ColumnWidth = {'1x'};
            app.config_Control.RowHeight = {2, 24, 21, 5, '1x', 1};
            app.config_Control.ColumnSpacing = 0;
            app.config_Control.RowSpacing = 0;
            app.config_Control.Padding = [0 0 0 0];
            app.config_Control.Layout.Row = 1;
            app.config_Control.Layout.Column = 1;
            app.config_Control.BackgroundColor = [1 1 1];

            % Create config_ControlMenu
            app.config_ControlMenu = uigridlayout(app.config_Control);
            app.config_ControlMenu.ColumnWidth = {'1x'};
            app.config_ControlMenu.RowHeight = {'1x', 3};
            app.config_ControlMenu.ColumnSpacing = 5;
            app.config_ControlMenu.RowSpacing = 0;
            app.config_ControlMenu.Padding = [0 0 0 0];
            app.config_ControlMenu.Layout.Row = [1 2];
            app.config_ControlMenu.Layout.Column = 1;
            app.config_ControlMenu.BackgroundColor = [1 1 1];

            % Create config_menuUnderline
            app.config_menuUnderline = uiimage(app.config_ControlMenu);
            app.config_menuUnderline.ScaleMethod = 'scaleup';
            app.config_menuUnderline.Layout.Row = 2;
            app.config_menuUnderline.Layout.Column = 1;
            app.config_menuUnderline.HorizontalAlignment = 'right';
            app.config_menuUnderline.ImageSource = fullfile(pathToMLAPP, 'Icons', 'LineH.png');

            % Create config_menuBtn1Grid
            app.config_menuBtn1Grid = uigridlayout(app.config_ControlMenu);
            app.config_menuBtn1Grid.ColumnWidth = {18, '1x'};
            app.config_menuBtn1Grid.RowHeight = {'1x'};
            app.config_menuBtn1Grid.ColumnSpacing = 3;
            app.config_menuBtn1Grid.Padding = [2 0 0 0];
            app.config_menuBtn1Grid.Layout.Row = 1;
            app.config_menuBtn1Grid.Layout.Column = 1;
            app.config_menuBtn1Grid.BackgroundColor = [0.9608 0.9608 0.9608];

            % Create config_menuBtn1Label
            app.config_menuBtn1Label = uilabel(app.config_menuBtn1Grid);
            app.config_menuBtn1Label.FontSize = 11;
            app.config_menuBtn1Label.Layout.Row = 1;
            app.config_menuBtn1Label.Layout.Column = 2;
            app.config_menuBtn1Label.Text = 'CONFIGURAÇÕES';

            % Create config_menuBtn1Icon
            app.config_menuBtn1Icon = uiimage(app.config_menuBtn1Grid);
            app.config_menuBtn1Icon.ScaleMethod = 'none';
            app.config_menuBtn1Icon.Tag = '1';
            app.config_menuBtn1Icon.Layout.Row = 1;
            app.config_menuBtn1Icon.Layout.Column = [1 2];
            app.config_menuBtn1Icon.HorizontalAlignment = 'left';
            app.config_menuBtn1Icon.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Settings_18.png');

            % Create config_Label
            app.config_Label = uilabel(app.config_Control);
            app.config_Label.VerticalAlignment = 'bottom';
            app.config_Label.FontSize = 10;
            app.config_Label.Layout.Row = 3;
            app.config_Label.Layout.Column = 1;
            app.config_Label.Text = 'PARÂMETROS A CONFIGURAR';

            % Create Panel
            app.Panel = uipanel(app.config_Control);
            app.Panel.Layout.Row = 5;
            app.Panel.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {88, '1x'};
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create config_ButtonGroup
            app.config_ButtonGroup = uibuttongroup(app.GridLayout2);
            app.config_ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @config_ButtonGroupSelectionChanged, true);
            app.config_ButtonGroup.BorderType = 'none';
            app.config_ButtonGroup.BackgroundColor = [1 1 1];
            app.config_ButtonGroup.Layout.Row = 1;
            app.config_ButtonGroup.Layout.Column = 1;
            app.config_ButtonGroup.FontSize = 11;

            % Create config_Option_Search
            app.config_Option_Search = uiradiobutton(app.config_ButtonGroup);
            app.config_Option_Search.Text = 'Pesquisa';
            app.config_Option_Search.FontSize = 11;
            app.config_Option_Search.Position = [11 58 67 22];
            app.config_Option_Search.Value = true;

            % Create config_Option_Fiscaliza
            app.config_Option_Fiscaliza = uiradiobutton(app.config_ButtonGroup);
            app.config_Option_Fiscaliza.Text = 'API Fiscaliza';
            app.config_Option_Fiscaliza.FontSize = 11;
            app.config_Option_Fiscaliza.Position = [11 36 86 22];

            % Create config_Option_Folder
            app.config_Option_Folder = uiradiobutton(app.config_ButtonGroup);
            app.config_Option_Folder.Text = 'Mapeamento de pastas';
            app.config_Option_Folder.FontSize = 11;
            app.config_Option_Folder.Position = [11 14 137 22];

            % Create config_Option1Grid
            app.config_Option1Grid = uigridlayout(app.config_mainGrid);
            app.config_Option1Grid.ColumnWidth = {'1x'};
            app.config_Option1Grid.RowHeight = {22, 5, '1x', 1};
            app.config_Option1Grid.RowSpacing = 0;
            app.config_Option1Grid.Padding = [0 0 0 0];
            app.config_Option1Grid.Layout.Row = 1;
            app.config_Option1Grid.Layout.Column = 4;
            app.config_Option1Grid.BackgroundColor = [1 1 1];

            % Create config_FolderMapLabel
            app.config_FolderMapLabel = uilabel(app.config_Option1Grid);
            app.config_FolderMapLabel.VerticalAlignment = 'bottom';
            app.config_FolderMapLabel.FontSize = 10;
            app.config_FolderMapLabel.Layout.Row = 1;
            app.config_FolderMapLabel.Layout.Column = 1;
            app.config_FolderMapLabel.Text = 'MAPEAMENTO DE PASTAS';

            % Create config_FolderMapPanel
            app.config_FolderMapPanel = uipanel(app.config_Option1Grid);
            app.config_FolderMapPanel.AutoResizeChildren = 'off';
            app.config_FolderMapPanel.Layout.Row = 3;
            app.config_FolderMapPanel.Layout.Column = 1;

            % Create config_FolderMapGrid
            app.config_FolderMapGrid = uigridlayout(app.config_FolderMapPanel);
            app.config_FolderMapGrid.ColumnWidth = {'1x', 20};
            app.config_FolderMapGrid.RowHeight = {17, 22, 17, 22, 17, 22, 17, 22, 17, 22};
            app.config_FolderMapGrid.ColumnSpacing = 5;
            app.config_FolderMapGrid.RowSpacing = 5;
            app.config_FolderMapGrid.Padding = [10 10 10 5];
            app.config_FolderMapGrid.BackgroundColor = [1 1 1];

            % Create config_Folder_DataHubGETLabel
            app.config_Folder_DataHubGETLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_DataHubGETLabel.VerticalAlignment = 'bottom';
            app.config_Folder_DataHubGETLabel.FontSize = 10;
            app.config_Folder_DataHubGETLabel.Layout.Row = 1;
            app.config_Folder_DataHubGETLabel.Layout.Column = 1;
            app.config_Folder_DataHubGETLabel.Text = 'DataHub - GET:';

            % Create config_Folder_DataHubGET
            app.config_Folder_DataHubGET = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_DataHubGET.Editable = 'off';
            app.config_Folder_DataHubGET.FontSize = 11;
            app.config_Folder_DataHubGET.Layout.Row = 2;
            app.config_Folder_DataHubGET.Layout.Column = 1;

            % Create config_Folder_DataHubGETButton
            app.config_Folder_DataHubGETButton = uiimage(app.config_FolderMapGrid);
            app.config_Folder_DataHubGETButton.ImageClickedFcn = createCallbackFcn(app, @config_getFolder, true);
            app.config_Folder_DataHubGETButton.Tag = 'DataHub_GET';
            app.config_Folder_DataHubGETButton.Layout.Row = 2;
            app.config_Folder_DataHubGETButton.Layout.Column = 2;
            app.config_Folder_DataHubGETButton.ImageSource = fullfile(pathToMLAPP, 'Icons', 'OpenFile_36x36.png');

            % Create config_Folder_DataHubPOSTLabel
            app.config_Folder_DataHubPOSTLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_DataHubPOSTLabel.VerticalAlignment = 'bottom';
            app.config_Folder_DataHubPOSTLabel.FontSize = 10;
            app.config_Folder_DataHubPOSTLabel.Layout.Row = 3;
            app.config_Folder_DataHubPOSTLabel.Layout.Column = 1;
            app.config_Folder_DataHubPOSTLabel.Text = 'DataHub - POST:';

            % Create config_Folder_DataHubPOST
            app.config_Folder_DataHubPOST = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_DataHubPOST.Editable = 'off';
            app.config_Folder_DataHubPOST.FontSize = 11;
            app.config_Folder_DataHubPOST.Layout.Row = 4;
            app.config_Folder_DataHubPOST.Layout.Column = 1;

            % Create config_Folder_DataHubPOSTButton
            app.config_Folder_DataHubPOSTButton = uiimage(app.config_FolderMapGrid);
            app.config_Folder_DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @config_getFolder, true);
            app.config_Folder_DataHubPOSTButton.Tag = 'DataHub_POST';
            app.config_Folder_DataHubPOSTButton.Layout.Row = 4;
            app.config_Folder_DataHubPOSTButton.Layout.Column = 2;
            app.config_Folder_DataHubPOSTButton.ImageSource = fullfile(pathToMLAPP, 'Icons', 'OpenFile_36x36.png');

            % Create config_Folder_pythonPathLabel
            app.config_Folder_pythonPathLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_pythonPathLabel.VerticalAlignment = 'bottom';
            app.config_Folder_pythonPathLabel.FontSize = 10;
            app.config_Folder_pythonPathLabel.Layout.Row = 5;
            app.config_Folder_pythonPathLabel.Layout.Column = 1;
            app.config_Folder_pythonPathLabel.Text = 'Pasta do ambiente virtual Python (lib fiscaliza):';

            % Create config_Folder_pythonPath
            app.config_Folder_pythonPath = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_pythonPath.Editable = 'off';
            app.config_Folder_pythonPath.FontSize = 11;
            app.config_Folder_pythonPath.Layout.Row = 6;
            app.config_Folder_pythonPath.Layout.Column = 1;

            % Create config_Folder_pythonPathButton
            app.config_Folder_pythonPathButton = uiimage(app.config_FolderMapGrid);
            app.config_Folder_pythonPathButton.ImageClickedFcn = createCallbackFcn(app, @config_getFolder, true);
            app.config_Folder_pythonPathButton.Tag = 'pythonPath';
            app.config_Folder_pythonPathButton.Layout.Row = 6;
            app.config_Folder_pythonPathButton.Layout.Column = 2;
            app.config_Folder_pythonPathButton.ImageSource = fullfile(pathToMLAPP, 'Icons', 'OpenFile_36x36.png');

            % Create config_Folder_userPathLabel
            app.config_Folder_userPathLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_userPathLabel.VerticalAlignment = 'bottom';
            app.config_Folder_userPathLabel.FontSize = 10;
            app.config_Folder_userPathLabel.Layout.Row = 7;
            app.config_Folder_userPathLabel.Layout.Column = 1;
            app.config_Folder_userPathLabel.Text = 'Pasta do usuário:';

            % Create config_Folder_userPath
            app.config_Folder_userPath = uidropdown(app.config_FolderMapGrid);
            app.config_Folder_userPath.Items = {''};
            app.config_Folder_userPath.FontSize = 11;
            app.config_Folder_userPath.BackgroundColor = [1 1 1];
            app.config_Folder_userPath.Layout.Row = 8;
            app.config_Folder_userPath.Layout.Column = 1;
            app.config_Folder_userPath.Value = '';

            % Create config_Folder_userPathButton
            app.config_Folder_userPathButton = uiimage(app.config_FolderMapGrid);
            app.config_Folder_userPathButton.ImageClickedFcn = createCallbackFcn(app, @config_getFolder, true);
            app.config_Folder_userPathButton.Tag = 'userPath';
            app.config_Folder_userPathButton.Layout.Row = 8;
            app.config_Folder_userPathButton.Layout.Column = 2;
            app.config_Folder_userPathButton.ImageSource = fullfile(pathToMLAPP, 'Icons', 'OpenFile_36x36.png');

            % Create config_Folder_tempPathLabel
            app.config_Folder_tempPathLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_tempPathLabel.VerticalAlignment = 'bottom';
            app.config_Folder_tempPathLabel.FontSize = 10;
            app.config_Folder_tempPathLabel.Layout.Row = 9;
            app.config_Folder_tempPathLabel.Layout.Column = 1;
            app.config_Folder_tempPathLabel.Text = 'Pasta temporária:';

            % Create config_Folder_tempPath
            app.config_Folder_tempPath = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_tempPath.Editable = 'off';
            app.config_Folder_tempPath.FontSize = 11;
            app.config_Folder_tempPath.Layout.Row = 10;
            app.config_Folder_tempPath.Layout.Column = 1;

            % Create config_Option2Grid
            app.config_Option2Grid = uigridlayout(app.config_mainGrid);
            app.config_Option2Grid.ColumnWidth = {'1x', 16};
            app.config_Option2Grid.RowHeight = {22, 5, 68, 5, 22, 5, 64, 5, 22, 5, 64, 5, 22, 5, '1x', 1};
            app.config_Option2Grid.RowSpacing = 0;
            app.config_Option2Grid.Padding = [0 0 0 0];
            app.config_Option2Grid.Layout.Row = 1;
            app.config_Option2Grid.Layout.Column = 2;
            app.config_Option2Grid.BackgroundColor = [1 1 1];

            % Create config_SearchModeLabel
            app.config_SearchModeLabel = uilabel(app.config_Option2Grid);
            app.config_SearchModeLabel.VerticalAlignment = 'bottom';
            app.config_SearchModeLabel.FontSize = 10;
            app.config_SearchModeLabel.Layout.Row = 1;
            app.config_SearchModeLabel.Layout.Column = 1;
            app.config_SearchModeLabel.Text = 'MODO';

            % Create config_SearchModePanel
            app.config_SearchModePanel = uibuttongroup(app.config_Option2Grid);
            app.config_SearchModePanel.AutoResizeChildren = 'off';
            app.config_SearchModePanel.SelectionChangedFcn = createCallbackFcn(app, @config_SearchModeChanged, true);
            app.config_SearchModePanel.BackgroundColor = [1 1 1];
            app.config_SearchModePanel.Layout.Row = 3;
            app.config_SearchModePanel.Layout.Column = [1 2];

            % Create config_SearchModeTokenSuggestion
            app.config_SearchModeTokenSuggestion = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeTokenSuggestion.Tag = 'strcmp';
            app.config_SearchModeTokenSuggestion.Text = '<p style="text-align:justify; line-height:1.1;">Pesquisa orientada à palavra que está sendo escrita, sugerindo <i>tokens</i> relacionados.</p>';
            app.config_SearchModeTokenSuggestion.WordWrap = 'on';
            app.config_SearchModeTokenSuggestion.FontSize = 11;
            app.config_SearchModeTokenSuggestion.Interpreter = 'html';
            app.config_SearchModeTokenSuggestion.Position = [10 33 840 29];
            app.config_SearchModeTokenSuggestion.Value = true;

            % Create config_SearchModeListOfWords
            app.config_SearchModeListOfWords = uiradiobutton(app.config_SearchModePanel);
            app.config_SearchModeListOfWords.Tag = 'contains';
            app.config_SearchModeListOfWords.Text = '<p style="text-align:justify; line-height:1.1;">Pesquisa orientada à uma lista de palavras separadas por vírgulas. Não há sugestão de <i>tokens</i> relacionados.</p>';
            app.config_SearchModeListOfWords.WordWrap = 'on';
            app.config_SearchModeListOfWords.FontSize = 11;
            app.config_SearchModeListOfWords.Interpreter = 'html';
            app.config_SearchModeListOfWords.Position = [11 4 837 34];

            % Create config_MiscelaneousLabel1
            app.config_MiscelaneousLabel1 = uilabel(app.config_Option2Grid);
            app.config_MiscelaneousLabel1.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel1.FontSize = 10;
            app.config_MiscelaneousLabel1.Layout.Row = 5;
            app.config_MiscelaneousLabel1.Layout.Column = 1;
            app.config_MiscelaneousLabel1.Text = 'ALGORITMO SUGESTÃO DE TOKENS';

            % Create config_MiscelaneousPanel1
            app.config_MiscelaneousPanel1 = uipanel(app.config_Option2Grid);
            app.config_MiscelaneousPanel1.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel1.Layout.Row = 7;
            app.config_MiscelaneousPanel1.Layout.Column = [1 2];

            % Create config_MiscelaneousGrid1
            app.config_MiscelaneousGrid1 = uigridlayout(app.config_MiscelaneousPanel1);
            app.config_MiscelaneousGrid1.ColumnWidth = {150, 150};
            app.config_MiscelaneousGrid1.RowHeight = {17, 22};
            app.config_MiscelaneousGrid1.RowSpacing = 5;
            app.config_MiscelaneousGrid1.Padding = [10 10 10 5];
            app.config_MiscelaneousGrid1.BackgroundColor = [1 1 1];

            % Create config_nMinCharactersLabel
            app.config_nMinCharactersLabel = uilabel(app.config_MiscelaneousGrid1);
            app.config_nMinCharactersLabel.VerticalAlignment = 'bottom';
            app.config_nMinCharactersLabel.WordWrap = 'on';
            app.config_nMinCharactersLabel.FontSize = 10;
            app.config_nMinCharactersLabel.Layout.Row = 1;
            app.config_nMinCharactersLabel.Layout.Column = 1;
            app.config_nMinCharactersLabel.Text = 'Qtd. mínima caracteres:';

            % Create config_nMinCharacters
            app.config_nMinCharacters = uispinner(app.config_MiscelaneousGrid1);
            app.config_nMinCharacters.Limits = [2 4];
            app.config_nMinCharacters.RoundFractionalValues = 'on';
            app.config_nMinCharacters.ValueDisplayFormat = '%d';
            app.config_nMinCharacters.FontSize = 11;
            app.config_nMinCharacters.Layout.Row = 2;
            app.config_nMinCharacters.Layout.Column = 1;
            app.config_nMinCharacters.Value = 2;

            % Create config_nMinWordsLabel
            app.config_nMinWordsLabel = uilabel(app.config_MiscelaneousGrid1);
            app.config_nMinWordsLabel.VerticalAlignment = 'bottom';
            app.config_nMinWordsLabel.WordWrap = 'on';
            app.config_nMinWordsLabel.FontSize = 10;
            app.config_nMinWordsLabel.Layout.Row = 1;
            app.config_nMinWordsLabel.Layout.Column = 2;
            app.config_nMinWordsLabel.Interpreter = 'html';
            app.config_nMinWordsLabel.Text = 'Qtd. mínima <i>tokens</i>:';

            % Create config_nMinWords
            app.config_nMinWords = uidropdown(app.config_MiscelaneousGrid1);
            app.config_nMinWords.Items = {'20', '50', '100'};
            app.config_nMinWords.FontSize = 11;
            app.config_nMinWords.BackgroundColor = [1 1 1];
            app.config_nMinWords.Layout.Row = 2;
            app.config_nMinWords.Layout.Column = 2;
            app.config_nMinWords.Value = '20';

            % Create config_MiscelaneousLabel2
            app.config_MiscelaneousLabel2 = uilabel(app.config_Option2Grid);
            app.config_MiscelaneousLabel2.VerticalAlignment = 'bottom';
            app.config_MiscelaneousLabel2.FontSize = 10;
            app.config_MiscelaneousLabel2.Layout.Row = 9;
            app.config_MiscelaneousLabel2.Layout.Column = 1;
            app.config_MiscelaneousLabel2.Text = 'ANOTAÇÃO DO TIPO "WORDCLOUD"';

            % Create config_MiscelaneousPanel2
            app.config_MiscelaneousPanel2 = uipanel(app.config_Option2Grid);
            app.config_MiscelaneousPanel2.AutoResizeChildren = 'off';
            app.config_MiscelaneousPanel2.Layout.Row = 11;
            app.config_MiscelaneousPanel2.Layout.Column = [1 2];

            % Create config_MiscelaneousGrid2
            app.config_MiscelaneousGrid2 = uigridlayout(app.config_MiscelaneousPanel2);
            app.config_MiscelaneousGrid2.ColumnWidth = {150, 150};
            app.config_MiscelaneousGrid2.RowHeight = {17, 22};
            app.config_MiscelaneousGrid2.RowSpacing = 5;
            app.config_MiscelaneousGrid2.Padding = [10 10 10 5];
            app.config_MiscelaneousGrid2.BackgroundColor = [1 1 1];

            % Create config_WordCloudAlgorithmLabel
            app.config_WordCloudAlgorithmLabel = uilabel(app.config_MiscelaneousGrid2);
            app.config_WordCloudAlgorithmLabel.VerticalAlignment = 'bottom';
            app.config_WordCloudAlgorithmLabel.WordWrap = 'on';
            app.config_WordCloudAlgorithmLabel.FontSize = 10;
            app.config_WordCloudAlgorithmLabel.Layout.Row = 1;
            app.config_WordCloudAlgorithmLabel.Layout.Column = 1;
            app.config_WordCloudAlgorithmLabel.Text = 'Algoritmo gráfico:';

            % Create config_WordCloudAlgorithm
            app.config_WordCloudAlgorithm = uidropdown(app.config_MiscelaneousGrid2);
            app.config_WordCloudAlgorithm.Items = {'D3.js', 'MATLAB built-in'};
            app.config_WordCloudAlgorithm.ValueChangedFcn = createCallbackFcn(app, @config_WordCloudAlgorithmValueChanged, true);
            app.config_WordCloudAlgorithm.FontSize = 11;
            app.config_WordCloudAlgorithm.BackgroundColor = [1 1 1];
            app.config_WordCloudAlgorithm.Layout.Row = 2;
            app.config_WordCloudAlgorithm.Layout.Column = 1;
            app.config_WordCloudAlgorithm.Value = 'D3.js';

            % Create config_WordCloudColumnLabel
            app.config_WordCloudColumnLabel = uilabel(app.config_MiscelaneousGrid2);
            app.config_WordCloudColumnLabel.VerticalAlignment = 'bottom';
            app.config_WordCloudColumnLabel.WordWrap = 'on';
            app.config_WordCloudColumnLabel.FontSize = 10;
            app.config_WordCloudColumnLabel.Layout.Row = 1;
            app.config_WordCloudColumnLabel.Layout.Column = 2;
            app.config_WordCloudColumnLabel.Text = 'Pesquisa orientada à coluna:';

            % Create config_WordCloudColumn
            app.config_WordCloudColumn = uidropdown(app.config_MiscelaneousGrid2);
            app.config_WordCloudColumn.Items = {'Modelo', 'Nome Comercial'};
            app.config_WordCloudColumn.FontSize = 11;
            app.config_WordCloudColumn.BackgroundColor = [1 1 1];
            app.config_WordCloudColumn.Layout.Row = 2;
            app.config_WordCloudColumn.Layout.Column = 2;
            app.config_WordCloudColumn.Value = 'Modelo';

            % Create config_SelectedTableColumnsLabel
            app.config_SelectedTableColumnsLabel = uilabel(app.config_Option2Grid);
            app.config_SelectedTableColumnsLabel.VerticalAlignment = 'bottom';
            app.config_SelectedTableColumnsLabel.FontSize = 10;
            app.config_SelectedTableColumnsLabel.Layout.Row = 13;
            app.config_SelectedTableColumnsLabel.Layout.Column = 1;
            app.config_SelectedTableColumnsLabel.Text = 'VISIBILIDADE DE COLUNAS';

            % Create config_SelectedTableColumns
            app.config_SelectedTableColumns = uitree(app.config_Option2Grid, 'checkbox');
            app.config_SelectedTableColumns.FontSize = 11;
            app.config_SelectedTableColumns.Layout.Row = 15;
            app.config_SelectedTableColumns.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.config_SelectedTableColumns.CheckedNodesChangedFcn = createCallbackFcn(app, @config_ListOfColumns2ShowChanged, true);

            % Create Image2
            app.Image2 = uiimage(app.config_Option2Grid);
            app.Image2.ImageClickedFcn = createCallbackFcn(app, @Image2Clicked, true);
            app.Image2.Layout.Row = 13;
            app.Image2.Layout.Column = 2;
            app.Image2.VerticalAlignment = 'bottom';
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Refresh_18.png');

            % Create config_Option3Grid
            app.config_Option3Grid = uigridlayout(app.config_mainGrid);
            app.config_Option3Grid.ColumnWidth = {'1x', 20};
            app.config_Option3Grid.RowHeight = {22, 5, 68, 15, 12, 5, '1x', 1};
            app.config_Option3Grid.RowSpacing = 0;
            app.config_Option3Grid.Padding = [0 0 0 0];
            app.config_Option3Grid.Layout.Row = 1;
            app.config_Option3Grid.Layout.Column = 3;
            app.config_Option3Grid.BackgroundColor = [1 1 1];

            % Create config_FiscalizaVersionLabel
            app.config_FiscalizaVersionLabel = uilabel(app.config_Option3Grid);
            app.config_FiscalizaVersionLabel.VerticalAlignment = 'bottom';
            app.config_FiscalizaVersionLabel.FontSize = 10;
            app.config_FiscalizaVersionLabel.Layout.Row = 1;
            app.config_FiscalizaVersionLabel.Layout.Column = 1;
            app.config_FiscalizaVersionLabel.Text = 'VERSÃO DO SISTEMA';

            % Create config_FiscalizaVersion
            app.config_FiscalizaVersion = uibuttongroup(app.config_Option3Grid);
            app.config_FiscalizaVersion.SelectionChangedFcn = createCallbackFcn(app, @config_FiscalizaMode, true);
            app.config_FiscalizaVersion.BackgroundColor = [1 1 1];
            app.config_FiscalizaVersion.Layout.Row = 3;
            app.config_FiscalizaVersion.Layout.Column = [1 2];

            % Create config_FiscalizaPD
            app.config_FiscalizaPD = uiradiobutton(app.config_FiscalizaVersion);
            app.config_FiscalizaPD.Text = 'FISCALIZA PRODUÇÃO';
            app.config_FiscalizaPD.FontSize = 11;
            app.config_FiscalizaPD.Interpreter = 'html';
            app.config_FiscalizaPD.Position = [10 36 146 22];

            % Create config_FiscalizaHM
            app.config_FiscalizaHM = uiradiobutton(app.config_FiscalizaVersion);
            app.config_FiscalizaHM.Text = 'FISCALIZA <font style="color: red;">HOMOLOGAÇÃO</font> (versão destinada a testes)';
            app.config_FiscalizaHM.FontSize = 11;
            app.config_FiscalizaHM.Interpreter = 'html';
            app.config_FiscalizaHM.Position = [10 10 310 22];
            app.config_FiscalizaHM.Value = true;

            % Create config_DefaultIssueValuesLabel
            app.config_DefaultIssueValuesLabel = uilabel(app.config_Option3Grid);
            app.config_DefaultIssueValuesLabel.VerticalAlignment = 'bottom';
            app.config_DefaultIssueValuesLabel.FontSize = 10;
            app.config_DefaultIssueValuesLabel.Layout.Row = [4 5];
            app.config_DefaultIssueValuesLabel.Layout.Column = 1;
            app.config_DefaultIssueValuesLabel.Text = 'VALORES PADRÕES DE CAMPOS DA INSPEÇÃO';

            % Create config_DefaultIssueValuesLock
            app.config_DefaultIssueValuesLock = uiimage(app.config_Option3Grid);
            app.config_DefaultIssueValuesLock.ImageClickedFcn = createCallbackFcn(app, @config_DefaultIssueValuesLockClicked, true);
            app.config_DefaultIssueValuesLock.Layout.Row = [5 6];
            app.config_DefaultIssueValuesLock.Layout.Column = 2;
            app.config_DefaultIssueValuesLock.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Lock1_18Gray.png');

            % Create config_DefaultIssueValuesPanel
            app.config_DefaultIssueValuesPanel = uipanel(app.config_Option3Grid);
            app.config_DefaultIssueValuesPanel.Layout.Row = 7;
            app.config_DefaultIssueValuesPanel.Layout.Column = [1 2];

            % Create config_DefaultIssueValuesGrid
            app.config_DefaultIssueValuesGrid = uigridlayout(app.config_DefaultIssueValuesPanel);
            app.config_DefaultIssueValuesGrid.ColumnWidth = {150, '1x'};
            app.config_DefaultIssueValuesGrid.RowHeight = {17, 22, 17, 22, 17, '1x', 17, '1x'};
            app.config_DefaultIssueValuesGrid.RowSpacing = 5;
            app.config_DefaultIssueValuesGrid.Padding = [10 10 10 5];
            app.config_DefaultIssueValuesGrid.BackgroundColor = [1 1 1];

            % Create config_CadastroSTELLabel
            app.config_CadastroSTELLabel = uilabel(app.config_DefaultIssueValuesGrid);
            app.config_CadastroSTELLabel.VerticalAlignment = 'bottom';
            app.config_CadastroSTELLabel.FontSize = 10;
            app.config_CadastroSTELLabel.Layout.Row = 1;
            app.config_CadastroSTELLabel.Layout.Column = [1 2];
            app.config_CadastroSTELLabel.Text = 'Entidade com cadastro STEL?';

            % Create config_CadastroSTEL
            app.config_CadastroSTEL = uidropdown(app.config_DefaultIssueValuesGrid);
            app.config_CadastroSTEL.Items = {};
            app.config_CadastroSTEL.ValueChangedFcn = createCallbackFcn(app, @config_FiscalizaDefaultValueChanged, true);
            app.config_CadastroSTEL.Enable = 'off';
            app.config_CadastroSTEL.FontSize = 11;
            app.config_CadastroSTEL.BackgroundColor = [1 1 1];
            app.config_CadastroSTEL.Layout.Row = 2;
            app.config_CadastroSTEL.Layout.Column = 1;
            app.config_CadastroSTEL.Value = {};

            % Create config_GerarPLAILabel
            app.config_GerarPLAILabel = uilabel(app.config_DefaultIssueValuesGrid);
            app.config_GerarPLAILabel.VerticalAlignment = 'bottom';
            app.config_GerarPLAILabel.FontSize = 10;
            app.config_GerarPLAILabel.Layout.Row = 3;
            app.config_GerarPLAILabel.Layout.Column = 1;
            app.config_GerarPLAILabel.Text = 'Gerar PLAI?';

            % Create config_GerarPLAI
            app.config_GerarPLAI = uidropdown(app.config_DefaultIssueValuesGrid);
            app.config_GerarPLAI.Items = {};
            app.config_GerarPLAI.ValueChangedFcn = createCallbackFcn(app, @config_FiscalizaDefaultValueChanged, true);
            app.config_GerarPLAI.Enable = 'off';
            app.config_GerarPLAI.FontSize = 11;
            app.config_GerarPLAI.BackgroundColor = [1 1 1];
            app.config_GerarPLAI.Layout.Row = 4;
            app.config_GerarPLAI.Layout.Column = 1;
            app.config_GerarPLAI.Value = {};

            % Create config_TipoPLAILabel
            app.config_TipoPLAILabel = uilabel(app.config_DefaultIssueValuesGrid);
            app.config_TipoPLAILabel.VerticalAlignment = 'bottom';
            app.config_TipoPLAILabel.FontSize = 10;
            app.config_TipoPLAILabel.Layout.Row = 3;
            app.config_TipoPLAILabel.Layout.Column = 2;
            app.config_TipoPLAILabel.Text = 'Tipo do PLAI:';

            % Create config_TipoPLAI
            app.config_TipoPLAI = uidropdown(app.config_DefaultIssueValuesGrid);
            app.config_TipoPLAI.Items = {};
            app.config_TipoPLAI.ValueChangedFcn = createCallbackFcn(app, @config_FiscalizaDefaultValueChanged, true);
            app.config_TipoPLAI.Enable = 'off';
            app.config_TipoPLAI.FontSize = 11;
            app.config_TipoPLAI.BackgroundColor = [1 1 1];
            app.config_TipoPLAI.Layout.Row = 4;
            app.config_TipoPLAI.Layout.Column = 2;
            app.config_TipoPLAI.Value = {};

            % Create config_MotivoLAILabel
            app.config_MotivoLAILabel = uilabel(app.config_DefaultIssueValuesGrid);
            app.config_MotivoLAILabel.VerticalAlignment = 'bottom';
            app.config_MotivoLAILabel.FontSize = 10;
            app.config_MotivoLAILabel.Layout.Row = 5;
            app.config_MotivoLAILabel.Layout.Column = 1;
            app.config_MotivoLAILabel.Text = 'Motivo de LAI:';

            % Create config_MotivoLAI
            app.config_MotivoLAI = uitree(app.config_DefaultIssueValuesGrid, 'checkbox');
            app.config_MotivoLAI.Enable = 'off';
            app.config_MotivoLAI.FontSize = 10;
            app.config_MotivoLAI.Layout.Row = 6;
            app.config_MotivoLAI.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.config_MotivoLAI.CheckedNodesChangedFcn = createCallbackFcn(app, @config_FiscalizaDefaultValueChanged, true);

            % Create config_ServicoInspecaoLabel
            app.config_ServicoInspecaoLabel = uilabel(app.config_DefaultIssueValuesGrid);
            app.config_ServicoInspecaoLabel.VerticalAlignment = 'bottom';
            app.config_ServicoInspecaoLabel.FontSize = 10;
            app.config_ServicoInspecaoLabel.Layout.Row = 7;
            app.config_ServicoInspecaoLabel.Layout.Column = 1;
            app.config_ServicoInspecaoLabel.Text = 'Serviços da Inspeção:';

            % Create config_ServicoInspecao
            app.config_ServicoInspecao = uitree(app.config_DefaultIssueValuesGrid, 'checkbox');
            app.config_ServicoInspecao.Enable = 'off';
            app.config_ServicoInspecao.FontSize = 10;
            app.config_ServicoInspecao.Layout.Row = 8;
            app.config_ServicoInspecao.Layout.Column = [1 2];

            % Assign Checked Nodes
            app.config_ServicoInspecao.CheckedNodesChangedFcn = createCallbackFcn(app, @config_FiscalizaDefaultValueChanged, true);

            % Create popupContainerGrid
            app.popupContainerGrid = uigridlayout(app.GridLayout);
            app.popupContainerGrid.ColumnWidth = {'1x', 880, '1x'};
            app.popupContainerGrid.RowHeight = {'1x', 300, '1x'};
            app.popupContainerGrid.Padding = [10 31 10 10];
            app.popupContainerGrid.Layout.Row = 3;
            app.popupContainerGrid.Layout.Column = 1;
            app.popupContainerGrid.BackgroundColor = [1 1 1];

            % Create SplashScreen
            app.SplashScreen = uiimage(app.popupContainerGrid);
            app.SplashScreen.Layout.Row = 2;
            app.SplashScreen.Layout.Column = 2;
            app.SplashScreen.ImageSource = fullfile(pathToMLAPP, 'Icons', 'SplashScreen.gif');

            % Create menu_Grid
            app.menu_Grid = uigridlayout(app.GridLayout);
            app.menu_Grid.ColumnWidth = {28, 28, 5, 28, '1x', 20, 20, 20, 20, 0, 0};
            app.menu_Grid.RowHeight = {7, '1x', 7};
            app.menu_Grid.ColumnSpacing = 5;
            app.menu_Grid.RowSpacing = 0;
            app.menu_Grid.Padding = [5 5 5 5];
            app.menu_Grid.Tag = 'COLORLOCKED';
            app.menu_Grid.Layout.Row = 1;
            app.menu_Grid.Layout.Column = 1;
            app.menu_Grid.BackgroundColor = [0.2 0.2 0.2];

            % Create menu_Button1
            app.menu_Button1 = uibutton(app.menu_Grid, 'state');
            app.menu_Button1.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button1.Tag = '1';
            app.menu_Button1.Enable = 'off';
            app.menu_Button1.Tooltip = {''};
            app.menu_Button1.Icon = fullfile(pathToMLAPP, 'Icons', 'Zoom_32Yellow.png');
            app.menu_Button1.IconAlignment = 'top';
            app.menu_Button1.Text = '';
            app.menu_Button1.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button1.FontSize = 11;
            app.menu_Button1.Layout.Row = [1 3];
            app.menu_Button1.Layout.Column = 1;
            app.menu_Button1.Value = true;

            % Create menu_Button2
            app.menu_Button2 = uibutton(app.menu_Grid, 'state');
            app.menu_Button2.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button2.Tag = '2';
            app.menu_Button2.Enable = 'off';
            app.menu_Button2.Tooltip = {''};
            app.menu_Button2.Icon = fullfile(pathToMLAPP, 'Icons', 'Detection_32White.png');
            app.menu_Button2.IconAlignment = 'top';
            app.menu_Button2.Text = '';
            app.menu_Button2.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button2.FontSize = 11;
            app.menu_Button2.Layout.Row = [1 3];
            app.menu_Button2.Layout.Column = 2;

            % Create menu_Button3
            app.menu_Button3 = uibutton(app.menu_Grid, 'state');
            app.menu_Button3.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button3.Tag = '3';
            app.menu_Button3.Enable = 'off';
            app.menu_Button3.Tooltip = {''};
            app.menu_Button3.Icon = fullfile(pathToMLAPP, 'Icons', 'Settings_36White.png');
            app.menu_Button3.IconAlignment = 'top';
            app.menu_Button3.Text = '';
            app.menu_Button3.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button3.FontSize = 11;
            app.menu_Button3.Layout.Row = [1 3];
            app.menu_Button3.Layout.Column = 4;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.menu_Grid);
            app.jsBackDoor.Tag = 'jsBackDoor';
            app.jsBackDoor.Layout.Row = 2;
            app.jsBackDoor.Layout.Column = 6;

            % Create DataHubLamp
            app.DataHubLamp = uilamp(app.menu_Grid);
            app.DataHubLamp.Enable = 'off';
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Tooltip = {'Pendente mapear pastas do Sharepoint'};
            app.DataHubLamp.Layout.Row = 2;
            app.DataHubLamp.Layout.Column = 7;
            app.DataHubLamp.Color = [1 0 0];

            % Create FigurePosition
            app.FigurePosition = uiimage(app.menu_Grid);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.FigurePosition.Enable = 'off';
            app.FigurePosition.Layout.Row = 2;
            app.FigurePosition.Layout.Column = 8;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Layout1.png');

            % Create AppInfo
            app.AppInfo = uiimage(app.menu_Grid);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_auxiliarButtonPushed, true);
            app.AppInfo.Enable = 'off';
            app.AppInfo.Layout.Row = 2;
            app.AppInfo.Layout.Column = 9;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Dots_36x36W.png');

            % Create menu_Separator2
            app.menu_Separator2 = uiimage(app.menu_Grid);
            app.menu_Separator2.ScaleMethod = 'fill';
            app.menu_Separator2.Enable = 'off';
            app.menu_Separator2.Layout.Row = [1 3];
            app.menu_Separator2.Layout.Column = 3;
            app.menu_Separator2.ImageSource = fullfile(pathToMLAPP, 'Icons', 'LineV_White.png');

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.menu_Grid);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 2;
            app.dockModule_Close.Layout.Column = 11;
            app.dockModule_Close.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Delete_12SVG_white.svg');

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.menu_Grid);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 2;
            app.dockModule_Undock.Layout.Column = 10;
            app.dockModule_Undock.ImageSource = fullfile(pathToMLAPP, 'Icons', 'Undock_18White.png');

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create ContextMenu_DeleteFcn
            app.ContextMenu_DeleteFcn = uimenu(app.ContextMenu);
            app.ContextMenu_DeleteFcn.MenuSelectedFcn = createCallbackFcn(app, @ContextMenu_DeleteFcnSelected, true);
            app.ContextMenu_DeleteFcn.Text = 'Excluir';
            
            % Assign app.ContextMenu
            app.search_ListOfProducts.ContextMenu = app.ContextMenu;
            app.search_SecundaryListOfFilters.ContextMenu = app.ContextMenu;
            app.report_Table.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winSCH_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
