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

      payload
    end

    # Send the render request and return raw output bytes.
    # @return [String] raw binary output
    def execute
      @client.send_render(build_payload)
    end
  end
end
