function Split-Pdf {
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
    [SplitModes]$SplitMode = "Ranges",

    [Parameter()]
    [string]$Ranges,

    [Parameter()]
    [int]$FixedRanges,

    [Parameter()]
    [string]$RemovePages,

    [Parameter()]
    [switch]$MergeAfter
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([SplitTask])
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
    $params = [SplitParams]::new()
    $params.SplitMode = $SplitMode

    if ($SplitMode -eq [SplitModes]::Ranges -and $Ranges) {
      $params.Ranges = $Ranges
    }
    elseif ($SplitMode -eq [SplitModes]::FixedRange -and $FixedRanges -gt 0) {
      $params.FixedRanges = $FixedRanges
    }
    elseif ($SplitMode -eq [SplitModes]::RemovePages -and $RemovePages) {
      $params.RemovePages = $RemovePages
    }

    $params.MergeAfter = $MergeAfter.IsPresent

    Write-Verbose "Processing split task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading split files to $OutputFolder"

    $downloadDest = Join-Path $OutputFolder "split_output.zip"

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
