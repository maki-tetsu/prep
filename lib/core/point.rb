# Point クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
    class Point
      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end
    end
  end
end
