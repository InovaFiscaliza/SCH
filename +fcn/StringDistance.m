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

                dists = zeros(numel(rawColumnData_uniqueTokens), 1, 'single');
                iquals = zeros(numel(rawColumnData_uniqueTokens), 1, 'single');
                acums = zeros(numel(rawColumnData_uniqueTokens), 1, 'single');
                dists_iquals_acums = [];
                matriz_ordenada = [];
                matriz_total =[];
                ok=0;
    
                for ii = 1:HH
                    NN = numel(rawColumnData_uniqueTokens{ii});
    
                    d = zeros(MM+1, NN+1);
                    d(:,1) = (0:MM)';
                    d(1,:) = 0:NN;
                    
                    Iqual = 0;
                    ActualValue = 0;
                    DifValue = 0;
                    LastValue = 1;
                    AcumValue = 0;
                    for jj = 1:NN
                        for kk = 1:MM
                            if value2Search(kk) == rawColumnData_uniqueTokens{ii}(jj)
                                Iqual = Iqual + 1;
                                ActualValue = kk;
                                DifValue = ActualValue - LastValue;
                                if DifValue == 1
                                    AcumValue = AcumValue+1;
                                    LastValue = ActualValue;
                                end

                                cost = 0;
                            else
                                cost = 1;
                            end
                            d(kk+1,jj+1) = min([d(kk,jj+1)+1, d(kk+1,jj)+1, d(kk,jj)+cost]);
                        end
                    end

                    dists(ii) = d(MM+1,NN+1);
                    iquals(ii) = abs(NN - Iqual);
                    acums(ii) = abs(MM - AcumValue);
                end
                
                  dists_iquals_acums = [dists, acums, iquals];
                  [~, matriz_ordenada_index] = sortrows(dists_iquals_acums, [1, 2, 3]);
      
                % [~, sortedIndex] = sort(dists);
                sortedIndex = matriz_ordenada_index;
                sortedTokenList  = rawColumnData_uniqueTokens(sortedIndex);
                
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