function GeneralSettings(appGeneral, rootFolder)
    
    if ismember(appGeneral.fileFolder.userPath, ccTools.fcn.OperationSystem('userPath'))
        appGeneral.fileFolder.userPath = '';
    end
    appGeneral.lastDocFullPath = '';

    [~, ...
     externalFolder]   = fcn.Path(rootFolder);
    fileName           = 'GeneralSettings.json';

    externalFilePath   = fullfile(externalFolder, fileName);

    try
        writematrix(jsonencode(appGeneral, 'PrettyPrint', true), externalFilePath, "FileType", "text", "QuoteStrings", "none", "WriteMode", "overwrite")
    catch
    end
    
end