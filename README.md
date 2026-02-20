# [ilovepdfapi](https://www.iloveapi.com/docs/pdf-guides/getting-started)

PowerShell module for iLovePDF API - manipulate PDFs with ease.

[![Downloads](https://img.shields.io/powershellgallery/dt/ilovepdfapi.svg?style=flat&logo=powershell&color=blue)](https://www.powershellgallery.com/packages/ilovepdfapi)

## Installation

```PowerShell
Install-Module ilovepdfapi
```

## Usage

```PowerShell
Import-Module ilovepdfapi
```

### Initialize with your API keys

```PowerShell
# see .env.example
$publicKey =  (Get-Env -Name ILOVEAPI_PUBLIC_KEY -Path .env).Value
$privateKey =  (Get-Env -Name ILOVEAPI_PRIVATE_KEY -Path .env).Value
```

### Available Functions

| Function | Description |
|----------|-------------|
| `Compress-Pdf` | Compress PDF files |
| `Merge-Pdf` | Merge multiple PDF files |
| `Split-Pdf` | Split PDF files |
| `ConvertFrom-OfficeToPdf` | Convert Office documents to PDF |
| `ConvertTo-PdfToJpg` | Convert PDF to JPG images |
| `ConvertTo-ImageToPdf` | Convert images to PDF |
| `Add-WaterMark` | Add watermark to PDF |
| `Add-PageNumbers` | Add page numbers to PDF |
| `Unlock-Pdf` | Unlock protected PDF |
| `Rotate-Pdf` | Rotate PDF pages |
| `Repair-Pdf` | Repair damaged PDF |
| `Protect-Pdf` | Protect PDF with password |
| `Test-PdfA` | Validate PDF/A compliance |
| `ConvertTo-PdfA` | Convert to PDF/A format |
| `Extract-PdfContent` | Extract content from PDF |
| `ConvertTo-PdfFromHtml` | Convert HTML to PDF |
| `Invoke-PdfOcr` | Perform OCR on PDF |
| `Edit-Pdf` | Edit PDF files |

### Example: Compress a PDF

```PowerShell
$result = Compress-Pdf -FilePaths @("document.pdf") `
    -PublicKey $publicKey `
    -PrivateKey $privateKey `
    -OutputFolder "." `
    -CompressionLevel "Recommended"

Write-Host "Original: $($result.OriginalFilesize) bytes"
Write-Host "Compressed: $($result.OutputFilesize) bytes"
Write-Host "Saved to: $($result.SavedPath)"
```

## License

This project is licensed under the [WTFPL License](LICENSE).
