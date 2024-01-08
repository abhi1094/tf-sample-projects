# Use a Linux image for initial steps
FROM alpine:latest AS downloader

# Download the OpenSSH zip
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/8.1.0.0p1-Beta/OpenSSH-Win64.zip /tmp/OpenSSH.zip

# Use a Windows image for Windows-specific steps
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Create a directory for OpenSSH
RUN mkdir C:\OpenSSH

# Copy files from the downloader stage
COPY --from=downloader /tmp/OpenSSH.zip /OpenSSH.zip

# Set the working directory
WORKDIR C:\

# Extract the contents of OpenSSH.zip to C:\OpenSSH
RUN powershell -Command Expand-Archive -Path C:\OpenSSH.zip -DestinationPath C:\OpenSSH ; \
    Move-Item -Path C:\OpenSSH\OpenSSH-Win64\* -Destination C:\OpenSSH ; \
    Remove-Item -Path C:\OpenSSH.zip -Force ; \
    Remove-Item -Path C:\OpenSSH\OpenSSH-Win64 -Recurse -Force

# Expose the SFTP port
EXPOSE 22

# Start the SSHD service
CMD ["C:\\OpenSSH\\sshd.exe", "-D"]
