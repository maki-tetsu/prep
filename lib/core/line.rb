# -*- coding: utf-8 -*-
# Line クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "point")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP # nodoc
  module Core # nodoc
    # 直線描画構成要素クラス
    class Line < Drawable
      STYLES = {
        :solid => "solid",
      }

      @@default_values = {
        :color           => { :red => 0, :green => 0, :blue => 0 },
        :width           => 1,
        :style           => STYLES[:solid],
        :layer           => 2,
        :control_visible => false,
      }

      attr_reader :start_point, :end_point, :color, :width, :style

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))
        super(identifier, values[:layer])

        @start_point = Point.new(values[:start][:x].mm2pixcel, values[:start][:y].mm2pixcel)
        @end_point = Point.new(values[:end][:x].mm2pixcel, values[:end][:y].mm2pixcel)
        @color = Color.new(values[:color][:red], values[:color][:green], values[:color][:blue])
        self.width = values[:width]
        self.style = values[:style]
        @control_visible = values[:control_visible]
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

      def calculate_region(prep, region, value, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        puts "Calculate region for #{self.class}: #{self.identifier} region: #{region}" if ENV["DEBUG"]
        width = [@start_point.x, @end_point.x].max
        height = [@start_point.y, @end_point.y].max

        ret_region = Region.new(0, 0,
                                region.width - width,
                                region.height - height)
        return width, height
      end

      # 直線の描画
      def draw(prep, region, value, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # 領域判定
        calculate_region(prep, region, value)

        if visible?(value)
          # 幅指定
          prep.current_page.set_line_width(@width)
          # 色指定
          prep.current_page.set_rgb_stroke(@color.red.to_f,
                                           @color.green.to_f,
                                           @color.blue.to_f)
          # 開始位置へ移動
          start_x, start_y = calculate_pos(prep.current_page, region, @start_point.x.to_f, @start_point.y.to_f)
          end_x, end_y = calculate_pos(prep.current_page, region, @end_point.x.to_f, @end_point.y.to_f)
          prep.current_page.move_to(start_x, start_y)
          # 終了位置へ向けて直線描画
          prep.current_page.line_to(end_x, end_y)
          # 実描画
          prep.current_page.stroke
        end

        prep.current_page.drawed = true
      end
    end
  end
end
