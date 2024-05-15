function [listOfProducts, msgWarning] = ListOfProducts(appGeneral)

    listOfProducts  = EmptyTable(appGeneral);
    msgWarning      = '';

end


%-------------------------------------------------------------------------%
function listOfProducts = EmptyTable(appGeneral)

  % columnNames    = {'Homologação', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', 'Qtd. uso/vendida', 'Qtd. estoque', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Situação', 'Infração', 'Informações adicionais'}
    columnNames    = class.Constants.listOfProductsColumns;

    listOfProducts = table('Size', [0, 16],                                                                                                        ...
                           'VariableTypes', [{'cell'}, {'categorical'}, repmat({'cell'}, 1, 2), repmat({'logical'}, 1, 3), repmat({'double'}, 1, 6), repmat({'cell'}, 1, 3)], ...
                           'VariableNames', columnNames);
    listOfProducts.("Tipo") = categorical(listOfProducts.("Tipo"), [{'-1'}; appGeneral.typeOfProduct]);

end