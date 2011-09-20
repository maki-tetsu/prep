# -*- coding: utf-8 -*-
# Image クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/09/12
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP # nodoc
  module Core # nodoc
    # イメージ描画構成要素クラス
    class Image < Drawable
      @@default_values = {
        :layer  => 1,
        :expand => false,
      }

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))
        super(identifier, values[:layer])

        @region = Region.new(values[:region][:x].mm2pixcel,
                             values[:region][:y].mm2pixcel,
                             values[:region][:width].mm2pixcel,
                             values[:region][:height].mm2pixcel)
        @image_path = values[:image_path].to_s
        @expand = values[:expand]
      end

      # イメージ描画領域の計算
      def calculate_region(prep, region, value, stop_on_drawable = nil)
        if self == stop_on_drawable
          raise ReRenderJump.new(region)
        end

        puts "Calculate region for #{self.class}: #{self.identifier} region: #{region}" if ENV["DEBUG"]
        ret_region = Region.new(0, 0,
                                region.width - (@region.x + @region.width),
                                region.height - (@region.y + @region.height))
        return @region.x + @region.width, @region.y + @region.height
      end

      # イメージの描画
      def draw(prep, region, value, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # 領域判定
        calculate_region(prep, region, value)
        
        # イメージファイルの指定があるか確認
        if value.to_s != ""
          # Load png image from specific file path
          image_path = value.to_s
        else
          # Load png image from default path
          image_path = @image_path.dup
        end
        begin
          image_data = prep.pdf.load_png_image_from_file(image_path)
        rescue => e
          raise "Failed to load the PNG image from '#{image_path}'"
        end
        region_backup = @region.dup
        if @expand_region
          @region = @expand_region.dup
          @expand_region = nil
        end
        pos_x, pos_y = calculate_pos(prep.current_page, region, @region.x, @region.y)
        # draw png image
        prep.current_page.draw_image(image_data,
                                     pos_x, pos_y - @region.height,
                                     @region.width, @region.height)
        @region = region_backup
        prep.current_page.drawed = true
      end
    end
  end
end
