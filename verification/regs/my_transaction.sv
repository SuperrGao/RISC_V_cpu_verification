`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

	rand logic            we[];
	rand logic [4:0]   waddr[];
	rand logic [31:0]  wdata[];
	rand logic           jwe[];
	rand logic [4:0]   jaddr[];
	rand logic [31:0] jwdata[];
	rand logic [31:0] jrdata[];
	rand logic [4:0]   addr1[];
	rand logic [31:0]  data1[];
	rand logic [4:0]   addr2[];
	rand logic [31:0]  data2[];
	//rand bit mode;
   
	constraint pdata_cons{
		we    .size >= 0;
		we    .size <= 1500;
		waddr .size == we.size;
		wdata .size == we.size;
		jwe   .size == we.size;
		jaddr .size == we.size;
		jwdata.size == we.size;
		//jrdata.size == we.size;
		addr1 .size == we.size;
		//data1 .size == we.size;
		addr2 .size == we.size;
		//data2 .size == we.size;
	}
	/*constraint wec{
		foreach(we[i]){
			we[i] dist{ 1'b0:= 20, [1'b1:3'b111]:=80};
			
		}
	
	
	}*/
	
	
	`uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
		`uvm_field_array_int(we    , UVM_ALL_ON)
		`uvm_field_array_int(waddr , UVM_ALL_ON)
		`uvm_field_array_int(wdata , UVM_ALL_ON)
		`uvm_field_array_int(jwe   , UVM_ALL_ON)
		`uvm_field_array_int(jaddr , UVM_ALL_ON)
		`uvm_field_array_int(jwdata, UVM_ALL_ON)
		`uvm_field_array_int(jrdata, UVM_ALL_ON)
		`uvm_field_array_int(addr1 , UVM_ALL_ON)
		`uvm_field_array_int(data1 , UVM_ALL_ON)
		`uvm_field_array_int(addr2 , UVM_ALL_ON)
		`uvm_field_array_int(data2 , UVM_ALL_ON)
		//`uvm_field_int(mode, UVM_ALL_ON)
	`uvm_object_utils_end
	
	function new(string name = "my_transaction");
		super.new();
	
	endfunction

endclass
`endif
