# Use the official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download and install OpenSSH
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/8.1.0.0p1-Beta/OpenSSH-Win64.zip C:\\OpenSSH.zip

# Create a directory for OpenSSH
RUN mkdir C:\OpenSSH

# Set the working directory
WORKDIR C:\

# Extract the contents of OpenSSH.zip to C:\OpenSSH
RUN powershell -Command Expand-Archive -Path C:\OpenSSH.zip -DestinationPath C:\OpenSSH ; \
    Move-Item -Path C:\OpenSSH\OpenSSH-Win64\* -Destination C:\OpenSSH ; \
    Remove-Item -Path C:\OpenSSH.zip -Force ; \
    Remove-Item -Path C:\OpenSSH\OpenSSH-Win64 -Recurse -Force

# Expose the SFTP port
EXPOSE 22

# Display contents of the OpenSSH directory for debugging
RUN Get-ChildItem -Path C:\OpenSSH -Recurse

# Start the SSHD service
CMD ["C:\\OpenSSH\\sshd.exe", "-D"]
