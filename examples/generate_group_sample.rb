require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("group_sample.yml")
prep.generate("#{$0}.pdf")
