require "rubygems"
gem "prep"
require "prep"

report = PREP::Report.new("sample.yml")
report.generate("#{$0}.pdf", { :title => "タイトル"})
