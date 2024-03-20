function preProcessedData = PreProcessedData(rawData)

    if iscell(rawData)
        preProcessedData = unique(rawData);
    else
        preProcessedData = rawData;
    end
    
    preProcessedData = lower(preProcessedData);
    preProcessedData = replace(preProcessedData, {'ç', 'ã', 'á', 'à', 'â', 'ê', 'é', 'í', 'î', 'ì', 'ó', 'ò', 'ô', 'õ', 'ú', 'ù', 'û', 'ü'}, ...
                                                 {'c', 'a', 'a', 'a', 'a', 'e', 'e', 'i', 'i', 'i', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u'});
    preProcessedData = replace(preProcessedData, {',', ';', '.', ':', '?', '!', '"', '''', '(', ')', '[', ']', '{', '}'}, ...
                                                 {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '});
    preProcessedData = strtrim(preProcessedData);

    if iscell(preProcessedData)
        preProcessedData(cellfun(@(x) isempty(x), preProcessedData)) = [];
        preProcessedData = unique(preProcessedData);
    end
end