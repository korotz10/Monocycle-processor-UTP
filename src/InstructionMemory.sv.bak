module InstructionMemory (
    input  logic [31:0] address,       // PC
    output logic [31:0] instruction // Instruction
);

    logic [31:0] memory [0:255];    // 256 instrucciones → 1 KB

    // Cargar programa en hex
    initial begin
        $readmemh("src/program.hex", memory);
    end

    // Direccion por palabras: PC >> 2
    assign instruction = memory[address[31:2]];

endmodule
