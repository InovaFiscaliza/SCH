classdef (Abstract) readExternalFile

    properties (Constant)
        %-----------------------------------------------------------------%
        cacheDefaultColumns = 'Homologação | Solicitante | Fabricante | Modelo | Nome Comercial'
        annotationColumns   = {'ID', 'DataHora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'}
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [type, source, variables, userData] = MAT(fileName)
            % Variável "version" será útil quando tivermos mais de uma versão,
            % tratando os dados de forma diferente.

            load(fileName, '-mat', 'version', 'type', 'source', 'variables', 'userData')
        end

        %-----------------------------------------------------------------%
        function [rawDataTable, releasedData, cacheData, cacheColumns] = SCHData(rootFolder, cloudFolder)
            fileName = 'SCHData_v2.mat';

            try
                load(fullfile(cloudFolder,                      fileName), 'rawDataTable', 'releasedData', 'cacheData')
            catch
                load(fullfile(rootFolder, 'config', 'DataBase', fileName), 'rawDataTable', 'releasedData', 'cacheData')
            end

            cacheColumns = util.readExternalFile.cacheDefaultColumns;
            if ~ismember(cacheColumns, {cacheData.Column})
                cacheColumns = cacheData(1).Column;
            end
        end

        %-----------------------------------------------------------------%
        function [annotationTable, msgWarning] = Annotation(rootFolder, cloudFolder)
            % A tabela de anotação possui colunas para identificar o responsável
            % pela inserção da informação (na ausência de login/senha, insere-se
            % os nomes do computador e do usuário).
            %
            % Possíveis valores do campo "Atributo":
            % "Fornecedor" | "Fabricante" | "Modelo" | "Outras informações" | "WordCloud"
            %
            % Todos os valores são inseridos manualmente pelo fiscal, exceto 
            % o "WordCloud", o qual é obtido de forma automática, a partir de
            % consulta ao Google/Bing.
            %
            % Possíveis valores do campo "Situação":
            % -1: Registro INATIVO na nuvem (não mais mostrado na GUI);
            %  0: Registro ATIVO na nuvem;
            %  1: Registro ATIVO na máquina local (ainda não submetido ao repositório); e
            %  2: Registro ATIVO na máquina local (já submetido ao repositório).

            annotationColumnNames = util.readExternalFile.annotationColumns;
            annotationTable = table( ...
                'Size', [0, 8], ...
                'VariableTypes', [repmat({'cell'}, 1, 7), {'double'}], ...
                'VariableNames', annotationColumnNames ...
            );
            msgWarning = '';
        
            [~, localCacheFolder] = appUtil.Path(class.Constants.appName, rootFolder);
            fileName = 'Annotation.xlsx';
        
            cloudFilePath      = fullfile(cloudFolder,      fileName);      % DataHub_GET
            localCacheFilePath = fullfile(localCacheFolder, fileName);      % C:\ProgramData\ANATEL\SCH (Windows)
        
            try
                if ~isempty(cloudFolder) && isfile(cloudFilePath)
                    annotationTable = readtable(cloudFilePath, 'VariableNamingRule', 'preserve', 'UseExcel', false);
        
                    % Validações p/ lidar com possíveis erros inseridos na consolidação 
                    % dos dados de anotação das diversas fontes.
                    if ~isequal(annotationTable.Properties.VariableNames, annotationColumnNames)
                        annotationTable = annotationTable(:, annotationColumnNames);
                    end
        
                    if ~isnumeric(annotationTable.("Situação"))
                        annotationTable.("Situação") = str2double(annotationTable.("Situação"));
                    end
        
                    % A coluna "Situação" controla os registros que serão submetidos 
                    % ao repositório do Sharepoint (POST). De forma geral, ao fechar 
                    % a sessão do app, todo registro com "Situação" = 1 será submetido 
                    % ao repositório. Ao fazer a operação abaixo, evita-se submeter
                    % registros que já constam no repositório, mas que por engano estavam
                    % com registro diferente de 0.
                    annotationTable.("Situação")(:) = 0;
                end
        
                if isfile(localCacheFilePath)
                    localCacheFileContent = readtable(localCacheFilePath, 'VariableNamingRule', 'preserve', 'UseExcel', false);
                    if ~isempty(localCacheFileContent)
                        idx = ~ismember(localCacheFileContent.ID, annotationTable.ID) & (localCacheFileContent.("Situação") ~= -1);
                        localCacheFileNewRows = localCacheFileContent(idx, :);                    
                        annotationTable = [annotationTable; localCacheFileNewRows];
                    end
                end
        
            catch ME
                msgWarning = ME.message;
            end
            
            annotationTable(annotationTable.("Situação") == -1, :) = [];
        end
    end

end