function Invoke-PdfOcr {
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
    [string]$OutputFileName = "ocr_output.pdf",

    [Parameter()]
    [OCRLanguage[]]$OCRLanguages
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([PdfocrTask])
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
    $params = [PDFOCRParams]::new()
    if ($OCRLanguages) {
      $params.OCRLanguages = [List[OCRLanguage]]::new($OCRLanguages)
    }

    Write-Verbose "Processing OCR task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading OCR files to $OutputFolder"

    $downloadDest = [IO.Path]::Combine($OutputFolder, $OutputFileName)

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
