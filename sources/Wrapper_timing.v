`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 * ff
 **/

module Wrapper (
    input clk_100mhz,
    input BTNU,
    input BTNL,
    input BTND,
    input BTNR,
    input reset, 
    input [15:0] SW,
    output VGA_HS, 		// H Sync Signal
	output VGA_VS, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
    output reg [15:0] LED);
    
    wire clock25mhz;
    wire locked;
    
    clk_wiz_0 pll(
    .clk_out1(clock25mhz),
    .reset(1'b0),
    .clk_in1(clk_100mhz));

    
    wire clock;
    assign clock = clock25mhz;
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, q_dmem, data, memAddr2, cardIndex;
    reg [15:0] SW_Q, SW_M;  
    wire[15:0] LED_out;
    
    wire io_read, io_write;
    
    assign io_read = (memAddr == 32'd4096) ? 1'b1: 1'b0;
    assign io_write = (memAddr == 32'd4) ? 1'b1: 1'b0;
//     always @(negedge clock) begin
//           SW_M <= SW;
//           SW_Q <= SW_M; 
//       end
       
//       always @(posedge clock) begin
//           if (io_write == 1'b1) begin
//               LED <= memDataIn[15:0];
//           end else begin
//               LED <= LED; 3e
//           end
//       end

    wire[1:0] io_type;
    
    assign io_type[1] = BTNU;
    assign io_type[0] = BTND;
    
    assign q_dmem = (io_read == 1'b1 && (io_type[1] ^ io_type[0])) ? (io_type[1] ? 1 : 2) : memDataOut; // Writes 1 if BTNU, 2 if BTND
	// ADD YOUR MEMORY FILE HERE 
	localparam INSTR_FILE = "timing";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(q_dmem)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.addr2(memAddr2[11:0]),
		.dataIn(memDataIn), 
		.dataOut(memDataOut),
		.dataOut2(cardIndex));

	reg [1:0] winLoss;

	always @(negedge clock) begin
		if (io_write == 1'b1) begin
			winLoss <= memDataIn;
			LED[12:0] <= memDataIn;
			LED[13] <= (memDataIn != 0) ? 1'b1 : 1'b0;
			LED[14] <= BTNL;
		end 
		if (io_read == 1'b1 && (io_type[1] ^ io_type[0]) && (io_type[0])) begin
		    LED[15] <= 1'b1;
		end else begin
		    LED[15] <= 1'b0;
		end
	end	
	
	VGAController VGA_display(     
	.clk(clock25mhz), 			// 100 MHz System Clock
	.RAMaddr(memAddr2),	// Address to query
	.winLoss(winLoss), // 2 bit, win or loss (01 = win, 10 = loss)
	.cardIndex(cardIndex),	// Card index to query
	.reset(reset), 		// Reset Signal
	.hSync(VGA_HS), 		// H Sync Signal
	.vSync(VGA_VS), 		// Veritcal Sync Signal
	.VGA_R(VGA_R),  // Red Signal Bits
	.VGA_G(VGA_G),  // Green Signal Bits
	.VGA_B(VGA_B),  // Blue Signal Bits
	.LED_out(LED_out) // Debugging LED output
	);


endmodule
