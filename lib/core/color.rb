# Color クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
    class Color
      attr_reader :red, :green, :blue

      def initialize(red, green, blue)
        self.red = red
        self.green = green
        self.blue = blue
      end

      # 全ての色設定が 255 の場合は白として扱う
      def white?
        return red == 1.0 && green == 1.0 && blue == 1.0
      end

      def red=(red)
        if red >= 0.0 && red <= 1.0
          @red = red
        else
          raise "Color red must be include range 0..1."
        end
      end

      def green=(green)
        if green >= 0.0 && green <= 1.0
          @green = green
        else
          raise "Color green must be include range 0..1."
        end
      end

      def blue=(blue)
        if blue >= 0.0 && blue <= 1.0
          @blue = blue
        else
          raise "Color blue must be include range 0..1."
        end
      end
    end
  end
end
