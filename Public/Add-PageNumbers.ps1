function Add-PageNumbers {
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

    [Parameter()]
    [string]$Pages = "all",

    [Parameter()]
    [int]$StartingNumber = 1,

    [Parameter()]
    [VerticalPositions]$VerticalPosition = "Bottom",

    [Parameter()]
    [HorizontalPositions]$HorizontalPosition = "Middle",

    [Parameter()]
    [int]$VerticalPositionAdjustment = 0,

    [Parameter()]
    [int]$HorizontalPositionAdjustment = 0,

    [Parameter()]
    [FontFamilies]$FontFamily = "Arial",

    [Parameter()]
    [int]$FontSize = 12,

    [Parameter()]
    [string]$FontColor = "#000000",

    [Parameter()]
    [string]$Text = "{n}",

    [Parameter()]
    [switch]$FacingPages,

    [Parameter()]
    [switch]$FirstCover
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([PageNumbersTask])
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
    $params = [PageNumbersParams]::new()
    $params.Pages = $Pages
    $params.StartingNumber = $StartingNumber
    $params.VerticalPosition = $VerticalPosition
    $params.HorizontalPosition = $HorizontalPosition
    $params.VerticalPositionAdjustment = $VerticalPositionAdjustment
    $params.HorizontalPositionAdjustment = $HorizontalPositionAdjustment
    $params.FontFamily = $FontFamily
    $params.FontSize = $FontSize
    $params.FontColor = $FontColor
    $params.Text = $Text
    $params.FacingPages = $FacingPages.IsPresent
    $params.FirstCover = $FirstCover.IsPresent

    Write-Verbose "Processing page numbers task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading files to $OutputFolder"

    $downloadDest = Join-Path $OutputFolder "pagenumbers_output.pdf"

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
