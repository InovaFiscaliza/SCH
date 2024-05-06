classdef (Abstract) Annotation

    methods (Static = true)
        %-----------------------------------------------------------------%
        function annotationTable = AnnotationTable()
            annotationTable = table('Size', [0, 7],                          ...
                                    'VariableTypes', repmat({'cell'}, 1, 7), ...
                                    'VariableNames', class.Constants.notesColumns);
        end


        %-----------------------------------------------------------------%
        function annotationTable = read(varargin)
            fileOperation = varargin{1};
            fileFullPath  = varargin{2};

            switch fileOperation
                case 'Local'                    
                    annotationTable = readtable(fileFullPath, 'VariableNamingRule', 'preserve');

                case 'Server'
                    URL = varargin{3};
                    try
                        websave(fileFullPath, URL)
                        load(fileFullPath, 'annotationTable')
                    catch
                        annotationTable = class.Annotation.AnnotationTable();
                    end
            end
        end


        %-----------------------------------------------------------------%
        function [annotationTable, annotationTempTable] = KeepJustOneWordCloud(annotationTable, annotationTempTable)
            annotationFull   = [annotationTable; annotationTempTable];
            wordCloudLogical = strcmp(annotationFull.("Atributo"), 'WordCloud');
            
            if any(wordCloudLogical)
                relatedTable = annotationFull(wordCloudLogical, :);
    
                [uniqueSelectedHom, uniqueSelectedHomIndex] = unique(relatedTable.("Homologação"));
                oldWordCloudUUID = {};
                for ii = 1:numel(uniqueSelectedHom)
                    idx = uniqueSelectedHomIndex == ii;
                    if numel(idx) > 1
                        oldWordCloudUUID = [oldWordCloudUUID; relatedTable.ID(idx(1:end-1))];
                    end
                end
    
                rowIndex1 = ismember(annotationTable.("ID"),     oldWordCloudUUID);
                rowIndex2 = ismember(annotationTempTable.("ID"), oldWordCloudUUID);
    
                annotationTable(rowIndex1, :)     = [];
                annotationTempTable(rowIndex2, :) = [];
            end
        end


        %-----------------------------------------------------------------%
        function msgError = AnnotationDataUpload(varargin)
            uploadType          = varargin{1};
            annotationTempTable = varargin{2};

            try
                switch uploadType
                    case 'Offline'
                        annotationTableFileFullPath = varargin{3};
                        writetable(annotationTempTable, annotationTableFileFullPath, 'WriteVariableNames', false, ...
                                                                                     'WriteMode', 'append',       ...
                                                                                     'AutoFitWidth', false)
    
                    case 'Online'
                        serverRepository = varargin{3};                        
                        webwrite(serverRepository, annotationTempTable)
                end

                msgError = '';
            catch ME
                msgError = ME.message;
            end
        end


        %-----------------------------------------------------------------%
        function [annotationFlag, relatedTable, annotationTempTable] = addRow(annotationTable, annotationTempTable, newRowTable, ForceAdd2Cache)
            annotationFlag  = true;

            selectedHom     = newRowTable.("Homologação"){1};
            attributeName   = newRowTable.("Atributo"){1};
            attributeValue  = newRowTable.("Valor"){1};

            annotationFull  = [annotationTable; annotationTempTable];
            if ForceAdd2Cache
                annotationIndex = [];
            else
                annotationIndex = find(strcmp(annotationFull.("Homologação"), selectedHom));
            end

            if isempty(annotationIndex)
                relatedTable = newRowTable;
                annotationTempTable(end+1,:) = newRowTable;

            else
                for ii = annotationIndex'
                    if strcmp(annotationFull.("Atributo"){ii}, attributeName) && strcmp(annotationFull.("Valor"){ii}, attributeValue)
                        annotationFlag = false;
                        break
                    end
                end

                relatedTable = annotationFull(annotationIndex,:);
    
                if annotationFlag
                    relatedTable = [relatedTable; newRowTable];
                    annotationTempTable(end+1,:) = newRowTable;
                end
            end
        end
    end
end