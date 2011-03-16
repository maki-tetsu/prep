# Point クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

module PREP # nodoc
  module Core # nodoc
    class Point
      attr_reader :x, :y

      def initialize(x, y)
        self.x, self.y = x, y
      end

      def x=(v)
        raise "x cannot be nil." if v.nil?
        @x = v
      end

      def y=(v)
        raise "y cannot be nil." if v.nil?
        @y = v
      end
    end
  end
end
