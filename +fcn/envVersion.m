function appVersion = envVersion(rootFolder, versionType)

    arguments
        rootFolder 
        versionType = 'full'
    end

    appName = class.Constants.appName;

    switch versionType
        case 'full'
            appVersion = struct('Machine', '', ...
                                'Matlab',  '', ...
                                appName,   struct('release',    class.Constants.appRelease, ...
                                                  'version',    class.Constants.appVersion, ...
                                                  'rootFolder', rootFolder));
        
            % OS
            appVersion.Machine = struct('platform',     ccTools.fcn.OperationSystem('platform'), ...
                                        'version',      ccTools.fcn.OperationSystem('ver'),      ...
                                        'computerName', getenv('COMPUTERNAME'),                  ...
                                        'userName',     getenv('USERNAME'));
        
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
            appVersion.Matlab  = struct('version',  sprintf('%s (Release date: %s)', matVersion, matReleaseDate),   ...
                                        'rootPath', matlabroot,                                                     ...
                                        'products', strjoin(matProducts.Name + " v. " + matProducts.Version, ', '), ...
                                        'openGL',   graphRender);
        case 'reportLib'
            appVersion = struct('App', struct('name',       appName,                    ...
                                              'release',    class.Constants.appRelease, ...
                                              'version',    class.Constants.appVersion, ...
                                              'rootFolder', rootFolder));
    end

end