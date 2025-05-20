function [type, source, variables, userData] = MAT(fileName)

    load(fileName, '-mat', 'version', 'type', 'source', 'variables', 'userData')
    
    % Variável "version" será útil quando tivermos mais de uma versão,
    % tratando os dados de forma diferente.

end