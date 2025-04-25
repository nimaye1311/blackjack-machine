    wire [18:0] WINAddr = x + 640 * y;
    wire [18:0] LOSSAddr = x + 640 * y;
    wire [PALETTE_ADDRESS_WIDTH-1:0] colorWIN, colorLOSS;
    wire [BITS_PER_COLOR-1:0] colorWINout, colorLOSSout;
    
    ROM #(
        .DEPTH(307200),
        .DATA_WIDTH(PALETTE_ADDRESS_WIDTH),
        .ADDRESS_WIDTH(19),
        .MEMFILE({FILES_PATH, "imageWIN.mem"}))
    ImageDataWIN(
        .clk(clk),
        .addr(WINAddr),
        .dataOut(colorWIN));
        
    ROM #(
        .DEPTH(PALETTE_COLOR_COUNT),
        .DATA_WIDTH(BITS_PER_COLOR),
        .ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),
        .MEMFILE({FILES_PATH, "colorsWIN.mem"}))
    ColorDataWIN(
        .clk(clk),
        .addr(colorWIN),
        .dataOut(colorWINout));
        
    ROM #(
        .DEPTH(307200),
        .DATA_WIDTH(PALETTE_ADDRESS_WIDTH),
        .ADDRESS_WIDTH(19),
        .MEMFILE({FILES_PATH, "imageLOSS.mem"}))
    ImageDataLOSS(
        .clk(clk),
        .addr(LOSSAddr),
        .dataOut(colorLOSS));
        
    ROM #(
        .DEPTH(PALETTE_COLOR_COUNT),
        .DATA_WIDTH(BITS_PER_COLOR),
        .ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),
        .MEMFILE({FILES_PATH, "colorsLOSS.mem"}))
    ColorDataLOSS(
        .clk(clk),
        .addr(colorLOSS),
        .dataOut(colorLOSSout));