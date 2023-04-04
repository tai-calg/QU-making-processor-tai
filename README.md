# B4 processor設計開発ディレクトリ

## 1. 概要
macにおいてコンパイル、シミュレーションの環境は以下のサイトを参考に構築しています。
コンパイルはiverilogを使用, 実行ファイルの実行はvvpを使用, シミュレーションは open **.vcdで行います。
https://miyanetdev.com/archives/240

```shell
$ iverilog -o main main.v AND_gate.v
$ vvp main
VCD info: dumpfile dump.vcd opened for output.
$ open dump.vcd
```