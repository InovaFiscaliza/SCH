classdef (Abstract) Variable
    methods (Static)
        %-----------------------------------------------------------------%
        function fieldValue = GeneralSettings(reportInfo, fieldName, varargin)
            projectData     = reportInfo.Project;
            context         = reportInfo.Context;
            generalSettings = reportInfo.Settings;

            switch fieldName
                case {'SEARCH+ReportTemplate', 'PRODUCTS+ReportTemplate'}
                    fieldNames = strsplit(fieldName, '+');
                    fieldValue = sprintf([ ...
                        '<span style=\"display: block; margin: 10px; margin-bottom: 20px; ' ...
                        'text-align: justify; word-break: break-all;\">CONFIGURAÇÕES:<br>' ...
                        '&#x2022;&thinsp;Módulo \"%s\": %s<br>&#x2022;&thinsp;Modelo do ' ...
                        'relatório: %s<br><br>SÍMBOLOS:<br>&#x2022;&thinsp;&#x1F6AB; ' ...
                        '(escrituração não possui lançamentos contábeis)<br>&#x2022;' ...
                        '&thinsp;&#x1F7E2; (registro encontrado na base da Receita Federal), ' ...
                        '&#x1F534; (não encontrado na base da Receita Federal) e &#x26AA; ' ...
                        '(situação indeterminada)<br>&#x2022;&thinsp;&#10133; (registro mesclado) ' ...
                        'e &#x231B; (período fiscal não anual)</span>' ...
                        ], fieldNames{1}, reportLibConnection.Variable.GeneralSettings(reportInfo, fieldNames{1}), reportLibConnection.Variable.GeneralSettings(reportInfo, 'ReportTemplate'));

                case {'SEARCH', 'PRODUCTS'}
                    fieldValue = jsonencode(generalSettings.context.(fieldName));

                case 'ReportTemplate'
                     fieldValue = jsonencode(struct('Name', reportInfo.Model.Name, 'DocumentType', reportInfo.Model.DocumentType, 'Version', reportInfo.Model.Version));

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end

        %-----------------------------------------------------------------%
        function fieldValue = CustomsShipments(reportInfo, fieldName, varargin)
            projectData = reportInfo.Project;
            
            customsShipments = projectData.customsShipments;
            reportIncludeIdx = find(arrayfun(@(x) x.UserData.ReportInclude, customsShipments), 1);

            reportContent = customsShipments(reportIncludeIdx).UserData.ReportContent;
            customsData = model.ProjectBase.applyReportContentFilter(customsShipments(reportIncludeIdx).Data, reportContent);

            switch fieldName
                case 'Total'
                    fieldValue = height(customsData);

                case {'SummarySimple', 'SummaryFluid'}
                    categoriesList = categories(categorical(customsData.("auditorDecisaoFinal")));
                    categoriesCount = countcats(categorical(customsData.("auditorDecisaoFinal")));
        
                    [categoriesCount, sortIdx] = sort(categoriesCount, 'descend');
                    categoriesList = categoriesList(sortIdx);

                    validMask = categoriesCount ~= 0;
                    categoriesList = categoriesList(validMask);
                    categoriesCount = categoriesCount(validMask);

                    switch fieldName
                        case 'SummarySimple'
                            fieldValue = cellstr(string(categoriesList) + " (" + string(categoriesCount) + ")");
                            if numel(fieldValue) > 1
                                fieldValue = strjoin({strjoin(fieldValue(1:end-1), ', '), fieldValue{end}}, ' e ');
                            end

                        otherwise % 'SummaryFluid'
                            numTotal = height(customsData);
                            numLiberados = sum(customsData.("auditorDecisaoFinal") == "Liberado");
                            numNaoLiberados = numTotal - numLiberados;

                            if numTotal == 1
                                fieldValue = 'Foi analisada <b>uma remessa de produtos</b>';
                            else
                                fieldValue = sprintf('Foram analisadas <b>%d remessas de produtos</b>', numTotal);
                            end

                            if numLiberados > 0
                                if numLiberados == 1
                                    fieldValue = sprintf('%s. A análise resultou na indicação de liberação para uma remessa', fieldValue);
                                else
                                    fieldValue = sprintf('%s. A análise resultou na indicação de liberação para %d remessas', fieldValue, numLiberados);
                                end

                                if numNaoLiberados > 0
                                    fieldValue = sprintf('%s, enquanto as demais apresentaram situações que ensejam devolução, perdimento ou concessão de prazo para regularização', fieldValue);
                                end
                            end

                            fieldValue = sprintf('%s. A sua distribuição em relação à destinação final é indicada na tabela apresentada a seguir.', fieldValue);
                    end

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end
    end
end