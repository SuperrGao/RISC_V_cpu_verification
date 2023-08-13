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
	logic       we_q[$];
	logic       we_array[];
	logic[4:0 ] waddr_q[$];
	logic[4:0 ] waddr_array[];
	logic[31:0] wdata_q[$];
	logic[31:0] wdata_array[];
	logic       jwe_q[$];
	logic       jwe_array[];
	logic[4:0 ] jaddr_q[$];
	logic[4:0 ] jaddr_array[];
	logic[31:0] jwdata_q[$];
	logic[31:0] jwdata_array[];
	logic[31:0] jrdata_q[$];
	logic[31:0] jrdata_array[];
	logic[4:0 ] addr1_q[$];
	logic[4:0 ] addr1_array[];
	logic[31:0] data1_q[$];
	logic[31:0] data1_array[];
	logic[4:0 ] addr2_q[$];
	logic[4:0 ] addr2_array[];
	logic[31:0] data2_q[$];
	logic[31:0] data2_array[];
	
	int data_size;
	
	while(1) begin
		@(posedge vif.clk);
		if(vif.flag) break;
	end
	`uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
	while(vif.flag) begin
		we_q    .push_back(vif.we);
		waddr_q .push_back(vif.waddr);
		wdata_q .push_back(vif.wdata);
		jwe_q   .push_back(vif.jwe);
		jaddr_q .push_back(vif.jaddr);
		jwdata_q.push_back(vif.jwdata);
		jrdata_q.push_back(vif.jrdata);
		addr1_q .push_back(vif.addr1);
		data1_q .push_back(vif.data1);
		addr2_q .push_back(vif.addr2);
		data2_q .push_back(vif.data2);
		@(posedge vif.clk);
	end
	data_size    = we_q.size();
	we_array     = new[data_size];
	waddr_array  = new[data_size];
	wdata_array  = new[data_size];
	jwe_array    = new[data_size];
	jaddr_array  = new[data_size];
	jwdata_array = new[data_size];
	jrdata_array = new[data_size];
	addr1_array  = new[data_size];
	data1_array  = new[data_size];
	addr2_array  = new[data_size];
	data2_array  = new[data_size];
	for ( int i = 0; i < data_size; i++ ) begin
		we_array[i]     = we_q[i];
		waddr_array[i]  = waddr_q[i];
		wdata_array[i]  = wdata_q[i];
		jwe_array[i]    = jwe_q[i];
		jaddr_array[i]  = jaddr_q[i];
		jwdata_array[i] = jwdata_q[i];
		jrdata_array[i] = jrdata_q[i];
		addr1_array[i]  = addr1_q[i];
		data1_array[i]  = data1_q[i];
		addr2_array[i]  = addr2_q[i];
		data2_array[i]  = data2_q[i];
	end
	tr.we     = new[data_size];
	tr.waddr  = new[data_size];
	tr.wdata  = new[data_size];
	tr.jwe    = new[data_size];
	tr.jaddr  = new[data_size];
	tr.jwdata = new[data_size];
	tr.jrdata = new[data_size];
	tr.addr1  = new[data_size];
	tr.data1  = new[data_size];
	tr.addr2  = new[data_size];
	tr.data2  = new[data_size];
	tr.we     = we_array;
	tr.waddr  = waddr_array;
	tr.wdata  = wdata_array;
	tr.jwe    = jwe_array;
	tr.jaddr  = jaddr_array;
	tr.jwdata = jwdata_array;
	tr.jrdata = jrdata_array;
	tr.addr1  = addr1_array;
	tr.data1  = data1_array;
	tr.addr2  = addr2_array;
	tr.data2  = data2_array;
	`uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
