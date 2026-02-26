# frozen_string_literal: true

module ForgeSdk
  # Output format for rendered content.
  module OutputFormat
    PDF  = "pdf"
    PNG  = "png"
    JPEG = "jpeg"
    BMP  = "bmp"
    TGA  = "tga"
    QOI  = "qoi"
    SVG  = "svg"
  end

  # Page orientation.
  module Orientation
    PORTRAIT  = "portrait"
    LANDSCAPE = "landscape"
  end

  # Document flow mode.
  module Flow
    AUTO       = "auto"
    PAGINATE   = "paginate"
    CONTINUOUS = "continuous"
  end

  # Dithering algorithm for color quantization.
  module DitherMethod
    NONE            = "none"
    FLOYD_STEINBERG = "floyd-steinberg"
    ATKINSON        = "atkinson"
    ORDERED         = "ordered"
  end

  # Built-in color palette presets.
  module Palette
    AUTO        = "auto"
    BLACK_WHITE = "bw"
    GRAYSCALE   = "grayscale"
    EINK        = "eink"
  end

  # Watermark layer position.
  module WatermarkLayer
    OVER  = "over"
    UNDER = "under"
  end
end
