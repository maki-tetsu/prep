# Page クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require "rubygems"
gem "hpdf"
require "hpdf"

module PREP # nodoc
  module Core # nodoc
    # ページ設定を保持するクラス
    class Page
      # ページサイズの設定種別
      SIZES = {
        :a4 => HPDFDoc::HPDF_PAGE_SIZE_A4, # A4
        :a3 => HPDFDoc::HPDF_PAGE_SIZE_A3, # A3
      }

      # ページ方向の設定種別
      ORIENTATIONS = {
        :portrait => HPDFDoc::HPDF_PAGE_PORTRAIT,   # 縦
        :landscape => HPDFDoc::HPDF_PAGE_LANDSCAPE, # 横
      }

      attr_reader :size, :orientation, :margin, :header_height, :footer_height

      # 初期化
      def initialize
        @size = SIZES[:a4]
        @orientation = ORIENTATIONS[:portrate]
        @margin = {
          :top => 10,
          :left => 10,
          :bottom => 10,
          :right => 10
        }
        @header_height = 0
        @footer_height = 0
      end

      def size=(size)
        if SIZES.values.include?(size)
          @size = size
        else
          raise "Unknown PAGE SIZE."
        end
      end

      def orientation=(orientation)
        if ORIENTATIONS.values.include?(orientation)
          @orientation = orientation
        else
          raise "Unknown PAGE ORIENTATION."
        end
      end

      def margin=(values)
        sym_key_values = values.keys.inject({ }) do |hash, key|
          hash[key.to_sym] = values[key]
          next hash
        end
        if (sym_key_values.keys - @margin.keys).length.zero?
          @margin.merge(values)
        else
          raise "Unknown margin keys (#{(sym_key_values.keys - @margin.keys).join(",")})."
        end
      end

      def header_height=(height)
        if height >= 0
          @header_height = height
        else
          raise "Invalid header height(#{height})."
        end
      end

      def footer_height=(height)
        if height >= 0
          @footer_height = height
        else
          raise "Invalid footer height(#{height})."
        end
      end
    end
  end
end
