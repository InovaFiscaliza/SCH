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

            customsData = [];
            if ~isempty(reportIncludeIdx)
                customsData = customsShipments(reportIncludeIdx).Data;
            end

            if isempty(customsData)
                error('reportLibConnection:Variable:UnexpectedEmptyTable', 'Unexpected empty table')
            end

            switch fieldName
                case 'Total'
                    fieldValue = height(customsData);

                case 'DestinationSummary'
                    categoriesList = categories(categorical(customsData.("auditorDecisaoFinal")));
                    categoriesCount = countcats(categorical(customsData.("auditorDecisaoFinal")));
        
                    [categoriesCount, sortIdx] = sort(categoriesCount, 'descend');
                    categoriesList = categoriesList(sortIdx);

                    validMask = categoriesCount ~= 0;
                    categoriesList = categoriesList(validMask);
                    categoriesCount = categoriesCount(validMask);

                    fieldValue = cellstr(string(categoriesList) + " (" + string(categoriesCount) + ")");
                    if numel(fieldValue) > 1
                        fieldValue = strjoin({strjoin(fieldValue(1:end-1), ', '), fieldValue{end}}, ' e ');
                    end

                otherwise
                    error('reportLibConnection:Variable:UnexpectedFieldName', 'Unexpected field name "%s"', fieldName)
            end
        end
    end
end