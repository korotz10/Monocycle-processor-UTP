module BranchUnit(
    input  logic [4:0] BrOp, 
    input  logic signed [31:0] A,   // rs1
    input  logic signed [31:0] B,   // rs2
    output logic NextPCSrc       // 1 = saltar, 0 = no saltar
);

always @(*) begin
    casex (BrOp)

        // NO BRANCH
        5'b0_0XXX: NextPCSrc = 1'b0;

        // BEQ (=)
        5'b0_1000: NextPCSrc = (A == B);

        // BNE (!=)
        5'b0_1001: NextPCSrc = (A != B);

        // BLT (< signed)
        5'b0_1100: NextPCSrc = (A < B);

        // BGE (≥ signed)
        5'b0_1101: NextPCSrc = (A >= B);

        // BLTU (< unsigned)
        5'b0_1110: NextPCSrc = ($unsigned(A) < $unsigned(B));

        // BGEU (≥ unsigned)
        5'b0_1111: NextPCSrc = ($unsigned(A) >= $unsigned(B));

        // JAL / JALR  → salto incondicional
        5'b1_XXXX: NextPCSrc = 1'b1;

        default:
            NextPCSrc = 1'b0;
    endcase
end

endmodule
