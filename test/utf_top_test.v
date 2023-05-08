// import top.v
// import Imem.dat
// import Dmem.dat
  `timescale 1ns/1ps
  `define IN_TOTAL 10000  // 最大シミュレーション時間 = 10000 クロックサイクル

  module top_test;
    
    //*** parameter declarations ***//
    parameter CYCLE       = 10;            // クロックサイクル時間       = 10ns
    parameter HALF_CYCLE  =  5;            // クロックサイクル時間の半分 = 5ns
    parameter STB         =  8;
    parameter SKEW        =  2;
    parameter BIT_WIDTH   = 32;            // 1 word  = 32bit
    parameter BYTE_SIZE    =  8;           // 1 byte  = 8bit
    parameter IMEM_LATENCY = 1;            // 命令メモリのレイテンシ   = 1クロックサイクル
    parameter DMEM_LATENCY = 1;            // データメモリのレイテンシ = 1クロックサイクル
    parameter IMEM_SIZE = 8000000;         // 命令メモリのサイズ = 8000000 byte
    parameter DMEM_SIZE = 8000000;         // データメモリのサイズ = 8000000 byte
    parameter STDOUT_ADDR = 32'hf0000000;  // 出力を行うための特別なアドレス．このアドレスに対し，sb 命令を実行するとストアすると内容を文字として画面に出力
    parameter EXIT_ADDR = 32'hff000000;    // シミュレーションを終わらせるための特別なアドレス．このアドレスに対し，ストア命令を実行するとシミュレーションを終了

    //*** reg,wire declarations ***//
    reg       clk,rst;             // クロック信号，リセット信号
    reg       ACKD_n;              // データメモリ用のアクノリッジ信号（アクティブ Low）
    reg       ACKI_n;              // 命令メモリ用のアクノリッジ信号（アクティブ Low）
    reg [BIT_WIDTH-1:0] IDT;       // 命令メモリ用の32ビットデータバス
    reg [2:0]           OINT_n;    // 外部割り込み信号（アクティブ Low）
    reg [BIT_WIDTH-1:0] Reg_temp;  // レジスタの内容を出力するときにつかう一時的な変数

    wire [BIT_WIDTH-1:0] IAD;     // 命令メモリ用の32ビットアドレスバス
    wire [BIT_WIDTH-1:0] DAD;     // データメモリ用の32ビットアドレスバス
    wire                 MREQ;    // データメモリに対するリクエスト信号
    wire                 WRITE;   // データメモリに対する書き込み要求信号
    wire [1:0]           SIZE;    // データメモリへのアクセス単位（bit, half word, word）を指定するための信号
    wire                 IACK_n;  // 外部割り込みに対するアクノリッジ信号
    wire [BIT_WIDTH-1:0] DDT;     // データメモリ用の32ビットデータバス

    integer              i;
    integer              CIL, CDLL, CDSL;      // 命令メモリ，データメモリのレイテンシがあるように見せかけるためのカウンタ．アクセス開始からの時間を保持．
    integer              Reg_data, Dmem_data;  // ファイルポインタ．Reg_data はファイル Reg_out.dat, Dmem_data はファイル Dmem_out.dat に出力するために用いる
    integer              Max_Daddr;            // データメモリへアクセスのあった最大アドレスを保持．(Dmem_out.dat には 0 ～ Max_Daddr までの内容のみを出力）
    reg [BIT_WIDTH-1:0]  Daddr, Iaddr;         // データメモリへのアクセスアドレス，命令メモリへのアクセスアドレスを一時的に保持しておくためのレジスタ

    reg [BYTE_SIZE-1:0]   DATA_Imem[0:IMEM_SIZE];   // 命令メモリ
    reg [BYTE_SIZE-1:0]   DATA_Dmem[0:DMEM_SIZE];   // データメモリ

    //*** top モジュールとの結合 ***//
    top u_top_1(//Inputs
                .clk(clk), .rst(rst),
                .ACKD_n(ACKD_n), .ACKI_n(ACKI_n), 
                .IDT(IDT), .OINT_n(OINT_n),
        
                //Outputs
                .IAD(IAD), .DAD(DAD), 
                .MREQ(MREQ), .WRITE(WRITE), 
                .SIZE(SIZE), .IACK_n(IACK_n), 
        
                //Inout
                .DDT(DDT)
                );

    
      //*** クロックの生成 ***//
      always begin
          clk = 1'b1;
          #(HALF_CYCLE) clk = 1'b0;
          #(HALF_CYCLE);
      end


      //*** 初期化 init ***//
      initial begin
          //*** read input data ***//
          $readmemh("./Dmem.dat", DATA_Dmem);  // データメモリの内容（Dmem.datの中身）を DATA_Dmem に格納
          $readmemh("./Imem.dat", DATA_Imem);  // 命令メモリの内容（Imem.datの中身）を DATA_Imem に格納

          Max_Daddr = 0;  // Max_Daddr を 0 に初期化

          //*** reset OINT_n, ACKI_n, ACKD_n, CIL, CDL ***//
          OINT_n = 3'b111;  // 外部割り込みはなし
          ACKI_n = 1'b1;    // 命令メモリのアクノリッジ信号を初期化
          ACKD_n = 1'b1;    // データメモリのアクノリッジ信号を初期化
          CIL = 0;          // 命令メモリのレイテンシを見せかけるためのカウンタを初期化
          CDLL = 0;         // データメモリの読み出しのレイテンシを見せかけるためのカウンタを初期化
          CDSL = 0;         // データメモリの書き込みのレイテンシを見せかけるためのカウンタを初期化

          //*** リセットを行う ***//
          rst = 1'b1;
          #1 rst = 1'b0; // 0でリセットする。
          #CYCLE rst = 1'b1;
      end


      //*** プログラムの実行 ***//
      initial begin
          #HALF_CYCLE;  // 半クロックサイクル時間ずらす．クリティカルなタイミング（クロックが立ち上がる瞬間）に信号が遷移しないようにするため．

          //*** 最大 IN_TOTAL クロックサイクル、プログラムを実行 ***//
          for (i = 0; i < `IN_TOTAL; i =i +1)
            begin

              Iaddr = u_top_1.IAD;  // 命令メモリアクセスアドレスを Iaddr に格納
              fetch_task1;          //fn: 命令メモリから命令をフェッチ

              Daddr = u_top_1.DAD;  // データメモリアクセスアドレス Daddr に格納
              load_task1;           //fn: ロードを実行（メモリアクセス要求があれば）
              store_task1;          //fn: ストアを実行（メモリアクセス要求があれば）
              
              // #(STB);
              #CYCLE;               // 1クロックサイクル時間を進める
              release DDT;          // force で DDT の値を固定していた（詳しくは下の load_task1 を参照）のを解放

            end // for (i = 0; i < `IN_TOTAL; i =i +1)

          $display("\nReach IN_TOTAL.");    // メッセージを出力．最大のシミュレーション時間に達したから終わり

          dump_task1;   //fn: データメモリの内容を Dmem_out.dat に，汎用レジスタの内容を Reg_out.dat に出力

          $finish;      // シミュレーションの終了

      end // initial begin

    //*** description for wave form ***//
    initial begin
        $monitor($stime," PC=%h", IAD);   // PC の値を monitor する．
        $shm_open("waves.shm");
        $shm_probe("AS");
    end


    //*** 以下、task（c でいう関数みたいなもの） ***//

    task fetch_task1;   // 命令メモリからのフェッチ用のタスク
        begin
          CIL = CIL + 1;           // 命令メモリアクセス開始からの時間をカウントアップ
          if(CIL == IMEM_LATENCY)  // CIL が命令メモリのレイテンシに達したら，命令メモリ用データバスに命令を流す
            begin
                IDT = {DATA_Imem[Iaddr], DATA_Imem[Iaddr+1], DATA_Imem[Iaddr+2], DATA_Imem[Iaddr+3]};  // 命令メモリ用データバスに命令を流す
                ACKI_n = 1'b0;  // アクノリッジ信号をアクティブにする
                CIL = 0;        // CIL のリセット
            end
          else   // CIL が命令メモリのレイテンシまで達していない
            begin
                IDT = 32'hxxxxxxxx;  // 命令用データバスの値は不定
                ACKI_n = 1'b1;       // アクノリッジ信号をインアクティブにしておく
            end // else: !if(CIL == IMEM_LATENCY)
        end
    endtask // fetch_task1


    task load_task1;  // データメモリからの読み出し用のタスク
        begin
          if(u_top_1.MREQ && !u_top_1.WRITE)  // データメモリにリクエストがあり，書き込みでなかったら
            begin

                if (Max_Daddr < Daddr)    // Max_Daddr の更新
                  begin
                    Max_Daddr = Daddr;
                  end

                CDLL = CDLL + 1;  //  読み出しアクセス開始からの時間をカウントアップ
                CDSL = 0;         //  書き込みアクセス開始からの時間を 0 にする
                if(CDLL == DMEM_LATENCY)  // CDLL がデータメモリのレイテンシに達したら，データメモリ用データバスにデータを流す
                  begin
                    if(SIZE == 2'b00)
                      begin
                          force DDT[BIT_WIDTH-1:0] = {DATA_Dmem[Daddr], DATA_Dmem[Daddr+1],     // データメモリからの読み出し（word）
                                                      DATA_Dmem[Daddr+2], DATA_Dmem[Daddr+3]};  // （wire である DDT の内容を強制的に変更し，読み出したデータの値にする）
                      end              
                    else if(SIZE == 2'b01)
                      begin
                          force DDT[BIT_WIDTH-1:0] = {{16{1'b0}}, DATA_Dmem[Daddr], DATA_Dmem[Daddr+1]};  // データメモリからの読み出し（half word）
                      end
                    else
                      begin
                          force DDT[BIT_WIDTH-1:0] = {{24{1'b0}}, DATA_Dmem[Daddr]};  // データメモリからの読み出し（byte）
                      end // else: !if(SIZE == 2'b01)

                    ACKD_n = 1'b0;  // アクノリッジ信号をアクティブにする
                    CDLL = 0;       // CDLL のリセット

                  end // if (CDLL == DMEM_LATENCY)
                else  // CDLL がデータメモリのレイテンシに達していなかったら
                  begin
                    ACKD_n = 1'b1;  // アクノリッジ信号をインアクティブにする
                  end // else: !if(CDLL == DMEM_LATENCY)
            end // if (u_top_1.MREQ && !u_top_1.WRITE)
        end
    endtask // load_task1


    task store_task1;  // データメモリへの書き込み用のタスク
        begin
          if(u_top_1.MREQ && u_top_1.WRITE)  //  データメモリにリクエストがあり，書き込みであったら
            begin

                if (Daddr == EXIT_ADDR)    // アクセスアドレスが EXIT_ADDR と一致したら
                  begin
                    $display("\nExited by program.");  // メッセージを出力．プログラムによって，シミュレーションが終了させられた
                    dump_task1;  // データメモリの内容を Dmem_out.dat に，汎用レジスタの内容を Reg_out.dat に出力
                    $finish;     // シミュレーションを終了
                  end
                else if (Daddr != STDOUT_ADDR)  // アクセスアドレスが STDOUT_ADDR と一致していなかったら
                  begin
                    if (Max_Daddr < Daddr)     // Max_Daddr の更新
                      begin
                          Max_Daddr = Daddr;
                      end
                  end

                CDSL = CDSL + 1;  // 書き込みアクセス開始からの時間をカウントアップ
                CDLL = 0;         // 読み出しアクセス開始からの時間を 0 にする

                if(CDSL == DMEM_LATENCY)  // CDSL がデータメモリのレイテンシに達したら，データをメモリに書き込む
                  begin
                    if(SIZE == 2'b00)
                      begin
                          DATA_Dmem[Daddr]   = DDT[BIT_WIDTH-1:BIT_WIDTH-8];     //
                          DATA_Dmem[Daddr+1] = DDT[BIT_WIDTH-9:BIT_WIDTH-16];    //  データメモリへの書き込み（word）
                          DATA_Dmem[Daddr+2] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];   //
                          DATA_Dmem[Daddr+3] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];   //
                      end
                    else if(SIZE == 2'b01)
                      begin
                          DATA_Dmem[Daddr] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];     //  データメモリへの書き込み（half word）
                          DATA_Dmem[Daddr+1] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];   //
                      end
                    else
                      begin
                          if (Daddr == STDOUT_ADDR)  // アドレスが STDOUT_ADDR と一致していたら
                            begin
                              $write("%c", DDT[BIT_WIDTH-25:BIT_WIDTH-32]);  // ストアする内容を画面に出力
                            end
                          else
                            begin
                              DATA_Dmem[Daddr] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];  // データメモリへの書き込み（byte）
                            end
                      end // else: !if(SIZE == 2'b01)
                    
                    ACKD_n = 1'b0;  // アクノリッジ信号をアクティブにする
                    CDSL = 0;       // 書き込みアクセス開始からの時間を 0 にする

                  end // if (CDSL == DMEM_LATENCY)
                else  // CDSL がデータメモリのレイテンシに達していなかったら
                  begin
                    ACKD_n = 1'b1;  // アクノリッジ信号をインアクティブにする
                  end // else: !if(CDSL == DMEM_LATENCY)
            end // if (u_top_1.MREQ && u_top_1.WRITE)             
        end
    endtask // store_task1

    task dump_task1;  // データメモリの内容を Dmem_out.dat に，汎用レジスタの内容を Reg_out.dat に出力
        begin

          Dmem_data = $fopen("./Dmem_out.dat");  // Dmem_out.dat を開く
          for (i = 0; i <= Max_Daddr && i < DMEM_SIZE; i = i+4)  // データメモリの内容（アドレス 0 ～ Max_Daddr）を Dmem_out.dat に出力
            begin
              $fwrite(Dmem_data, "%h :%h %h %h %h\n", i, DATA_Dmem[i], DATA_Dmem[i+1], DATA_Dmem[i+2], DATA_Dmem[i+3]);
            end
          $fclose(Dmem_data);  // Dmem_out.dat を閉じる

          Reg_data = $fopen("./Reg_out.dat");  // Reg_out.dat を開く
          for (i =0; i < 32; i = i+1)          // レジスタの内容を Reg_out.dat 出力
            begin
              Reg_temp = u_top_1.u_rf32x32.u_DW_ram_2r_w_s_dff.mem >> (BIT_WIDTH * i);
              $fwrite(Reg_data, "%d:%h\n", i, Reg_temp);
            end
          $fclose(Reg_data);
        end

    endtask // dump_task1

  endmodule // top_test
