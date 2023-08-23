`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
	
	uvm_blocking_get_port #(my_transaction)  port;
	uvm_analysis_port #(my_transaction)  ap;
	
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
	my_transaction tr;
	my_transaction new_tr;
	
	logic [ 3:0]req_i   = 4'b0 ;
	logic [ 3:0]we_i    = 4'b0 ;
	logic [31:0]maddr   = 32'b0;
	logic [31:0]saddr   = 32'b0;
	logic [31:0]mdata_i = 32'b0;
	logic [31:0]sdata_i = 32'b0;
	logic [31:0]mdata_o = 32'b0;
	logic [31:0]m1data_o = 32'h00000001;
	logic [31:0]sdata_o = 32'b0;
	logic [ 5:0]we_o    = 6'b0 ;
	logic hold_flag     = 1'b0 ;
	int data_size;
	super.main_phase(phase);
	while(1) begin
		port.get(tr);
		
		new_tr = new("new_tr");
		data_size = tr.req_i.size;
		new_tr.req_i     = new[data_size];
		new_tr.we_i      = new[data_size];
		new_tr.m0_addr   = new[data_size];
		new_tr.m1_addr   = new[data_size];
		new_tr.m2_addr   = new[data_size];
		new_tr.m3_addr   = new[data_size];
		new_tr.s0_addr   = new[data_size];
		new_tr.s1_addr   = new[data_size];
		new_tr.s2_addr   = new[data_size];
		new_tr.s3_addr   = new[data_size];
		new_tr.s4_addr   = new[data_size];
		new_tr.s5_addr   = new[data_size];
		new_tr.m0_data_i = new[data_size];
		new_tr.m1_data_i = new[data_size];
		new_tr.m2_data_i = new[data_size];
		new_tr.m3_data_i = new[data_size];
		new_tr.s0_data_i = new[data_size];
		new_tr.s1_data_i = new[data_size];
		new_tr.s2_data_i = new[data_size];
		new_tr.s3_data_i = new[data_size];
		new_tr.s4_data_i = new[data_size];
		new_tr.s5_data_i = new[data_size];
		new_tr.m0_data_o = new[data_size];
		new_tr.m1_data_o = new[data_size];
		new_tr.m2_data_o = new[data_size];
		new_tr.m3_data_o = new[data_size];
		new_tr.s0_data_o = new[data_size];
		new_tr.s1_data_o = new[data_size];
		new_tr.s2_data_o = new[data_size];
		new_tr.s3_data_o = new[data_size];
		new_tr.s4_data_o = new[data_size];
		new_tr.s5_data_o = new[data_size];
		new_tr.we_o      = new[data_size];
		new_tr.hold_flag = new[data_size];
		for(int i=0;i<data_size;i++)begin
			req_i = tr.req_i[i];
			if(req_i[3]) begin
				hold_flag = 1'b1;
				maddr = tr.m3_addr[i];
				saddr = {{4'h0}, {maddr[27:0]}};
				mdata_i = tr.m3_data_i[i];
				case(maddr[31:28])
					4'b0000: begin
						new_tr.s0_addr[i] = saddr;
						sdata_i = tr.s0_data_i[i];
						sdata_o = mdata_i;
						new_tr.s0_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
					4'b0001: begin
						new_tr.s1_addr[i] = saddr;
						sdata_i = tr.s1_data_i[i];
						sdata_o = mdata_i;
						new_tr.s1_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
					4'b0010: begin
						new_tr.s2_addr[i] = saddr;
						sdata_i = tr.s2_data_i[i];
						sdata_o = mdata_i;
						new_tr.s2_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
					4'b0011: begin
						new_tr.s3_addr[i] = saddr;
						sdata_i = tr.s3_data_i[i];
						sdata_o = mdata_i;
						new_tr.s2_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
					4'b0100: begin
						new_tr.s4_addr[i] = saddr;
						sdata_i = tr.s4_data_i[i];
						sdata_o = mdata_i;
						new_tr.s4_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
					4'b0101: begin
						new_tr.s5_addr[i] = saddr;
						sdata_i = tr.s5_data_i[i];
						sdata_o = mdata_i;
						new_tr.s5_data_o[i] = sdata_o;
						mdata_o = sdata_i;
					end
				endcase
				new_tr.m3_data_o[i] = mdata_o;
			end	else if (req_i[0]) begin
				hold_flag = 1'b1;
				maddr = tr.m0_addr[i];
			    saddr = {{4'h0}, {maddr[27:0]}};
			    mdata_i = tr.m0_data_i[i];
			    case(maddr[31:28])
			    	4'b0000: begin
			    		new_tr.s0_addr[i] = saddr;
						sdata_i = tr.s0_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s0_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0001: begin
			    		new_tr.s1_addr[i] = saddr;
						sdata_i = tr.s1_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s1_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0010: begin
			    		new_tr.s2_addr[i] = saddr;
						sdata_i = tr.s2_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s2_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0011: begin
			    		new_tr.s3_addr[i] = saddr;
						sdata_i = tr.s3_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s3_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0100: begin
			    		new_tr.s4_addr[i] = saddr;
						sdata_i = tr.s4_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s4_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0101: begin
			    		new_tr.s5_addr[i] = saddr;
						sdata_i = tr.s5_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s5_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    endcase
				new_tr.m0_data_o[i] = mdata_o;
			end	else if (req_i[2]) begin
				hold_flag = 1'b1;
				maddr = tr.m2_addr[i];
			    saddr = {{4'h0}, {maddr[27:0]}};
			    mdata_i = tr.m2_data_i[i];
			    case(maddr[31:28])
			    	4'b0000: begin
			    		new_tr.s0_addr[i] = saddr;
						sdata_i = tr.s0_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s0_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0001: begin
			    		new_tr.s1_addr[i] = saddr;
						sdata_i = tr.s1_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s1_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0010: begin
			    		new_tr.s2_addr[i] = saddr;
						sdata_i = tr.s2_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s2_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0011: begin
			    		new_tr.s3_addr[i] = saddr;
						sdata_i = tr.s3_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s3_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0100: begin
			    		new_tr.s4_addr[i] = saddr;
						sdata_i = tr.s4_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s4_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    	4'b0101: begin
			    		new_tr.s5_addr[i] = saddr;
						sdata_i = tr.s5_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s5_data_o[i] = sdata_o;
			    		mdata_o = sdata_i;
			    	end
			    endcase
				new_tr.m2_data_o[i] = mdata_o;
			end	else if (req_i[1]) begin
				hold_flag = 1'b0;
				maddr = tr.m1_addr[i];
			    saddr = {{4'h0}, {maddr[27:0]}};
			    mdata_i = tr.m1_data_i[i];
			    case(maddr[31:28])
			    	4'b0000: begin
			    		new_tr.s0_addr[i] = saddr;
						sdata_i = tr.s0_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s0_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    	4'b0001: begin
			    		new_tr.s1_addr[i] = saddr;
						sdata_i = tr.s1_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s1_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    	4'b0010: begin
			    		new_tr.s2_addr[i] = saddr;
						sdata_i = tr.s2_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s2_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    	4'b0011: begin
			    		new_tr.s3_addr[i] = saddr;
						sdata_i = tr.s3_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s3_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    	4'b0100: begin
			    		new_tr.s4_addr[i] = saddr;
						sdata_i = tr.s4_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s4_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    	4'b0101: begin
			    		new_tr.s5_addr[i] = saddr;
						sdata_i = tr.s5_data_i[i];
			    		sdata_o = mdata_i;
						new_tr.s5_data_o[i] = sdata_o;
			    		m1data_o = sdata_i;
			    	end
			    endcase
				new_tr.m1_data_o[i] = m1data_o;
				
			end
			new_tr.hold_flag[i] = hold_flag;
		end
		`uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
		//new_tr.print();
		ap.write(new_tr);
		`uvm_info("my_model", "model has send a pakage", UVM_LOW)
	end
endtask
`endif
