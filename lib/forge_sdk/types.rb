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

  # PDF standard compliance level.
  module PdfStandard
    NONE = "none"
    A2B  = "pdf/a-2b"
    A3B  = "pdf/a-3b"
  end

  # Relationship of an embedded file to the PDF document.
  module EmbedRelationship
    ALTERNATIVE = "alternative"
    SUPPLEMENT  = "supplement"
    DATA        = "data"
    SOURCE      = "source"
    UNSPECIFIED  = "unspecified"
  end

  # PDF rendering mode.
  module PdfMode
    AUTO   = "auto"
    VECTOR = "vector"
    RASTER = "raster"
  end

  # PDF accessibility level.
  module AccessibilityLevel
    NONE    = "none"
    BASIC   = "basic"
    PDF_UA_1 = "pdf/ua-1"
  end

  # Barcode symbology type.
  module BarcodeType
    QR      = "qr"
    CODE128 = "code128"
    EAN13   = "ean13"
    UPCA    = "upca"
    CODE39  = "code39"
  end

  # Anchor position for barcode placement.
  module BarcodeAnchor
    TOP_LEFT     = "top-left"
    TOP_RIGHT    = "top-right"
    BOTTOM_LEFT  = "bottom-left"
    BOTTOM_RIGHT = "bottom-right"
  end
end
