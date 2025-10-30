module ALUBSrcMux_tb;
    // Señales del testbench
    logic signed [31:0] ru_rs2;
    logic signed [31:0] Imm_ext;
    logic sel;
    logic signed [31:0] b;
    
    // Instanciar el DUT
    ALUBSrcMux dut (
        .ru_rs2(ru_rs2),
        .Imm_ext(Imm_ext),
        .sel(sel),
        .b(b)
    );
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/ALUBSrcMux_tb.vcd");
        $dumpvars(0, ALUBSrcMux_tb);
    end
    
    // Tarea para verificar resultado
    task check_result(input [31:0] rs2_val, input [31:0] imm_val, 
                     input sel_val, input [31:0] expected, input string test_name);
        tests++;
        ru_rs2 = rs2_val;
        Imm_ext = imm_val;
        sel = sel_val;
        #10; // Esperar a que se propague
        $display("Test %0d: %s", tests, test_name);
        $display("  ru_rs2   = 0x%h", rs2_val);
        $display("  Imm_ext  = 0x%h", imm_val);
        $display("  SEL      = %b (%s)", sel_val, sel_val ? "Imm_ext" : "ru_rs2");
        $display("  Esperado = 0x%h", expected);
        $display("  Obtenido = 0x%h", b);
        if (b !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        ru_rs2 = 0;
        Imm_ext = 0;
        sel = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion ALUBSrcMux ===");
        $display("========================================\n");
        
        #10;
        
        // Test 1: Seleccionar ru_rs2 (sel=0)
        $display("========== Test 1: Seleccionar ru_rs2 ==========");
        check_result(32'h00000014, 32'h00000064, 1'b0, 32'h00000014, "Usar ru_rs2");
        
        // Test 2: Seleccionar Imm_ext (sel=1)
        $display("========== Test 2: Seleccionar Imm_ext ==========");
        check_result(32'h00000014, 32'h00000064, 1'b1, 32'h00000064, "Usar Imm_ext");
        
        // Test 3: Seleccionar ru_rs2 con valor negativo (sel=0)
        $display("========== Test 3: ru_rs2 negativo ==========");
        check_result(32'hFFFFFFE0, 32'h00000010, 1'b0, 32'hFFFFFFE0, "Usar ru_rs2 negativo");
        
        // Test 4: Seleccionar Imm_ext con valor negativo (sel=1)
        $display("========== Test 4: Imm_ext negativo ==========");
        check_result(32'h00000050, 32'hFFFFFFF0, 1'b1, 32'hFFFFFFF0, "Usar Imm_ext negativo");
        
        // Test 5: Seleccionar ru_rs2 con valor grande (sel=0)
        $display("========== Test 5: ru_rs2 valor grande ==========");
        check_result(32'h7FFFFFFF, 32'h00000001, 1'b0, 32'h7FFFFFFF, "Usar ru_rs2 grande");
        
        // Test 6: Seleccionar Imm_ext con offset grande (sel=1)
        $display("========== Test 6: Imm_ext offset grande ==========");
        check_result(32'h00000100, 32'h00000FFF, 1'b1, 32'h00000FFF, "Usar Imm_ext grande");
        
        // Test 7: Seleccionar ru_rs2 con cero (sel=0)
        $display("========== Test 7: ru_rs2 cero ==========");
        check_result(32'h00000000, 32'h00000020, 1'b0, 32'h00000000, "Usar ru_rs2 cero");
        
        // Test 8: Seleccionar Imm_ext con cero (sel=1)
        $display("========== Test 8: Imm_ext cero ==========");
        check_result(32'h00000ABC, 32'h00000000, 1'b1, 32'h00000000, "Usar Imm_ext cero");
        
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