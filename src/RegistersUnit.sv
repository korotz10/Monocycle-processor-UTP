module RegistersUnit(

    input logic clk,
    input logic signed [4:0] rs1,
    input logic signed [4:0] rs2,
    input logic signed [4:0] rd,

    input logic signed [31:0] DataWR,
    input logic RUWr, // toggle

    output logic signed [31:0] ru_rs1,
    output logic signed [31:0] ru_rs2
);
    // register matrix
    logic signed [31:0] ru [31:0];

    initial begin
        ru[2] = 32'b1000000000;
    end

    assign ru_rs1 = ru[rs1];
    assign ru_rs2 = ru[rs2];

    always @(posedge clk) begin
        if (RUWr && rd != 0) begin
            ru[rd] <= DataWR;
        end 
    end
endmodule