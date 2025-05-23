function [similarStrings, idxFiltered, redFontFlag] = getSimilarStrings(cacheData, value2Search, listOfColumns, nMinValues)

    persistent cacheStringList
    persistent cacheTokenList

    if isempty(cacheTokenList)
        cacheStringList = suggestion.getCacheStringList(cacheData, listOfColumns);    
    end

    if isempty(cacheTokenList) || ~isvalid(cacheTokenList)
        cacheTokenList = parallel.pool.Constant(suggestion.getCacheTokenList(cacheData, listOfColumns));
    end

    algorithmsOrder = {'startsWith', 'Contains', 'Levenshtein'};
    redFontFlag     = false;

    idxFiltered     = [];
    for kk = algorithmsOrder
        methodName = char(kk);
        
        if strcmp(methodName, 'Levenshtein')
            if numel(idxFiltered) >= nMinValues
                break
            end

            if isempty(idxFiltered)
                redFontFlag = true;
            end
        end

        tic
        idxFiltered = getSimilarStringsIndex(methodName, cacheStringList, cacheTokenList, value2Search, idxFiltered, nMinValues);
        toc
    end

    similarStrings = cacheStringList(idxFiltered);

end


%-------------------------------------------------------------------------%
function idxFiltered = getSimilarStringsIndex(methodName, cacheStringList, cacheTokenList, value2Search, idxFiltered, nMinValues)

    switch methodName
        case 'startsWith'
            idxLogical  = startsWith(cacheStringList, value2Search);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
    
        case 'Contains'
            idxLogical  = contains(cacheStringList, value2Search);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
    
        case 'Levenshtein'
            nTokens     = numel(cacheTokenList.Value);
            levDistance = zeros(nTokens, 1, 'single');
    
            %parpoolCheck()
            parfor ii = 1:nTokens
                token = cacheTokenList.Value{ii};
                levDistance(ii) = suggestion.LevenshteinDistance(token, value2Search);
            end
            [~, sortedIndex] = sortrows(levDistance);
    
            kk = 0;
            while numel(idxFiltered) < nMinValues
                kk = kk+1;
                if kk > nTokens
                    break
                end
    
                sortedTokenIndex = find(contains(cacheStringList, cacheTokenList.Value{sortedIndex(kk)}));
                idxFiltered      = unique([idxFiltered; sortedTokenIndex], 'stable');
            end
            idxFiltered = idxFiltered(1:min([numel(idxFiltered), nMinValues]));
    end

end