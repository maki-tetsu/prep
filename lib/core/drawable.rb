# Drawable クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
    # 描画機能が実装されていない場合に発行される例外クラス
    class NotImplementedError < StandardError; end

    # 構成要素を表現する基底クラス
    #
    # Label, Line, Rectangle などの描画構成要素の基底クラス.
    # 描画に必要となる基本的な機能が実装されている.
    class Drawable
      attr_reader :identifier

      # 初期化
      def initialize(identifier)
        @identifier = identifier
      end

      # 描画領域計算
      def calculate_region(prep, region, values)
        raise NotImplementedError.new
      end

      # 描画処理の呼び出し
      #
      # 継承先で実装されるべきメソッド
      # 引数として描画対象のページインスタンスと描画可能領域を
      # 表現するリージョンインスタンスを持ちます。
      def draw(prep, region, values)
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
    end
  end
end
