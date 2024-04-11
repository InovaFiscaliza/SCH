function idxFiltered = StringDistance(value2Search, rawColumnData, methodName, idxFiltered, NumberMaxValues, rawColumnData_uniqueTokens)

    if ~isempty(value2Search)
        switch methodName
            case 'startsWith'
                idxLogical  = startsWith(rawColumnData, value2Search);
                idxFiltered = MergeProcess(idxFiltered, find(idxLogical), NumberMaxValues);
    
            case 'Contains'
                idxLogical  = contains(rawColumnData, value2Search);                
                idxFiltered = MergeProcess(idxFiltered, find(idxLogical), NumberMaxValues);

            case 'Levenshtein'
                HH = numel(rawColumnData_uniqueTokens);
                MM = numel(value2Search);

                LevenshteinArray = zeros(HH, 1, 'single');
                blockOfTwoArray  = zeros(HH, 1, 'single');
                countainsArray   = zeros(HH, 1, 'single');                
    
                for ii = 1:HH
                    NN = numel(rawColumnData_uniqueTokens{ii});
    
                    d = zeros(MM+1, NN+1);
                    d(:,1) = (0:MM)';
                    d(1,:) = 0:NN;
                    
                    % countainsCharCount: quanto maior, melhor. soma acumulada de caracteres do token que possuem na palavra digitada.
                    % blockOfCharsCount: quanto maior, melhor. número de blocos de dois caraceres da palavra digitada que possuem equivalência no token

                    countainsCharCount   = 0;                    
                    blockOfTwoCharsCount = 0;
                                        
                    for jj = 1:NN
                        for kk = 1:MM
                            if value2Search(kk) == rawColumnData_uniqueTokens{ii}(jj)
                                cost = 0;

                                % Experimento de evolução do "Método de Levenshtein"
                                % (PARTE 1)
                                countainsCharCount = countainsCharCount + 1;  
                                % Experimento de evolução do "Método de Levenshtein"
                            else
                                cost = 1;
                            end
                            d(kk+1,jj+1) = min([d(kk,jj+1)+1, d(kk+1,jj)+1, d(kk,jj)+cost]);
                        end
                    end

                    % Experimento de evolução do "Método de Levenshtein"
                    % (PARTE 2)
                    if numel(value2Search) > 1
                        for kk = 2:MM
                            blockOfTwoChars      = value2Search(kk-1:kk);
                            blockOfTwoCharsCount = blockOfTwoCharsCount + numel(strfind(rawColumnData_uniqueTokens{ii}, blockOfTwoChars));
                        end
                    end
                    % Experimento de evolução do "Método de Levenshtein"

                    LevenshteinArray(ii) = d(MM+1, NN+1);
                    blockOfTwoArray(ii)  = -blockOfTwoCharsCount;
                    countainsArray(ii)   = -countainsCharCount;
                end
                
                [~, sortedIndex] = sortrows([LevenshteinArray, blockOfTwoArray, countainsArray]);
              % [~, sortedIndex] = sort(LevenshteinArray);

                sortedTokenList  = rawColumnData_uniqueTokens(sortedIndex);
                
                % Iteração para garantir que tenhamos o NumberMaxValues...
                kk = 0;
                while numel(idxFiltered) < NumberMaxValues
                    kk = kk+1;
                    sortedTokenIndex = find(contains(rawColumnData, sortedTokenList{kk}));
                    idxFiltered = unique([idxFiltered; sortedTokenIndex], 'stable');
                end
                idxFiltered = idxFiltered(1:NumberMaxValues);
         end
    end
end


%-------------------------------------------------------------------------%
function idxFiltered = MergeProcess(idxFiltered, idxSortedData, NumberMaxValues)

    idxFiltered = unique([idxFiltered; idxSortedData], 'stable');
    idxFiltered = idxFiltered(1:min([numel(idxFiltered), NumberMaxValues]));

end