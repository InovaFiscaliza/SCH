function listOfWords = getRelatedWords(word2Search)

    try
        webURL      = sprintf('https://www.google.com/search?q=%s', word2Search);
        webContent  = webread(webURL);
        
        webTree     = htmlTree(webContent);
        webSubTree  = findElement(webTree, 'A');
        
        listOfWords = extractHTMLText(webSubTree);
        
    catch ME
        listOfWords = [];
    end

end