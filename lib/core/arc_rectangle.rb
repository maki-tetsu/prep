# -*- coding: utf-8 -*-
# ArcRectangle クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/10/10
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "color")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "rectangle")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP # nodoc
  module Core # nodoc
    # 角丸矩形描画構成要素クラス
    class ArcRectangle < Rectangle
      @@default_values[:round_arc] = nil

      attr_reader :round_arc

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))
        @round_arc = values.delete(:round_arc)

        if @round_arc.nil?
          raise "round_arc must be specified for arc_rectangle."
        else
          @round_arc = @round_arc.mm2pixcel
        end

        super(identifier, values)
      end

      # 角丸矩形の描画
      def draw(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # 領域判定
        calculate_region(prep, region, values)

        if visible?(values)
          # 円弧描画時は 5% 太さを上げる
          prep.current_page.set_line_width(@line_width.to_f * 1.05)
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
        end

        region_backup = @region.dup
        if @expand_region
          @region = @expand_region.dup
          @expand_region = nil
        end
        pos_x, pos_y = calculate_pos(prep.current_page, region, @region.x, @region.y)

        if visible?(values)
          ### 塗り潰し描画
          unless @fill_color.white?
            # 縦方向
            prep.current_page.rectangle(pos_x + @round_arc, pos_y - @region.height,
                                        @region.width - (@round_arc * 2), @region.height)
            prep.current_page.fill
            # 横方向
            prep.current_page.rectangle(pos_x, pos_y - @region.height + @round_arc,
                                        @region.width, @region.height - (@round_arc * 2))
            prep.current_page.fill
          end

          # ここからが本番
          ### ４角の円弧を描画
          # 左上
          unless @fill_color.white?
            prep.current_page.move_to(pos_x + @round_arc, pos_y - @round_arc)
            prep.current_page.line_to(pos_x, pos_y - @round_arc)
            prep.current_page.arc(pos_x + @round_arc,
                                  pos_y - @round_arc,
                                  @round_arc, 360 * 0.75, 360)
            prep.current_page.line_to(pos_x + @round_arc, pos_y - @round_arc)
            prep.current_page.fill
          end
          unless @line_color.white?
            prep.current_page.arc(pos_x + @round_arc,
                                  pos_y - @round_arc,
                                  @round_arc, 360 * 0.75, 360)
            prep.current_page.stroke
          end
          # 右上
          unless @fill_color.white?
            prep.current_page.move_to(pos_x + @region.width - @round_arc, pos_y - @round_arc)
            prep.current_page.line_to(pos_x + @region.width - @round_arc, pos_y)
            prep.current_page.arc(pos_x + @region.width - @round_arc,
                                  pos_y - @round_arc,
                                  @round_arc, 0, 360 * 0.25)
            prep.current_page.line_to(pos_x + @region.width - @round_arc, pos_y - @round_arc)
            prep.current_page.fill
          end
          unless @line_color.white?
            prep.current_page.arc(pos_x + @region.width - @round_arc,
                                  pos_y - @round_arc,
                                  @round_arc, 0, 360 * 0.25)
            prep.current_page.stroke
          end
          # 左下
          unless @fill_color.white?
            prep.current_page.move_to(pos_x + @round_arc, pos_y - @region.height + @round_arc)
            prep.current_page.line_to(pos_x + @round_arc, pos_y - @region.height)
            prep.current_page.arc(pos_x + @round_arc,
                                  pos_y - @region.height + @round_arc,
                                  @round_arc, 360 * 0.5, 360 * 0.75)
            prep.current_page.line_to(pos_x + @round_arc, pos_y - @region.height + @round_arc)
            prep.current_page.fill
          end
          unless @line_color.white?
            prep.current_page.arc(pos_x + @round_arc,
                                  pos_y - @region.height + @round_arc,
                                  @round_arc, 360 * 0.5, 360 * 0.75)
            prep.current_page.stroke
          end
          # 右下
          unless @fill_color.white?
            prep.current_page.move_to(pos_x + @region.width - @round_arc, pos_y - @region.height + @round_arc)
            prep.current_page.line_to(pos_x + @region.width, pos_y - @region.height + @round_arc)
            prep.current_page.arc(pos_x + @region.width - @round_arc,
                                  pos_y - @region.height + @round_arc,
                                  @round_arc, 360 * 0.25, 360 * 0.5)
            prep.current_page.line_to(pos_x + @region.width - @round_arc, pos_y - @region.height + @round_arc)
            prep.current_page.fill
          end
          unless @line_color.white?
            prep.current_page.arc(pos_x + @region.width - @round_arc,
                                  pos_y - @region.height + @round_arc,
                                  @round_arc, 360 * 0.25, 360 * 0.5)
            prep.current_page.stroke
          end

          # 元の太さへ
          prep.current_page.set_line_width(@line_width.to_f)

          # ### ４辺描画
          unless @line_color.white?
            # 上
            prep.current_page.move_to(pos_x + @round_arc,                 pos_y)
            prep.current_page.line_to(pos_x + @region.width - @round_arc, pos_y)
            prep.current_page.stroke
            # 下
            prep.current_page.move_to(pos_x + @round_arc,                 pos_y - @region.height)
            prep.current_page.line_to(pos_x + @region.width - @round_arc, pos_y - @region.height)
            prep.current_page.stroke
            # 左
            prep.current_page.move_to(pos_x,                              pos_y - @region.height + @round_arc)
            prep.current_page.line_to(pos_x,                              pos_y - @round_arc)
            prep.current_page.stroke
            # 右
            prep.current_page.move_to(pos_x + @region.width,              pos_y - @region.height + @round_arc)
            prep.current_page.line_to(pos_x + @region.width,              pos_y - @round_arc)
            prep.current_page.stroke
          end
        end

        @region = region_backup
        prep.current_page.drawed = true
      end
    end
  end
end
