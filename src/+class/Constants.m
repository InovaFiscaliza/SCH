classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'SCH'
        appRelease    = 'R2024a'
        appVersion    = '1.22.0'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function d = english2portuguese()
            names  = ["FileName", ...
                      "TempFileName", ...
                      "UF"];
            values = ["Arquivo", ...
                      "Arquivo temporário", ...
                      "Unidade da Federação"];
        
            d = dictionary(names, values);
        end
    end

end