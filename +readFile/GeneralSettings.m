function [generalSettings, msgError] = GeneralSettings(rootFolder)

    generalSettings    = [];
    msgError           = '';

    [projectFolder, ...
     externalFolder]   = fcn.Path(rootFolder);
    fileName           = 'GeneralSettings.json';

    projectFilePath    = fullfile(projectFolder,  fileName);
    externalFilePath   = fullfile(externalFolder, fileName);

    projectFileContent = jsondecode(fileread(projectFilePath));
    try
        % Cria a pasta externa - em "%PROGRAMDATA%\ANATEL\SCH" -, caso ainda
        % não exista. E, além disso, copia arquivos do projeto, independente 
        % das suas versões (MATLAB IDE, webapp ou desktop standalone) para a 
        % pasta externa.

        % Caso o arquivo de configurações principal - o "GeneralSettings.json"
        % - exista, verifica-se o seu versionamento. Caso o projeto possua
        % um arquivo mais recente, os antigos são salvos em subpasta "oldFiles"
        % e os novos são copiados para a pasta externa.

        if ~isfile(externalFilePath)
            if ~isfolder(externalFolder)
                mkdir(externalFolder)
            end
            copyFiles(projectFolder, externalFolder)
        
        else
            externalFileContent = jsondecode(fileread(externalFilePath));

            if projectFileContent.version > externalFileContent.version
                % Para não perder o mapeamento de pastas...
                oldFields = fieldnames(externalFileContent.fileFolder);
                for ii = 1:numel(oldFields)
                    if isfield(projectFileContent.fileFolder, oldFields{ii})
                        projectFileContent.fileFolder.(oldFields{ii}) = externalFileContent.fileFolder.(oldFields{ii});
                    end
                end

                % Cria a subpasta "oldFiles"...
                externalFolder_backup = fullfile(externalFolder, 'oldFiles');
                if ~isfolder(externalFolder_backup)
                    mkdir(externalFolder_backup)
                end

                copyFiles(externalFolder, externalFolder_backup)
                copyFiles(projectFolder, externalFolder)
                writematrix(jsonencode(projectFileContent, "PrettyPrint", true), externalFilePath, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite")
                
                error('Os arquivos de configuração do app hospedado na pasta de configuração local, incluindo "GeneralSettings.json", foram atualizados. As versões antigas dos arquivos foram salvas na subpasta "oldFiles".')
            
            else
                generalSettings = externalFileContent;
            end
        end        

    catch ME
        msgError = ME.message;
    end

    if isempty(generalSettings)
        generalSettings = projectFileContent;
    end
    generalSettings.SCHDataInfo = struct2table(generalSettings.SCHDataInfo);

end


%-------------------------------------------------------------------------%
function copyFiles(oldPath, newPath)

    jsonFiles = dir(oldPath);
    jsonFiles([jsonFiles.isdir]) = [];

    for ii = 1:numel(jsonFiles)
        jsonFilePath = fullfile(jsonFiles(ii).folder, jsonFiles(ii).name);
        copyfile(jsonFilePath, newPath, 'f');
    end

end