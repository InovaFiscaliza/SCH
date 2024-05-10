classdef (Abstract) Annotation

    methods (Static = true)
        %-----------------------------------------------------------------%
        function annotationTable = AnnotationTable()
            % A tabela de anotação possui colunas para identificar o responsável
            % pela inserção da informação (na ausência de login/senha, insere-se
            % os nomes do computador e do usuário).
            %
            % Possíveis valores do campo "Atributo":
            % "Fornecedor" | "Fabricante" | "Modelo" | "Outras informações" | "WordCloud"
            %
            % Todos os valores são inseridos manualmente pelo fiscal, exceto 
            % o "WordCloud", o qual é obtido de forma automática, a partir de
            % consulta ao Google.
            %
            % Possíveis valores do campo "Situação":
            % 0: Registro oficial excluído;
            % 1: Registro oficial inalterado; e
            % 2: Registro oficial editado ou inserido um novo registro.
            %
            % Por enquanto, não estará habilitada a exclusão do registro. E
            % a edição estará limitada ao atributo "WordCloud".


          % notesColumns    = {'ID', 'Data/Hora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'};
            columnNames     = class.Constants.notesColumns;
            tableWidth      = numel(columnNames);

            annotationTable = table('Size', [0, tableWidth],                          ...
                                    'VariableTypes', repmat({'cell'}, 1, tableWidth), ...
                                    'VariableNames', columnNames);
        end


        %-----------------------------------------------------------------%
        function [annotationTable, msgWarning] = read(Source, localFilePath, URL)
            msgWarning = '';

            try
                switch Source
                    case 'Local'
                        annotationTable = readtable(localFilePath, 'VariableNamingRule', 'preserve');                
    
                    case 'Server'
                        % Abrindo a versão local...
                        localAnnotationTable = class.Annotation.read('Local', localFilePath, URL);

                        % Baixando a versão da nuvem...
                        [filePath, fileName, fileExt] = fileparts(localFilePath);
                        cloudFilePath = fullfile(filePath, [fileName '_Cloud' fileExt]);
        
                        websave(cloudFilePath, URL)
                        cloudAnnotationTable = readtable(cloudFilePath, 'VariableNamingRule', 'preserve');
    
                        % Aplicando eventuais edições locais, que ainda não
                        % foram aplicadas à base oficial (GitHub).
                        cloudAnnotationTable = class.Annotation.LocalChanges(cloudAnnotationTable, localAnnotationTable, 0);
                        cloudAnnotationTable = class.Annotation.LocalChanges(cloudAnnotationTable, localAnnotationTable, 2);
                        annotationTable      = cloudAnnotationTable;
                end

            catch ME
                msgWarning = ME.message;
            end

            annotationTable = class.Annotation.KeepJustOneWordCloud(annotationTable);
        end


        %-----------------------------------------------------------------%
        function cloudAnnotationTable = LocalChanges(cloudAnnotationTable, localAnnotationTable, statusValue)
            idx1 = find(localAnnotationTable.("Situação") == statusValue);
            uuid = localAnnotationTable.("ID")(idx1);

            for ii = 1:numel(idx1)
                idx2 = find(strcmp(cloudAnnotationTable.("ID"), uuid{ii}), 1);
                if isempty(idx2)
                    idx2 = height(cloudAnnotationTable) + 1;                                
                end
                cloudAnnotationTable(idx2, :) = localAnnotationTable(idx1(ii), :);
            end
        end  


        %-----------------------------------------------------------------%
        function annotationTable = KeepJustOneWordCloud(annotationTable)
            wordCloudLogical = strcmp(annotationTable.("Atributo"), 'WordCloud');
            
            if any(wordCloudLogical)
                relatedTable = annotationTable(wordCloudLogical, :);
    
                [uniqueSelectedHom, ~, uniqueSelectedHomIndex] = unique(relatedTable.("Homologação"), 'stable');
                oldWordCloudUUID = {};
                for ii = 1:numel(uniqueSelectedHom)
                    idx = find(uniqueSelectedHomIndex == ii);
                    if numel(idx) > 1
                        oldWordCloudUUID = [oldWordCloudUUID; relatedTable.ID(idx(1:end-1))];
                    end
                end
    
                rowIndex = ismember(annotationTable.("ID"), oldWordCloudUUID);
                annotationTable(rowIndex, :) = [];
            end
        end


        %-----------------------------------------------------------------%
        function msgError = DataUpload(varargin)
            msgError        = '';

            % !! PENDENTE DEFINIR COMO SERÁ O UPLOAD DA INFORMAÇÃO !!
            uploadType      = varargin{1};
            annotationTable = varargin{2};

            idx = annotationTable.("Situação") == 2;
            newDataTable = annotationTable(idx,:);
            newDataTable.("Situação")(:) = 1;

            if ~isempty(annotationTable)
                try
                    switch uploadType
                        case 'Offline'
                            annotationTablePath = varargin{3};
                            writetable(newDataTable, annotationTablePath, 'WriteVariableNames', false,    ...
                                                                          'WriteMode',          'append', ...
                                                                          'AutoFitWidth',       false)
        
                        case 'Online'
                            serverRepository = varargin{3};                        
                            webwrite(serverRepository, newDataTable)
                    end

                catch ME
                    msgError = ME.message;
                end
            end
        end


        %-----------------------------------------------------------------%
        function [annotationFlag, annotationTable] = addRow(annotationTable, newRowTable, wourdCloudRefreshTag)
            annotationFlag  = true;

            selectedHom     = newRowTable.("Homologação"){1};
            attributeName   = newRowTable.("Atributo"){1};
            attributeValue  = newRowTable.("Valor"){1};

            annotationIndex = find(strcmp(annotationTable.("Homologação"), selectedHom))';

            if isempty(annotationIndex) || wourdCloudRefreshTag
                annotationTable(end+1,:) = newRowTable;

            else
                if any(strcmp(annotationTable.("Atributo")(annotationIndex), attributeName) & strcmp(annotationTable.("Valor")(annotationIndex), attributeValue))
                    annotationFlag = false;
                else
                    annotationTable(end+1,:) = newRowTable;
                end
            end
        end
    end
end