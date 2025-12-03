function addsTable = importRegulatronAdds()
    %---------------------------------------------------------------------%
    % Função EXPERIMENTAL, ainda não implantada no SCH. Como entrada, o
    % arquivo "Anuncios.xlsx" gerado pelo scarab com a consolidação de dados 
    % coletados pelo regulatron.
    %---------------------------------------------------------------------%

    % Bases de referência:
    global rawDataTable
    global rawAdds

    if isempty(rawDataTable)
        load("D:\OneDrive - ANATEL\InovaFiscaliza - GetPost\DEV - InovaFiscaliza (Post)\SCHData_v2.mat", 'rawDataTable')
    end

    if isempty(rawAdds)        
        rawAdds = readtable("D:\OneDrive - ANATEL\InovaFiscaliza - GetPost\InovaFiscaliza - Regulatron (Get)\Anuncios.xlsx", "VariableNamingRule", "preserve");
    end

    % Restringe dados às três colunas mais importantes e depois elimina 
    % linhas sem registros de certificado ou url...
    addsTable = rawAdds(:, {'certificado', 'pdf', 'marketplace'});
    emptyIndexes = strcmp(addsTable.certificado, '') | strcmp(addsTable.pdf, '');
    addsTable(emptyIndexes, :) = [];

    % Regex no certificado, excluindo registros que não possuem sequência 
    % de 12 números...
    certificado  = regexp(addsTable.certificado, '\d{12}', 'match');
    invalidCert  = cellfun(@(x) isempty(x), certificado);
    addsTable(invalidCert, :) = [];
    certificado(invalidCert)  = [];

    % Elimina registros duplicados...
    [~, uniqueIndexes] = unique(addsTable.pdf, 'stable');
    addsTable    = addsTable(uniqueIndexes, :);
    certificado  = certificado(uniqueIndexes);

    % Elimina registros que não estão na base de referência do SCH.
    nAddsTable   = height(addsTable);
    validSet     = replace(rawDataTable.("Homologação"), '-', '');
    validIndexes = zeros(nAddsTable, 1, 'logical');    

    parpoolCheck()
    parfor ii = 1:nAddsTable
        if ~mod(ii, 100)
            100*ii/nAddsTable
        end

        currentCertificado = certificado{ii};
        currentCertificado(~ismember(currentCertificado, validSet)) = [];

        if ~isempty(currentCertificado)
            validIndexes(ii) = true;
            certificado{ii} = strjoin(currentCertificado);
        end
    end

    addsTable   = addsTable(validIndexes, :);
    certificado = certificado(validIndexes);

    addsTable.certificado = certificado;
    addsTable = sortrows(addsTable, 'certificado');
end