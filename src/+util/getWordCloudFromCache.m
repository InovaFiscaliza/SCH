function [wordCloudTable, wordCloudInfo] = getWordCloudFromCache(wordCloudAnnotation)

    wordCloudInfo = jsondecode(wordCloudAnnotation);
    
    [s, d] = ccTools.fcn.jsonDecode(wordCloudInfo.cloudOfWords);
    wordCloudTable = table(replace(string(fieldnames(s)), d.values, d.keys), cell2mat(struct2cell(s)), 'VariableNames', {'Word', 'Count'});

end