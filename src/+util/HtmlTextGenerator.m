classdef (Abstract) HtmlTextGenerator

    % Essa classe abstrata organiza a criação de "textos decorados",
    % valendo-se das funcionalidades do HTML+CSS. Um texto aqui produzido
    % será renderizado em um componente uihtml, uilabel ou outro que tenha 
    % html como interpretador.

    % Antes de cada função, consta a indicação do módulo que chama a
    % função.

    properties (Constant)
        %-----------------------------------------------------------------%
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        % SCH:INFO
        %-----------------------------------------------------------------%
        function htmlContent = AppInfo(generalSettings, rootFolder, executionMode, renderCount, schDataTable, releasedData, cacheData, annotationTable, outputFormat)
            arguments
                generalSettings 
                rootFolder 
                executionMode 
                renderCount
                schDataTable
                releasedData
                cacheData
                annotationTable
                outputFormat char {mustBeMember(outputFormat, {'popup', 'textview'})} = 'textview'
            end
        
            appName      = class.Constants.appName;
            appVersion   = generalSettings.AppVersion;
            appURL       = util.publicLink(appName, rootFolder, 'SCH');
            cacheColumns = textFormatGUI.cellstr2ListWithQuotes({cacheData.Column});
        
            switch executionMode
                case {'MATLABEnvironment', 'desktopStandaloneApp'}
                    appMode = 'desktopApp';        
                case 'webApp'
                    computerName = appEngine.util.OperationSystem('computerName');
                    if strcmpi(computerName, generalSettings.computerName.webServer)
                        appMode = 'webServer';
                    else
                        appMode = 'deployServer';                    
                    end
            end

            dataStruct    = struct('group', 'COMPUTADOR',     'value', struct('Machine', rmfield(appVersion.machine, 'name'), 'Mode', sprintf('%s - %s', executionMode, appMode)));
            dataStruct(2) = struct('group', 'MATLAB',         'value', rmfield(appVersion.matlab, 'name'));
            if ~isempty(appVersion.browser)
                dataStruct(3) = struct('group', 'NAVEGADOR',  'value', rmfield(appVersion.browser, 'name'));
            end
            dataStruct(end+1) = struct('group', 'RENDERIZAÇÕES','value', renderCount);
            dataStruct(end+1) = struct('group', 'APLICATIVO', 'value', appVersion.application);

            dataStruct(end+1) = struct('group', [upper(appName) 'Data'], 'value', struct('releasedDate', releasedData, 'numberOfRows', height(schDataTable), 'numberOfUniqueHom', numel(unique(schDataTable.("Homologação"))), 'cacheColumns', cacheColumns));
            dataStruct(end+1) = struct('group', [upper(appName) 'Data_Annotation'], 'value', struct('numberOfRows', height(annotationTable), 'numberOfUniqueHom', numel(unique(annotationTable.("Homologação")))));

            freeInitialText = sprintf('<font style="font-size: 12px;">O repositório das ferramentas desenvolvidas no Laboratório de inovação da SFI pode ser acessado <a href="%s" target="_blank">aqui</a>.</font>\n\n', appURL.Sharepoint);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'print -1', freeInitialText, outputFormat);
        end

        %-----------------------------------------------------------------%
        % SCH:SEARCH
        %-----------------------------------------------------------------%
        function htmlContent = ProductInfo(varargin)
            dataType = varargin{1};

            switch dataType
                case 'ProdutoHomologado'
                    relatedSCHTable = varargin{2};
                    wordCloudsCount = varargin{3};
                    imagesCount = varargin{4};
                    ads = varargin{5};
        
                    Homologacao   = char(relatedSCHTable.("Homologação")(1));
                    Status        = char(relatedSCHTable.("Situação")(1));
                    StatusColor   = '';
                    if ismember(Status, {'Homologação Anulada', 'Homologação Cancelada', 'Homologação Suspensa', 'Requerimento - Cancelado'})
                        StatusColor = 'color:red; ';
                    end
                    
                    DataEmissao   = char(relatedSCHTable.("Data da Homologação")(1));
                
                    certID        = char(relatedSCHTable.("Certificado de Conformidade Técnica")(1));
                    certEmissao   = char(relatedSCHTable.("Data do Certificado de Conformidade Técnica")(1));
                    certValidade  = char(relatedSCHTable.("Data de Validade do Certificado")(1));
                    if ~strcmp(certValidade, 'NaT')
                        certValidade = sprintf(', válido até %s', certValidade);
                    else
                        certValidade = '';
                    end
                
                    Solicitante   = upper(char(relatedSCHTable.("Solicitante")(1)));
                    CNPJ          = char(relatedSCHTable.("CNPJ/CPF")(1));
                    Fabricante    = upper(char(relatedSCHTable.("Fabricante")(1)));
                    Pais          = char(relatedSCHTable.("País do Fabricante")(1));
                    Tipo          = getListOfValues(relatedSCHTable, "Tipo");
                    Categoria     = char(relatedSCHTable.("Categoria do Produto")(1));
                    Modelo        = getListOfValues(relatedSCHTable, "Modelo");
                    NomeComercial = getListOfValues(relatedSCHTable, "Nome Comercial");
                
                    % Valor inicial...
                    InformacoesDaInternet = {
                        'Não consta imagem';
                        'Não consta nuvem de palavras';
                        'Não consta anúncio'
                    };

                    if imagesCount == 1
                        InformacoesDaInternet{1} = 'Uma imagem baixada de anúncio';
                    elseif imagesCount > 1
                        InformacoesDaInternet{1} = sprintf('%d imagens baixadas de anúncio(s)', imagesCount);
                    end

                    if wordCloudsCount == 1
                        InformacoesDaInternet{2} = 'Uma nuvem de palavras obtida da API Google|Bing';
                    elseif wordCloudsCount > 1
                        InformacoesDaInternet{2} = sprintf('%d nuvens de palavras obtidas da API Google|Bing', wordCloudsCount);
                    end

                    numAdds = height(ads);
                    if numAdds
                        marketplaces = unique(string(ads.marketplace), 'stable');

                        if numAdds == 1
                            summaryText = 'Um anúncio extraído ';
                        else
                            summaryText = sprintf('%d anúncios extraídos ', numAdds);
                        end

                        if isscalar(marketplaces)
                            summaryText = [summaryText, 'de um marketplace. '];
                        else
                            summaryText = [summaryText, sprintf('de %d marketplaces. ', numel(marketplaces))];
                        end

                        InformacoesDaInternet{3} = summaryText;
                    end

                    displayEntry = [ ...
                        util.HtmlTextGenerator.makeDisplayEntry('DATA DE EMISSÃO', DataEmissao), ...
                        util.HtmlTextGenerator.makeDisplayEntry('CERTIFICADO DE CONFORMIDADE TÉCNICA', sprintf('"%s", de %s%s', certID, certEmissao, certValidade)), ...
                        util.HtmlTextGenerator.makeDisplayEntry('SOLICITANTE', {{Solicitante, sprintf('CNPJ/CPF: %s', CNPJ)}}), ...
                        util.HtmlTextGenerator.makeDisplayEntry('FABRICANTE', {{Fabricante, Pais}}), ...
                        util.HtmlTextGenerator.makeDisplayEntry('CATEGORIA', Categoria), ...
                        util.HtmlTextGenerator.makeDisplayEntry('TIPO', {Tipo}), ...
                        util.HtmlTextGenerator.makeDisplayEntry('MODELO', {Modelo}), ...
                        util.HtmlTextGenerator.makeDisplayEntry('NOME COMERCIAL', {NomeComercial}), ...
                        util.HtmlTextGenerator.makeDisplayEntry('INFORMAÇÕES ADICIONAIS', textFormatGUI.cellstr2Bullets(InformacoesDaInternet)) ...
                    ];
        
                case 'ProdutoNãoHomologado'
                    listOfProducts = varargin{2};

                    StatusColor    = 'color:red; ';
                    Status         = 'PRODUTO NÃO HOMOLOGADO';
        
                    Homologacao    = char(listOfProducts.("Homologação")(1));
                    Fabricante     = upper(char(listOfProducts.("Fabricante")(1)));
                    if isempty(Fabricante)
                        Fabricante = '(desconhecido)';
                    end
                    Tipo           = getListOfValues(listOfProducts, "Tipo");
                    Modelo         = getListOfValues(listOfProducts, "Modelo");

                    displayEntry(1) = struct('group', 'Fabricante:', 'value', Fabricante);
                    displayEntry(2) = struct('group', 'Tipo:',       'value', Tipo);
                    displayEntry(3) = struct('group', 'Modelo:',     'value', Modelo);
            end

            freeInitialText = sprintf('<font style="color: white; background-color: #8caec9; display: inline-block; vertical-align: middle; padding: 5px; border-radius: 5px; font-size: 16px;"><b>%s</b></font><font style="%sfont-size: 9px;"> %s</font><br><br>', Homologacao, StatusColor, upper(Status));
            %freeInitialText = sprintf('<font style="font-size: 16px;"><b>%s</b></font><font style="%sfont-size: 9px;"> %s</font><br><br>', Homologacao, StatusColor, upper(Status));
            htmlContent     = textFormatGUI.struct2PrettyPrintList(displayEntry, 'delete', freeInitialText, 'textview', 'normal+gray', 'margin-top: 7px; ');
            
            function htmlList = getListOfValues(referenceTable, columnName)        
                values = setdiff(unique(referenceTable.(columnName)), {''});
                if isempty(values)
                    values = {'(desconhecido)'};
                end
                htmlList = strcat('•&thinsp;', cellstr(values));
            end        
        end

        %-----------------------------------------------------------------%
        % AUXAPP.DOCKANNOTATION
        %-----------------------------------------------------------------%
        function htmlContent = ProductInfoUnderAnnotation(relatedSCHTable, relatedAnnotationTable)
            homologation = char(relatedSCHTable.("Homologação")(1));
            status = char(relatedSCHTable.("Situação")(1));
            color  = '';
            if ismember(status, {'Homologação Anulada', 'Homologação Cancelada', 'Homologação Suspensa', 'Requerimento - Cancelado'})
                color = 'color:red; ';
            end

            numWordCloud = sum(strcmp(relatedAnnotationTable.("Atributo"), 'WordCloud'));
            numOthers    = height(relatedAnnotationTable) - numWordCloud;

            manufacturer = upper(char(relatedSCHTable.("Fabricante")(1)));
            model        = MergedModel(relatedSCHTable);

            htmlContent = sprintf([ ...
                '<font style="font-size: 16px;"><b>%s</b></font><font style="%sfont-size: 9px;"> %s</font><br>' ...
                '%s<br>%s<br>☁️%d  🏷️%d'], homologation, color, upper(status), manufacturer, model, numWordCloud, numOthers);

            function model = MergedModel(referenceTable)
                modelList = strtrim({referenceTable.("Modelo"){1}, referenceTable.("Nome Comercial"){1}});
                modelList(cellfun(@isempty, modelList)) = [];

                model = strjoin(unique(modelList, 'stable'), ' - ');
            end
        end

        %-----------------------------------------------------------------%
        % AUXAPP.WINCONFIG: CHECKUPDATE
        %-----------------------------------------------------------------%
        function htmlContent = checkUpdate(generalSettings, rootFolder)
            try
                % Versão instalada no computador:
                appName          = class.Constants.appName;
                presentVersion   = struct(appName, generalSettings.AppVersion.application.version); 
                
                % Versão estável, indicada nos arquivos de referência (na nuvem):
                generalURL       = util.publicLink(appName, rootFolder, 'VersionFile');
                generalVersions  = webread(generalURL, weboptions("ContentType", "json"));        
                stableVersion    = struct(appName, generalVersions.(appName).Version);
                
                % Validação:
                if isequal(presentVersion, stableVersion)
                    msgWarning   = 'O SCH está atualizado';
                else
                    updatedModule    = {};
                    nonUpdatedModule = {};
                    if strcmp(presentVersion.(appName), stableVersion.(appName))
                        updatedModule(end+1)    = {appName};
                    else
                        nonUpdatedModule(end+1) = {appName};
                    end
        
                    dataStruct    = struct('group', 'VERSÃO INSTALADA', 'value', presentVersion);
                    dataStruct(2) = struct('group', 'VERSÃO ESTÁVEL',   'value', stableVersion);
                    dataStruct(3) = struct('group', 'SITUAÇÃO',         'value', struct('updated', strjoin(updatedModule, ', '), 'nonupdated', strjoin(nonUpdatedModule, ', ')));
        
                    msgWarning = textFormatGUI.struct2PrettyPrintList(dataStruct, 'print -1', '', 'popup');
                end
                
            catch ME
                msgWarning = ME.message;
            end
        
            htmlContent = msgWarning;
        end

        %-----------------------------------------------------------------%
        % AUXAPP.DOCKREPORTLIB
        %-----------------------------------------------------------------%
        function htmlContent = issueDetails(system, issue, details)
            dataStruct      = struct('group', 'CADASTRO', 'value', details);
            freeInitialText = sprintf('<font style="font-size: 16px;"><b>Atividade de Inspeção #%d</b></font> %s<br><br>', issue, system);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'print -1', freeInitialText, 'popup');
        end

        %-----------------------------------------------------------------%
        function htmlContent = entityDetails(id, details)
            dataStruct      = struct('group', 'CADASTRO', 'value', details);
            freeInitialText = sprintf('<font style="font-size: 16px;"><b>%s</b></font><br><br>', id);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', freeInitialText, 'popup');
        end

        %-----------------------------------------------------------------%
        function htmlContent = generateAdCard(adsTable, urlPreffix)
            adName = adsTable.nome{1};
            adDateRaw = adsTable.data{1};
            marketplace = adsTable.marketplace{1};
            adURL = adsTable.url{1};
            pdfURL = [urlPreffix adsTable.screenshot{1}];
            try
                adDate = datestr(datetime(adDateRaw, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss"), 'dd/mm/yyyy');
            catch
            end

            if isempty(adsTable.vendedor{1})
                vendor = '<font style="color: #5f5f5f;">(não identificado)</font>';
            else
                vendor = sprintf('%s', adsTable.vendedor{1});
            end

            if isempty(adsTable.marca{1})
                manufacturer = '<font style="color: #5f5f5f;">(não identificado)</font>';
            else
                manufacturer = sprintf('<b>%s</b>', adsTable.marca{1});
            end

            if isempty(adsTable.modelo{1})
                model = '<font style="color: #5f5f5f;">(não identificado)</font>';
            else
                model = sprintf('<b>%s</b>', adsTable.modelo{1});
            end

            priceRaw = adsTable.("preço"){1};
            adPrice = char(regexprep(priceRaw, '[^0-9\.,]', ''));

            characteristicsRaw = adsTable.("características"){1};

            try
                characteristicsData = matlab.jsondecode(characteristicsRaw, 'table');
            catch
                characteristicsData = [];
            end

            if isempty(characteristicsData)
                characteristicsTableRows = 'Características técnicas indisponíveis ou não processadas para este anúncio.<br>';
            else
                characteristicsTableRows = '';
                for kk = 1:height(characteristicsData)
                    characteristicsTableRows = [characteristicsTableRows, sprintf([ ...
                        '<tr>' ...
                            '<td style="width: 50%%; padding: 3px 6px 3px 6px; color: #5f5f5f; word-break: break-word; border: 1px solid #202020;"><b>%s</b></td>' ...
                            '<td style="width: 50%%; padding: 3px 6px 3px 6px; color: #202020; word-break: break-word; border: 1px solid #202020;">%s</td>' ...
                        '</tr>' ...
                    ], characteristicsData.field{kk}, characteristicsData.value{kk})];
                end

                characteristicsTableRows = sprintf('Características técnicas do produto:<br><table style="width: 100%%; table-layout: fixed; border: 1px solid #202020; border-collapse: collapse; font-size: 11px;">%s</table>', characteristicsTableRows);
            end

            llmAnalysis = sprintf('<i>"%s"</i><br><font style="font-size: 10px; color: #5f5f5f;">(%s)</font>', adsTable.("justificativa_produto_telecom"){1}, adsTable.("llm_model"){1});

            infoTable = sprintf([ ...
                '<table style="width: 100%%; border-collapse: collapse;">' ...
                    '<tr>' ...
                        '<td>' ...
                            'Fabricante: %s<br>' ...
                            'Modelo: %s' ...
                        '</td>' ...
                        '<td style="text-align: right;">' ...
                            '<font style="font-size: 16px;"><b>R$ %.2f</b></font><br>' ...
                            '<font style="font-size: 10px; color: #5f5f5f;">%s</font>' ...
                        '</td>' ...
                    '</tr>' ...
                '</table>' ...
            ], manufacturer, model, str2double(adPrice), vendor);

            htmlContent = sprintf([ ...
                '<section style="margin: 10px;">' ...
                    '<font style="font-size: 16px; display: inline-block; vertical-align: middle;"><b>%s</b></font><br>' ...
                    '<font style="font-size: 10px; color: #5f5f5f;">%s • %s</font><br>' ...
                    '<a href="%s" target="_blank" rel="noopener noreferrer">&#x1F5BC;&#xFE0F;</a> ' ...
                    '<a href="%s" target="_blank" rel="noopener noreferrer">&#128279;</a><br><br>' ...
                    '%s<br>' ...
                    '%s<br>' ...
                    '%s' ...
                '</section>' ...
            ], adName, adDate, marketplace, pdfURL, adURL, infoTable, characteristicsTableRows, llmAnalysis);
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        function entry = makeDisplayEntry(group, value, link)
            arguments
                group
                value
                link = ''
            end

            entry = struct('group', group, 'value', value, 'link', link);
        end

        %-----------------------------------------------------------------%
        function htmlLink = createEditHTMLLink(appHandleNameInBase, generalSettings, eventName, eventData, linkType, imgFileName, imgWidth, imgHeight)
            arguments
                appHandleNameInBase 
                generalSettings
                eventName
                eventData = ''                
                linkType {mustBeMember(linkType, {'link', 'question', 'edit'})} = 'edit'
                imgFileName = 'Edit_32.png'
                imgWidth = 18 % pixels
                imgHeight = 18% pixels
            end

            htmlLink = '';

            try
                if ~isempty(appHandleNameInBase)
                    if ~isempty(generalSettings) && ~isempty(generalSettings.AppVersion.application.resourceStaticURL)
                        htmlLink = ui.TextView.createHTMLLink('customImage', appHandleNameInBase, eventName, eventData, imgFileName, imgWidth, imgHeight, generalSettings);
                    else
                        htmlLink = ui.TextView.createHTMLLink(linkType, appHandleNameInBase, eventName, eventData);
                    end
                end
            catch
            end
        end
    end
end