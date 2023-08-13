//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "regs.v"
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_sequence.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"

module top_tb;

reg clk;
reg rst_n;



my_if input_if(clk, rst_n);
my_if output_if(clk, rst_n);



regs  dut(
	.clk(clk),
	.rst(rst_n),
	.we_i(input_if.we),    // 写寄存器标志
	.waddr_i(input_if.waddr),    // 写寄存器地址
	.wdata_i(input_if.wdata),    // 写寄存器数据
	.jtag_we_i(input_if.jwe),    // JTAG写寄存器标志  
	.jtag_addr_i(input_if.jaddr),    // JTAG读、写寄存器地址
	.jtag_data_i(input_if.jwdata),    // JTAG写寄存器数据
	.raddr1_i(input_if.addr1),    // 读寄存器1地址
	.rdata1_o(output_if.data1),    // 读寄存器1数据
	.raddr2_i(input_if.addr2),    // 读寄存器2地址
	.rdata2_o(output_if.data2 ),    // 读寄存器2数据
	.jtag_data_o(output_if.jrdata)     // JTAG读寄存器数据
    );
covergroup cov_counter @(posedge clk);
	
	we : coverpoint input_if.we {
		bins s1   = {1'b0};
		bins s2   = {1'b1};
	}
    waddr : coverpoint input_if.waddr {
		bins all  = {5'b0,5'b11111};
    }
	jaddr : coverpoint input_if.jaddr {
		bins all  = {5'b0,5'b11111};
    }
	addr1 : coverpoint input_if.addr1 {
		bins all  = {5'b0,5'b11111};
    }
	addr2 : coverpoint input_if.addr2 {
		bins all  = {5'b0,5'b11111};
    }
	wdata : coverpoint input_if.wdata {
		bins all  = {32'b0,32'hffff_ffff};
	}
	jwdata : coverpoint input_if.jwdata {
		bins all  = {32'b0,32'hffff_ffff};
	}
	/*data1 : coverpoint input_if.data1 {
		bins all  = {32'b0,32'hffff_ffff};
	}
	data2 : coverpoint input_if.data2 {
		bins all  = {32'b0,32'hffff_ffff};
	}*/
    rst  : coverpoint rst_n{
      bins one ={1};
      bins zero = {0};
    }
  endgroup
cov_counter cov_count = new();


initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end
assign output_if.flag = input_if.flag;//tr 标志位
initial begin
   rst_n = 1'b0;
   #30 rst_n = 1'b1;
end

initial begin
   run_test("my_case1");
   //run_test("my_env");
end

initial begin
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
end

initial begin
   $fsdbDumpfile("top_tb.fsdb");
   $fsdbDumpvars(0);
end


endmodule
