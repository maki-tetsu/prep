# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("rect_line_width_zero_sample.yml")
prep.generate("#{$0}.pdf", { :content => { :title => "外部引き渡しタイトル文字列" } })
