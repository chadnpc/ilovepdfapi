function ConvertTo-PdfToJpg {
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
    [PdfToJpgModes]$PdfJpgMode = "Pages"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([PdfToJpgTask])
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
    $params = [PdftoJpgParams]::new()
    $params.PdfJpgMode = $PdfJpgMode

    Write-Verbose "Processing PDF to JPG conversion on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading converted files to $OutputFolder"

    $downloadDest = Join-Path $OutputFolder "pdf_to_jpg_output.zip"

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
