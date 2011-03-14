# Label クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "region")

require "nkf"

module PREP # nodoc
  module Core # nodoc
    # 文字列描画構成要素クラス
    class Label < Drawable
      ALIGNS = {
        :left   => "left",
        :right  => "right",
        :center => "center"
      }

      @@default_values = {
        :align => ALIGNS[:left],
        :font => "MS-Mincyo",
        :size => 12,
        :color => { :red => 0, :green => 0, :blue => 0 },
      }

      attr_reader :region, :label, :align, :font, :color, :size

      def initialize(identifier, values = { })
        super(identifier)
        values = @@default_values.merge(key_string_to_symbol(values))

        @region = Region.new(values[:region][:x], values[:region][:y],
                             values[:region][:width], values[:region][:height])
        if values[:label].nil?
          raise "Label string cannot be blank for \"#{identifier}\""
        else
          @label = values[:label]
        end

        if ALIGNS.values.include?(values[:align])
          @align = values[:align]
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
      end

      # 指定された領域を元に再計算して描画を実施
      #
      # TODO align 指定が効かない
      def draw(pdf, page, region, value)
        # 文字列指定があるかを確認
        if value.nil?
          string = self.label
        else
          string = value.to_s
        end
        # 文字列の描画
        font = pdf.get_font(self.font, "90ms-RKSJ-H")
        page.begin_text
        page.set_rgb_fill(@color.red.to_f, @color.green.to_f, @color.blue.to_f)
        pos_x, pos_y = calculate_pos(page, region, @region.x, @region.y)
        page.move_text_pos(pos_x, pos_y - @region.height)
        page.set_font_and_size(font, @size)
        page.show_text(NKF.nkf("--oc=cp932 -W8", string))
        page.end_text
      end
    end
  end
end
