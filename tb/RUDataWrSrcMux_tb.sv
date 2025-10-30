module RUDataWrSrcMux_tb;
    // Señales del testbench
    logic signed [31:0] alu_result;
    logic signed [31:0] data_mem_rd;
    logic signed [31:0] adder_result;
    logic signed [1:0] sel;
    logic signed [31:0] ru_wrdata;
    
    // Instanciar el DUT
    RUDataWrSrcMux dut (
        .alu_result(alu_result),
        .data_mem_rd(data_mem_rd),
        .adder_result(adder_result),
        .sel(sel),
        .ru_wrdata(ru_wrdata)
    );
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/RUDataWrSrcMux_tb.vcd");
        $dumpvars(0, RUDataWrSrcMux_tb);
    end
    
    // Tarea para verificar resultado
    task check_result(input [31:0] alu_val, input [31:0] mem_val, 
                     input [31:0] adder_val, input [1:0] sel_val,
                     input [31:0] expected, input string test_name);
        tests++;
        alu_result = alu_val;
        data_mem_rd = mem_val;
        adder_result = adder_val;
        sel = sel_val;
        #10; // Esperar a que se propague
        $display("Test %0d: %s", tests, test_name);
        $display("  alu_result    = 0x%h", alu_val);
        $display("  data_mem_rd   = 0x%h", mem_val);
        $display("  adder_result  = 0x%h", adder_val);
        $display("  SEL           = %b (%s)", sel_val, 
                 sel_val == 2'b10 ? "adder_result" : 
                 sel_val == 2'b01 ? "data_mem_rd" : "alu_result");
        $display("  Esperado      = 0x%h", expected);
        $display("  Obtenido      = 0x%h", ru_wrdata);
        if (ru_wrdata !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        alu_result = 0;
        data_mem_rd = 0;
        adder_result = 0;
        sel = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion RUDataWrSrcMux ===");
        $display("========================================\n");
        
        #10;
        
        // Test 1: Seleccionar alu_result (sel=00)
        $display("========== Test 1: Seleccionar alu_result (sel=00) ==========");
        check_result(32'h0000002A, 32'h00000064, 32'h00000100, 2'b00, 
                    32'h0000002A, "Usar alu_result");
        
        // Test 2: Seleccionar data_mem_rd (sel=01)
        $display("========== Test 2: Seleccionar data_mem_rd (sel=01) ==========");
        check_result(32'h0000002A, 32'h00000064, 32'h00000100, 2'b01, 
                    32'h00000064, "Usar data_mem_rd");
        
        // Test 3: Seleccionar adder_result (sel=10)
        $display("========== Test 3: Seleccionar adder_result (sel=10) ==========");
        check_result(32'h0000002A, 32'h00000064, 32'h00000100, 2'b10, 
                    32'h00000100, "Usar adder_result");
        
        // Test 4: Seleccionar alu_result con sel=11 (default)
        $display("========== Test 4: sel=11 debe usar alu_result (default) ==========");
        check_result(32'h12345678, 32'hABCDEF00, 32'hDEADBEEF, 2'b11, 
                    32'h12345678, "Default a alu_result");
        
        // Test 5: data_mem_rd con valor negativo (sel=01)
        $display("========== Test 5: data_mem_rd negativo ==========");
        check_result(32'h00000050, 32'hFFFFFFF0, 32'h00000200, 2'b01, 
                    32'hFFFFFFF0, "Usar data_mem_rd negativo");
        
        // Test 6: adder_result con PC+4 típico (sel=10)
        $display("========== Test 6: adder_result PC+4 ==========");
        check_result(32'h00000000, 32'h00000000, 32'h00000104, 2'b10, 
                    32'h00000104, "Usar adder_result PC+4");
        
        // Test 7: alu_result con valor grande (sel=00)
        $display("========== Test 7: alu_result valor grande ==========");
        check_result(32'h7FFFFFFF, 32'h00001000, 32'h00002000, 2'b00, 
                    32'h7FFFFFFF, "Usar alu_result grande");
        
        // Test 8: Todos cero con sel=01
        $display("========== Test 8: Todos cero, seleccionar data_mem_rd ==========");
        check_result(32'h00000000, 32'h00000000, 32'h00000000, 2'b01, 
                    32'h00000000, "Todos cero");
        
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