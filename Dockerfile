# Use a Windows base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install OpenSSH
RUN powershell -Command \
    Add-WindowsFeature SSH-Server; \
    New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force; \
    Start-Service sshd

# Create an SFTP user
RUN powershell -Command \
    New-LocalUser -Name "sftpuser" -Password (ConvertTo-SecureString -AsPlainText "sftppassword" -Force) -FullName "SFTP User" -Description "SFTP User"; \
    net localgroup administrators sftpuser /add

# Expose SFTP port
EXPOSE 22

# Start SSHD
CMD [ "sshd", "-D" ]
