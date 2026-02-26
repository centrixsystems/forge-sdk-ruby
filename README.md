# forge-sdk

Ruby SDK for the [Forge](https://github.com/centrixsystems/forge) rendering engine. Converts HTML/CSS to PDF, PNG, and other formats via a running Forge server.

Uses `net/http` from the standard library.

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
  .send

File.binwrite("invoice.pdf", pdf)
```

## Usage

### Render URL to PNG

```ruby
png = client.render_url("https://example.com")
  .format(ForgeSdk::OutputFormat::PNG)
  .width(1280)
  .height(800)
  .send
```

### Color Quantization

```ruby
eink = client.render_html("<h1>Dashboard</h1>")
  .format(ForgeSdk::OutputFormat::PNG)
  .palette(ForgeSdk::Palette::EINK)
  .dither(ForgeSdk::DitherMethod::FLOYD_STEINBERG)
  .send
```

### Health Check

```ruby
healthy = client.health
```

## API Reference

### Constants

- `ForgeSdk::OutputFormat::PDF`, `PNG`, `JPEG`, `BMP`, `TGA`, `QOI`, `SVG`
- `ForgeSdk::Orientation::PORTRAIT`, `LANDSCAPE`
- `ForgeSdk::Flow::AUTO`, `PAGINATE`, `CONTINUOUS`
- `ForgeSdk::DitherMethod::NONE`, `FLOYD_STEINBERG`, `ATKINSON`, `ORDERED`
- `ForgeSdk::Palette::AUTO`, `BLACK_WHITE`, `GRAYSCALE`, `EINK`

### Errors

- `ForgeSdk::ForgeError` — base error
- `ForgeSdk::ServerError` — 4xx/5xx (has `status_code`)
- `ForgeSdk::ConnectionError` — network failures

## License

MIT
