function preProcessedData = PreProcessedData(rawData)

    if iscell(rawData) % lista de valores de uma coluna em cellstring (cache)
        preProcessedData = unique(rawData);

    elseif iscategorical(rawData) % lista de valores de uma coluna em categorical, transformando-o para cellstr (cache)
        preProcessedData = unique(cellstr(string(rawData)));
        
    else % acho que aqui é a consulta do usuário
        preProcessedData = rawData;
    end

    preProcessedData = lower(preProcessedData);
    preProcessedData = replace(preProcessedData, {'ç', 'ã', 'á', 'à', 'â', 'ê', 'é', 'í', 'î', 'ì', 'ó', 'ò', 'ô', 'õ', 'ú', 'ù', 'û', 'ü'}, ...
                                                 {'c', 'a', 'a', 'a', 'a', 'e', 'e', 'i', 'i', 'i', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u'});
    preProcessedData = replace(preProcessedData, {',', ';', '.', ':', '?', '!', '"', '''', '(', ')', '[', ']', '{', '}'}, ...
                                                 {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '});
    preProcessedData = strtrim(preProcessedData);

    if iscell(preProcessedData) % usado apenas para cache...
        preProcessedData(cellfun(@(x) isempty(x), preProcessedData)) = [];
        preProcessedData = unique(preProcessedData);
    end
end