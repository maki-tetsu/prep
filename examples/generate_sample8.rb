# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample8.yml")
values = {
  :content =>
  {
    :out_loop =>
    {
      :values => [
                  { :inner_loop =>
                    {:values =>
                      [
                       {:title => "hogehoge1"},
                       {:title => "hogehoge2"},
                       {:title => "hogehoge3"},
                       {:title => "hogehoge4"},
                       {:title => "hogehoge5"},
                       {:title => "hogehoge6"},
                       {:title => "hogehoge7"},
                       {:title => "hogehoge8"},
                       {:title => "hogehoge9"},
                       {:title => "hogehoge10"},
                       {:title => "hogehoge11"},
                       {:title => "hogehoge12"},
                      ],
                      :header => { :title=> "in title" },
                    },
                  },
                 ],
      :header => { :title_label => "タイトル(一回だけ)" },
    },
  },
}

prep.generate("#{$0}.pdf", values)
