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


## TODO

//シミュレーションをみると、hello.dsの100e8のret命令で100d8にもどってこの間を無限ループしてる
これの原因解析。
myputs()にて発生。

## 疑問点


- ｓｌｔって2回演算するよね（クロック2回変わる必要あるよね）？

今のALUは全て１クロックで完了するようにしてるのだけれど、もしこれを拡張したらALUが遅くなってしまうのでは…
パイプライン最適化のためにも汎用ALUは１クロックに収めたい

ALUを簡単にするため４ビットのALU_OPを使っているが、A-Bをゼロフラグで判定して、ブランチするかどうかに使う代わりにA==Bを実装してしまった。だが、A==Bを廃止してA-Bのゼロフラグで判定する実装を採用した。



## 議論

- U形式の符号拡張どうする問題

1. immSrcの信号を一本増やす（最も純粋）
2. U形式の処理をするためだけの専用モジュールを作る。U形式と判定したらそっちに流す。(最適な処理がかけるかも?)
3. ハイブリッド版。全形式で使うALUを複数個作ったり、U形式を判定して特別な処理に回したり。

とりあえず１で実装してみる. immsrc=100の時Utype。

- ゼロフラグとItype19命令などを原因にALUを魔改造してる。

Itype19命令をalu_op=11として新たに分離させた。そうしないとaddiがSUB演算をしてしまうため。

   10018:	00112623          	sw	ra,12(sp)

ここまで動作確認済み。
しかし
   
   1001c:	00812423          	sw	s0,8(sp)
   
   で8がSrcBなのに12のままになってる。

- 0514 変更点

top.vに

    assign DDT = WRITE ? rd2 : 32'hz; 

を設置。プロセッサ設計における注意点2020pdfを参照した。

```
       200 PC=000100cc
       210 PC=000100d0
       220 PC=000100XX
```

まで動作確認済み.

```
   100c8:	00f707b3          	add	a5,a4,a5
   100cc:	0007c783          	lbu	a5,0(a5)
   100d0:	**fc0796e3**          	bnez	a5,1009c <myputs+0x1c>
   100d4:	fec42783          	lw	a5,-20(s0) //! back to here
   100d8:	00078513          	mv	a0,a5
```
bnezで止まっているので、その前後あたりの信号線をみて解決を図る
