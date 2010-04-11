require 'rubygems'
require 'ffi'

module X11
  class Xosd
    module XosdRaw
      extend FFI::Library
      ffi_lib 'xosd'
      enum :command, [:percentage,:string,:printf,:slider]
      enum :position, [:top,:bottom,:middle]
      enum :align, [:left,:center,:right]
    
      attach_variable :xosd_error, :pointer
      attach_variable :osd_default_font,:string
      attach_variable :osd_default_colour,:string

      attach_function :xosd_create,[:int],:pointer
      attach_function :xosd_destroy,[:pointer],:int
      attach_function :xosd_get_number_lines,[:pointer],:int
      attach_function :xosd_display,[:pointer,:int,:command,:varargs],:int
      attach_function :xosd_set_font,[:pointer,:string],:int
      attach_function :xosd_set_pos,[:pointer,:position],:int
      attach_function :xosd_set_align,[:pointer,:align],:int
    
    end
    
    def initialize(lines)
      @xosd=XosdRaw.xosd_create(lines)
    end
    
    def destroy
      XosdRaw.xosd_destroy(@xosd)
    end
    
    def lines
      XosdRaw.xosd_get_number_lines(@xosd)
    end
    
    def slider=value
      XosdRaw.xosd_display(@xosd,6,:slider,:int,value)
    end
    
    def percentage=value
      XosdRaw.xosd_display(@xosd,6,:percentage,:int,value)
    end
    
    def string=value
      XosdRaw.xosd_display(@xosd,6,:string,:string,value)
    end

    def default_color
      XosdRaw.osd_default_colour
    end

    def default_font
      XosdRaw.osd_default_font
    end

    def error
      err=XosdRaw.xosd_error
     return nil  if err.address==0
     err.read_string
    end
    
    def font=(string)
      XosdRaw.xosd_set_font(@xosd,string)
    end
    
    def position=(value)
      XosdRaw.xosd_set_pos(@xosd,value)
    end
  end
end

osd=X11::Xosd.new(10)
osd.font="-*-*-*-*-*-*-*-246-*-*-*-*-*-*"
#puts osd.error
#puts osd.lines
#puts osd.default_font
osd.percentage=70
sleep 2
osd.position=:bottom
puts osd.error
#osd.string="Hallo du da"
osd.slider=70
sleep 3
osd.destroy



