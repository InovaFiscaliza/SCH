classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'SCH'
        appRelease    = 'R2024a'
        appVersion    = '0.01'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]
        
        xDecimals     = 5        
        floatDiffTol  = 1e-5

        userPaths     = {fullfile(getenv('USERPROFILE'), 'Documents'); fullfile(getenv('USERPROFILE'), 'Downloads')}

        nMaxSuggested = 20
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function fileName = DefaultFileName(userPath, Prefix, Issue)
            fileName = fullfile(userPath, sprintf('%s_%s', Prefix, datestr(now,'yyyy.mm.dd_THH.MM.SS')));

            if Issue > 0
                fileName = sprintf('%s_%d', fileName, Issue);
            end
        end
    end
end