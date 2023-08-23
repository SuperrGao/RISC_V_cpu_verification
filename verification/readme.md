
# Project_rv: tiny_risc_v_cpu by [liangkangnan](https://gitee.com/liangkangnan/tinyriscv)
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

