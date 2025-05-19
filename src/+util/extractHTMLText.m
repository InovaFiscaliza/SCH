function listOfWords = extractHTMLText(htmlContent, htmlTag)

    webTree     = htmlTree(htmlContent);
    webSubTree  = findElement(webTree, htmlTag);
    
    listOfWords = extractHTMLText(webSubTree);

end