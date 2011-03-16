# Group クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "label")
require File.join(File.dirname(__FILE__), "line")
require File.join(File.dirname(__FILE__), "rectangle")
require File.join(File.dirname(__FILE__), "loop")

module PREP # nodoc
  module Core # nodoc
    # 呼び出し可能グループの定義
    class Group < Drawable
      attr_reader :drawables

      # 初期化
      def initialize(identifier = "main", values = { })
        super(identifier)

        @drawables = { }
        values.keys.each do |key|
          unless key == "type" # type は除外
            add_drawable(key, values[key])
          end
        end
      end

      # 指定された識別子を持つ定義情報を返却
      def [](drawable_key)
        if @drawables.has_key?(drawable_key.to_sym)
          return @drawables[drawable_key.to_sym]
        else
          raise "Unknown drawable key \"#{drawable_key}\"."
        end
      end

      # 指定された識別子を持つ定義情報の有無を返却
      def has_identifier?(key)
        return @drawables.has_key?(key)
      end

      # 構成要素の追加
      #
      # 引数に渡されるのは単一の構成要素
      def add_drawable(identifier, config, global = false)
        # 事前にキー重複をチェック
        if @drawables.has_key?(identifier.to_sym)
          raise "Duplicated ID \"#{identifier}\"."
        end
        # キー重複が無ければ設定情報を読み込む
        # 構成要素種別の指定を確認
        case config["type"]
        when "label"
          klass = Label
        when "line"
          klass = Line
        when "rectangle"
          klass = Rectangle
        when "group"
          # global でのみグループ定義を許可
          unless global
            raise "Group definition allowed at global level only for \"#{identifier}\"."
          end
          klass = Group
        when "loop"
          klass = Loop
        else
          raise "Unknown type expression \"#{config["type"]}\"."
        end

        @drawables[identifier.to_sym] = klass.new(identifier, config)
      end

      # グループを構成する各要素が全体で占有する領域サイズを返却
      def calculate_region(prep, region, values)
        values ||= { }

        # 各構成要素の描画領域を計算して最大の領域を計算、width, height のみを利用
        group_region_size = drawable_items.inject({ :width => 0, :height => 0 }) do |size, drawable|
          if values.has_key?(drawable.identifier)
            drawable_values = values[drawable.identifier]
          else
            drawable_values = { }
          end
          width, height = drawable.calculate_region(prep, region, drawable_values)

          size[:width] = width if size[:width] < width
          size[:height] = height if size[:height] < height

          next size
        end

        ret_region = Region.new(0, 0,
                                region.width - group_region_size[:width],
                                region.height - group_region_size[:height])
        return group_region_size[:width], group_region_size[:height]
      end

      def draw(prep, page, region, values)
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        values ||= { }
        # 管理対象の各オブジェクトに対して描画を開始
        drawable_items.each do |drawable|
          if values.has_key?(drawable.identifier.to_sym)
            drawable_values = values[drawable.identifier.to_sym]
          else
            drawable_values = { }
          end

          drawable.draw(prep, page, region, drawable_values)
        end
      end

      # 描画対象となる構成要素の一覧を返却
      def drawable_items
        return @drawables.values.map { |d|
          case d
          when Group
            next nil
          else
            next d
          end
        }.compact
      end
    end
  end
end
