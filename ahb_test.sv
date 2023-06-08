///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_test.sv
// Title       : Memory Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory testbench module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module ahb_test ( ifa bus
                );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
// Packed Array to read data from burst
//bit[3:0] [31:0] data_burst_read ;

// Packed Array to hold data to be written in burst
bit [3:0] [31:0]data_burst = '{32'h59, 32'h61, 32'h63, 32'h65};
logic [7:0] rd_8bit;
logic [15:0] rd_16bit;
logic [31:0] rd_32bit;
logic [63:0] rd_64bit;
logic [127:0] rd_128bit;
logic [255:0] rd_256bit;
logic [511:0] rd_512bit;
logic [1023:0] rd_1024bit;
// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
     #5000 $display ( "MEMORY TEST TIMEOUT" );
     $finish;
    end

initial
  begin: memtest
  int error_status;

	$display("Checking 32bit data read and write when hsel is 0");
    for (int i = 0; i< 32; i=i+4)
	begin
       bus.write_hsel (i, i);
       bus.read_hsel (i, rd_32bit);
	bus.check(i,i,rd_32bit);
   	end
	//$display("Checking 32bit data read and write when error is 1");
       //bus.write_error (0, 0);
       //bus.read_error (0, rd_32bit);
	//bus.check(0,0,rd_32bit);
	$display("Checking 8bit data read and write");
    for (int i = 0; i< 32; i++)
	begin
       bus.write_8bit (i, i);
       bus.read_8bit (i, rd_8bit);
	bus.check_8bit(i,i,rd_8bit);
   	end
	$display("Checking 16bit data read and write");
    for (int i = 0; i< 32; i=i+2)
	begin
       bus.write_16bit (i, i);
       bus.read_16bit (i, rd_16bit);
	bus.check_16bit(i,i,rd_16bit);
   	end
	$display("Checking 32bit data read and write");
    for (int i = 0; i< 32; i=i+4)
	begin
       bus.write (i, i);
       bus.read (i, rd_32bit);
	bus.check(i,i,rd_32bit);
   	end
	$display("Checking 64bit data read and write");
    for (int i = 0; i< 32; i=i+8)
	begin
       bus.write_64bit (i, i);
       bus.read_64bit (i, rd_64bit);
       bus.check_64bit(i,i,rd_64bit);
       end
	$display("Checking 128bit data read and write");
    for (int i = 0; i< 32; i=i+16)
	begin
       bus.write_128bit (i, i);
       bus.read_128bit (i, rd_128bit);
       bus.check_128bit(i,i,rd_128bit);
       end
	$display("Checking 256bit data read and write");
       bus.write_256bit (0,255'h1234567891234567834567 );
       bus.read_256bit (0, rd_256bit);
       bus.check_256bit(0,255'h1234567891234567834567 ,rd_256bit);
	$display("Checking 512bit data read and write");
       bus.write_512bit (0,511'h1234567891234567834567 );
       bus.read_512bit (0, rd_512bit);
       bus.check_512bit(0,511'h1234567891234567834567 ,rd_512bit);
	$display("Checking 1024bit data read and write");
       bus.write_512bit (0,1023'h1234567891234567834567 );
       bus.read_512bit (0, rd_1024bit);
       bus.check_512bit(0,1023'h1234567891234567834567 ,rd_1024bit);

       //bus.write_64bit (0, 64'h3456789012345678);
       //bus.read_64bit (0, rd_64bit);
	//bus.check_64bit(0,64'h3456789012345678,rd_64bit);
  // `endif
    //#400;
   // $finish;

  end
// Coverage for size
covergroup cg_hsize @(posedge hclk);
    coverpoint ifa.hsize {
      bins Byte              = {0};
      bins Halfword          = {1};
      bins Word              = {2};
    }
endgroup

// Coverage for write_data
covergroup cg_write_data @(posedge hclk);
    option.per_instance = 1;
    coverpoint ifa.hwdata {
      bins lowest = {[0:8]};
      bins lower[4] = {[8:16]};
      bins mid[4] = {[16:64]};
      bins high[4] = {[64:256]};
      bins misc = default;
    }
endgroup
// Coverage for address
covergroup cg_address @(posedge hclk);
    option.per_instance = 1;
    coverpoint ifa.haddr {
      bins zero = {[0:80]};
      bins low[4] = {[80:160]};
      bins med[4] = {[160:640]};
      bins high[4] = {[640:1023]};
      bins misc = default;
    }
endgroup
// Coverage for only single burst mode
covergroup cg_burst @(posedge hclk);
    option.per_instance = 1;

    coverpoint ifa.hburst {
      bins SINGLE   = {0};
       }

endgroup


cg_hsize cg1;
cg_write_data cg2;
cg_address cg3;
cg_burst cg4;

initial begin
cg1 =new();
cg2 = new();
cg3 = new();
cg4 = new();
end
endmodule
