$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$taskAssetDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\assets\images'))
New-Item -ItemType Directory -Path $taskAssetDir -Force | Out-Null

# Recursos originales provisionales, sin fotografías ni datos personales reales.
$taskAvatar = New-Object Drawing.Bitmap 512,512
$taskGraphics = [Drawing.Graphics]::FromImage($taskAvatar)
$taskGraphics.SmoothingMode = 'AntiAlias'
$taskGraphics.Clear([Drawing.ColorTranslator]::FromHtml('#EAF3EF'))
$taskBrush = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#183D38'))
$taskGraphics.FillEllipse($taskBrush,184,116,144,144)
$taskGraphics.FillEllipse($taskBrush,116,280,280,260)
$taskAvatar.Save((Join-Path $taskAssetDir 'profile.png'),[Drawing.Imaging.ImageFormat]::Png)
$taskGraphics.Dispose()
$taskAvatar.Dispose()

$taskToolbox = New-Object Drawing.Bitmap 1200,560
$taskGraphics = [Drawing.Graphics]::FromImage($taskToolbox)
$taskGraphics.SmoothingMode = 'AntiAlias'
$taskGraphics.Clear([Drawing.ColorTranslator]::FromHtml('#E7A45C'))
$taskLightBrush = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#F7D4A8'))
$taskGraphics.FillEllipse($taskLightBrush,-100,220,550,550)
$taskGraphics.FillEllipse($taskLightBrush,950,-200,500,500)
$taskPen = New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml('#183D38')),28
$taskGraphics.DrawRectangle($taskPen,480,125,240,110)
$taskGraphics.FillRectangle($taskBrush,340,215,520,245)
$taskGraphics.FillRectangle($taskLightBrush,340,280,520,22)
$taskGraphics.FillRectangle($taskLightBrush,575,263,50,64)
$taskToolbox.Save((Join-Path $taskAssetDir 'toolbox.png'),[Drawing.Imaging.ImageFormat]::Png)
$taskGraphics.Dispose()
$taskToolbox.Dispose()
$taskBrush.Dispose()
$taskLightBrush.Dispose()
$taskPen.Dispose()
