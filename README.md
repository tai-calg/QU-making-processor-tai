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

ファイルを書き換えたあとは一度make cleanするのを推奨。top_test.v以外を変更した場合はmakeコマンドを使用しても反映されません。
それらをまとめたのがcompile.shです。

- makefileの文法

https://tex2e.github.io/blog/makefile/automatic-variables

- 論理合成

```dc_shell-t -f first_test.tcl | tee log```

で実行できます。`| tee ` によってlogファイルに結果が記録されます。

  - クリティカルパスの探索決定方法 

.tclファイルの

```create_clock -period 7.90 clk```

を調整してslack(MET) が負にならない最小値を探っていきます。data arrival time がクリティカルパスにかかる時間です。

```ncverilog pipeline/test/top_test.sv pipeline/top.v```

のようにしてコンパイルと実行を行います。プロジェクトのトップディレクトリで行ってください。そうしなければreadmesh("path")が正しくファイルをReadできません。

実行の最後にprintされる ”2178681750 PS + 0” がスクリプトの実行にかかった時間です。

## TODO




## 疑問点


- sltは2回演算する（クロック2回変わる必要ある）？

今のALUは全て１クロックで完了するようにしてるのだけれど、もしこれを拡張したらALUが遅くなってしまうのでは…
パイプライン最適化のためにも汎用ALUは１クロックに収めたい

ALUを簡単にするため４ビットのALU_OPを使っているが、A-Bをゼロフラグで判定して、ブランチするかどうかに使う代わりにA==Bを実装してしまった。だが、A==Bを廃止してA-Bのゼロフラグで判定する実装を採用した。



## 議論

- U形式の符号拡張をどうするか

1. immSrcの信号を一本増やす（最も純粋）
2. U形式の処理をするためだけの専用モジュールを作る。U形式と判定したらそっちに流す。(最適な処理がかけるかも?)
3. ハイブリッド版。全形式で使うALUを複数個作ったり、U形式を判定して特別な処理に回したり。

とりあえず１で実装してみる. immsrc=100の時Utype。

- ゼロフラグとItype19命令などを原因にALUを魔改造してる。

Itype19命令をalu_op=11として新たに分離させた。そうしないとaddiがSUB演算をしてしまうため。


top.vに

    assign DDT = WRITE ? rd2 : 32'hz; 

を設置。プロセッサ設計における注意点2020pdfを参照した。


