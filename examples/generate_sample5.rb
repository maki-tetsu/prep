require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample5.yml")
values = {
  :content => {
    :out_table => {
      :header => { :header_title => "hoge" },
      :values => [
                  {
                    :inner_table => {
                      :header => { :header_title => "hogehoge" },
                      :values => [
                                  { :inner_table_content_column01_label => "1-1" },
                                  { :inner_table_content_column01_label => "1-2" },
                                  { :inner_table_content_column01_label => "1-3" },
                                  { :inner_table_content_column01_label => "1-4" },
                                 ],
                    },
                  },
                  {
                    :inner_table => {
                      :values => [
                                  { :inner_table_content_column01_label => "2-1" },
                                  { :inner_table_content_column01_label => "2-2" },
                                  { :inner_table_content_column01_label => "2-3" },
                                  { :inner_table_content_column01_label => "2-4" },
                                 ],
                    },
                  },
                  {
                    :inner_table => {
                      :values => [
                                  { :inner_table_content_column01_label => "3-1" },
                                  { :inner_table_content_column01_label => "3-2" },
                                  { :inner_table_content_column01_label => "3-3" },
                                  { :inner_table_content_column01_label => "3-4" },
                                 ],
                    },
                  },
                  {
                    :inner_table => {
                      :values => [
                                  { :inner_table_content_column01_label => "4-1" },
                                  { :inner_table_content_column01_label => "4-2" },
                                  { :inner_table_content_column01_label => "4-3" },
                                  { :inner_table_content_column01_label => "4-4" },
                                 ],
                    },
                  },
                  {
                    :inner_table => {
                      :values => [
                                  { :inner_table_content_column01_label => "5-1" },
                                  { :inner_table_content_column01_label => "5-2" },
                                  { :inner_table_content_column01_label => "5-3" },
                                  { :inner_table_content_column01_label => "5-4" },
                                 ],
                    },
                  },
                  {
                    :inner_table => {
                      :values => [
                                  { :inner_table_content_column01_label => "6-1" },
                                  { :inner_table_content_column01_label => "6-2" },
                                  { :inner_table_content_column01_label => "6-3" },
                                  { :inner_table_content_column01_label => "6-4" },
                                 ],
                    },
                  },
                 ],
    }
  }
}
prep.generate("#{$0}.pdf", values)
