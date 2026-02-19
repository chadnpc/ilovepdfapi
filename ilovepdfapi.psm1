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

class ConnectTaskResponse {
  [string]$Server
  [string]$TaskId
  [Dictionary[string, string]]$Files
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

#region HTTP Helpers

class RequestHelper {
  static [string] GetJwt([string]$publicKey, [string]$privateKey) {
    $header = @{
      alg = "HS256"
      typ = "JWT"
    } | ConvertTo-Json -Compress

    $payload = @{
      jti = $publicKey
      iss = ""
      aud = ""
      iat = [Math]::Floor([datetimeoffset]::UtcNow.AddHours(-1).ToUnixTimeSeconds())
      nbf = [Math]::Floor([datetimeoffset]::UtcNow.AddHours(-1).ToUnixTimeSeconds())
      exp = [Math]::Floor([datetimeoffset]::UtcNow.AddHours(2).ToUnixTimeSeconds())
    } | ConvertTo-Json -Compress

    $base64UrlHeader = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($header)).TrimEnd('=').Replace('+', '-').Replace('/', '_')
    $base64UrlPayload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($payload)).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    $hmac = [System.Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($privateKey))
    $signature = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes("$base64UrlHeader.$base64UrlPayload"))
    $base64UrlSignature = [Convert]::ToBase64String($signature).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    return "$base64UrlHeader.$base64UrlPayload.$base64UrlSignature"
  }

  static [StartTaskResponse] StartTask([string]$publicKey, [string]$privateKey, [string]$tool) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "https://api.ilovepdf.com/v1/start/$tool"

    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    $res = [StartTaskResponse]::new()
    $res.Server = $response.server
    $res.TaskId = $response.task
    return $res
  }

  static [ConnectTaskResponse] ConnectTask([string]$publicKey, [string]$privateKey, [string]$parentTaskId, [string]$tool) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "https://api.ilovepdf.com/v1/task/next"

    $form = @{
      task = $parentTaskId
      tool = $tool
    }

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Form $form

    $res = [ConnectTaskResponse]::new()
    $res.Server = $response.server
    $res.TaskId = $response.task
    $res.Files = [System.Collections.Generic.Dictionary[string, string]]::new()
    if ($null -ne $response.files) {
      $props = $response.files.psobject.properties
      if ($null -ne $props) {
        foreach ($prop in $props) {
          $res.Files.Add($prop.Name, $prop.Value.ToString())
        }
      }
    }
    return $res
  }

  static [UploadTaskResponse] UploadFile([string]$publicKey, [string]$privateKey, [Uri]$serverUrl, [string]$taskId, [string]$filePath) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "$($serverUrl.AbsoluteUri)v1/upload"

    $form = @{
      task = $taskId
      file = Get-Item -Path $filePath
    }

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Form $form

    $res = [UploadTaskResponse]::new()
    $res.ServerFileName = $response.server_filename
    return $res
  }

  static [ExecuteTaskResponse] ExecuteTask([string]$publicKey, [string]$privateKey, [Uri]$serverUrl, [string]$taskId, [List[FileModel]]$files, [string]$tool, [BaseParams]$parameters) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "$($serverUrl.AbsoluteUri)v1/process"

    # Build form data
    $form = @{
      task = $taskId
      tool = $tool
      v    = "net.pwsh"
    }

    # Add files array properly
    for ($i = 0; $i -lt $files.Count; $i++) {
      $form.Add("files[$i][filename]", $files[$i].FileName)
      $form.Add("files[$i][server_filename]", $files[$i].ServerFileName)
      $form.Add("files[$i][password]", $files[$i].Password)
    }

    # Add parameter properties
    if ($parameters) {
      $props = $parameters.psobject.properties | Where-Object { $null -ne $_.Value }
      foreach ($prop in $props) {
        # Map PascalCase to snake_case minimally if needed, or rely on them matching API expected cases.
        # In C# there are [JsonProperty("property_name")] bindings.
        # We'll just pass them. For complete support a JSON/Hashtable property mapper is needed.
        $form.Add($prop.Name.ToLower(), $prop.Value.ToString())
      }
    }

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Form $form

    $res = [ExecuteTaskResponse]::new()
    $res.FileSize = $response.filesize
    $res.OutputFileSize = $response.output_filesize
    $res.Timer = $response.timer
    return $res
  }

  static [StatusTaskResponse] CheckTaskStatus([string]$publicKey, [string]$privateKey, [Uri]$serverUrl, [string]$taskId) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "$($serverUrl.AbsoluteUri)v1/task/$taskId"

    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    $res = [StatusTaskResponse]::new()
    $res.Status = $response.status
    $res.StatusMessage = $response.status_message
    $res.Timer = $response.timer
    return $res
  }

  static [void] Download([string]$publicKey, [string]$privateKey, [Uri]$serverUrl, [string]$taskId, [string]$destinationPath) {
    $jwt = [RequestHelper]::GetJwt($publicKey, $privateKey)
    $headers = @{ Authorization = "Bearer $jwt" }
    $url = "$($serverUrl.AbsoluteUri)v1/download/$taskId"

    Invoke-WebRequest -Uri $url -Method Get -Headers $headers -OutFile $destinationPath
  }
}

#endregion HTTP Helpers

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

  [iLovePdfTask] CreateTask([type]$TaskType) {
    if (-not $TaskType.IsSubclassOf([iLovePdfTask])) {
      throw "TaskType must inherit from iLovePdfTask"
    }

    $instance = $TaskType::new()
    $response = [RequestHelper]::StartTask($this._publicKey, $this._privateKey, $instance.GetToolName())

    $serverUrl = "https://$($response.Server)/"
    $instance.SetServerTaskId([Uri]::new($serverUrl), $response.TaskId)

    return $instance
  }

  [iLovePdfTask] ConnectTask([iLovePdfTask]$parent, [type]$TaskType) {
    if (-not $TaskType.IsSubclassOf([iLovePdfTask])) {
      throw "TaskType must inherit from iLovePdfTask"
    }

    $instance = $TaskType::new()
    $response = [RequestHelper]::ConnectTask($this._publicKey, $this._privateKey, $parent.TaskId, $instance.GetToolName())

    $instance.SetServerTaskId($parent.ServerUrl, $response.TaskId)
    $instance.AddFiles($response.Files)

    return $instance
  }
}

#endregion Classes

# Types that will be available to users when they import the module.
$typestoExport = @(
  [ilovepdfapi], [RequestHelper], [CompressParams]
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
