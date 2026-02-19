#!/usr/bin/env pwsh
using namespace System.Collections.Generic

#region Enums

enum TaskName {
  Merge
  Split
  Compress
  OfficeToPdf
  PdfToJpg
  ImagePdf
  WaterMark
  PageNumber
  Unlock
  Rotate
  Repair
  Protect
  ValidatePdfA
  PdfToPdfA
  Extract
  HtmlToPdf
  Edit
  Sign
  Pdfocr
}

enum CompressionLevels {
  Extreme
  Recommended
  Low
  SuperLow
}

enum DocumentPageSizes {
  Auto
  Fit
  A3
  A4
  A5
  A6
  Letter
}

#endregion Enums

#region Models and Parameters

class BaseParams {
  [bool]$IgnoreErrors = $true
  [bool]$IgnorePassword = $false
  [string]$OutputFileName
  [string]$PackageFileName
  [string]$FileEncryptionKey
  [bool]$TryPdfRepair = $true

  BaseParams() {}
}

class OfficeToPdfParams : BaseParams { }
class RotateParams : BaseParams { }
class RepairParams : BaseParams { }
class UnlockParams : BaseParams { }

class CompressParams : BaseParams {
  [CompressionLevels]$CompressionLevel = [CompressionLevels]::Recommended
}

# Responses
class StartTaskResponse {
  [string]$Server
  [string]$TaskId
}

class StatusTaskFileResponse {
  [string]$ServerFilename
  [string]$Status
  [string]$StatusMessage
  [string]$Filename
  [double]$Timer
  [int]$Filesize
  [int]$OutputFilesize
}

class StatusTaskResponse {
  [string]$Tool
  [string]$ProcessStart
  [string]$Status
  [string]$StatusMessage
  [string]$Timer
  [int]$Filesize
  [int]$OutputFilesize
  [int]$OutputFilenumber
  [List[string]]$OutputExtensions
  [string]$Server
  [string]$Task
  [string]$FileNumber
  [string]$DownloadFilename
  [List[StatusTaskFileResponse]]$Files
}

class Validation {
}

class ExecuteTaskResponse {
  [System.Collections.ObjectModel.Collection[Validation]]$Validations
  [long]$FileSize
  [long]$OutputFileSize
  [decimal]$Timer

  ExecuteTaskResponse() {
    $this.Validations = [System.Collections.ObjectModel.Collection[Validation]]::new()
  }
}

class UploadTaskResponse {
  [string]$ServerFileName
  [string[]]$PdfPages
  [string]$PdfPageNumber
  [List[Dictionary[string, object]]]$PdfForms
}

#endregion Models and Parameters

#region Core Tasks

class FileModel {
  [string]$ServerFileName
  [string]$FileName
  [string]$Password
  # [Rotate]$Rotate
}

class iLovePdfTask {
  [Uri]$ServerUrl
  [string]$TaskId
  hidden [List[FileModel]]$Files

  iLovePdfTask() {
    $this.Files = [List[FileModel]]::new()
  }

  hidden [string] GetToolName() {
    return ""
  }

  [void] SetServerTaskId([Uri]$serverUrl, [string]$taskId) {
    $this.ServerUrl = $serverUrl
    $this.TaskId = $taskId
    $this.Files = [List[FileModel]]::new()
  }

  [void] AddFiles([Dictionary[string, string]]$files) {
    foreach ($kvp in $files.GetEnumerator()) {
      $model = [FileModel]::new()
      $model.ServerFileName = $kvp.Key
      $model.FileName = $kvp.Value
      $this.Files.Add($model)
    }
  }
}

#endregion Core Tasks

#region Classes

# Main class
class ilovepdfapi {
  hidden [string]$_publicKey
  hidden [string]$_privateKey

  ilovepdfapi([string]$publicKey, [string]$privateKey) {
    if ([string]::IsNullOrWhiteSpace($publicKey)) {
      throw [System.ArgumentOutOfRangeException]::new("publicKey")
    }
    if ([string]::IsNullOrWhiteSpace($privateKey)) {
      throw [System.ArgumentOutOfRangeException]::new("privateKey")
    }
    $this._publicKey = $publicKey
    $this._privateKey = $privateKey
  }

  static [iLovePdfTask] CreateTask([type]$TaskType, [string]$publicKey, [string]$privateKey) {
    $api = [ilovepdfapi]::new($publicKey, $privateKey)
    $instance = $TaskType::new()

    # In a full implementation, you'd call RequestHelper.StartTask here
    # to get StartTaskResponse. For now we just return the instantiated task.

    return $instance
  }

  static [iLovePdfTask] ConnectTask([iLovePdfTask]$parent, [type]$TaskType) {
    $instance = $TaskType::new()

    # Here we'd call RequestHelper.ConnectTask

    return $instance
  }
}

#endregion Classes

# Types that will be available to users when they import the module.
$typestoExport = @(
  [ilovepdfapi]
)

$TypeAcceleratorsClass = [PsObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
foreach ($Type in $typestoExport) {
  if ($Type.FullName -in $TypeAcceleratorsClass::Get.Keys) {
    $Message = @(
      "Unable to register type accelerator '$($Type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '
    "TypeAcceleratorAlreadyExists $Message" | Write-Debug
  }
}
# Add type accelerators for every exportable type.
foreach ($Type in $typestoExport) {
  $TypeAcceleratorsClass::Add($Type.Name, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach ($Type in $typestoExport) {
    $TypeAcceleratorsClass::Remove($Type.Name)
  }
}.GetNewClosure();

$scripts = @();
$Public = Get-ChildItem "$PSScriptRoot/Public" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += Get-ChildItem "$PSScriptRoot/Private" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += $Public

foreach ($file in $scripts) {
  try {
    if ([string]::IsNullOrWhiteSpace($file.fullname)) { continue }
    . "$($file.fullname)"
  } catch {
    Write-Warning "Failed to import function $($file.BaseName): $_"
    $host.UI.WriteErrorLine($_)
  }
}

$Param = @{
  Cmdlet  = '*'
  Alias   = '*'
  Verbose = $false
}

if ($null -ne $Public -and $Public.Count -gt 0) {
  $Param.Function = $Public.BaseName
}

Export-ModuleMember @Param
