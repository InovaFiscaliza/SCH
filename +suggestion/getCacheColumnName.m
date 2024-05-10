function cacheColumnName = getCacheColumnName(tableVariableNames, columnName)

    cacheColumnName = sprintf('_%s', columnName);
    if ~ismember(cacheColumnName, tableVariableNames)
        cacheColumnName = columnName;
    end

end