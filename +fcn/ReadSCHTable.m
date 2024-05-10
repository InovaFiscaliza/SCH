function [rawDataTable, releasedData, cacheData, matFullFile] = ReadSCHTable(fileFullPath, cacheColumns)

    arguments
        fileFullPath
        cacheColumns = {'Homologação', 'Solicitante | Fabricante', 'Modelo | Nome Comercial'}
    end

    cacheData    = [];
    matFullFile  = '';
    saveMATFile  = false;

    [filePath, ~, fileExt] = fileparts(fileFullPath);

    switch lower(fileExt)
        case '.mat'
            load(fileFullPath, 'rawDataTable', 'releasedData', 'cacheData')

        case '.csv'
            % rawTable
            opts = delimitedTextImportOptions('NumVariables',       21,         ...
                                              'Encoding',           'UTF-8',    ...
                                              'Delimiter',          ';',        ...
                                              'VariableNamingRule', 'preserve', ...
                                              'VariableNamesLine',  1,          ...
                                              'DataLines',          2,          ...
                                              'VariableTypes',      {'datetime', 'char', 'char', 'char', 'categorical', 'datetime', 'datetime', 'categorical', 'categorical', 'categorical', 'categorical', 'char', 'char', 'char', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical'});
            
            opts = setvaropts(opts, 1, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 6, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 7, 'InputFormat', 'dd/MM/yyyy HH:mm:ss', 'DatetimeFormat', 'dd/MM/yyyy');
        
            % Simplificação dos nomes de algumas das colunas que serão apresentadas 
            % na interface gráfica do usuário.
            rawColumnNames    = {'Número de Homologação', 'Nome do Solicitante', 'CNPJ do Solicitante', 'Nome do Fabricante', 'Situação do Requerimento', 'Tipo do Produto'};
            editedColumnNames = {'Homologação', 'Solicitante', 'CNPJ/CPF', 'Fabricante', 'Situação', 'Tipo'};
            
            rawDataTable = readtable(fileFullPath, opts);
            rawDataTable = renamevars(rawDataTable, rawColumnNames, editedColumnNames);

            % Formatando a coluna "Homologação"
            nHomLogicalIndex = cellfun(@(x) numel(x)~=12, rawDataTable.("Homologação"));
            if any(nHomLogicalIndex)
                rawDataTable(nHomLogicalIndex,:) = [];
            end
            rawDataTable.("Homologação") = regexprep(rawDataTable.("Homologação"), '(\d{5})(\d{2})(\d{5})', '$1-$2-$3');

            % Formatando a coluna "CNPJ/CPF"
            nCharactersCNPJCPF = cellfun(@(x) numel(x), rawDataTable.("CNPJ/CPF"));
            nCPFLogicalIndex   = nCharactersCNPJCPF == 11;
            nCNPJLogicalIndex  = nCharactersCNPJCPF == 14;
            
            rawDataTable.("CNPJ/CPF")(nCPFLogicalIndex)  = regexprep(rawDataTable.("CNPJ/CPF")(nCPFLogicalIndex),  '(\d{3})(\d{3})(\d{3})(\d{2})',        '$1.$2.$3-$4');
            rawDataTable.("CNPJ/CPF")(nCNPJLogicalIndex) = regexprep(rawDataTable.("CNPJ/CPF")(nCNPJLogicalIndex), '(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})', '$1.$2.$3/$4-$5');

            % releasedData
            fileInfo     = dir(fileFullPath);
            releasedData = datestr(fileInfo.date, 'dd/mm/yyyy');

        otherwise
            error('Unexpected file format')
    end

    if isempty(cacheData) || any(~ismember(cacheColumns, {cacheData.Column}))
        saveMATFile  = true;
        [rawDataTable, cacheData] = CacheDataCreation(rawDataTable, cacheColumns);
    end

    if saveMATFile
        matFullFile = fullfile(filePath, 'SCHData.mat');
        save(matFullFile, 'rawDataTable', 'releasedData', 'cacheData')
    end

end


%-------------------------------------------------------------------------%
function [rawTable, cacheData] = CacheDataCreation(rawTable, cacheColumns)

    cacheData = repmat(struct('Column', '', 'uniqueValues', {{}}, 'uniqueTokens', {{}}), numel(cacheColumns), 1);

    for ii = 1:numel(cacheColumns)
        listOfColumns = strsplit(cacheColumns{ii}, ' | ');

        uniqueValues  = {};
        uniqueTokens  = {};

        for jj = 1:numel(listOfColumns)
            cacheColumn        = listOfColumns{jj};
            [uniqueTempValues, ...
                referenceData] = fcn.PreProcessedData(rawTable.(cacheColumn));
            tokenizedDoc       = tokenizedDocument(uniqueTempValues);

            uniqueValues       = [uniqueValues; uniqueTempValues];
            uniqueTokens       = [uniqueTokens; cellstr(tokenizedDoc.tokenDetails.Token)];
    
            rawTable.(sprintf('_%s', cacheColumn)) = referenceData;
        end
        uniqueValues  = unique(uniqueValues);

        cacheData(ii) = struct('Column',       cacheColumns{ii},  ...
                               'uniqueValues', {uniqueValues},    ...
                               'uniqueTokens', {unique([uniqueValues; uniqueTokens])});
    end

end