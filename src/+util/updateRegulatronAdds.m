function updateRegulatronAdds()
    schFilePath = "D:\OneDrive - ANATEL\InovaFiscaliza - GetPost\InovaFiscaliza - SCH (Get)\SCHData_v2.mat";
    regulatronFilePath = "C:\Users\anatel_master\Downloads\Anuncios.xlsx";
    
    % Lê a base de referência do SCH para filtrar os certificados válidos.
    sch = load(schFilePath, 'rawDataTable');
    validCertificadoSet = unique(replace(sch.rawDataTable.("Homologação"), '-', ''));

    % Lê as abas "LLM" e "Anúncio" de "Anuncios.xlsx", faz o relacionamento
    % por "key" e retorna a tabela principal com colunas selecionadas.
    llm = readtable(regulatronFilePath, "VariableNamingRule", "preserve", "Sheet", "LLM");
    anuncio = readtable(regulatronFilePath, "VariableNamingRule", "preserve", "Sheet", "Anúncio");

    addsTable = join( ...
        anuncio, llm, ...
        'Keys', 'key', ...
        'LeftVariables', {'certificado', 'data', 'marketplace', 'nome', 'vendedor', 'fabricante', 'modelo', 'características', 'preço', 'screenshot', 'url'}, ...
        'RightVariables', {'anuncio_produto_telecom', 'justificativa_produto_telecom', 'llm_model'} ...
    );

    invalidCertificadoMask = ~ismember(anuncio.certificado, validCertificadoSet);
    invalidScreenshotMask = ~endsWith(anuncio.screenshot, '.pdf');
    telecomFlagMask = ~ismember(addsTable.anuncio_produto_telecom, {'Proibido', 'Sim'});

    removeMask = invalidCertificadoMask | invalidScreenshotMask | telecomFlagMask;
    addsTable(removeMask, :) = [];

    addsTable = sortrows(addsTable, 'data', 'descend');
    [~, uniqueIdxs] = unique(addsTable.url);
    addsTable = addsTable(uniqueIdxs, :);

    addsTable = sortrows(addsTable, 'certificado');

    utilFolder = fileparts(mfilename('fullpath'));
    srcFolder = fileparts(utilFolder);
    outputFilePath = fullfile(srcFolder, 'config', 'DataBase', 'RegulatronAdds.mat');
    save(outputFilePath, 'addsTable', '-mat')
end