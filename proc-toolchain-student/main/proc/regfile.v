module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

    wire [31:0] registers [0:31]; // Wire array for outputs of each register
	wire [31:0] writeReg, readRegA, readRegB;

	assign writeReg = ctrl_writeEnable << ctrl_writeReg;

    // Generate blocks for registers and their bits
    genvar i, j, k;

	generate
		for (i = 1; i < 32; i = i + 1) begin : register
			for (j = 0; j < 32; j = j + 1) begin : bit
				dffe_ref dff (
					.q(registers[i][j]),
					.d(data_writeReg[j]),
					.clk(clock),
					.en(writeReg[i]),
					.clr(ctrl_reset)
				);
			end
		end

		for (k = 0; k < 32; k = k + 1) begin : bit_reg_0
			dffe_ref dff_0 (
				.q(registers[0][k]),
				.d(1'b0),
				.clk(clock),
				.en(1'b0),
				.clr(1'b0)
			);
		end
	endgenerate

	mux_32 muxA(
		.out(data_readRegA),
		.select(ctrl_readRegA),
		.in0(registers[0]), .in1(registers[1]), .in2(registers[2]), .in3(registers[3]),
		.in4(registers[4]), .in5(registers[5]), .in6(registers[6]), .in7(registers[7]),
		.in8(registers[8]), .in9(registers[9]), .in10(registers[10]), .in11(registers[11]),
		.in12(registers[12]), .in13(registers[13]), .in14(registers[14]), .in15(registers[15]),
		.in16(registers[16]), .in17(registers[17]), .in18(registers[18]), .in19(registers[19]),
		.in20(registers[20]), .in21(registers[21]), .in22(registers[22]), .in23(registers[23]),
		.in24(registers[24]), .in25(registers[25]), .in26(registers[26]), .in27(registers[27]),
		.in28(registers[28]), .in29(registers[29]), .in30(registers[30]), .in31(registers[31])
		);

    mux_32 muxB(
        .out(data_readRegB),
        .select(ctrl_readRegB),
        .in0(registers[0]), .in1(registers[1]), .in2(registers[2]), .in3(registers[3]),
        .in4(registers[4]), .in5(registers[5]), .in6(registers[6]), .in7(registers[7]),
        .in8(registers[8]), .in9(registers[9]), .in10(registers[10]), .in11(registers[11]),
        .in12(registers[12]), .in13(registers[13]), .in14(registers[14]), .in15(registers[15]),
        .in16(registers[16]), .in17(registers[17]), .in18(registers[18]), .in19(registers[19]),
        .in20(registers[20]), .in21(registers[21]), .in22(registers[22]), .in23(registers[23]),
        .in24(registers[24]), .in25(registers[25]), .in26(registers[26]), .in27(registers[27]),
        .in28(registers[28]), .in29(registers[29]), .in30(registers[30]), .in31(registers[31])
    );
endmodule
