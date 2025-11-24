function [similarStrings, idxFiltered, redFontFlag] = getSimilarStrings(cacheData, value2Search, nMinValues)
    valueReferenceList = cacheData(1).uniqueValues;
    tokenList = cacheData(1).uniqueTokens;
    tokenListLength = cacheData(1).uniqueTokensLength;
    
    algorithmsOrder = {'startsWith', 'Contains', 'Levenshtein_Optimazed'};
    redFontFlag     = false;
    idxFiltered     = [];

    for kk = algorithmsOrder
        methodName = char(kk);
        
        if strcmp(methodName, 'Levenshtein_Optimazed')
            if numel(idxFiltered) >= nMinValues
                break
            end

            if isempty(idxFiltered)
                redFontFlag = true;
            end
        end

        idxFiltered = getSimilarStringsIndex(methodName, valueReferenceList, tokenList, tokenListLength, value2Search, idxFiltered, nMinValues);
    end

    similarStrings = valueReferenceList(idxFiltered);
end

%-------------------------------------------------------------------------%
function idxFiltered = getSimilarStringsIndex(methodName, valueReferenceList, tokenList, tokenListLength, value2Search, idxFiltered, nMinValues)
    % As funções "startsWith" e "contains" não precisam do argumento opcional 
    % "IgnoreCase" igual a true porque os valores sob análise já estão nas suas 
    % versões lowcase.

    % Criado vetor de distância persistente, evitando recriá-lo a cada
    % chamada.

    switch methodName
        case 'startsWith'
            idxLogical  = startsWith(valueReferenceList, value2Search);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
    
        case 'Contains'
            idxLogical  = contains(valueReferenceList, value2Search);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');

        case 'Levenshtein_Optimazed'
            % Calcula comprimento das palavras (tokenListLength vai ser
            % sempre igual, então pré-calcular na estrutura do cache).
            value2SearchLength = numel(value2Search);

            % Identifica os candidatos, que é um conjunto com um tamanho
            % mínimo.
            nMinCandidates = nMinValues - numel(idxFiltered);
            initialMaxLengthDiff = 5;
            while true
                candidateMask = abs(tokenListLength - value2SearchLength) <= initialMaxLengthDiff;
                candidateIdx  = find(candidateMask);

                if nMinCandidates < numel(candidateIdx)
                    break
                end
                initialMaxLengthDiff = initialMaxLengthDiff+1;
            end
        
            candidatesList = tokenList(candidateIdx);
            numCandidates  = numel(candidateIdx);
            localDistances = zeros(numCandidates, 1);

            parpoolCheck()
            parfor ii = 1:numCandidates
                localDistances(ii) = LevenshteinDistance(candidatesList{ii}, value2Search);
            end
            [~, sortedIndex] = mink(localDistances, nMinCandidates);         
        
            kk = 0;
            while numel(idxFiltered) < nMinValues
                kk = kk+1;
                if kk > nMinCandidates
                    break
                end
    
                idxLogical  = contains(valueReferenceList, candidatesList{sortedIndex(kk)});
                idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
            end
            idxFiltered = idxFiltered(1:min([numel(idxFiltered), nMinValues]));
    
        case 'Levenshtein'
            persistent nTokens
            persistent levDistance

            if isempty(nTokens)
                nTokens     = numel(tokenList);
                levDistance = zeros(nTokens, 1);
            end

            parpoolCheck()
            parfor ii = 1:nTokens
                levDistance(ii) = LevenshteinDistance(tokenList{ii}, value2Search);
            end
            [~, sortedIndex] = sort(levDistance);
    
            kk = 0;
            while numel(idxFiltered) < nMinValues
                kk = kk+1;
                if kk > nTokens
                    break
                end
    
                idxLogical  = contains(valueReferenceList, tokenList{sortedIndex(kk)});
                idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
            end
            idxFiltered = idxFiltered(1:min([numel(idxFiltered), nMinValues]));
    end
end

%-------------------------------------------------------------------------%
function d = LevenshteinDistance(s1, s2)
    len1 = numel(s1);
    len2 = numel(s2);

    D = zeros(len1+1, len2+1);
    D(:,1) = (0:len1)';
    D(1,:) = 0:len2;

    for ii = 1:len1
        for jj = 1:len2
            cost = s1(ii) ~= s2(jj);
            D(ii+1,jj+1) = min([ ...
                D(ii,jj+1) + 1, ...
                D(ii+1,jj) + 1, ...
                D(ii,jj)   + cost ...
            ]);
        end
    end
    d = D(len1+1, len2+1);
end