function Test-PdfA {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]]$FilePaths,

    [Parameter(Mandatory)]
    [string]$PublicKey,

    [Parameter(Mandatory)]
    [string]$PrivateKey,

    [Parameter()]
    [ConformanceValues]$Conformance = "PdfA1B"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([ValidatePdfATask])
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
    $params = [ValidatePdfAParams]::new()
    $params.Conformance = $Conformance

    Write-Verbose "Processing PDF/A validation on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Task finished."

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      Validations      = $executionRes.Validations
    }
  }
}
