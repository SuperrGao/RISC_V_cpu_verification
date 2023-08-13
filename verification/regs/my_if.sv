`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst_n);

	logic              we;
	logic [ 4:0]    waddr;
	logic [31:0]    wdata;
	logic             jwe;    
	logic [ 4:0]    jaddr;
	logic [31:0]   jwdata;
	logic [31:0]   jrdata;
	logic [ 4:0]    addr1;
	logic [31:0]    data1;
	logic [ 4:0]    addr2;
	logic [31:0]    data2;
	logic  ss;
	logic flag;
endinterface

`endif
