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
                    relatedAnnotationTable = varargin{3};
                    regulatronData = varargin{4};
        
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
                    Tipo          = FindListOfValues(relatedSCHTable, "Tipo");
                    Categoria     = char(relatedSCHTable.("Categoria do Produto")(1));
                    Modelo        = FindListOfValues(relatedSCHTable, "Modelo");
                    NomeComercial = FindListOfValues(relatedSCHTable, "Nome Comercial");
                
                    Anotacoes     = {};
                    for ii = 1:height(relatedAnnotationTable)
                        value = sprintf('"%s"', relatedAnnotationTable.("Valor"){ii});
                
                        if strcmp(relatedAnnotationTable.("Atributo"){ii}, 'WordCloud')
                            try
                                wordCloudInfo = jsondecode(relatedAnnotationTable.("Valor"){ii});
                                value = sprintf('%s<br><font style="color: gray; font-size: 10px;">TERMO PESQUISADO: "%s"</font>', wordCloudInfo.cloudOfWords(2:end-1), wordCloudInfo.searchedWord);
                            catch
                            end
                        end
                
                        Anotacoes{end+1} = sprintf('•&thinsp;%s: %s<br><font style="color: gray; font-size: 10px;">(%s em %s)</font>', relatedAnnotationTable.("Atributo"){ii}, ...
                                                                                                                                       value,                                   ...
                                                                                                                                       relatedAnnotationTable.("Usuário"){ii},  ...
                                                                                                                                       relatedAnnotationTable.("DataHora"){ii});
                    end

                    if isempty(Anotacoes)
                        Anotacoes = {'•&thinsp;-1'};
                    end

                    dataStruct    = struct('group', 'Data de emissão:',      'value', DataEmissao);
                    dataStruct(2) = struct('group', 'Certificado de Conformidade Técnica:', 'value', sprintf('"%s", de %s%s', certID, certEmissao, certValidade));
                    dataStruct(3) = struct('group', 'Solicitante:',          'value', {{Solicitante, sprintf('CNPJ/CPF: %s', CNPJ)}});
                    dataStruct(4) = struct('group', 'Fabricante:',           'value', {{Fabricante, Pais}});
                    dataStruct(5) = struct('group', 'Categoria:',            'value', Categoria);
                    dataStruct(6) = struct('group', 'Tipo:',                 'value', {Tipo});
                    dataStruct(7) = struct('group', 'Modelo:',               'value', {Modelo});
                    dataStruct(8) = struct('group', 'Nome Comercial:',       'value', {NomeComercial});

                    regulatronAddsIndexes  = find(contains(regulatronData.addsTable.certificado, replace(Homologacao, '-', '')));
                    if ~isempty(regulatronAddsIndexes)
                        regulatronAddsUrls = strcat('<a href="', regulatronData.urlPreffix, regulatronData.addsTable.pdf(regulatronAddsIndexes), '" target="_blank" rel="noopener noreferrer">', cellstr(string(1:numel(regulatronAddsIndexes)))', '</a>');
                        dataStruct(end+1) = struct('group', 'Anúncios Regulatron:',   'value', strjoin(regulatronAddsUrls, ', '));
                    end

                    dataStruct(end+1) = struct('group', 'Anotações:',        'value', {Anotacoes});
        
                case 'ProdutoNãoHomologado'
                    listOfProducts = varargin{2};

                    StatusColor    = 'color:red; ';
                    Status         = 'PRODUTO NÃO HOMOLOGADO';
        
                    Homologacao    = char(listOfProducts.("Homologação")(1));
                    Fabricante     = upper(char(listOfProducts.("Fabricante")(1)));
                    if isempty(Fabricante)
                        Fabricante = '(desconhecido)';
                    end
                    Tipo           = FindListOfValues(listOfProducts, "Tipo");
                    Modelo         = FindListOfValues(listOfProducts, "Modelo");

                    dataStruct(1) = struct('group', 'Fabricante:', 'value', Fabricante);
                    dataStruct(2) = struct('group', 'Tipo:',       'value', Tipo);
                    dataStruct(3) = struct('group', 'Modelo:',     'value', Modelo);
            end

            freeInitialText = sprintf('<font style="font-size: 16px;"><b>%s</b></font><font style="%sfont-size: 9px;"> %s</font><br><br>', Homologacao, StatusColor, upper(Status));
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'delete', freeInitialText, 'textview', 'normal+gray');
            
            function htmlList = FindListOfValues(referenceTable, columnName)        
                listOfValues = setdiff(unique(referenceTable.(columnName)), {''});
                if isempty(listOfValues)
                    listOfValues = {'(desconhecido)'};
                end
                htmlList = strcat('•&thinsp;', cellstr(listOfValues));
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
    end
end