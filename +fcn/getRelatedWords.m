function listOfWords = getRelatedWords(word2Search)

    try
        webURL      = sprintf('https://www.google.com/search?q=%s', word2Search);
        webContent  = webread(webURL);
        listOfWords = fcn.extractHTMLText(webContent, 'A');
        
    catch ME
        listOfWords = [];
    end

end