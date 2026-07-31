classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName = 'SCH'
        appVersion = '1.23.4'

        windowSize = [1244, 660]
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