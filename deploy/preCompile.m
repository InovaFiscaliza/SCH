function preCompile(prjInfo)
    arguments
        prjInfo matlab.project.Project = matlab.project.Project.empty
    end

    appEngine.generateExportedApps('SCH', prjInfo)
end
