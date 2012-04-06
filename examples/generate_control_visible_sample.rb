# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("control_visible_sample.yml")
prep.generate("#{$0}.pdf",
              { :content => {
                  :title => "外部引き渡しタイトル文字列",
                  :control_visible_line => false,
                  :control_visible_rect => false,
                  :control_visible_arcrect => false,
                } })
