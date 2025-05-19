function [rawDataTable, releasedData, cacheData, matFullFile] = SCHData(fileFullPath)

    matFullFile  = '';
    saveMATFile  = false;

    [filePath, ~, fileExt] = fileparts(fileFullPath);

    switch lower(fileExt)
        case '.mat'
            load(fileFullPath, 'rawDataTable', 'releasedData', 'cacheData')
        otherwise
            error('Unexpected file format')
    end

    cacheColumns = class.Constants.cacheColumns;
    if isempty(cacheData) || any(~ismember(cacheColumns, {cacheData.Column}))
        saveMATFile  = true;
        [rawDataTable, cacheData] = suggestion.CacheCreation(rawDataTable, cacheColumns);
    end

    if saveMATFile
        matFullFile = fullfile(filePath, 'SCHData.mat');
        save(matFullFile, 'rawDataTable', 'releasedData', 'cacheData')
    end

end