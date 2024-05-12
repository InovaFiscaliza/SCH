function userPaths = UserPaths(rootFolder, userPath)

    userPaths = [ccTools.fcn.OperationSystem('userPath'), {userPath}];
    userPaths(~isfolder(userPaths)) = [];

    if isempty(userPaths)
        userPaths = {fullfile(rootFolder, 'Temp')};
        if ~isfolder(userPaths)
            mkdir(userPaths{1})
        end
    end

end