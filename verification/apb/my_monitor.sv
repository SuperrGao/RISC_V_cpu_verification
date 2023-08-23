`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
class my_monitor extends uvm_monitor;

	virtual my_if vif;
	
	uvm_analysis_port #(my_transaction)  ap;
	
	`uvm_component_utils(my_monitor)
	function new(string name = "my_monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
			`uvm_fatal("my_monitor", "virtual interface must be set for vif!!!")
		ap = new("ap", this);
	endfunction

	extern task main_phase(uvm_phase phase);
	extern task collect_one_pkt(my_transaction tr);
endclass

task my_monitor::main_phase(uvm_phase phase);
	my_transaction tr;
	while(1) begin
		tr = new("tr");
		collect_one_pkt(tr);
		$display("mon tr");
		tr.print();
		ap.write(tr);
	end
endtask

task my_monitor::collect_one_pkt(my_transaction tr);
	logic[ 3:0] req_i_q[$]    ;
	logic[ 3:0] we_i_q[$]     ;
	logic[31:0] m0_addr_q[$]  ;
	logic[31:0] m1_addr_q[$]  ;
	logic[31:0] m2_addr_q[$]  ;
	logic[31:0] m3_addr_q[$]  ;
	logic[31:0] s0_addr_q[$]  ;
	logic[31:0] s1_addr_q[$]  ;
	logic[31:0] s2_addr_q[$]  ;
	logic[31:0] s3_addr_q[$]  ;
	logic[31:0] s4_addr_q[$]  ;
	logic[31:0] s5_addr_q[$]  ;
	logic[31:0] m0_data_i_q[$];
	logic[31:0] m1_data_i_q[$];
	logic[31:0] m2_data_i_q[$];
	logic[31:0] m3_data_i_q[$];
	logic[31:0] s0_data_i_q[$];
	logic[31:0] s1_data_i_q[$];
	logic[31:0] s2_data_i_q[$];
	logic[31:0] s3_data_i_q[$];
	logic[31:0] s4_data_i_q[$];
	logic[31:0] s5_data_i_q[$];
	logic[31:0] m0_data_o_q[$];
	logic[31:0] m1_data_o_q[$];
	logic[31:0] m2_data_o_q[$];
	logic[31:0] m3_data_o_q[$];
	logic[31:0] s0_data_o_q[$];
	logic[31:0] s1_data_o_q[$];
	logic[31:0] s2_data_o_q[$];
	logic[31:0] s3_data_o_q[$];
	logic[31:0] s4_data_o_q[$];
	logic[31:0] s5_data_o_q[$];
	logic[ 5:0] we_o_q[$]     ;
	logic       hold_flag_q[$];
	
	logic[ 3:0] req_i_array    [];
	logic[ 3:0] we_i_array     [];
	logic[31:0] m0_addr_array  [];
	logic[31:0] m1_addr_array  [];
	logic[31:0] m2_addr_array  [];
	logic[31:0] m3_addr_array  [];
	logic[31:0] s0_addr_array  [];
	logic[31:0] s1_addr_array  [];
	logic[31:0] s2_addr_array  [];
	logic[31:0] s3_addr_array  [];
	logic[31:0] s4_addr_array  [];
	logic[31:0] s5_addr_array  [];
	logic[31:0] m0_data_i_array[];
	logic[31:0] m1_data_i_array[];
	logic[31:0] m2_data_i_array[];
	logic[31:0] m3_data_i_array[];
	logic[31:0] s0_data_i_array[];
	logic[31:0] s1_data_i_array[];
	logic[31:0] s2_data_i_array[];
	logic[31:0] s3_data_i_array[];
	logic[31:0] s4_data_i_array[];
	logic[31:0] s5_data_i_array[];
	logic[31:0] m0_data_o_array[];
	logic[31:0] m1_data_o_array[];
	logic[31:0] m2_data_o_array[];
	logic[31:0] m3_data_o_array[];
	logic[31:0] s0_data_o_array[];
	logic[31:0] s1_data_o_array[];
	logic[31:0] s2_data_o_array[];
	logic[31:0] s3_data_o_array[];
	logic[31:0] s4_data_o_array[];
	logic[31:0] s5_data_o_array[];
	logic[ 5:0] we_o_array     [];
	logic       hold_flag_array[];
	
	int data_size;
	
	while(1) begin
		@(posedge vif.clk);
		if(vif.flag) break;
	end
	`uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
	while(vif.flag) begin
		req_i_q    .push_back(vif.req_i          );
		we_i_q     .push_back(vif.we_i           );
		m0_addr_q  .push_back(vif.addr  [31 :0  ]);
		m1_addr_q  .push_back(vif.addr  [63 :32 ]);
		m2_addr_q  .push_back(vif.addr  [95 :64 ]);
		m3_addr_q  .push_back(vif.addr  [127:96 ]);
		s0_addr_q  .push_back(vif.addr  [159:128]);
		s1_addr_q  .push_back(vif.addr  [191:160]);
		s2_addr_q  .push_back(vif.addr  [223:192]);
		s3_addr_q  .push_back(vif.addr  [255:224]);
		s4_addr_q  .push_back(vif.addr  [287:256]);
		s5_addr_q  .push_back(vif.addr  [319:288]);
		m0_data_i_q.push_back(vif.data_i[31 :0  ]);
		m1_data_i_q.push_back(vif.data_i[63 :32 ]);
		m2_data_i_q.push_back(vif.data_i[95 :64 ]);
		m3_data_i_q.push_back(vif.data_i[127:96 ]);
		s0_data_i_q.push_back(vif.data_i[159:128]);
		s1_data_i_q.push_back(vif.data_i[191:160]);
		s2_data_i_q.push_back(vif.data_i[223:192]);
		s3_data_i_q.push_back(vif.data_i[255:224]);
		s4_data_i_q.push_back(vif.data_i[287:256]);
		s5_data_i_q.push_back(vif.data_i[319:288]);
		m0_data_o_q.push_back(vif.data_o[31 :0  ]);
		m1_data_o_q.push_back(vif.data_o[63 :32 ]);
		m2_data_o_q.push_back(vif.data_o[95 :64 ]);
		m3_data_o_q.push_back(vif.data_o[127:96 ]);
		s0_data_o_q.push_back(vif.data_o[159:128]);
		s1_data_o_q.push_back(vif.data_o[191:160]);
		s2_data_o_q.push_back(vif.data_o[223:192]);
		s3_data_o_q.push_back(vif.data_o[255:224]);
		s4_data_o_q.push_back(vif.data_o[287:256]);
		s5_data_o_q.push_back(vif.data_o[319:288]);
		we_o_q     .push_back(vif.we_o           );
		hold_flag_q.push_back(vif.hold_flag      );
		
		@(posedge vif.clk);
	end
	data_size  = req_i_q.size();

	req_i_array     = new[data_size];
    we_i_array      = new[data_size];
	m0_addr_array   = new[data_size];
	m1_addr_array   = new[data_size];
	m2_addr_array   = new[data_size];
	m3_addr_array   = new[data_size];
	s0_addr_array   = new[data_size];
	s1_addr_array   = new[data_size];
	s2_addr_array   = new[data_size];
	s3_addr_array   = new[data_size];
	s4_addr_array   = new[data_size];
	s5_addr_array   = new[data_size];
	m0_data_i_array = new[data_size];
	m1_data_i_array = new[data_size];
	m2_data_i_array = new[data_size];
	m3_data_i_array = new[data_size];
	s0_data_i_array = new[data_size];
	s1_data_i_array = new[data_size];
	s2_data_i_array = new[data_size];
	s3_data_i_array = new[data_size];
	s4_data_i_array = new[data_size];
	s5_data_i_array = new[data_size];
	m0_data_o_array = new[data_size];
	m1_data_o_array = new[data_size];
	m2_data_o_array = new[data_size];
	m3_data_o_array = new[data_size];
	s0_data_o_array = new[data_size];
	s1_data_o_array = new[data_size];
	s2_data_o_array = new[data_size];
	s3_data_o_array = new[data_size];
	s4_data_o_array = new[data_size];
	s5_data_o_array = new[data_size];
    we_o_array      = new[data_size];
    hold_flag_array = new[data_size];
	
	for ( int i = 0; i < data_size; i++ ) begin
		
		req_i_array     [i] = req_i_q     [i];
		we_i_array      [i] = we_i_q      [i];
		m0_addr_array   [i] = m0_addr_q   [i];
		m1_addr_array   [i] = m1_addr_q   [i];
		m2_addr_array   [i] = m2_addr_q   [i];
		m3_addr_array   [i] = m3_addr_q   [i];
		s0_addr_array   [i] = s0_addr_q   [i];
		s1_addr_array   [i] = s1_addr_q   [i];
		s2_addr_array   [i] = s2_addr_q   [i];
		s3_addr_array   [i] = s3_addr_q   [i];
		s4_addr_array   [i] = s4_addr_q   [i];
		s5_addr_array   [i] = s5_addr_q   [i];
		m0_data_i_array [i] = m0_data_i_q [i];
		m1_data_i_array [i] = m1_data_i_q [i];
		m2_data_i_array [i] = m2_data_i_q [i];
		m3_data_i_array [i] = m3_data_i_q [i];
		s0_data_i_array [i] = s0_data_i_q [i];
		s1_data_i_array [i] = s1_data_i_q [i];
		s2_data_i_array [i] = s2_data_i_q [i];
		s3_data_i_array [i] = s3_data_i_q [i];
		s4_data_i_array [i] = s4_data_i_q [i];
		s5_data_i_array [i] = s5_data_i_q [i];
		m0_data_o_array [i] = m0_data_o_q [i];
		m1_data_o_array [i] = m1_data_o_q [i];
		m2_data_o_array [i] = m2_data_o_q [i];
		m3_data_o_array [i] = m3_data_o_q [i];
		s0_data_o_array [i] = s0_data_o_q [i];
		s1_data_o_array [i] = s1_data_o_q [i];
		s2_data_o_array [i] = s2_data_o_q [i];
		s3_data_o_array [i] = s3_data_o_q [i];
		s4_data_o_array [i] = s4_data_o_q [i];
		s5_data_o_array [i] = s5_data_o_q [i];
		we_o_array      [i] = we_o_q      [i];
		hold_flag_array [i] = hold_flag_q [i];
	end
	
	tr.req_i     = new[data_size];
	tr.we_i      = new[data_size];
	tr.m0_addr   = new[data_size];
	tr.m1_addr   = new[data_size];
	tr.m2_addr   = new[data_size];
	tr.m3_addr   = new[data_size];
	tr.s0_addr   = new[data_size];
	tr.s1_addr   = new[data_size];
	tr.s2_addr   = new[data_size];
	tr.s3_addr   = new[data_size];
	tr.s4_addr   = new[data_size];
	tr.s5_addr   = new[data_size];
	tr.m0_data_i = new[data_size];
	tr.m1_data_i = new[data_size];
	tr.m2_data_i = new[data_size];
	tr.m3_data_i = new[data_size];
	tr.s0_data_i = new[data_size];
	tr.s1_data_i = new[data_size];
	tr.s2_data_i = new[data_size];
	tr.s3_data_i = new[data_size];
	tr.s4_data_i = new[data_size];
	tr.s5_data_i = new[data_size];
	tr.m0_data_o = new[data_size];
	tr.m1_data_o = new[data_size];
	tr.m2_data_o = new[data_size];
	tr.m3_data_o = new[data_size];
	tr.s0_data_o = new[data_size];
	tr.s1_data_o = new[data_size];
	tr.s2_data_o = new[data_size];
	tr.s3_data_o = new[data_size];
	tr.s4_data_o = new[data_size];
	tr.s5_data_o = new[data_size];
	tr.we_o      = new[data_size];
	tr.hold_flag = new[data_size];//da sa, e_type, crc
	tr.req_i     = req_i_array    ;
	tr.we_i      = we_i_array     ;
	tr.m0_addr   = m0_addr_array  ;
	tr.m1_addr   = m1_addr_array  ;
	tr.m2_addr   = m2_addr_array  ;
	tr.m3_addr   = m3_addr_array  ;
	tr.s0_addr   = s0_addr_array  ;
	tr.s1_addr   = s1_addr_array  ;
	tr.s2_addr   = s2_addr_array  ;
	tr.s3_addr   = s3_addr_array  ;
	tr.s4_addr   = s4_addr_array  ;
	tr.s5_addr   = s5_addr_array  ;
	tr.m0_data_i = m0_data_i_array;
	tr.m1_data_i = m1_data_i_array;
	tr.m2_data_i = m2_data_i_array;
	tr.m3_data_i = m3_data_i_array;
	tr.s0_data_i = s0_data_i_array;
	tr.s1_data_i = s1_data_i_array;
	tr.s2_data_i = s2_data_i_array;
	tr.s3_data_i = s3_data_i_array;
	tr.s4_data_i = s4_data_i_array;
	tr.s5_data_i = s5_data_i_array;
	tr.m0_data_o = m0_data_o_array;
	tr.m1_data_o = m1_data_o_array;
	tr.m2_data_o = m2_data_o_array;
	tr.m3_data_o = m3_data_o_array;
	tr.s0_data_o = s0_data_o_array;
	tr.s1_data_o = s1_data_o_array;
	tr.s2_data_o = s2_data_o_array;
	tr.s3_data_o = s3_data_o_array;
	tr.s4_data_o = s4_data_o_array;
	tr.s5_data_o = s5_data_o_array;
	tr.we_o      = we_o_array     ;
	tr.hold_flag = hold_flag_array;
	`uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
