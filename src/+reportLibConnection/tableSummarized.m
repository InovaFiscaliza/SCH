function outputTable = tableSummarized(listOfProducts, configTable)

    % A tabela "listOfProducts" possui na presente data (21/05/2025) vinte
    % e uma colunas, conforme exposto abaixo.

    % listOfProducts = table('Size',          [0, 21],                                                                                                                                                                                                                        ...
    %                        'VariableTypes', {'cell', 'cell', 'cell', 'categorical', 'cell', 'cell', 'logical', 'logical', 'logical', 'double', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'categorical', 'categorical', 'categorical', 'cell'},  ...
    %                        'VariableNames', {'Homologação', 'Importador', 'Código aduaneiro', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', 'Qtd. uso', 'Qtd. vendida', 'Qtd. estoque/aduana', 'Qtd. anunciada', 'Qtd. lacradas', ... 
    %                                          'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Situação', 'Infração', 'Sanável?', 'Informações adicionais'});

    columnName   = configTable.Settings(1).ColumnName;
    columnClass  = class(listOfProducts.(columnName));
    columnValues = listOfProducts.(columnName);

    if ismember(columnClass, {'string', 'categorical'})
        columnValues = cellstr(listOfProducts.(columnName));
    end

    outputTable = table('Size',          [0, 6],                                               ...
                        'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'double', 'double'}, ...
                        'VariableNames', {configTable.Settings.ColumnName});   

    [uniqueValues, ~, uniqueValuesIndex] = unique(columnValues, 'stable');
    for ii = 1:numel(uniqueValues)
        idx = find((ii == uniqueValuesIndex));

        pricePerProductStr  = {};
        for jj = idx'
            pricePerProductStr{end+1} = sprintf('R$ %.2f (#%d)', listOfProducts.("Valor Unit. (R$)")(jj), jj);
        end
        pricePerProductStr  = strjoin(pricePerProductStr, '<br>');

        unitPricePerProduct = listOfProducts.("Valor Unit. (R$)")(idx);
        quantityPerProduct  = double(listOfProducts.("Qtd. lacradas")(idx) + listOfProducts.("Qtd. apreendidas")(idx) + listOfProducts.("Qtd. retidas (RFB)")(idx));
        totalPrice          = sum(unitPricePerProduct .* quantityPerProduct);

        if sum(quantityPerProduct)
            meanPrice       = sprintf('R$ %.2f', totalPrice/sum(quantityPerProduct));
        else
            meanPrice       = '-';
        end

        outputTable(ii,:)   = {uniqueValues{ii},                                                              ...
                               pricePerProductStr,                                                            ...
                               char(strjoin(string(quantityPerProduct) + " (#" + string(idx) + ")", '<br>')), ...
                               meanPrice,                                                                     ...
                               sum(quantityPerProduct),                                                       ...
                               totalPrice};
    end
end