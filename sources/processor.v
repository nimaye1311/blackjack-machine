/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    /* Wires Defined */

    wire [1:0] MUX_OpA_select, MUX_OpB_select;
    wire WM_bypass, stall;
    wire [31:0] pc_input, pc_current, pc_plus_one;
    wire is_multdiv_D;
    wire multdiv_ready, multdiv_active;
    wire flush_pipeline;
    wire is_jii_type_D;
    wire is_bex_D;
    wire [31:0] FD_insn, FD_pc;
    wire is_sw_or_branch;
    wire [31:0] DX_insn, DX_pc, DX_dataA, DX_dataB, DX_rt_data;
    wire [31:0] sign_ext_imm, jump_target_pc, branch_target_pc;
    wire is_i_type, is_j_type, is_jii_type_X, suppress_jump;
    wire is_r_type, is_blt_or_bne, branch_taken;
    wire [31:0] alu_result, XM_insn_in, alu_result_in;
    wire overflow, cond_NE, cond_LT;
    wire [4:0] alu_op;
    wire is_multdiv_X, is_mult, is_bex_X;
    wire [31:0] multdiv_output, multdiv_output_latched;
    wire [4:0] multdiv_dest_reg;
    wire multdiv_exception;
    wire [31:0] aluA, aluB, mdA, mdB;
    wire mult_complete;
    wire [31:0] mem_data_out;
    wire [21:0] ovf_type_mult, ovf_type_alu, final_ovf_type;
    wire [31:0] XM_insn, XM_alu_out, XM_rt_data, XM_pc;
    wire [31:0] MW_insn, MW_write_data, MW_rt_data, MW_pc;
    wire is_write_normal, is_write_rstatus, is_write_jar, is_write_setx;
    wire [31:0] setx_value, rstatus_value;
    wire FD_nop, DX_nop, XM_nop, MW_nop;
    wire FD_store, DX_store, XM_store, MW_store;
    wire B_uses_rt;
    wire XM_not_0, MW_not_0;
    wire JR_MX, JR_WX;
    wire [31:0] JR_target_PC;
    wire WX_bypass, bex_bypass;
    wire dx_blt_bne, fd_blt_bne, blt_bne_mx_bypass_rd, blt_bne_mx_bypass_rs, blt_bne_wx_bypass_rs, blt_bne_wx_bypass_rd;
    wire XM_modifies_regfile;
    wire MW_modifies_regfile;

    /* F stage */

    assign flush_pipeline = (is_j_type || is_jii_type_X || branch_taken) & ~suppress_jump;

    assign pc_current = flush_pipeline ? jump_target_pc : pc_plus_one;
    assign pc_input = (multdiv_active || stall) ? address_imem : (reset ? 32'b0 : pc_current);
    
    latch pc_latch(.q(address_imem), .d(pc_input), .clk(clock), .en(1'b1), .clr(reset));

    thirty_two_bit_adder pc_incrementer(
        .A(address_imem),
        .B(32'b1),
        .sum(pc_plus_one),
        .sub(1'b0)
    );

    /* F/D latch */

    latch fd_insn(.q(FD_insn), .d(stall ? FD_insn : ((multdiv_active || flush_pipeline) ? 32'b0 : q_imem)), .clk(clock), .en(1'b1), .clr(reset));
    latch fd_pc(.q(FD_pc), .d(stall ? FD_pc : pc_plus_one), .clk(clock), .en(1'b1), .clr(reset));

    /* D stage */

    assign is_jii_type_D = ~FD_insn[31] & ~FD_insn[30] & FD_insn[29] & ~FD_insn[28] & ~FD_insn[27];
    assign is_sw_or_branch = (~FD_insn[31] & ~FD_insn[30] & FD_insn[29] & FD_insn[28]) | 
                              (~FD_insn[31] & ~FD_insn[30] & FD_insn[28] & ~FD_insn[27]);

    assign is_bex_D = FD_insn[31] & ~FD_insn[30] & FD_insn[29] & FD_insn[28] & ~FD_insn[27];

    assign is_multdiv_D = ~FD_insn[31] & ~FD_insn[30] & ~FD_insn[29] & ~FD_insn[28] & ~FD_insn[27] & ~FD_insn[6] & ~FD_insn[5] & 
                          FD_insn[4] & FD_insn[3];

    latch_1bit multdiv_active_latch(.q(multdiv_active), .d(is_multdiv_D), .clk(clock), .en(is_multdiv_D | multdiv_ready), .clr(reset));

    assign ctrl_readRegA = is_bex_D ? 5'd30 : (is_jii_type_D ? FD_insn[26:22] : FD_insn[21:17]);
    assign ctrl_readRegB = is_sw_or_branch ? FD_insn[26:22] : FD_insn[16:12];

    /* D/X latch */

    latch dx_insn(.q(DX_insn), .d(flush_pipeline || stall ? 32'd0 : FD_insn), .clk(clock), .en(1'b1), .clr(reset));
    latch dx_data_operandA(.q(DX_dataA), .d(data_readRegA), .clk(clock), .en(1'b1), .clr(reset));
    latch dx_data_operandB(.q(DX_rt_data), .d(data_readRegB), .clk(clock), .en(1'b1), .clr(reset));
    latch dx_pc(.q(DX_pc), .d(FD_pc), .clk(clock), .en(1'b1), .clr(reset));

    /* X stage */


    assign is_r_type = ~(is_i_type | is_j_type);
    assign is_blt_or_bne =  ~DX_insn[31] & ~DX_insn[30] & DX_insn[28] & ~DX_insn[27];
    assign is_jii_type_X = ~DX_insn[31] & ~DX_insn[30] & DX_insn[29] & ~DX_insn[28] & ~DX_insn[27];
    assign suppress_jump = (DX_insn[31] & ~DX_insn[30] & DX_insn[29] & ~DX_insn[28] & DX_insn[27]) | (is_bex_X & ~cond_NE);

    sx sign_extend(.in(DX_insn[16:0]), .out(sign_ext_imm));
    assign is_i_type = (~DX_insn[31] & DX_insn[30] & ~DX_insn[29] & ~DX_insn[28] & ~DX_insn[27]) |
                       (~DX_insn[31] & ~DX_insn[30] & DX_insn[29]);

    assign is_j_type = (~DX_insn[31] & ~DX_insn[30] & ~DX_insn[29] & DX_insn[27]) |
                       (DX_insn[31] & ~DX_insn[30] & DX_insn[29] & DX_insn[28] & ~DX_insn[27]) |
                       (DX_insn[31] & ~DX_insn[30] & DX_insn[29] & ~DX_insn[28] & DX_insn[27]);

    assign JR_target_PC = JR_MX ? XM_alu_out : (JR_WX ? data_writeReg : DX_dataA);

    assign DX_dataB = (is_i_type & ~is_blt_or_bne) ? sign_ext_imm : DX_rt_data;
    assign jump_target_pc = (is_bex_X & cond_NE) ? {5'b0, DX_insn[26:0]} : (branch_taken ? branch_target_pc : (is_jii_type_X ? JR_target_PC : {5'b0, DX_insn[26:0]}));

    thirty_two_bit_adder branch_adder(
        .A(DX_pc),
        .B(sign_ext_imm),
        .sum(branch_target_pc),
        .sub(1'b0)
    );

    assign branch_taken = (cond_NE & is_blt_or_bne & ~DX_insn[29]) | (cond_LT & is_blt_or_bne & DX_insn[29]);

    assign alu_op = is_r_type ? DX_insn[6:2] : 5'b00000;

    assign is_bex_X = DX_insn[31] & ~DX_insn[30] & DX_insn[29] & DX_insn[28] & ~DX_insn[27];

    assign is_multdiv_X = (~DX_insn[31] & ~DX_insn[30] & ~DX_insn[29] & ~DX_insn[28] & ~DX_insn[27] & ~DX_insn[6] & ~DX_insn[5] & 
                           DX_insn[4] & DX_insn[3]);

    assign is_mult = ~DX_insn[2];

    // A is $rs for blt, bne
    // B is $rd for blt, bne

    mux_4 muxA(.out(aluA), .in0(DX_dataA), .in1(XM_alu_out), .in2(data_writeReg), .in3(DX_dataA), .select(MUX_OpA_select));
    mux_4 muxB(.out(aluB), .in0(DX_dataB), .in1(XM_alu_out), .in2(data_writeReg), .in3(DX_dataB), .select(MUX_OpB_select));

    mux_4 muxA_muldiv(.out(mdA), .in0(DX_dataA), .in1(XM_alu_out), .in2(data_writeReg), .in3(DX_dataA), .select(MUX_OpA_select));
    mux_4 muxB_muldiv(.out(mdB), .in0(DX_dataB), .in1(XM_alu_out), .in2(data_writeReg), .in3(DX_dataB), .select(MUX_OpB_select));

    alu ALU(
        .data_operandA(blt_bne_wx_bypass_rs ? data_writeReg : (blt_bne_mx_bypass_rs ? XM_alu_out : (bex_bypass ? {5'b0, XM_insn[26:0]} : aluA))),
        .data_operandB(blt_bne_wx_bypass_rd ? data_writeReg : (blt_bne_mx_bypass_rd ? XM_alu_out : (is_bex_X ? 32'b0 : aluB))),
        .ctrl_ALUopcode(alu_op),
        .data_result(alu_result),
        .ctrl_shiftamt(DX_insn[11:7]),
        .isNotEqual(cond_NE),
        .isLessThan(cond_LT),
        .overflow(overflow)
    );


    multdiv md_unit(
        .data_operandA(mdA),
        .data_operandB(mdB),
        .ctrl_MULT(is_mult & is_multdiv_X),
        .ctrl_DIV(~is_mult & is_multdiv_X),
        .clock(clock),
        .data_result(multdiv_output),
        .data_exception(multdiv_exception),
        .data_resultRDY(multdiv_ready),
        .OpMult(mult_complete)
    );

    latch multdiv_result_latch(.q(multdiv_output_latched), .d(multdiv_output), .clk(clock), .en(multdiv_ready), .clr(reset));
    latch_5bit multdiv_dest_latch(.q(multdiv_dest_reg), .d(DX_insn[26:22]), .clk(clock), .en(is_multdiv_X), .clr(reset));

    assign ovf_type_alu = alu_op[0] ? 22'd3 : 22'd1;
    assign ovf_type_mult = mult_complete ? 22'd4 : 22'd5;
    assign final_ovf_type = is_i_type ? 22'd2 : ovf_type_alu;

    assign XM_insn_in = (multdiv_exception & multdiv_active & multdiv_ready) ? {5'b11111, 5'd30, ovf_type_mult} :
                        (overflow ? {5'b11111, 5'd30, final_ovf_type} : DX_insn);

    assign alu_result_in = (XM_insn_in[31:27] == 5'b11111) ? {10'b0, final_ovf_type} : alu_result;
    // let 11111 be opcode for $rstatus write, 
    // remember to keep this in mind for writeback stage

    /* X/M latch */

    latch xm_insn(.q(XM_insn), .d(XM_insn_in), .clk(clock), .en(1'b1), .clr(reset));
    latch xm_output(.q(XM_alu_out), .d(alu_result_in), .clk(clock), .en(1'b1), .clr(reset));
    latch xm_data_operandB(.q(XM_rt_data), .d(WX_bypass ? data_writeReg : DX_rt_data), .clk(clock), .en(1'b1), .clr(reset));
    latch xm_PC(.q(XM_pc), .d(DX_pc), .clk(clock), .en(1'b1), .clr(reset));

    /* M stage */

    assign address_dmem = XM_alu_out;
    assign data = WM_bypass ? data_writeReg : XM_rt_data;
    assign wren = ~XM_insn[31] & ~XM_insn[30] & XM_insn[29] & XM_insn[28] & XM_insn[27];
    assign mem_data_out = (~XM_insn[31] & XM_insn[30] & ~XM_insn[29] & ~XM_insn[28] & ~XM_insn[27]) ? q_dmem : XM_alu_out;

    /* M/W latch */

    latch mw_insn(.q(MW_insn), .d(XM_insn), .clk(clock), .en(1'b1), .clr(reset));
    latch mw_output(.q(MW_write_data), .d(mem_data_out), .clk(clock), .en(1'b1), .clr(reset));
    latch mw_data_operandB(.q(MW_rt_data), .d(XM_rt_data), .clk(clock), .en(1'b1), .clr(reset));
    latch mw_PC(.q(MW_pc), .d(XM_pc), .clk(clock), .en(1'b1), .clr(reset));

    /* W stage */

    assign is_write_rstatus = MW_insn[31] & MW_insn[30] & MW_insn[29] & MW_insn[28] & MW_insn[27];
    assign rstatus_value = {10'b0, MW_insn[21:0]};
    assign setx_value = {5'b0, MW_insn[26:0]};
    
    assign is_write_setx = MW_insn[31] & ~MW_insn[30] & MW_insn[29] & ~MW_insn[28] & MW_insn[27];

    assign is_write_normal = (~MW_insn[31] & ~MW_insn[29] & ~MW_insn[28] & ~MW_insn[27]) | 
                             (~MW_insn[30] & MW_insn[29] & ~MW_insn[28] & MW_insn[27]);

    assign is_write_jar = (~MW_insn[31] & ~MW_insn[30] & ~MW_insn[29] & MW_insn[28] & MW_insn[27]);

    assign ctrl_writeReg = (multdiv_ready & multdiv_active) ? multdiv_dest_reg : (is_write_setx ? 5'd30 : (is_write_jar ? 5'b11111 : MW_insn[26:22]));
    assign ctrl_writeEnable = (is_write_normal | is_write_rstatus | is_write_jar | is_write_setx | (multdiv_ready & multdiv_active)) & (ctrl_writeReg != 5'd0);
    assign data_writeReg = (multdiv_ready & multdiv_active) ? multdiv_output_latched :
                           (is_write_setx ? setx_value :
                           (is_write_rstatus ? rstatus_value :
                           (is_write_jar ? MW_pc : MW_write_data)));

    /* DATA HAZARDS CONTROL UNIT */

    // Default to 00 (no bypass)

    assign FD_nop = FD_insn[31:0] == 32'b0;
    assign DX_nop = DX_insn[31:0] == 32'b0;
    assign XM_nop = XM_insn[31:0] == 32'b0;
    assign MW_nop = MW_insn[31:0] == 32'b0;

    assign FD_store = FD_insn[31:27] == 5'b00111;
    assign DX_store = DX_insn[31:27] == 5'b00111;
    assign XM_store = XM_insn[31:27] == 5'b00111;
    assign MW_store = MW_insn[31:27] == 5'b00111;

    assign XM_modifies_regfile = (XM_insn[30:27] == 4'b0101) | ({XM_insn[31],XM_insn[29:27]} == 4'b0000) | ({XM_insn[31:30],XM_insn[28:27]} == 4'b0011) | (XM_insn[31:27] == 5'b11111);
    assign MW_modifies_regfile = (MW_insn[30:27] == 4'b0101) | ({MW_insn[31],MW_insn[29:27]} == 4'b0000) | ({MW_insn[31:30],MW_insn[28:27]} == 4'b0011); //

    assign XM_not_0 = (XM_insn[26:22] != 5'b00000);

    assign B_uses_rt = (DX_insn[31:27] == 5'b00000) &&
                   ((DX_insn[6:3] == 4'b0000) || ({DX_insn[6:5], DX_insn[3]} == 3'b001));

    assign MUX_OpA_select = ((DX_insn[21:17] == XM_insn[26:22]) & ~DX_nop & ~XM_nop & ~XM_store & XM_not_0 & XM_modifies_regfile) ? 2'b01 :  // M/X bypass
                            (DX_insn[21:17] == MW_insn[26:22] & ~DX_nop & ~MW_nop & ~MW_store & (MW_insn[26:22] != 5'd0 & MW_modifies_regfile)) ? 2'b10 :  // W/X bypass
                            2'b00;                                        // No bypass

    assign MUX_OpB_select = (DX_insn[16:12] == XM_insn[26:22] & ~DX_nop & ~XM_nop & ~XM_store & B_uses_rt & XM_not_0 & XM_modifies_regfile) ? 2'b01 :  // M/X bypass
                            (DX_insn[16:12] == MW_insn[26:22] & ~DX_nop & ~MW_nop & ~MW_store & B_uses_rt & (MW_insn[26:22] != 5'd0) & MW_modifies_regfile) ? 2'b10 :  // W/X bypass
                            2'b00;                                        // No bypass

    assign WM_bypass = (MW_insn[26:22] == XM_insn[26:22]) & XM_store & ~MW_nop & ~MW_store && MW_modifies_regfile;
    assign WX_bypass = (MW_insn[26:22] == DX_insn[26:22]) & DX_store & ~MW_nop & ~MW_store && MW_modifies_regfile;

    assign JR_MX = (DX_insn[31:27] == 5'b00100) && (XM_insn[26:22] == 5'b11111) && XM_modifies_regfile && ~XM_store;
    assign JR_WX = (DX_insn[31:27] == 5'b00100) && (MW_insn[26:22] == DX_insn[26:22]) && MW_modifies_regfile && ~MW_store;

    assign stall = (DX_insn[31:27] == 5'b01000) && ((FD_insn[21:17] == DX_insn[26:22]) || ((FD_insn[16:12] == DX_insn[26:22]) && ~FD_store) || 
                                                     ((FD_insn[26:22] == DX_insn[26:22]) && ((FD_insn[31:27] == 5'b00100) || fd_blt_bne))) && ~FD_nop;

    assign bex_bypass = (DX_insn[31:27] == 5'b10110) && (XM_insn[31:27] == 5'b10101);

    assign dx_blt_bne = (DX_insn[31:30] == 5'b00) && (DX_insn[28:27] == 5'b10);
    assign fd_blt_bne = (FD_insn[31:30] == 5'b00) && (FD_insn[28:27] == 5'b10);

    assign blt_bne_mx_bypass_rd = (dx_blt_bne) && (XM_insn[26:22] == DX_insn[26:22]) && ~XM_nop && XM_modifies_regfile && ~XM_store;
    assign blt_bne_mx_bypass_rs = (dx_blt_bne) && (XM_insn[26:22] == DX_insn[21:17]) && ~XM_nop && XM_modifies_regfile && ~XM_store;
    assign blt_bne_wx_bypass_rd = dx_blt_bne && (MW_insn[26:22] == DX_insn[26:22]) && ~MW_nop && MW_modifies_regfile && ~MW_store;
    assign blt_bne_wx_bypass_rs = dx_blt_bne && (MW_insn[26:22] == DX_insn[21:17]) && ~MW_nop && MW_modifies_regfile && ~MW_store;
    /* YOUR CODE ENDS HERE */

endmodule
