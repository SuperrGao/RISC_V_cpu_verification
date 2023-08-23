`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst_n);

	logic [ 3:0]  req_i;
	logic [ 3:0]   we_i;
	logic [319:0]   addr;
	logic [319:0] data_i;
	logic [319:0] data_o;
	logic [ 5:0]   we_o;
	logic     hold_flag;
	
	logic  ss;
	logic flag;
endinterface

`endif
