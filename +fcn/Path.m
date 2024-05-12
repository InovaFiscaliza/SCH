function [localPath, configPath] = Path(rootFolder)

    appName    = class.Constants.appName;

    localPath  = fullfile(rootFolder, 'Settings');
    configPath = fullfile(getenv('PROGRAMDATA'), 'ANATEL', appName);

end