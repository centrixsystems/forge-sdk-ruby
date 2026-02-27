# forge-sdk

Ruby SDK for the [Forge](https://github.com/centrixsystems/forge) rendering engine. Converts HTML/CSS to PDF, PNG, and other formats via a running Forge server.

Uses `net/http` from the standard library. Zero dependencies.

## Installation

```sh
gem install forge-sdk
```

Or add to `Gemfile`:

```ruby
gem "forge-sdk"
```

## Quick Start

```ruby
require "forge_sdk"

client = ForgeSdk::Client.new("http://localhost:3000")

pdf = client.render_html("<h1>Invoice #1234</h1>")
  .format(ForgeSdk::OutputFormat::PDF)
  .paper("a4")
  .execute

File.binwrite("invoice.pdf", pdf)
```

## Usage

### Render HTML to PDF

```ruby
pdf = client.render_html("<h1>Hello</h1>")
  .format(ForgeSdk::OutputFormat::PDF)
  .paper("a4")
  .orientation(ForgeSdk::Orientation::PORTRAIT)
  .margins("25.4,25.4,25.4,25.4")
  .flow(ForgeSdk::Flow::PAGINATE)
  .execute
```

### Render URL to PNG

```ruby
png = client.render_url("https://example.com")
  .format(ForgeSdk::OutputFormat::PNG)
  .width(1280)
  .height(800)
  .density(2.0)
  .execute
```

### Color Quantization

Reduce colors for e-ink displays or limited-palette output.

```ruby
eink = client.render_html("<h1>Dashboard</h1>")
  .format(ForgeSdk::OutputFormat::PNG)
  .palette(ForgeSdk::Palette::EINK)
  .dither(ForgeSdk::DitherMethod::FLOYD_STEINBERG)
  .execute
```

### Custom Palette

```ruby
img = client.render_html("<h1>Brand</h1>")
  .format(ForgeSdk::OutputFormat::PNG)
  .palette(["#000000", "#ffffff", "#ff0000"])
  .dither(ForgeSdk::DitherMethod::ATKINSON)
  .execute
```

### PDF Metadata

Set PDF document properties such as title, author, and keywords.

```ruby
pdf = client.render_html("<h1>Invoice #1234</h1>")
  .format(ForgeSdk::OutputFormat::PDF)
  .paper("a4")
  .pdf_title("Invoice #1234")
  .pdf_author("Centrix ERP")
  .pdf_subject("Monthly invoice")
  .pdf_keywords("invoice,billing,2026")
  .pdf_creator("Forge Renderer")
  .pdf_bookmarks(true)
  .execute

File.binwrite("invoice.pdf", pdf)
```

### PDF Watermarks

Add text or image watermarks to each page.

```ruby
pdf = client.render_html("<h1>Draft Report</h1>")
  .pdf_watermark_text("DRAFT")
  .pdf_watermark_opacity(0.15)
  .pdf_watermark_rotation(-45)
  .pdf_watermark_color("#888888")
  .pdf_watermark_layer(ForgeSdk::WatermarkLayer::OVER)
  .execute
```

### PDF/A Archival Output

Generate PDF/A-compliant documents for long-term archiving.

```ruby
pdf = client.render_html("<h1>Archival Report</h1>")
  .pdf_standard(ForgeSdk::PdfStandard::A2B)
  .pdf_title("Archival Report")
  .execute
```

### Embedded Files (ZUGFeRD/Factur-X)

Attach files to PDF output. Requires PDF/A-3b for embedded file attachments.

```ruby
require "base64"

xml_data = Base64.strict_encode64(File.binread("factur-x.xml"))

pdf = client.render_html("<h1>Invoice #1234</h1>")
  .pdf_standard(ForgeSdk::PdfStandard::A3B)
  .pdf_attach("factur-x.xml", xml_data,
    mime_type: "text/xml",
    description: "Factur-X invoice",
    relationship: ForgeSdk::EmbedRelationship::ALTERNATIVE)
  .execute
```

### PDF Digital Signatures

Sign PDF documents with a PKCS#12 certificate.

```ruby
require "base64"

cert_data = Base64.strict_encode64(File.binread("certificate.p12"))

pdf = client.render_html("<h1>Signed Contract</h1>")
  .pdf_sign_certificate(cert_data)
  .pdf_sign_password("cert-password")
  .pdf_sign_name("Jane Doe")
  .pdf_sign_reason("Contract approval")
  .pdf_sign_location("New York, NY")
  .execute
```

### PDF Encryption

Protect PDF documents with passwords and permission restrictions.

```ruby
pdf = client.render_html("<h1>Confidential Report</h1>")
  .pdf_owner_password("owner-secret")
  .pdf_user_password("user-secret")
  .pdf_permissions(["print", "copy"])
  .execute
```

### PDF Accessibility

Generate accessible PDF documents.

```ruby
pdf = client.render_html("<h1>Accessible Report</h1>")
  .pdf_accessibility(ForgeSdk::AccessibilityLevel::PDF_UA_1)
  .pdf_bookmarks(true)
  .execute
```

### PDF Linearization

Enable fast web view for large PDF documents.

```ruby
pdf = client.render_html("<h1>Large Report</h1>")
  .pdf_linearize(true)
  .execute
```

### PDF Rendering Mode

Control how PDF content is rendered.

```ruby
pdf = client.render_html("<h1>Vector Report</h1>")
  .pdf_mode(ForgeSdk::PdfMode::VECTOR)
  .execute
```

### Custom Timeout

```ruby
client = ForgeSdk::Client.new("http://forge:3000", timeout: 300)
```

### Health Check

```ruby
healthy = client.health
```

## API Reference

### `ForgeSdk::Client`

```ruby
ForgeSdk::Client.new(base_url, timeout: 120)
```

| Method | Returns | Description |
|--------|---------|-------------|
| `render_html(html)` | `RenderRequest` | Start a render request from HTML |
| `render_url(url)` | `RenderRequest` | Start a render request from a URL |
| `health` | `Boolean` | Check server health |

### `ForgeSdk::RenderRequest`

All methods return `self` for chaining. Call `.execute` to send the request.

| Method | Type | Description |
|--------|------|-------------|
| `format` | `String` | Output format (default: `"pdf"`) |
| `width` | `Integer` | Viewport width in CSS pixels |
| `height` | `Integer` | Viewport height in CSS pixels |
| `paper` | `String` | Paper size: a3, a4, a5, b4, b5, letter, legal, ledger |
| `orientation` | `String` | `"portrait"` or `"landscape"` |
| `margins` | `String` | Preset (`default`, `none`, `narrow`) or `"T,R,B,L"` in mm |
| `flow` | `String` | `"auto"`, `"paginate"`, or `"continuous"` |
| `density` | `Numeric` | Output DPI (default: 96) |
| `background` | `String` | CSS background color (e.g. `"#ffffff"`) |
| `timeout` | `Integer` | Page load timeout in seconds |
| `colors` | `Integer` | Quantization color count (2-256) |
| `palette` | `String \| Array` | Preset string or array of hex color strings |
| `dither` | `String` | Dithering algorithm |
| `pdf_title` | `String` | PDF document title |
| `pdf_author` | `String` | PDF document author |
| `pdf_subject` | `String` | PDF document subject |
| `pdf_keywords` | `String` | PDF keywords (comma-separated) |
| `pdf_creator` | `String` | PDF creator application name |
| `pdf_bookmarks` | `Boolean` | Generate PDF bookmarks from headings |
| `pdf_page_numbers` | `Boolean` | Add "Page X of Y" footers to each page |
| `pdf_watermark_text` | `String` | Watermark text on each page |
| `pdf_watermark_image` | `String` | Base64-encoded PNG/JPEG watermark image |
| `pdf_watermark_opacity` | `Numeric` | Watermark opacity (0.0-1.0, default: 0.15) |
| `pdf_watermark_rotation` | `Numeric` | Watermark rotation in degrees (default: -45) |
| `pdf_watermark_color` | `String` | Watermark text color as hex (default: #888888) |
| `pdf_watermark_font_size` | `Numeric` | Watermark font size in PDF points (default: auto) |
| `pdf_watermark_scale` | `Numeric` | Watermark image scale (0.0-1.0, default: 0.5) |
| `pdf_watermark_layer` | `String` | Layer position: `OVER` or `UNDER` |
| `pdf_mode` | `String` | PDF rendering mode: `AUTO`, `VECTOR`, `RASTER` |
| `pdf_sign_certificate` | `String` | Base64-encoded PKCS#12 certificate for PDF signing |
| `pdf_sign_password` | `String` | Password for the signing certificate |
| `pdf_sign_name` | `String` | Signer name for the digital signature |
| `pdf_sign_reason` | `String` | Reason for signing |
| `pdf_sign_location` | `String` | Location of signing |
| `pdf_sign_timestamp_url` | `String` | RFC 3161 timestamp server URL |
| `pdf_user_password` | `String` | PDF user password (restricts opening) |
| `pdf_owner_password` | `String` | PDF owner password (restricts editing) |
| `pdf_permissions` | `Array` | PDF permission flags |
| `pdf_accessibility` | `String` | Accessibility level: `NONE`, `BASIC`, `PDF_UA_1` |
| `pdf_linearize` | `Boolean` | Enable PDF linearization (fast web view) |
| `pdf_standard` | `String` | PDF standard: `NONE`, `A2B`, `A3B` |
| `pdf_attach` | `String, String, **opts` | Embed file: path, base64 data, mime_type:, description:, relationship: |

| Terminal Method | Returns | Description |
|-----------------|---------|-------------|
| `execute` | `String` | Execute the request, returns raw binary output |

### Constants

| Module | Constants |
|--------|----------|
| `ForgeSdk::OutputFormat` | `PDF`, `PNG`, `JPEG`, `BMP`, `TGA`, `QOI`, `SVG` |
| `ForgeSdk::Orientation` | `PORTRAIT`, `LANDSCAPE` |
| `ForgeSdk::Flow` | `AUTO`, `PAGINATE`, `CONTINUOUS` |
| `ForgeSdk::DitherMethod` | `NONE`, `FLOYD_STEINBERG`, `ATKINSON`, `ORDERED` |
| `ForgeSdk::Palette` | `AUTO`, `BLACK_WHITE`, `GRAYSCALE`, `EINK` |
| `ForgeSdk::WatermarkLayer` | `OVER`, `UNDER` |
| `ForgeSdk::PdfStandard` | `NONE`, `A2B`, `A3B` |
| `ForgeSdk::EmbedRelationship` | `ALTERNATIVE`, `SUPPLEMENT`, `DATA`, `SOURCE`, `UNSPECIFIED` |
| `ForgeSdk::PdfMode` | `AUTO`, `VECTOR`, `RASTER` |
| `ForgeSdk::AccessibilityLevel` | `NONE`, `BASIC`, `PDF_UA_1` |

### Errors

| Exception | Attributes | Description |
|-----------|------------|-------------|
| `ForgeSdk::ForgeError` | `message` | Base error for all SDK errors |
| `ForgeSdk::ServerError` | `status_code` | Server returned 4xx/5xx |
| `ForgeSdk::ConnectionError` | `message` | Network failure |

## Requirements

- Ruby 3.0+
- A running [Forge](https://github.com/centrixsystems/forge) server

## License

MIT
