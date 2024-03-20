function rawTable = ReadRawSCHTable(fileFullPath)

    opts = delimitedTextImportOptions("NumVariables", 21, "Encoding", "UTF-8");
    opts.Delimiter = ";";

    opts.VariableNamingRule = "preserve";
    opts.VariableNamesLine = 1;
    opts.VariableTypes = ["datetime", "categorical", "categorical", "categorical", "char", "datetime", "datetime", "double", "categorical", "double", "categorical", "categorical", "char", "char", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical"];
    
    opts.DataLines = 2;
    
    opts = setvaropts(opts, 1, "InputFormat", "dd/MM/yyyy");
    opts = setvaropts(opts, 6, "InputFormat", "dd/MM/yyyy");
    opts = setvaropts(opts, 7, "InputFormat", "dd/MM/yyyy HH:mm:ss");

    rawTable = readtable(fileFullPath, opts);

    % Inserido esse passo porque a uitable, da GUI, escreve "missing" em
    % tela para os valores faltantes, o que fica feio.
    missingFlag = ismissing(rawTable);
    missingColumnIndex = find(sum(missingFlag));
    for ii = missingColumnIndex
        columnName = rawTable.Properties.VariableNames{ii};
        columnDataType = class(rawTable.(columnName));

        switch columnDataType
            case 'string'
                rawTable.(columnName)(missingFlag(:,ii)) = "";
            otherwise
                % nada por enquanto...
        end
    end

end