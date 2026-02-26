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
