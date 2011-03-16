require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample2.yml")
values = {
  :content => {
    :table => {
      :values => [
                  { :column01_label => 101, :column02_label => 102, :column03_label => 103 },
                  { :column01_label => 201, :column02_label => 202, :column03_label => 203 },
                  { :column01_label => 301, :column02_label => 302, :column03_label => 303 },
                  { :column01_label => 401, :column02_label => 402, :column03_label => 403 },
                  { :column01_label => 501, :column02_label => 502, :column03_label => 503 },
                  { :column01_label => 601, :column02_label => 602, :column03_label => 603 },
                  { :column01_label => 701, :column02_label => 702, :column03_label => 703 },
                 ]
    }
  }
}
prep.generate("#{$0}.pdf", values)
