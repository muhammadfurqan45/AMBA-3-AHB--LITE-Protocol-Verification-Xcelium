timeunit 1ns;
timeprecision 1ns;
`include "amba_ahb_defines.sv"
interface ifa(input bit hclk,input bit hresetn);

  // AMBA AHB decoder signal
  logic            hsel;     // Slave select
  // AMBA AHB master signals
  logic  [31:0] haddr;    // Address bus
  logic      [1:0] htrans;   // Transfer type
  logic            hwrite;   // Transfer direction
  logic      [2:0] hsize;   // Transfer size
  logic      [2:0] hburst;   // Burst type
  logic      [3:0] hprot;    // Protection control
  logic   [31:0] hwdata;   // Write data bus
  // AMBA AHB slave signals
  logic  [31:0] hrdata;   // Read data bus
  logic            hready;   // Transfer done
  logic   	 hresp;    // Transfer response
  // slave control signal
  logic             error;     // request an error response
//////////////////clocking Block/////////////////////////////////////////////////////////////////////////////////////////
  //clocking DUT_CB @(posedge hclk)
    //default input #1 output #3;
    //output hsel, haddr, hwrite, hsize, hburst, hprothtrans, hmastlock, hready, hwdata, hresetn,error;
    //input hready, hresp, hrdata;
  //endclocking : DUT_CB
  clocking cb @(posedge hclk);
      default input #1
              output #1;
    input hready;
    input hrdata;
    input hresp;

    output haddr;
    output htrans;
    output hwrite;
    output hsize;
    output hburst;
    output hprot;
    output hwdata;
    output error;

  endclocking
////////////////////////////////////////////basic read and write when hsel is 0///////////////////////////////
task read_hsel(input bit [31:0] addr, output logic [31:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b010;								// define HSIZE as a Parameter and change it in compile time, nitially lets start with 32 bits - halfword
	hburst	= 3'b000;								// Single burst
	hsel    = '0;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data = hrdata;  								// Get the data from the slave(RAM)
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 32bit/////////////////////////////////////////////

task write_hsel(input bit[31:0] addr, input logic[31:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b010;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time 
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='0;				
	error   ='0;
	
	@(posedge hclk);
	hwdata	= data;
	@(posedge hclk);
		
endtask
/////////////////////////////basic write and read with hsel with error response//////////////
task read_error(input bit [31:0] addr, output logic [31:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b010;								// define HSIZE as a Parameter and change it in compile time, nitially lets start with 32 bits - halfword
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '1;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data = hrdata;  								// Get the data from the slave(RAM)
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 32bit/////////////////////////////////////////////

task write_error(input bit[31:0] addr, input logic[31:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b010;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time 
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='1;
	
	@(posedge hclk);
	hwdata	= data;
	@(posedge hclk);
		
endtask
////////////////////////////BASIC READ WITH AND WITHOUT WAIT STATES for 32bit///////////////////////////////////////////////////////
task read(input bit [31:0] addr, output logic [31:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b010;								// define HSIZE as a Parameter and change it in compile time, nitially lets start with 32 bits - halfword
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data = hrdata;  								// Get the data from the slave(RAM)
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 32bit/////////////////////////////////////////////

task write(input bit[31:0] addr, input logic[31:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b010;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time 
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata	= data;
	//@(posedge hclk);
		
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES/////////////////////////////////////////////

task write_8bit(input bit[31:0] addr, input logic[7:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b000;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	begin
	if(addr[1:0]=='b00)
	hwdata[7:0]=data; 								// Get the data from the slave(RAM)
	else if(addr[1:0]=='b01)
	hwdata[15:8]=data;// Get the data from the slave(RAM)
	else if(addr[1:0]=='b10)
	hwdata[23:16]=data;// Get the data from the slave(RAM)
	else if(addr[1:0]=='b11)
	hwdata[31:24]=data;// Get the data from the slave(RAM)
	end
	@(posedge hclk);
		
endtask	
task read_8bit(input bit [31:0] addr, output logic [7:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b000;								// define HSIZE as a Parameter and change it in compile time, nitially lets start with 32 bits - halfword
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	begin
	if(addr[1:0]=='b00)
	data = hrdata[7:0]; 								// Get the data from the slave(RAM)
	else if(addr[1:0]=='b01)
	data = hrdata[15:8];// Get the data from the slave(RAM)
	else if(addr[1:0]=='b10)
	data = hrdata[23:16];// Get the data from the slave(RAM)
	else if(addr[1:0]=='b11)
	data = hrdata[31:24];// Get the data from the slave(RAM)
	end
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 16bit/////////////////////////////////////////////
task write_16bit(input bit[31:0] addr, input logic[15:0] data); //pragma tbx xtf
	
	//@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b001;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	//begin
	if(addr[1]==1'b0)
	hwdata[15:0]=data; 								// Get the data from the slave(RAM)
	else
	hwdata[31:16]=data;// Get the data from the slave(RAM)
	//end
	@(posedge hclk);
		
endtask	
task read_16bit(input bit [31:0] addr, output logic [15:0] data);
	//@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b001;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	//begin
	if(addr[1]==1'b0)
	data = hrdata[15:0]; 								// Get the data from the slave(RAM)
	else
	data = hrdata[31:16];// Get the data from the slave(RAM)
	//end
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 64bit/////////////////////////////////////////////
task write_64bit(input bit[31:0] addr, input logic[63:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b011;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata=data[31:0]; 
	@(posedge hclk);
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[63:32]; 								// Get the data from the slave(RAM)
	//@(posedge hclk);
		
endtask	
task read_64bit(input bit [31:0] addr, output logic [63:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b011;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data[31:0] = hrdata;
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[63:32] = hrdata; 								// Get the data from the slave(RAM)
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 128bit/////////////////////////////////////////////
task write_128bit(input bit[31:0] addr, input logic[127:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b100;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata=data[31:0]; 
	@(posedge hclk);
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[63:32]; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	haddr 	= addr+8;
	@(posedge hclk);
	hwdata=data[95:64];
	@(posedge hclk);
	haddr 	= addr+12;
	@(posedge hclk);
	hwdata=data[127:96];
		
endtask	
task read_128bit(input bit [31:0] addr, output logic [127:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b100;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data[31:0] = hrdata;
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[63:32] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+8;
	@(posedge hclk);
	data[95:64] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+8;
	@(posedge hclk);
	data[127:96] = hrdata; 								// Get the data from the slave(RAM)
endtask
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 256bit/////////////////////////////////////////////
task write_256bit(input bit[31:0] addr, input logic[255:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b101;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata=data[31:0]; 
	@(posedge hclk);
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[63:32]; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	haddr 	= addr+8;
	@(posedge hclk);
	hwdata=data[95:64];
	@(posedge hclk);
	haddr 	= addr+12;
	@(posedge hclk);
	hwdata=data[127:96];
	@(posedge hclk);
	haddr 	= addr+16;
	@(posedge hclk);
	hwdata=data[159:128];
	@(posedge hclk);
	haddr 	= addr+20;
	@(posedge hclk);
	hwdata=data[191:160];
	@(posedge hclk);
	haddr 	= addr+24;
	@(posedge hclk);
	hwdata=data[223:192];
	@(posedge hclk);
	haddr 	= addr+28;
	@(posedge hclk);
	hwdata=data[255:224];
		
endtask	
task read_256bit(input bit [31:0] addr, output logic [255:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b101;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data[31:0] = hrdata;
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[63:32] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+8;
	@(posedge hclk);
	data[95:64] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+12;
	@(posedge hclk);
	data[127:96] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+16;
	@(posedge hclk);
	data[159:128] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+20;
	@(posedge hclk);
	data[191:160] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+24;
	@(posedge hclk);
	data[223:192] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+28;
	@(posedge hclk);
	data[255:224] = hrdata; 								// Get the data from the slave(RAM)
endtask	
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 512bit/////////////////////////////////////////////
task write_512bit(input bit[31:0] addr, input logic[511:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b110;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata=data[31:0]; 
	@(posedge hclk);
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[63:32]; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	haddr 	= addr+8;
	@(posedge hclk);
	hwdata=data[95:64];
	@(posedge hclk);
	haddr 	= addr+12;
	@(posedge hclk);
	hwdata=data[127:96];
	@(posedge hclk);
	haddr 	= addr+16;
	@(posedge hclk);
	hwdata=data[159:128];
	@(posedge hclk);
	haddr 	= addr+20;
	@(posedge hclk);
	hwdata=data[191:160];
	@(posedge hclk);
	haddr 	= addr+24;
	@(posedge hclk);
	hwdata=data[223:192];
	@(posedge hclk);
	haddr 	= addr+28;
	@(posedge hclk);
	hwdata=data[255:224];
	haddr 	= addr+32;
	@(posedge hclk);
	hwdata=data[287:256];
	@(posedge hclk);
	haddr 	= addr+36;
	@(posedge hclk);
	hwdata=data[319:288];
	@(posedge hclk);
	haddr 	= addr+40;
	@(posedge hclk);
	hwdata=data[351:320];
	@(posedge hclk);
	haddr 	= addr+44;
	@(posedge hclk);
	hwdata=data[383:352];
	@(posedge hclk);
	haddr 	= addr+48;
	@(posedge hclk);
	hwdata=data[415:384];
	haddr 	= addr+52;
	@(posedge hclk);
	hwdata=data[447:416];
	haddr 	= addr+56;
	@(posedge hclk);
	hwdata=data[479:448];
	haddr 	= addr+60;
	@(posedge hclk);
	hwdata=data[511:480];
		
endtask	
task read_512bit(input bit [31:0] addr, output logic [511:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b110;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data[31:0] = hrdata;
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[63:32] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+8;
	@(posedge hclk);
	data[95:64] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+12;
	@(posedge hclk);
	data[127:96] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+16;
	@(posedge hclk);
	data[159:128] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+20;
	@(posedge hclk);
	data[191:160] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+24;
	@(posedge hclk);
	data[223:192] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+28;
	@(posedge hclk);
	data[255:224] = hrdata; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	data[287:256] = hrdata;
	haddr 	= addr+32;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[319:288] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+36;
	@(posedge hclk);
	data[351:320] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+40;
	@(posedge hclk);
	data[383:352] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+44;
	@(posedge hclk);
	data[415:384] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+48;
	@(posedge hclk);
	data[447:416] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+52;
	@(posedge hclk);
	data[479:448] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+56;
	@(posedge hclk);
	data[511:480] = hrdata; 								// Get the data from the slave(RAM)
endtask	
/////////////////////////////////////////////////BASIC WRITE TASK WITH AND WITHOUT WAIT STATES for 1024bit/////////////////////////////////////////////
task write_1024bit(input bit[31:0] addr, input logic[511:0] data); //pragma tbx xtf
	
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '1;									// indicates that this is a write operation
	hsize	= 3'b111;	
	htrans	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	hburst 	= '0;									//	signifies that it is a single burst
	hsel    ='1;				
	error   ='0;
	
	@(posedge hclk);
	hwdata=data[31:0]; 
	@(posedge hclk);
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[63:32]; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	haddr 	= addr+8;
	@(posedge hclk);
	hwdata=data[95:64];
	@(posedge hclk);
	haddr 	= addr+12;
	@(posedge hclk);
	hwdata=data[127:96];
	@(posedge hclk);
	haddr 	= addr+16;
	@(posedge hclk);
	hwdata=data[159:128];
	@(posedge hclk);
	haddr 	= addr+20;
	@(posedge hclk);
	hwdata=data[191:160];
	@(posedge hclk);
	haddr 	= addr+24;
	@(posedge hclk);
	hwdata=data[223:192];
	@(posedge hclk);
	haddr 	= addr+28;
	@(posedge hclk);
	hwdata=data[255:224];
	haddr 	= addr+32;
	@(posedge hclk);
	hwdata=data[287:256];
	@(posedge hclk);
	haddr 	= addr+36;
	@(posedge hclk);
	hwdata=data[319:288];
	@(posedge hclk);
	haddr 	= addr+40;
	@(posedge hclk);
	hwdata=data[351:320];
	@(posedge hclk);
	haddr 	= addr+44;
	@(posedge hclk);
	hwdata=data[383:352];
	@(posedge hclk);
	haddr 	= addr+48;
	@(posedge hclk);
	hwdata=data[415:384];
	haddr 	= addr+52;
	@(posedge hclk);
	hwdata=data[447:416];
	haddr 	= addr+56;
	@(posedge hclk);
	hwdata=data[479:448];
	haddr 	= addr+60;
	@(posedge hclk);
	hwdata=data[511:480];
	@(posedge hclk);
	haddr 	= addr+64;									// Get the data from the slave(RAM)
	@(posedge hclk);
	hwdata=data[543:512]; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	haddr 	= addr+68;
	@(posedge hclk);
	hwdata=data[573:544];
	@(posedge hclk);
	haddr 	= addr+72;
	@(posedge hclk);
	hwdata=data[607:574];
	@(posedge hclk);
	haddr 	= addr+76;
	@(posedge hclk);
	hwdata=data[639:608];
	@(posedge hclk);
	haddr 	= addr+80;
	@(posedge hclk);
	hwdata=data[671:640];
	@(posedge hclk);
	haddr 	= addr+84;
	@(posedge hclk);
	hwdata=data[703:672];
	@(posedge hclk);
	haddr 	= addr+88;
	@(posedge hclk);
	hwdata=data[735:704];
	haddr 	= addr+92;
	@(posedge hclk);
	hwdata=data[767:736];
	@(posedge hclk);
	haddr 	= addr+96;
	@(posedge hclk);
	hwdata=data[799:768];
	@(posedge hclk);
	haddr 	= addr+100;
	@(posedge hclk);
	hwdata=data[831:800];
	@(posedge hclk);
	haddr 	= addr+104;
	@(posedge hclk);
	hwdata=data[863:832];
	@(posedge hclk);
	haddr 	= addr+108;
	@(posedge hclk);
	hwdata=data[895:864];
	haddr 	= addr+112;
	@(posedge hclk);
	hwdata=data[927:896];
	@(posedge hclk);
	haddr 	= addr+116;
	@(posedge hclk);
	hwdata=data[959:928];
	@(posedge hclk);
	haddr 	= addr+120;
	@(posedge hclk);
	hwdata=data[991:960];
	@(posedge hclk);
	haddr 	= addr+124;
	@(posedge hclk);
	hwdata=data[1023:992];


		
endtask	
task read_1024bit(input bit [31:0] addr, output logic [511:0] data);
	@(posedge hclk);
	haddr 	= addr;									// Address put on the Address bus
	hwrite 	= '0;									// indicates that this is a read operation
	hsize	= 3'b111;								// define HSIZE as a Parameter and change it in compile time
	hburst	= 3'b000;								// Single burst
	hsel    = '1;
	error   = '0;

	if (hresp)		$display (" ERROR RESPONSE FROM SLAVE TO MASTER \n ");
	while (!hready);	

	//@(posedge hclk);
	@(posedge hclk);
	data[31:0] = hrdata;
	haddr 	= addr+4;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[63:32] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+8;
	@(posedge hclk);
	data[95:64] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+12;
	@(posedge hclk);
	data[127:96] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+16;
	@(posedge hclk);
	data[159:128] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+20;
	@(posedge hclk);
	data[191:160] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+24;
	@(posedge hclk);
	data[223:192] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+28;
	@(posedge hclk);
	data[255:224] = hrdata; 								// Get the data from the slave(RAM)
	@(posedge hclk);
	data[287:256] = hrdata;
	haddr 	= addr+32;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[319:288] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+36;
	@(posedge hclk);
	data[351:320] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+40;
	@(posedge hclk);
	data[383:352] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+44;
	@(posedge hclk);
	data[415:384] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+48;
	@(posedge hclk);
	data[447:416] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+52;
	@(posedge hclk);
	data[479:448] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+56;
	@(posedge hclk);
	data[511:480] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+60;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[543:512] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+64;
	@(posedge hclk);
	data[573:544] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+68;
	@(posedge hclk);
	data[607:574] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+72;
	@(posedge hclk);
	data[639:608] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+76;
	@(posedge hclk);
	data[671:640] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+80;
	@(posedge hclk);
	data[703:672] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+84;
	@(posedge hclk);
	data[735:704] = hrdata; 	
	haddr 	= addr+88;							// Get the data from the slave(RAM)
	@(posedge hclk);
	data[767:736] = hrdata;
	haddr 	= addr+92;									// Get the data from the slave(RAM)
	@(posedge hclk);
	data[799:768] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+96;
	@(posedge hclk);
	data[831:800] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+100;
	@(posedge hclk);
	data[863:832] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+104;
	@(posedge hclk);
	data[895:864] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+108;
	@(posedge hclk);
	data[927:896] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+112;
	@(posedge hclk);
	data[959:928] = hrdata; 								// Get the data from the slave(RAM)
	haddr 	= addr+116;
	@(posedge hclk);
	data[991:960] = hrdata; 
	haddr 	= addr+120;
	@(posedge hclk);
	data[1023:992] = hrdata; 

endtask	
//task to check reads-writes
task check(logic [31:0] Address, logic [31:0] Data_written, logic [31:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_8bit(logic [31:0] Address, logic [7:0] Data_written, logic [7:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_16bit(logic [31:0] Address, logic [15:0] Data_written, logic [15:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_64bit(logic [31:0] Address, logic [63:0] Data_written, logic [63:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_128bit(logic [31:0] Address, logic [127:0] Data_written, logic [127:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_256bit(logic [31:0] Address, logic [255:0] Data_written, logic [255:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_512bit(logic [31:0] Address, logic [511:0] Data_written, logic [511:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask
task check_1024bit(logic [31:0] Address, logic [1023:0] Data_written, logic [1023:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask

// SYSTEMVERILOG: default task input argument values
endinterface //:ifa
 
