function Table = reportTable_type1(reportTable, configTable)

    columnID      = (1:height(reportTable))';
    columnProduct = "HOMOLOGAÇÃO: <b>" + string(reportTable.("Homologação")) + "</b><br>" + ...
                    "TIPO: <b>"        + string(reportTable.("Tipo"))        + "</b><br>" + ...
                    "FABRICANTE: <b>"  + string(reportTable.("Fabricante"))  + "</b><br>" + ...
                    "MODELO: <b>"      + string(reportTable.("Modelo"))      + "</b>";

    Table         = [table(columnID, columnProduct), reportTable(:, [7,9:15,17,19])];

    Table.("RF?")                    = reportLib.Constants.logical2String(Table.("RF?"), 'cellstr');
    Table.("Interferência?")         = reportLib.Constants.logical2String(Table.("Interferência?"), 'cellstr');
    Table.("Informações adicionais") = replace(Table.("Informações adicionais"), newline, '<br>');

    Table.Properties.VariableNames   = {configTable.Settings.ColumnName};

end