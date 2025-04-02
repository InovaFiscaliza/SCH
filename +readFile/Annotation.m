function [annotationTable, msgWarning] = Annotation(rootFolder, cloudFolder)

    annotationTable  = EmptyTable();
    msgWarning       = '';

    [~, ...
     externalFolder] = appUtil.Path(class.Constants.appName, rootFolder);
    fileName         = 'Annotation.xlsx';

    externalFilePath = fullfile(externalFolder, fileName);
    cloudFilePath    = fullfile(cloudFolder,    fileName);

    try
        if ~isempty(cloudFolder) && isfile(cloudFilePath)
            annotationTable = readtable(cloudFilePath, 'VariableNamingRule', 'preserve', 'UseExcel', false);

            % Validações p/ lidar com possíveis erros inseridos na consolidação 
            % dos dados de anotação das diversas fontes.
            if ~isequal(annotationTable.Properties.VariableNames, class.Constants.annotationTableColumns)
                annotationTable = annotationTable(:, class.Constants.annotationTableColumns);
            end

            if ~isnumeric(annotationTable.("Situação"))
                annotationTable.("Situação") = str2double(annotationTable.("Situação"));
            end

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

    annotationTable = table('Size', [0, 8],                                        ...
                            'VariableTypes', [repmat({'cell'}, 1, 7), {'double'}], ...
                            'VariableNames', class.Constants.annotationTableColumns);

end


%-------------------------------------------------------------------------%
function annotationTable = MergeTables(annotationTable, externalFilePath)

    externalFileContent = readtable(externalFilePath, 'VariableNamingRule', 'preserve', 'UseExcel', false);
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