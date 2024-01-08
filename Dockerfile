# Use the official Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set the working directory
WORKDIR C:\app

# Copy the executable file to the container
COPY your_executable_file.exe .

# Install OpenSSH
RUN powershell -Command Add-WindowsFeature OpenSSH.Server

# Expose the SSH port (default is 22)
EXPOSE 22

# Start the SSH server when the container starts
CMD ["C:\\Windows\\System32\\OpenSSH\\sshd.exe", "-D"]

# CMD ["your_executable_file.exe"]  # Uncomment this line if you want to start your executable instead of the SSH server
