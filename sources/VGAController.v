`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	input [31:0] cardIndex,	// Card index to draw
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output [31:0] RAMaddr,	// Address to query
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B  // Blue Signal Bits
	);
	
	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/Nimaye Garodia/iCloudDrive/Desktop/3-2/ECE 350/blackjack-machine/sources/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

    assign clk25 = clk;
    
	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;

	wire[9:0] left_x;
	wire[8:0] top_y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = 102375, 	             					 // Number of pixels in sprite sheet
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr, colorBTNAddr; 	 // Color address for the color palette

	wire [31:0] cardNumber;
	assign cardNumber = x/95;
	assign left_x = cardNumber * 85 + 10;
	assign top_y = 9'd20;
	assign RAMaddr = 16 + cardNumber;
	
	wire [31:0] safeCardIndex = (cardIndex == 0) ? 1 : cardIndex;

	assign imgAddress = (x - left_x) + ((y - top_y) * 85) + 7875 * (safeCardIndex - 1); // Calculate the address in the image data

	RAM #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorDataCard, colorDataBTN; // 12-bit color data at current pixel
	wire[BITS_PER_COLOR-1:0] colorData, colorBTN;

	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorDataCard),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading
		
	wire[15:0] imgBTNAddress;
	assign imgBTNAddress = (x-200) + 240*(y-300);
	
	RAM #(		
		.DEPTH(36000), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(16),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "imageBTN.mem"})) // Memory initialization
	ImageDataBTN(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgBTNAddress),					 // Image data address
		.dataOut(colorBTNAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading
		
	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colorsBTN.mem"}))  // Memory initialization
	ColorPaletteBTN(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorBTNAddr),					       // Address from the ImageData RAM
		.dataOut(colorBTN),				       // Color at current pixel
		.wEn(1'b0));						 // We're always reading

	wire [2:0] writeType; // 100 = cardWrite, 111 = controllerWrite, 001 = winScreenWrite, 010 = lossScreenWrite, 000 = whiteScreen
	
	wire isCardRegion, isBTNRegion;

	assign isCardRegion = ((left_x <= x) && (x <= left_x+74) && (top_y <= y) && (y <= top_y+104));
    assign isBTNRegion = ((200 <= x) && (x <= 439) && (300 <= y) && (y < 450));
    
    assign writeType[2] = isCardRegion;
    assign writeType[1] = isBTNRegion && !isCardRegion;
    assign writeType[0] = isBTNRegion && !isCardRegion;

	mux_8_12bit chooseWriteType(
		.out(colorData),
		.select(writeType),
		.in0(12'hfff), // whiteScreen
		.in1(12'h000), // winScreenWrite
		.in2(12'h000), // lossScreenWrite
		.in3(12'hfff), // UNUSED
		.in4((imgAddress < 0) ? 12'hfff : colorDataCard), // cardWrite
		.in5(12'hfff), // UNUSED
		.in6(12'hfff), // UNUSED
		.in7(colorBTN)  // controllerWrite
	);

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	assign colorOut = active ? colorData : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule