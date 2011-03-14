# Line クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "point")

module PREP # nodoc
  module Core # nodoc
    # 直線描画構成要素クラス
    class Line < Drawable
      STYLES = {
        :solid => "solid",
      }

      @@default_values = {
        :color => { :red => 0, :green => 0, :blue => 0 },
        :width => 1,
        :style => STYLES[:solid],
      }

      attr_reader :start_point, :end_point, :color, :width, :style

      def initialize(identifier, values = { })
        super(identifier)
        values = @@default_values.merge(key_string_to_symbol(values))

        @start_point = Point.new(values[:start][:x], values[:start][:y])
        @end_point = Point.new(values[:end][:x], values[:end][:y])
        @color = Color.new(values[:color][:red], values[:color][:green], values[:color][:blue])
        self.width = values[:width]
        self.style = values[:style]
      end

      def width=(w)
        if w > 0
          @width = w
        else
          raise "Line width must be grater than zero."
        end
      end

      def style=(s)
        if STYLES.values.include?(s)
          @style = s
        else
          raise "Line style \"#{s}\" is unknown."
        end
      end

      # 直線の描画
      def draw(pdf, page, region, values)
        # 幅指定
        page.set_line_width(@width)
        # 色指定
        page.set_rgb_stroke(@color.red.to_f,
                            @color.green.to_f,
                            @color.blue.to_f)
        # 開始位置へ移動
        start_x, start_y = calculate_pos(page, region, @start_point.x.to_f, @start_point.y.to_f)
        end_x, end_y = calculate_pos(page, region, @end_point.x.to_f, @end_point.y.to_f)
        page.move_to(start_x, start_y)
        # 終了位置へ向けて直線描画
        page.line_to(end_x, end_y)
        # 実描画
        page.stroke
      end
    end
  end
end
