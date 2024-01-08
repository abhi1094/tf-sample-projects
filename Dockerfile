# Use the official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download and install OpenSSH (adjust the version URL as needed)
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip C:\\OpenSSH.zip
RUN Expand-Archive -Path C:\\OpenSSH.zip -DestinationPath C:\\OpenSSH ; \
    Move-Item -Path C:\\OpenSSH\\OpenSSH-Win64 -Destination C:\\OpenSSH ; \
    Remove-Item C:\\OpenSSH.zip -Force ; \
    Remove-Item -Recurse -Force C:\\OpenSSH\\*.pdf

# Expose the SFTP port
EXPOSE 22

# Start the SSHD service
CMD ["C:\\OpenSSH\\sshd.exe", "-D"]
