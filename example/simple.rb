$: << File.join(File.dirname(__FILE__),'..','lib')
require 'xosd'
require 'xosd-ffi-patch'

osd=X11::Xosd.new(:lines => 10)
font="-*-*-*-*-*-*-*-246-*-*-*-*-*-*"

osd.timeout=6
osd.line=1


osd.display('hallo',
  :line => 5,
  :color => 'red',
  :shadow_color => 'green',
  :shadow_offset => 4,
  :outline_offset => 2,
  :outline_color => 'blue',
  :voffset => 0,
  :hoffset => 0,
  :font => font,
  :bar_length => 30,
  :position => 0,
  :align => :left,
  :timeout => 10
)

osd.percentage(70,:line => 6)
osd.slider(57,:line => 7)
osd.display(56.0,:line => 8,:wait => true)




osd.destroy
