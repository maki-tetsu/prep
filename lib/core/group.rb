# -*- coding: utf-8 -*-
# Group クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")
require File.join(File.dirname(__FILE__), "label")
require File.join(File.dirname(__FILE__), "line")
require File.join(File.dirname(__FILE__), "rectangle")
require File.join(File.dirname(__FILE__), "arc_rectangle")
require File.join(File.dirname(__FILE__), "image")
require File.join(File.dirname(__FILE__), "loop")

module PREP # nodoc
  module Core # nodoc
    # 呼び出し可能グループの定義
    class Group < Drawable
      @@allow_all = false

      attr_reader :drawables

      def self.allow_all
        return @@allow_all
      end

      def self.allow_all=(v)
        @@allow_all = !!v
      end

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
          unless @@allow_all
            @drawables.values.each do |drawable|
              if Loop === drawable
                raise "Group already has Loop!!"
              end
            end
          end
        when "line"
          klass = Line
          unless @@allow_all
            @drawables.values.each do |drawable|
              if Loop === drawable
                raise "Group already has Loop!!"
              end
            end
          end
        when "rectangle"
          klass = Rectangle
          unless @@allow_all
            @drawables.values.each do |drawable|
              if Loop === drawable
                raise "Group already has Loop!!"
              end
            end
          end
        when "arc_rectangle"
          klass = ArcRectangle
          unless @@allow_all
            @drawables.values.each do |drawable|
              if Loop === drawable
                raise "Group already has Loop!!"
              end
            end
          end
        when "image"
          klass = Image
          unless @@allow_all
            @drawables.values.each do |drawable|
              if Loop === drawable
                raise "Group already has Loop!!"
              end
            end
          end
        when "group"
          # global でのみグループ定義を許可
          unless global
            raise "Group definition allowed at global level only for \"#{identifier}\"."
          end
          klass = Group
        when "loop"
          klass = Loop
          unless @@allow_all
            unless @drawables.size.zero?
              raise "Group has only one loop!!"
            end
          end
        else
          raise "Unknown type expression \"#{config["type"]}\"."
        end

        @drawables[identifier.to_sym] = klass.new(identifier, config)
      end

      # データセット雛形を生成
      def generate_sample_dataset(prep)
        dataset = { }
        drawable_items.each do |drawable|
          case drawable
          when Loop, Group
            dataset[drawable.identifier.to_sym] = drawable.generate_sample_dataset(prep)
          when Label
            dataset[drawable.identifier.to_sym] = drawable.label
          end
        end

        return dataset
      end

      # グループを構成する各要素が全体で占有する領域サイズを返却
      def calculate_region(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        puts "Calculate region for #{self.class}: #{self.identifier} region: #{region}" if ENV["DEBUG"]
        values ||= { }

        # 各構成要素の描画領域を計算して最大の領域を計算、width, height のみを利用
        group_region_size = drawable_items.inject({ }) do |size, drawable|
          if values.has_key?(drawable.identifier.to_sym)
            drawable_values = values[drawable.identifier.to_sym]
          else
            drawable_values = { }
          end

          width, height = drawable.calculate_region(prep, region, drawable_values, stop_on_drawable)

          size[:width] ||= width
          size[:height] ||= height
          size[:width] = width if size[:width] < width
          size[:height] = height if size[:height] < height

          next size
        end

        group_region_size[:width] ||= 0
        group_region_size[:height] ||= 0

        ret_region = Region.new(0, 0,
                                region.width - group_region_size[:width],
                                region.height - group_region_size[:height])
        return group_region_size[:width], group_region_size[:height]
      end

      def draw(prep, region, values, stop_on_drawable = nil)
        if self === stop_on_drawable
          raise ReRenderJump.new(region)
        end
        STDERR.puts("Draw on #{self.class} #{self.identifier}") if ENV['DEBUG']
        values ||= { }
        # 管理対象の各オブジェクトに対して描画を開始
        drawable_items.each do |drawable|
          if values.has_key?(drawable.identifier.to_sym)
            drawable_values = values[drawable.identifier.to_sym]
          else
            drawable_values = { }
          end

          drawable.draw(prep, region, drawable_values, stop_on_drawable)
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
        }.compact.sort
      end
    end
  end
end
