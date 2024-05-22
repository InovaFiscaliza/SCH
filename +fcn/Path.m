function [settingsFolder, externalFolder, reportFolder] = Path(rootFolder)

    settingsFolder = fullfile(rootFolder, 'Settings');
    externalFolder = fullfile(getenv('PROGRAMDATA'), 'ANATEL', class.Constants.appName);
    reportFolder   = fullfile(rootFolder, '+reportLibConnection');

end