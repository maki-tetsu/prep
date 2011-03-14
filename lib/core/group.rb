# Group クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "label")
require File.join(File.dirname(__FILE__), "line")
require File.join(File.dirname(__FILE__), "rectangle")
require File.join(File.dirname(__FILE__), "reference")

module PREP # nodoc
  module Core # nodoc
    # 呼び出し可能グループの定義
    class Group < Drawable
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
        if @drawables.has_key?(drawable_key)
          return @drawables[drawable_key]
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
      def add_drawable(identifier, config)
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
          klass = Group
        when "reference"
          klass = Reference
        else
          raise "Unknown type expression \"#{config["type"]}\"."
        end

        @drawables[identifier.to_sym] = klass.new(identifier, config)
      end

      def draw(pdf, page, region, values)
        values ||= { }
        # 管理対象の各オブジェクトに対して描画を開始
        @drawables.values.each do |drawable|
          drawable_values = values[drawable.identifier] if values.has_key?(drawable.identifier)

          drawable.draw(pdf, page, region, drawable_values)
        end
      end
    end
  end
end
