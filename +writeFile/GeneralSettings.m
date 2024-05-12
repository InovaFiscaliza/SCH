function GeneralSettings(appGeneral, rootFolder)
    
    if ismember(appGeneral.userPath, ccTools.fcn.OperationSystem('userPath'))
        appGeneral.userPath = '';
    end

    [~, ...
     externalFolder]   = fcn.Path(rootFolder);
    fileName           = 'GeneralSettings.json';

    externalFilePath   = fullfile(externalFolder, fileName);

    try
        writematrix(jsonencode(appGeneral, 'PrettyPrint', true), externalFilePath, "FileType", "text", "QuoteStrings", "none")
    catch
    end
    
end