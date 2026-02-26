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
| `pdf_watermark_text` | `String` | Watermark text on each page |
| `pdf_watermark_image` | `String` | Base64-encoded PNG/JPEG watermark image |
| `pdf_watermark_opacity` | `Numeric` | Watermark opacity (0.0-1.0, default: 0.15) |
| `pdf_watermark_rotation` | `Numeric` | Watermark rotation in degrees (default: -45) |
| `pdf_watermark_color` | `String` | Watermark text color as hex (default: #888888) |
| `pdf_watermark_font_size` | `Numeric` | Watermark font size in PDF points (default: auto) |
| `pdf_watermark_scale` | `Numeric` | Watermark image scale (0.0-1.0, default: 0.5) |
| `pdf_watermark_layer` | `String` | Layer position: `OVER` or `UNDER` |

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
