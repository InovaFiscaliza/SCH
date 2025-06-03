classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'SCH'
        appRelease    = 'R2024a'
        appVersion    = '1.01.4'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]
        
        xDecimals     = 5
        floatDiffTol  = 1e-5

        % uistyle
        configStyle1  = uistyle('BackgroundColor', [.96,.96,.96])                                                           % Search table "row striping"
        configStyle2  = uistyle('BackgroundColor', [.24 .47 .85], 'FontColor', 'white')                                     % Search table "primary column background"
        configStyle3  = uistyle('Icon', 'Edit_18x18White2.png', 'IconAlignment', 'rightmargin')                             % Search table "cell annotation icon - Type1"
        configStyle4  = uistyle('Icon', 'Edit_36.png',  'IconAlignment', 'rightmargin')                                     % Search table "cell annotation icon - Type2"
        configStyle5  = uistyle('Icon', 'Lock1_18Gray.png', 'FontColor', [.65,.65,.65], 'IconAlignment', 'leftmargin')      % Config uitree (Search table)
        configStyle6  = uistyle('Icon', 'Warn_18.png',  'IconAlignment', 'rightmargin')                                     % Incomplete data (Report table)
        configStyle7  = uistyle('BackgroundColor', '#c80b0f', 'FontColor', 'white')                                         % Incomplete data (Report table)

        % app.cacheData
        cacheColumns              = {'Homologação', 'Solicitante | Fabricante', 'Modelo | Nome Comercial'}

        % app.annotationTable
        annotationTableColumns    = {'ID', 'DataHora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'}
    end

end