# Loop クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

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
        :page_break => false,
        :layer => 4,
      }

      attr_reader :direction, :gap, :header_group, :iterator_group, :footer_group, :point, :page_break, :width, :height

      def initialize(identifier, values = { })
        values = @@default_values.merge(key_string_to_symbol(values))

        super(identifier, values[:layer])

        self.direction = values[:direction]
        @header_group = values[:header]
        @iterator_group = values[:iterator]
        @gap = values[:gap].mm2pixcel
        @footer_group = values[:footer]
        @point = Point.new(values[:x].mm2pixcel, values[:y].mm2pixcel)
        @page_break = values[:page_break]
      end

      def direction=(d)
        if DIRECTIONS.values.include?(d)
          @direction = d
        else
          raise "Unknown direction \"#{d}\"."
        end
      end

      # データセット雛形を生成
      def generate_sample_dataset(prep)
        dataset = { }

        unless @header_group.nil?
          header = prep.group(@header_group)
          dataset[:header] = header.generate_sample_dataset(prep)
        end
        iterator = prep.group(@iterator_group)
        dataset[:values] = [iterator.generate_sample_dataset(prep)]
        unless @footer_group.nil?
          footer = prep.group(@footer_group)
          dataset[:footer] = footer.generate_sample_dataset(prep)
        end

        return dataset
      end

      # データに依存してサイズが変化する可能性がある
      def calculate_region(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        puts "Calculate region for #{self.class}: #{self.identifier} region: #{region}" if ENV["DEBUG"]
        # リージョン補正
        current_region = fit_region(region)
        # 描画計算の初期位置を保持
        @initial_calculate_region = current_region.dup

        # ヘッダの領域サイズを計算
        current_region = calculate_header_region(prep, current_region, values, stop_on_drawable)
        puts "Header:\t#{current_region}" if ENV["DEBUG"]

        # 繰り返し部分の領域サイズを計算
        current_region = calculate_iterator_region(prep, current_region, values, stop_on_drawable)
        puts "Iterator:\t#{current_region}" if ENV["DEBUG"]

        # フッタの領域サイズを計算
        current_region = calculate_footer_region(prep, current_region, values, stop_on_drawable)
        puts "Footer:\t#{current_region}" if ENV["DEBUG"]

        # 最終的にリージョン補正位置から必要な領域を計算
        # 元のリージョン範囲から最終的に残っているリージョン範囲を減算すればよい
        ret_region = Region.new(0, 0,
                                region.width - current_region.width,
                                region.height - current_region.height)

        # 進行方向じゃない方向に対しての差分は別途取得
        if @direction == DIRECTIONS[:horizontal]
          ret_region.height = @height
        else # if @direction == DIRECTIONS[:vertical]
          ret_region.width = @width
        end

        return ret_region.width, ret_region.height
      end

      # リージョン補正
      #
      # 相対位置情報を元にリージョンを補正して返却
      def fit_region(region)
        current_region = region.dup
        current_region.x += point.x
        current_region.y += point.y
        current_region.width -= point.x
        current_region.height -= point.y

        return current_region
      end

      # 実際の描画を実施
      def draw(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        # リージョン補正
        current_region = fit_region(region)
        # 描画計算の初期位置を保持
        @initial_draw_region = current_region.dup

        # 領域に関する情報を取得
        expand_setting = { }
        if !@page_break
          # 描画に先立ち領域拡張設定を実施
          # ループ要素の描画領域を算出（事前計算）
          rewind_current_page(prep) do
            calculate_region(prep, region.dup, values)
          end
          if @direction == DIRECTIONS[:horizontal]
            expand_setting[:height] = @height
          else # if @direction == DIRECTIONS[:vertical]
            expand_setting[:width] = @width
          end
        end
        # ヘッダおよびフッタの子に関してワンタイム設定を実施
        unless @header_group.nil?
          header = prep.group(@header_group)
          header.drawable_items.each do |drawable|
            if Label === drawable || Rectangle === drawable
              if drawable.expand
                drawable.expand_region(expand_setting)
              end
            end
          end
        end
        unless @footer_group.nil?
          footer = prep.group(@footer_group)
          footer.drawable_items.each do |drawable|
            if Label === drawable || Rectangle === drawable
              if drawable.expand
                drawable.expand_region(expand_setting)
              end
            end
          end
        end
        # ヘッダブロック描画
        current_region = draw_header(prep, current_region, values, stop_on_drawable)

        # 繰り返しブロック描画
        current_region = draw_iterator(prep, current_region, values, stop_on_drawable)

        # フッタブロック描画
        current_region = draw_footer(prep, current_region, values, stop_on_drawable)
      end

      private

      # ヘッダ構成要素を描画するためのメソッド
      #
      # 描画後に新しい region を返却
      def draw_header(prep, region, values, stop_on_drawable = nil)
        unless @header_group.nil?
          header = prep.group(@header_group)
          w, h = rewind_current_page(prep) do
            header.calculate_region(prep, region, values[:header], stop_on_drawable)
          end
          rewind_current_page(prep, self.direction) do
            header.draw(prep, region, values[:header], stop_on_drawable)
          end
          if @direction == DIRECTIONS[:horizontal] # 右方向
            if (has_iterator_group?(prep) && !values[:values].nil? && !values[:values].size.zero?) || has_footer_group?(prep)
              w += @gap
            end
            region.x += w
            region.width -= w
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            if (has_iterator_group?(prep) && !values[:values].nil? && !values[:values].size.zero?) || has_footer_group?(prep)
              h += @gap
            end
            region.y += h
            region.height -= h
          end
        end

        return region
      end

      # ヘッダ構成要素の描画領域を計算するためのメソッド
      def calculate_header_region(prep, region, values, stop_on_drawable = nil)
        unless @header_group.nil?
          header = prep.group(@header_group)
          w, h = header.calculate_region(prep, region, values[:header], stop_on_drawable)
          if @direction == DIRECTIONS[:horizontal] # 右方向
            if (has_iterator_group?(prep) && !values[:values].nil? && !values[:values].size.zero?) || has_footer_group?(prep)
              w += @gap
            end
            region.x += w
            region.width -= w
            @height ||= h
            @height = h if @height < h
          else # if @direction == DIRECTIONS[:vertical] # 下方向
            if (has_iterator_group?(prep) && !values[:values].nil? && !values[:values].size.zero?) || has_footer_group?(prep)
              h += @gap
            end
            region.y += h
            region.height -= h
            @width ||= w
            @width = w if @width < w
          end
        end

        return region
      end

      # 繰返し構成要素を描画するためのメソッド
      def draw_iterator(prep, region, values, stop_on_drawable = nil)
        iterator = prep.group(@iterator_group)
        values[:values].each_with_index do |iterator_values, index|
          begin
            w, h = rewind_current_page(prep) do
              iterator.calculate_region(prep, region, iterator_values, stop_on_drawable)
            end
            rewind_current_page(prep, self.direction) do
              iterator.draw(prep, region, iterator_values, stop_on_drawable)
            end
            # 描画したので、方向に応じてリージョン補正
            if @direction == DIRECTIONS[:horizontal] # 右方向
              if has_footer_group?(prep) || (values[:values].size > index + 1)
                w += @gap
              end
              region.x += w
              region.width -= w
              @height ||= h
              @height = h if @height < h
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              if has_footer_group?(prep) || (values[:values].size > index + 1)
                h += @gap
              end
              region.y += h
              region.height -= h
              @width ||= w
              @width = w if @width < w
            end
          rescue RegionWidthOverflowError
            # 幅オーバーフロー時のページ切り替え対応
            if @page_break && @direction == DIRECTIONS[:horizontal]
              next_page_exist = prep.exists_move_to_page?(1, 0)

              page = prep.move_page_to(1, 0)
              if next_page_exist
                region = @initial_draw_region.dup
              else
                region = prep.page_content_region
                # 過去を再描画
                begin
                  prep.group(:content).draw(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRedering Error!!"
                end
              end
              region = draw_header(prep, region, values, stop_on_drawable)
              # リトライ
              retry
            end
            raise
          rescue RegionHeightOverflowError
            # 高さオーバーフロー時のページ切り替え対応
            if @page_break && @direction == DIRECTIONS[:vertical]
              next_page_exist = prep.exists_move_to_page?(0, 1)
              page = prep.move_page_to(0, 1)
              if next_page_exist
                region = @initial_draw_region.dup
              else
                region = prep.page_content_region
                # 過去を再描画
                begin
                  prep.group(:content).draw(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              # ヘッダを再描画
              region = draw_header(prep, region, values, stop_on_drawable)
              # リトライ
              retry
            end
            raise
          end
        end

        return region
      end

      # 繰返し構成要素の描画領域を計算するためのメソッド
      def calculate_iterator_region(prep, region, values, stop_on_drawable = nil)
        iterator = prep.group(@iterator_group)
        values[:values].each_with_index do |iterator_values, index|
          begin
            w, h = iterator.calculate_region(prep, region, iterator_values, stop_on_drawable)
            # 描画したので、方向に応じてリージョン補正
            if @direction == DIRECTIONS[:horizontal] # 右方向
              if has_footer_group?(prep) || (values[:values].size > index + 1)
                w += @gap
              end
              region.x += w
              region.width -= w
              @height ||= h
              @height = h if @height < h
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              if has_footer_group?(prep) || (values[:values].size > index + 1)
                h += @gap
              end
              region.y += h
              region.height -= h
              @width ||= w
              @width = w if @width < w
            end
          rescue RegionWidthOverflowError
            # 幅オーバーフロー時のページ切り替え対応
            if @page_break && @direction == DIRECTIONS[:horizontal]
              next_page_exist = prep.exists_move_to_page?(1, 0)

              page = prep.move_page_to(1, 0)
              if next_page_exist
                region = @initial_calculate_region.dup
              else
                region = prep.page_content_region
                # 過去を再計算
                begin
                  prep.group(:content).calculate_region(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              # ヘッダを再計算
              region = calculate_header_region(prep, region, values, stop_on_drawable)
              # リトライ
              retry
            end
            raise
          rescue RegionHeightOverflowError
            # 高さオーバーフロー時のページ切り替え対応
            if @page_break && @direction == DIRECTIONS[:vertical]
              next_page_exist = prep.exists_move_to_page?(0, 1)

              page = prep.move_page_to(0, 1)
              if next_page_exist
                region = @initial_calculate_region.dup
              else
                region = prep.page_content_region
                # 過去を再計算
                begin
                  prep.group(:content).calculate_region(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              # ヘッダを再計算
              region = calculate_header_region(prep, region, values, stop_on_drawable)
              # リトライ
              retry
            end
            raise
          end
        end

        return region
      end

      # フッタ構成要素を描画するためのメソッド
      def draw_footer(prep, region, values, stop_on_drawable = nil)
        unless @footer_group.nil?
          begin
            footer = prep.group(@footer_group)
            w, h = rewind_current_page(prep) do
              footer.calculate_region(prep, region, values[:footer], stop_on_drawable)
            end
            rewind_current_page(prep, self.direction) do
              footer.draw(prep, region, values[:footer], stop_on_drawable)
            end
            if @direction == DIRECTIONS[:horizontal] # 右方向
              region.x += w
              region.width -= w
              @height ||= h
              @height = h if @height < h
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              region.y += h
              region.height -= h
              @width ||= w
              @width = w if @width < w
            end
          rescue RegionWidthOverflowError
            if @page_break && @direction == DIRECTIONS[:horizontal]
              next_page_exist = prep.exists_move_to_page?(1, 0)

              page = prep.move_page_to(1, 0)
              if next_page_exist
                region = @initial_draw_region.dup
              else
                region = prep.page_content_region
                # 過去を再描画
                begin
                  prep.group(:content).draw(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              region = draw_header(prep, region, values, stop_on_drawable)
              retry
            end
            raise
          rescue RegionHeightOverflowError
            if @page_break && @direction == DIRECTIONS[:vertical]
              next_page_exist = prep.exists_move_to_page?(0, 1)

              page = prep.move_page_to(0, 1)
              if next_page_exist
                region = @initial_draw_region.dup
              else
                region = prep.page_content_region
                # 過去を再描画
                begin
                  prep.group(:content).draw(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              region = draw_header(prep, region, values, stop_on_drawable)
              retry
            end
            raise
          end
        end

        return region
      end

      # フッタ構成要素の描画領域を計算するためのメソッド
      def calculate_footer_region(prep, region, values, stop_on_drawable = nil)
        unless @footer_group.nil?
          begin
            footer = prep.group(@footer_group)
            w, h = footer.calculate_region(prep, region, values[:footer], stop_on_drawable)
            if @direction == DIRECTIONS[:horizontal] # 右方向
              region.x += w
              region.width -= w
              @height ||= h
              @height = h if @height < h
            else # if @direction == DIRECTIONS[:vertical] # 下方向
              region.y += h
              region.height -= h
              @width ||= w
              @width = w if @width < w
            end
          rescue RegionWidthOverflowError
            if @page_break && @direction == DIRECTIONS[:horizontal]
              next_page_exist = prep.exists_move_to_page?(1, 0)

              page = prep.move_page_to(1, 0)
              if next_page_exist
                region = @initial_calculate_region.dup
              else
                region = prep.page_content_region
                # 過去を再計算
                begin
                  prep.group(:content).calculate_region(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              region = calculate_header_region(prep, region, values, stop_on_drawable)
              retry
            end
            raise
          rescue RegionHeightOverflowError
            if @page_break && @direction == DIRECTIONS[:vertical]
              next_page_exist = prep.exists_move_to_page?(0, 1)

              page = prep.move_page_to(0, 1)
              if next_page_exist
                region = @initial_calculate_region.dup
              else
                region = prep.page_content_region
                # 過去を再計算
                begin
                  prep.group(:content).calculate_region(prep, region, prep.values[:content], self)
                rescue ReRenderJump => e
                  region = fit_region(e.region)
                else
                  raise "ReRendering Error!!"
                end
              end
              region = calculate_header_region(prep, region, values, stop_on_drawable)
              retry
            end
            raise
          end
        end

        return region
      end

      # ヘッダグループの設定有無を確認
      def has_header_group?(prep)
        if @header_group.nil?
          return false
        else
          return prep.has_group?(@header_group)
        end
      end

      # 繰返しグループの設定有無を確認
      def has_iterator_group?(prep)
        if @iterator_group.nil?
          return false
        else
          return prep.has_group?(@iterator_group)
        end
      end

      # フッタグループの設定有無を確認
      def has_footer_group?(prep)
        if @footer_group.nil?
          return false
        else
          return prep.has_group?(@footer_group)
        end
      end
    end
  end
end
