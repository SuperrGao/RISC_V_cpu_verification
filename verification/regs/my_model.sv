`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
	
	uvm_blocking_get_port #(my_transaction)  port;
	uvm_analysis_port     #(my_transaction)    ap;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern virtual  task main_phase(uvm_phase phase);
	
	`uvm_component_utils(my_model)
endclass 

function my_model::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction 

function void my_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	port = new("port", this);
	ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
	my_transaction       tr;
	my_transaction   new_tr;
	
	logic            we =  1'b0;
	logic [ 4:0]  waddr =  5'b0;
	logic [31:0]  wdata = 32'b0;
	logic           jwe =  1'b0;
	logic [ 4:0]  jaddr =  5'b0;
	logic [31:0] jwdata = 32'b0;
	logic [31:0] jrdata = 32'b0;
	logic [ 4:0]  addr1 =  5'b0;
	logic [31:0]  data1 = 32'b0;
	logic [ 4:0]  addr2 =  5'b0;
	logic [31:0]  data2 = 32'b0;
	
	logic [31:0]  regs   [0:31];
	
	int data_size;
	super.main_phase(phase);
	while(1) begin
		port.get(tr);
		new_tr        = new("new_tr");
		data_size     = tr.we.size;
		new_tr.data1  = new[data_size];
		new_tr.data2  = new[data_size];
		new_tr.jrdata = new[data_size];
		
		for (int i=0;i<data_size;i++) begin   //写寄存器，ex优先
			
			fork
			begin
				if ((we == 1'b1) && (waddr != 5'b0)) begin
					regs[waddr] = wdata;
				end else if ((jwe == 1'b1) && (jaddr != 5'b0)) begin
					regs[jaddr] = jwdata;
				end
			end
			join
			
			we     = tr.we    [i];
			jwe    = tr.jwe   [i];
			waddr  = tr.waddr [i];
			wdata  = tr.wdata [i];
			jaddr  = tr.jaddr [i];
			jwdata = tr.jwdata[i];
			addr1  = tr.addr1 [i];
			addr2  = tr.addr2 [i];
			
			fork
			begin
				if (addr1 == 5'b0) begin
					data1 = 32'b0;
				end else if (addr1 == waddr && we == `WriteEnable) begin
					data1 = wdata;
				end else begin
					data1 = regs[addr1];
				end
			end
			begin
				if (addr2 == 5'b0) begin
					data2 = 32'b0;
				end else if (addr2 == waddr && we == `WriteEnable) begin
					data2 = wdata;
				end else begin
					data2 = regs[addr2];
				end
			end
			begin
				if (jaddr == 5'b0) begin
					jrdata = 32'b0;
				end else begin
					jrdata = regs[jaddr];
				end
			end
				
			join
			
			new_tr.jrdata[i] = jrdata;
			new_tr.data1 [i] = data1 ;
			new_tr.data2 [i] = data2 ;
			
			
		end
			
			
			
			
		/*new_tr.we     = tr.we    ;
		new_tr.waddr  = tr.waddr ;
		new_tr.wdata  = tr.wdata ;
		new_tr.jwe    = tr.jwe   ;
		new_tr.jaddr  = tr.jaddr ;
		new_tr.jwdata = tr.jwdata;
		new_tr.jrdata = tr.jrdata;
		new_tr.addr1  = tr.addr1 ;
		new_tr.data1  = tr.data1 ;
		new_tr.addr2  = tr.addr2 ;
		new_tr.data2  = tr.data2 ;
		new_tr.jrdata = tr.jrdata;
		new_tr.data1  = tr.data1 ;
		new_tr.data2  = tr.data2 ;*/
		
		`uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
		//new_tr.print();
		ap.write(new_tr);
		`uvm_info("my_model", "model has send a pakage", UVM_LOW)
		
		
	end
endtask
`endif
