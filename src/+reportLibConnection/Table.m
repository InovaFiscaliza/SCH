classdef (Abstract) Table
    methods (Static)
        %-----------------------------------------------------------------%
        function outputTable = InspectedProducts(inspectedProducts, configTable, legalSituation)
            arguments
                inspectedProducts table
                configTable       struct
                legalSituation    string {mustBeMember(legalSituation, ["any", "Irregular", "Regular"])} = "any"
            end
        
            % A tabela "inspectedProducts" possui mais de vinte colunas - 'Homologação', 
            % 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?',
            % 'Valor Unit. (R$)', 'Fonte do valor', 'Qtd. uso', 'Qtd. vendida' etc.        
            if ismember(legalSituation, ["Irregular", "Regular"])
                idx = string(inspectedProducts.("Situação")) == legalSituation;
                inspectedProducts = inspectedProducts(idx, :);
            end
        
            % Na presente função, criam-se cinco colunas calculadas:
            % - "#" 
            % - "Produto"
            % - "Qtd. vistoriadas"
            % - "Mercadoria retida (R$)"
            % - "Mercadoria vendida (R$)"        
            inspectedProducts.("#")                       = (1:height(inspectedProducts))';
            inspectedProducts.("Produto")                 = "HOMOLOGAÇÃO: <b>" + string(inspectedProducts.("Homologação")) + "</b><br>" + ...
                                                            "TIPO: <b>"        + string(inspectedProducts.("Tipo"))        + "</b><br>" + ...
                                                            "SUBTIPO: <b>"     + string(inspectedProducts.("Subtipo"))     + "</b><br>" + ...
                                                            "FABRICANTE: <b>"  + string(inspectedProducts.("Fabricante"))  + "</b><br>" + ...
                                                            "MODELO: <b>"      + string(inspectedProducts.("Modelo"))      + "</b>";
            inspectedProducts.("Qtd. vistoriadas")        = inspectedProducts.("Qtd. uso") + inspectedProducts.("Qtd. vendida") + inspectedProducts.("Qtd. estoque/aduana") + inspectedProducts.("Qtd. anunciada");
            inspectedProducts.("Mercadoria retida (R$)")  = inspectedProducts.("Valor Unit. (R$)") .* double(inspectedProducts.("Qtd. lacradas") + inspectedProducts.("Qtd. apreendidas") + inspectedProducts.("Qtd. retidas (RFB)"));
            inspectedProducts.("Mercadoria vendida (R$)") = inspectedProducts.("Valor Unit. (R$)") .* double(inspectedProducts.("Qtd. vendida"));
        
            % Por fim, são realizadas algumas transformações nos dados, como substituição 
            % de true por "Sim" e "\n" por "<br>".        
            for ii = 1:width(inspectedProducts)
                columnName = inspectedProducts.Properties.VariableNames{ii};
        
                switch columnName
                    case 'Informações adicionais'
                        for jj = 1:numel(inspectedProducts.("Informações adicionais"))
                            currentValue = inspectedProducts.("Informações adicionais"){jj};
        
                            if ~isempty(currentValue) && (ischar(currentValue) || (isstring(currentValue) && isscalar(currentValue)))
                                inspectedProducts.("Informações adicionais"){jj} = replace(currentValue, newline, '<br>');
        
                            elseif iscellstr(currentValue)
                                inspectedProducts.("Informações adicionais"){jj} = replace(strjoin(currentValue, '<br>'), newline, '<br>');
                            end
                        end
        
                    otherwise
                        if islogical(inspectedProducts.(columnName))
                            inspectedProducts.(columnName) = reportLib.Constants.logical2String(inspectedProducts.(columnName), 'cellstr');
                        end
                end
            end 
        
            % A tabela renderizada no arquivo .HTML possuirá todas as linhas da tabela
            % "listOfProducts", mas apenas as colunas definidas no arquivo .JSON que 
            % alimenta a lib "reportLib".        
            outputTable = inspectedProducts(:, configTable.Columns);
        end

        %-----------------------------------------------------------------%
        function outputTable = Summarized(inspectedProducts, configTable, legalSituation)
            arguments
                inspectedProducts table
                configTable       struct
                legalSituation    string {mustBeMember(legalSituation, ["any", "Irregular", "Regular"])} = "any"
            end
        
            % A tabela "inspectedProducts" possui mais de vinte colunas - 'Homologação', 
            % 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?',
            % 'Valor Unit. (R$)', 'Fonte do valor', 'Qtd. uso', 'Qtd. vendida' etc.        
            if ismember(legalSituation, ["Irregular", "Regular"])
                idx = string(inspectedProducts.("Situação")) == legalSituation;
                inspectedProducts = inspectedProducts(idx, :);
            end
        
            % Na presente função, sumariza-se "inspectedProducts" em função dos valores
            % de uma das suas colunas.        
            columnName   = configTable.Settings(1).ColumnName;
            columnClass  = class(inspectedProducts.(columnName));
            columnValues = inspectedProducts.(columnName);
        
            if ismember(columnClass, {'string', 'categorical'})
                columnValues = cellstr(inspectedProducts.(columnName));
            end
        
            outputTable = table('Size',          [0, 6],                                               ...
                                'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'double', 'double'}, ...
                                'VariableNames', {configTable.Settings.ColumnName});   
        
            [uniqueValues, ~, uniqueValuesIndex] = unique(columnValues, 'stable');
            for ii = 1:numel(uniqueValues)
                idx = find((ii == uniqueValuesIndex));
        
                pricePerProductStr  = {};
                for jj = idx'
                    pricePerProductStr{end+1} = sprintf('R$ %.2f (#%d)', inspectedProducts.("Valor Unit. (R$)")(jj), jj);
                end
                pricePerProductStr  = strjoin(pricePerProductStr, '<br>');
        
                unitPricePerProduct = inspectedProducts.("Valor Unit. (R$)")(idx);
                quantityPerProduct  = double(inspectedProducts.("Qtd. lacradas")(idx) + inspectedProducts.("Qtd. apreendidas")(idx) + inspectedProducts.("Qtd. retidas (RFB)")(idx));
                totalPrice = sum(unitPricePerProduct .* quantityPerProduct);
        
                if sum(quantityPerProduct)
                    meanPrice = sprintf('R$ %.2f', totalPrice/sum(quantityPerProduct));
                else
                    meanPrice = '-';
                end
        
                outputTable(ii,:)   = {
                    uniqueValues{ii},                                                              ...
                    pricePerProductStr,                                                            ...
                    char(strjoin(string(quantityPerProduct) + " (#" + string(idx) + ")", '<br>')), ...
                    meanPrice,                                                                     ...
                    sum(quantityPerProduct),                                                       ...
                    totalPrice ...
                };
            end
        end
    end
end