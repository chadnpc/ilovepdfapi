function Compress-Pdf {
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
    [CompressionLevels]$CompressionLevel = "Recommended"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([CompressTask])
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
    $params = [CompressParams]::new()
    $params.CompressionLevel = $CompressionLevel

    Write-Verbose "Processing compression task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading compressed files to $OutputFolder"

    $downloadDest = $OutputFolder
    # If it's a single file it returns a PDF, if multiple it might pack them.
    # Often it's easier to specify the folder, or append the filename if single.
    if ($FilePaths.Count -eq 1) {
      $name = [System.IO.Path]::GetFileNameWithoutExtension($FilePaths[0])
      $ext = [System.IO.Path]::GetExtension($FilePaths[0])
      $downloadDest = Join-Path $OutputFolder "${name}_compressed$ext"
    } else {
      $downloadDest = Join-Path $OutputFolder "compressed_output.zip"
    }

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
