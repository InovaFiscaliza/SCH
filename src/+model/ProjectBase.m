classdef (Abstract) ProjectBase

    % ## model.ProjectBase ##      
    % - *.*
    %   ├── INSPECTEDPRODUCTSSPECIFICATION                  (Constant)
    %   ├── WARNING_ENTRYEXIST                              (Constant)
    %   ├── WARNING_VALIDATIONSRULES                        (Constant)
    %   |── model.ProjectBase.readRegulatronData            (Static)
    %   |   ├── util.publicLink
    %   |   └── util.readExternalFile.RegulatronData
    %   ├── model.ProjectBase.computeUploadedFileHash       (Static)
    %   ├── model.ProjectBase.computeProjectHash            (Static)
    %   ├── model.ProjectBase.computeInspectedProductHash   (Static)
    %   |── model.ProjectBase.createInspectedProductsTable  (Static)
    %   └── model.ProjectBase.initializeInspectedProduct    (Static)
    %       └── model.ProjectBase.computeInspectedProductHash

    properties (Constant)
    %---------------------------------------------------------------------%
    % Lista de colunas e seus respectivos tipos que compõem a tabela
    % "inspectedProducts".
    %
    % As colunas comentadas — "Mercadoria retida (R$)", "Mercadoria vendida (R$)" 
    % e "Qtd. vistoriadas" — não fazem parte de "inspectedProducts", pois são 
    % colunas calculadas. Seus valores são aferidos antes da exportação dos dados.
    %
    % A seguir, os diferentes contextos de uso de "inspectedProducts":
    % • "vendorView" : visualização padrão da tabela no modo "auxApp.winProducts", 
    %                  apresentada na GUI como "Fornecedor | Usuário".
    % • "customsView": visualização da tabela no modo "auxApp.winProducts",
    %                  apresentada na GUI como "Aduana".
    % • "sharepoint" : planilha exportada para o SharePoint.
    % • "eFiscaliza" : planilha exportada para o eFiscaliza.
    %---------------------------------------------------------------------%
        INSPECTEDPRODUCTSSPECIFICATION = {
            'cell',        'Hash';
            'cell',        'Homologação';           % vendorView customsView sharepoint
            'cell',        'Importador';            %            customsView sharepoint
            'cell',        'Código aduaneiro';      %            customsView sharepoint
            'categorical', 'Tipo';                  % vendorView customsView sharepoint eFiscaliza
            'cell',        'Subtipo';               %                        sharepoint eFiscaliza
            'cell',        'Fabricante';            % vendorView customsView sharepoint eFiscaliza
            'cell',        'Modelo';                % vendorView customsView sharepoint eFiscaliza
            'logical',     'RF?';                   % vendorView customsView sharepoint eFiscaliza
            'logical',     'Em uso?';               % vendorView             sharepoint eFiscaliza
            'logical',     'Interferência?';        % vendorView             sharepoint eFiscaliza
            'double',      'Valor Unit. (R$)';      % vendorView customsView sharepoint eFiscaliza
            'cell',        'Fonte do valor';        % vendorView customsView sharepoint eFiscaliza
        ... 'double',      'Mercadoria retida (R$);
        ... 'double',      'Mercadoria vendida (R$);
        ... 'uint32',      'Qtd. vistoriadas';      %                                   eFiscaliza
            'uint32',      'Qtd. uso';              % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. vendida';          % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. estoque/aduana';   % vendorView customsView sharepoint eFiscaliza
            'uint32',      'Qtd. anunciada';        % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. lacradas';         % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. apreendidas';      % vendorView             sharepoint eFiscaliza
            'uint32',      'Qtd. retidas (RFB)';    % vendorView customsView sharepoint eFiscaliza
            'cell',        'Lacre';                 %                        sharepoint eFiscaliza
            'cell',        'PLAI';                  %                        sharepoint eFiscaliza
            'categorical', 'Situação';              % vendorView customsView sharepoint eFiscaliza
            'categorical', 'Infração';              % vendorView customsView sharepoint
            'categorical', 'Sanável?';              %            customsView sharepoint
            'cell',        'Informações adicionais' %                        sharepoint
        }

        WARNING_ENTRYEXIST = struct( ...
            'SEARCH', [ ...
                'O(s) registro(s) selecionado(s) já consta(m) na lista de ' ...
                'produtos sob análise.' ...
            ], ...
            'PRODUCTS', [ ...
                'Na lista de produtos sob análise já consta um produto não ' ...
                'homologado sem fabricante e modelo definidos. Inserir um ' ...
                'novo registro irá duplicá-lo. Se houver vários produtos não ' ...
                'homologados, preencha fabricante e modelo para diferenciá-los ' ...
                'e evitar duplicidades.' ...
            ] ...
        )

        WARNING_VALIDATIONSRULES = struct( ...
            'SEARCH', [], ...
            'PRODUCTS', struct( ...
                'inspectedProducts', [ ...
                    'As informações de tipo, subtipo, fabricante, modelo e situação são obrigatórias. ' ...
                    'Além disso, a soma das quantidades em uso, vendida, em estoque/aduana e ' ...
                    'anunciada deve ser maior que zero.' ...
                    '<br><br>' ...
                    'Caso evidenciada situação <b>REGULAR</b>:<br>' ...
                    '•&thinsp;Não admite infração.<br>' ...
                    '•&thinsp;Não pode haver quantidades lacradas, apreendidas ou retidas.' ...
                    '<br><br>' ...
                    'Caso evidenciada situação <b>IRREGULAR</b>:<br>' ...
                    '•&thinsp;A infração é obrigatória.<br>' ...
                    '•&thinsp;A soma das quantidades lacradas, apreendidas e retidas não pode ' ...
                    'exceder a soma das quantidades em uso e em estoque/aduana.<br>' ...
                    '•&thinsp;É obrigatória a estimativa do valor unitário, além da indicação ' ...
                    'da fonte da estimativa, como, por exemplo, nota fiscal, sistema de ' ...
                    'controle de estoque ou pesquisa de mercado.<br>' ...
                    '•&thinsp;Se a soma das quantidades lacradas e apreendidas for maior que zero, ' ...
                    'então lacre e PLAI são obrigatórios.' ...
                ], ...
                'entity', [ ...
                    '____________<br>' ...
                    'Em relação à <b>ATIVIDADE DE INSPEÇÃO</b>:<br>' ...
                    '•&thinsp;O número deve ser válido (inteiro, positivo e finito).<br><br>' ...
                    'Em relação à qualificação da <b>FISCALIZADA</b>:<br>' ...
                    '•&thinsp;O tipo não pode ser vazio;<br>' ...
                    '•&thinsp;O nome deve ser preenchido; e<br>' ...
                    '•&thinsp;O número do CPF/CNPJ deve ser válido.<br><br>' ...
                    'Por fim, em relação à <b>LISTA DE PRODUTOS SOB ANÁLISE</b>:<br>' ...
                    '•&thinsp;As informações de tipo, subtipo, fabricante, modelo e situação são obrigatórias, ' ...
                    'assim como a existência de ao menos uma quantidade informada (em uso, ' ...
                    'vendida, em estoque/aduana ou anunciada).<br>' ...
                    '•&thinsp;Em situação regular, não se admite infração nem a existência de ' ...
                    'quantidades lacradas, apreendidas ou retidas.<br>' ...
                    '•&thinsp;Já em situação irregular, a infração é obrigatória, as ' ...
                    'quantidades lacradas, apreendidas e retidas não podem exceder as ' ...
                    'quantidades em uso e em estoque/aduana, e deve ser informada a estimativa ' ...
                    'do valor unitário, acompanhada da respectiva fonte. Em sendo adotada medida ' ...
                    'cautelar conduzida por fiscais da Agência, então lacre e PLAI são obrigatórios.' ...
                ] ...
            ) ...
        );
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function data = readRegulatronData(rootFolder, cloudFolder)
            data = struct( ...
                'urlPreffix', util.publicLink(class.Constants.appName, rootFolder, 'RegulatronAdds'), ...
                'addsTable', util.readExternalFile.RegulatronData(rootFolder, cloudFolder) ...
            );
        end

        %-----------------------------------------------------------------%
        function hash = computeUploadedFileHash(system, issue, status)
            hash = Hash.sha1(strjoin({system, num2str(issue), status}, ' - '));
        end

        %-----------------------------------------------------------------%
        function prjHash = computeProjectHash(prjName, prjFile, inspectedProducts, issueDetails, entityDetails)
            inspectedProducts = sortrows(inspectedProducts, 'Hash');
            prjHash = Hash.sha1(sprintf('%s - %s - %s - %s - %s', prjName, prjFile, jsonencode(inspectedProducts), jsonencode(issueDetails), jsonencode(entityDetails)));
        end

        %-----------------------------------------------------------------%
        function hash = computeInspectedProductHash(homologation, manufacturer, model)
            hash = Hash.sha1(strjoin({homologation, manufacturer, model}, ' - '));
        end

        %-----------------------------------------------------------------%
        function inspectedProducts = createInspectedProductsTable(generalSettings)
            inspectedProducts = table( ...
                'Size', [0, height(model.ProjectBase.INSPECTEDPRODUCTSSPECIFICATION)], ...
                'VariableTypes', model.ProjectBase.INSPECTEDPRODUCTSSPECIFICATION(:, 1), ...
                'VariableNames', model.ProjectBase.INSPECTEDPRODUCTSSPECIFICATION(:, 2) ...
            );
            
            inspectedProducts.("Tipo")     = categorical(inspectedProducts.("Tipo"),     generalSettings.ui.typeOfProduct.options);
            inspectedProducts.("Situação") = categorical(inspectedProducts.("Situação"), generalSettings.ui.typeOfSituation.options);
            inspectedProducts.("Infração") = categorical(inspectedProducts.("Infração"), generalSettings.ui.typeOfViolation.options);
            inspectedProducts.("Sanável?") = categorical(inspectedProducts.("Sanável?"), {'-', 'Sim', 'Não'});
        end

        %-----------------------------------------------------------------%
        function inspectedProducts = validateCategoricalColumns(inspectedProducts, generalSettings)
            categoricalColumns = {'Tipo', 'Situação', 'Infração', 'Sanável?'};

            inspectedProducts = convertvars( ...
                inspectedProducts, ...
                categoricalColumns, ...
                'categorical' ...
            );

            for ii = 1:numel(categoricalColumns)
                column = categoricalColumns{ii};
                
                switch column
                    case 'Tipo'
                        columnSpec = generalSettings.ui.typeOfProduct;
                    case 'Situação'
                        columnSpec = generalSettings.ui.typeOfSituation;
                    case 'Infração'
                        columnSpec = generalSettings.ui.typeOfViolation;
                    case 'Sanável?'
                        columnSpec = struct('options', {{'-', 'Sim', 'Não'}}, 'default', '-');
                end

                invalidIndexes = ~ismember(inspectedProducts.(column), columnSpec.options);
                if any(invalidIndexes)
                    inspectedProducts.(column)(invalidIndexes) = categorical(columnSpec.default);
                end
            end
        end

        %-----------------------------------------------------------------%
        function [productData, productHash] = initializeInspectedProduct(status, generalSettings, varargin)
            arguments
                status char {mustBeMember(status, {'NãoHomologado', 'Homologado', 'LegacyProject'})}
                generalSettings
            end

            arguments (Repeating)
                varargin
            end

            productType = generalSettings.ui.typeOfProduct.default;
            subtype     = '-';
            situation   = generalSettings.ui.typeOfSituation.default;
            violation   = generalSettings.ui.typeOfViolation.default;
            corrigible  = '-';

            switch status
                case 'NãoHomologado'
                    homologation = '-';
                    manufacturer = '';
                    modelName    = '';
                    optionalNote = '';

                    productHash = model.ProjectBase.computeInspectedProductHash( ...
                        homologation, ...
                        manufacturer, ...
                        modelName ...
                    );

                case 'Homologado'
                    rawDataTable = varargin{1};
                    indexRow = varargin{2};

                    homologation = rawDataTable.("Homologação"){indexRow};
                    
                    productHash = model.ProjectBase.computeInspectedProductHash( ...
                        homologation, ...
                        strjoin({rawDataTable.("Solicitante"){indexRow}, rawDataTable.("Fabricante"){indexRow}}, ' - '), ...
                        strjoin({rawDataTable.("Modelo"){indexRow}, rawDataTable.("Nome Comercial"){indexRow}}, ' - ') ...
                    );

                    manufacturer = upper(rawDataTable.("Fabricante"){indexRow});

                    modelList = unique([rawDataTable.("Modelo")(indexRow), rawDataTable.("Nome Comercial")(indexRow)], 'stable');
                    modelList(cellfun(@(x) isempty(x), modelList)) = [];
                    if isempty(modelList)
                        modelList = {''};
                        modelName = '';
                    else
                        modelName = strjoin(modelList, ' - ');
                    end            

                    indexHom = strcmp(rawDataTable.("Homologação"), homologation);
                    typeList = unique(cellstr(rawDataTable.("Tipo")(indexHom)));
                    optionalNote  = sprintf('TIPO: %s', textFormatGUI.cellstr2ListWithQuotes(typeList, 'none'));
                    if numel(modelList) > 1
                        optionalNote = sprintf('%s\nMODELO: %s', optionalNote, textFormatGUI.cellstr2ListWithQuotes(modelList, 'none'));
                    end

                case 'LegacyProject'
                    homologation = varargin{1};
                    productType  = varargin{2};
                    subtype      = varargin{3};
                    manufacturer = varargin{4};
                    modelName    = varargin{5};
                    situation    = varargin{6};
                    violation    = varargin{7};
                    corrigible   = varargin{8};
                    optionalNote = varargin{9};

                    productHash = model.ProjectBase.computeInspectedProductHash( ...
                        homologation, ...
                        manufacturer, ...
                        modelName ...
                    );
            end

            productData = {
                'Hash', productHash;
                'Homologação', homologation;
                'Tipo', productType;
                'Subtipo', subtype;
                'Fabricante', manufacturer;
                'Modelo', modelName;
                'Situação', situation;
                'Infração', violation;
                'Sanável?', corrigible;
                'Informações adicionais', optionalNote
            };

            % Por fim, identificam-se colunas do tipo "cell" que são inicializadas 
            % como [] (numérico), mas que no contexto atual precisam ser inicializadas 
            % como '' (texto).
            cellColumnIndexes = strcmp(model.ProjectBase.INSPECTEDPRODUCTSSPECIFICATION(:, 1), 'cell');
            cellColumnNames = model.ProjectBase.INSPECTEDPRODUCTSSPECIFICATION(cellColumnIndexes, 2);
            uninitializedColumns = setdiff(cellColumnNames, productData(:, 1), 'stable');

            if ~isempty(uninitializedColumns)
                productData = [ ...
                    productData; ...
                    [uninitializedColumns, repmat({''}, numel(uninitializedColumns), 1)] ...
                ];
            end
        end
    end
    
end