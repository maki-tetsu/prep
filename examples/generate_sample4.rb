require File.join(File.dirname(__FILE__), "..", "lib", "prep")

prep = PREP::Core::Prep.new("sample3.yml")
values = {
  :content => {
    :title => "任意のタイトルさんだよー",
    :table => {
      :values => [
                  { :column01_label => "03/01", :column02_label => 102, :column03_label => 103, :column04_label => 104 },
                  { :column01_label => "03/02", :column02_label => 202, :column03_label => 203, :column04_label => 204 },
                  { :column01_label => "03/03", :column02_label => 302, :column03_label => 303, :column04_label => 304 },
                  { :column01_label => "03/04", :column02_label => 402, :column03_label => 403, :column04_label => 404 },
                  { :column01_label => "03/05", :column02_label => 502, :column03_label => 503, :column04_label => 504 },
                  { :column01_label => "03/06", :column02_label => 602, :column03_label => 603, :column04_label => 604 },
                  { :column01_label => "03/07", :column02_label => 702, :column03_label => 703, :column04_label => 704 },
                  { :column01_label => "03/08", :column02_label => 702, :column03_label => 703, :column04_label => 704 },
                  { :column01_label => "03/09", :column02_label => 102, :column03_label => 103, :column04_label => 104 },
                  { :column01_label => "03/10", :column02_label => 202, :column03_label => 203, :column04_label => 204 },
                  { :column01_label => "03/11", :column02_label => 302, :column03_label => 303, :column04_label => 304 },
                  { :column01_label => "03/12", :column02_label => 402, :column03_label => 403, :column04_label => 404 },
                  { :column01_label => "03/13", :column02_label => 502, :column03_label => 503, :column04_label => 504 },
                  { :column01_label => "03/14", :column02_label => 602, :column03_label => 603, :column04_label => 604 },
                  { :column01_label => "03/15", :column02_label => 702, :column03_label => 703, :column04_label => 704 },
                  { :column01_label => "03/16", :column02_label => 702, :column03_label => 703, :column04_label => 704 },
                 ]
    }
  }
}
prep.generate("#{$0}.pdf", values)
