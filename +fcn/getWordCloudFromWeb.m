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
    wordCloudTable = wordCloudCounts(listOfWords);

    if height(wordCloudTable) > nMaxWords
        wordCloudTable = wordCloudTable(1:nMaxWords,:);
    end

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