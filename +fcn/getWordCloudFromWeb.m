function [wordCloudTable, wordCloudInfo] = getWordCloudFromWeb(word2Search, nMaxWords)

    VERSION = 1;
    SOURCE  = 'GOOGLE';
    MODE    = 'HTTP';
    FIELDS  = 'Textual content of tag <a>';
    URL     = 'https://www.google.com/search?q=%s';
    TAG     = 'A';

    webURL      = sprintf(URL, word2Search);
    webContent  = webread(webURL);

    listOfWords = fcn.extractHTMLText(webContent, TAG);
    
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
    bag                 = bag.removeWords(textAnalysis.stopWords);

    wordCloudTable      = topkwords(bag, nMaxWords);
    wordCloudTable.Word = regexprep(wordCloudTable.Word, cellfun(@(x) sprintf('\\<%s\\>', x), referenceWordCloud.editedWord, 'UniformOutput', false), referenceWordCloud.Word);

    wordCloudJSON = jsonEncode(wordCloudTable);
    wordCloudInfo = sprintf(['{"metaData": {'          ...
                                '"Version": %d, '      ...
                                '"Source": "%s", '     ...
                                '"Mode": "%s", '       ...
                                '"Fields": ["%s"], '   ...
                                '"nWords": %d '        ...
                              '},'                     ...
                              '"searchedWord": "%s", ' ...
                              '"cloudOfWords": "%s"'   ...
                             '}'], VERSION, SOURCE, MODE, FIELDS, nMaxWords, word2Search, wordCloudJSON);

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