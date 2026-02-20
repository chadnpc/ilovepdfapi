function ConvertTo-PdfA {
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
    [ConformanceValues]$Conformance = "PdfA1B",

    [Parameter()]
    [string]$OutputFileName = "pdfa_output.pdf"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([PdfToPdfATask])
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
    $params = [PdfToPdfAParams]::new()
    $params.Conformance = $Conformance

    Write-Verbose "Processing PDF to PDF/A conversion on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading converted files to $OutputFolder"

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
