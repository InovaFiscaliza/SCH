function Annotation(rootFolder, postCloudFolder, annotationTable, annotationBackupFlag)

    [~, ...
     externalFolder] = fcn.Path(rootFolder);

    externalFilePath = fullfile(externalFolder,  'Annotation.xlsx');
    cloudFilePath    = [class.Constants.DefaultFileName(postCloudFolder, 'Annotation', -1) '.xlsx'];

    % É salvo localmente todos os registros com o campo "Situação" igual a
    % 1 ou 2. 
    idx1 = annotationTable.("Situação") > 0;
    localAnnotationTable = annotationTable(idx1, :);

    try
        % É submetido ao repositório na nuvem apenas aqueles registros com 
        % "Situação" igual a 1. Ao submeter os dados, contudo, a "Situação" 
        % é alterada para 0, simplificando a concatenação dos dados pela rotina 
        % a ser criada no Power Automate, mas na sua versão local a "Situação"
        % é alterada para 2.

        idx2 = localAnnotationTable.("Situação") == 1;        
        if any(idx2)
            % A versão submetida à pasta do Sharepoint POST...
            localAnnotationTable.("Situação")(idx2) = 0;
            writetable(localAnnotationTable(idx2, :), cloudFilePath)
    
            % O backup local...
            localAnnotationTable.("Situação")(idx2) = 2;
        end
        
    catch
        % E se der erro mantém a "Situação" igual a 1.
        localAnnotationTable.("Situação")(idx2) = 1;
    end

    try
        if annotationBackupFlag || any(idx2)
            writetable(localAnnotationTable, externalFilePath, 'WriteMode', 'replacefile')
        end
    catch
    end

end