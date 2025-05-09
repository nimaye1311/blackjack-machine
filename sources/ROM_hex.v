`timescale 1ns / 1ps
module ROM_hex #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 12, DEPTH = 4096, MEMFILE = "") (
    input wire                     clk,
    input wire [ADDRESS_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0]    dataOut = 0);
    
    reg[DATA_WIDTH-1:0] MemoryArray[0:DEPTH-1];
    
    initial begin
        if(MEMFILE > 0) begin
            $readmemh(MEMFILE, MemoryArray);
        end
    end
    // CUSTOM ROM MODULE!
    always @(posedge clk) begin
        dataOut <= MemoryArray[addr];
    end
endmodule
