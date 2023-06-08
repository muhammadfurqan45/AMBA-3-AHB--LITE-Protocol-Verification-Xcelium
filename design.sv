//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  AMBA AHB bus slave model (simple memory model)                          //
//                                                                          //
//  Copyright (C) 2008  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This RTL is free hardware: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

`include "amba_ahb_defines.sv"

module amba_ahb_slave #(
  // bus paramaters
  parameter AW = `AW,    // address bus width
  parameter DW = `DW,    // data bus width
  parameter DE = `DE,    // endianess
  parameter RW = `RW,    // response width
  // memory parameters
  parameter MS = 1024,  // memory size (in Bytes)
  parameter AM = {10{1'b1}},  // address mask
  // write and read latencies for sequential and nonsequential accesses
  parameter LW_NS = 0,  // write latency for nonsequential transfers
  parameter LW_S  = 0,  // write latency for sequential transfers
  parameter LR_NS = 0,  // read latency for nonsequential transfers
  parameter LR_S  = 0   // read latency for sequential transfers
)
(ifa bus);

//////////////////////////////////////////////////////////////////////////////
// local parameters and signals                                             //
//////////////////////////////////////////////////////////////////////////////

localparam SW = DW/8;  // byte select width (data bus width in Bytes)

// slave control signal
wor           error_req;

assign error_req = 1'b0;
assign error_req = bus.error;          // default error value

// cycle and burst length couners
// TODO should be integers
wire [32-1:0] delay;    // expected delay for observed cycle
wire [32-1:0] cnt_t;    // time counter reload input
reg  [32-1:0] cnt_t_r;  // time counter register

// registered AHB input signals
reg           hsel_r;
reg  [AW-1:0] haddr_r;
reg     [1:0] htrans_r;
reg           hwrite_r;
reg     [2:0] hsize_r;
reg     [2:0] hburst_r;
reg     [2:0] hprot_r;

// slave memory
reg     [7:0] mem [0:MS-1];

genvar i;

wire    [7:0] bytes;
wire [DW-1:0] wdata;    // write data buse used for endian byte swap
wire [DW-1:0] rdata;    // read data buse used for endian byte swap
wire          trn;      // read or write transfer
wire          trn_req;  // transfer request
wire          trn_ack;  // transfer acknowledge

//////////////////////////////////////////////////////////////////////////////
// pipelining input signals                                                 //
//////////////////////////////////////////////////////////////////////////////

always @(negedge bus.hresetn, posedge bus.hclk)
if (~bus.hresetn) begin
  htrans_r <= `H_IDLE;
  for(int i=0;i<256;i++) mem[i]=i;
end else if (bus.hready) begin
  hsel_r   <= bus.hsel;
  haddr_r  <= bus.haddr;
  htrans_r <= bus.htrans;
  hwrite_r <= bus.hwrite;
  hsize_r  <= bus.hsize;
  hburst_r <= bus.hburst;
  hprot_r  <= bus.hprot;
end

//////////////////////////////////////////////////////////////////////////////
// slave response timing                                                    //
//////////////////////////////////////////////////////////////////////////////

// cycle and burst length couners
// generating the response signals with the proper timing
always @(negedge bus.hresetn, posedge bus.hclk)
if (~bus.hresetn) begin
  cnt_t_r <= 0;
  bus.hready  <= 1'b1;
  bus.hresp   <= `H_OKAY;
end else begin
  // apply a new value to the counter register
  cnt_t_r <= cnt_t;
  // error response: wait periods + two ERROR periods
  if (bus.error) begin
    if (bus.hready) begin
      if ((bus.htrans == `H_IDLE) | (bus.htrans == `H_BUSY)) begin
        bus.hresp   <= `H_OKAY;
        bus.hready  <= 1'b1;
      end
      if ((bus.htrans == `H_NONSEQ) | (bus.htrans == `H_SEQ)) begin
        bus.hresp   <= (cnt_t == 0) ? `H_ERROR : `H_OKAY;
        bus.hready  <= 1'b0;
      end
    end else begin
      if ((htrans_r == `H_NONSEQ) | (htrans_r == `H_SEQ)) begin
        if (bus.hresp == `H_OKAY) begin
          bus.hresp   <= (cnt_t == 0) ? `H_ERROR : `H_OKAY;
        end else begin
          bus.hready  <= 1'b1;
        end
      end
    end
  // okay response: wait periods + one OKAY period
  end else begin
    bus.hresp   <= `H_OKAY;
    bus.hready  <= (cnt_t == 0);
  end
end

assign delay = bus.htrans[0] ? (bus.hwrite ? LW_S  : LR_S )
                         : (bus.hwrite ? LW_NS : LR_NS);

assign cnt_t = bus.hready ? (bus.htrans[1] & bus.hsel ? delay
                                          : 0)
                      : cnt_t_r - 1;

//////////////////////////////////////////////////////////////////////////////
// memory and data bus implementation                                       //
//////////////////////////////////////////////////////////////////////////////

assign trn_req = ((htrans_r == `H_NONSEQ) | (htrans_r == `H_SEQ)) & hsel_r;
assign trn_ack = bus.hready;
assign trn     = trn_req & trn_ack;

assign bytes = 1 << hsize_r;

// endian byte swap
generate
  for (i=0; i<SW; i=i+1) begin
    if (DE == "BIG") begin
//      assign  wdata [DW-1-8*i-:8] = bus.hwdata [8*i+:8];
//      assign bus.hrdata [DW-1-8*i-:8] =  rdata [8*i+:8];
    end else if (DE == "LITTLE") begin
//      assign  wdata [     8*i+:8] = bus.hwdata [8*i+:8];
//      assign bus.hrdata [     8*i-:8] =  rdata [8*i+:8];
    end
  end
        assign  wdata  =  bus.hwdata ;
        assign  bus.hrdata =  rdata ;
endgenerate

// write to memory
generate
  for (i=0; i<SW; i=i+1) begin
    always @(posedge bus.hclk) begin
      if (trn & (bus.hresp == `H_OKAY) & hwrite_r) begin
        if (((haddr_r&AM)%SW <= i) & (i < ((haddr_r&AM)%SW + bytes)))  mem [(haddr_r&AM)/SW*SW+i] <= wdata [8*i+:8];
      end
    end
  end
endgenerate

// read from memory
generate
  for (i=0; i<SW; i=i+1) begin
    assign rdata [8*i+:8] = ((trn & (bus.hresp == `H_OKAY) & ~hwrite_r) & ((haddr_r&AM)%SW <= i) & (i < ((haddr_r&AM)%SW + bytes))) ? mem [(haddr_r&AM)/SW*SW+i] : 8'hxx;
  end
endgenerate

endmodule
