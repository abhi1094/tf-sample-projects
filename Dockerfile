# Builder stage to cache MQ installer
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder
COPY Resources/9.3.4.0-IBM-MQC-Win64/Windows/ C:/IBM-MQC-Win64/
 
# Lighter stage
FROM mcr.microsoft.com/dotnet/runtime:6.0-windowsservercore-ltsc2019
 
# Copy MQ install folder from builder stage
COPY --from=builder C:/IBM-MQC-Win64/ C:/IBM-MQC-Win64/
 
# Install IBM MQ Client
RUN msiexec /i C:\IBM-MQC-Win64\IBM MQ.msi /l*v C:\IBM-MQC-Win64\install.log /q TRANSFORMS="C:\IBM-MQC-Win64\1033.mst" AGREETOLICENSE="yes" ADDLOCAL="Client"
 
# Install JRE
RUN msiexec /i C:\IBM-MQC-Win64\IBM MQ.msi /l*v C:\IBM-MQC-Win64\install-jre.log /q ADDLOCAL=JRE
 
# Cleanup install files
RUN del C:\IBM-MQC-Win64\IBM MQ.msi /q
