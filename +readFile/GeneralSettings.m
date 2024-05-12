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
        if ~isfolder(externalFolder)
            mkdir(externalFolder)
        end

        if ~isfile(externalFilePath)
            copyfile(projectFilePath, externalFolder, 'f');
        
        else
            externalFileContent = jsondecode(fileread(externalFilePath));

            if projectFileContent.version > externalFileContent.version
                projectFileContent.fileFolder = externalFileContent.fileFolder;

                copyfile(projectFilePath, externalFolder, 'f');
                error(['O arquivo de configuração "GeneralSettings.json", '        ...
                       'hospedado na pasta de configuração local, foi atualizado ' ...
                       'da v. %d para a v. %d'], externalFileContent.version, projectFileContent.version)
            
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

end