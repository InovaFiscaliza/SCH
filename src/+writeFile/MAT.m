function msgError = MAT(fileName, type, source, variables, userData)
    
    version = 1;
    
    try
        save(fileName, 'version', 'type', 'source', 'variables', 'userData', '-v7.3', '-nocompression')
        msgError = '';
    catch ME
        msgError = ME.message;
    end

end