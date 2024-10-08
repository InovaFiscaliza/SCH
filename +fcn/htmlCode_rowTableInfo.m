function htmlContent = htmlCode_rowTableInfo(varargin)

    dataType = varargin{1};
    switch dataType
        case 'ProdutoHomologado'
            relatedSCHTable = varargin{2};
            relatedAnnotationTable = varargin{3};

            Homologacao   = char(relatedSCHTable.("Homologação")(1));
            Status        = char(relatedSCHTable.("Situação")(1));
            StatusColor   = '';
            if ismember(Status, {'Homologação Anulada', 'Homologação Cancelada', 'Homologação Suspensa', 'Requerimento - Cancelado'})
                StatusColor = ' style="color:red;"';
            end
            
            DataEmissao   = char(relatedSCHTable.("Data da Homologação")(1));
        
            certID        = char(relatedSCHTable.("Certificado de Conformidade Técnica")(1));
            certEmissao   = char(relatedSCHTable.("Data do Certificado de Conformidade Técnica")(1));
            certValidade  = char(relatedSCHTable.("Data de Validade do Certificado")(1));
            if ~strcmp(certValidade, 'NaT')
                certValidade = sprintf(', válido até %s', certValidade);
            else
                certValidade = '';
            end
        
            Solicitante   = upper(char(relatedSCHTable.("Solicitante")(1)));
            CNPJ          = char(relatedSCHTable.("CNPJ/CPF")(1));
            Fabricante    = upper(char(relatedSCHTable.("Fabricante")(1)));
            Pais          = char(relatedSCHTable.("País do Fabricante")(1));
            Tipo          = FindListOfValues(relatedSCHTable, "Tipo");
            Categoria     = char(relatedSCHTable.("Categoria do Produto")(1));
            Modelo        = FindListOfValues(relatedSCHTable, "Modelo");
            NomeComercial = FindListOfValues(relatedSCHTable, "Nome Comercial");
        
            Anotacoes     = {};
            for ii = 1:height(relatedAnnotationTable)
                value = sprintf('"%s"', relatedAnnotationTable.("Valor"){ii});
        
                if strcmp(relatedAnnotationTable.("Atributo"){ii}, 'WordCloud')
                    try
                        wordCloudInfo = jsondecode(relatedAnnotationTable.("Valor"){ii});
                        value = sprintf('%s<br><span style="color: gray;">Termo pesquisado: "%s"</span>', wordCloudInfo.cloudOfWords(2:end-1), wordCloudInfo.searchedWord);
                    catch
                    end
                end
        
                Anotacoes{end+1} = sprintf('<li>%s: %s<br><span style="color: gray; font-size: 10px;">(%s em %s)</span></li>', relatedAnnotationTable.("Atributo"){ii}, ...
                                                                                                                               value,                                   ...
                                                                                                                               relatedAnnotationTable.("Usuário"){ii},  ...
                                                                                                                               relatedAnnotationTable.("DataHora"){ii});
            end
            Anotacoes      = strjoin(Anotacoes, '');
            if isempty(Anotacoes)
                Anotacoes  = '<li>-1</li>';
            end
        
            htmlBase       = HTMLBase(dataType);
            htmlContent    = sprintf(htmlBase, Homologacao, StatusColor, upper(Status), DataEmissao, certID, certEmissao, certValidade, Solicitante, CNPJ, Fabricante, Pais, Categoria, Tipo, Modelo, NomeComercial, Anotacoes);

        case 'ProdutoNãoHomologado'
            listOfProducts = varargin{2};

            Homologacao    = char(listOfProducts.("Homologação")(1));
            Fabricante     = upper(char(listOfProducts.("Fabricante")(1)));
            if isempty(Fabricante)
                Fabricante = '(desconhecido)';
            end
            Tipo           = FindListOfValues(listOfProducts, "Tipo");
            Modelo         = FindListOfValues(listOfProducts, "Modelo");

            htmlBase       = HTMLBase(dataType);
            htmlContent    = sprintf(htmlBase, Homologacao, Fabricante, Tipo, Modelo);
    end

end


%-------------------------------------------------------------------------%
function htmlBase = HTMLBase(dataType)

    switch dataType
        case 'ProdutoHomologado'
            htmlBase = ['<!DOCTYPE html>\n' ...
                        '<html lang="pt">\n\t' ...
                            '<head>\n\t\t' ...
                                '<meta charset="UTF-8">\n\t\t' ...
                                '<style>\n\t\t\t' ...
                                    'body { font-family: Helvetica, Arial, sans-serif; margin-top: 5px; margin: 5px; text-align: justify;}\n\t\t\t' ...
                                    'ul { margin-top: 0px; list-style-position: outside; padding-left: 0; }\n\t\t\t' ...
                                    'li { text-indent: 0px; margin-left: 15px; }\n\t\t\t' ...
                                    '.ID { font-size: 16px; font-weight: bold; }\n\t\t\t' ...
                                    '.Status { font-size: 10px; }\n\t\t\t' ...
                                    '.section { margin-top: 10px; }\n\t\t\t' ...
                                    '.section-title { color: gray; font-size: 10px; }\n\t\t\t' ...
                                    '.section-value { font-size: 12px; }\n\t\t' ...
                                '</style>\n\t' ...
                            '</head>\n\t' ...
                            '<body>\n\t\t' ...
                                '<div>\n\t\t\t' ...
                                    '<span class="ID">%s</span>\n\t\t\t' ...
                                    '<span class="Status"%s>%s</span>\n\t\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Data de emissão:</div>\n\t\t\t' ...
                                    '<span class="section-value">%s</span><br>\n\t\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Certificado de Conformidade Técnica:</div>\n\t\t\t' ...
                                    '<span class="section-value">"%s", de %s%s</span><br>\n\t\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Solicitante:</div>\n\t\t\t' ...
                                    '<span class="section-value">%s</span><br>\n\t\t\t' ...
                                    '<span class="section-value">CNPJ/CPF: %s</span>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Fabricante:</div>\n\t\t\t' ...
                                    '<span class="section-value">%s</span><br>\n\t\t\t' ...
                                    '<span class="section-value">%s</span>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Categoria:</div>\n\t\t\t' ...
                                    '<span class="section-value">%s</span>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Tipo:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Modelo:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Nome Comercial:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Anotações:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t' ...
                            '</body>\n' ...
                        '</html>'];

        case 'ProdutoNãoHomologado'
            htmlBase = ['<!DOCTYPE html>\n' ...
                        '<html lang="pt">\n\t' ...
                            '<head>\n\t\t' ...
                                '<meta charset="UTF-8">\n\t\t' ...
                                '<style>\n\t\t\t' ...
                                    'body { font-family: Helvetica, Arial, sans-serif; margin-top: 5px; margin: 5px; text-align: justify;}\n\t\t\t' ...
                                    'ul { margin-top: 0px; list-style-position: outside; padding-left: 0; }\n\t\t\t' ...
                                    'li { text-indent: 0px; margin-left: 15px; }\n\t\t\t' ...
                                    '.ID { font-size: 16px; font-weight: bold; }\n\t\t\t' ...
                                    '.Status { font-size: 10px; }\n\t\t\t' ...
                                    '.section { margin-top: 10px; }\n\t\t\t' ...
                                    '.section-title { color: gray; font-size: 10px; }\n\t\t\t' ...
                                    '.section-value { font-size: 12px; }\n\t\t' ...
                                '</style>\n\t' ...
                            '</head>\n\t' ...
                            '<body>\n\t\t' ...
                                '<div>\n\t\t\t' ...
                                    '<span class="ID">%s</span>\n\t\t\t' ...
                                    '<span class="Status" style="color:red;">PRODUTO NÃO HOMOLOGADO</span>\n\t\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Fabricante:</div>\n\t\t\t' ...
                                    '<span class="section-value">%s</span><br>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Tipo:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t\t' ...
                                '<div class="section">\n\t\t\t' ...
                                '<div class="section-title">Modelo:</div>\n\t\t\t' ...
                                    '<ul><span class="section-value">%s</span></ul>\n\t\t' ...
                                '</div>\n\t\t' ...
                            '</body>\n' ...
                        '</html>'];
    end

end


%-------------------------------------------------------------------------%
function htmlList = FindListOfValues(referenceTable, columnName)

    listOfValues = setdiff(unique(referenceTable.(columnName)), {''});
    if isempty(listOfValues)
        listOfValues = '(desconhecido)';
    end

    htmlList = strjoin("<li>" + string(listOfValues) + "</li>", '');

end
