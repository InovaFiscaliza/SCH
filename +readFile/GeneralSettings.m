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
                % Para não perder o mapeamento de pastas...
                oldFields = fieldnames(externalFileContent.fileFolder);
                for ii = 1:numel(oldFields)
                    if isfield(projectFileContent.fileFolder, oldFields{ii})
                        projectFileContent.fileFolder.(oldFields{ii}) = externalFileContent.fileFolder.(oldFields{ii});
                    end
                end

                writematrix(jsonencode(projectFileContent, "PrettyPrint", true), externalFilePath, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite")
                
                error(['O arquivo de configuração "GeneralSettings.json", '        ...
                       'hospedado na pasta de configuração local, foi atualizado ' ...
                       'da v. %.0f para a v. %.0f'], externalFileContent.version, projectFileContent.version)
            
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