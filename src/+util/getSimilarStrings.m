function [similarStrings, idxFiltered, redFontFlag] = getSimilarStrings(cacheData, valueToSearch, numMinValues)
    valueReferenceList = cacheData(1).uniqueValues;
    tokenList = cacheData(1).uniqueTokens;
    tokenListLength = cacheData(1).uniqueTokensLength;
    
    algorithmsOrder = {'startsWith', 'Contains', 'Levenshtein'};
    redFontFlag     = false;
    idxFiltered     = [];

    for kk = algorithmsOrder
        methodName = char(kk);
        
        if strcmp(methodName, 'Levenshtein')
            if numel(idxFiltered) >= numMinValues
                break
            end

            if isempty(idxFiltered)
                redFontFlag = true;
            end
        end

        idxFiltered = getSimilarStringsIndex(methodName, valueReferenceList, tokenList, tokenListLength, valueToSearch, idxFiltered, numMinValues);
    end

    similarStrings = valueReferenceList(idxFiltered);
end

%-------------------------------------------------------------------------%
function idxFiltered = getSimilarStringsIndex(methodName, valueReferenceList, tokenList, tokenListLength, valueToSearch, idxFiltered, numMinValues)
    % As funções "startsWith" e "contains" não precisam do argumento opcional 
    % "IgnoreCase" igual a true porque os valores sob análise já estão nas suas 
    % versões lowcase.

    % Criado vetor de distância persistente, evitando recriá-lo a cada
    % chamada.

    switch methodName
        case 'startsWith'
            idxLogical  = startsWith(valueReferenceList, valueToSearch);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
    
        case 'Contains'
            idxLogical  = contains(valueReferenceList, valueToSearch);
            idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');

        % case 'Levenshtein'
        %     persistent nTokens
        %     persistent levDistance
        % 
        %     if isempty(nTokens)
        %         nTokens     = numel(tokenList);
        %         levDistance = zeros(nTokens, 1);
        %     end
        % 
        %     parpoolCheck()
        %     parfor ii = 1:nTokens
        %         levDistance(ii) = LevenshteinDistance(tokenList{ii}, valueToSearch);
        %     end
        %     [~, sortedIndex] = sort(levDistance);
        % 
        %     kk = 0;
        %     while numel(idxFiltered) < nMinValues
        %         kk = kk+1;
        %         if kk > nTokens
        %             break
        %         end
        % 
        %         idxLogical  = contains(valueReferenceList, tokenList{sortedIndex(kk)});
        %         idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
        %     end
        %     idxFiltered = idxFiltered(1:min([numel(idxFiltered), nMinValues]));

        case 'Levenshtein'
            numValueToSearch = numel(valueToSearch);

            % Identifica os candidatos, que é um conjunto com um tamanho
            % mínimo.
            nMinCandidates = numMinValues - numel(idxFiltered);
            initialMaxLengthDiff = 3;

            while true
                candidateMask = abs(tokenListLength - numValueToSearch) <= initialMaxLengthDiff;
                if nMinCandidates < sum(candidateMask)
                    break
                end
                initialMaxLengthDiff = initialMaxLengthDiff+1;
            end
        
            candidatesList = tokenList(candidateMask);
            numCandidates  = sum(candidateMask);
            localDistances = zeros(numCandidates, 1);

            parpoolCheck()
            parfor ii = 1:numCandidates
                localDistances(ii) = LevenshteinDistance(candidatesList{ii}, valueToSearch);
            end
            [~, sortedIndex] = mink(localDistances, nMinCandidates);
        
            kk = 0;
            while numel(idxFiltered) < numMinValues
                kk = kk+1;
                if kk > nMinCandidates
                    break
                end
    
                idxLogical  = contains(valueReferenceList, candidatesList{sortedIndex(kk)});
                idxFiltered = unique([idxFiltered; find(idxLogical)], 'stable');
            end
            idxFiltered = idxFiltered(1:min([numel(idxFiltered), numMinValues]));
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