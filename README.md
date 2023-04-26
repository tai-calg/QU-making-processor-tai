# B4 processor設計開発ディレクトリ

## 1. 概要
macにおいてコンパイル、シミュレーションの環境は以下のサイトを参考に構築しています。
コンパイルはiverilogを使用, 実行ファイルの実行はvvpを使用, シミュレーションは open **.vcdで行います。
https://miyanetdev.com/archives/240

```shell
$ iverilog -o main.vvp main.v AND_gate.v
$ vvp main.vvp
VCD info: dumpfile dump.vcd opened for output.
$ open dump.vcd
```

testディレクトリの.vファイルがシミュレーションファイルです。
 
- how to use make command 

makeコマンドで.vvpが出力されます、vvpコマンドで.vvpファイルをコンパイルするとdump.vcdが出力されます。

- open *.vcdでGUIでシミュレーションが確認できます。

- makefileの文法

https://tex2e.github.io/blog/makefile/automatic-variables


## TODO

1. Utype配線の設計

比較器とUtype処理演算器は別に作ろう。
比較器は処理が2回になるため。Utypeはfunct{3,7}がないため。

## 疑問点

- U形式funct3すらないからどうするんだ？alu_opに00渡してもfunct3ないから+-判定できないぞ

- ｓｌｔって2回演算するよね（クロック2回変わる必要あるよね）？

今のALUは全て１クロックで完了するようにしてるのだけれど、もしこれを拡張したらALUが遅くなってしまうのでは…
パイプライン最適化のためにも汎用ALUは１クロックに収めたい



## 議論

- U形式の符号拡張どうする問題

1. immSrcの信号を一本増やす（最も純粋）
2. U形式の処理をするためだけの専用モジュールを作る。U形式と判定したらそっちに流す。(最適な処理がかけるかも?)
3. ハイブリッド版。全形式で使うALUを複数個作ったり、U形式を判定して特別な処理に回したり。

とりあえず１で実装してみる. immsrc=100の時Utype。

## 文法

always_comb : pubsubのように信号線に変化があったら処理を行う。