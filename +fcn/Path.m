function [projectFolder, externalFolder] = Path(rootFolder)

    projectFolder  = fullfile(rootFolder, 'Settings');
    externalFolder = fullfile(ccTools.fcn.OperationSystem('programData'), 'ANATEL', class.Constants.appName);

end