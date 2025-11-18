module RUDataWrSrcMux(
    input logic signed [31:0] alu_result,
    input logic signed [31:0] data_mem_rd,
    input logic signed [31:0] adder_result,
    input logic signed [1:0] sel,

    output logic signed [31:0] ru_wrdata
);
    always @(*) begin
        if (sel == 2'b10)
            ru_wrdata = adder_result;
        else if (sel == 2'b01)
            ru_wrdata = data_mem_rd;
        else if (sel == 2'b00)
            ru_wrdata = alu_result;
        else
            ru_wrdata = 32'b0; // Default case
    end
endmodule