//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "rib.v"
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



rib dut(.clk(   clk),
        .rst( rst_n),
        .m0_addr_i  (input_if .addr    [ 31:0]),         // 主设备0读、写地址
		.m0_data_i  (input_if .data_i  [ 31:0]),         // 主设备0写数据
		.m0_data_o  (output_if.data_o  [ 31:0]),         // 主设备0读取到的数据
		.m0_req_i   (input_if .req_i   [0]    ),         // 主设备0访问请求标志
		.m0_we_i    (input_if .we_i    [0]    ),         // 主设备0写标志
		.m1_addr_i  (input_if .addr    [63:32]),         // 主设备1读、写地址
		.m1_data_i  (input_if .data_i  [63:32]),         // 主设备1写数据
		.m1_data_o  (output_if.data_o  [63:32]),         // 主设备1读取到的数据
		.m1_req_i   (input_if .req_i   [1]    ),         // 主设备1访问请求标志
		.m1_we_i    (input_if .we_i    [1]    ),         // 主设备1写标志
		.m2_addr_i  (input_if .addr    [95:64]),         // 主设备2读、写地址
		.m2_data_i  (input_if .data_i  [95:64]),         // 主设备2写数据
		.m2_data_o  (output_if.data_o  [95:64]),         // 主设备2读取到的数据
		.m2_req_i   (input_if .req_i   [2]    ),         // 主设备2访问请求标志
		.m2_we_i    (input_if .we_i    [2]    ),         // 主设备2写标志
		.m3_addr_i  (input_if .addr    [127:96]),        // 主设备3读、写地址
		.m3_data_i  (input_if .data_i  [127:96]),        // 主设备3写数据
		.m3_data_o  (output_if.data_o  [127:96]),        // 主设备3读取到的数据
		.m3_req_i   (input_if .req_i   [3]    ),         // 主设备3访问请求标志
		.m3_we_i    (input_if .we_i    [3]    ),         // 主设备3写标志
		.s0_addr_o  (output_if.addr    [159:128]),       // 从设备0读、写地址
		.s0_data_o  (output_if.data_o  [159:128]),       // 从设备0写数据
		.s0_data_i  (input_if .data_i  [159:128]),       // 从设备0读取到的数据
		.s0_we_o    (output_if.we_o    [0]    ),         // 从设备0写标志
		.s1_addr_o  (output_if.addr    [191:160]),       // 从设备1读、写地址
		.s1_data_o  (output_if.data_o  [191:160]),       // 从设备1写数据
		.s1_data_i  (input_if .data_i  [191:160]),       // 从设备1读取到的数据
		.s1_we_o    (output_if.we_o    [1]    ),         // 从设备1写标志
		.s2_addr_o  (output_if.addr    [223:192]),       // 从设备2读、写地址
		.s2_data_o  (output_if.data_o  [223:192]),       // 从设备2写数据
		.s2_data_i  (input_if .data_i  [223:192]),       // 从设备2读取到的数据
		.s2_we_o    (output_if.we_o    [2]    ),         // 从设备2写标志
		.s3_addr_o  (output_if.addr    [255:224]),       // 从设备3读、写地址
		.s3_data_o  (output_if.data_o  [255:224]),       // 从设备3写数据
		.s3_data_i  (input_if .data_i  [255:224]),       // 从设备3读取到的数据
		.s3_we_o    (output_if.we_o    [3]    ),         // 从设备3写标志
		.s4_addr_o  (output_if.addr    [287:256]),       // 从设备4读、写地址
		.s4_data_o  (output_if.data_o  [287:256]),       // 从设备4写数据
		.s4_data_i  (input_if .data_i  [287:256]),       // 从设备4读取到的数据
		.s4_we_o    (output_if.we_o    [4]    ),         // 从设备4写标志
		.s5_addr_o  (output_if.addr    [319:288]),       // 从设备5读、写地址
		.s5_data_o  (output_if.data_o  [319:288]),       // 从设备5写数据
		.s5_data_i  (input_if .data_i  [319:288]),       // 从设备5读取到的数据
		.s5_we_o    (output_if.we_o    [5]    ),         // 从设备5写标志
						  
		.hold_flag_o(output_if.hold_flag)                // 暂停流水线标志   

    );

    
covergroup cov_counter @(posedge clk);
	
	req_i : coverpoint input_if.req_i {
		bins all  = {3'b0,3'b111};
	}
	we_i : coverpoint input_if.we_i {
		bins all  = {3'b0,3'b111};
	}
	addr : coverpoint input_if.addr {
		bins all  = {320'b0,320'h5fff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff};
	}
	data_i : coverpoint input_if.data_i {
		bins all  = {320'b0,320'h5fff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff};
	}
	
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
