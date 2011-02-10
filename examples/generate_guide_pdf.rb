require "rubygems"
gem "prep"
require "prep"

PREP::Report.generate_guide("#{$0}.pdf")
