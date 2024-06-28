function appInfo = htmlCode_appInfo(appGeneral, rootFolder, executionMode, rawDataTable, releasedData, cacheData)

    appName       = class.Constants.appName;
    appVersion    = fcn.envVersion(rootFolder);
    cacheColumns  = ccTools.fcn.FormatString({cacheData.Column});
    [~, SCHLinks] = fcn.PublicLinks(rootFolder);

    switch executionMode
        case {'MATLABEnvironment', 'desktopStandaloneApp'}                  % MATLAB | MATLAB RUNTIME
            appMode = 'desktopApp';

        case 'webApp'                                                       % MATLAB WEBSERVER + RUNTIME
            computerName = ccTools.fcn.OperationSystem('computerName');
            if strcmpi(computerName, appGeneral.computerName.webServer)
                appMode = 'webServer';
            else
                appMode = 'deployServer';                    
            end
    end

    msgStructInfo    = struct('group', 'COMPUTADOR',            'value', struct('Machine', appVersion.Machine, 'Mode', sprintf('%s - %s', executionMode, appMode)));
    msgStructInfo(2) = struct('group', upper(appName),          'value', appVersion.(appName));
    msgStructInfo(3) = struct('group', [upper(appName) 'Data'], 'value', struct('releasedData', releasedData, 'numberOfRows', height(rawDataTable), 'numberOfUniqueHom', numel(unique(rawDataTable.("Homologação"))), 'cacheColumns', cacheColumns));
    msgStructInfo(4) = struct('group', 'MATLAB',                'value', appVersion.Matlab);

    appInfo = sprintf('<p style="text-align:justify;">O repositório das ferramentas desenvolvidas no Escritório de inovação da SFI pode ser acessado <a href="%s">aqui</a>.\n\n</p>%s', SCHLinks.Sharepoint, fcn.htmlCode_appsStyle(msgStructInfo));

end