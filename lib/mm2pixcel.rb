class Numeric
  def mm2pixcel(dpi = 72, inchi_in_mm = 25.4)
    return (self.to_f / inchi_in_mm) * dpi
  end
end
