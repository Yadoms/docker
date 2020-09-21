FROM mcr.microsoft.com/windows/servercore:ltsc2019
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

#Setup default shell
SHELL ["cmd", "/S", "/C"]

###################################################################
# Install VisualStudio Tools
###################################################################

# Download & Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
RUN powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_buildtools.exe', 'C:\\vs_buildtools.exe') \
    && C:\\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Workload.MSBuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
    --add Microsoft.VisualStudio.Component.VC.CLI.Support \
    --add Microsoft.VisualStudio.Component.VC.Llvm.Clang \
    --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0
 

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

