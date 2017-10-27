# escape=`
FROM microsoft/aspnet

#Add extended powershell commandlets to get a some easy ways to do things

COPY ["./PSModules/NTFSSecurity","C:\\Program Files\\WindowsPowerShell\\Modules\\NTFSSecurity"]

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# All ready included in base image microsoft/aspnet just included for reference sake
#Install-WindowsFeature -name Web-Server -IncludeManagementTools;` 
#Install-WindowsFeature -name Web-Scripting-Tools -IncludeAllSubFeature;` 
#Install-WindowsFeature -name Web-App-Dev; `


RUN Install-WindowsFeature -Name Web-Common-Http -IncludeAllSubFeature;`
	Install-WindowsFeature -name Web-Health -IncludeAllSubFeature;`
	Install-WindowsFeature -Name Web-Performance -IncludeAllSubFeature;` 
	Install-WindowsFeature -name Web-Security -IncludeAllSubFeature;`
	Install-WindowsFeature -name Web-Mgmt-Tools -IncludeAllSubFeature;`
	Install-WindowsFeature -name Net-WCF-HTTP-Activation45;
 

# Enable Registry Key to allow IIS Remote Management
RUN powershell.exe New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force

# Create local user and include on local administrators group
RUN net user assima Pa$$w0rd /add ;`
	net localgroup administrators assima /add

# Restart IIS Services
RUN Restart-Service iisadmin,w3svc,wmsvc

# Download and install URL Rewrite
RUN New-item c:\teste -ItemType "directory" ; `
	Invoke-WebRequest https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi `
	-OutFile C:\teste\rewrite_amd64.msi ; `
	Start-Process -filepath C:\Teste\rewrite_amd64.msi -ArgumentList "/qn" -PassThru | Wait-Process
	#msiexec.exe /i c:\teste\rewrite_amd64.msi /passive /l*v log.txt
	
# Install Chocolatey set up ... choclatey in the base image will makes it easy to run nuget package installations and upgrades from the shell. 
RUN Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));`
	choco install microsoft-build-tools -y --allow-empty-checksums -version 14.0.23107.10;`
	choco install dotnet4.6-targetpack --allow-empty-checksums -y;`
	choco install nuget.commandline --allow-empty-checksums -y;`
	nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3;`
	nuget install WebConfigTransformRunner -Version 1.0.0.1

