# Align クラスのソースファイル
# Author:: maki-tetsu
# Date:: 2011/03/11
# Copyright:: Copyright (c) 2011 maki-tetsu

require File.join(File.dirname(__FILE__), "drawable")

module PREP # nodoc
  module Core # nodoc
    class Align
      # 左寄せ
      LEFT   = :left
      # 右寄せ
      RIGHT  = :right
      CENTER = :center
      attr_reader :align
    end
  end
end
