function FilterTable = FilterColum(RootFolder,ColumDataSearch)
            
            RootFolder = RootFolder;
            ColumDataSearch = ColumDataSearch;

            app.rawSCHTable = fcn.ReadRawSCHTable(fullfile(RootFolder, 'DataBase', 'Produtos_Homologados_Anatel.csv'));
            app.rawSCHTable = app.rawSCHTable(:,[12 13 14 16 2 11 3 4 5 7 9]);
            % 
            % app.rawSCHTable_uniqueModels = fcn.PreProcessedData(app.rawSCHTable.('Nome Comercial'));
            app.rawSCHTable_uniqueModels = fcn.PreProcessedData(app.rawSCHTable{:,ColumDataSearch});
            % app.matchDistance = zeros(numel(app.rawSCHTable_uniqueModels), 1);
            % 
            % app.UITable.Data = app.rawSCHTable;
            % app.UITable.ColumnName = app.rawSCHTable.Properties.VariableNames;
            FilterTable = app.rawSCHTable_uniqueModels;
end