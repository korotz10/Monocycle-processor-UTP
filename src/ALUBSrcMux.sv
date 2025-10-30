module ALUBSrcMux(
    input logic signed [31:0] ru_rs2,
    input logic signed [31:0] Imm_ext,
    input logic sel,

    output logic signed [31:0] b
);
    always @(*) begin
        if (sel)
            b = Imm_ext;
        else
            b = ru_rs2;
    end
endmodule