# Region クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc

    # リージョンの幅がマイナスになった場合に発行される例外
    class RegionWidthOverflowError < StandardError; end
    # リージョンの高さがマイナスになった場合に発行される例外
    class RegionHeightOverflowError < StandardError; end

    class Region
      attr_reader :x, :y, :width, :height

      def initialize(x, y, width, height)
        self.x = x
        self.y = y

        self.width = width
        self.height = height
      end

      def x=(x)
        @x = x
      end

      def y=(y)
        @y = y
      end

      def width=(width)
        if width >= 0
          @width = width
        else
          raise RegionWidthOverflowError.new("Region width must be grater than zero.")
        end
      end

      def height=(height)
        if height >= 0
          @height = height
        else
          raise RegionHeightOverflowError.new("Region height must be grater than zero.")
        end
      end

      def to_s
        "[x=#{x},y=#{y},w=#{width},h=#{height}]"
      end
    end
  end
end
