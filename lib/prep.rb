require "rubygems"
gem "hpdf"
require "hpdf"
require "yaml"
require "nkf"

module PREP
  class Report
    def initialize(config_file_path)
      @config = YAML.load_file(config_file_path)

      raise "Configuration Error" unless valid_configuration?
    end

    def generate(file_path, values)
      @pdf = HPDFDoc.new
      @pdf.use_jp_fonts
      @pdf.use_jp_encodings
      page = @pdf.add_page
      page.set_size(HPDFDoc::HPDF_PAGE_SIZE_A4, HPDFDoc::HPDF_PAGE_PORTRAIT)

      draw_rectangles(page)
      draw_lines(page)
      draw_labels(page, values)

      @pdf.save_to_file(file_path)
    ensure
      @pdf = nil
    end

    def self.generate_guide(file_path)
      pdf = HPDFDoc.new
      pdf.use_jp_fonts
      pdf.use_jp_encodings
      page = pdf.add_page
      page.set_size(HPDFDoc::HPDF_PAGE_SIZE_A4, HPDFDoc::HPDF_PAGE_PORTRAIT)

      # 10 ピクセルごとに方眼
      height = page.get_height
      width = page.get_width
      x = 0; y = 0
      guide_label_pos = 50
      page.set_font_and_size(pdf.get_font("Helvetica", nil), 5)
      step = 5
      while x < width
        x += step
        page.set_line_width(1)
        if x % 50 == 0
          if x % 100 == 0
            page.set_rgb_stroke(0.5, 0.5, 0.5)
          else
            page.set_rgb_stroke(0.8, 0.8, 0.8)
          end
        else
          page.set_rgb_stroke(0.8, 1.0, 0.8)
        end
        page.move_to(x, 0)
        page.line_to(x, height)
        page.stroke
      end
      while y < height
        y += step
        page.set_line_width(1)
        if y % 50 == 0
          if y % 100 == 0
            page.set_rgb_stroke(0.5, 0.5, 0.5)
            page.begin_text
            page.move_text_pos(guide_label_pos, y)
            page.show_text(y.to_s)
            page.end_text
            page.begin_text
            page.move_text_pos(((width.to_f / guide_label_pos).floor * guide_label_pos), y)
            page.show_text(y.to_s)
            page.end_text
          else
            page.set_rgb_stroke(0.8, 0.8, 0.8)
          end
        else
          page.set_rgb_stroke(0.8, 1.0, 0.8)
        end
        page.move_to(0, y)
        page.line_to(width, y)
        page.stroke
      end
      x = 0
      while x < width
        x += step
        if x % 50 == 0
          if x % 100 == 0
            page.begin_text
            page.move_text_pos(x, guide_label_pos)
            page.show_text(x.to_s)
            page.end_text
            page.begin_text
            page.move_text_pos(x, (height.to_f / guide_label_pos).floor * guide_label_pos)
            page.show_text(x.to_s)
            page.end_text
          end
        end
      end

      pdf.save_to_file(file_path)
    end

    private

    def draw_rectangles(page)
      @config.keys.each do |key|
        if @config[key]["type"] == "rectangle"
          rect = @config[key]
          page.set_line_width(rect["line_width"].to_f)
          page.set_rgb_stroke(rect["line_color"]["red"].to_f,
                              rect["line_color"]["green"].to_f,
                              rect["line_color"]["blue"].to_f)
          page.set_rgb_fill(rect["fill_color"]["red"].to_f,
                            rect["fill_color"]["green"].to_f,
                            rect["fill_color"]["blue"].to_f)
          page.rectangle(rect["x_pos"].to_f, rect["y_pos"].to_f,
                         rect["width"].to_f, rect["height"].to_f)
          if rect["fill"]
            if rect["stroke"]
              page.fill_stroke
            else
              page.fill
            end
          elsif rect["stroke"]
            page.stroke
          end
        end
      end
    end

    def draw_lines(page)
      @config.keys.each do |key|
        if @config[key]["type"] == "line"
          line = @config[key]
          page.set_line_width(line["line_width"].to_f)
          page.set_rgb_stroke(line["line_color"]["red"].to_f,
                              line["line_color"]["green"].to_f,
                              line["line_color"]["blue"].to_f)
          page.move_to(line["start_x_pos"].to_f, line["start_y_pos"].to_f)
          page.line_to(line["end_x_pos"].to_f, line["end_y_pos"].to_f)
          page.stroke
        end
      end
    end

    def draw_labels(page, values)
      values.keys.each do |key|
        if @config.has_key?(key.to_s)
          label = @config[key.to_s]
          # フォントの取得
          font = @pdf.get_font(label["font"], "90ms-RKSJ-H")
          page.begin_text
          page.move_text_pos(label["x_pos"].to_f, label["y_pos"].to_f)
          page.set_font_and_size(font, label["size"].to_f)
          page.show_text(NKF.nkf("--oc=cp932", values[key]))
          page.end_text
        else
          raise ArgumentError.new("Unknown label key \"#{key.to_s}\"")
        end
      end
    end

    def valid_configuration?
      # 未実装（常に true）
      return true
    end
  end
end
