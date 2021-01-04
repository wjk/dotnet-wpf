param(
    [int]$BuildNumberMajor = 0,
    [int]$BuildNumberMinor = 1,
    [System.IO.FileInfo]$WorkDirectory,

    [System.IO.FileInfo]$SdkPackagePath,
    [System.IO.FileInfo]$BinaryPackagePath,
    [System.IO.FileInfo]$BinaryPackagePath64Bit = $null,
    [System.IO.FileInfo]$NuspecTemplatePath
)

mkdir $WorkDirectory.FullName -ErrorAction SilentlyContinue | Out-Null
cd $WorkDirectory.FullName

rm -Recurse sdk, bin_common, bin_x64, output -Force -ErrorAction SilentlyContinue
mkdir sdk, bin_common, bin_x64, output | Out-Null

Expand-Archive -DestinationPath sdk -Path $SdkPackagePath.FullName
Expand-Archive -DestinationPath bin_common -Path $BinaryPackagePath.FullName
if ($BinaryPackagePath64Bit -ne $null) {
  Expand-Archive -DestinationPath bin_x64 -Path $BinaryPackagePath64Bit.Fullname
}

copy -Recurse sdk\tools output -Force
copy -Recurse bin_common\ref, bin_common\lib, bin_common\runtimes output -Force
if ($BinaryPackagePath64Bit -ne $null) {
  copy -Recurse bin_x64\runtimes\win-x64 output\runtimes -Force
}

$xml = ""
ls -Recurse -File bin_common\lib, bin_common\runtimes | %{
  $rel = [System.IO.Path]::GetRelativePath("$($pwd.Path)\bin_common", $_.FullName)
  $xml += "<file target=`"$($rel)`" src=`"$($_.FullName)`" />`n"
}
ls -Recurse -File sdk\tools | %{
  $rel = [System.IO.Path]::GetRelativePath("$($pwd.Path)\sdk", $_.FullName)
  $xml += "<file target=`"$($rel)`" src=`"$($_.FullName)`" />`n"
}

mkdir output\build -Force | Out-Null
copy sdk\targets\Microsoft.NET.Sdk.WindowsDesktop.props output\build\Sunburst.UpdatedWPF.props
copy sdk\targets\Microsoft.NET.Sdk.WindowsDesktop.targets output\build\Sunburst.UpdatedWPF.targets
copy sdk\targets\Microsoft.WinFX.targets output\build\Microsoft.WinFX.targets
ls -Recurse -File output\build | %{
  $rel = [System.IO.Path]::GetRelativePath("$($pwd.Path)\output", $_.FullName)
  $xml += "<file target=`"$($rel)`" src=`"$($_.FullName)`" />`n"
}

copy $NuspecTemplatePath.FullName wpf.nuspec
$nuspec = Get-Content wpf.nuspec
$nuspec = $nuspec.Replace('%FILES%', $xml)

$date = Get-Date
$year = $date.Year - 2000

$nuspec = $nuspec.Replace('%VERSION%', "1.0.$($BuildNumberMajor).$($BuildNumberMinor))
Set-Content wpf.nuspec $nuspec

if (-not [System.IO.File]::Exists('nuget.exe')) {
  (New-Object System.Net.WebClient).DownloadFile('http://dist.nuget.org/win-x86-commandline/latest/nuget.exe', "$($pwd.Path)\nuget.exe")
}

# Remove all other nupkg files, so older ones won't be picked up by mistake.
rm *.nupkg

& "$($pwd.Path)\nuget.exe" pack wpf.nuspec
