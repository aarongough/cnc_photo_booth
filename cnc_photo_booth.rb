require 'rubygems'
require 'chunky_png'
require 'fileutils'

class CNCPhotoBooth
  def initialize(input_path, output_folder)
  output_folder = File.expand_path(output_folder)

    @current_line_num = 0
    @input_name = File.split(input_path)[-1].gsub(File.extname(input_path), "")

    @output_ngc_name = @input_name.downcase + ".ngc"
    @output_svg_name = @input_name.downcase + ".svg"
    @output_ngc_path = File.join(output_folder, @output_ngc_name)
    @output_svg_path = File.join(output_folder, @output_svg_name)

    FileUtils.mkdir_p(output_folder)
    @output_ngc_file = File.new(@output_ngc_path, "w+")
    @output_svg_file = File.new(@output_svg_path, "w+")

    @image = ChunkyPNG::Image.from_file(input_path)

    @resolution = 0.08
    @left_margin = 0.85
    @top_margin = 1.1

    @z_clear = 0.1
    @z_max = -0.05
    @z_step = @z_max / 255
  end

  def generate_gcode()
    gcode "%", false
    gcode "O999 (CNC PHOTO BOOTH FOR #{@input_name.gsub(/\W/,"").upcase})"
    gcode "G54 G17 G80 G8 G90 M92 M5 G0"
    gcode "M94 P91 Q0.003"
    gcode "X#{@left_margin} Y#{@top_margin} Z#{@z_clear}"
    gcode "G1 F250"

    @image.height.times do |y|
      x_cols = @image.width.times.to_a
      x_cols.reverse! if y.odd?
      x_cols.each do |x|
        shade = ChunkyPNG::Color.r(@image[x,y])
        x_pos = (@left_margin + (x*@resolution)).round(3)
        y_pos = (@top_margin + (y*@resolution)).round(3)
        z_pos = (shade*@z_step).round(3)
        gcode "X#{x_pos} Y#{y_pos} Z#{z_pos}"
      end
    end

    gcode "G0 Z10.0"
    gcode "X0. Y0."
    gcode "M2"
    gcode "%", false
  end

  def generate_svg()
    svg '<?xml version="1.0" standalone="no"?>'
    svg '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
    svg '<svg x="0" y="0" width="8.5in" height="11in" viewBox="0 0 8.5 11" xmlns="http://www.w3.org/2000/svg" version="1.1">'
    svg '  <g transform="translate(0in,0in)">'

    last_point = [@left_margin, @top_margin, 0.0]
    
    @image.height.times do |y|
      x_cols = @image.width.times.to_a
      x_cols.reverse! if y.odd?
      x_cols.each do |x|
        shade = 255 - ChunkyPNG::Color.r(@image[x,y])
        x_pos = (@left_margin + (x*@resolution)).round(3)
        y_pos = (@top_margin + (y*@resolution)).round(3)
        radius = ((@resolution / 255 / 2) * shade).round(3)
        svg "    <circle cx=\"#{x_pos}\" cy=\"#{y_pos}\" r=\"#{radius}\" stroke=\"black\" fill=\"black\" stroke-width=\"0\"/>"
        3.times do |diff|
          int_x_pos = x_pos == last_point[0] ? x_pos : (x_pos - (((x_pos - last_point[0]) / 3) * diff))
          int_y_pos = y_pos == last_point[1] ? y_pos : (y_pos - (((y_pos - last_point[1]) / 3) * diff))
          int_radius = radius + (((radius - last_point[2]) / 3) * diff)
          svg "    <circle cx=\"#{int_x_pos}\" cy=\"#{int_y_pos}\" r=\"#{int_radius}\" stroke=\"black\" fill=\"black\" stroke-width=\"0\"/>"
        end
        last_point = [x_pos, y_pos, radius]
      end
    end
    
    svg '  </g>'
    svg '</svg>'

    puts @output_svg_path
  end

  def gcode(string, include_line_num = true)
    if include_line_num
      @output_ngc_file << "N#{@current_line_num} #{string}\n"
      @current_line_num += 1
    else
      @output_ngc_file << "#{string}\n"
    end
  end

  def svg(string)
    @output_svg_file << "#{string}\n"
  end
end

photo_booth = CNCPhotoBooth.new(ARGV[0], "~/Desktop/cnc_photo_booth_toolpaths/")

photo_booth.generate_gcode()
photo_booth.generate_svg()
