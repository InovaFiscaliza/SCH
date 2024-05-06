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

        cacheColumns  = {'Homologação', 'Solicitante | Fabricante', 'Modelo | Nome Comercial'}
        GUIColumns    = {'Homologação', 'Tipo', 'Solicitante', 'CNPJ/CPF', 'Fabricante', 'Modelo', 'Nome Comercial', 'Situação'}
        notesColumns  = {'ID', 'Data/Hora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor'}

        nMaxSuggested = 20

        tblStyle_row  = uistyle('BackgroundColor', [.96,.96,.96]);                          % Row striping
        tblStyle_col  = uistyle('BackgroundColor', [.24 .47 .85], 'FontColor', 'white');    % Table primary column background
        tblStyle_cell = uistyle('Icon', 'Edit_18x18G.png', 'IconAlignment', 'rightmargin');  % Cell annotation icon
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function fileName = DefaultFileName(userPath, Prefix, Issue)
            fileName = fullfile(userPath, sprintf('%s_%s', Prefix, datestr(now, 'yyyy.mm.dd_THH.MM.SS')));

            if Issue > 0
                fileName = sprintf('%s_%d', fileName, Issue);
            end
        end
    end
end