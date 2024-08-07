function [annotationTable, msgWarning] = Annotation(rootFolder, cloudFolder)

    annotationTable  = EmptyTable();
    msgWarning       = '';

    [~, ...
     externalFolder] = fcn.Path(rootFolder);
    fileName         = 'Annotation.xlsx';

    externalFilePath = fullfile(externalFolder, fileName);
    cloudFilePath    = fullfile(cloudFolder,    fileName);

    try
        if ~isempty(cloudFolder) && isfile(cloudFilePath)
            annotationTable = readtable(cloudFilePath, 'VariableNamingRule', 'preserve');

            % A coluna "Situação" controla os registros que serão submetidos 
            % ao repositório do Sharepoint (POST). De forma geral, ao fechar 
            % a sessão do app, todo registro com "Situação" = 1 será submetido 
            % ao repositório. Ao fazer a operação abaixo, evita-se submeter
            % registros que já constam no repositório, mas que por engano estavam
            % com registro diferente de 0.
            annotationTable.("Situação")(:) = 0;
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
    columnNames     = class.Constants.annotationTableColumns;

    annotationTable = table('Size', [0, 8],                                        ...
                            'VariableTypes', [repmat({'cell'}, 1, 7), {'double'}], ...
                            'VariableNames', columnNames);

end


%-------------------------------------------------------------------------%
function annotationTable = MergeTables(annotationTable, externalFilePath)

    externalFileContent = readtable(externalFilePath, 'VariableNamingRule', 'preserve');
    if ~isempty(externalFileContent)
        idx = ~ismember(externalFileContent.ID, annotationTable.ID) & (externalFileContent.("Situação") ~= -1);
        externalFileNewRows = externalFileContent(idx, :);
    
        annotationTable     = [annotationTable; externalFileNewRows];
    end

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