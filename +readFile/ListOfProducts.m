function [listOfProducts, msgWarning] = ListOfProducts(appGeneral)

    listOfProducts  = EmptyTable(appGeneral);
    msgWarning      = '';

end


%-------------------------------------------------------------------------%
function listOfProducts = EmptyTable(appGeneral)

  % columnNames    = {'Homologação', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', 'Qtd. uso/vendida', 'Qtd. estoque', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Situação', 'Infração', 'Informações adicionais'}
    columnNames    = class.Constants.listOfProductsColumns;

    listOfProducts = table('Size', [0, 16],                                                         ...
                           'VariableTypes', {'cell', 'categorical', 'cell', 'cell', 'logical',      ...
                                             'logical', 'logical', 'double', 'uint32', 'uint32',    ...
                                             'uint32', 'uint32', 'uint32', 'cell', 'cell', 'cell'}, ...
                           'VariableNames', columnNames);
    listOfProducts.("Tipo") = categorical(listOfProducts.("Tipo"), appGeneral.typeOfProduct);

end