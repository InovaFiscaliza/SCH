function [version, SCH] = PublicLinks(rootFolder)

    fileParser = jsondecode(fileread(fullfile(rootFolder, 'Settings', 'PublicLinks.json')));
    version    = fileParser.VersionFile;
    SCH        = fileParser.SCH;

end