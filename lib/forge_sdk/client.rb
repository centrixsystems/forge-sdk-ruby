# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module ForgeSdk
  # Client for a Forge rendering server.
  class Client
    # @param base_url [String] Forge server base URL
    # @param timeout [Integer] HTTP timeout in seconds (default: 120)
    def initialize(base_url, timeout: 120)
      @base_url = base_url.sub(%r{/+\z}, "")
      @timeout = timeout
    end

    # Start a render request from an HTML string.
    # @return [RenderRequest]
    def render_html(html)
      RenderRequest.new(self, html: html)
    end

    # Start a render request from a URL.
    # @return [RenderRequest]
    def render_url(url)
      RenderRequest.new(self, url: url)
    end

    # Check if the server is healthy.
    # @return [Boolean]
    def health
      uri = URI("#{@base_url}/health")
      resp = make_request(:get, uri)
      resp.is_a?(Net::HTTPSuccess)
    rescue StandardError
      false
    end

    # @api private
    def send_render(payload)
      uri = URI("#{@base_url}/render")
      resp = make_request(:post, uri, payload.to_json)

      unless resp.is_a?(Net::HTTPSuccess)
        message = begin
          JSON.parse(resp.body)["error"]
        rescue StandardError
          "HTTP #{resp.code}"
        end
        raise ServerError.new(resp.code.to_i, message)
      end

      resp.body.b
    end

    private

    def make_request(method, uri, body = nil)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      req = case method
            when :get then Net::HTTP::Get.new(uri)
            when :post
              r = Net::HTTP::Post.new(uri)
              r["Content-Type"] = "application/json"
              r.body = body
              r
            end

      http.request(req)
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
      raise ConnectionError, e
    end
  end

  # Builder for a render request.
  class RenderRequest
    def initialize(client, html: nil, url: nil)
      @client = client
      @html = html
      @url = url
      @format = OutputFormat::PDF
      @options = {}
    end

    def format(f)
      @format = f
      self
    end

    def width(px)
      @options[:width] = px
      self
    end

    def height(px)
      @options[:height] = px
      self
    end

    def paper(size)
      @options[:paper] = size
      self
    end

    def orientation(o)
      @options[:orientation] = o
      self
    end

    def margins(m)
      @options[:margins] = m
      self
    end

    def flow(f)
      @options[:flow] = f
      self
    end

    def density(dpi)
      @options[:density] = dpi
      self
    end

    def background(color)
      @options[:background] = color
      self
    end

    def timeout(seconds)
      @options[:timeout] = seconds
      self
    end

    def colors(n)
      @options[:colors] = n
      self
    end

    def palette(p)
      @options[:palette] = p
      self
    end

    def dither(method)
      @options[:dither] = method
      self
    end

    def pdf_title(t)
      @options[:pdf_title] = t
      self
    end

    def pdf_author(a)
      @options[:pdf_author] = a
      self
    end

    def pdf_subject(s)
      @options[:pdf_subject] = s
      self
    end

    def pdf_keywords(k)
      @options[:pdf_keywords] = k
      self
    end

    def pdf_creator(c)
      @options[:pdf_creator] = c
      self
    end

    def pdf_bookmarks(b)
      @options[:pdf_bookmarks] = b
      self
    end

    def pdf_watermark_text(t)
      @options[:pdf_watermark_text] = t
      self
    end

    def pdf_watermark_image(base64_data)
      @options[:pdf_watermark_image] = base64_data
      self
    end

    def pdf_watermark_opacity(o)
      @options[:pdf_watermark_opacity] = o
      self
    end

    def pdf_watermark_rotation(d)
      @options[:pdf_watermark_rotation] = d
      self
    end

    def pdf_watermark_color(c)
      @options[:pdf_watermark_color] = c
      self
    end

    def pdf_watermark_font_size(s)
      @options[:pdf_watermark_font_size] = s
      self
    end

    def pdf_watermark_scale(s)
      @options[:pdf_watermark_scale] = s
      self
    end

    def pdf_watermark_layer(l)
      @options[:pdf_watermark_layer] = l
      self
    end

    def pdf_watermark_pages(pages)
      @options[:pdf_watermark_pages] = pages
      self
    end

    def pdf_barcode(type:, data:, x: nil, y: nil, width: nil, height: nil, anchor: nil, foreground: nil, background: nil, draw_background: nil, pages: nil)
      @options[:pdf_barcodes] ||= []
      entry = { type: type, data: data }
      entry[:x] = x if x
      entry[:y] = y if y
      entry[:width] = width if width
      entry[:height] = height if height
      entry[:anchor] = anchor if anchor
      entry[:foreground] = foreground if foreground
      entry[:background] = background if background
      entry[:draw_background] = draw_background unless draw_background.nil?
      entry[:pages] = pages if pages
      @options[:pdf_barcodes] << entry
      self
    end

    def pdf_standard(s)
      @options[:pdf_standard] = s
      self
    end

    def pdf_attach(path, base64_data, mime_type: nil, description: nil, relationship: nil)
      @options[:pdf_embedded_files] ||= []
      @options[:pdf_embedded_files] << { path: path, data: base64_data, mime_type: mime_type,
                                         description: description, relationship: relationship }
      self
    end

    # Build the payload hash.
    # @return [Hash]
    def build_payload
      payload = { format: @format }
      payload[:html] = @html if @html
      payload[:url] = @url if @url
      payload[:width] = @options[:width] if @options[:width]
      payload[:height] = @options[:height] if @options[:height]
      payload[:paper] = @options[:paper] if @options[:paper]
      payload[:orientation] = @options[:orientation] if @options[:orientation]
      payload[:margins] = @options[:margins] if @options[:margins]
      payload[:flow] = @options[:flow] if @options[:flow]
      payload[:density] = @options[:density] if @options[:density]
      payload[:background] = @options[:background] if @options[:background]
      payload[:timeout] = @options[:timeout] if @options[:timeout]

      has_quantize = @options[:colors] || @options[:palette] || @options[:dither]
      if has_quantize
        q = {}
        q[:colors] = @options[:colors] if @options[:colors]
        q[:palette] = @options[:palette] if @options[:palette]
        q[:dither] = @options[:dither] if @options[:dither]
        payload[:quantize] = q
      end

      has_watermark = @options[:pdf_watermark_text] || @options[:pdf_watermark_image] ||
                      @options[:pdf_watermark_opacity] || @options[:pdf_watermark_rotation] ||
                      @options[:pdf_watermark_color] || @options[:pdf_watermark_font_size] ||
                      @options[:pdf_watermark_scale] || @options[:pdf_watermark_layer] ||
                      @options[:pdf_watermark_pages]

      has_pdf = @options[:pdf_title] || @options[:pdf_author] || @options[:pdf_subject] ||
                @options[:pdf_keywords] || @options[:pdf_creator] || !@options[:pdf_bookmarks].nil? ||
                has_watermark || @options[:pdf_standard] || @options[:pdf_embedded_files] ||
                @options[:pdf_barcodes]
      if has_pdf
        p = {}
        p[:title] = @options[:pdf_title] if @options[:pdf_title]
        p[:author] = @options[:pdf_author] if @options[:pdf_author]
        p[:subject] = @options[:pdf_subject] if @options[:pdf_subject]
        p[:keywords] = @options[:pdf_keywords] if @options[:pdf_keywords]
        p[:creator] = @options[:pdf_creator] if @options[:pdf_creator]
        p[:bookmarks] = @options[:pdf_bookmarks] unless @options[:pdf_bookmarks].nil?
        p[:standard] = @options[:pdf_standard] if @options[:pdf_standard]
        if has_watermark
          wm = {}
          wm[:text] = @options[:pdf_watermark_text] if @options[:pdf_watermark_text]
          wm[:image_data] = @options[:pdf_watermark_image] if @options[:pdf_watermark_image]
          wm[:opacity] = @options[:pdf_watermark_opacity] if @options[:pdf_watermark_opacity]
          wm[:rotation] = @options[:pdf_watermark_rotation] if @options[:pdf_watermark_rotation]
          wm[:color] = @options[:pdf_watermark_color] if @options[:pdf_watermark_color]
          wm[:font_size] = @options[:pdf_watermark_font_size] if @options[:pdf_watermark_font_size]
          wm[:scale] = @options[:pdf_watermark_scale] if @options[:pdf_watermark_scale]
          wm[:layer] = @options[:pdf_watermark_layer] if @options[:pdf_watermark_layer]
          wm[:pages] = @options[:pdf_watermark_pages] if @options[:pdf_watermark_pages]
          p[:watermark] = wm
        end
        if @options[:pdf_barcodes]
          p[:barcodes] = @options[:pdf_barcodes]
        end
        if @options[:pdf_embedded_files]
          p[:embedded_files] = @options[:pdf_embedded_files].map do |ef|
            h = { path: ef[:path], data: ef[:data] }
            h[:mime_type] = ef[:mime_type] if ef[:mime_type]
            h[:description] = ef[:description] if ef[:description]
            h[:relationship] = ef[:relationship] if ef[:relationship]
            h
          end
        end
        payload[:pdf] = p
      end

      payload
    end

    # Send the render request and return raw output bytes.
    # @return [String] raw binary output
    def execute
      @client.send_render(build_payload)
    end
  end
end
