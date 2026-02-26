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
end
