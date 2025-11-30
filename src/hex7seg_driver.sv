// hex7seg_driver.sv
// Driver multiplexado para 6 displays de 7 segmentos
// Muestra 24 bits (6 dígitos hex) con refresco ~1kHz por display

module hex7seg_driver(
    input  logic        clk,          // 50 MHz
    input  logic        reset,
    input  logic [23:0] hex_value,    // 6 dígitos hex a mostrar
    output logic [6:0]  seg,          // Segmentos a-g (activo bajo)
    output logic [5:0]  dig_enable    // Enable para cada display (activo bajo)
);

    // Divisor de reloj: ~1kHz por display (refresh ~6kHz total)
    // 50MHz / 50000 = 1kHz
    localparam REFRESH_COUNT = 50_000;
    logic [$clog2(REFRESH_COUNT)-1:0] refresh_counter;
    logic [2:0] digit_select;  // 0-5 para seleccionar dígito
    
    // Contador de refresco
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= '0;
            digit_select <= 3'd0;
        end else begin
            if (refresh_counter >= REFRESH_COUNT - 1) begin
                refresh_counter <= '0;
                digit_select <= (digit_select == 3'd5) ? 3'd0 : digit_select + 3'd1;
            end else begin
                refresh_counter <= refresh_counter + 1'b1;
            end
        end
    end
    
    // Selección del dígito actual
    logic [3:0] current_digit;
    always_comb begin
        case (digit_select)
            3'd0: current_digit = hex_value[3:0];
            3'd1: current_digit = hex_value[7:4];
            3'd2: current_digit = hex_value[11:8];
            3'd3: current_digit = hex_value[15:12];
            3'd4: current_digit = hex_value[19:16];
            3'd5: current_digit = hex_value[23:20];
            default: current_digit = 4'h0;
        endcase
    end
    
    // Decodificador hex a 7 segmentos (cátodo común: activo bajo)
    // Segmentos: seg[6:0] = {g,f,e,d,c,b,a}
    always_comb begin
        case (current_digit)
            4'h0: seg = 7'b1000000;  // 0
            4'h1: seg = 7'b1111001;  // 1
            4'h2: seg = 7'b0100100;  // 2
            4'h3: seg = 7'b0110000;  // 3
            4'h4: seg = 7'b0011001;  // 4
            4'h5: seg = 7'b0010010;  // 5
            4'h6: seg = 7'b0000010;  // 6
            4'h7: seg = 7'b1111000;  // 7
            4'h8: seg = 7'b0000000;  // 8
            4'h9: seg = 7'b0010000;  // 9
            4'hA: seg = 7'b0001000;  // A
            4'hB: seg = 7'b0000011;  // b
            4'hC: seg = 7'b1000110;  // C
            4'hD: seg = 7'b0100001;  // d
            4'hE: seg = 7'b0000110;  // E
            4'hF: seg = 7'b0001110;  // F
        endcase
    end
    
    // Habilitación del display (activo bajo, solo uno a la vez)
    always_comb begin
        dig_enable = 6'b111111;  // Todos deshabilitados
        dig_enable[digit_select] = 1'b0;  // Habilitar el actual
    end
    
endmodule