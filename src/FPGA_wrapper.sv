// FPGA_wrapper.sv
// Wrapper para CPU monociclo en DE1-SoC
// Maneja step-by-step execution con botón y display en 7-seg

module FPGA_wrapper(
    input  logic       CLOCK_50,        // 50 MHz clock de la DE1-SoC
    input  logic [2:0] KEY,             // KEY[0]=step, KEY[1]=toggle_half, KEY[2]=reset (activo bajo)
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5  // 7-seg displays
);

    // Botones activo bajo -> activo alto
    logic btn_step_raw, btn_toggle_raw, reset;
    assign btn_step_raw = ~KEY[0];
    assign btn_toggle_raw = ~KEY[1];
    assign reset = ~KEY[2];  // KEY[2] como reset
    
    // ================================================
    // Debouncer para botones
    // ================================================
    logic btn_step_pulse, btn_toggle_pulse;
    
    debouncer #(.DEBOUNCE_TIME_MS(20)) debounce_step (
        .clk(CLOCK_50),
        .reset(reset),
        .btn_in(btn_step_raw),
        .btn_pulse(btn_step_pulse)
    );
    
    debouncer #(.DEBOUNCE_TIME_MS(20)) debounce_toggle (
        .clk(CLOCK_50),
        .reset(reset),
        .btn_in(btn_toggle_raw),
        .btn_pulse(btn_toggle_pulse)
    );
    
    // ================================================
    // Toggle para seleccionar mitad alta/baja (24 bits)
    // ================================================
    logic show_upper_half;  // 0=lower 24 bits, 1=upper 8+lower16
    
    always_ff @(posedge CLOCK_50 or posedge reset) begin
        if (reset)
            show_upper_half <= 1'b0;
        else if (btn_toggle_pulse)
            show_upper_half <= ~show_upper_half;
    end
    
    // ================================================
    // Clock para CPU: un pulso por presión de botón
    // ================================================
    logic cpu_clk;
    assign cpu_clk = btn_step_pulse;
    
    // ================================================
    // Instancia del CPU con señales de debug
    // ================================================
    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;
    logic [31:0] debug_alu_result;
    logic [31:0] debug_writeback;
    logic [31:0] debug_rs2;
    logic        debug_branch_taken;
    
    CPU_top cpu_inst (
        .clk(cpu_clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_writeback(debug_writeback),
        .debug_rs2(debug_rs2),
        .debug_branch_taken(debug_branch_taken)
    );
    
    // ================================================
    // Decodificación de instrucción para seleccionar display_value
    // ================================================
    logic [6:0] opcode;
    assign opcode = debug_instruction[6:0];
    
    logic [31:0] display_value_32bit;
    logic [31:0] pc_plus4;
    assign pc_plus4 = debug_pc + 32'd4;
    
    // Decodificación según tipo de instrucción
    always_comb begin
        case (opcode)
            // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            7'b0110011: display_value_32bit = debug_writeback;
            
            // I-type arithmetic: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: display_value_32bit = debug_writeback;
            
            // I-type load: LB, LH, LW, LBU, LHU
            7'b0000011: display_value_32bit = debug_writeback;
            
            // S-type: SB, SH, SW -> mostrar rs2 (dato a escribir)
            7'b0100011: display_value_32bit = debug_rs2;
            
            // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
            // Mostrar dirección destino: si rama tomada -> ALURes, sino -> PC+4
            7'b1100011: display_value_32bit = debug_branch_taken ? debug_alu_result : pc_plus4;
            
            // U-type: LUI, AUIPC
            7'b0110111, 7'b0010111: display_value_32bit = debug_writeback;
            
            // J-type: JAL
            7'b1101111: display_value_32bit = debug_writeback;
            
            // JALR
            7'b1100111: display_value_32bit = debug_writeback;
            
            // Default: mostrar writeback
            default: display_value_32bit = debug_writeback;
        endcase
    end
    
    // ================================================
    // Selección de 24 bits a mostrar (mitad alta/baja)
    // ================================================
    logic [23:0] display_value_24bit;
    
    always_comb begin
        if (show_upper_half)
            display_value_24bit = {8'h00, display_value_32bit[31:16]};  // Upper 16 bits
        else
            display_value_24bit = display_value_32bit[23:0];  // Lower 24 bits
    end
    
    // ================================================
    // Driver de displays 7-seg multiplexado
    // ================================================
    // Nota: DE1-SoC tiene displays separados, no multiplexados físicamente
    // Convertir señales para cada display individual
    logic [6:0] seg_combined;
    logic [5:0] dig_enable;
    
    hex7seg_driver display_driver (
        .clk(CLOCK_50),
        .reset(reset),
        .hex_value(display_value_24bit),
        .seg(seg_combined),
        .dig_enable(dig_enable)
    );
    
    // Asignación a displays individuales (multiplexado en tiempo)
    // En DE1-SoC cada HEXn es independiente, así que usamos lógica para mostrar todos
    // Alternativa: mostrar directamente sin multiplexado
    
    // Solución simple: decodificar directamente cada dígito sin multiplexado
    logic [3:0] digit0, digit1, digit2, digit3, digit4, digit5;
    assign digit0 = display_value_24bit[3:0];
    assign digit1 = display_value_24bit[7:4];
    assign digit2 = display_value_24bit[11:8];
    assign digit3 = display_value_24bit[15:12];
    assign digit4 = display_value_24bit[19:16];
    assign digit5 = display_value_24bit[23:20];
    
    // Lookup table para reducir conflictos de LAB
    logic [6:0] HEX_LUT [0:15];
    
    initial begin
        HEX_LUT[4'h0] = 7'b1000000;
        HEX_LUT[4'h1] = 7'b1111001;
        HEX_LUT[4'h2] = 7'b0100100;
        HEX_LUT[4'h3] = 7'b0110000;
        HEX_LUT[4'h4] = 7'b0011001;
        HEX_LUT[4'h5] = 7'b0010010;
        HEX_LUT[4'h6] = 7'b0000010;
        HEX_LUT[4'h7] = 7'b1111000;
        HEX_LUT[4'h8] = 7'b0000000;
        HEX_LUT[4'h9] = 7'b0010000;
        HEX_LUT[4'hA] = 7'b0001000;
        HEX_LUT[4'hB] = 7'b0000011;
        HEX_LUT[4'hC] = 7'b1000110;
        HEX_LUT[4'hD] = 7'b0100001;
        HEX_LUT[4'hE] = 7'b0000110;
        HEX_LUT[4'hF] = 7'b0001110;
    end
    
    assign HEX0 = HEX_LUT[digit0];
    assign HEX1 = HEX_LUT[digit1];
    assign HEX2 = HEX_LUT[digit2];
    assign HEX3 = HEX_LUT[digit3];
    assign HEX4 = HEX_LUT[digit4];
    assign HEX5 = HEX_LUT[digit5];
    
endmodule