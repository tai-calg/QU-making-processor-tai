`timescale 1ns/1ps
`define IN_TOTAL 1000000000

module top_test;

   //*** parameter declarations ***//
   parameter CYCLE       = 8;
   parameter HALF_CYCLE  =  4;
   parameter STB         =  8;
   parameter SKEW        =  2;
   parameter BIT_WIDTH   = 32;
   parameter BYTE_SIZE    =  8;
   parameter IMEM_LATENCY = 1;  // instruction memory latency
   parameter DMEM_LATENCY = 1;  // data memory latency
   parameter IMEM_START = 32'h0000_0000;
   parameter DMEM_START = 32'h0800_0000;
   parameter IMEM_SIZE = 8000000;  // instruction memory size
   parameter DMEM_SIZE = 8000000;  // data memory size
   parameter STDOUT_ADDR = 32'hf0000000;
   parameter EXIT_ADDR = 32'hff000000;

   //*** reg,wire declarations ***//
   reg       clk,rst;
   reg       ACKD_n;
   reg       ACKI_n;
   reg [BIT_WIDTH-1:0] IDT1;
   reg [BIT_WIDTH-1:0] IDT2;
   reg [2:0]           OINT_n;
   reg [BIT_WIDTH-1:0] Reg_temp;

   wire [BIT_WIDTH-1:0] IAD;
   wire [BIT_WIDTH-1:0] DAD1;
   wire [BIT_WIDTH-1:0] DAD2;
   wire                 MREQ1;
   wire                 MREQ2;
   wire                 WRITE1;
   wire                 WRITE2;
   wire [1:0]           SIZE1;
   wire [1:0]           SIZE2;
   wire                 IACK_n;
   wire [BIT_WIDTH-1:0] DDT11;
   wire [BIT_WIDTH-1:0] DDT12;


   integer              i;
   integer              CIL, CDLL, CDSL;  // counter for emulate memory access latency
   integer              Reg_data, Dmem_data, Imem_data;   // file pointer for "Reg_out.dat", "Dmem.out"
   integer              Max_Daddr;  // integer for remenbering maximum accessed addr of data memory
   reg [BIT_WIDTH-1:0]  Daddr1, Daddr2, Iaddr;

   reg [BYTE_SIZE-1:0]   DATA_Imem[IMEM_START:IMEM_START + IMEM_SIZE];   // use in readmemh  (Instruction mem)
   reg [BYTE_SIZE-1:0]   DATA_Dmem[DMEM_START:DMEM_START + DMEM_SIZE];   // use in readmemh (Data mem)

   //*** module instantations ***//
   top u_top_1(//Inputs
               .clk(clk), .rst(rst),
               .ACKD_n(ACKD_n), .ACKI_n(ACKI_n),
               .IDT1(IDT1), .OINT_n(OINT_n),
               .IDT2(IDT2),

               //Outputs
               .IAD(IAD), 
               .DAD1(DAD1), .DAD2(DAD2),
               .MREQ1(MREQ1), .MREQ2(MREQ2), 
               .WRITE1(WRITE1), .WRITE2(WRITE2),
               .SIZE1(SIZE1), .SIZE2(SIZE2),
               .IACK_n(IACK_n),

               //Inout
               .DDT1(DDT1),
               .DDT2(DDT2)
               );

     //*** clock generation ***//
     always begin
        clk = 1'b1;
        #(HALF_CYCLE) clk = 1'b0;
        #(HALF_CYCLE);
     end

     //*** initialize ***//
     initial begin
        //*** read input data ***//
        $readmemh("./test/Dmem.dat", DATA_Dmem);
        $readmemh("./test/Imem.dat", DATA_Imem);

        Max_Daddr = 0;

        //*** reset OINT_n, ACKI_n, ACKD_n, CIL, CDL ***//
        OINT_n = 3'b111;
        ACKI_n = 1'b1;
        ACKD_n = 1'b1;
        CIL = 0;
        CDLL = 0;
        CDSL = 0;

        //*** reset ***//
        rst = 1'b1;
        #1 rst = 1'b0;
        #CYCLE rst = 1'b1;
     end

     initial begin
        #HALF_CYCLE;
        //*** data input loop ***//
        for (i = 0; i < `IN_TOTAL; i =i +1)
          begin

               //  $display("所要クロックサイクル数= %d | Iaddr = %h", i,Iaddr);
               // if (IAD == 32'hxxxxxxxx) begin
               //    $display("IAD is 0xxxxxxxxx+4 at time %t", $time);
               //    $stop;
               // end
             Iaddr = u_top_1.IAD;
             fetch_task1; //F stage

             Daddr1 = u_top_1.DAD1;
             Daddr2 = u_top_1.DAD2;
             load_task1;
             load_task2;
             store_task1;
             store_task2;

             // #(STB);
             #CYCLE;
             release DDT1;
             release DDT2;
             // rerurn if inst is xxxx
               if (IDT1 == 32'hxxxxxxxx || IDT2 == 32'hxxxxxxxx)
                  begin
                     $display("\nReach xxxx.");
                     $finish;
                  end
          end // for (i = 0; i < `IN_TOTAL; i =i +1)

        $display("\nReach IN_TOTAL.");

        dump_task;

        $finish;

     end // initial begin

   //*** description for wave form ***//
   initial begin
      $monitor($stime," PC=%h INST1=%h and INST2=%h", IAD, IDT1 ,IDT2);
      //ここから2行はIcarus Verilog用(手元で動かすときに使ってください)
	  $dumpfile("top_test.vcd");
      $dumpvars(0, u_top_1);
	  //ここから2行はNC-Verilog用(woodblockで動かすときに使ってください)
   //    $shm_open("waves.shm");
   //    $shm_probe("AS");
   end


   //*** tasks ***//

   task fetch_task1;
      begin
         CIL = CIL + 1;
         if(CIL == IMEM_LATENCY)
           begin
              IDT1 = {DATA_Imem[Iaddr], DATA_Imem[Iaddr+1], DATA_Imem[Iaddr+2], DATA_Imem[Iaddr+3]};
              IDT2 = {DATA_Imem[Iaddr+4], DATA_Imem[Iaddr+5], DATA_Imem[Iaddr+6], DATA_Imem[Iaddr+7]};
              //! ここにIaddrをもう一つ付け足して一度で２命令分読み込めばいける→どこで並列依存性を確認すればいい？
              ACKI_n = 1'b0;
              CIL = 0;
           end
         else
           begin
              IDT1 = 32'hxxxxxxxx;
              IDT2 = 32'hxxxxxxxx;
              ACKI_n = 1'b1;
           end // else: !if(CIL == IMEM_LATENCY)
      end
   endtask // fetch_task1

   task load_task1;
      begin
         if(u_top_1.MREQ1 && !u_top_1.WRITE1)
           begin

              if (Max_Daddr < Daddr1)
                begin
                   Max_Daddr = Daddr1;
                end

              CDLL = CDLL + 1;
              CDSL = 0;
              if(CDLL == DMEM_LATENCY)
                begin
                   if(SIZE1 == 2'b00)
                     begin
                        force DDT1[BIT_WIDTH-1:0] = {DATA_Dmem[Daddr1], DATA_Dmem[Daddr1 + 1],
                                                    DATA_Dmem[Daddr1 + 2], DATA_Dmem[Daddr1 + 3]};

                     end
                   else if(SIZE1 == 2'b01) //half
                     begin
                        force DDT1[BIT_WIDTH-1:0] = {{16{1'b0}}, DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b10} - Daddr1[1:0]],
													DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b10} - Daddr1[1:0] + 1]};
                     end
                   else
                     begin //byte
                        force DDT1[BIT_WIDTH-1:0] = {{24{1'b0}}, DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b11} - Daddr1[1:0]]};
                     end // else: !if(SIZE1 == 2'b01)


                   ACKD_n = 1'b0;
                   CDLL = 0;

                end // if (CDLL == DMEM_LATENCY)
              else
                begin
                   ACKD_n = 1'b1;
                end // else: !if(CDLL == DMEM_LATENCY)
           end // if (u_top_1.MREQ && !u_top_1.WRITE1)
      end
   endtask // load_task1

   task load_task2;
      begin
         if(u_top_1.MREQ2 && !u_top_1.WRITE2)
           begin

              if (Max_Daddr < Daddr2)
                begin
                   Max_Daddr = Daddr2;
                end

              CDLL = CDLL + 1;
              CDSL = 0;
              if(CDLL == DMEM_LATENCY)
                begin
                   if(SIZE2 == 2'b00)
                     begin
                        force DDT2[BIT_WIDTH-1:0] = {DATA_Dmem[Daddr2], DATA_Dmem[Daddr2 + 1],
                                                    DATA_Dmem[Daddr2 + 2], DATA_Dmem[Daddr2 + 3]};

                     end
                   else if(SIZE2 == 2'b01) //half
                     begin
                        force DDT2[BIT_WIDTH-1:0] = {{16{1'b0}}, DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b10} - Daddr2[1:0]],
													DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b10} - Daddr2[1:0] + 1]};
                     end
                   else
                     begin //byte
                        force DDT2[BIT_WIDTH-1:0] = {{24{1'b0}}, DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b11} - Daddr2[1:0]]};
                     end // else: !if(SIZE2 == 2'b01)


                   ACKD_n = 1'b0;
                   CDLL = 0;

                end // if (CDLL == DMEM_LATENCY)
              else
                begin
                   ACKD_n = 1'b1;
                end // else: !if(CDLL == DMEM_LATENCY)
           end 
      end
   endtask // load_task2

   task store_task1;
      begin
         if(u_top_1.MREQ1 && u_top_1.WRITE1)
           begin

              if (Daddr1 == EXIT_ADDR)
                begin
                   $display("\nExited by program.");
                   dump_task;
                   $finish;
                end
              else if (Daddr1 != STDOUT_ADDR)
                begin
                   if (Max_Daddr < Daddr1)
                     begin
                        Max_Daddr = Daddr1;
                     end
                end

              CDSL = CDSL + 1;
              CDLL = 0;

              if(CDSL == DMEM_LATENCY)
                begin
                   if(SIZE1 == 2'b00)
                     begin
                        DATA_Dmem[Daddr1]   = DDT1[BIT_WIDTH-1:BIT_WIDTH-8];
                        DATA_Dmem[Daddr1+1] = DDT1[BIT_WIDTH-9:BIT_WIDTH-16];
                        DATA_Dmem[Daddr1+2] = DDT1[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[Daddr1+3] = DDT1[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                   else if(SIZE1 == 2'b01)
                     begin
                        DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b10} - Daddr1[1:0]] = DDT1[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b10} - Daddr1[1:0] + 1] = DDT1[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                   else
                     begin
                        if (Daddr1 == STDOUT_ADDR)
                          begin
                             $write("%c", DDT1[BIT_WIDTH-25:BIT_WIDTH-32]);
                          end
                        else
                          begin // under8bit write : SIZE1 = 10
                             DATA_Dmem[{Daddr1[BIT_WIDTH-1:2],2'b11} - Daddr1[1:0]] = DDT1[BIT_WIDTH-25:BIT_WIDTH-32];
                          end
                     end

                   ACKD_n = 1'b0;
                   CDSL = 0;
                  //  $display("Dmem[%h] = %h", Daddr1, DDT1[BIT_WIDTH-1:0]);


                end // if (CDSL == DMEM_LATENCY)
              else
                begin
                   ACKD_n = 1'b1;
                end // else: !if(CDSL == DMEM_LATENCY)
           end // if (u_top_1.MREQ && u_top_1.WRITE1)
      end
   endtask // store_task1

   task store_task2;
      begin
         if(u_top_1.MREQ2 && u_top_1.WRITE2)
           begin

              if (Daddr2 == EXIT_ADDR)
                begin
                   $display("\nExited by program.");
                   dump_task;
                   $finish;
                end
              else if (Daddr2 != STDOUT_ADDR)
                begin
                   if (Max_Daddr < Daddr2)
                     begin
                        Max_Daddr = Daddr2;
                     end
                end

              CDSL = CDSL + 1;
              CDLL = 0;

              if(CDSL == DMEM_LATENCY)
                begin
                   if(SIZE2 == 2'b00)
                     begin
                        DATA_Dmem[Daddr2]   = DDT2[BIT_WIDTH-1:BIT_WIDTH-8];
                        DATA_Dmem[Daddr2+1] = DDT2[BIT_WIDTH-9:BIT_WIDTH-16];
                        DATA_Dmem[Daddr2+2] = DDT2[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[Daddr2+3] = DDT2[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                   else if(SIZE2 == 2'b01)
                     begin
                        DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b10} - Daddr2[1:0]] = DDT2[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b10} - Daddr2[1:0] + 1] = DDT2[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                   else
                     begin
                        if (Daddr2 == STDOUT_ADDR)
                          begin
                             $write("%c", DDT2[BIT_WIDTH-25:BIT_WIDTH-32]);
                          end
                        else
                          begin // under8bit write : SIZE2 = 10
                             DATA_Dmem[{Daddr2[BIT_WIDTH-1:2],2'b11} - Daddr2[1:0]] = DDT2[BIT_WIDTH-25:BIT_WIDTH-32];
                          end
                     end

                   ACKD_n = 1'b0;
                   CDSL = 0;
                  //  $display("Dmem[%h] = %h", Daddr2, DDT2[BIT_WIDTH-1:0]);


                end // if (CDSL == DMEM_LATENCY)
              else
                begin
                   ACKD_n = 1'b1;
                end // else: !if(CDSL == DMEM_LATENCY)
           end // if (u_top_1.MREQ && u_top_1.WRITE1)
      end
   endtask // store_task2

   task dump_task;
      begin
        Imem_data = $fopen("./Imem_out.dat");
        for (i = IMEM_START; i <= IMEM_START + IMEM_SIZE; i = i+4)  // output data memory to Dmem_data (Dmem_out.dat)
          begin
             $fwrite(Imem_data, "%h :%h %h %h %h\n", i, DATA_Imem[i], DATA_Imem[i+1], DATA_Imem[i+2], DATA_Imem[i+3]);
          end
        $fclose(Imem_data);
        Dmem_data = $fopen("./Dmem_out.dat");
        for (i = DMEM_START; i <= DMEM_START + DMEM_SIZE; i = i+4)  // output data memory to Dmem_data (Dmem_out.dat)
          begin
             $fwrite(Dmem_data, "%h :%h %h %h %h\n", i, DATA_Dmem[i], DATA_Dmem[i+1], DATA_Dmem[i+2], DATA_Dmem[i+3]);
          end
        $fclose(Dmem_data);

        Reg_data = $fopen("./Reg_out.dat");
        for (i =0; i < 32; i = i+1)  // output register to Reg_data (Reg_out.dat)
          begin
             Reg_temp = u_top_1.datapath.rf.u_DW_ram_2r_w_s_dff.mem >> (BIT_WIDTH * i);
             $fwrite(Reg_data, "%d:%h\n", i, Reg_temp);
          end
        $fclose(Reg_data);
      end

   endtask // dump_task

endmodule // top_test
