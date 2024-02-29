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


- name: run pre-commit
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: pre-commit run --all-files -v


{
    "groups": {
        "AR-SSO-TMS-Test-su": {
            "group_ids": ["c2525543-71f0-4fee-9b44-666479d60f4f", "27b52799-2e62-4ffd-ab0b-52f33f296fde"],
            "appstream": [
                            ["tps_appstream_stack", "appstream-fleet-tps"],
                            ["stack2", "fleet1"]
                            ]
        },
        "AR-SSO-TMS-Test-Sysad": {
            "group_ids": ["b5331347-221a-4260-a362-082d4560ad25", "e4135df4-8b00-4633-a553-b2704c6daa19"],
            "appstream": [
                            ["tps_appstream_stack", "appstream-fleet-tps"],
                            ["stack2", "fleet1"]
                        ]
        }
            
        }
}
