`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

	rand bit[ 3:0]  req_i     [];
	rand bit[ 3:0]  we_i      [];
	rand bit[31:0]  m0_addr   [];
	rand bit[31:0]  m1_addr   [];
	rand bit[31:0]  m2_addr   [];
	rand bit[31:0]  m3_addr   [];
	rand bit[31:0]  s0_addr   [];
	rand bit[31:0]  s1_addr   [];
	rand bit[31:0]  s2_addr   [];
	rand bit[31:0]  s3_addr   [];
	rand bit[31:0]  s4_addr   [];
	rand bit[31:0]  s5_addr   [];
	rand bit[31:0]  m0_data_i [];
	rand bit[31:0]  m1_data_i [];
	rand bit[31:0]  m2_data_i [];
	rand bit[31:0]  m3_data_i [];
	rand bit[31:0]  s0_data_i [];
	rand bit[31:0]  s1_data_i [];
	rand bit[31:0]  s2_data_i [];
	rand bit[31:0]  s3_data_i [];
	rand bit[31:0]  s4_data_i [];
	rand bit[31:0]  s5_data_i [];
	rand bit[31:0]  m0_data_o [];
	rand bit[31:0]  m1_data_o [];
	rand bit[31:0]  m2_data_o [];
	rand bit[31:0]  m3_data_o [];
	rand bit[31:0]  s0_data_o [];
	rand bit[31:0]  s1_data_o [];
	rand bit[31:0]  s2_data_o [];
	rand bit[31:0]  s3_data_o [];
	rand bit[31:0]  s4_data_o [];
	rand bit[31:0]  s5_data_o [];	
	rand bit[ 5:0]  we_o      [];
	rand bit        hold_flag [];
	//rand bit mode;
   

	constraint pload_cons{
		req_i    .size >= 1;
		req_i    .size <= 1500;
		m0_addr  .size == req_i.size;
		m1_addr  .size == req_i.size;
		m2_addr  .size == req_i.size;
		m3_addr  .size == req_i.size;
		s0_addr  .size == req_i.size;
		s1_addr  .size == req_i.size;
		s2_addr  .size == req_i.size;
		s3_addr  .size == req_i.size;
		s4_addr  .size == req_i.size;
		s5_addr  .size == req_i.size;
		m0_data_i.size == req_i.size;
		m1_data_i.size == req_i.size;
		m2_data_i.size == req_i.size;
		m3_data_i.size == req_i.size;
		s0_data_i.size == req_i.size;
		s1_data_i.size == req_i.size;
		s2_data_i.size == req_i.size;
		s3_data_i.size == req_i.size;
		s4_data_i.size == req_i.size;
		s5_data_i.size == req_i.size;
		m0_data_o.size == req_i.size;
		m1_data_o.size == req_i.size;
		m2_data_o.size == req_i.size;
		m3_data_o.size == req_i.size;
		s0_data_o.size == req_i.size;
		s1_data_o.size == req_i.size;
		s2_data_o.size == req_i.size;
		s3_data_o.size == req_i.size;
		s4_data_o.size == req_i.size;
		s5_data_o.size == req_i.size;
		we_i     .size == req_i.size;
		we_o     .size == req_i.size;
		hold_flag.size == req_i.size;

	}
	
	constraint m2s_addr_range{
		foreach (m0_addr[i]) begin
			m0_addr[i][31:28] inside {[4'b0000:4'b0101]};
		end
		foreach (m1_addr[i]) begin
			m1_addr[i][31:28] inside {[4'b0000:4'b0101]};
		end
		foreach (m2_addr[i]) begin
			m2_addr[i][31:28] inside {[4'b0000:4'b0101]};
		end
		foreach (m3_addr[i]) begin
			m3_addr[i][31:28] inside {[4'b0000:4'b0101]};
		end
	}
	
	
/*	constraint holdc{
		foreach(hold[i]){
			hold[i] dist{ 3'b000:= 50, [3'b001:3'b111]:=30};
			
			//mode == 1 -> hold[i] == 3'b000;
			//mode == 0 -> hold[i] >=3'b001;
			//mode dist {1:=1,0:=1};
		}
	
	
	}*/
	

	`uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
		`uvm_field_array_int(req_i    , UVM_ALL_ON)
		`uvm_field_array_int(m0_addr  , UVM_ALL_ON)
		`uvm_field_array_int(m1_addr  , UVM_ALL_ON)
		`uvm_field_array_int(m2_addr  , UVM_ALL_ON)
		`uvm_field_array_int(m3_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s0_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s1_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s2_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s3_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s4_addr  , UVM_ALL_ON)
		`uvm_field_array_int(s5_addr  , UVM_ALL_ON)
		`uvm_field_array_int(m0_data_i, UVM_ALL_ON)
		`uvm_field_array_int(m1_data_i, UVM_ALL_ON)
		`uvm_field_array_int(m2_data_i, UVM_ALL_ON)
		`uvm_field_array_int(m3_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s0_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s1_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s2_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s3_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s4_data_i, UVM_ALL_ON)
		`uvm_field_array_int(s5_data_i, UVM_ALL_ON)
		`uvm_field_array_int(m0_data_o, UVM_ALL_ON)
		`uvm_field_array_int(m1_data_o, UVM_ALL_ON)
		`uvm_field_array_int(m2_data_o, UVM_ALL_ON)
		`uvm_field_array_int(m3_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s0_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s1_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s2_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s3_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s4_data_o, UVM_ALL_ON)
		`uvm_field_array_int(s5_data_o, UVM_ALL_ON)
		`uvm_field_array_int(we_i     , UVM_ALL_ON)
		`uvm_field_array_int(we_o     , UVM_ALL_ON)
		`uvm_field_array_int(hold_flag, UVM_ALL_ON)
		//`uvm_field_int(mode, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "my_transaction");
		super.new();
		
	endfunction

endclass
`endif
