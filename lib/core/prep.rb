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
require File.join(File.dirname(__FILE__), "group")
require File.join(File.dirname(__FILE__), "region")
require File.join(File.dirname(__FILE__), "page")
require File.join(File.dirname(__FILE__), "..", "mm2pixcel")

module PREP
  module Core
    # PREP の中心クラス
    class Prep
      attr_reader :pdf, :pages

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
        @pdf = HPDFDoc.new
        # 日本語対応
        @pdf.use_jp_fonts
        @pdf.use_jp_encodings
        @pages = []
        # 1ページ目の追加
        add_page

        draw_contents(values)
        draw_headers(values)
        draw_footers(values)

        # 指定されたファイルへの書込
        @pdf.save_to_file(output_file_path)
      # rescue => e
      #   puts "Error occured!!\n#{e}"
      end

      # コンテンツの埋め込み
      def draw_contents(values)
        content = @content[:content]

        # 描画領域を含めて描画開始
        content.draw(self, current_page, page_content_region, values[:content])
      end

      # ヘッダの埋め込み
      def draw_headers(values)
        return unless @content.has_identifier?(:header)

        header = @content[:header]

        @pages.each do |page|
          header.draw(self, page, page_header_region, values[:header])
        end
      end

      # フッタの埋め込み
      def draw_footers(values)
        return unless @content.has_identifier?(:footer)

        footer = @content[:footer]
        @pages.each do |page|
          footer.draw(self, page, page_footer_region, values[:footer])
        end
      end

      # ページの追加
      #
      # 新規ページを追加し、参照を返却
      def add_page
        @pages << (page = @pdf.add_page)
        page.set_size(@page_config.size, @page_config.orientation)

        return page
      end

      # 現在の総ページ数を返却
      def total_pages
        return @pages.size
      end

      # 現在描画中のページインスタンスを返却
      def current_page
        return @pages.last
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
    end
  end
end
