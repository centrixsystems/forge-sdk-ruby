# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/forge_sdk"

class TestRenderRequest < Minitest::Test
  def setup
    @client = ForgeSdk::Client.new("http://localhost:3000")
  end

  def test_minimal_html_payload
    req = @client.render_html("<h1>Hi</h1>")
    payload = req.build_payload

    assert_equal "<h1>Hi</h1>", payload[:html]
    assert_equal "pdf", payload[:format]
    refute payload.key?(:url)
    refute payload.key?(:quantize)
  end

  def test_url_payload_with_options
    req = @client.render_url("https://example.com")
      .format(ForgeSdk::OutputFormat::PNG)
      .width(1280)
      .height(800)
      .paper("letter")
      .orientation(ForgeSdk::Orientation::LANDSCAPE)
      .margins("10,20,10,20")
      .flow(ForgeSdk::Flow::PAGINATE)
      .density(300.0)
      .background("#ffffff")
      .timeout(60)

    payload = req.build_payload

    refute payload.key?(:html)
    assert_equal "https://example.com", payload[:url]
    assert_equal "png", payload[:format]
    assert_equal 1280, payload[:width]
    assert_equal 800, payload[:height]
    assert_equal "letter", payload[:paper]
    assert_equal "landscape", payload[:orientation]
    assert_equal "paginate", payload[:flow]
    refute payload.key?(:quantize)
  end

  def test_quantize_payload
    req = @client.render_html("<p>test</p>")
      .format(ForgeSdk::OutputFormat::PNG)
      .colors(16)
      .palette(ForgeSdk::Palette::AUTO)
      .dither(ForgeSdk::DitherMethod::FLOYD_STEINBERG)

    payload = req.build_payload
    q = payload[:quantize]

    assert_equal 16, q[:colors]
    assert_equal "auto", q[:palette]
    assert_equal "floyd-steinberg", q[:dither]
  end

  def test_custom_palette
    req = @client.render_html("<p>test</p>")
      .palette(["#000000", "#ffffff", "#ff0000"])
      .dither(ForgeSdk::DitherMethod::ATKINSON)

    payload = req.build_payload
    q = payload[:quantize]

    assert_equal ["#000000", "#ffffff", "#ff0000"], q[:palette]
    assert_equal "atkinson", q[:dither]
  end

  def test_no_quantize_when_unset
    req = @client.render_html("<p>test</p>")
      .format(ForgeSdk::OutputFormat::PNG)

    payload = req.build_payload
    refute payload.key?(:quantize)
  end

  def test_pdf_options_payload
    req = @client.render_html("<h1>Invoice</h1>")
      .format(ForgeSdk::OutputFormat::PDF)
      .pdf_title("Invoice #1234")
      .pdf_author("Centrix ERP")
      .pdf_subject("Monthly invoice")
      .pdf_keywords("invoice,billing,2026")
      .pdf_creator("Forge Renderer")
      .pdf_bookmarks(true)

    payload = req.build_payload
    p = payload[:pdf]

    assert_equal "Invoice #1234", p[:title]
    assert_equal "Centrix ERP", p[:author]
    assert_equal "Monthly invoice", p[:subject]
    assert_equal "invoice,billing,2026", p[:keywords]
    assert_equal "Forge Renderer", p[:creator]
    assert_equal true, p[:bookmarks]
  end

  def test_partial_pdf_options
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_title("My Document")
      .pdf_bookmarks(false)

    payload = req.build_payload
    p = payload[:pdf]

    assert_equal "My Document", p[:title]
    assert_equal false, p[:bookmarks]
    refute p.key?(:author)
    refute p.key?(:subject)
    refute p.key?(:keywords)
    refute p.key?(:creator)
  end

  def test_no_pdf_when_unset
    req = @client.render_html("<p>test</p>")
      .format(ForgeSdk::OutputFormat::PDF)

    payload = req.build_payload
    refute payload.key?(:pdf)
  end

  def test_watermark_pages
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_watermark_text("DRAFT")
      .pdf_watermark_pages("1,3-5")

    payload = req.build_payload
    wm = payload[:pdf][:watermark]

    assert_equal "DRAFT", wm[:text]
    assert_equal "1,3-5", wm[:pages]
  end

  def test_watermark_pages_only_triggers_pdf
    req = @client.render_html("<p>test</p>")
      .pdf_watermark_pages("2-4")

    payload = req.build_payload

    assert payload.key?(:pdf)
    assert_equal "2-4", payload[:pdf][:watermark][:pages]
  end

  def test_barcode_minimal
    req = @client.render_html("<p>test</p>")
      .pdf_barcode(type: ForgeSdk::BarcodeType::QR, data: "https://example.com")

    payload = req.build_payload
    barcodes = payload[:pdf][:barcodes]

    assert_equal 1, barcodes.length
    assert_equal "qr", barcodes[0][:type]
    assert_equal "https://example.com", barcodes[0][:data]
    refute barcodes[0].key?(:x)
    refute barcodes[0].key?(:anchor)
  end

  def test_barcode_all_options
    req = @client.render_html("<p>test</p>")
      .pdf_barcode(
        type: ForgeSdk::BarcodeType::CODE128,
        data: "ABC-123",
        x: 50.0,
        y: 100.0,
        width: 200.0,
        height: 80.0,
        anchor: ForgeSdk::BarcodeAnchor::BOTTOM_RIGHT,
        foreground: "#000000",
        background: "#ffffff",
        draw_background: true,
        pages: "1,3"
      )

    payload = req.build_payload
    bc = payload[:pdf][:barcodes][0]

    assert_equal "code128", bc[:type]
    assert_equal "ABC-123", bc[:data]
    assert_equal 50.0, bc[:x]
    assert_equal 100.0, bc[:y]
    assert_equal 200.0, bc[:width]
    assert_equal 80.0, bc[:height]
    assert_equal "bottom-right", bc[:anchor]
    assert_equal "#000000", bc[:foreground]
    assert_equal "#ffffff", bc[:background]
    assert_equal true, bc[:draw_background]
    assert_equal "1,3", bc[:pages]
  end

  def test_barcode_draw_background_false
    req = @client.render_html("<p>test</p>")
      .pdf_barcode(type: ForgeSdk::BarcodeType::EAN13, data: "5901234123457", draw_background: false)

    payload = req.build_payload
    bc = payload[:pdf][:barcodes][0]

    assert_equal false, bc[:draw_background]
  end

  def test_multiple_barcodes
    req = @client.render_html("<p>test</p>")
      .pdf_barcode(type: ForgeSdk::BarcodeType::QR, data: "qr-data", anchor: ForgeSdk::BarcodeAnchor::TOP_LEFT)
      .pdf_barcode(type: ForgeSdk::BarcodeType::CODE39, data: "CODE39DATA", anchor: ForgeSdk::BarcodeAnchor::TOP_RIGHT)

    payload = req.build_payload
    barcodes = payload[:pdf][:barcodes]

    assert_equal 2, barcodes.length
    assert_equal "qr", barcodes[0][:type]
    assert_equal "top-left", barcodes[0][:anchor]
    assert_equal "code39", barcodes[1][:type]
    assert_equal "top-right", barcodes[1][:anchor]
  end

  def test_barcode_types_constants
    assert_equal "qr", ForgeSdk::BarcodeType::QR
    assert_equal "code128", ForgeSdk::BarcodeType::CODE128
    assert_equal "ean13", ForgeSdk::BarcodeType::EAN13
    assert_equal "upca", ForgeSdk::BarcodeType::UPCA
    assert_equal "code39", ForgeSdk::BarcodeType::CODE39
  end

  def test_barcode_anchor_constants
    assert_equal "top-left", ForgeSdk::BarcodeAnchor::TOP_LEFT
    assert_equal "top-right", ForgeSdk::BarcodeAnchor::TOP_RIGHT
    assert_equal "bottom-left", ForgeSdk::BarcodeAnchor::BOTTOM_LEFT
    assert_equal "bottom-right", ForgeSdk::BarcodeAnchor::BOTTOM_RIGHT
  end

  def test_barcode_with_watermark_and_metadata
    req = @client.render_html("<h1>Invoice</h1>")
      .pdf_title("Invoice #5678")
      .pdf_watermark_text("PAID")
      .pdf_watermark_pages("1")
      .pdf_barcode(type: ForgeSdk::BarcodeType::QR, data: "INV-5678", anchor: ForgeSdk::BarcodeAnchor::BOTTOM_LEFT)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal "Invoice #5678", pdf[:title]
    assert_equal "PAID", pdf[:watermark][:text]
    assert_equal "1", pdf[:watermark][:pages]
    assert_equal 1, pdf[:barcodes].length
    assert_equal "qr", pdf[:barcodes][0][:type]
    assert_equal "bottom-left", pdf[:barcodes][0][:anchor]
  end

  def test_pdf_mode_constants
    assert_equal "auto", ForgeSdk::PdfMode::AUTO
    assert_equal "vector", ForgeSdk::PdfMode::VECTOR
    assert_equal "raster", ForgeSdk::PdfMode::RASTER
  end

  def test_accessibility_level_constants
    assert_equal "none", ForgeSdk::AccessibilityLevel::NONE
    assert_equal "basic", ForgeSdk::AccessibilityLevel::BASIC
    assert_equal "pdf/ua-1", ForgeSdk::AccessibilityLevel::PDF_UA_1
  end

  def test_pdf_mode_payload
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_mode(ForgeSdk::PdfMode::VECTOR)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal "vector", pdf[:mode]
  end

  def test_pdf_signature_payload
    req = @client.render_html("<h1>Contract</h1>")
      .pdf_sign_certificate("base64cert")
      .pdf_sign_password("secret")
      .pdf_sign_name("Jane Doe")
      .pdf_sign_reason("Approval")
      .pdf_sign_location("New York")
      .pdf_sign_timestamp_url("https://tsa.example.com")

    payload = req.build_payload
    sig = payload[:pdf][:signature]

    assert_equal "base64cert", sig[:certificate_data]
    assert_equal "secret", sig[:password]
    assert_equal "Jane Doe", sig[:signer_name]
    assert_equal "Approval", sig[:reason]
    assert_equal "New York", sig[:location]
    assert_equal "https://tsa.example.com", sig[:timestamp_url]
  end

  def test_pdf_partial_signature
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_sign_certificate("base64cert")
      .pdf_sign_name("Signer")

    payload = req.build_payload
    sig = payload[:pdf][:signature]

    assert_equal "base64cert", sig[:certificate_data]
    assert_equal "Signer", sig[:signer_name]
    refute sig.key?(:password)
    refute sig.key?(:reason)
    refute sig.key?(:location)
    refute sig.key?(:timestamp_url)
  end

  def test_pdf_encryption_payload
    req = @client.render_html("<h1>Secret</h1>")
      .pdf_user_password("user123")
      .pdf_owner_password("owner456")
      .pdf_permissions(["print", "copy"])

    payload = req.build_payload
    enc = payload[:pdf][:encryption]

    assert_equal "user123", enc[:user_password]
    assert_equal "owner456", enc[:owner_password]
    assert_equal ["print", "copy"], enc[:permissions]
  end

  def test_pdf_partial_encryption
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_owner_password("owner-only")

    payload = req.build_payload
    enc = payload[:pdf][:encryption]

    assert_equal "owner-only", enc[:owner_password]
    refute enc.key?(:user_password)
    refute enc.key?(:permissions)
  end

  def test_pdf_accessibility_payload
    req = @client.render_html("<h1>Accessible</h1>")
      .pdf_accessibility(ForgeSdk::AccessibilityLevel::PDF_UA_1)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal "pdf/ua-1", pdf[:accessibility]
  end

  def test_pdf_linearize_true
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_linearize(true)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal true, pdf[:linearize]
  end

  def test_pdf_linearize_false
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_linearize(false)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal false, pdf[:linearize]
  end

  def test_no_signature_when_unset
    req = @client.render_html("<h1>Doc</h1>")
      .pdf_title("Title only")

    payload = req.build_payload
    pdf = payload[:pdf]

    refute pdf.key?(:signature)
    refute pdf.key?(:encryption)
    refute pdf.key?(:mode)
    refute pdf.key?(:accessibility)
    refute pdf.key?(:linearize)
  end

  def test_all_new_pdf_options_combined
    req = @client.render_html("<h1>Full</h1>")
      .pdf_title("Full Doc")
      .pdf_mode(ForgeSdk::PdfMode::RASTER)
      .pdf_sign_certificate("cert")
      .pdf_sign_name("Signer")
      .pdf_owner_password("owner")
      .pdf_permissions(["print"])
      .pdf_accessibility(ForgeSdk::AccessibilityLevel::BASIC)
      .pdf_linearize(true)

    payload = req.build_payload
    pdf = payload[:pdf]

    assert_equal "Full Doc", pdf[:title]
    assert_equal "raster", pdf[:mode]
    assert_equal "cert", pdf[:signature][:certificate_data]
    assert_equal "Signer", pdf[:signature][:signer_name]
    assert_equal "owner", pdf[:encryption][:owner_password]
    assert_equal ["print"], pdf[:encryption][:permissions]
    assert_equal "basic", pdf[:accessibility]
    assert_equal true, pdf[:linearize]
  end
end
