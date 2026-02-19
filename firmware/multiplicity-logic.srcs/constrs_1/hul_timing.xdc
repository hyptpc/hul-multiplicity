# Clock definition
#create_clock -name clk_in -period 8 -waveform {0 4} [get_ports PHY_RX_CLK]

# SiTCP
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX11Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX12Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX13Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX14Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX15Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX16Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX17Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX18Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX19Data*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1AData*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1BData*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/BBT_SiTCP_RST/resetReq*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/memRdReq*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/orRdAct*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank0LastWrAddr*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank1LastWrAddr*]
set_false_path -through [get_nets u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/muxEndTgl]

#set_false_path -from [get_nets u_MTX1/reg_fbh*] -to [get_nets u_MTX1/gen_tof[*].gen_ch[*].u_Matrix_Impl/in_fbh]

set_false_path -through [get_ports {LEDOUT[*]}]
set_false_path -through [get_nets {DIP[*]}]
set_false_path -through [get_nets {NIMOUT[*]}]
set_false_path -through [get_nets u_BCT_Inst/rst_from_bus]

#for 1M counter of 400MHz clk
#set_false_path -through [get_nets {u_tPS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/BH2_Pi_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/Beam_TOF_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/Beam_Pi_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/Beam_P_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/Coin1_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/Coin2_PS_Inst/counter_reg[*]}]
#set_false_path -through [get_nets {u_Region3_Inst/For_E03_PS_Inst/counter_reg[*]}]

#set_property PACKAGE_PIN T7 [get_ports {NIMIN[1]}]

create_generated_clock -name clk_trg [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_sys [get_pins u_ClkMan_Sys_Inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_gtx [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name clk_int [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKOUT2]
#create_generated_clock -name clk_clock [get_pins u_ClkMan_Clk_Inst/inst/mmcm_adv_inst/CLKOUT0]
set_clock_groups -name async_trg_sys_gtx_int -asynchronous -group clk_trg -group clk_sys -group clk_gtx -group clk_int
