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

                case {'Solicitação de Inspeção'; 
                      'Ação de Inspeção'; 
                      'Atividade de Inspeção';
                      'Unidade Demandante'
                      'Unidade Executante';
                      'Sede da Unidade Executante';
                      'Descrição da Atividade de Inspeção';
                      'Período Previsto da Fiscalização';
                      'Lista de Fiscais';
                      'Processo SEI'}

                    issueDetails = getOrFetchIssueDetails(projectData, projectData.modules.(context).ui.system, projectData.modules.(context).ui.issue, reportInfo.App.eFiscalizaObj);

                    if ~isempty(issueDetails)
                        switch fieldName
                            case 'Solicitação de Inspeção'
                                fieldValue = issueDetails.issueTree.solicitacao;
                            case 'Ação de Inspeção'
                                fieldValue = issueDetails.issueTree.acao;
                            case 'Atividade de Inspeção'
                                fieldValue = issueDetails.issueTree.atividade;
                            case 'Unidade Demandante'
                                issueCode  = issueDetails.issueTree.solicitacao; % 'SOL_GIDS_2024_0002'
                                fieldValue = char(regexp(issueCode, '^SOL_([^_]+)_', 'tokens', 'once'));
                            case 'Unidade Executante'
                                fieldValue = issueDetails.unit;
                            case 'Sede da Unidade Executante'
                                unit = issueDetails.unit;
                                unitIndex = find(strcmp({generalSettings.eFiscaliza.defaultValues.unitCityMapping.unit}, unit), 1);
                                if ~isempty(unitIndex)
                                    fieldValue = generalSettings.eFiscaliza.defaultValues.unitCityMapping(unitIndex).city;
                                else
                                    fieldValue = '';
                                end
                            case 'Descrição da Atividade de Inspeção'
                                fieldValue = issueDetails.description;
                            case 'Período Previsto da Fiscalização'
                                fieldValue = issueDetails.period;
                            case 'Lista de Fiscais'
                                fiscais = issueDetails.fiscais;
                                if isscalar(fiscais)
                                    fieldValue = char(fiscais);
                                else
                                    fieldValue = strjoin(strjoin(fiscais(1:end-1), ', '), fiscais(end), ' e ');
                                end
                            case 'Processo SEI'
                                fieldValue = issueDetails.sei;
                        end
                    end

                otherwise
                    error('UnexpectedFieldName')
            end
        end
    end
end