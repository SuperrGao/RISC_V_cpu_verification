# RISC_V_cpu_verification
```
项目结构RISC_V_cpu_verification
	    │
            ├─design
            │  ├─core
            │  ├─debug
            │  ├─perips
            │  ├─soc
            │  └─utils
            ├─verification
	    │  ├─pc_reg
	    │  ├─regs
	    │  ├─core
	    │  ├─random inst
	    │  └─tinycpu
	    └─README
```

## Project_rv: tiny_risc_v_cpu by [liangkangnan](https://gitee.com/liangkangnan/tinyriscv)

### 分析cpu设计文档
设计需求：三级流水线，即取指，译码，执行，支持RV32IM指令集等  rv内容参见 [rv中文手册](http://riscvbook.com/chinese/RISC-V-Reader-Chinese-v2p1.pdf)
```
          32bits RV32I基础整数指令集(47条) 扩展硬件乘法器：(R) : mul mulh mulhsu mulhu div divu rem remu
          R: func-7      rs2-5 rs1-5 func-3  rd-5         opcode-7  寄存器-寄存器操作   add sub sll slt sltu xor srl sra or and 
          I: imm-12            rs1-5 func-3  rd-5         opcode-7  短立即数计算和访存load  lb lh lw lbu lhu addi slti sltiu xori ori andi fence fence.i ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
          S: imm-7       rs2-5 rs1-5 func-3  imm-5        opcode-7  访存store           sb sh sw 
          B: imm-1 imm-6 rs2-5 rs1-5 func-3  imm-4 imm-1  opcode-7  条件跳转            beq bne blt bge bltu bgeu
          U: imm-20                          rd-5         opcode-7  长立即数            lui auipc
          J: imm-1 imm-10 imm-1 imm-8        rd-5         opcode-7  无条件跳转          jal jalr
```
tinyriscv.v 结构分析

```
// tinyriscv处理器核顶层模块
module tinyriscv(
    input wire clk,
    input wire rst,
    output wire[`MemAddrBus] rib_ex_addr_o,    // 读、写外设的地址
    input wire[`MemBus] rib_ex_data_i,         // 从外设读取的数据
    output wire[`MemBus] rib_ex_data_o,        // 写入外设的数据
    output wire rib_ex_req_o,                  // 访问外设请求
    output wire rib_ex_we_o,                   // 写外设标志
    output wire[`MemAddrBus] rib_pc_addr_o,    // 取指地址
    input wire[`MemBus] rib_pc_data_i,         // 取到的指令内容
    input wire[`RegAddrBus] jtag_reg_addr_i,   // jtag模块读、写寄存器的地址
    input wire[`RegBus] jtag_reg_data_i,       // jtag模块写寄存器数据
    input wire jtag_reg_we_i,                  // jtag模块写寄存器标志
    output wire[`RegBus] jtag_reg_data_o,      // jtag模块读取到的寄存器数据
    input wire rib_hold_flag_i,                // 总线暂停标志
    input wire jtag_halt_flag_i,               // jtag暂停标志
    input wire jtag_reset_flag_i,              // jtag复位PC标志
    input wire[`INT_BUS] int_i                 // 中断信号
    );


    // pc寄存器: 重置->`CpuResetAddr | jump: pc-> jump_addr_i | hold: pc->pc | else : pc + 4
    pc_reg u_pc_reg(.clk(clk),.rst(rst),.jtag_reset_flag_i(jtag_reset_flag_i),.pc_o(pc_pc_o),.hold_flag_i(ctrl_hold_flag_o),.jump_flag_i(ctrl_jump_flag_o),.jump_addr_i(ctrl_jump_addr_o));

    // 控制模块: 发出跳转、暂停流水线信号 优先级：jump | exhold | clinthold 暂停流水线 -> ribhold暂停pc -> jtag 暂停流水线
    ctrl u_ctrl(.rst(rst),.jump_flag_i(ex_jump_flag_o),.jump_addr_i(ex_jump_addr_o),.hold_flag_ex_i(ex_hold_flag_o),.hold_flag_rib_i(rib_hold_flag_i),.hold_flag_o(ctrl_hold_flag_o),.hold_flag_clint_i(clint_hold_flag_o),.jump_flag_o(ctrl_jump_flag_o),.jump_addr_o(ctrl_jump_addr_o),.jtag_halt_flag_i(jtag_halt_flag_i));

    // 通用r1r2寄存器读写操作: 原子写r1,r2  并行读r1,r2 优先级 ex -> jtag
    regs u_regs(.clk(clk),.rst(rst),.we_i(ex_reg_we_o),.waddr_i(ex_reg_waddr_o),.wdata_i(ex_reg_wdata_o),.raddr1_i(id_reg1_raddr_o),.rdata1_o(regs_rdata1_o),.raddr2_i(id_reg2_raddr_o),.rdata2_o(regs_rdata2_o),.jtag_we_i(jtag_reg_we_i),.jtag_addr_i(jtag_reg_addr_i),.jtag_data_i(jtag_reg_data_i),.jtag_data_o(jtag_reg_data_o)
);

    // 状态控制寄存器：读写 优先级 ex -> clint 
    csr_reg u_csr_reg(.clk(clk),.rst(rst),.we_i(ex_csr_we_o),.raddr_i(id_csr_raddr_o),.waddr_i(ex_csr_waddr_o),.data_i(ex_csr_wdata_o),.data_o(csr_data_o),.global_int_en_o(csr_global_int_en_o),.clint_we_i(clint_we_o),.clint_raddr_i(clint_raddr_o),.clint_waddr_i(clint_waddr_o),.clint_data_i(clint_data_o),.clint_data_o(csr_clint_data_o),.clint_csr_mtvec(csr_clint_csr_mtvec),.clint_csr_mepc(csr_clint_csr_mepc),.clint_csr_mstatus(csr_clint_csr_mstatus));

    // 传递指令给译码器：包括指令地址和指令内容
    if_id u_if_id(.clk(clk),.rst(rst),.inst_i(rib_pc_data_i),.inst_addr_i(pc_pc_o),.int_flag_i(int_i),.int_flag_o(if_int_flag_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(if_inst_o),.inst_addr_o(if_inst_addr_o)
);

    // 指令解码器：传入指令地址32和内容32 寄存器1&2&csr的数据 根据后七位判断指令类型 输出寄存器操作 除以下特殊指令,均 读写地址置零 写标志置零
    INST_TYPE_I   : 0010011  func3 ：[立即数&rs1加、比较、异或、与、移位]addi slti sltiu xori ori andi slli sri 获取操作数(符号位扩展) 设置读rs1和写rd: o
    INST_TYPE_R_M : 0110011  func7 ：R/M func3 : [rs1&rs2加、比较、异或、与、移位]add_sub sll slt sltu xor sr or and 获取操作数 设置读rs1&2和写rd: o / func3 : [rs1&2乘、高位乘、有无符号乘]mul mulhu mulh mulhsu 获取操作数 设置读rs1&2和写rd：[rs1&2除法、无符号除法、求余、无符号余]div divu rem remu 获取操作数 设置读rs1&2和写rd: o
    INST_TYPE_L   : 0000011  func3 : [字节、半字、字加载offset & rs1]lb lh lw lbu lhu 获取操作数(符号位扩展) 设置读rs1和写rd:o
    INST_TYPE_S   : 0100011  func3 : [存rs2字节、字、半字至内存地址rs1+offset]sb sw sh 获取操作数off rs1 设置读rs1&2:o
    INST_TYPE_B   : 1100011  func3 : [r1r2相等、不等、小于、大于时pc分支offset]beq bne blt bge bltu bgeu 获取操作数rs1&2 跳转操作数pcaddr-off 设置读rs1&2:o 
    INST_JAL      : 1101111  跳转并链接 rd off ；x[rd] = pc+4; pc += sext(offset) 暂存下条指令，并跳转offset  获取操作数pc 4 跳转操作数pc off 写rd 
    INST_JALR     : 1100111  跳转并寄存器链接 t =pc+4; pc=(x[rs1]+sext(offset))&~1; x[rd]=t 暂存下条指令，并跳转offset 获取操作数pc 4 跳转rs1 off 写rd
    INST_LUI      : 0110111  高位立即数加载 x[rd] = sext(immediate[31:12] << 12) 操作数 {inst_i[31:12], 12'b0} 写入rd
    INST_AUIPC    : 0010111  PC加立即数 x[rd] = pc + sext(immediate[31:12] << 12)  操作数 pc {inst_i[31:12], 12'b0} 写入rd
    INST_NOP_OP   : 0000001  空 同默认
    INST_FENCE    : 0001111  同步内存和 I/O  跳转操作数pc 4
    INST_CSR      : 1110011  func3 : [读后写、读后置位(CSRs[csr] | x[rs1])、读后清除控制状态寄存器]csrrw csrrs crsrc 设置读rs1 写rd csr可写: csrrwi csrrsi csrrci 写rd csr可写:o
    id u_id(.rst(rst),.inst_i(if_inst_o),.inst_addr_i(if_inst_addr_o),.reg1_rdata_i(regs_rdata1_o),.reg2_rdata_i(regs_rdata2_o),.ex_jump_flag_i(ex_jump_flag_o),.reg1_raddr_o(id_reg1_raddr_o),.reg2_raddr_o(id_reg2_raddr_o),.inst_o(id_inst_o),.inst_addr_o(id_inst_addr_o),.reg1_rdata_o(id_reg1_rdata_o),.reg2_rdata_o(id_reg2_rdata_o),.reg_we_o(id_reg_we_o),.reg_waddr_o(id_reg_waddr_o),.op1_o(id_op1_o),.op2_o(id_op2_o),.op1_jump_o(id_op1_jump_o),.op2_jump_o(id_op2_jump_o),.csr_rdata_i(csr_data_o),.csr_raddr_o(id_csr_raddr_o),.csr_we_o(id_csr_we_o),.csr_rdata_o(id_csr_rdata_o),.csr_waddr_o(id_csr_waddr_o));

    // 从译码器传参给执行器：pc和内容 通用、csr寄存器写标志、读写地址 四个操作数：计算和跳转 
    id_ex u_id_ex(.clk(clk),.rst(rst),.inst_i(id_inst_o),.inst_addr_i(id_inst_addr_o),.reg_we_i(id_reg_we_o),.reg_waddr_i(id_reg_waddr_o),.reg1_rdata_i(id_reg1_rdata_o),.reg2_rdata_i(id_reg2_rdata_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(ie_inst_o),.inst_addr_o(ie_inst_addr_o),.reg_we_o(ie_reg_we_o),.reg_waddr_o(ie_reg_waddr_o),.reg1_rdata_o(ie_reg1_rdata_o),.reg2_rdata_o(ie_reg2_rdata_o),.op1_i(id_op1_o),.op2_i(id_op2_o),.op1_jump_i(id_op1_jump_o),.op2_jump_i(id_op2_jump_o),.op1_o(ie_op1_o),.op2_o(ie_op2_o),.op1_jump_o(ie_op1_jump_o),.op2_jump_o(ie_op2_jump_o),.csr_we_i(id_csr_we_o),.csr_waddr_i(id_csr_waddr_o),.csr_rdata_i(id_csr_rdata_o),.csr_we_o(ie_csr_we_o),.csr_waddr_o(ie_csr_waddr_o),.csr_rdata_o(ie_csr_rdata_o));

    // 执行！根据指令 与内存 除法器 通用寄存器 csr寄存器 控制器交互
    ex u_ex(.rst(rst),.inst_i(ie_inst_o),.inst_addr_i(ie_inst_addr_o),.reg_we_i(ie_reg_we_o),.reg_waddr_i(ie_reg_waddr_o),.reg1_rdata_i(ie_reg1_rdata_o),.reg2_rdata_i(ie_reg2_rdata_o),.op1_i(ie_op1_o),.op2_i(ie_op2_o),.op1_jump_i(ie_op1_jump_o),.op2_jump_i(ie_op2_jump_o),.mem_rdata_i(rib_ex_data_i),.mem_wdata_o(ex_mem_wdata_o),.mem_raddr_o(ex_mem_raddr_o),.mem_waddr_o(ex_mem_waddr_o),.mem_we_o(ex_mem_we_o).mem_req_o(ex_mem_req_o),.reg_wdata_o(ex_reg_wdata_o),.reg_we_o(ex_reg_we_o),.reg_waddr_o(ex_reg_waddr_o),.hold_flag_o(ex_hold_flag_o),.jump_flag_o(ex_jump_flag_o),.jump_addr_o(ex_jump_addr_o),.int_assert_i(clint_int_assert_o),.int_addr_i(clint_int_addr_o),.div_ready_i(div_ready_o),.div_result_i(div_result_o),.div_busy_i(div_busy_o),.div_reg_waddr_i(div_reg_waddr_o),.div_start_o(ex_div_start_o),.div_dividend_o(ex_div_dividend_o),.div_divisor_o(ex_div_divisor_o),.div_op_o(ex_div_op_o),.div_reg_waddr_o(ex_div_reg_waddr_o),.csr_we_i(ie_csr_we_o),.csr_waddr_i(ie_csr_waddr_o),.csr_rdata_i(ie_csr_rdata_o),.csr_wdata_o(ex_csr_wdata_o),.csr_we_o(ex_csr_we_o),.csr_waddr_o(ex_csr_waddr_o));

    // 除法器
    div u_div(.clk(clk),.rst(rst),.dividend_i(ex_div_dividend_o),.divisor_i(ex_div_divisor_o),.start_i(ex_div_start_o),.op_i(ex_div_op_o),.reg_waddr_i(ex_div_reg_waddr_o),.result_o(div_result_o),.ready_o(div_ready_o),.busy_o(div_busy_o),.reg_waddr_o(div_reg_waddr_o));

    // clint模块例化
    clint u_clint(.clk(clk),.rst(rst),.int_flag_i(if_int_flag_o),.inst_i(id_inst_o),.inst_addr_i(id_inst_addr_o),.jump_flag_i(ex_jump_flag_o),.jump_addr_i(ex_jump_addr_o),.hold_flag_i(ctrl_hold_flag_o),.div_started_i(ex_div_start_o),.data_i(csr_clint_data_o),.csr_mtvec(csr_clint_csr_mtvec),.csr_mepc(csr_clint_csr_mepc),.csr_mstatus(csr_clint_csr_mstatus),.we_o(clint_we_o),.waddr_o(clint_waddr_o),.raddr_o(clint_raddr_o),.data_o(clint_data_o),.hold_flag_o(clint_hold_flag_o),.global_int_en_i(csr_global_int_en_o),.int_addr_o(clint_int_addr_o),.int_assert_o(clint_int_assert_o));

```
tinycpu结构图：![tinyriscv](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/8037f02d-4a37-48d8-bade-8dc52c662e20)

---
tinyriscv_soc_top.v 结构分析



```
// tinyriscv soc顶层模块 - 内核连接外设
    // tinyriscv处理器核模块例化
    tinyriscv u_tinyriscv(.clk(clk),.rst(rst),.rib_ex_addr_o(m0_addr_i),.rib_ex_data_i(m0_data_o),.rib_ex_data_o(m0_data_i),.rib_ex_req_o(m0_req_i),.rib_ex_we_o(m0_we_i),.rib_pc_addr_o(m1_addr_i),.rib_pc_data_i(m1_data_o),.jtag_reg_addr_i(jtag_reg_addr_o),.jtag_reg_data_i(jtag_reg_data_o),.jtag_reg_we_i(jtag_reg_we_o),.jtag_reg_data_o(jtag_reg_data_i),.rib_hold_flag_i(rib_hold_flag_o),.jtag_halt_flag_i(jtag_halt_req_o),.jtag_reset_flag_i(jtag_reset_req_o),.int_i(int_flag));

    // rom模块例化
    rom u_rom(.clk(clk),.rst(rst),.we_i(s0_we_o),.addr_i(s0_addr_o),.data_i(s0_data_o),.data_o(s0_data_i));
    // ram模块例化
    ram u_ram(.clk(clk),.rst(rst),.we_i(s1_we_o),.addr_i(s1_addr_o),.data_i(s1_data_o),.data_o(s1_data_i));
    // timer模块例化
    timer timer_0(.clk(clk),.rst(rst),.data_i(s2_data_o),.addr_i(s2_addr_o),.we_i(s2_we_o),.data_o(s2_data_i),.int_sig_o(timer0_int));
    // uart模块例化
    uart uart_0(.clk(clk),.rst(rst),.we_i(s3_we_o),.addr_i(s3_addr_o),.data_i(s3_data_o),.data_o(s3_data_i),.tx_pin(uart_tx_pin),.rx_pin(uart_rx_pin));
    // io0
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
    assign io_in[0] = gpio[0];
    // io1
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
    assign io_in[1] = gpio[1];
    // gpio模块例化
    gpio gpio_0(.clk(clk),.rst(rst),.we_i(s4_we_o),.addr_i(s4_addr_o),.data_i(s4_data_o),.data_o(s4_data_i),.io_pin_i(io_in),.reg_ctrl(gpio_ctrl),.reg_data(gpio_data)
    );
    // spi模块例化
    spi spi_0(.clk(clk),.rst(rst),.data_i(s5_data_o),.addr_i(s5_addr_o),.we_i(s5_we_o),.data_o(s5_data_i),.spi_mosi(spi_mosi),.spi_miso(spi_miso),.spi_ss(spi_ss),.spi_clk(spi_clk));

    // RISC-V Internal Bus
    rib u_rib(.clk(clk),.rst(rst),

        // master 0 interface
        .m0_addr_i(m0_addr_i),.m0_data_i(m0_data_i),.m0_data_o(m0_data_o),.m0_req_i(m0_req_i),.m0_we_i(m0_we_i),
        // master 1 interface
        .m1_addr_i(m1_addr_i),.m1_data_i(`ZeroWord),.m1_data_o(m1_data_o),.m1_req_i(`RIB_REQ),.m1_we_i(`WriteDisable),
        // master 2 interface
        .m2_addr_i(m2_addr_i),.m2_data_i(m2_data_i),.m2_data_o(m2_data_o),.m2_req_i(m2_req_i),.m2_we_i(m2_we_i),
        // master 3 interface
        .m3_addr_i(m3_addr_i),.m3_data_i(m3_data_i),.m3_data_o(m3_data_o),.m3_req_i(m3_req_i),.m3_we_i(m3_we_i),
        // slave 0 interface
        .s0_addr_o(s0_addr_o),.s0_data_o(s0_data_o),.s0_data_i(s0_data_i),.s0_we_o(s0_we_o),
        // slave 1 interface
        .s1_addr_o(s1_addr_o),.s1_data_o(s1_data_o),.s1_data_i(s1_data_i),.s1_we_o(s1_we_o),
        // slave 2 interface
        .s2_addr_o(s2_addr_o),.s2_data_o(s2_data_o),.s2_data_i(s2_data_i),.s2_we_o(s2_we_o),
        // slave 3 interface
        .s3_addr_o(s3_addr_o),.s3_data_o(s3_data_o),.s3_data_i(s3_data_i),.s3_we_o(s3_we_o),
        // slave 4 interface
        .s4_addr_o(s4_addr_o),.s4_data_o(s4_data_o),.s4_data_i(s4_data_i),.s4_we_o(s4_we_o),
        // slave 5 interface
        .s5_addr_o(s5_addr_o),.s5_data_o(s5_data_o),.s5_data_i(s5_data_i),.s5_we_o(s5_we_o),
        .hold_flag_o(rib_hold_flag_o));
    // 串口下载模块例化
    uart_debug u_uart_debug(.clk(clk),.rst(rst),.debug_en_i(uart_debug_pin),.req_o(m3_req_i),.mem_we_o(m3_we_i),.mem_addr_o(m3_addr_i),.mem_wdata_o(m3_data_i),.mem_rdata_i(m3_data_o));

    // jtag模块例化
    jtag_top #(.DMI_ADDR_BITS(6),.DMI_DATA_BITS(32),.DMI_OP_BITS(2)) u_jtag_top(.clk(clk),.jtag_rst_n(rst),.jtag_pin_TCK(jtag_TCK),.jtag_pin_TMS(jtag_TMS),.jtag_pin_TDI(jtag_TDI),.jtag_pin_TDO(jtag_TDO),.reg_we_o(jtag_reg_we_o),.reg_addr_o(jtag_reg_addr_o),.reg_wdata_o(jtag_reg_data_o),.reg_rdata_i(jtag_reg_data_i),.mem_we_o(m2_we_i),.mem_addr_o(m2_addr_i),.mem_wdata_o(m2_data_i),.mem_rdata_i(m2_data_o),.op_req_o(m2_req_i),.halt_req_o(jtag_halt_req_o),.reset_req_o(jtag_reset_req_o));

```


### 验证部分
编译指令：make com   仿真：./simv -gui   查看覆盖率：make cov   查看波形图：make verdi    
#### core内部模块
##### pc寄存器 
测试1500条指令，验证了暂停，跳转，和pc+4的功能   
结果比较方法：`result = get_actual.data==tmp_tran.data;`    
信号波形图：![pc_reg_wave](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/cf55d5fe-cbb2-4d92-8f45-13bc1af97bdf)

代码覆盖率：![pc_reg_cov1](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/10b8ea46-c27d-42b4-ab57-c8883403ca19)

功能覆盖率：![pc_reg_cov2](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/9fe856f6-c51e-4418-836a-15b4be9b1745)


条件覆盖率为2/3是由于一条|语句未完全判断   
rst，jump，hold，inst addr 均为100%；   

##### regs 通用寄存器
测试了优先级判断，寄存器读写（含零寄存器5'b0），jtag的寄存器读写操作     
结果比较方法：`result = (get_actual.jrdata === tmp_tran.jrdata) && (get_actual.data1 === tmp_tran.data1) && (get_actual.data2 === tmp_tran.data2);//可能包含不定态X，要用算数全等===`    
信号波形图：![regs_wave](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/30369f38-6cd3-43d5-8ed4-2399fce642da)

代码覆盖率：![regs_cov1](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/06035aee-7b02-4b09-9269-658f33c63bff)

功能覆盖率：![regs_cov2](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/10432d23-c375-459a-a32d-af40d3ab8968)

##### 总线
测试了主从设备间数据传输，主设备优先级判断，从设备的选择，设计文档中grant1的输出初始化时为32'b1，结果比较时易出错

结果比较方法：`result =    (get_actual.s0_addr   == tmp_tran.s0_addr)   && (get_actual.s1_addr   == tmp_tran.s1_addr)   &&
		(get_actual.s2_addr   == tmp_tran.s2_addr)   && (get_actual.s3_addr   == tmp_tran.s3_addr)   &&
		(get_actual.s4_addr   == tmp_tran.s4_addr)   && (get_actual.s5_addr   == tmp_tran.s5_addr)   &&
		(get_actual.m0_data_o == tmp_tran.m0_data_o) && (get_actual.m1_data_o == tmp_tran.m1_data_o) &&
		(get_actual.m2_data_o == tmp_tran.m2_data_o) && (get_actual.m3_data_o == tmp_tran.m3_data_o) &&
		(get_actual.s0_data_o == tmp_tran.s0_data_o) && (get_actual.s1_data_o == tmp_tran.s1_data_o) &&
		(get_actual.s2_data_o == tmp_tran.s2_data_o) && (get_actual.s3_data_o == tmp_tran.s3_data_o) &&
		(get_actual.s4_data_o == tmp_tran.s4_data_o) && (get_actual.s5_data_o == tmp_tran.s5_data_o);`
  
  信号波形图：![apb_wave](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/9baaef15-05ba-40a8-82cc-cba2843d40a6)

  代码覆盖率：![apb_cov1](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/d1cc7434-616e-4909-9abf-25826ac07198)

  功能覆盖率：![apb_cov2](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/70c492a0-0f67-4fab-8b93-04e6b92c187f)


##### tiny_cpu
目前只测试指令执行和pc跳转功能 有两种思路：

1.在transaction中直接生成随机指令
会生成大量非法指令，很难达到覆盖率要求，例如使用20000条随机指令，代码覆盖率仅有61%，状态机覆盖率更是不到30%，所以有必要开发一个随机指令合法生成平台    
代码覆盖率：![cov0](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/071c947a-d246-4035-9bb8-5951222556ab)

2.搭建随机指令生成平台
使用instr_gen平台生成可配置的指令流，包括RV32im全部55条指令，可配置各种指令的占比。     
使用指令生成平台控制指令，仅产生1500条指令便可达到很高的覆盖率(各指令权重均为1)，图中clint覆盖率较低是因为未考虑各种中断，而非指令不全
代码覆盖率：![cov1](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/d9c92a67-f6fd-4bd7-ae21-96e5d2b65dad)

功能覆盖率：![cov2](https://github.com/SuperrGao/RISC_V_cpu_verification/assets/138287304/13b91937-51a6-443d-a890-71853f0cffeb)

