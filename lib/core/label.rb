# Label クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

require "nkf"

module PREP # nodoc
  module Core # nodoc
    # 文字列描画構成要素クラス
    class Label < Drawable
      ALIGNS = {
        :left    => HPDFDoc::HPDF_TALIGN_LEFT,
        :right   => HPDFDoc::HPDF_TALIGN_RIGHT,
        :center  => HPDFDoc::HPDF_TALIGN_CENTER,
        :justify => HPDFDoc::HPDF_TALIGN_JUSTIFY,
      }

      @@default_values = {
        :align => "left",
        :font => "MS-Mincyo",
        :size => 12,
        :color => { :red => 0, :green => 0, :blue => 0 },
        :layer => 3,
        :expand => false,
      }

      attr_reader :region, :label, :align, :font, :color, :size, :expand

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))
        super(identifier, values[:layer])

        @region = Region.new(values[:region][:x].mm2pixcel,
                             values[:region][:y].mm2pixcel,
                             values[:region][:width].mm2pixcel,
                             values[:region][:height].mm2pixcel)
        if values[:label].nil?
          raise "Label string cannot be blank for \"#{identifier}\""
        else
          @label = values[:label]
        end

        if ALIGNS.keys.include?(values[:align].to_sym)
          @align = ALIGNS[values[:align].to_sym]
        else
          raise "Unknown label alignment option \"#{values[:align]}\"."
        end
        if values[:font].nil? || values[:font] == ""
          raise "Lable font must be specified."
        else
          @font = values[:font]
        end
        @color = Color.new(values[:color][:red],
                           values[:color][:green],
                           values[:color][:blue])
        if values[:size].nil? || values[:size] == ""
          raise "Label size must be specified."
        else
          @size = values[:size]
        end
        @expand = values[:expand]
      end

      def expand_region(setting)
        @expand_region = @region.dup
        @expand_region.width = setting[:width] if setting[:width]
        @expand_region.height = setting[:height] if setting[:height]
      end

      # 幅と高さを返却
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

      # 指定された領域を元に再計算して描画を実施
      def draw(prep, region, value, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # 領域判定
        calculate_region(prep, region, value)
        # 文字列指定があるかを確認
        if value.nil? || value.to_s == ""
          string = self.label.dup
        else
          string = value.to_s
        end
        # 文字列指定に変数がある場合は判定
        string.gsub!("[[[current_page_number]]]", prep.current_page_number.to_s)
        string.gsub!("[[[total_page_count]]]", prep.total_pages.to_s)
        # 文字列の描画
        font = prep.pdf.get_font(self.font, "90ms-RKSJ-H")
        prep.current_page.begin_text
        prep.current_page.set_rgb_fill(@color.red.to_f, @color.green.to_f, @color.blue.to_f)
        region_backup = @region.dup
        if @expand_region
          @region = @expand_region.dup
          @expand_region = nil
        end
        left, top = calculate_pos(prep.current_page, region, @region.x, @region.y)
        right, bottom = left + @region.width, top - @region.height
        prep.current_page.set_font_and_size(font, @size)
        prep.current_page.text_rect(left, top, right, bottom,
                                    NKF.nkf("--oc=cp932 -W8", string), @align)
        prep.current_page.end_text
        @region = region_backup
        prep.current_page.drawed = true
      end
    end
  end
end
