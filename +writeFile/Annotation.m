function Annotation(rootFolder, postCloudFolder, annotationTable)

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
        % é alterada para 2.

        idx2 = localAnnotationTable.("Situação") == 1;
        localAnnotationTable.("Situação")(idx2) = 2;

        writetable(localAnnotationTable(idx2, :), cloudFilePath)
        
    catch
        localAnnotationTable.("Situação")(idx2) = 1;
    end

    try
        writetable(localAnnotationTable, externalFilePath, 'WriteMode', 'replacefile')
    catch
    end

end