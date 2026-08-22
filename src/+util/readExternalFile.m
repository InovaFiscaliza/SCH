classdef (Abstract) readExternalFile

    properties (Constant)
        %-----------------------------------------------------------------%
        numMaxCategories    = 500
        cacheDefaultColumns = 'Homologação | Solicitante | Fabricante | Modelo | Nome Comercial'
        annotationColumns   = {'ID', 'DataHora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'}
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [schData, schDataCategories, releasedData, cacheData, cacheColumns] = SCHData(rootFolder, cloudFolder, generalSettings)
            [projectFolder, localCacheFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
            fileName = sprintf('SCHData%s.mat', generalSettings.context.SEARCH.dataBaseVersion);

            try
                cloudFilePath = fullfile(cloudFolder, fileName);
                if ~isempty(cloudFolder) && isfile(cloudFilePath)
                    load(cloudFilePath, 'schData', 'releasedData', 'cacheData')
                else
                    localCacheFilePath = fullfile(localCacheFolder, 'DataBase', fileName);
                    load(localCacheFilePath, 'schData', 'releasedData', 'cacheData')
                end
            catch
                projectFilePath = fullfile(projectFolder, 'DataBase', fileName);
                load(projectFilePath, 'schData', 'releasedData', 'cacheData')
            end

            schDataCategories = struct('columnName', {}, 'numCategories', {}, 'categories', {});

            schColumnTypes = matlab.Compatibility.resolveTableVariableTypes(schData.detailed, false);
            schColumnNames = schData.detailed.Properties.VariableNames(strcmp(schColumnTypes, 'categorical'));
            
            for ii = 1:numel(schColumnNames)
                columnName = schColumnNames{ii};
                categories = unique(cellstr(schData.detailed.(columnName)));
                categories = textAnalysis.sort(categories);
                numCategories = numel(categories);

                if numCategories > util.readExternalFile.numMaxCategories
                    categories = {};
                end

                schDataCategories(end+1) = struct( ...
                    'columnName', columnName, ...
                    'numCategories', numCategories, ...
                    'categories', {categories} ...
                );
            end

            cacheColumns = util.readExternalFile.cacheDefaultColumns;
            if ~ismember(cacheColumns, {cacheData.Column})
                cacheColumns = cacheData(1).Column;
            end
        end

        %-----------------------------------------------------------------%
        function adsTable = RegulatronData(rootFolder, cloudFolder)
            [projectFolder, localCacheFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
            fileName = 'Regulatron.mat';

            try
                cloudFilePath = fullfile(cloudFolder, fileName);
                if ~isempty(cloudFolder) && isfile(cloudFilePath)
                    load(cloudFilePath, 'adsTable');
                else
                    localCacheFilePath = fullfile(localCacheFolder, 'DataBase', fileName);
                    load(localCacheFilePath, 'adsTable');
                end
            catch
                projectFilePath = fullfile(projectFolder, 'DataBase', fileName);
                load(projectFilePath, 'adsTable');
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
        
            [~, localCacheFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
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
                        localCacheFileContent = localCacheFileContent(:, annotationColumnNames);

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

        %-----------------------------------------------------------------%
        function varargout = CustomsShipments(operationType, varargin)
            arguments
                operationType {mustBeMember(operationType, {'Rules', 'Data'})}
            end

            arguments (Repeating)
                varargin
            end

            varargout = {};

            switch operationType
                case 'Rules'
                    rootFolder = varargin{1};

                    [projectFolder, localCacheFolder] = appEngine.util.Path(class.Constants.appName, rootFolder);
                    fileName = 'CustomsRules.json';
        
                    try
                        localCacheFilePath = fullfile(localCacheFolder, fileName);
                        rules = jsondecode(fileread(localCacheFilePath, 'Encoding', 'UTF-8'));
                    catch
                        projectFilePath = fullfile(projectFolder, fileName);
                        rules = jsondecode(fileread(projectFilePath, 'Encoding', 'UTF-8'));
                    end

                    varargout{1} = rules;

                otherwise % 'Data'
                    fileName = varargin{1};
                    generalSettings = varargin{2};

                    tbl = readtable(fileName, 'VariableNamingRule', 'preserve');
        
                    requiredColumns = generalSettings.context.CUSTOMS.requiredColumns.rawFile;
                    if ~all(ismember(requiredColumns, tbl.Properties.VariableNames))
                        error('Tabela de entrada precisa ter as colunas %s', textFormatGUI.cellstr2FriendlyListWithQuotes(requiredColumns))
                    end
        
                    tbl = tbl(:, requiredColumns);
                    tbl = renamevars(tbl, requiredColumns, {'remessaCodigo', 'remessaImportador', 'remessaDescricao'});
                    
                    varargout{1} = tbl;
            end
        end
    end

end