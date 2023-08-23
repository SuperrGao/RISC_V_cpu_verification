
`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);//参数化 添加参数选择驱动的transaction类型 则可使用req(获得的参数 此处为my_transaction)

	virtual my_if vif;
	//my_cov cov;
	
	`uvm_component_utils(my_driver)
	function new(string name = "my_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//cov = new();
		if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
			`uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
	endfunction
	
	
	extern task main_phase(uvm_phase phase);
	extern task drive_one_pkt(my_transaction tr);
endclass

task my_driver::main_phase(uvm_phase phase);
	vif.data_i    <= 320'b0;
	vif.req_i     <= 4'b0;
	vif.we_i      <= 4'b0;
	vif.addr      <= 320'b0;
	vif.data_o    <= 320'b0;
	vif.we_o      <= 6'b0;
	vif.hold_flag <= 1'b0;
	
	while(!vif.rst_n)
		@(posedge vif.clk);
	while(1) begin
		//seq_item_port.get_next_item(req);//向sequencer阻塞申请新的transaction 还可以使用try_next_item 需要判断是否有内容
		seq_item_port.try_next_item(req);
		if(req==null)
			#1;//@(posedge vif.clk or negedge vif.clk);
		else begin
			`uvm_info("my_driver", "get a transaction", UVM_LOW);
			drive_one_pkt(req);
			seq_item_port.item_done();//通知sequencer已经完成驱动，sequencer会删除上一个transaction  {握手机制} sequence 结束uvm_do
			`uvm_info("my_driver", "done a transaction", UVM_LOW);
		end
	end
endtask

task my_driver::drive_one_pkt(my_transaction tr);
	logic[ 3:0] req_i_q       [];
	logic[ 3:0] we_i_q        [];
	logic[31:0] m0_addr_q     [];
	logic[31:0] m1_addr_q     [];
	logic[31:0] m2_addr_q     [];
	logic[31:0] m3_addr_q     [];
	logic[31:0] s0_addr_q     [];
	logic[31:0] s1_addr_q     [];
	logic[31:0] s2_addr_q     [];
	logic[31:0] s3_addr_q     [];
	logic[31:0] s4_addr_q     [];
	logic[31:0] s5_addr_q     [];
	logic[31:0] m0_data_i_q   [];
	logic[31:0] m1_data_i_q   [];
	logic[31:0] m2_data_i_q   [];
	logic[31:0] m3_data_i_q   [];
	logic[31:0] s0_data_i_q   [];
	logic[31:0] s1_data_i_q   [];
	logic[31:0] s2_data_i_q   [];
	logic[31:0] s3_data_i_q   [];
	logic[31:0] s4_data_i_q   [];
	logic[31:0] s5_data_i_q   [];
	logic[31:0] m0_data_o_q   [];
	logic[31:0] m1_data_o_q   [];
	logic[31:0] m2_data_o_q   [];
	logic[31:0] m3_data_o_q   [];
	logic[31:0] s0_data_o_q   [];
	logic[31:0] s1_data_o_q   [];
	logic[31:0] s2_data_o_q   [];
	logic[31:0] s3_data_o_q   [];
	logic[31:0] s4_data_o_q   [];
	logic[31:0] s5_data_o_q   [];
	logic[ 5:0] we_o_q        [];
	logic       hold_flag_q   [];
	
	int  data_size;
	logic[31:0]   r;
	
	data_size = tr.req_i.size; 
	
	req_i_q     = new[data_size];
	we_i_q      = new[data_size];
	m0_addr_q   = new[data_size];
	m1_addr_q   = new[data_size];
	m2_addr_q   = new[data_size];
	m3_addr_q   = new[data_size];
	s0_addr_q   = new[data_size];
	s1_addr_q   = new[data_size];
	s2_addr_q   = new[data_size];
	s3_addr_q   = new[data_size];
	s4_addr_q   = new[data_size];
	s5_addr_q   = new[data_size];
	m0_data_i_q = new[data_size];
	m1_data_i_q = new[data_size];
	m2_data_i_q = new[data_size];
	m3_data_i_q = new[data_size];
	s0_data_i_q = new[data_size];
	s1_data_i_q = new[data_size];
	s2_data_i_q = new[data_size];
	s3_data_i_q = new[data_size];
	s4_data_i_q = new[data_size];
	s5_data_i_q = new[data_size];
	m0_data_o_q = new[data_size];
	m1_data_o_q = new[data_size];
	m2_data_o_q = new[data_size];
	m3_data_o_q = new[data_size];
	s0_data_o_q = new[data_size];
	s1_data_o_q = new[data_size];
	s2_data_o_q = new[data_size];
	s3_data_o_q = new[data_size];
	s4_data_o_q = new[data_size];
	s5_data_o_q = new[data_size];
	we_o_q      = new[data_size];
	hold_flag_q = new[data_size];
	
	req_i_q     = tr.req_i     ;
	we_i_q      = tr.we_i      ;
	m0_addr_q   = tr.m0_addr   ;
	m1_addr_q   = tr.m1_addr   ;
	m2_addr_q   = tr.m2_addr   ;
	m3_addr_q   = tr.m3_addr   ;
	s0_addr_q   = tr.s0_addr   ;
	s1_addr_q   = tr.s1_addr   ;
	s2_addr_q   = tr.s2_addr   ;
	s3_addr_q   = tr.s3_addr   ;
	s4_addr_q   = tr.s4_addr   ;
	s5_addr_q   = tr.s5_addr   ;
	m0_data_i_q = tr.m0_data_i ;
	m1_data_i_q = tr.m1_data_i ;
	m2_data_i_q = tr.m2_data_i ;
	m3_data_i_q = tr.m3_data_i ;
	s0_data_i_q = tr.s0_data_i ;
	s1_data_i_q = tr.s1_data_i ;
	s2_data_i_q = tr.s2_data_i ;
	s3_data_i_q = tr.s3_data_i ;
	s4_data_i_q = tr.s4_data_i ;
	s5_data_i_q = tr.s5_data_i ;
	m0_data_o_q = tr.m0_data_o ;
	m1_data_o_q = tr.m1_data_o ;
	m2_data_o_q = tr.m2_data_o ;
	m3_data_o_q = tr.m3_data_o ;
	s0_data_o_q = tr.s0_data_o ;
	s1_data_o_q = tr.s1_data_o ;
	s2_data_o_q = tr.s2_data_o ;
	s3_data_o_q = tr.s3_data_o ;
	s4_data_o_q = tr.s4_data_o ;
	s5_data_o_q = tr.s5_data_o ;
	we_o_q      = tr.we_o      ;
	hold_flag_q = tr.hold_flag ;
	
	`uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
	repeat(1) @(posedge vif.clk);
	for ( int i = 0; i < data_size; i++ ) begin
		@(posedge vif.clk);
		vif.flag      <= 1'b1;
		vif.req_i     <= req_i_q     [i];
		vif.we_i      <= we_i_q      [i];
		vif.addr  [31 :0  ] <= m0_addr_q   [i];
		vif.addr  [63 :32 ] <= m1_addr_q   [i];
		vif.addr  [95 :64 ] <= m2_addr_q   [i];
		vif.addr  [127:96 ] <= m3_addr_q   [i];
		vif.addr  [159:128] <= s0_addr_q   [i];
		vif.addr  [191:160] <= s1_addr_q   [i];
		vif.addr  [223:192] <= s2_addr_q   [i];
		vif.addr  [255:224] <= s3_addr_q   [i];
		vif.addr  [287:256] <= s4_addr_q   [i];
		vif.addr  [319:288] <= s5_addr_q   [i];
		vif.data_i[31 :0  ] <= m0_data_i_q [i];
		vif.data_i[63 :32 ] <= m1_data_i_q [i];
		vif.data_i[95 :64 ] <= m2_data_i_q [i];
		vif.data_i[127:96 ] <= m3_data_i_q [i];
		vif.data_i[159:128] <= s0_data_i_q [i];
		vif.data_i[191:160] <= s1_data_i_q [i];
		vif.data_i[223:192] <= s2_data_i_q [i];
		vif.data_i[255:224] <= s3_data_i_q [i];
		vif.data_i[287:256] <= s4_data_i_q [i];
		vif.data_i[319:288] <= s5_data_i_q [i];
		vif.data_o[31 :0  ] <= m0_data_o_q [i];
		vif.data_o[63 :32 ] <= m1_data_o_q [i];
		vif.data_o[95 :64 ] <= m2_data_o_q [i];
		vif.data_o[127:96 ] <= m3_data_o_q [i];
		vif.data_o[159:128] <= s0_data_o_q [i];
		vif.data_o[191:160] <= s1_data_o_q [i];
		vif.data_o[223:192] <= s2_data_o_q [i];
		vif.data_o[255:224] <= s3_data_o_q [i];
		vif.data_o[287:256] <= s4_data_o_q [i];
		vif.data_o[319:288] <= s5_data_o_q [i];
		vif.we_o      <= we_o_q      [i];
		vif.hold_flag <= hold_flag_q [i];
		r= {$random} % 100;
		vif.ss <=r[0];
		//cov.sample(vif);
	end
	@(posedge vif.clk);
	vif.flag <= 1'b0;
	`uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
