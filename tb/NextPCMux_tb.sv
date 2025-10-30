module NextPCMux_tb;
    // Señales del testbench
    logic signed [31:0] pc_plus4;
    logic signed [31:0] branch_target;
    logic sel;
    logic signed [31:0] next_pc;
    
    // Instanciar el DUT
    NextPCMux dut (
        .pc_plus4(pc_plus4),
        .branch_target(branch_target),
        .sel(sel),
        .next_pc(next_pc)
    );
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/NextPCMux_tb.vcd");
        $dumpvars(0, NextPCMux_tb);
    end
    
    // Tarea para verificar resultado
    task check_result(input [31:0] pc4_val, input [31:0] branch_val, 
                     input sel_val, input [31:0] expected, input string test_name);
        tests++;
        pc_plus4 = pc4_val;
        branch_target = branch_val;
        sel = sel_val;
        #10; // Esperar a que se propague
        $display("Test %0d: %s", tests, test_name);
        $display("  PC+4          = 0x%h", pc4_val);
        $display("  Branch Target = 0x%h", branch_val);
        $display("  SEL           = %b (%s)", sel_val, sel_val ? "Branch" : "Sequential");
        $display("  Esperado      = 0x%h", expected);
        $display("  Obtenido      = 0x%h", next_pc);
        if (next_pc !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        pc_plus4 = 0;
        branch_target = 0;
        sel = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion NextPCMux ===");
        $display("========================================\n");
        
        #10;
        
        // Test 1: Ejecución secuencial (sel=0, usa PC+4)
        $display("========== Test 1: Ejecucion secuencial ==========");
        check_result(32'h00000004, 32'h00001000, 1'b0, 32'h00000004, "Secuencial PC+4");
        
        // Test 2: Salto a branch_target (sel=1)
        $display("========== Test 2: Salto a branch target ==========");
        check_result(32'h00000008, 32'h00001000, 1'b1, 32'h00001000, "Branch");
        
        // Test 3: Ejecución secuencial desde dirección típica (sel=0)
        $display("========== Test 3: Ejecucion secuencial 0x104 ==========");
        check_result(32'h00000104, 32'h00002000, 1'b0, 32'h00000104, "Secuencial");
        
        // Test 4: Salto hacia atrás (sel=1)
        $display("========== Test 4: Salto hacia atras (loop) ==========");
        check_result(32'h00000204, 32'h00000100, 1'b1, 32'h00000100, "Branch backward");
        
        // Test 5: Ejecución secuencial con dirección grande (sel=0)
        $display("========== Test 5: Direccion grande secuencial ==========");
        check_result(32'h0FFFFFF4, 32'h00000000, 1'b0, 32'h0FFFFFF4, "Secuencial grande");
        
        // Test 6: Salto a dirección lejana (sel=1)
        $display("========== Test 6: Salto a direccion lejana ==========");
        check_result(32'h00000014, 32'h10000000, 1'b1, 32'h10000000, "Branch far");
        
        // Test 7: Ejecución secuencial con wraparound (sel=0)
        $display("========== Test 7: Wraparound secuencial ==========");
        check_result(32'h00000000, 32'h00000500, 1'b0, 32'h00000000, "Secuencial wraparound");
        
        // Test 8: Salto a dirección 0 (sel=1)
        $display("========== Test 8: Salto a direccion 0 ==========");
        check_result(32'h00000ABC, 32'h00000000, 1'b1, 32'h00000000, "Branch to 0");
        
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