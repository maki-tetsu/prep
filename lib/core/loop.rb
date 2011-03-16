# Loop クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")

module PREP # nodoc
  module Core # nodoc
    # ループ読み込みクラスの定義
    class Loop < Drawable
      DIRECTIONS = {
        :horizontal => 'horizontal',
        :vertical => 'vertical'
      }

      @@default_values = {
        :direction => DIRECTIONS[:vertical],
        :gap => 0,
      }

      attr_reader :direction, :gap, :header_group, :iterator_group, :footer_group, :point

      def initialize(identifier, values = { })
        super(identifier)

        values = @@default_values.merge(key_string_to_symbol(values))

        self.direction = values[:direction]
        @header_group = values[:header]
        @iterator_group = values[:iterator]
        @gap = values[:gap]
        @footer_group = values[:footer]
        @point = Point.new(values[:x], values[:y])
      end

      def direction=(d)
        if DIRECTIONS.values.include?(d)
          @direction = d
        else
          raise "Unknown direction \"#{d}\"."
        end
      end

      # データに依存してサイズが変化する可能性がある
      #
      # また、伸長方向 direction によって占有領域の計算方向が変化
      def calculate_region(prep, region, value)
        # リージョン補正
        current_region = region.dup
        current_region.x += point.x
        current_region.y += point.y
        current_region.width -= point.x
        current_region.height -= point.y

        # ヘッダの領域サイズを計算
        unless @header_group.nil?
          header = prep.group(@header_group)
          w, h = header.calculate_region(prep, current_region, values[:header])
          # 描画したので、方向に応じてリージョン補正
          if @direction == DIRECTIONS[:horizontal] # 右方向
            current_region.x += w + @gap
            current_region.width -= w + @gap
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            current_region.y += h + @gap
            current_region.height -= h + @gap
          end
        end

        # 繰り返し部分の領域サイズを計算
        unless @iterator_group.nil?
          iterator = prep.group(@iterator_group)
          values[:values].each do |iterator_values|
            w, h = iterator.calculate_region(prep, current_region, iterator_values)
            # 描画したので、方向に応じてリージョン補正
            if @direction == DIRECTIONS[:horizontal] # 右方向
              current_region.x += w + @gap
              current_region.width -= w + @gap
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              current_region.y += h + @gap
              current_region.height -= h + @gap
            end
          end
        end

        # フッタの領域サイズを計算
        unless @footer_group.nil?
          footer = prep.group(@footer_group)
          w, h = footer.calculate_region(prep, region, values[:footer])
          # 描画したので、方向に応じてリージョン補正
          if @direction == DIRECTIONS[:horizontal] # 右方向
            current_region.x += w
            current_region.width -= w
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            current_region.y += h
            current_region.height -= h
          end
        end

        # 最終的にリージョン補正位置から必要な領域を計算
        # 元のリージョン範囲から最終的に残っているリージョン範囲を減算すればよい
        # TODO ページ切り替え対応
        return region.width - current_region.width, region.height - current_region.height
      end

      # 実際の描画を実施
      def draw(prep, region, values)
        # リージョン補正
        current_region = region.dup
        current_region.x += point.x
        current_region.y += point.y
        current_region.width -= point.x
        current_region.height -= point.y

        # ヘッダの領域サイズを計算
        unless @header_group.nil?
          header = prep.group(@header_group)
          w, h = header.calculate_region(prep, current_region, values[:header])
          header.draw(prep, current_region, values[:header])
          # 描画したので、方向に応じてリージョン補正
          if @direction == DIRECTIONS[:horizontal] # 右方向
            current_region.x += w + @gap
            current_region.width -= w + @gap
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            current_region.y += h + @gap
            current_region.height -= h + @gap
          end
        end

        # 繰り返し部分の領域サイズを計算
        unless @iterator_group.nil?
          iterator = prep.group(@iterator_group)
          values[:values].each do |iterator_values|
            w, h = iterator.calculate_region(prep, current_region, iterator_values)
            iterator.draw(prep, current_region, iterator_values)
            # 描画したので、方向に応じてリージョン補正
            if @direction == DIRECTIONS[:horizontal] # 右方向
              current_region.x += w + @gap
              current_region.width -= w + @gap
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              current_region.y += h + @gap
              current_region.height -= h + @gap
            end
          end
        end

        # フッタの領域サイズを計算
        unless @footer_group.nil?
          footer = prep.group(@footer_group)
          w, h = footer.calculate_region(prep, current_region, values[:footer])
          footer.draw(prep, current_region, values[:footer])
          # 描画したので、方向に応じてリージョン補正
          if @direction == DIRECTIONS[:horizontal] # 右方向
            current_region.x += w
            current_region.width -= w
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            current_region.y += h
            current_region.height -= h
          end
        end
      end
    end
  end
end
