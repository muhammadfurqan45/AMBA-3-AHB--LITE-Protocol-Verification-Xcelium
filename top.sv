///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : top.sv
// Title       : top module for Memory labs 
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the top module for memory labs
// Notes       :
// Memory Lab - top-level 
// A top-level module which instantiates the memory and mem_test modules
// 
///////////////////////////////////////////////////////////////////////////
`include "amba_ahb_defines.sv"
`include "interface.sv"
`include "design.sv"
`include "ahb_test.sv"
module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;
bit         hclk;
reg [31:0] rd_3;
bit hresetn;
ifa busa (hclk,hresetn);
// SYSTEMVERILOG: logic and bit data types


// SYSTEMVERILOG:: implicit .* port connections
ahb_test test (busa);

// SYSTEMVERILOG:: implicit .name port connections
amba_ahb_slave slave (  busa);
initial 
begin
		$dumpfile("top_dump.vcd");
		$dumpvars(0,top);
hresetn=1;
//$display("when reset is high");
       //busa.write (0, 0);
       //busa.read (0, rd_3);
	//busa.check(0,0,rd_3);
#10 hresetn=0;
#10 hresetn=1;
//#800 $finish;
end
always #5 hclk = ~hclk;
endmodule
