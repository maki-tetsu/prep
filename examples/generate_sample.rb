require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample.yml")
prep.generate("#{$0}.pdf", { :content => { :title => "外部引き渡しタイトル文字列" } })
