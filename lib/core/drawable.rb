# -*- coding: utf-8 -*-
# Drawable クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
    # 描画機能が実装されていない場合に発行される例外クラス
    class NotImplementedError < StandardError; end
    # 再描画時に元の場所まで戻ったときにその時のリージョンセットを伴って戻る例外
    class ReRenderJump < StandardError
      attr_reader :region

      def initialize(region)
        @region = region
      end
    end

    # 構成要素を表現する基底クラス
    #
    # Label, Line, Rectangle などの描画構成要素の基底クラス.
    # 描画に必要となる基本的な機能が実装されている.
    class Drawable
      attr_reader :identifier, :layer

      # 初期化
      def initialize(identifier, layer = 1)
        STDERR.puts("Initializing #{self.class}: #{identifier}") if ENV['DEBUG']
        @identifier = identifier
        @layer = layer.to_i
      end

      # 描画領域計算
      def calculate_region(prep, region, values, stop_on_drawable = nil)
        raise NotImplementedError.new
      end

      # 比較メソッド
      def <=>(other)
        unless Drawable === other
          raise ArgumentError.new
        end
        return @layer <=> other.layer
      end

      # 描画処理の呼び出し
      #
      # 継承先で実装されるべきメソッド
      # 引数として描画可能領域を表現するリージョンインスタンス、
      # および、関連する値のハッシュが渡されます。
      # 描画対象は Prep#current_page から取得します。
      def draw(prep, region, values, stop_on_drawable = nil)
        raise NotImplementedError.new
      end

      # ハッシュに対して再帰的にキーが文字列の場合にシンボルに置換
      def key_string_to_symbol(hash)
        if Hash === hash
          ret_hash = hash.keys.inject({ }) do |h, key|
            case hash[key]
            when Hash
              h[key.to_sym] = key_string_to_symbol(hash[key])
            else
              h[key.to_sym] = hash[key]
            end

            next h
          end
          return ret_hash
        else
          raise "Argument not Hash."
        end
      end

      # 座標変換
      #
      # 実際に PDF 上に配置する際の座標に変換
      # 絶対補正座標と相対座標の組みで渡されて
      # x, y のリストで返却される
      def calculate_pos(page, region, x, y)
        # 絶対座標変換
        x = region.x + x
        y = region.y + y
        # Y 座標反転
        return x, page.get_height - y
      end

      # 領域計算前後で現在位置を保持して戻すためのブロック付きメソッド
      #
      # Prep インスタンスと必要に応じて元ループの方向を示す
      # 元ループの方向と内部のページ遷移方向が異なる場合のみページを元に戻す
      # 親の方向が指定されない場合は無条件にページを戻す
      def rewind_current_page(prep, parent_direction = nil)
        # 領域計算中にページ移動が発生した場合に戻すために保持
        current_page_x, current_page_y = prep.page_pos_x, prep.page_pos_y
        begin
          values = yield
        rescue ReRenderJump => e
          # ページの移動方向を確認
          # 設定ファイルの構成によっては両方に遷移する可能性があるがそれはエラーとする
          horizontal_page_move = prep.page_pos_x - current_page_x
          vertical_page_move = prep.page_pos_y - current_page_y
          if horizontal_page_move < 0 # 左方向の遷移を検出したのでエラー
            raise "Page move to left error!"
          end
          if vertical_page_move < 0 # 上方向の遷移を検出したのでエラー
            raise "Page move to up error!"
          end
          if horizontal_page_move != 0 && vertical_page_move != 0
            # 水平、垂直両方向への遷移を検出したのでエラー
            raise "Page move is too difficult!!(Please wait...)"
          end
          if parent_direction.nil?
            if horizontal_page_move != 0 || vertical_page_move != 0
              # 方向指定がない場合は戻す
              prep.current_page = { :x => current_page_x, :y => current_page_y }
              puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
            end
          elsif parent_direction == Loop::DIRECTIONS[:horizontal] && vertical_page_move > 0
            # 方向指定と異なる方向の場合は戻す(ループは水平、ページは垂直)
            prep.current_page = { :x => current_page_x, :y => current_page_y }
            puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
          elsif parent_direction == Loop::DIRECTIONS[:vertical] && horizontal_page_move > 0
            # 方向指定と異なる方向の場合は戻す(ループは垂直、ページは水平)
            prep.current_page = { :x => current_page_x, :y => current_page_y }
            puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
          end
          raise e
        end
        # 現在のページ番号を元に戻す
        horizontal_page_move = prep.page_pos_x - current_page_x
        vertical_page_move = prep.page_pos_y - current_page_y
        if horizontal_page_move < 0 # 左方向の遷移を検出したのでエラー
          raise "Page move to left error!"
        end
        if vertical_page_move < 0 # 上方向の遷移を検出したのでエラー
          raise "Page move to up error!"
        end
        if horizontal_page_move != 0 && vertical_page_move != 0
          # 水平、垂直両方向への遷移を検出したのでエラー
          raise "Page move is too difficult!!(Please wait...)"
        end
        if parent_direction.nil?
          if horizontal_page_move != 0 || vertical_page_move != 0
            # 方向指定がない場合は戻す
            prep.current_page = { :x => current_page_x, :y => current_page_y }
            puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
          end
        elsif parent_direction == Loop::DIRECTIONS[:horizontal] && vertical_page_move > 0
          # 方向指定と異なる方向の場合は戻す(ループは水平、ページは垂直)
          prep.current_page = { :x => current_page_x, :y => current_page_y }
          puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
        elsif parent_direction == Loop::DIRECTIONS[:vertical] && horizontal_page_move > 0
          # 方向指定と異なる方向の場合は戻す(ループは垂直、ページは水平)
          prep.current_page = { :x => current_page_x, :y => current_page_y }
          puts "Rewind page index to [#{current_page_x}:#{current_page_y}]" if ENV["DEBUG"]
        end

        return values
      end

      # 実際の描画を行うかどうかの判定
      def visible?(value)
        return true unless @control_visible

        return !!value
      end
    end
  end
end
