function appVersion = getAppVersion(requestType, rootFolder, varargin)

    arguments
        requestType char {mustBeMember(requestType, {'app', 'reportLib'})}
        rootFolder  char        
    end

    arguments (Repeating)
        varargin
    end

    appName    = class.Constants.appName;
    appRelease = class.Constants.appRelease;
    appVersion = class.Constants.appVersion;

    switch requestType
        case 'app'
            appVersion = struct('machine', '',                                      ...
                                'matlab',  '',                                      ...
                                appName,   struct('release',           appRelease,  ...
                                                  'version',           appVersion,  ...
                                                  'rootFolder',        rootFolder,  ...
                                                  'entryPointFolder',  varargin{1}, ...
                                                  'ctfRoot',           ctfroot,     ...
                                                  'tempSessionFolder', varargin{2}));
        
            % OS
            appVersion.machine = struct('platform',     ccTools.fcn.OperationSystem('platform'),     ...
                                        'version',      ccTools.fcn.OperationSystem('ver'),          ...
                                        'computerName', ccTools.fcn.OperationSystem('computerName'), ...
                                        'userName',     ccTools.fcn.OperationSystem('userName'));
        
            % OpenGL
            graphRender = '';
            try
                graphRender = opengl('data');
                graphRender = rmfield(graphRender, {'MaxTextureSize', 'Visual', 'SupportsGraphicsSmoothing', 'SupportsDepthPeelTransparency', 'SupportsAlignVertexCenters', 'Extensions', 'MaxFrameBufferSize'});
            catch
            end
        
            % MATLAB    
            [matVersion, matReleaseDate] = version;
            matProducts = struct2table(ver);
        
            appVersion.matlab = struct('version',  sprintf('%s (Release date: %s)', matVersion, matReleaseDate),   ...
                                       'pid',      feature('getpid'),                                              ...
                                       'rootPath', matlabroot,                                                     ...
                                       'products', strjoin(matProducts.Name + " v. " + matProducts.Version, ', '), ...
                                       'openGL',   graphRender);
        
            p = gcp("nocreate");
            if ~isempty(p)
                appVersion.matlab.numWorkers = p.NumWorkers;
            end

        case 'reportLib'
            rawDataTable = varargin{1};
            releaseDate  = varargin{2};
            appVersion   = struct('App', struct('name',              appName,     ...
                                                'release',           appRelease,  ...
                                                'version',           appVersion,  ...
                                                'rootFolder',        rootFolder,  ...
                                                'databaseRelease',   releaseDate, ...
                                                'databaseRows',      sprintf('%.0f', height(rawDataTable)), ...
                                                'databaseUniqueHom', sprintf('%.0f', numel(unique(rawDataTable.("Homologação"))))));
    end
end