require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample6.yml")
values = {
  :content => {
    :out_table => {
      :header => { :header_title => "hoge" },
      :values => [
                  {
                    :inner_table => {
                      :header => { :inner_table_header_title => "First" },
                      :values => [
                                  { :inner_table_content_column01_label => "1-1" },
                                  { :inner_table_content_column01_label => "1-2" },
                                  ],
                    },
                  },
                  {
                    :inner_table => {
                      :header => { :inner_table_header_title => "Second" },
                      :values => [
                                  { :inner_table_content_column01_label => "2-1" },
                                  { :inner_table_content_column01_label => "2-2" },
                                  ],
                    },
                  },
                  {
                    :inner_table => {
                      :header => { :inner_table_header_title => "Third" },
                      :values => [
                                  { :inner_table_content_column01_label => "3-1" },
                                  { :inner_table_content_column01_label => "3-2" },
                                  ],
                    },
                  },
                 ],
    }
  }
}
prep.generate("#{$0}.pdf", values)
