# -*- coding: utf-8 -*-
# Rectangle クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP # nodoc
  module Core # nodoc
    # 矩形描画構成要素クラス
    class Rectangle < Drawable
      STYLES = {
        :solid => "solid",
      }

      FILL_PATTERNS = {
        :flat => "flat",
      }

      @@default_values = {
        :line_color   => { :red => 0, :green => 0, :blue => 0 },
        :line_width   => 1,
        :line_style   => STYLES[:solid],
        :fill_pattern => FILL_PATTERNS[:flat],
        :fill_color   => { :red => 1, :green => 1, :blue => 1 },
        :layer        => 1,
        :expand       => false,
      }

      attr_reader :region, :line_color, :line_width, :line_style, :fill_pattern, :fill_color, :expand

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))
        super(identifier, values[:layer])

        @region = Region.new(values[:region][:x].mm2pixcel,
                             values[:region][:y].mm2pixcel,
                             values[:region][:width].mm2pixcel,
                             values[:region][:height].mm2pixcel)
        @line_color = Color.new(values[:line_color][:red],
                                values[:line_color][:green],
                                values[:line_color][:blue])
        self.line_style = values[:line_style]
        self.fill_pattern = values[:fill_pattern]
        @fill_color = Color.new(values[:fill_color][:red],
                                values[:fill_color][:green],
                                values[:fill_color][:blue])
        self.line_width = values[:line_width]
        @expand = values[:expand]
      end

      def expand_region(setting)
        @expand_region = @region.dup
        @expand_region.width = setting[:width] if setting[:width]
        @expand_region.height = setting[:height] if setting[:height]
      end

      def line_width=(w)
        if w > 0
          @line_width = w
        elsif w.zero?
          @line_color = @fill_color
        else
          raise "Rectangle line width must be grater than zero."
        end
      end

      def line_style=(s)
        if STYLES.values.include?(s)
          @line_style = s
        else
          raise "Rectangle line style \"#{s}\" is unknown."
        end
      end

      def fill_pattern=(fp)
        if FILL_PATTERNS.values.include?(fp)
          @fill_pattern = fp
        else
          raise "Rectangle fill pattern \"#{fp}\" is unknown."
        end
      end

      def calculate_region(prep, region, value, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        puts "Calculate region for #{self.class}: #{self.identifier} region: #{region}" if ENV["DEBUG"]
        ret_region = Region.new(0, 0,
                                region.width - (@region.x + @region.width),
                                region.height - (@region.y + @region.height))
        return @region.x + @region.width, @region.y + @region.height
      end

      # 矩形の描画
      def draw(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # 領域判定
        calculate_region(prep, region, values)
        prep.current_page.set_line_width(@line_width.to_f)
        unless @line_color.white?
          prep.current_page.set_rgb_stroke(@line_color.red.to_f,
                                           @line_color.green.to_f,
                                           @line_color.blue.to_f)
        end
        unless @fill_color.white?
          prep.current_page.set_rgb_fill(@fill_color.red.to_f,
                                         @fill_color.green.to_f,
                                         @fill_color.blue.to_f)
        end
        region_backup = @region.dup
        if @expand_region
          @region = @expand_region.dup
          @expand_region = nil
        end
        pos_x, pos_y = calculate_pos(prep.current_page, region, @region.x, @region.y)
        prep.current_page.rectangle(pos_x, pos_y - @region.height, @region.width, @region.height)

        fill_and_or_stroke(prep)

        @region = region_backup
        prep.current_page.drawed = true
      end

      def fill_and_or_stroke(prep)
        if @fill_color.white?
          unless @line_color.white?
            prep.current_page.stroke
          end
        elsif @line_color.white?
          prep.current_page.fill
        else
          prep.current_page.fill_stroke
        end
      end
      private :fill_and_or_stroke
    end
  end
end
