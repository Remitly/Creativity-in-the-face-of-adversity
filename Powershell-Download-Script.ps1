$OutputLocation = $env:TEMP + "\osquery4.5.1.msi"
$OSQueryURL = "https://pkg.osquery.io/windows/osquery-4.5.0.msi"
$OSQueryPath = $env:ProgramFiles + "\osquery"
$OSQuerySecretFile = $OSQueryPath + "\________INSERT_____FLEET_SECRET_FILE____.txt"
$OSQueryFlagFile = $OSqueryPath + "\osquery.flags"
$OSQuerySecret = "____INSERT_____SECRET_________"
$OSQueryFlags= "
--enroll_secret_path=______INSERT____SECRET____LOCATION_____
--tls_hostname=_____INSERT___OSQUERY____URL______
--host_identifier=uuid
--enroll_tls_endpoint=/api/v1/osquery/enroll
--config_plugin=tls
--config_tls_endpoint=/api/v1/osquery/config
--config_refresh=10
--disable_distributed=false
--distributed_plugin=tls
--distributed_interval=10
--distributed_tls_max_attempts=3
--distributed_tls_read_endpoint=/api/v1/osquery/distributed/read
--distributed_tls_write_endpoint=/api/v1/osquery/distributed/write
--logger_plugin=tls
--logger_tls_endpoint=/api/v1/osquery/log
--logger_tls_period=10
--disable_events=false
--disable_forensic=false
--enable_windows_events_publisher=true
--enable_windows_events_subscriber=true
--windows_events_channel=System,Application,Setup,Security,Microsoft-Windows-PowerShell
--windows_event_channels=Microsoft-Windows-PowerShell/Operational
"

# Install OSQuery if not already installed
If (-Not (Test-Path -Path $OSQueryFlagFile -ErrorAction SilentlyContinue)){
    Write-Output "Getting Ready To Install"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $OSQueryURL -OutFile $OutputLocation
    Start-Process -FilePath $OutputLocation -Wait -ArgumentList "/quiet", "/promptrestart"
    New-Item -Path $OSQuerySecretFile -Force -ErrorAction SilentlyContinue
    Set-Content -Path $OSQuerySecretFile -Value $OSQuerySecret
    New-Item -Path $OSQueryFlagFile -Force -ErrorAction SilentlyContinue
    Set-Content -Path $OSQueryFlagFile -Value $OSQueryFlags
} Else {
    Write-Output "Already Installed, Updating Configuration"
    $OSQueryFlags | Out-File -FilePath $OSQueryFlagFile
}

Write-Output "Restarting Service"
Set-Service -Name osqueryd -Status Stopped
Set-Service -Name osqueryd -Status Running

Write-Output "Done!!"
