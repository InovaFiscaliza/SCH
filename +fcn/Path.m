function [projectFolder, externalFolder] = Path(rootFolder)

    projectFolder  = fullfile(rootFolder, 'Settings');
    externalFolder = fullfile(getenv('PROGRAMDATA'), 'ANATEL', class.Constants.appName);

end