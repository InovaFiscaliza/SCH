function [annotationTable, msgWarning] = Annotation(rootFolder, postCloudFolder, annotationTable)

    msgWarning = {};

    [~, ...
     externalFolder] = appUtil.Path(class.Constants.appName, rootFolder);
    externalFilePath = fullfile(externalFolder,  'Annotation.xlsx');

    % É salvo localmente todos os registros com o campo "Situação" igual a
    % 1 ou 2. 
    idx1 = annotationTable.("Situação") == 1;
    idx2 = annotationTable.("Situação") > 0;

    try
        % É submetido ao repositório na nuvem apenas aqueles registros com 
        % "Situação" igual a 1. Ao submeter os dados, contudo, a "Situação" 
        % é alterada para 0, simplificando a concatenação dos dados pela rotina 
        % a ser criada no Power Automate, mas na sua versão local a "Situação"
        % é alterada para 2.
        if isfolder(postCloudFolder)
            cloudFilePath = [class.Constants.DefaultFileName(postCloudFolder, 'Annotation', -1) '.xlsx'];
        else
            error('Pendente mapear a pasta "SCH" do repositório "DataHub - POST". Independente disso, a anotação será registrada em <i>cache</i> local, sendo feito o seu <i>upload</i> ao repositório após o mapeamento.')
        end

        if any(idx1)
            % A versão submetida à pasta do Sharepoint POST...
            annotationTable.("Situação")(idx1) = 0;
            writetable(annotationTable(idx1,:), cloudFilePath)
    
            % O backup local...
            annotationTable.("Situação")(idx1) = 2;
        end
        
    catch ME
        % E se der erro mantém a "Situação" igual a 1.
        annotationTable.("Situação")(idx1) = 1;
        msgWarning{end+1} = ME.message;
    end

    try
        if any(idx2)
            writetable(annotationTable(idx2,:), externalFilePath, 'WriteMode', 'replacefile')
        else
            if isfile(externalFilePath)
                delete(externalFilePath)
            end
        end
    catch ME
        msgWarning{end+1} = ME.message;
    end

    msgWarning = strjoin(msgWarning, '\n');

end