classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName       = 'SCH'
        appRelease    = 'R2024a'
        appVersion    = '0.85'

        windowSize    = [1244, 660]
        windowMinSize = [ 880, 660]
        
        xDecimals     = 5
        floatDiffTol  = 1e-5

        % uistyle
        configStyle1  = uistyle('BackgroundColor', [.96,.96,.96])                                                           % Search table "row striping"
        configStyle2  = uistyle('BackgroundColor', [.24 .47 .85], 'FontColor', 'white')                                     % Search table "primary column background"
        configStyle3  = uistyle('Icon', 'Edit_18x18White2.png', 'IconAlignment', 'rightmargin')                             % Search table "cell annotation icon - Type1"
        configStyle4  = uistyle('Icon', 'Edit_18x18Gray2.png',  'IconAlignment', 'rightmargin')                             % Search table "cell annotation icon - Type2"
        configStyle5  = uistyle('Icon', 'Lock1_18Gray.png', 'FontColor', [.65,.65,.65], 'IconAlignment', 'leftmargin')      % Config uitree (Search table)
        configStyle6  = uistyle('Icon', 'Warn_18.png',  'IconAlignment', 'rightmargin')                                     % Incomplete data (Report table)
        configStyle7  = uistyle('BackgroundColor', '#c80b0f', 'FontColor', 'white')                                         % Incomplete data (Report table)

        % app.cacheData
        cacheColumns              = {'Homologação', 'Solicitante | Fabricante', 'Modelo | Nome Comercial'}

        % app.annotationTable & app.listOfProducts
        annotationTableColumns    = {'ID', 'DataHora', 'Computador', 'Usuário', 'Homologação', 'Atributo', 'Valor', 'Situação'}
        listOfProductsColumns     = {'Homologação', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', ...
                                     'Qtd. uso/vendida', 'Qtd. estoque', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Situação', 'Infração', 'Informações adicionais'}

        % app.report_Table (GUI)        
        report_TableColumnNames   = {'Homologação', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', ...
                                     'Qtd. uso/vendida', 'Qtd. estoque', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)'}
        report_TableColumnWidths  = {110, 300, 'auto', 150, 'auto', 'auto', 'auto', 110, 110, 110, 110, 110, 110}

        report_TableColumns2CSV   = {'Homologação', 'Tipo', 'Fabricante', 'Modelo', 'RF?', 'Em uso?', 'Interferência?', 'Valor Unit. (R$)', ...
                                     'Qtd. uso/vendida', 'Qtd. estoque', 'Qtd. lacradas', 'Qtd. apreendidas', 'Qtd. retidas (RFB)', 'Situação', 'Infração'}
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function fileName = DefaultFileName(userPath, Prefix, Issue)
            fileName = fullfile(userPath, sprintf('%s_%s', Prefix, datestr(now, 'yyyy.mm.dd_THH.MM.SS')));

            if Issue > 0
                fileName = sprintf('%s_%d', fileName, Issue);
            end
        end


        %-----------------------------------------------------------------%
        function d = english2portuguese()
            % !! PONTO DE EVOLUÇÃO !!
            % Pendente identificar chaves em inglês aplicáveis ao SCH...
            names  = ["Azimuth", ...
                      "File", ...
                      "Frequency", ...
                      "Height", ...
                      "nSweeps"];
            values = ["Azimute", ...
                      "Arquivo", ...
                      "Frequência", ...
                      "Altura", ...
                      "Qtd. varreduras"];
            % !! PONTO DE EVOLUÇÃO !!
        
            d = dictionary(names, values);
        end


        %-----------------------------------------------------------------%
        function d = listOfProductsColumnNames()
            names  = [ "RF?", ...
                       "Qtd uso/vendida", ...
                       "Qtd estoque", ...
                       "Interferência?", ...
                       "Qtd lacradas", ...
                       "Qtd apreendidas", ...
                       "Qtd retidas (RFB)"];
            values = [ "Usa radiofrequência?", ...
                       "Qtd. unidades em uso/comercializadas", ...
                       "Qtd. unidades em estoque", ...
                       "Evidenciada interferência?", ...
                       "Qtd. unidades lacradas", ...
                       "Qtd. unidades apreendidas", ...
                       "Qtd. unidades retidas (RFB)"];
        
            d = dictionary(names, values);
        end
    end
end