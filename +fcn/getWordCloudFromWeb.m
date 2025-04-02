function [wordCloudTable, wordCloudInfo] = getWordCloudFromWeb(word2Search, nMaxWords)

    response  = ws.Google.customSearchEngine(word2Search);
    
    itemClass = class(response.items);
    switch itemClass
        case 'cell'
            listOfWords = cellfun(@(x) horzcat(x.title, x.snippet), response.items, 'UniformOutput', false);
        case 'struct'
            listOfWords = [{response.items.title}, {response.items.snippet}];
    end
    
    referenceWordCloud  = wordCloudCounts(listOfWords);
    referenceWordCloud  = convertvars(referenceWordCloud, "Word", 'cellstr');
    
    referenceData       = textAnalysis.normalizeWords(referenceWordCloud.Word);
    [~, uniqueIndex]    = unique(referenceData, 'stable');
    
    referenceWordCloud.editedWord = referenceData;
    referenceWordCloud  = referenceWordCloud(uniqueIndex,:);

    % A normalização de palavras garante o tratamento igual às palavras "iPhone" 
    % e "iphone", ou "Ação" e "acao", por exemplo. Ao final, contudo, usa-se
    % a primeira referência da palavra normalizada: "iPhone" e "Ação", nos 
    % supracitados exemplos.
    referenceData       = textAnalysis.normalizeWords(listOfWords);

    % Aqui os dados são processados, sendo excluídas pontuações e "stop words" 
    % comuns da língua portuguesa.
    documents           = tokenizedDocument(referenceData);
    documents           = erasePunctuation(documents);
    % documents           = removeShortWords(documents, 1);

    bag                 = bagOfWords(documents);
    bag                 = bag.removeWords([cellstr(stopWords('Language', 'en')), textAnalysis.stopWords]); % Inglês e Português

    wordCloudTable      = topkwords(bag, nMaxWords);
    wordCloudTable.Word = regexprep(wordCloudTable.Word, cellfun(@(x) sprintf('\\<%s\\>', x), referenceWordCloud.editedWord, 'UniformOutput', false), referenceWordCloud.Word);

    wordCloudJSON = jsonEncode(wordCloudTable);
    wordCloudInfo = jsonencode(struct('metaData', struct('Version', 1,                     ...
                                                         'Source',  'GOOGLE',              ...
                                                         'Mode',    'API',                 ...
                                                         'Fields',  {{'Name', 'Snippet'}}, ...
                                                         'nWords',  nMaxWords),            ...
                                      'searchedWord', words2Search,                        ...
                                      'cloudOfWords', wordCloudJSON));
end


%-------------------------------------------------------------------------%
function wordCloudJSON = jsonEncode(wordCloudTable)
    wordCloudJSON = "{";    
    for ii = 1:height(wordCloudTable)
        wordCloudJSON = wordCloudJSON + "\""" + wordCloudTable.Word(ii) + "\"": " + string(wordCloudTable.Count(ii));
        
        if ii < height(wordCloudTable)
            wordCloudJSON = wordCloudJSON + ", ";
        end
    end    
    wordCloudJSON = wordCloudJSON + "}";
end