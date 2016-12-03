Adafruit 8x8 LED Matrix用ライブラリ for GR-CITRUS/mruby
====

# Overview

GR-CITRUSでAdafruit 8x8 LED Matrixを使うためのmruby用ライブラリです。


## Description

## Requirement

## Usage

Classとして定義されてます。
```
Matrix_8x8

#インスタンスを作成する。
#new(opt)
   opt = {:port=> WireNo, :addr=> I2C Address }

#表示モードを設定する
#set_blink_rate(mode)
   mode : 0=off, 1=1秒...

-明るさを1〜15で設定する
#set_brightness(brightness)
   brightness: 1〜15

-表示する内容をArrayでまとめてバッファに設定する
#buffer=(ary)
   ary は
   [
     "11111111",
     "00000000",...
   ]
   ...のように1行ごと 文字列で 点灯する部分を1, 消灯する部分を0で指定します


-バッファに設定されている内容で描画する
#write_display

-ピクセルを描画する
#draw_pixel(x,y,color)
  color: 0消灯, 1点灯

-表示されている内容を上下左右いずれにかズラす。
#shift(direction)
  direction : :up,:down,:right,:left

-すべて消灯する
#clear

```


## Install
require等の組み込みがない場合は、自分のプログラムのどこかにコピペすればいいんじゃないでしょうか。
I2C接続で Wire1 を使う場合は、pin0,1にSDA/SCL接続します。
アドレスは標準で0x70想定ですが、0x71等に変更している場合は下記のように設定します。

```
matrix = Matrix_8x8.new( {:port=>1, :addr=>0x71} )
```



## Author

[paichi81](https://github.com/paichi81)
