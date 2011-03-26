# HPDFPage の拡張
require "rubygems"
gem "hpdf"
require "hpdf"

class HPDFPage
  def drawed?
    return !!@drawed
  end

  def drawed=(flag)
    @drawed = flag
  end
end
