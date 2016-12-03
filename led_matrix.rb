#!mruby
# coding: utf-8
=begin

Aadafruit HT16K33 8x8 LED Matrix

Matrix8
#new(opt)
   opt = {:port=> WireNo, :addr=> I2C Address }

#set_blink_rate(mode)
   mode : 0=off, 1=1秒

#set_brightness(brightness)
   brightness: 1〜15

#clear

#write_display

#draw_pixel(x,y,color)

#shift(direction)
  direction : :up,:down,:right,:left


=end


class Matrix_8x8
  HT16K33_CMD_BLINK = 0x80
  HT16K33_CMD_BRIGHTNESS = 0xE0
  HT16K33_CMD_BLINK_DISPLAYON = 0x01
  HT16K33_BLINKOFF = 0
  HT16K33_BLINK1HZ = 1
  HT16K33_BLINK2HZ = 2
  HT16K33_BLINKHALFHZ = 3

  attr_accessor :buffer

  def initialize(opt={:port => 1,:addr=> 0x70, :led_module => 'MONO', :console=>nil})
    @addr = opt[:addr] || 0x70
    @module = opt[:led_module] || 'MONO' # MONO, BI, RGB, 7SEG
    @port = opt[:port]
    @logout = opt[:console]
    @buffer = [
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000'
    ]

    self.log("open #{@addr} on #{@port}")
    @matrix = I2c.new(@port)

    self.send_cmd(0x21)
    self.log("send blinkrate...")
    self.set_blink_rate(0)
    self.set_brightness(10)
  end

  def set_blink_rate(i)
    i = 0 if i > 3
    self.send_cmd( HT16K33_CMD_BLINK|HT16K33_CMD_BLINK_DISPLAYON|(i << 1) )
  end

  def set_brightness(b=15) # 1-15
    self.send_cmd( HT16K33_CMD_BRIGHTNESS|b )
  end

  def init_display
    @ini_buffer = [
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000',
      '00000000'
    ]
    @buffer = @ini_buffer
    @matrix.begin(@addr)
    @matrix.lwrite( 0x00 )
    8.times do
      @matrix.lwrite(0b00000000)
      @matrix.lwrite(0b00000000)
    end
    @matrix.end
  end
  alias :clear :init_display

  def draw_pixel(x,y,color=1)
    color = 1 if color.to_i > 0
    color = 0 if color.to_i == 0
    @buffer[y][x] = color.to_s
    write_display()
  end

  def write_display()
    @matrix.begin(@addr)
    @matrix.lwrite( 0x00 )

    @buffer.each do |pat|
      dbit = "#{pat[0]}#{pat[1..-1].reverse}".to_i(2)
      @matrix.lwrite( dbit )
      @matrix.lwrite( 0x00 )
    end
    alias :display :write_display

    @matrix.end
  end

  def shift(direction)
    case direction
    when :up # ^
      #@buffer = [ @buffer[1..-1],@buffer.first ].flatten
      @buffer = [ @buffer[1],
                  @buffer[2],
                  @buffer[3],
                  @buffer[4],
                  @buffer[5],
                  @buffer[6],
                  @buffer[7],
                  @buffer.first ]
    when :down # v
      #@buffer = [ @buffer.last, @buffer[0..-2] ].flatten
      @buffer = [ @buffer[7],
                  @buffer[0],
                  @buffer[1],
                  @buffer[2],
                  @buffer[3],
                  @buffer[4],
                  @buffer[5],
                  @buffer[6] ]
    when :left # <
      @buffer = @buffer.map do |s|
        [s[1..-1],s[0]].join
      end
    when :right # >
      @buffer.map! do |s|
        [s[-1],s[0..-2]].join
      end
    end
    self.write_display
  end

  def rotate(direction=:left)
    new_buffer = []# @ini_buffer
    0.upto(7) do |x|
      str = ''
      0.upto(7) do |y|
        str += @buffer[y][x]
        #new_buffer[x][y] = @buffer[y][x]
      end
      new_buffer << str
    end
    @buffer = new_buffer
    self.write_display
  end

private
  def log(str)
    if @logout
      @logout.println(str)
    end
  end

  def send_cmd(cmd)
    @matrix.begin(@addr)
    @matrix.lwrite(cmd)
    @matrix.end
  end
end


#if $0 == __FILES__
  usb = Serial.new(0)
  m = Matrix_8x8.new({:port=>1, :addr=>0x70})
  m.init_display

  m.buffer = [
    "00010111",
    "00110110",
    "11110100",
    "00001000",
    "00010100",
    "00100011",
    "11000110",
    "10001000"
  ]

  15.step(1,4) do |i|
    m.write_display
    #lcd.locate(0,1)
    usb.print " #{i} "
    delay 81
    m.set_brightness(i)
  end


  #m.init_display
  [
    [0,0],[4,7],[0,6],[7,0],[3,3],[7,6],[0,1],[5,2]
  ].each do |ary|
    m.draw_pixel(ary.first,ary.last,0)
    delay(81)
  end

  m.buffer = [
    "01100010",
    "10010110",
    "10010010",
    "01100010",
    "10010010",
    "10010010",
    "01100111",
    "00000000"
  ]

  m.set_brightness(15)
  [:up, :down, :left, :right].each do |d|
    usb.println d.to_s
    8.times do
      m.shift(d)
      delay(81)
    end
  end

  delay(81)
  m.buffer = [
    "01100010",
    "10010110",
    "10010010",
    "01100010",
    "10010010",
    "10010010",
    "01100111",
    "00000000"
  ]
  81.times do
    m.rotate
    delay(810)
  end

  #
  # FILL
  #
  m.init_display
  0.upto(7) do |y|
    0.upto(7) do |x|
      m.draw_pixel(x,y,1)
      delay(81)
    end
  end
  delay(81)

  7.downto(0) do |y|
    7.downto(0) do |x|
      m.draw_pixel(x,y,0)
      delay(81)
    end
  end

  
  
#end
