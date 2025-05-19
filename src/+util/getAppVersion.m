function appVersion = getAppVersion(rootFolder, entryPointFolder, temporaryDir)

    arguments
        rootFolder       char
        entryPointFolder char
        temporaryDir     char
    end

    appName = class.Constants.appName;

    appVersion = struct('machine',   '',                                              ...
                        'matlab',    '',                                              ...
                        appName,     struct('release',    class.Constants.appRelease, ...
                                            'version',    class.Constants.appVersion, ...
                                            'rootFolder', rootFolder,                 ...
                                            'entryPointFolder',  entryPointFolder,    ...
                                            'ctfRoot',           ctfroot,             ...
                                            'tempSessionFolder', temporaryDir));

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
end