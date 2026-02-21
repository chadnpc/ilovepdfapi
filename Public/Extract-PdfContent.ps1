function Get-PdfContent {
  [Alias('Extract-PdfContent')]
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
    [switch]$Detailed,

    [Parameter()]
    [switch]$ByWord
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([ExtractTask])
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
    $params = [ExtractParams]::new()
    $params.Detailed = $Detailed.IsPresent
    $params.ByWord = $ByWord.IsPresent

    Write-Verbose "Processing extract task on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading extracted files to $OutputFolder"

    $downloadDest = [IO.Path]::Combine($OutputFolder, "extracted_output.zip")

    $task.DownloadFile($downloadDest)

    Write-Verbose "Task finished. File saved to $downloadDest"

    return [PSCustomObject]@{
      OutputFilesize   = $executionRes.OutputFileSize
      OriginalFilesize = $executionRes.FileSize
      SavedPath        = $downloadDest
    }
  }
}
