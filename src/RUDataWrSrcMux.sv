module RUDataWrSrcMux(
    input logic signed [31:0] alu_result,
    input logic signed [31:0] data_mem_rd,
    input logic signed [31:0] adder_result,
    input logic signed [31:0] imm_ext,     
    input logic signed [1:0] sel,

    output logic signed [31:0] ru_wrdata
);
    always @(*) begin
        case (sel)
            2'b00: ru_wrdata = alu_result;     // Para R-type, I-type, AUIPC
            2'b01: ru_wrdata = data_mem_rd;    // Para LOAD
            2'b10: ru_wrdata = adder_result;   // Para JAL/JALR (PC+4)
            2'b11: ru_wrdata = imm_ext;        // Para LUI (inmediato extendido)
            default: ru_wrdata = 32'b0;
        endcase
    end
endmodule