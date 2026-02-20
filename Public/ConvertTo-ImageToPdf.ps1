function ConvertTo-ImageToPdf {
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
    [string]$OutputFileName = "images_merged.pdf",

    [Parameter()]
    [Orientations]$Orientation = "Portrait",

    [Parameter()]
    [PageSizes]$PageSize = "A4",

    [Parameter()]
    [int]$Margin = 0,

    [Parameter()]
    [switch]$MergeAfter
  )

  begin {
    $api = [ilovepdfapi]::new($PublicKey, $PrivateKey)
    $task = $api.CreateTask([ImageToPdfTask])
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
    $params = [ImageToPdfParams]::new()
    $params.Orientation = $Orientation
    $params.PageSize = $PageSize
    $params.Margin = $Margin
    $params.MergeAfter = $MergeAfter.IsPresent

    Write-Verbose "Processing Image to PDF conversion on iLovePDF server..."
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
