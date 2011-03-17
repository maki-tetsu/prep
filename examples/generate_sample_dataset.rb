$KCODE='u'

require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample5.yml")
values = prep.generate_sample_dataset
require 'pp'
pp values
prep.generate("#{$0}.pdf", values)
