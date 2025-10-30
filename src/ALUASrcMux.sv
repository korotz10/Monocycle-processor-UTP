module ALUASrcMux(
    input logic signed [31:0] ru_rs1,
    input logic signed [31:0] pc,
    input logic sel,

    output logic signed [31:0] a
);
    always @(*) begin
        if (sel)
            a = pc;
        else
            a = ru_rs1;
    end
endmodule