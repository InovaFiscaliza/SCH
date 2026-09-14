function SCHDataUpdate()
    % PATH
    appName = class.Constants.appName;
    fileName = 'SCHData_v3';
    rootFolder = appEngine.util.RootFolder(appName, fileparts(mfilename('fullpath')));
    warning('off', 'MATLAB:readtable:AllNaTVariable')

    % LOG
    timeStamp  = datetime('now');
    logFile    = fullfile(rootFolder, 'log', sprintf('LOG_%d_%d.txt', year(timeStamp), month(timeStamp)));
    diary(logFile)
    diary on
    fprintf(sprintf('%s: Tentativa de atualização da base de dados "%s.mat" iniciada.\n', datestr(now), fileName))
    
    try
        [fileUrls, schDataHubGet, schDataHubPost, regulatronDataHubGet] = initialValidations(rootFolder);

        % REFERENCE TABLE, AND REFERENCE RELEASED DATE
        schData = [];
        try
            load(fullfile(schDataHubGet, [fileName '.mat']), 'schData')
        catch
        end

        % RAW TABLE
        schRawDataByFile = struct('Table', {}, 'TableHeight', {}, 'FileSize', {}, 'TimeStamp', {});
        tempName = tempname;
    
        for ii = 1:numel(fileUrls)
            zipFullFile = websave(sprintf('%s_zipFile%d.zip', tempName, ii), fileUrls{ii}, weboptions('Timeout', 10));
            unzipedFile = char(unzip(zipFullFile, tempdir));
            
            rawTable = parseWebFile(unzipedFile, ii);
            fileInfo = dir(unzipedFile);
    
            schRawDataByFile(ii) = struct('Table', rawTable, 'TableHeight', height(rawTable), 'FileSize', fileInfo.bytes, 'TimeStamp', datestr(fileInfo.datenum, "dd/mm/yyyy"));
            try
                eval(sprintf('delete %s %s', zipFullFile, unzipedFile))
            catch
            end
        end

        schRawData = vertcat(schRawDataByFile.Table);
        schRawData = sortrows(schRawData, {'Homologação', 'Categoria do Produto', 'Tipo'});
        releasedData = datestr(max(cellfun(@(x) datetime(x, 'InputFormat', 'dd/MM/yyyy'), {schRawDataByFile.TimeStamp})), 'dd/mm/yyyy');

        % NEW DATA?!
        % Como isequal(NaT, NaT) é FALSO, elimina-se da análise as colunas
        % com informações de data, além das colunas de cache (presentes apenas
        % em refTable).
        columnIndexes = ~strcmp(matlab.Compatibility.resolveTableVariableTypes(schRawData, false), 'datetime');

        if isempty(schData) || ~isequal(schData.detailed(:, columnIndexes), schRawData(:, columnIndexes))
            % CACHE
            cacheColumns = {'Homologação | Solicitante | Fabricante | Modelo | Nome Comercial'};
            [schRawData, cacheData] = createCache(schRawData, cacheColumns);
            [schRawData, aggregatedTable] = aggregateTableByHomologation(schRawData);
            schData = struct( ...
                'detailed', schRawData, ...
                'aggregated', aggregatedTable ...
            );
        
            % .MAT
            save(fullfile(schDataHubPost, [fileName '.mat']), 'schData', 'cacheData', 'releasedData', '-mat', '-v7')
            fprintf(sprintf('%s: Base de dados "%s.mat" atualizada em %s, sendo composta por %d linhas.\n', datestr(now), fileName, releasedData, height(schRawData)))

            % .XLSX
            writetable(schRawData(:, 1:19), fullfile(schDataHubPost, [fileName '.xlsx']), "UseExcel", false, "PreserveFormat", true)
            fprintf(sprintf('%s: Base de dados exportada como "%s.xlsx".\n', datestr(now), fileName))

            % REGULATRON ADS
            updateAdsTable(aggregatedTable, schDataHubPost, regulatronDataHubGet)

        else
            error('Dados idênticos ao da última extração.')
        end

    catch ME
        fprintf(sprintf('%s: %s\n\n', datestr(now), ME.message))
    end

    diary off

    if isdeployed
        pidMatlab = feature('getpid');
        system(sprintf('taskkill /F /PID %d', pidMatlab));
    end
end


%-------------------------------------------------------------------------%
function [fileURLs, schDataHubGet, schDataHubPost, regulatronDataHubGet] = initialValidations(rootFolder)
    publicLinks = jsondecode(fileread(fullfile(rootFolder, 'config', 'public-links.json')));
    fileURLs = {publicLinks.SCH.Dashboard_File1, publicLinks.SCH.Dashboard_File2};

    generalSettings = jsondecode(fileread(fullfile(rootFolder, 'config', 'general-settings.json')));
    schDataHubGet = generalSettings.fileFolder.dataHub.sch.get;
    schDataHubPost = generalSettings.fileFolder.dataHub.sch.post;
    regulatronDataHubGet = generalSettings.fileFolder.dataHub.regulatron.get;

    if ~isfolder(schDataHubGet)
        error('Pendente mapear pasta do Sharepoint, atualizando o arquivo de configuração "general-settings.json".')
    end
end


%-------------------------------------------------------------------------%
function rawTable = parseWebFile(fileFullPath, fileID)
    switch fileID
        % 'Produtos_Homologados_Anatel.csv'
        case 1            
            opts = delimitedTextImportOptions('NumVariables',          21,         ...
                                              'Encoding',              'UTF-8',    ...
                                              'Delimiter',             ';',        ...
                                              'VariableNamingRule',    'preserve', ...
                                              'VariableNamesLine',     1,          ...
                                              'DataLines',             2,          ...
                                              'SelectedVariableNames', [1:7,9,11:21], ...
                                              'VariableTypes',         {'datetime', 'char', 'char', 'char', 'categorical',          ...
                                                                        'datetime', 'datetime', 'categorical', 'categorical',       ...
                                                                        'categorical', 'categorical', 'char', 'char', 'char',       ...
                                                                        'categorical', 'categorical', 'categorical', 'categorical', ...
                                                                        'categorical', 'categorical', 'categorical'});
            opts = setvaropts(opts, 1, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 6, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 7, 'InputFormat', 'dd/MM/yyyy HH:mm:ss', 'DatetimeFormat', 'dd/MM/yyyy');
        
            rawColumnNames    = {'Número de Homologação', 'Nome do Solicitante', 'CNPJ do Solicitante', 'Nome do Fabricante', 'Situação do Requerimento', 'Tipo do Produto'};
            editedColumnNames = {'Homologação', 'Solicitante', 'CNPJ/CPF', 'Fabricante', 'Situação', 'Tipo'};            
            newColumnNames    = {};

        % 'Produtos_Homologados_por_Declaração_de_Conformidade.csv'
        case 2
            opts = delimitedTextImportOptions('NumVariables',        8,         ...
                                              'Encoding',           'UTF-8',    ...
                                              'Delimiter',          ';',        ...
                                              'VariableNamingRule', 'preserve', ...
                                              'VariableNamesLine',  1,          ...
                                              'DataLines',          2,          ...
                                              'VariableTypes',      {'char', 'datetime', 'char', 'char', 'categorical', 'char', 'char', 'categorical'});
            opts = setvaropts(opts, 2, 'InputFormat', 'yyyy-MM-dd', 'DatetimeFormat', 'dd/MM/yyyy');
        
            rawColumnNames    = {'NumeroHomologacao', 'DataEmissaoHomologacao', 'Produto', 'NomeComercial', 'StatusRequerimento'};
            editedColumnNames = {'Homologação', 'Data da Homologação', 'Tipo', 'Nome Comercial', 'Situação'};
            newColumnNames    = {'CNPJ/CPF',                                    'char';        ...
                                 'Certificado de Conformidade Técnica',         'categorical'; ...
                                 'Data do Certificado de Conformidade Técnica', 'datetime';    ...
                                 'Data de Validade do Certificado',             'datetime';    ...
                                 'Situação do Certificado',                     'categorical'; ...
                                 'Categoria do Produto',                        'categorical'; ...
                                 'IC_ANTENA',                                   'categorical'; ...
                                 'IC_ATIVO',                                    'categorical'; ...
                                 'País do Fabricante',                          'categorical'; ...
                                 'CodUIT',                                      'categorical'; ...
                                 'CodISO',                                      'categorical'};
    end

    % Leitura do arquivo, trocando nomes de algumas colunas.
    rawTable = readtable(fileFullPath, opts);
    rawTable = renamevars(rawTable, rawColumnNames, editedColumnNames);

    % Formatando a coluna "Homologação" e eliminando os registros
    % que não possuem o nº esperado de caracteres (no caso, 12).
    nHomLogicalIndex = cellfun(@(x) numel(x)~=12, rawTable.("Homologação"));
    if any(nHomLogicalIndex)
        rawTable(nHomLogicalIndex,:) = [];
    end
    rawTable.("Homologação") = regexprep(rawTable.("Homologação"), '(\d{5})(\d{2})(\d{5})', '$1-$2-$3');

    % Formatando a coluna "CNPJ/CPF".
    if ismember('CNPJ/CPF', rawTable.Properties.VariableNames)
        nCharactersCNPJCPF = cellfun(@(x) numel(x), rawTable.("CNPJ/CPF"));
        nCPFLogicalIndex   = nCharactersCNPJCPF == 11;
        nCNPJLogicalIndex  = nCharactersCNPJCPF == 14;
        
        rawTable.("CNPJ/CPF")(nCPFLogicalIndex)  = regexprep(rawTable.("CNPJ/CPF")(nCPFLogicalIndex),  '(\d{3})(\d{3})(\d{3})(\d{2})',        '$1.$2.$3-$4');
        rawTable.("CNPJ/CPF")(nCNPJLogicalIndex) = regexprep(rawTable.("CNPJ/CPF")(nCNPJLogicalIndex), '(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})', '$1.$2.$3/$4-$5');
    end

    % Eliminando qualquer caractere vazio equivalente a [ \f\n\r\t\v] das
    % outras colunas base do cache (além de "Homologação").
    cacheColumnNames = {'Fabricante', 'Modelo', 'Nome Comercial', 'Solicitante'};
    for ii = 1:numel(cacheColumnNames)
        columnName = cacheColumnNames{ii};
        rawTable.(columnName) = regexprep(rawTable.(columnName), '\s+', ' ');
    end

    % Adicionando novas colunas com valores padrões...
    for ii = 1:height(newColumnNames)
        newColumnName  = newColumnNames{ii,1};
        newColumnClass = newColumnNames{ii,2};

        switch newColumnClass
            case 'char';        newColumnValue = {'-1'};
            case 'categorical'; newColumnValue = categorical(-1);
            case 'datetime';    newColumnValue = NaT;
        end

        rawTable.(newColumnName)(:) = newColumnValue;
    end

    pause(1)
end


%-------------------------------------------------------------------------%
function [rawTable, cacheData] = createCache(rawTable, cacheColumns)
    cacheData = repmat(struct('Column', '', 'uniqueValues', {{}}, 'uniqueTokens', {{}}, 'uniqueTokensLength', []), numel(cacheColumns), 1);

    for ii = 1:numel(cacheColumns)
        listOfColumns = strsplit(cacheColumns{ii}, ' | ');

        uniqueValues  = {};
        uniqueTokens  = {};

        for jj = 1:numel(listOfColumns)
            cacheColumn        = listOfColumns{jj};
            cacheColumnName    = sprintf('_%s', cacheColumn);

            [uniqueTempValues, ...
                referenceData] = textAnalysis.preProcessedData(rawTable.(cacheColumn));
            tokenizedDoc       = tokenizedDocument(uniqueTempValues);

            uniqueValues       = [uniqueValues; uniqueTempValues];
            uniqueTokens       = [uniqueTokens; cellstr(tokenizedDoc.tokenDetails.Token)];
    
            if ~ismember(cacheColumnName, rawTable.Properties.VariableNames)
                rawTable.(cacheColumnName) = referenceData;
            end
        end
        uniqueValues = unique(uniqueValues);
        uniqueTokens = unique([uniqueValues; uniqueTokens]);

        cacheData(ii) = struct( ...
            'Column', cacheColumns{ii},  ...
            'uniqueValues', {uniqueValues}, ...
            'uniqueTokens', {uniqueTokens}, ...
            'uniqueTokensLength', strlength(uniqueTokens) ...
        );
    end
end


%-------------------------------------------------------------------------%
function [detailedTable, aggregatedTable] = aggregateTableByHomologation(detailedTable)
    [~, firstRowIndexes, homGroupIndexes] = unique(detailedTable.("Homologação"), 'stable');
    detailedTable.('Índice Homologação Agregada') = homGroupIndexes;
    aggregatedTable = detailedTable(firstRowIndexes, {'Homologação', 'Tipo', 'Solicitante', 'Fabricante', 'Modelo', 'Nome Comercial'});    

    numGroups = max(homGroupIndexes);

    for columnName = ["Tipo", "Modelo", "Nome Comercial"]
        groupedValues = cell(numGroups, 1);

        for ii = 1:numGroups
            groupMask = (homGroupIndexes == ii);
            values = detailedTable.(columnName)(groupMask);
            if ~iscellstr(values)
                values = cellstr(values);
            end
            values = values(~cellfun(@isempty, strtrim(values)));

            if isempty(values)
                groupedValues{ii} = '';
            else
                groupedValues{ii} = strjoin(unique(values), '\n');
            end
        end

        aggregatedTable.(columnName) = groupedValues;
    end
end


%-----------------------------------------------------------------%
function updateAdsTable(schAggregatedTable, schDataHubGet, regulatronDataHubGet)
    validCertificadoSet = replace(schAggregatedTable.("Homologação"), '-', '');

    % Lê as abas "LLM" e "Anúncio" de "Anuncios.xlsx", faz o relacionamento
    % por "key" e retorna a tabela principal com colunas selecionadas. Como 
    % a relação pode ser 1:n (um anúncio pode ter múltiplos LLMs), mantém-se
    % apenas a última ocorrência de cada chave.
    adsFile = fullfile(regulatronDataHubGet, 'Anuncios.xlsx');
    llm = readtable(adsFile, "VariableNamingRule", "preserve", "Sheet", "LLM");
    llm = keepLastOccurrence(llm, 'key');
    
    anuncio = readtable(adsFile, "VariableNamingRule", "preserve", "Sheet", "Anúncio");
    anuncio = keepLastOccurrence(anuncio, 'key');

    adsTable = join( ...
        anuncio, llm, ...
        'Keys', 'key', ...
        'LeftVariables', {'certificado', 'data', 'marketplace', 'nome', 'vendedor', 'marca', 'modelo', 'características', 'preço', 'screenshot', 'url', 'imagem', 'imagens'}, ...
        'RightVariables', {'anuncio_produto_telecom', 'justificativa_produto_telecom', 'llm_model'} ...
    );

    invalidCertificadoMask = ~ismember(anuncio.certificado, validCertificadoSet);
    invalidScreenshotMask = ~endsWith(anuncio.screenshot, '.pdf');
    telecomFlagMask = ~ismember(adsTable.anuncio_produto_telecom, {'Proibido', 'Sim'});

    removeMask = invalidCertificadoMask | invalidScreenshotMask | telecomFlagMask;
    adsTable(removeMask, :) = [];

    adsTable = sortrows(adsTable, 'data', 'descend');
    [~, uniqueIdxs] = unique(adsTable.url, 'stable');
    adsTable = adsTable(uniqueIdxs, :);

    adsTable.('#') = uint32((1:height(adsTable))');
    adsTable = movevars(adsTable, '#', 'Before', 1);

    save(fullfile(schDataHubGet, 'Regulatron.mat'), 'adsTable', '-mat')
    fprintf(sprintf('%s: Base de dados "Regulatron.mat" atualizada, sendo composta por %d linhas.\n\n', datestr(now), height(adsTable)))

    function tbl = keepLastOccurrence(tbl, keyColumn)
        [~, lastIdxs] = unique(tbl.(keyColumn), 'last');
        tbl = tbl(lastIdxs, :);
    end
end