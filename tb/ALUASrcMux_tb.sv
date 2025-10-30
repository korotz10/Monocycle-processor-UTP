module ALUASrcMux_tb;
    // Señales del testbench
    logic signed [31:0] ru_rs1;
    logic signed [31:0] pc;
    logic sel;
    logic signed [31:0] a;
    
    // Instanciar el DUT
    ALUASrcMux dut (
        .ru_rs1(ru_rs1),
        .pc(pc),
        .sel(sel),
        .a(a)
    );
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/ALUASrcMux_tb.vcd");
        $dumpvars(0, ALUASrcMux_tb);
    end
    
    // Tarea para verificar resultado
    task check_result(input [31:0] rs1_val, input [31:0] pc_val, 
                     input sel_val, input [31:0] expected, input string test_name);
        tests++;
        ru_rs1 = rs1_val;
        pc = pc_val;
        sel = sel_val;
        #10; // Esperar a que se propague
        $display("Test %0d: %s", tests, test_name);
        $display("  ru_rs1   = 0x%h", rs1_val);
        $display("  pc       = 0x%h", pc_val);
        $display("  SEL      = %b (%s)", sel_val, sel_val ? "PC" : "ru_rs1");
        $display("  Esperado = 0x%h", expected);
        $display("  Obtenido = 0x%h", a);
        if (a !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        ru_rs1 = 0;
        pc = 0;
        sel = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion ALUASrcMux ===");
        $display("========================================\n");
        
        #10;
        
        // Test 1: Seleccionar ru_rs1 (sel=0)
        $display("========== Test 1: Seleccionar ru_rs1 ==========");
        check_result(32'h0000000A, 32'h00000100, 1'b0, 32'h0000000A, "Usar ru_rs1");
        
        // Test 2: Seleccionar pc (sel=1)
        $display("========== Test 2: Seleccionar pc ==========");
        check_result(32'h0000000A, 32'h00000100, 1'b1, 32'h00000100, "Usar pc");
        
        // Test 3: Seleccionar ru_rs1 con valor negativo (sel=0)
        $display("========== Test 3: ru_rs1 negativo ==========");
        check_result(32'hFFFFFFF0, 32'h00000200, 1'b0, 32'hFFFFFFF0, "Usar ru_rs1 negativo");
        
        // Test 4: Seleccionar pc con valor típico (sel=1)
        $display("========== Test 4: pc valor tipico ==========");
        check_result(32'h00000050, 32'h00001000, 1'b1, 32'h00001000, "Usar pc tipico");
        
        // Test 5: Seleccionar ru_rs1 con valor grande (sel=0)
        $display("========== Test 5: ru_rs1 valor grande ==========");
        check_result(32'h7FFFFFFF, 32'h00000004, 1'b0, 32'h7FFFFFFF, "Usar ru_rs1 grande");
        
        // Test 6: Seleccionar pc con valor grande (sel=1)
        $display("========== Test 6: pc valor grande ==========");
        check_result(32'h00000020, 32'h0FFFFFF0, 1'b1, 32'h0FFFFFF0, "Usar pc grande");
        
        // Test 7: Seleccionar ru_rs1 con cero (sel=0)
        $display("========== Test 7: ru_rs1 cero ==========");
        check_result(32'h00000000, 32'h00000500, 1'b0, 32'h00000000, "Usar ru_rs1 cero");
        
        // Test 8: Seleccionar pc desde inicio (sel=1)
        $display("========== Test 8: pc desde inicio ==========");
        check_result(32'h12345678, 32'h00000000, 1'b1, 32'h00000000, "Usar pc cero");
        
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