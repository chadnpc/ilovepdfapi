function Add-WaterMark {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]]$FilePaths,

    [Parameter(Mandatory)]
    [string]$PublicKey,

    [Parameter(Mandatory)]
    [string]$PrivateKey,

    [Parameter()]
    [string]$OutputFolder = ".",

    [Parameter(Mandatory)]
    [string]$Text,

    [Parameter()]
    [string]$Image,

    [Parameter()]
    [string]$Pages = "all",

    [Parameter()]
    [WaterMarkVerticalPositions]$VerticalPosition = "Center",

    [Parameter()]
    [WaterMarkHorizontalPositions]$HorizontalPosition = "Center",

    [Parameter()]
    [int]$VerticalPositionAdjustment = 0,

    [Parameter()]
    [int]$HorizontalPositionAdjustment = 0,

    [Parameter()]
    [switch]$Mosaic,

    [Parameter()]
    [int]$Rotation = 0,

    [Parameter()]
    [string]$FontFamily = "Arial Unicode MS",

    [Parameter()]
    [int]$FontSize = 14,

    [Parameter()]
    [string]$FontColor = "#000000",

    [Parameter()]
    [int]$Transparency = 100
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([WaterMarkTask])
  }

  process {
    foreach ($file in $FilePaths) {
      if (-not (Test-Path $file)) {
        Write-Error "File not found: $file"
        continue
      }
      Write-Verbose "Uploading file: $file"
      $null = $task.UploadFile($file)
    }
  }

  end {
    $params = [WaterMarkParams]::new()
    $params.Text = $Text
    $params.Image = $Image
    $params.Pages = $Pages
    $params.VerticalPosition = $VerticalPosition
    $params.HorizontalPosition = $HorizontalPosition
    $params.VerticalPositionAdjustment = $VerticalPositionAdjustment
    $params.HorizontalPositionAdjustment = $HorizontalPositionAdjustment
    $params.Mosaic = $Mosaic.IsPresent
    $params.Rotation = $Rotation
    $params.FontFamily = $FontFamily
    $params.FontSize = $FontSize
    $params.FontColor = $FontColor
    $params.Transparency = $Transparency
    $params.Mode = if ($Image) { [WaterMarkModes]::Image } else { [WaterMarkModes]::Text }

    Write-Verbose "Processing watermark task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading watermarked files to $OutputFolder"

    $downloadDest = [IO.Path]::Combine($OutputFolder, "watermarked_output.pdf")

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
