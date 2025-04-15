module is_zero (
    input [31:0] A,      // 32-bit input
    output isZero        // Output: 0 if all bits of A are 0, otherwise 1
);

    // Intermediate wires for each level of the OR tree
    wire [15:0] or_level1;
    wire [7:0] or_level2;
    wire [3:0] or_level3;
    wire [1:0] or_level4;
    wire final_or;

    // Level 1: Pairwise OR of 32 bits into 16 outputs
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : level1
            or u1 (or_level1[i], A[2*i], A[2*i+1]);
        end
    endgenerate

    // Level 2: OR of 16 inputs into 8 outputs
    generate
        for (i = 0; i < 8; i = i + 1) begin : level2
            or u2 (or_level2[i], or_level1[2*i], or_level1[2*i+1]);
        end
    endgenerate

    // Level 3: OR of 8 inputs into 4 outputs
    generate
        for (i = 0; i < 4; i = i + 1) begin : level3
            or u3 (or_level3[i], or_level2[2*i], or_level2[2*i+1]);
        end
    endgenerate

    // Level 4: OR of 4 inputs into 2 outputs
    generate
        for (i = 0; i < 2; i = i + 1) begin : level4
            or u4 (or_level4[i], or_level3[2*i], or_level3[2*i+1]);
        end
    endgenerate

    // Level 5: Final OR gate to combine the last two outputs
    or final_or_gate (isZero, or_level4[0], or_level4[1]);

endmodule
