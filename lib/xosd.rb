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
      attach_function :xosd_is_onscreen,[:pointer],:int
      attach_function :xosd_wait_until_no_display,[:pointer],:int
      attach_function :xosd_show,[:pointer],:int
      attach_function :xosd_hide,[:pointer],:int
      attach_function :xosd_set_font,[:pointer,:string],:int
      attach_function :xosd_set_bar_length,[:pointer,:int],:int
      attach_function :xosd_set_pos,[:pointer,:position],:int
      attach_function :xosd_set_align,[:pointer,:align],:int
      attach_function :xosd_set_shadow_offset,[:pointer,:int],:int
      attach_function :xosd_set_outline_offset,[:pointer,:int],:int
      attach_function :xosd_set_outline_colour,[:pointer,:string],:int
      attach_function :xosd_set_shadow_colour,[:pointer,:string],:int
      attach_function :xosd_set_horizontal_offset,[:pointer,:int],:int
      attach_function :xosd_set_vertical_offset,[:pointer,:int],:int
      attach_function :xosd_set_timeout,[:pointer,:int],:int
      attach_function :xosd_set_colour,[:pointer,:string],:int
      attach_function :xosd_scroll,[:pointer,:int],:int
    end

    class Error < RuntimeError; end
    
    def self.defaults
      {:lines => 10,:line => 0,:timeout => 0}
    end

    def initialize(options={})
      opts=options.merge(self.class.defaults)
      lines=opts.delete(:lines)
      set_options opts
      @xosd=XosdRaw.xosd_create(lines)
    end
    
    attr_accessor :line
    attr_reader :shadow_color,
      :shadow_offset,
      :outline_offset,
      :outline_color,
      :voffset,
      :hoffset,
      :bar_length,
      :position,
      :align,
      :timeout

    def destroy
      call_and_raise(:xosd_destroy,@xosd)
    end

    def show
      call_and_raise(:xosd_show,@xosd)
    end

    def hide
      call_and_raise(:xosd_hide,@xosd)
    end

    def visible?
      call_and_raise(:xosd_is_onscreen,@xosd) == 0 ? false : true
    end
    
    def lines
      call_and_raise(:xosd_get_number_lines,@xosd)
    end

    def color=(color)
      call_and_raise(:xosd_set_colour,@xosd,color)
      @color=color
    end

    def shadow_color=(color)
      call_and_raise(:xosd_set_shadow_colour,@xosd,color)
      @shadow_color=color
    end

    def shadow_offset=(offset)
      call_and_raise(:xosd_set_shadow_offset,@xosd,offset)
      @shadow_offset=offset
    end

    def voffset=(offset)
      call_and_raise(:xosd_set_vertical_offset,@xosd,offset)
      @voffset=offset
    end

    def hoffset=(offset)
      call_and_raise(:xosd_set_horizontal_offset,@xosd,offset)
      @hoffset=offset
    end
    
    def font=(string)
      call_and_raise(:xosd_set_font,@xosd,string)
      @font=string
    end

    def bar_length=(length)
      call_and_raise(:xosd_set_bar_length,@xosd,length)
      @bar_length=length
    end

    def position=(value)
      call_and_raise(:xosd_set_pos,@xosd,value)
      @position=value
    end

    def align=(align)
      call_and_raise(:xosd_set_align,@xosd,align)
      @align=align
    end

    def timeout?
      !(timeout.nil? || timeout == 0)
    end

    def timeout=(seconds)
      call_and_raise(:xosd_set_timeout,@xosd,seconds)
      @timeout=seconds
    end

    def slider(value,options={})
      _display(options,:slider,:int,value)
    end
    
    def percentage(value,options={})
      _display(options,:percentage,:int,value)
    end
    
    def string(value,options={})
      _display(options,:string,:string,value)
    end

    def display(value,options={})
      case value
      when String
        string(value,options)
      when Float
        percentage(value.to_i,options)
      when Numeric
        slider(value,options)
      else
        string(value.to_s,options)
      end
    end

    def color
      @color || default_color
    end

    def default_color
      call_and_raise(:osd_default_colour)
    end

    def font
      @font || default_font
    end
    
    def default_font
      call_and_raise(:osd_default_font)
    end

    def error
      err=XosdRaw.xosd_error
      return nil  if err.address==0
      err.read_string
    end

    private

    def set_options(options)
      options.each_pair do |key,value|
        setter="#{key}="
        self.send(setter,value) if respond_to?(setter)
      end
    end

    def call_and_raise(method,*args)
      result=XosdRaw.send(method,*args)
      raise Error.new(error) if result == -1 && error
      result
    end

    def _display(options,command,type,value)
      wait=options.delete(:wait)
      set_options options
      call_and_raise(:xosd_display,@xosd,line,command,type,value)
      call_and_raise(:xosd_wait_until_no_display,@xosd) if wait && timeout?
      nil
    end
  end
end

