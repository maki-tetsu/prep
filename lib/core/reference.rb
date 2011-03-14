# Reference クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")

module PREP # nodoc
  module Core # nodoc
    # グループ読み込みクラスの定義
    class Reference < Drawable
      attr_reader :group

      def initialize(identifier, values = { })
        super(identifier)
        values = @@default_values.merge(key_string_to_symbol(values))

        @group = values[:group]
      end

      def draw(page, region)
      end
    end
  end
end
