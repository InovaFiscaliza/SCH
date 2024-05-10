function appVersion = envVersion(rootFolder)
    appName    = class.Constants.appName;
    appVersion = struct('OS',     '', ...
                        'Matlab', '', ...
                        'OpenGL', '', ...
                        appName,  struct('Release',    class.Constants.appRelease, ...
                                         'Version',    class.Constants.appVersion, ...
                                         'RootFolder', rootFolder));

    % OS
    appVersion.OS = ccTools.fcn.OperationSystem();

    % MATLAB    
    [matVersion, matReleaseDate] = version;    
    matProducts = struct2table(ver);
    appVersion.Matlab = struct('Version',  sprintf('%s (Release date: %s)', matVersion, matReleaseDate), ...
                               'Path',     matlabroot,                                                   ...
                               'Products', strjoin(matProducts.Name + " v. " + matProducts.Version, ', '));

    % OpenGL
    try
        graphRender = opengl('data');
        appVersion.OpenGL = rmfield(graphRender, {'MaxTextureSize', 'Visual', 'SupportsGraphicsSmoothing', 'SupportsDepthPeelTransparency', 'SupportsAlignVertexCenters', 'Extensions', 'MaxFrameBufferSize'});
    catch
    end
end