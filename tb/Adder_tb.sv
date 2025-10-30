module Adder_tb;
    // Señales del testbench
    logic signed [31:0] pc_in;
    logic signed [31:0] pc_out;
    
    // Instanciar el DUT
    Adder dut (
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/Adder_tb.vcd");
        $dumpvars(0, Adder_tb);
    end
    
    // Tarea para verificar resultado
    task check_result(input [31:0] input_val, input [31:0] expected);
        tests++;
        pc_in = input_val;
        #10; // Esperar a que se propague
        $display("Test %0d:", tests);
        $display("  Entrada  = 0x%h (%0d)", input_val, input_val);
        $display("  Esperado = 0x%h (%0d)", expected, expected);
        $display("  Obtenido = 0x%h (%0d)", pc_out, pc_out);
        if (pc_out !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        pc_in = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion Adder ===");
        $display("========================================\n");
        
        #10;
        
        // Test 1: Suma desde 0
        $display("========== Test 1: Desde direccion 0 ==========");
        check_result(32'h00000000, 32'h00000004);
        
        // Test 2: Suma desde 4
        $display("========== Test 2: Desde direccion 4 ==========");
        check_result(32'h00000004, 32'h00000008);
        
        // Test 3: Suma desde dirección típica
        $display("========== Test 3: Desde direccion tipica ==========");
        check_result(32'h00001000, 32'h00001004);
        
        // Test 4: Suma desde dirección grande
        $display("========== Test 4: Desde direccion grande ==========");
        check_result(32'h0FFFFFF0, 32'h0FFFFFF4);
        
        // Test 5: Cerca del límite superior
        $display("========== Test 5: Cerca del limite superior ==========");
        check_result(32'h7FFFFFFC, 32'h80000000);
        
        // Test 6: Overflow desde valor máximo
        $display("========== Test 6: Overflow ==========");
        check_result(32'hFFFFFFFC, 32'h00000000);
        
        // Test 7: Desde dirección negativa
        $display("========== Test 7: Desde direccion negativa ==========");
        check_result(32'hFFFFFFF0, 32'hFFFFFFF4);
        
        // Test 8: Desde 0xFFFFFFFF
        $display("========== Test 8: Desde 0xFFFFFFFF ==========");
        check_result(32'hFFFFFFFF, 32'h00000003);
        
        // Resumen final
        $display("========================================");
        $display("=== Resumen de la simulacion ===");
        $display("Tests ejecutados: %0d", tests);
        $display("Tests exitosos: %0d", tests - errors);
        $display("Errores: %0d", errors);
        $display("========================================");
        
        if (errors == 0)
            $display("Todos los tests pasaron exitosamente");
        else
            $display("Se encontraron %0d errores", errors);
        
        $finish;
    end
    
endmodule