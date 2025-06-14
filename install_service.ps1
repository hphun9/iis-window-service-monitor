# CONFIGURATION
$serviceName = "HelloWorldMonitor"
$exePath = "C:\Development\Freelancer\Eurofins\WindowsServiceMonitor\publish\WindowsServiceMonitor.exe"
$displayName = "HelloWorld Site Health Monitor"
$description = "Monitors HelloWorld IIS site every 60s and stops on failure."
$user = "$env:COMPUTERNAME\HelloWorldUser"
$password = "********"

# Ensure the user exists
if (-not (Get-LocalUser -Name "HelloWorldUser" -ErrorAction SilentlyContinue)) {
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name "HelloWorldUser" -Password $securePass -PasswordNeverExpires
    Add-LocalGroupMember -Group "Users" -Member "HelloWorldUser"
}

# Stop and delete existing service if exists
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Stop-Service -Name $serviceName -Force
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 2
}

# Install service
New-Service -Name $serviceName `
            -BinaryPathName "`"$exePath`"" `
            -DisplayName $displayName `
            -Description $description `
            -StartupType Automatic `
            -Credential (New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $password -AsPlainText -Force)))

# Set failure recovery
sc.exe failure $serviceName reset= 0 actions= restart/300000

# Start the service
Start-Service -Name $serviceName

Write-Host "Service '$serviceName' installed and started successfully."
