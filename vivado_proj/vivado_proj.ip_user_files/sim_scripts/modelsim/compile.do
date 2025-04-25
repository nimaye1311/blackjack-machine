vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../ipstatic" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../ipstatic" \
"../../../vivado_proj.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../vivado_proj.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \
"../../../../sources/RAM.v" \
"../../../../sources/ROM.v" \
"../../../../sources/VGAController.v" \
"../../../../sources/VGATimingGenerator.v" \
"../../../../sources/alu.v" \
"../../../../sources/counter.v" \
"../../../../sources/dffe_ref.v" \
"../../../../sources/div.v" \
"../../../../sources/divpos_to_neg.v" \
"../../../../sources/eight_bit_adder.v" \
"../../../../sources/is_zero.v" \
"../../../../sources/latch.v" \
"../../../../sources/latch_1bit.v" \
"../../../../sources/latch_5bit.v" \
"../../../../sources/mult.v" \
"../../../../sources/multdiv.v" \
"../../../../sources/multovf.v" \
"../../../../sources/mux_2.v" \
"../../../../sources/mux_2_12bit.v" \
"../../../../sources/mux_32.v" \
"../../../../sources/mux_4.v" \
"../../../../sources/mux_4_12bit.v" \
"../../../../sources/mux_8.v" \
"../../../../sources/mux_8_12bit.v" \
"../../../../sources/processor.v" \
"../../../../sources/reg_64.v" \
"../../../../sources/reg_66.v" \
"../../../../sources/regfile.v" \
"../../../../sources/rng.v" \
"../../../../sources/sll_16bit.v" \
"../../../../sources/sll_1bit.v" \
"../../../../sources/sll_1bit_64b_version.v" \
"../../../../sources/sll_2bit.v" \
"../../../../sources/sll_4bit.v" \
"../../../../sources/sll_8bit.v" \
"../../../../sources/sll_barrel.v" \
"../../../../sources/sra_16bit.v" \
"../../../../sources/sra_1bit.v" \
"../../../../sources/sra_2bit.v" \
"../../../../sources/sra_2bit_66b_version.v" \
"../../../../sources/sra_4bit.v" \
"../../../../sources/sra_8bit.v" \
"../../../../sources/sra_barrel.v" \
"../../../../sources/sx.v" \
"../../../../sources/tff.v" \
"../../../../sources/thirty_two_bit_adder.v" \
"../../../../sources/Wrapper_timing.v" \

vlog -work xil_defaultlib \
"glbl.v"

