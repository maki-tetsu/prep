require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("gap_test.yml")

values = {:content=>
  {:inner_loop=>
    {:footer=>{:footer1=>"Footer1", :footer3=>"Footer3", :footer2=>"Footer2"},
     :values=>
      [{:value3=>"1-3", :value2=>"1-2", :value1=>"1-1"},
       {:value3=>"2-3", :value2=>"2-2", :value1=>"2-1"},
       {:value3=>"3-3", :value2=>"3-2", :value1=>"3-1"},
       {:value3=>"4-3", :value2=>"4-2", :value1=>"4-1"},
       {:value3=>"5-3", :value2=>"5-2", :value1=>"5-1"},
       {:value3=>"6-3", :value2=>"6-2", :value1=>"6-1"},
       {:value3=>"7-3", :value2=>"7-2", :value1=>"7-1"},
       {:value3=>"8-3", :value2=>"8-2", :value1=>"8-1"},
       {:value3=>"9-3", :value2=>"9-2", :value1=>"9-1"},
       {:value3=>"10-3", :value2=>"10-2", :value1=>"10-1"},
       {:value3=>"11-3", :value2=>"11-2", :value1=>"11-1"},
       {:value3=>"12-3", :value2=>"12-2", :value1=>"12-1"}],
     :header=>
      {:header3=>"Header3", :header2=>"Header2", :header1=>"Header1"}}}}

prep.generate("#{$0}.pdf", values)
