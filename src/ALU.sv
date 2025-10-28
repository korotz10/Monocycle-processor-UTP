module ALU(
    input logic signed [31:0] A,
    input logic signed [31:0] B,

    input logic [3:0] ALUOp,

    output logic signed [31:0] ALURes = 0
);

    // It executes each time any input changes
    always @* begin
        case(ALUOp)
            4'b0000: ALURes = A + B; // ADD
            4'b1000: ALURes = A - B; // SUB
            4'b0001: ALURes = A << B; // SLL
            4'b0010: ALURes = A < B; // SLT
            4'b0011: ALURes = $unsigned(A) < $unsigned(B); // SLTU
            4'b0100: ALURes = A ^ B; // XOR
            4'b0101: ALURes = A >> B; // SRL
            4'b1101: ALURes = A >>> B; // SRA
            4'b0110: ALURes = A | B; // OR
            4'b0111: ALURes = A & B; // AND
            4'b1001: ALURes = B;
        endcase
    end
endmodule