classdef (Abstract) Regulatron

    methods (Static = true)
        %-----------------------------------------------------------------%
        function updateAdsTable(schFilePath, regulatronFilePath)
            arguments
                schFilePath (1, :) char = 'D:\_ANATEL - AppsDeployVersions\_Post Or Get (scarab DEV)\SCHData_v2.mat'
                regulatronFilePath (1, :) char = 'C:\Users\anatel_master\Downloads\Anuncios.xlsx'
            end

            % Lê a base de referência do SCH para filtrar os certificados válidos.
            sch = load(schFilePath, 'rawDataTable');
            validCertificadoSet = unique(replace(sch.rawDataTable.("Homologação"), '-', ''));

            % Lê as abas "LLM" e "Anúncio" de "Anuncios.xlsx", faz o relacionamento
            % por "key" e retorna a tabela principal com colunas selecionadas.
            llm = readtable(regulatronFilePath, "VariableNamingRule", "preserve", "Sheet", "LLM");
            anuncio = readtable(regulatronFilePath, "VariableNamingRule", "preserve", "Sheet", "Anúncio");

            adsTable = join( ...
                anuncio, llm, ...
                'Keys', 'key', ...
                'LeftVariables', {'certificado', 'data', 'marketplace', 'nome', 'vendedor', 'marca', 'modelo', 'características', 'preço', 'screenshot', 'url', 'imagem', 'imagens'}, ...
                'RightVariables', {'anuncio_produto_telecom', 'justificativa_produto_telecom', 'llm_model'} ...
            );

            invalidCertificadoMask = ~ismember(anuncio.certificado, validCertificadoSet);
            invalidScreenshotMask = ~endsWith(anuncio.screenshot, '.pdf');
            telecomFlagMask = ~ismember(adsTable.anuncio_produto_telecom, {'Proibido', 'Sim'});

            removeMask = invalidCertificadoMask | invalidScreenshotMask | telecomFlagMask;
            adsTable(removeMask, :) = [];

            adsTable = sortrows(adsTable, 'data', 'descend');
            [~, uniqueIdxs] = unique(adsTable.url, 'stable');
            adsTable = adsTable(uniqueIdxs, :);

            adsTable.('#') = uint32((1:height(adsTable))');
            adsTable = movevars(adsTable, '#', 'Before', 1);

            utilFolder = fileparts(mfilename('fullpath'));
            srcFolder = fileparts(utilFolder);
            outputFilePath = fullfile(srcFolder, 'config', 'DataBase', 'Regulatron.mat');
            save(outputFilePath, 'adsTable', '-mat')
        end

        %-----------------------------------------------------------------%
        function annotationTable = downloadAdsImages(annotationTable, adsTable, downloadFolder)
            % Cria a pasta de download se não existir
            if ~isfolder(downloadFolder)
                mkdir(downloadFolder);
            end

            correlationKey = char(matlab.lang.internal.uuid());

            for ii = 1:height(adsTable)
                addUrl = adsTable.url{ii};
                homologation = adsTable.certificado{ii};
                
                % A ideia é inserir o hash do certificado e da URL do anúncio 
                % para criar um nome de arquivo único para cada imagem baixada. 
                % Isso evita conflitos de nomes de arquivos quando diferentes 
                % anúncios têm imagens com o mesmo nome.
                fileHash = Hash.sha1(sprintf('%s - %s', homologation, addUrl));

                imageUrls = adsTable.imagem(ii);
                if ~isempty(adsTable.imagens{ii})
                    try
                        images = jsondecode(adsTable.imagens{ii});
                        imageUrls = [imageUrls; images];
                    catch me
                        imageUrls{end+1} = adsTable.imagens{ii};
                    end
                end                
                imageUrls = imageUrls(~cellfun('isempty', imageUrls));

                for jj = 1:numel(imageUrls)
                    imageUrl = imageUrls{jj};

                    [~, fileName, fileExt] = fileparts(imageUrl);
                    fileName = sprintf('%s_%s%s', fileHash, fileName, fileExt);
                    fileFullName = fullfile(downloadFolder, fileName);

                    if isfile(fileFullName)
                        continue
                    end

                    try
                        websave(fileFullName, imageUrl);
                        annotationTable(end+1, :) = createAnnotationFile(homologation, 'Image', fileName);
                        
                    catch ME
                        warning('Falha ao baixar %s: %s', imageUrl, ME.message);
                        continue
                    end
                end
            end

            function annotationFile = createAnnotationFile(homologation, attributeName, attributeValue)
                annotationFile = table( ...
                    {correlationKey}, ...
                    {datestr(now, 'dd/mm/yyyy HH:MM:SS')}, ...
                    {appEngine.util.OperationSystem('computerName')}, ...
                    {appEngine.util.OperationSystem('userName')}, ...
                    {homologation}, ...
                    {attributeName}, ...
                    {attributeValue}, ...
                    1, ...
                    'VariableNames', util.readExternalFile.annotationColumns ...
                );
            end
        end

        %-----------------------------------------------------------------%
        function annotationTable = fixAdsImageExtensions(annotationTable, downloadFolder)
            arguments
                annotationTable table
                downloadFolder (1, :) char
            end

            % [annotationTable, msgWarning] = util.readExternalFile.Annotation(pwd, "D:\_ANATEL - AppsDeployVersions\_Post Or Get (scarab DEV)");
            % annotationTable = util.Regulatron.fixAdsImageExtensions(annotationTable, "D:\_ANATEL - AppsDeployVersions\_Post Or Get (scarab DEV)\Images")

            d = dir(downloadFolder);
            d([d.isdir]) = [];
            imageList = {d.name};
            
            imageRowIdxs = find(strcmp(annotationTable.("Atributo"), 'Image'));
            imageCount = numel(imageRowIdxs);

            fixedImageCount = 0;
            fixedAnnotationCount = 0;
            errorCount = 0;

            for ii = 1:imageCount
                if mod(ii, 100) == 0
                    sprintf('Processando registro %d de %d...\n', ii, imageCount)
                end

                imageFile = fullfile(downloadFolder, annotationTable.("Valor"){imageRowIdxs(ii)});

                if ~isfile(imageFile)
                    imageFileIdx = find(contains(imageList, annotationTable.("Valor"){imageRowIdxs(ii)}), 1);
                    imageFile = fullfile(downloadFolder, d(imageFileIdx).name);
                end

                [~, imageName, imageExt] = fileparts(imageFile);
                imageExt = lower(extractAfter(imageExt, '.'));

                try
                    imageInfo = imfinfo(imageFile);
                    imageFormat = lower(imageInfo.Format);

                    if all(ismember({imageExt, imageFormat}, {'jpg', 'jpeg'}))
                        continue
                    end

                    if ~strcmp(imageFormat, imageExt)
                        imageNewFile = fullfile(downloadFolder, sprintf('%s.%s', imageName, imageFormat));
                        movefile(imageFile, imageNewFile);
                        fixedImageCount = fixedImageCount + 1;
                    end

                    if ~strcmp(annotationTable.("Valor"){imageRowIdxs(ii)}, sprintf('%s.%s', imageName, imageFormat))
                        annotationTable.("Valor"){imageRowIdxs(ii)} = sprintf('%s.%s', imageName, imageFormat);
                        fixedAnnotationCount = fixedAnnotationCount + 1;
                    end

                catch
                    errorCount = errorCount + 1;
                end
            end

            sprintf([ ...
                '%d imagens tiveram suas extensões corrigidas\n' ...
                '%d registros da tabela de anotação foram corrigidos\n' ...
                '%d registros de erro na tentativa de obter informações dos arquivos' ...
            ], fixedImageCount, fixedAnnotationCount, errorCount)

            if fixedImageCount > 0
                rootFolder = fileparts(fileparts(mfilename('fullpath')));
                postCloudFolder = fileparts(downloadFolder);
                util.writeExternalFile.Annotation(rootFolder, postCloudFolder, annotationTable)
            end
        end

        %-----------------------------------------------------------------%
        function deleteUnsuportedAdsImages(downloadFolder)
            arguments
                downloadFolder (1, :) char
            end

            d = dir(downloadFolder);
            d([d.isdir]) = [];

            imageList = {d.name};
            imageCount = numel(imageList);

            for ii = 1:imageCount
                if mod(ii, 1000) == 0
                    sprintf('Processando registro %d de %d...\n', ii, imageCount)
                end

                imageFile = fullfile(downloadFolder, imageList{ii});
                try
                    imfinfo(imageFile);
                catch
                    delete(imageFile);
                end
            end
        end

        %-----------------------------------------------------------------%
        function annotationTable = updateAnnotationTable(annotationTable, downloadFolder)
            arguments
                annotationTable table
                downloadFolder (1, :) char
            end

            imageRowIdxs = flip(find(strcmp(annotationTable.("Atributo"), 'Image')))';

            for ii = imageRowIdxs
                imageFile = fullfile(downloadFolder, annotationTable.("Valor"){ii});
                if ~isfile(imageFile)
                    annotationTable(ii, :) = [];
                end
            end
        end
    end

end
