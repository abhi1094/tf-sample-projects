# Use the official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Download and install WinSSHD (adjust the version URL as needed)
ADD https://www.bitvise.com/ssh-server-download/bitvise-ssh-server-8.48-x64-installer.exe C:\\bitvise-installer.exe
RUN Start-Process -Wait -FilePath C:\\bitvise-installer.exe -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART'

# Expose the SFTP port
EXPOSE 22

# Command to start the WinSSHD service
CMD ["C:\\Program Files (x86)\\Bitvise SSH Server\\BssCtrl.exe", "/START"]
