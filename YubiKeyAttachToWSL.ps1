$yubiKeyBusId = (usbipd list | Select-String "1050:0407" | ForEach-Object { $_.Line.Split()[0] })

if ($yubiKeyBusId) {
    usbipd attach --wsl --busid $yubiKeyBusId
    Write-Host "YubiKey attached to WSL with busid $yubiKeyBusId."
} else {
    Write-Host "YubiKey not found."
}