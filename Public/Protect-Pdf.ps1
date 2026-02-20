function Protect-Pdf {
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
    [string]$Password,

    [Parameter()]
    [string]$OutputFileName = "protected.pdf"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([ProtectTask])
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
    $params = [ProtectParams]::new()
    $params.Password = $Password

    Write-Verbose "Processing protect task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading protected files to $OutputFolder"

    $downloadDest = Join-Path $OutputFolder $OutputFileName

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
