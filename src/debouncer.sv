// debouncer.sv
// Debouncer robusto para botones físicos
// Genera un pulso de 1 ciclo cuando detecta flanco de subida estable

module debouncer #(
    parameter DEBOUNCE_TIME_MS = 20  // 20ms debounce
)(
    input  logic clk,           // 50 MHz
    input  logic reset,
    input  logic btn_in,        // Botón crudo
    output logic btn_pulse      // Pulso de 1 ciclo
);

    // Para 50 MHz y 20ms: contar hasta 1_000_000 ciclos
    localparam COUNT_MAX = DEBOUNCE_TIME_MS * 50_000;
    localparam COUNT_BITS = $clog2(COUNT_MAX + 1);
    
    logic [COUNT_BITS-1:0] counter;
    logic btn_sync_1, btn_sync_2;  // Sincronización doble FF
    logic btn_stable;
    logic btn_stable_prev;
    
    // Sincronizador de 2 FFs para evitar metaestabilidad
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync_1 <= 1'b0;
            btn_sync_2 <= 1'b0;
        end else begin
            btn_sync_1 <= btn_in;
            btn_sync_2 <= btn_sync_1;
        end
    end
    
    // Debouncer: esperar que señal sea estable por DEBOUNCE_TIME_MS
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= '0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_sync_2 == btn_stable) begin
                counter <= '0;  // Señal coincide, resetear contador
            end else begin
                counter <= counter + 1'b1;
                if (counter >= COUNT_MAX) begin
                    btn_stable <= btn_sync_2;  // Actualizar después de timeout
                    counter <= '0;
                end
            end
        end
    end
    
    // Detector de flanco de subida: genera pulso de 1 ciclo
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_stable_prev <= 1'b0;
            btn_pulse <= 1'b0;
        end else begin
            btn_stable_prev <= btn_stable;
            btn_pulse <= btn_stable && !btn_stable_prev;
        end
    end
    
endmodule