function ConvertTo-PdfFromHtml {
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
    [int]$ViewWidth = 1024,

    [Parameter()]
    [int]$Margin = 0,

    [Parameter()]
    [switch]$RemovePopups,

    [Parameter()]
    [switch]$SinglePage,

    [Parameter()]
    [string]$OutputFileName = "html_converted.pdf"
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([HtmlToPdfTask])
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
    $params = [HTMLtoPDFParams]::new()
    $params.ViewWidth = $ViewWidth
    $params.Margin = $Margin
    $params.RemovePopups = $RemovePopups.IsPresent
    $params.SinglePage = $SinglePage.IsPresent

    Write-Verbose "Processing HTML to PDF conversion on iLovePDF server..."
    $executionRes = $task.Process($params)

    Write-Verbose "Downloading converted files to $OutputFolder"

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
