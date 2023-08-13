`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);
	
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
	vif.we     <= 1'b0;
	vif.waddr  <= 5'b0;
	vif.wdata  <= 32'b0;
	vif.jwe    <= 1'b0;
	vif.jaddr  <= 5'b0;
	vif.jwdata <= 32'b0;
	vif.jrdata <= 32'b0;
	vif.addr1  <= 5'b0;
	vif.data1  <= 32'b0;
	vif.addr2  <= 5'b0;
	vif.data2  <= 32'b0;
	while(!vif.rst_n)
	@(posedge vif.clk);
	/*while(1) begin
		seq_item_port.get_next_item(req);
		`uvm_info("my_driver", "get a transaction", UVM_LOW);
		drive_one_pkt(req);
		seq_item_port.item_done();
		`uvm_info("my_driver", "done a transaction", UVM_LOW);
		end*/
	while(1) begin
		//seq_item_port.get_next_item(req);//向sequencer阻塞申请新的transaction 还可以使用try_next_item 需要判断是否有内容
		seq_item_port.try_next_item(req);
		if(req==null)
			#2;//@(posedge vif.clk or negedge vif.clk);
		else begin
			`uvm_info("my_driver", "get a transaction", UVM_LOW);
			req.print();
			drive_one_pkt(req);
			seq_item_port.item_done();//通知sequencer已经完成驱动，sequencer会删除上一个transaction  {握手机制} sequence 结束uvm_do
			`uvm_info("my_driver", "done a transaction", UVM_LOW);
		end
	end
	
endtask	

task my_driver::drive_one_pkt(my_transaction tr);
	logic              we[];
	logic[4:0]      waddr[];
	logic[31:0]     wdata[];
	logic             jwe[];
	logic[4:0]      jaddr[];
	logic[31:0]    jwdata[];
	logic[31:0]    jrdata[];
	logic[4:0]      addr1[];
	logic[31:0]     data1[];
	logic[4:0]      addr2[];
	logic[31:0]     data2[];
	int           data_size;
	logic[31:0]           r;
	
	
	data_size = tr.we.size; 
	we        = new[data_size];
	waddr     = new[data_size];
	wdata     = new[data_size];
	jwe       = new[data_size];
	jaddr     = new[data_size];
	jwdata    = new[data_size];
	//jrdata    = new[data_size];
	addr1     = new[data_size];
	//data1     = new[data_size];
	addr2     = new[data_size];
	//data2     = new[data_size];
	
	
	we        = tr.we;
	waddr     = tr.waddr;
	wdata     = tr.wdata;
	jwe       = tr.jwe;
	jaddr     = tr.jaddr;
	jwdata    = tr.jwdata;
	//jrdata    = tr.jrdata;
	addr1     = tr.addr1;
	//data1     = tr.data1;
	addr2     = tr.addr2;
	//data2     = tr.data2;
	
	
	`uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
	repeat(1) @(posedge vif.clk);
	for ( int i = 0; i < data_size; i++ ) begin
		@(posedge vif.clk);
		vif.flag   <= 1'b1;
		vif.we     <= we[i];
		vif.waddr  <= waddr[i];
		vif.wdata  <= wdata[i];
		vif.jwe    <= jwe[i];
		vif.jaddr  <= jaddr[i];
		vif.jwdata <= jwdata[i];
		//vif.jrdata <= jrdata[i];
		vif.addr1  <= addr1[i];
		//vif.data1  <= data1[i];
		vif.addr2  <= addr2[i];
		//vif.data2  <= data2[i];
		r= {$random} % 100;
		vif.ss <=r[0];
		//cov.sample(vif);
	end
	@(posedge vif.clk);
	vif.flag <= 1'b0;
	`uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
