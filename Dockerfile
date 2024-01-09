# Base image 
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install OpenSSH Server
RUN powershell Add-WindowsCapability -Online -Name OpenSSH.Server

# Create user and folder
RUN powershell "New-LocalUser -Name sftpuser -Description 'SFTP User' -Password (ConvertTo-SecureString -AsPlainText 'pass@123' -Force)" 
RUN mkdir C:\sftp 

# Copy config 
COPY sshd_config C:\ProgramData\ssh\sshd_config

# Open port in firewall
RUN Set-NetFirewallRule -Name sshd -NewEnabled True

# Expose port
EXPOSE 22 

# Run SSHD as entry point
CMD ["powershell", "Start-Service sshd"]
