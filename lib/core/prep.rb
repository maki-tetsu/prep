# -*- coding: utf-8 -*-
# Prep クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require "yaml"
require "rubygems"
gem "hpdf"
require "hpdf"

require File.join(File.dirname(__FILE__), "label")
require File.join(File.dirname(__FILE__), "line")
require File.join(File.dirname(__FILE__), "rectangle")
require File.join(File.dirname(__FILE__), "arc_rectangle")
require File.join(File.dirname(__FILE__), "group")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "page")
require File.join(File.dirname(__FILE__), "page_ext")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP
  module Core
    # PREP 用例外
    #
    # 帳票生成時に発生するあらゆる例外を補足して再発生させる際に利用
    class PrepError < StandardError
      # 元々のエラー
      attr_reader :original_error

      def initialize(error)
        @original_error = error
      end
    end
    # PREP の中心クラス
    class Prep
      attr_reader :pdf, :pages, :page_pos_x, :page_pos_y, :values

      # 初期化
      #
      # 設定ファイルのパスが与えられれば初期化
      # 無ければブランクの設定をロード
      def initialize(configuration_file_path = nil)
        if configuration_file_path
          if File.exists?(configuration_file_path)
            load_configuration(configuration_file_path)
          else
            raise "File not found \"#{configuration_file_path}\"."
          end
        else
          init_configuration
        end
      end

      # データセット雛形を生成して返却
      def generate_sample_dataset
        # ヘッダのデータセット生成
        dataset = { }
        if @content.has_identifier?(:header)
          dataset[:header] = @content[:header].generate_sample_dataset(self)
        end
        dataset[:content] = @content[:content].generate_sample_dataset(self)
        if @content.has_identifier?(:footer)
          dataset[:footer] = @content[:footer].generate_sample_dataset(self)
        end

        return dataset
      end

      # 帳票の生成
      def generate(output_file_path, values = { })
        # 再描画用に初期値を保持
        @values = values.dup
        @pdf = HPDFDoc.new
        # 日本語対応
        @pdf.use_jp_fonts
        @pdf.use_jp_encodings
        # ページの初期化
        initialize_pages

        draw_contents(values)
        draw_headers(values)
        draw_footers(values)

        # 指定されたファイルへの書込
        @pdf.save_to_file(output_file_path)
      rescue => e
        @pdf.save_to_file(output_file_path) if ENV["DEBUG"]
        puts "Error occured!!\n#{e}"
        raise PrepError.new(e)
      end

      # ページの初期化
      def initialize_pages
        # 一次元配列
        @pages = []
        # 二次元配列
        @flat_pages = []
        # ページの作成
        page = generate_page
        # 1ページ目の登録
        @pages << page
        @flat_pages = [[page]] # [0][0] 位置への追加
        # 現在のページの位置情報を初期化
        @page_pos_x, @page_pos_y = 0, 0

        return page
      end

      # コンテンツの埋め込み
      def draw_contents(values)
        content = @content[:content]

        # 描画領域を含めて描画開始
        content.draw(self, page_content_region, values[:content])
      end

      # ヘッダの埋め込み
      def draw_headers(values)
        return unless @content.has_identifier?(:header)

        header = @content[:header]

        # 全てのページに対してインデックスを切り替えながら実行
        @flat_pages.each_with_index do |row_pages, y|
          row_pages.each_with_index do |page, x|
            self.current_page = { :x => x, :y => y }
            header.draw(self, page_header_region, values[:header])
          end
        end
      end

      # フッタの埋め込み
      def draw_footers(values)
        return unless @content.has_identifier?(:footer)

        footer = @content[:footer]

        # 全てのページに対してインデックスを切り替えながら実行
        @flat_pages.each_with_index do |row_pages, y|
          row_pages.each_with_index do |page, x|
            self.current_page = { :x => x, :y => y }
            footer.draw(self, page_footer_region, values[:footer])
          end
        end
      end

      # ページの移動および追加
      #
      # 指定された位置への移動に際してページが存在しなければページを追加
      def move_page_to(x, y)
        puts "[#{@page_pos_x}:#{@page_pos_y}] => [#{@page_pos_x + x}:#{@page_pos_y + y}]" if ENV["DEBUG"]
        @page_pos_x, @page_pos_y = @page_pos_x + x, @page_pos_y + y

        @flat_pages[@page_pos_y] ||= []
        if @flat_pages[@page_pos_y][@page_pos_x].nil?
          @flat_pages[@page_pos_y][@page_pos_x] = (page = generate_page)
          @pages << page
        end

        print_flat_pages if ENV["DEBUG"]

        return @flat_pages[@page_pos_y][@page_pos_x]
      end

      # 移動先のページが存在するかどうかをチェック
      def exists_move_to_page?(x, y)
        x += @page_pos_x
        y += @page_pos_y

        return exists_and_drawed_page?(x, y)
      end

      # 指定されたページが存在するかどうかをチェック
      def exists_page?(x, y)
        if @flat_pages[y].nil?
          return false
        elsif @flat_pages[y][x].nil?
          return false
        else
          return true
        end
      end

      # 指定されたページが存在し描画済みであるかどうかをチェック
      def exists_and_drawed_page?(x, y)
        if exists_page?(x, y)
          return @flat_pages[y][x].drawed?
        else
          return false
        end
      end

      # ページオブジェクトの作成とページ設定
      def generate_page
        page = @pdf.add_page
        page.set_size(@page_config.size, @page_config.orientation)

        return page
      end

      # 現在の総ページ数を返却
      def total_pages
        return @pages.size
      end

      # 現在描画中のページインスタンスを返却
      def current_page
        return @flat_pages[@page_pos_y][@page_pos_x]
      end

      # 現在の通しページ番号を返却
      def current_page_number
        @pages.each_with_index do |page, index|
          if page === current_page
            return index + 1
          end
        end
        raise "Unknown Page instance \"#{page}\"."
      end

      # 現在のページを強制的に変更
      #
      # 存在しないページへの移動は不可(例外)
      # 引数の形式はハッシュ: Ex.) { :x => 0, :y => 0 }
      def current_page=(pos)
        if exists_page?(pos[:x], pos[:y])
          puts "[#{@page_pos_x}:#{@page_pos_y}] => [#{pos[:x]}:#{pos[:y]}]" if ENV["DEBUG"]
          @page_pos_x, @page_pos_y = pos[:x], pos[:y]
          print_flat_pages if ENV["DEBUG"]
          return current_page
        else
          print_flat_pages if ENV["DEBUG"]
          raise "Unknown page index [#{pos[:x]},#{pos[:y]}]."
        end
      end

      # ページ構成を模式印字するデバッグ用メソッド
      def print_flat_pages
        @flat_pages.each_with_index do |flat_page, y|
          flat_page.each_with_index do |one_page, x|
            char = one_page.nil? ? "?" : "."
            if x == page_pos_x && y == page_pos_y
              char = '!'
            end
            STDERR.write("[#{char}]")
          end
          STDERR.write("\n")
        end
        gets if ENV["DEBUG"]
      end

      # コンテンツ描画領域の取得
      def page_content_region
        # 全体の描画領域を取得
        width = current_page.get_width
        height = current_page.get_height
        x = 0
        y = 0
        # マージンを含める
        x += @page_config.margin[:left]
        width -= (@page_config.margin[:left] + @page_config.margin[:right])
        y += @page_config.margin[:top]
        height -= (@page_config.margin[:top] + @page_config.margin[:bottom])
        # ヘッダ、および、フッタ領域を含める
        y += @page_config.header_height
        height -= (@page_config.header_height + @page_config.footer_height)

        return Region.new(x, y, width, height)
      end

      # ヘッダ領域の取得
      def page_header_region
        # 全体の描画領域を取得
        width = current_page.get_width
        height = current_page.get_height
        x = 0
        y = 0
        # マージンを含める
        x += @page_config.margin[:left]
        width -= (@page_config.margin[:left] + @page_config.margin[:right])
        y += @page_config.margin[:top]
        # 高さをヘッダ領域に変更
        height = @page_config.header_height

        return Region.new(x, y, width, height)
      end

      # フッタ領域の取得
      def page_footer_region
        # 全体の描画領域を取得
        width = current_page.get_width
        height = current_page.get_height
        x = 0
        y = current_page.get_height
        # マージンを含める
        x += @page_config.margin[:left]
        width -= (@page_config.margin[:left] + @page_config.margin[:right])
        # 高さをフッタ領域に変更
        height = @page_config.footer_height
        # フッタの開始 Y 座標を計算
        y -= (@page_config.margin[:bottom] + height)

        return Region.new(x, y, width, height)
      end

      # 設定の初期化
      def init_configuration
        raise "Need configuration file!"
      end

      # 設定ファイルのロード
      def load_configuration(configuration_file_path)
        # YAML からハッシュ形式に変換
        config_values = YAML.load_file(configuration_file_path)

        # ページ設定情報を取り込み
        @page_config = Page.new
        if config_values["page"]
          values = config_values["page"]
          if !values["size"].nil? && values["size"] != ""
            @page_config.size = Page::SIZES[values["size"].to_sym]
          end
          if !values["orientation"].nil? && values["orientation"] != ""
            @page_config.orientation = Page::ORIENTATIONS[values["orientation"].to_sym]
          end
          if !values["margin"].nil?
            margin_values = values["margin"].keys.inject({ }) do |hash, key|
              hash[key.to_sym] = values["margin"][key].mm2pixcel
              next hash
            end
            @page_config.margin = margin_values
          end
          if !values["header_height"].nil?
            @page_config.header_height = values["header_height"].mm2pixcel
          end
          if !values["footer_height"].nil?
            @page_config.footer_height = values["footer_height"].mm2pixcel
          end
        end

        # コンテンツ定義情報を読み込む
        # page 以外について読み込みを実施
        @content = Group.new
        config_values.keys.each do |identifier|
          unless identifier == "page"
            @content.add_drawable(identifier, config_values[identifier], true)
          end
        end
      end

      # 指定されたグループ識別子を検索して返却
      # 存在しない場合は例外発生
      def group(group_identifiy)
        return @content[group_identifiy]
      end

      # 指定されたグループ識別子の存在確認
      def has_group?(group_identifiy)
        return @content.drawables.has_key?(group_identifiy.to_sym)
      end
    end
  end
end
