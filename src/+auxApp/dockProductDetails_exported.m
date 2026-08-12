classdef dockProductDetails_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        AdsCount              matlab.ui.control.Label
        AdsDownloadRequest    matlab.ui.control.Image
        AdsNext               matlab.ui.control.Image
        AdsPrevious           matlab.ui.control.Image
        AdsPanel              matlab.ui.container.Panel
        AdsGrid               matlab.ui.container.GridLayout
        Ads                   matlab.ui.control.Label
        WordCloudCount        matlab.ui.control.Label
        WordCloudDownload     matlab.ui.control.Image
        WordCloudNext         matlab.ui.control.Image
        WordCloudPrevious     matlab.ui.control.Image
        WordCloud             matlab.ui.container.GridLayout
        WordCloudNote         matlab.ui.control.Label
        ImageCount            matlab.ui.control.Label
        ImageZoom             matlab.ui.control.Image
        ImageNext             matlab.ui.control.Image
        ImagePrevious         matlab.ui.control.Image
        Image                 matlab.ui.control.Image
        HomologationCount     matlab.ui.control.Label
        HomologationNext      matlab.ui.control.Image
        HomologationPrevious  matlab.ui.control.Image
        HomologationPanel     matlab.ui.container.Panel
        HomologationGrid      matlab.ui.container.GridLayout
        Homologation          matlab.ui.control.Label
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
        jsBackDoor
        progressDialog
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        inputArgs
        wordCloudObj
        resultContext
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function applyJSCustomizations(app)
            drawnow

            appName = class(app);
            elToModify = {
                app.Homologation;
                app.Image;
                app.Ads;
                app.WordCloud
            };
            ui.CustomizationBase.getElementsDataTag(elToModify);

            try
                ui.TextView.startup(app.jsBackDoor, app.Homologation, appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
                ui.TextView.startup(app.jsBackDoor, app.Ads,          appName, struct('class', {{'textview--borderless', 'textview--wordbreak'}}));
            catch
            end
        end

        %-----------------------------------------------------------------%
        function resultCtx = initializeResultContext(app, resultCtx)
            fieldNames = fieldnames(resultCtx);
            for ii = 1:numel(fieldNames)
                field = fieldNames{ii};

                if ~isempty(resultCtx.(field).data) && isfield(resultCtx.(field), 'index')
                    resultCtx.(field).index = 1;
                end
            end
        end

        %-----------------------------------------------------------------%
        function updatePanel(app, resultCtx)
            app.resultContext = initializeResultContext(app, resultCtx);

            updateSCH(app)
            updateImages(app)
            updateWordCloud(app)
            updateAds(app)
        end

        %-----------------------------------------------------------------%
        function updateSCH(app)
            relatedSCH = app.resultContext.SCH.data;
            numWordClouds = height(app.resultContext.WordCloud.data);
            numImages = numel(app.resultContext.Images.data);
            ads = app.resultContext.Ads.data;

            if isempty(relatedSCH)
                app.Homologation.Text = '';
                return
            end

            htmlSource = util.HtmlTextGenerator.ProductInfo('ProdutoHomologado', relatedSCH, numWordClouds, numImages, ads);
            ui.TextView.update(app.Homologation, htmlSource);

            homItems = app.inputArgs.homValues.items;
            homIndex = app.inputArgs.homValues.selectedIndex;
            app.HomologationCount.Text = sprintf('%d DE %d', homIndex, numel(homItems));
        end

        %-----------------------------------------------------------------%
        function updateImages(app)
            imageItems = app.resultContext.Images.data;
            imageIndex = app.resultContext.Images.index;
            if imageIndex >= numel(app.resultContext.Images.data)
                imageIndex = numel(app.resultContext.Images.data);
            end

            set([app.ImageZoom, app.ImagePrevious, app.ImageNext], 'Enable', ~isempty(imageItems))

            if isempty(imageItems)
                if ~strcmp(app.Image.ImageSource, 'image-missing.svg')
                    app.Image.ImageSource = 'image-missing.svg';
                end
                app.ImageCount.Text = '0 DE 0';
                return
            end

            if isempty(imageIndex)
                imageIndex = 1;
            end

            try
                app.Image.ImageSource = imageItems{imageIndex};
            catch
                if numel(app.resultContext.Images.data) >= imageIndex
                    app.resultContext.Images.data(imageIndex) = [];
                    updateImages(app, app.resultContext)
                end
                return
            end

            app.ImageCount.Text = sprintf('%d DE %d', imageIndex, numel(imageItems));
            app.resultContext.Images.index = imageIndex;
        end

        %-----------------------------------------------------------------%
        function updateWordCloud(app)
            if isempty(app.wordCloudObj) || ~isvalid(app.wordCloudObj)
                app.wordCloudObj = ui.WordCloud(app.jsBackDoor, app.WordCloud);
            end

            wordClouds = app.resultContext.WordCloud.data;
            wordCloudIndex = app.resultContext.WordCloud.index;

            set([app.WordCloudPrevious, app.WordCloudNext], 'Enable', ~isempty(wordClouds))

            if isempty(wordClouds)
                app.wordCloudObj.Table = [];
                app.WordCloudNote.Text = '';
                app.WordCloudCount.Text = '0 DE 0';
                return
            end

            if isempty(wordCloudIndex)
                wordCloudIndex = 1;
            end

            [wordCloudTable, wordCloudInfo] = util.getWordCloudFromCache(wordClouds.("Valor"){wordCloudIndex});

            app.wordCloudObj.Table = wordCloudTable;
            app.WordCloudNote.Text = sprintf('%s • %s\nTERMO PESQUISADO: "%s"', wordClouds.("DataHora"){wordCloudIndex}, wordCloudInfo.metaData.Source, wordCloudInfo.searchedWord);
            app.WordCloudCount.Text = sprintf('%d DE %d', wordCloudIndex, height(wordClouds));

            app.resultContext.WordCloud.index = wordCloudIndex;
        end

        %-----------------------------------------------------------------%
        function updateAds(app)
            relatedSCH = app.resultContext.SCH.data;
            if isempty(relatedSCH)
                app.Ads.Text = '';
                app.AdsCount.Text = '0 DE 0';
                return
            end

            ads = app.resultContext.Ads.data;
            adsIndex = app.resultContext.Ads.index;

            set([app.AdsPrevious, app.AdsNext], 'Enable', ~isempty(ads))

            if isempty(ads)
                homologation = app.resultContext.SCH.data.("Homologação"){1};
                lastUpdate = ipcMainMatlabCallsHandler(app.mainApp, app, 'getAdLastUpdate');

                app.Ads.Text = sprintf([ ...
                    '<p style="padding: 10px;">' ...
                    'Nenhum anúncio foi identificado pelo Regulatron para o ' ...
                    'produto %s até %s, data da última consolidação dos dados ' ...
                    'pela presente ferramenta.</p>' ...
                ], homologation, lastUpdate);
                app.AdsCount.Text = '0 DE 0';
                return
            end

            if isempty(adsIndex)
                adsIndex = 1;
            end

            app.Ads.Text = util.HtmlTextGenerator.generateAdCard(ads(adsIndex, :), app.mainApp.projectData.regulatronData.urlPreffix);
            app.AdsCount.Text = sprintf('%d DE %d', adsIndex, height(ads));
            app.resultContext.Ads.index = adsIndex;
        end

        %-----------------------------------------------------------------%
        function status = addAnnotationToCache(app, homologation, attributeName, attributeValue)
            status = true;
            annotation = table( ...
                {char(matlab.lang.internal.uuid())}, ...
                {datestr(now, 'dd/mm/yyyy HH:MM:SS')}, ...
                {appEngine.util.OperationSystem('computerName')}, ...
                {appEngine.util.OperationSystem('userName')}, ...
                {homologation}, ...
                {attributeName}, ...
                {attributeValue}, ...
                1, ...
                'VariableNames', util.readExternalFile.annotationColumns ...
            );

            homIdxs = find(strcmp(app.mainApp.annotationTable.("Homologação"), homologation));
            if ~isempty(homIdxs) && any(strcmp(app.mainApp.annotationTable.("Atributo")(homIdxs), attributeName) & strcmpi(app.mainApp.annotationTable.("Valor")(homIdxs), attributeValue))
                status = false;
                return
            end

            app.mainApp.annotationTable(end+1,:) = annotation;

            % A cada nova inserção, gera-se uma planilha que é submetida à
            % pasta POST, ou é salva localmente em cache.
            [app.mainApp.annotationTable, msgWarning] = util.writeExternalFile.Annotation(app.mainApp.rootFolder, app.mainApp.General.fileFolder.DataHub_POST, app.mainApp.annotationTable);
            if ~isempty(msgWarning)
                ui.Dialog(app.UIFigure, 'warning', msgWarning);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, homValues, resultCtx)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.inputArgs = struct('context', context, 'homValues', homValues);
                applyJSCustomizations(app)
                updatePanel(app, resultCtx)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end            
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            delete(app)
            
        end

        % Image clicked function: HomologationNext, HomologationPrevious
        function onHomologationsArrowButtonClicked(app, event)
            
            homItems = app.inputArgs.homValues.items;
            homCurrentIndex = app.inputArgs.homValues.selectedIndex;

            numHoms = height(homItems);

            switch event.Source
                case app.HomologationPrevious
                    homNewIndex = homCurrentIndex - 1;
                case app.HomologationNext
                    homNewIndex = homCurrentIndex + 1;
            end

            if homNewIndex < 1
                homNewIndex = numHoms;
            elseif homNewIndex > numHoms
                homNewIndex = 1;
            end

            app.inputArgs.homValues.selectedIndex = homNewIndex;
            resultCtx = ipcMainMatlabCallsHandler(app.mainApp, app, 'onSelectedRowChangeRequest', homNewIndex);
            updatePanel(app, resultCtx)

        end

        % Image clicked function: ImageNext, ImagePrevious
        function onImagesArrowButtonClicked(app, event)
            
            images = app.resultContext.Images.data;
            imageCurrentIndex = app.resultContext.Images.index;

            numImages = numel(images);

            switch event.Source
                case app.ImagePrevious
                    imageNewIndex = imageCurrentIndex - 1;
                otherwise % app.ImageNext
                    imageNewIndex = imageCurrentIndex + 1;
            end

            if imageNewIndex < 1
                imageNewIndex = numImages;
            elseif imageNewIndex > numImages
                imageNewIndex = 1;
            end

            app.resultContext.Images.index = imageNewIndex;
            updateImages(app)

        end

        % Image clicked function: ImageZoom
        function onImagesZoomButtonClicked(app, event)
            
            sendEventToHTMLSource(app.jsBackDoor, 'imageHighlight', struct('dataTag', app.Image.UserData.id))

        end

        % Image clicked function: WordCloudNext, WordCloudPrevious
        function onWordCloudsArrowButtonClicked(app, event)
            
            wordclouds = app.resultContext.WordCloud.data;
            wordcloudCurrentIndex = app.resultContext.WordCloud.index;

            numWordClouds = height(wordclouds);

            switch event.Source
                case app.WordCloudPrevious
                    wordcloudNewIndex = wordcloudCurrentIndex - 1;
                case app.WordCloudNext
                    wordcloudNewIndex = wordcloudCurrentIndex + 1;
            end

            if wordcloudNewIndex < 1
                wordcloudNewIndex = numWordClouds;
            elseif wordcloudNewIndex > numWordClouds
                wordcloudNewIndex = 1;
            end

            app.resultContext.WordCloud.index = wordcloudNewIndex;
            updateWordCloud(app)

        end

        % Image clicked function: WordCloudDownload
        function onWordCloudDownloadRequest(app, event)
            
            relatedSCH = app.resultContext.SCH.data;
            if isempty(relatedSCH)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                homologation = relatedSCH.("Homologação"){1};

                switch app.mainApp.General.context.SEARCH.wordCloud.column
                    case 'Modelo'
                        modelList = [
                            relatedSCH.("Modelo");
                            relatedSCH.("Nome Comercial") 
                        ];
    
                    case 'Nome Comercial'
                        modelList = [
                            relatedSCH.("Nome Comercial");
                            relatedSCH.("Modelo")
                        ];
                end
                modelList(cellfun(@isempty, modelList)) = [];
                modelList = unique(modelList, 'stable');
    
                if isempty(modelList)
                    error('Registro %s não possui cadastrado "Modelo" ou "Nome Comercial", inviabilizando consulta à internet.', homologation)
                end

                word2Search = modelList{1};
                numMaxWords = 25;

                [wordCloudTable, wordCloudInfo] = util.getWordCloudFromWeb(word2Search, numMaxWords);
                if ~isempty(wordCloudTable)
                    if addAnnotationToCache(app, homologation, 'WordCloud', wordCloudInfo)
                        homCurrentIndex = app.inputArgs.homValues.selectedIndex;
                        resultCtx = ipcMainMatlabCallsHandler(app.mainApp, app, 'onSelectedRowChangeRequest', homCurrentIndex);
                        updatePanel(app, resultCtx)
                    end
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.identifier);
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: AdsNext, AdsPrevious
        function onAdsArrowButtonClicked(app, event)
            
            ads = app.resultContext.Ads.data;
            adsCurrentIndex = app.resultContext.Ads.index;

            numAds = height(ads);

            switch event.Source
                case app.AdsPrevious
                    adsNewIndex = adsCurrentIndex - 1;
                case app.AdsNext
                    adsNewIndex = adsCurrentIndex + 1;
            end

            if adsNewIndex < 1
                adsNewIndex = numAds;
            elseif adsNewIndex > numAds
                adsNewIndex = 1;
            end

            app.resultContext.Ads.index = adsNewIndex;
            updateAds(app)

        end

        % Image clicked function: AdsDownloadRequest
        function onAdsDownloadRequest(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onGetImageUrl')

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
                app.UIFigure.Position = [100 100 1038 660];
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
            app.GridLayout.ColumnWidth = {18, 5, 18, 277, 20, 18, 5, 18, 5, 18, 256, 20, 18, 5, 18, 5, 18, 256};
            app.GridLayout.RowHeight = {279, 20, 20, 279, 22};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create HomologationPanel
            app.HomologationPanel = uipanel(app.GridLayout);
            app.HomologationPanel.AutoResizeChildren = 'off';
            app.HomologationPanel.Layout.Row = [1 4];
            app.HomologationPanel.Layout.Column = [1 4];

            % Create HomologationGrid
            app.HomologationGrid = uigridlayout(app.HomologationPanel);
            app.HomologationGrid.ColumnWidth = {'1x'};
            app.HomologationGrid.RowHeight = {'1x'};
            app.HomologationGrid.Padding = [0 0 0 0];
            app.HomologationGrid.BackgroundColor = [1 1 1];

            % Create Homologation
            app.Homologation = uilabel(app.HomologationGrid);
            app.Homologation.BackgroundColor = [1 1 1];
            app.Homologation.VerticalAlignment = 'top';
            app.Homologation.WordWrap = 'on';
            app.Homologation.FontSize = 11;
            app.Homologation.Layout.Row = 1;
            app.Homologation.Layout.Column = 1;
            app.Homologation.Interpreter = 'html';
            app.Homologation.Text = '';

            % Create HomologationPrevious
            app.HomologationPrevious = uiimage(app.GridLayout);
            app.HomologationPrevious.ScaleMethod = 'none';
            app.HomologationPrevious.ImageClickedFcn = createCallbackFcn(app, @onHomologationsArrowButtonClicked, true);
            app.HomologationPrevious.Layout.Row = 5;
            app.HomologationPrevious.Layout.Column = 1;
            app.HomologationPrevious.ImageSource = 'chevron-left.svg';

            % Create HomologationNext
            app.HomologationNext = uiimage(app.GridLayout);
            app.HomologationNext.ScaleMethod = 'none';
            app.HomologationNext.ImageClickedFcn = createCallbackFcn(app, @onHomologationsArrowButtonClicked, true);
            app.HomologationNext.Layout.Row = 5;
            app.HomologationNext.Layout.Column = 3;
            app.HomologationNext.ImageSource = 'chevron-right.svg';

            % Create HomologationCount
            app.HomologationCount = uilabel(app.GridLayout);
            app.HomologationCount.HorizontalAlignment = 'right';
            app.HomologationCount.FontSize = 10;
            app.HomologationCount.Layout.Row = 5;
            app.HomologationCount.Layout.Column = 4;
            app.HomologationCount.Text = '';

            % Create Image
            app.Image = uiimage(app.GridLayout);
            app.Image.BackgroundColor = [0.9804 0.9804 0.9804];
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = [6 11];
            app.Image.ImageSource = 'image-missing.svg';

            % Create ImagePrevious
            app.ImagePrevious = uiimage(app.GridLayout);
            app.ImagePrevious.ScaleMethod = 'none';
            app.ImagePrevious.ImageClickedFcn = createCallbackFcn(app, @onImagesArrowButtonClicked, true);
            app.ImagePrevious.Enable = 'off';
            app.ImagePrevious.Layout.Row = 2;
            app.ImagePrevious.Layout.Column = 6;
            app.ImagePrevious.ImageSource = 'chevron-left.svg';

            % Create ImageNext
            app.ImageNext = uiimage(app.GridLayout);
            app.ImageNext.ScaleMethod = 'none';
            app.ImageNext.ImageClickedFcn = createCallbackFcn(app, @onImagesArrowButtonClicked, true);
            app.ImageNext.Enable = 'off';
            app.ImageNext.Layout.Row = 2;
            app.ImageNext.Layout.Column = 8;
            app.ImageNext.ImageSource = 'chevron-right.svg';

            % Create ImageZoom
            app.ImageZoom = uiimage(app.GridLayout);
            app.ImageZoom.ScaleMethod = 'none';
            app.ImageZoom.ImageClickedFcn = createCallbackFcn(app, @onImagesZoomButtonClicked, true);
            app.ImageZoom.Enable = 'off';
            app.ImageZoom.Layout.Row = 2;
            app.ImageZoom.Layout.Column = 10;
            app.ImageZoom.ImageSource = 'screen-full.svg';

            % Create ImageCount
            app.ImageCount = uilabel(app.GridLayout);
            app.ImageCount.HorizontalAlignment = 'right';
            app.ImageCount.FontSize = 10;
            app.ImageCount.Layout.Row = 2;
            app.ImageCount.Layout.Column = 11;
            app.ImageCount.Text = '0 DE 0';

            % Create WordCloud
            app.WordCloud = uigridlayout(app.GridLayout);
            app.WordCloud.ColumnWidth = {'1x'};
            app.WordCloud.RowHeight = {'1x'};
            app.WordCloud.Padding = [5 5 5 5];
            app.WordCloud.Layout.Row = 4;
            app.WordCloud.Layout.Column = [6 11];
            app.WordCloud.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create WordCloudNote
            app.WordCloudNote = uilabel(app.WordCloud);
            app.WordCloudNote.VerticalAlignment = 'bottom';
            app.WordCloudNote.FontSize = 10;
            app.WordCloudNote.FontColor = [0.502 0.502 0.502];
            app.WordCloudNote.Layout.Row = 1;
            app.WordCloudNote.Layout.Column = 1;
            app.WordCloudNote.Text = '';

            % Create WordCloudPrevious
            app.WordCloudPrevious = uiimage(app.GridLayout);
            app.WordCloudPrevious.ScaleMethod = 'none';
            app.WordCloudPrevious.ImageClickedFcn = createCallbackFcn(app, @onWordCloudsArrowButtonClicked, true);
            app.WordCloudPrevious.Enable = 'off';
            app.WordCloudPrevious.Layout.Row = 5;
            app.WordCloudPrevious.Layout.Column = 6;
            app.WordCloudPrevious.ImageSource = 'chevron-left.svg';

            % Create WordCloudNext
            app.WordCloudNext = uiimage(app.GridLayout);
            app.WordCloudNext.ScaleMethod = 'none';
            app.WordCloudNext.ImageClickedFcn = createCallbackFcn(app, @onWordCloudsArrowButtonClicked, true);
            app.WordCloudNext.Enable = 'off';
            app.WordCloudNext.Layout.Row = 5;
            app.WordCloudNext.Layout.Column = 8;
            app.WordCloudNext.ImageSource = 'chevron-right.svg';

            % Create WordCloudDownload
            app.WordCloudDownload = uiimage(app.GridLayout);
            app.WordCloudDownload.ScaleMethod = 'none';
            app.WordCloudDownload.ImageClickedFcn = createCallbackFcn(app, @onWordCloudDownloadRequest, true);
            app.WordCloudDownload.Layout.Row = 5;
            app.WordCloudDownload.Layout.Column = 10;
            app.WordCloudDownload.ImageSource = 'cloud-download.svg';

            % Create WordCloudCount
            app.WordCloudCount = uilabel(app.GridLayout);
            app.WordCloudCount.HorizontalAlignment = 'right';
            app.WordCloudCount.FontSize = 10;
            app.WordCloudCount.Layout.Row = 5;
            app.WordCloudCount.Layout.Column = 11;
            app.WordCloudCount.Text = '0 DE 0';

            % Create AdsPanel
            app.AdsPanel = uipanel(app.GridLayout);
            app.AdsPanel.AutoResizeChildren = 'off';
            app.AdsPanel.Layout.Row = [1 4];
            app.AdsPanel.Layout.Column = [13 18];

            % Create AdsGrid
            app.AdsGrid = uigridlayout(app.AdsPanel);
            app.AdsGrid.ColumnWidth = {'1x'};
            app.AdsGrid.RowHeight = {'1x'};
            app.AdsGrid.Padding = [0 0 0 0];
            app.AdsGrid.BackgroundColor = [1 1 1];

            % Create Ads
            app.Ads = uilabel(app.AdsGrid);
            app.Ads.BackgroundColor = [1 1 1];
            app.Ads.VerticalAlignment = 'top';
            app.Ads.WordWrap = 'on';
            app.Ads.FontSize = 11;
            app.Ads.Layout.Row = 1;
            app.Ads.Layout.Column = 1;
            app.Ads.Interpreter = 'html';
            app.Ads.Text = '';

            % Create AdsPrevious
            app.AdsPrevious = uiimage(app.GridLayout);
            app.AdsPrevious.ScaleMethod = 'none';
            app.AdsPrevious.ImageClickedFcn = createCallbackFcn(app, @onAdsArrowButtonClicked, true);
            app.AdsPrevious.Enable = 'off';
            app.AdsPrevious.Layout.Row = 5;
            app.AdsPrevious.Layout.Column = 13;
            app.AdsPrevious.ImageSource = 'chevron-left.svg';

            % Create AdsNext
            app.AdsNext = uiimage(app.GridLayout);
            app.AdsNext.ScaleMethod = 'none';
            app.AdsNext.ImageClickedFcn = createCallbackFcn(app, @onAdsArrowButtonClicked, true);
            app.AdsNext.Enable = 'off';
            app.AdsNext.Layout.Row = 5;
            app.AdsNext.Layout.Column = 15;
            app.AdsNext.ImageSource = 'chevron-right.svg';

            % Create AdsDownloadRequest
            app.AdsDownloadRequest = uiimage(app.GridLayout);
            app.AdsDownloadRequest.ScaleMethod = 'none';
            app.AdsDownloadRequest.ImageClickedFcn = createCallbackFcn(app, @onAdsDownloadRequest, true);
            app.AdsDownloadRequest.Layout.Row = 5;
            app.AdsDownloadRequest.Layout.Column = 17;
            app.AdsDownloadRequest.ImageSource = 'cloud-download.svg';

            % Create AdsCount
            app.AdsCount = uilabel(app.GridLayout);
            app.AdsCount.HorizontalAlignment = 'right';
            app.AdsCount.FontSize = 10;
            app.AdsCount.Layout.Row = 5;
            app.AdsCount.Layout.Column = 18;
            app.AdsCount.Text = '0 DE 0';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockProductDetails_exported(Container, varargin)

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
