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

#region Exceptions
class DownloadException : System.Exception {
  DownloadException() : base() {}
  DownloadException([string]$message) : base($message) {}
  DownloadException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class NotFoundException : System.Exception {
  NotFoundException() : base() {}
  NotFoundException([string]$message) : base($message) {}
  NotFoundException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class ProcessingException : System.Exception {
  ProcessingException() : base() {}
  ProcessingException([string]$message) : base($message) {}
  ProcessingException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class ServerErrorException : System.Exception {
  ServerErrorException() : base() {}
  ServerErrorException([string]$message) : base($message) {}
  ServerErrorException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class SignatureException : System.Exception {
  SignatureException() : base() {}
  SignatureException([string]$message) : base($message) {}
  SignatureException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class SignStartException : System.Exception {
  SignStartException() : base() {}
  SignStartException([string]$message) : base($message) {}
  SignStartException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class TaskStartException : System.Exception {
  TaskStartException() : base() {}
  TaskStartException([string]$message) : base($message) {}
  TaskStartException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class TooManyRequestsException : System.Exception {
  TooManyRequestsException() : base() {}
  TooManyRequestsException([string]$message) : base($message) {}
  TooManyRequestsException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class UndefinedException : System.Exception {
  UndefinedException() : base() {}
  UndefinedException([string]$message) : base($message) {}
  UndefinedException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}

class UploadException : System.Exception {
  UploadException() : base() {}
  UploadException([string]$message) : base($message) {}
  UploadException([string]$message, [System.Exception]$innerException) : base($message, $innerException) {}
}
#endregion Exceptions

#region Additional Enums
enum LovePdfErrors {
  UploadError
  ProcessingError
  DownloadError
  StartError
  SignatureError
}

enum ConformanceValues {
  PdfA1B
  PdfA1A
  PdfA2B
  PdfA2U
  PdfA2A
  PdfA3B
  PdfA3U
  PdfA3A
}

enum ElementTypes {
  Bottom
  Text
  Image
  SVG
}

enum FontFamilies {
  Arial
  Courier
  TimesNewRoman
  Verdana
  ComicSansMs
  WenQuanYiZenHei
  ArialUnicodeMs
  LohitMarathi
  LohitDevanagari
}

enum FontStyles {
  Bold
  Italic
}

enum ForceSignatureType {
  All
  Text
  Sign
  Image
}

enum Gravity {
  NorthWest
  North
  NorthEast
  West
  Center
  East
  SouthWest
  South
  SouthEast
}

enum HorizontalPositions {
  Left
  Middle
  Right
}

enum Languages {
  Arabic
  Bulgarian
  Catalan
  German
  Greek
  English
  Spanish
  French
  Hindi
  Indonesian
  Italian
  Japanese
  Korean
  Malaysian
  Dutch
  Polish
  Portuguese
  Russian
  Swedish
  Thai
  Turkish
  Ukrainian
  Vietnamese
  SimplifiedChinese
  TraditionalChinese
  Chinese
  TaiwanChinese
}

enum Layer {
  Above
  Below
}

enum OCRLanguage {
  Eng
  Afr
  Amh
  Ara
  Asm
  Aze
  Aze_Cyrl
  Bel
  Ben
  Bod
  Bos
  Bre
  Bul
  Cat
  Ceb
  Ces
  Chi_Sim
  Chi_Tra
  Chr
  Cos
  Cym
  Dan
  Dan_Frak
  Deu
  Deu_Frak
  Dzo
  Ell
  Enm
  Epo
  Equ
  Est
  Eus
  Fao
  Fas
  Fil
  Fin
  Fra
  Frk
  Frm
  Fry
  Gla
  Gle
  Glg
  Grc
  Guj
  Hat
  Heb
  Hin
  Hrv
  Hun
  Hye
  Iku
  Ind
  Isl
  Ita
  Ita_Old
  Jav
  Jpn
  Kan
  Kat
  Kat_Old
  Kaz
  Khm
  Kir
  Kmr
  Kor
  Kor_Vert
  Kur
  Lao
  Lat
  Lav
  Lit
  Ltz
  Mal
  Mar
  Mkd
  Mlt
  Mon
  Mri
  Msa
  Mya
  Nep
  Nld
  Nor
  Oci
  Ori
  Pan
  Pol
  Por
  Pus
  Que
  Ron
  Rus
  San
  Sin
  Slk
  Slk_Frak
  Slv
  Snd
  Spa
  Spa_Old
  Squ
  Srp
  Srp_Latn
  Sun
  Swa
  Swe
  Syr
  Tam
  Tat
  Tel
  Tgk
  Tgl
  Tha
  Tir
  Ton
  Tur
  Uig
  Ukr
  Urd
  Uzb
  Uzb_Cyrl
  Vie
  Yid
  Yor
}

enum Orientations {
  Portrait
  Landscape
}

enum PageSizes {
  Fit
  A4
  Letter
}

enum PdfToJpgModes {
  Pages
  Extract
}

enum Rotate {
  Degrees0
  Degrees90
  Degrees180
  Degrees270
}

enum SignElementTypes {
  Initials
  Signature
  Name
  Date
  Text
  Input
}

enum SignSignerType {
  Signer
  Validator
  Viewer
}

enum SplitModes {
  Ranges
  FixedRange
  RemovePages
}

enum TextAligments {
  Left
  Center
  Right
}

enum TextFontStyles {
  Regular
  Bold
  Italic
  BoldItalic
}

enum ValidationStatus {
  Conformant
  NonConformant
}

enum VerticalPositions {
  Bottom
  Top
}

enum WaterMarkHorizontalPositions {
  Left
  Middle
  Right
}

enum WaterMarkModes {
  Text
  Image
  Multi
}

enum WaterMarkVerticalPositions {
  Bottom
  Top
  Center
}

#endregion Additional Enums

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

class Dimension {
  [int]$Width
  [int]$Height
}

class Coordinate {
  [int]$X
  [int]$Y
}

class Position {
  [string]$X
  [string]$Y
}

class BaseExtraUploadParams {
  [Dictionary[string, string]]$ExtraParams
  BaseExtraUploadParams() {
    $this.ExtraParams = [Dictionary[string, string]]::new()
  }
}

class EditElement {
  [ElementTypes]$Type = [ElementTypes]::Bottom
  [int]$Pages = 1
  [int]$ZIndex = 1
  [string]$Gravity = "Center"
  [Dimension]$Dimensions
  [Coordinate]$Coordinates
  [int]$Rotation
  [int]$Opacity = 100
}

class BaseSignElement {
  [SignElementTypes]$Type
  [string]$Pages
  [Position]$Position
  [int]$Size = 18
  [int]$HorizontalAdjustment = 0
  [int]$VerticalAdjustment = 0
}

class BaseSignSigner {
  [SignSignerType]$Type
  [string]$Name
  [string]$Email
  [string]$AccessCode
}

class SignerFile {
  [string]$File
  [List[object]]$Elements
  SignerFile() {
    # Using [object] to avoid circular type reference before BaseSignElement is defined?
    # Actually in PS it should be fine.
    $this.Elements = [List[object]]::new()
  }
}

class ImageElement : EditElement {
  [string]$ServerFileName
}

class SvgElement : EditElement {
  [string]$ServerFileName
}

class TextElementEdit : EditElement {
  [string]$Text
  [TextAligments]$Align
  [FontFamilies]$FontFamily
  [TextFontStyles]$FontStyle
  [bool]$UnderlineText
}

class DateElement : BaseSignElement {
}

class InitialsElement : BaseSignElement {
}

class InputElement : BaseSignElement {
}

class NameElement : BaseSignElement {
}

class SignatureElement : BaseSignElement {
}

class TextElementSign : BaseSignElement {
  [string]$Text
}

class Signer : BaseSignSigner {
  [string]$Phone
  [List[SignerFile]]$Files
  Signer() {
    $this.Files = [List[SignerFile]]::new()
  }
}

class Validator : BaseSignSigner {
}

class Viewer : BaseSignSigner {
}

class EditParams : BaseParams {
}

class ExtractParams : BaseParams {
  [bool]$Detailed
  [bool]$ByWord
}

class HTMLtoPDFParams : BaseParams {
  [int]$ViewWidth
  [int]$Margin
  [bool]$RemovePopups
  [bool]$SinglePage
}

class ImageToPdfParams : BaseParams {
  [Orientations]$Orientation
  [int]$Margin
  [PageSizes]$PageSize
  [bool]$MergeAfter
}

class MergeParams : BaseParams {
}

class PageNumbersParams : BaseParams {
  [bool]$FacingPages
  [bool]$FirstCover
  [string]$Pages
  [int]$StartingNumber
  [VerticalPositions]$VerticalPosition
  [HorizontalPositions]$HorizontalPosition
  [int]$VerticalPositionAdjustment
  [int]$HorizontalPositionAdjustment
  [FontFamilies]$FontFamily
  [int]$FontSize
  [string]$FontColor
  [string]$Text
}

class PDFOCRParams : BaseParams {
  [List[OCRLanguage]]$OCRLanguages = [List[OCRLanguage]]::new()
}

class PdftoJpgParams : BaseParams {
  [PdfToJpgModes]$PdfJpgMode
}

class PdfToPdfAParams : BaseParams {
  [ConformanceValues]$Conformance
}

class ProtectParams : BaseParams {
  [string]$Password
}

class SignExtraUploadParams : BaseExtraUploadParams {
}

class SplitParams : BaseParams {
  [SplitModes]$SplitMode
  [string]$Ranges
  [int]$FixedRanges
  [string]$RemovePages
  [bool]$MergeAfter
}

class ValidatePdfAParams : BaseParams {
  [ConformanceValues]$Conformance
}

class WaterMarkParams : BaseParams {
  [WaterMarkModes]$Mode
  [string]$Text
  [string]$Image
  [string]$Pages
  [int]$VerticalPositionAdjustment
  [int]$HorizontalPositionAdjustment
  [bool]$Mosaic
  [int]$Rotation
  [string]$FontFamily
  [int]$FontSize
  [string]$FontColor
  [int]$Transparency
}

class CompressParams : BaseParams {
  [CompressionLevels]$CompressionLevel = [CompressionLevels]::Recommended
}

class WatermarkModeText {
  [string]$Text
  WatermarkModeText([string]$text) {
    $this.Text = $text
  }
}

class WatermarkModeImage {
  [string]$ServerFileName
  WatermarkModeImage([string]$serverFileName) {
    $this.ServerFileName = $serverFileName
  }
}

class WaterMarkParamsElement {
  [WaterMarkModes]$Mode
  [string]$Text
  [string]$Image
  [string]$Pages = "all"
  [WaterMarkVerticalPositions]$VerticalPosition
  [WaterMarkHorizontalPositions]$HorizontalPosition
  [int]$VerticalPositionAdjustment = 0
  [int]$HorizontalPositionAdjustment = 0
  [bool]$Mosaic = $false
  [int]$Rotation = 0
  [string]$FontFamily = "Arial Unicode MS"
  [FontStyles]$FontStyle
  [int]$FontSize = 14
  [string]$FontColor = "#000000"
  [int]$Transparency = 100
  [int]$Zoom
  [int]$Border
  [Gravity]$Gravity = [Gravity]::Center
  [Layer]$Layer

  WaterMarkParamsElement([WatermarkModeText]$mode) {
    if ($null -eq $mode) {
      throw [System.ArgumentException]::new("mode cannot be null", "mode")
    }
    $this.Mode = [WaterMarkModes]::Text
    $this.Text = $mode.Text
  }

  WaterMarkParamsElement([WatermarkModeImage]$mode) {
    if ($null -eq $mode) {
      throw [System.ArgumentException]::new("mode cannot be null", "mode")
    }
    $this.Mode = [WaterMarkModes]::Image
    $this.Image = $mode.ServerFileName
  }
}

class SplitModeFixedRanges {
  [int]$FixedRange
  SplitModeFixedRanges([int]$ranges) {
    $this.FixedRange = $ranges
  }
}

class SplitModeRanges {
  [string]$Ranges
  SplitModeRanges([string]$ranges) {
    $this.Ranges = $ranges
  }
}

class SplitModeRemovePages {
  [string]$RemovePages
  SplitModeRemovePages([string]$removePages) {
    $this.RemovePages = $removePages
  }
}

class ListRequest {
  [int]$Page = 0
  [int]$PerPage = 20

  ListRequest() {}

  ListRequest([int]$page, [int]$perPage) {
    $this.Page = $page
    $this.PerPage = $perPage
  }

  [void] SetPerPage([int]$value) {
    if ($value -lt 1 -or $value -gt 100) {
      throw [System.ArgumentOutOfRangeException]::new("PerPage", "PerPage must be between 1 and 100 pages")
    }
    $this.PerPage = $value
  }
}

class SignParams : BaseParams {
  [string]$BrandName
  [string]$BrandLogo
  [Languages]$Language = [Languages]::English
  [bool]$LockOrder = $false
  [bool]$SignerReminders = $true
  [int]$SignerReminderDaysCycle = 1
  [bool]$VerifyEnabled = $true
  [bool]$UuidVisible = $true
  [int]$ExpirationDays = 120
  [string]$MessageSigner
  [string]$SubjectSigner
  [List[object]]$Signers

  SignParams() {
    $this.Signers = [List[object]]::new()
  }

  SignParams([List[object]]$signers) {
    $this.Signers = if ($null -ne $signers) { $signers } else { [List[object]]::new() }
  }

  [void] SetBrand([string]$name, [string]$serverFileName) {
    if ([string]::IsNullOrEmpty($name) -or [string]::IsNullOrEmpty($serverFileName)) {
      throw [System.ArgumentNullException]::new("name", "Parameters are mandatory.")
    }
    $this.BrandName = $name
    $this.BrandLogo = $serverFileName
  }

  [void] SetExpirationDays([int]$days) {
    if ($days -lt 1 -or $days -gt 130) {
      throw [System.ArgumentOutOfRangeException]::new("ExpirationDays", "Value must be between 1 and 130")
    }
    $this.ExpirationDays = $days
  }
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
  [string]$_publicKey
  [string]$_privateKey
  [Uri]$ServerUrl
  [string]$TaskId
  [List[FileModel]]$Files

  iLovePdfTask() {
    $this.Files = [List[FileModel]]::new()
  }

  [string] GetToolName() {
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

  [UploadTaskResponse] UploadFile([string]$filePath) {
    $res = [RequestHelper]::UploadFile($this._publicKey, $this._privateKey, $this.ServerUrl, $this.TaskId, $filePath)
    $model = [FileModel]::new()
    $model.ServerFileName = $res.ServerFileName
    $model.FileName = [System.IO.Path]::GetFileName($filePath)
    $this.Files.Add($model)
    return $res
  }

  [ExecuteTaskResponse] Process([BaseParams]$parameters) {
    $res = [RequestHelper]::ExecuteTask($this._publicKey, $this._privateKey, $this.ServerUrl, $this.TaskId, $this.Files, $this.GetToolName(), $parameters)
    $this.Files.Clear()
    return $res
  }

  [void] DownloadFile([string]$destination) {
    [RequestHelper]::Download($this._publicKey, $this._privateKey, $this.ServerUrl, $this.TaskId, $destination)
  }
}

class CompressTask : iLovePdfTask {
  CompressTask() {}

  [string] GetToolName() {
    return [TaskName]::Compress.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([CompressParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [CompressParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class MergeTask : iLovePdfTask {
  MergeTask() {}

  [string] GetToolName() {
    return [TaskName]::Merge.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [MergeParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([MergeParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [MergeParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class SplitTask : iLovePdfTask {
  SplitTask() {}

  [string] GetToolName() {
    return [TaskName]::Split.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([SplitParams]$parameters) {
    if ($null -eq $parameters) {
      throw [System.ArgumentException]::new("Parameters should not be null", "parameters")
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class OfficeToPdfTask : iLovePdfTask {
  OfficeToPdfTask() {}

  [string] GetToolName() {
    return [TaskName]::OfficeToPdf.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [OfficeToPdfParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([OfficeToPdfParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [OfficeToPdfParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class PdfToJpgTask : iLovePdfTask {
  PdfToJpgTask() {}

  [string] GetToolName() {
    return [TaskName]::PdfToJpg.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [PdftoJpgParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([PdftoJpgParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [PdftoJpgParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class ImageToPdfTask : iLovePdfTask {
  ImageToPdfTask() {}

  [string] GetToolName() {
    return [TaskName]::ImagePdf.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [ImageToPdfParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([ImageToPdfParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [ImageToPdfParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class WaterMarkTask : iLovePdfTask {
  WaterMarkTask() {}

  [string] GetToolName() {
    return [TaskName]::WaterMark.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([WaterMarkParams]$parameters) {
    if ($null -eq $parameters) {
      throw [System.ArgumentException]::new("Parameters should not be null", "parameters")
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class PageNumbersTask : iLovePdfTask {
  PageNumbersTask() {}

  [string] GetToolName() {
    return [TaskName]::PageNumber.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([PageNumbersParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [PageNumbersParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class UnlockTask : iLovePdfTask {
  UnlockTask() {}

  [string] GetToolName() {
    return [TaskName]::Unlock.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [UnlockParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([UnlockParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [UnlockParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class RotateTask : iLovePdfTask {
  RotateTask() {}

  [string] GetToolName() {
    return [TaskName]::Rotate.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [RotateParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([RotateParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [RotateParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class RepairTask : iLovePdfTask {
  RepairTask() {}

  [string] GetToolName() {
    return [TaskName]::Repair.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [RepairParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([RepairParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [RepairParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class ProtectTask : iLovePdfTask {
  ProtectTask() {}

  [string] GetToolName() {
    return [TaskName]::Protect.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([ProtectParams]$parameters) {
    if ($null -eq $parameters) {
      throw [System.ArgumentException]::new("Parameters should not be null", "parameters")
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class ValidatePdfATask : iLovePdfTask {
  ValidatePdfATask() {}

  [string] GetToolName() {
    return [TaskName]::ValidatePdfA.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [ValidatePdfAParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([ValidatePdfAParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [ValidatePdfAParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class PdfToPdfATask : iLovePdfTask {
  PdfToPdfATask() {}

  [string] GetToolName() {
    return [TaskName]::PdfToPdfA.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [PdfToPdfAParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([PdfToPdfAParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [PdfToPdfAParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class ExtractTask : iLovePdfTask {
  ExtractTask() {}

  [string] GetToolName() {
    return [TaskName]::Extract.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [ExtractParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([ExtractParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [ExtractParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class HtmlToPdfTask : iLovePdfTask {
  HtmlToPdfTask() {}

  [string] GetToolName() {
    return [TaskName]::HtmlToPdf.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([HTMLtoPDFParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [HTMLtoPDFParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class PdfocrTask : iLovePdfTask {
  PdfocrTask() {}

  [string] GetToolName() {
    return [TaskName]::Pdfocr.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process() {
    $parameters = [PDFOCRParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([PDFOCRParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [PDFOCRParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }
}

class EditTask : iLovePdfTask {
  EditTask() {}

  [string] GetToolName() {
    return [TaskName]::Edit.ToString().ToLower()
  }

  [ExecuteTaskResponse] Process([List[object]]$elements) {
    $parameters = [EditParams]::new()
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
  }

  [ExecuteTaskResponse] Process([EditParams]$parameters) {
    if ($null -eq $parameters) {
      $parameters = [EditParams]::new()
    }
    return ([iLovePdfTask]$this).Process([BaseParams]$parameters)
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
    $instance._publicKey = $this._publicKey
    $instance._privateKey = $this._privateKey

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
    $instance._publicKey = $this._publicKey
    $instance._privateKey = $this._privateKey

    $response = [RequestHelper]::ConnectTask($this._publicKey, $this._privateKey, $parent.TaskId, $instance.GetToolName())

    $instance.SetServerTaskId($parent.ServerUrl, $response.TaskId)
    $instance.AddFiles($response.Files)

    return $instance
  }
}

#endregion Classes

# Types that will be available to users when they import the module.
$typestoExport = @(
  # Core classes
  [ilovepdfapi], [RequestHelper],
  # TaskParams
  [BaseParams], [CompressParams], [MergeParams], [SplitParams], [OfficeToPdfParams],
  [PdftoJpgParams], [ImageToPdfParams], [WaterMarkParams], [PageNumbersParams],
  [UnlockParams], [RotateParams], [RepairParams], [ProtectParams],
  [ValidatePdfAParams], [PdfToPdfAParams], [ExtractParams], [HTMLtoPDFParams],
  [PDFOCRParams], [EditParams], [SignParams], [ListRequest],
  [WatermarkModeText], [WatermarkModeImage], [WaterMarkParamsElement],
  [SplitModeFixedRanges], [SplitModeRanges], [SplitModeRemovePages],
  # Tasks
  [iLovePdfTask], [CompressTask], [MergeTask], [SplitTask], [OfficeToPdfTask],
  [PdfToJpgTask], [ImageToPdfTask], [WaterMarkTask], [PageNumbersTask],
  [UnlockTask], [RotateTask], [RepairTask], [ProtectTask],
  [ValidatePdfATask], [PdfToPdfATask], [ExtractTask], [HtmlToPdfTask],
  [PdfocrTask], [EditTask]
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
