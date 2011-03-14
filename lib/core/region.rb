# Region クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
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
        if width > 0
          @width = width
        else
          raise "Region width must be grater than zero."
        end
      end

      def height=(height)
        if height > 0
          @height = height
        else
          raise "Region height must be grater than zero."
        end
      end
    end
  end
end
