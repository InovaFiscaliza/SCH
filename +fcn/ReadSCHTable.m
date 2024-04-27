function [rawDataTable, releasedData, cacheData, matFullFile] = ReadSCHTable(fileFullPath, cacheColumns)

    arguments
        fileFullPath
        cacheColumns = {'Modelo', 'Nome Comercial', 'Fabricante', 'Solicitante'}
    end

    cacheData    = [];
    matFullFile  = '';

    [filePath, fileName, fileExt] = fileparts(fileFullPath);

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
                                              'VariableTypes',      {'datetime', 'char', 'categorical', 'categorical', 'char', 'datetime', 'datetime', 'double', 'categorical', 'double', 'categorical', 'categorical', 'char', 'char', 'double', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical'});
            
            opts = setvaropts(opts, 1, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 6, 'InputFormat', 'dd/MM/yyyy');
            opts = setvaropts(opts, 7, 'InputFormat', 'dd/MM/yyyy HH:mm:ss', 'DatetimeFormat', 'dd/MM/yyyy');
        
            % Simplificação dos nomes de algumas das colunas que serão apresentadas 
            % na interface gráfica do usuário.
            rawColumnNames    = {'Número de Homologação', 'Nome do Solicitante', 'CNPJ do Solicitante', 'Nome do Fabricante', 'Situação do Requerimento', 'Tipo do Produto'};
            editedColumnNames = {'Homologação', 'Solicitante', 'CNPJ', 'Fabricante', 'Situação', 'Tipo'};
            
            rawDataTable = readtable(fileFullPath, opts);
            rawDataTable = renamevars(rawDataTable, rawColumnNames, editedColumnNames);

            % Exclusão de registros cujo campo de "Homologação" não possui
            % 12 caracteres, formatando-o posteriormente.
            dataIndex = find(cellfun(@(x) numel(x)~=12, rawDataTable.("Homologação")));
            if ~isempty(dataIndex)
                rawDataTable(dataIndex,:) = [];
            end
            rawDataTable.("Homologação") = cellfun(@(x) sprintf('%s-%s-%s', x(1:5), x(6:7), x(8:12)), rawDataTable.("Homologação"), 'UniformOutput', false);

            % releasedData
            fileInfo     = dir(fileFullPath);
            releasedData = datestr(fileInfo.date, 'dd/mm/yyyy');

        otherwise
            error('Unexpected file format')
    end

    if isempty(cacheData) || any(~contains(cacheColumns, {cacheData.Column}))
        [rawDataTable, cacheData] = CacheDataCreation(rawDataTable, cacheColumns);
    end

    if strcmpi(fileExt, '.csv')
        matFullFile = fullfile(filePath, [fileName '.mat']);
        save(matFullFile, 'rawDataTable', 'releasedData', 'cacheData')
    end

end


%-------------------------------------------------------------------------%
function [rawTable, cacheData] = CacheDataCreation(rawTable, cacheColumns)

    cacheData = repmat(struct('Column', '', 'uniqueValues', {{}}, 'uniqueTokens', {{}}), numel(cacheColumns), 1);

    for ii = 1:numel(cacheColumns)
        cacheColumn        = cacheColumns{ii};
        [uniqueValues, ...
            referenceData] = fcn.PreProcessedData(rawTable.(cacheColumn));
        tokenizedDoc       = tokenizedDocument(uniqueValues);
        uniqueTokens       = unique(cellstr(tokenizedDoc.tokenDetails.Token));

        cacheData(ii)      = struct('Column',       cacheColumn,  ...
                                    'uniqueValues', {uniqueValues}, ...
                                    'uniqueTokens', {unique([uniqueValues; uniqueTokens])});

        rawTable.(sprintf('_%s', cacheColumn)) = referenceData;
    end

end