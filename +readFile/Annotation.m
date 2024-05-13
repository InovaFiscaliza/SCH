function [annotationTable, msgWarning] = Annotation(rootFolder, getCloudFolder)

    annotationTable  = EmptyTable();
    msgWarning       = '';

    [~, ...
     externalFolder] = fcn.Path(rootFolder);
    fileName         = 'Annotation.xlsx';

    externalFilePath = fullfile(externalFolder, fileName);
    cloudFilePath    = fullfile(getCloudFolder, fileName);

    try
        if ~isempty(getCloudFolder) && isfile(cloudFilePath)
            annotationTable = readtable(cloudFilePath, 'VariableNamingRule', 'preserve');
        end

        if isfile(externalFilePath)
            annotationTable = MergeTables(annotationTable, externalFilePath);
        end

    catch ME
        msgWarning = ME.message;
    end

    annotationTable = KeepOnlyValidRows(annotationTable);
    annotationTable = KeepJustLastWordCloud(annotationTable);

end


%-------------------------------------------------------------------------%
function annotationTable = EmptyTable()

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
    % -1: Registro INATIVO na nuvem (não mais mostrado na GUI);
    %  0: Registro ATIVO na nuvem;
    %  1: Registro ATIVO na máquina local (ainda não submetido ao repositório); e
    %  2: Registro ATIVO na máquina local (já submetido ao repositório).
    %
    % Por enquanto, não estará habilitada a exclusão do registro. E
    % a edição estará limitada ao atributo "WordCloud".

  % columnNames     = {'ID', 'DataHora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'};
    columnNames     = class.Constants.notesColumns;

    annotationTable = table('Size', [0, 8],                                        ...
                            'VariableTypes', [repmat({'cell'}, 1, 7), {'double'}], ...
                            'VariableNames', columnNames);

end


%-------------------------------------------------------------------------%
function annotationTable = MergeTables(annotationTable, externalFilePath)

    externalFileContent = readtable(externalFilePath, 'VariableNamingRule', 'preserve');
    
    idx = ~ismember(externalFileContent.ID, annotationTable.ID) & (externalFileContent.("Situação") ~= -1);
    externalFileNewRows = externalFileContent(idx, :);

    annotationTable     = [annotationTable; externalFileNewRows];

end


%-----------------------------------------------------------------%
function annotationTable = KeepOnlyValidRows(annotationTable)

    idx = annotationTable.("Situação") ~= -1;
    annotationTable = annotationTable(idx, :);

end


%-----------------------------------------------------------------%
function annotationTable = KeepJustLastWordCloud(annotationTable)

    wordCloudLogical = strcmp(annotationTable.("Atributo"), 'WordCloud');
    
    if any(wordCloudLogical)
        relatedTable = annotationTable(wordCloudLogical, :);

        [uniqueSelectedHom, ~, uniqueSelectedHomIndex] = unique(relatedTable.("Homologação"), 'stable');
        oldWordCloudUUID = {};
        for ii = 1:numel(uniqueSelectedHom)
            idx1 = find(uniqueSelectedHomIndex == ii);

            if numel(idx1) > 1
                oldWordCloudUUID = [oldWordCloudUUID; relatedTable.ID(idx1(1:end-1))];
            end
        end

        idx2 = ismember(annotationTable.ID, oldWordCloudUUID);
        annotationTable(idx2,:) = [];
    end

end