`timescale 1ns / 1ps

module rng_tb;
    reg clk;
    reg [31:0] current;
    wire [31:0] next;

    // Instantiate stateless RNG logic
    rng dut (
        .current(current),
        .next(next)
    );

    // Clock generator: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // State register and logging
    integer i;
    initial begin
        current = 32'd1;  // seed

        $display("Time\t\tcurrent\t\t\t\tnext");
        $display("---------------------------------------------------------");

        // Generate 20 values
        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            $display("%0t\t%d\t%0d\t->\t%d\t%0d", $time, current, ((current % 52) % 13) + 1, next, ((next % 52) % 13) + 1);
            current <= next;
        end

        $finish;
    end
endmodule
