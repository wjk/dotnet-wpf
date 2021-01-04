@echo off
cd %~dp0\..

pwsh -ExecutionPolicy Bypass -File eng\create-updatedwpf-nupkg.ps1 ^
  -VersionNumber 1.0.255.255 ^
  -WorkDirectory artifacts\tmp\nupkg ^
  -SdkPackagePath artifacts\packages\Debug\NonShipping\Microsoft.NET.Sdk.WindowsDesktop.Debug.5.0.0-dev.nupkg ^
  -BinaryPackagePath artifacts\packages\Debug\NonShipping\runtime.win-x86.Microsoft.DotNet.Wpf.GitHub.Debug.5.0.0-dev.nupkg ^
  -BinaryPackagePath64Bit artifacts\packages\Debug\NonShipping\runtime.win-x64.Microsoft.DotNet.Wpf.GitHub.Debug.5.0.0-dev.nupkg ^
  -NuspecTemplatePath eng\Sunburst.UpdatedWPF.nuspec
