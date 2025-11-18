`timescale 1ns/1ps

module DataMemory_tb;

    // Señales del testbench
    logic [31:0] Address;
    logic [31:0] DataWr;
    logic        DMWr;
    logic [2:0]  DMCtrl;
    logic [31:0] DataRd;
    
    // Instancia del módulo bajo prueba
    DataMemory #(.ADDR_WIDTH(10)) uut (
        .Address(Address),
        .DataWr(DataWr),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .DataRd(DataRd)
    );
    
    // Variables para verificación
    logic [31:0] expected;
    integer errors = 0;
    integer tests = 0;

    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);
    end
    
    // Task para verificar resultado
    task check_result(input string test_name, input logic [31:0] exp);
        tests++;
        #1;
        if (DataRd !== exp) begin
            $display("ERROR: %s", test_name);
            $display("   Address:  0x%h", Address);
            $display("   DMCtrl:   0x%h (%03b)", DMCtrl, DMCtrl);
            $display("   Expected: 0x%h (%0d)", exp, exp);
            $display("   Got:      0x%h (%0d)", DataRd, DataRd);
            errors++;
        end else begin
            $display("PASS: %s", test_name);
            $display("   Address: 0x%h, DMCtrl: %03b, DataRd = 0x%h", Address, DMCtrl, DataRd);
        end
        $display("");
    endtask
    
    initial begin
        $display("\n========================================");
        $display("  DataMemory Testbench");
        $display("========================================\n");
        
        // Inicializar señales
        DMWr = 0;
        Address = 0;
        DataWr = 0;
        DMCtrl = 0;
        #10;
        
        // ==================== PRUEBAS DE ESCRITURA Y LECTURA ====================
        
        // Test 1: SW (Store Word) - Escribir palabra completa
        $display("--- Test 1: SW (Store Word) ---");
        Address = 32'h00000000;
        DataWr = 32'hDEADBEEF;
        DMCtrl = 3'b011;  // SW
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LW
        DMCtrl = 3'b010;  // LW
        expected = 32'hDEADBEEF;
        #10 check_result("Test 1: LW after SW", expected);
        
        // Test 2: SB (Store Byte) - Escribir byte en offset 0
        $display("--- Test 2: SB (Store Byte) offset 0 ---");
        Address = 32'h00000004;
        DataWr = 32'h000000AB;
        DMCtrl = 3'b110;  // SB
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LBU
        Address = 32'h00000004;
        DMCtrl = 3'b100;  // LBU
        expected = 32'h000000AB;
        #10 check_result("Test 2: LBU after SB at offset 0", expected);
        
        // Test 3: SB (Store Byte) - Escribir byte en offset 1
        $display("--- Test 3: SB (Store Byte) offset 1 ---");
        Address = 32'h00000005;
        DataWr = 32'h000000CD;
        DMCtrl = 3'b110;  // SB
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LBU
        Address = 32'h00000005;
        DMCtrl = 3'b100;  // LBU
        expected = 32'h000000CD;
        #10 check_result("Test 3: LBU after SB at offset 1", expected);
        
        // Test 4: LB (Load Byte signed) - Byte negativo
        $display("--- Test 4: LB (Load Byte signed) ---");
        Address = 32'h00000008;
        DataWr = 32'h000000FF;  // -1 en complemento a 2
        DMCtrl = 3'b110;  // SB
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LB (debe extender signo)
        Address = 32'h00000008;
        DMCtrl = 3'b000;  // LB
        expected = 32'hFFFFFFFF;  // -1 extendido
        #10 check_result("Test 4: LB signed extension", expected);
        
        // Test 5: SH (Store Halfword) - Escribir halfword en offset 0
        $display("--- Test 5: SH (Store Halfword) offset 0 ---");
        Address = 32'h0000000C;
        DataWr = 32'h00001234;
        DMCtrl = 3'b111;  // SH
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LHU
        Address = 32'h0000000C;
        DMCtrl = 3'b101;  // LHU
        expected = 32'h00001234;
        #10 check_result("Test 5: LHU after SH at offset 0", expected);
        
        // Test 6: SH (Store Halfword) - Escribir halfword en offset 2
        $display("--- Test 6: SH (Store Halfword) offset 2 ---");
        Address = 32'h0000000E;
        DataWr = 32'h00005678;
        DMCtrl = 3'b111;  // SH
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LHU
        Address = 32'h0000000E;
        DMCtrl = 3'b101;  // LHU
        expected = 32'h00005678;
        #10 check_result("Test 6: LHU after SH at offset 2", expected);
        
        // Test 7: LH (Load Halfword signed) - Halfword negativo
        $display("--- Test 7: LH (Load Halfword signed) ---");
        Address = 32'h00000010;
        DataWr = 32'h0000FFFF;  // -1 en 16 bits
        DMCtrl = 3'b111;  // SH
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        // Leer con LH (debe extender signo)
        Address = 32'h00000010;
        DMCtrl = 3'b001;  // LH
        expected = 32'hFFFFFFFF;  // -1 extendido
        #10 check_result("Test 7: LH signed extension", expected);
        
        // Test 8: Verificar escritura completa de palabra con múltiples bytes
        $display("--- Test 8: Multiple byte writes forming a word ---");
        Address = 32'h00000014;
        DataWr = 32'h000000AA;
        DMCtrl = 3'b110;  // SB
        DMWr = 1;
        #10;
        Address = 32'h00000015;
        DataWr = 32'h000000BB;
        #10;
        Address = 32'h00000016;
        DataWr = 32'h000000CC;
        #10;
        Address = 32'h00000017;
        DataWr = 32'h000000DD;
        #10;
        DMWr = 0;
        #10;
        // Leer palabra completa
        Address = 32'h00000014;
        DMCtrl = 3'b010;  // LW
        expected = 32'hDDCCBBAA;  // Little-endian
        #10 check_result("Test 8: LW after multiple SB", expected);
        
        // ==================== RESUMEN ====================
        $display("========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("Total tests: %0d", tests);
        $display("Passed:      %0d", tests - errors);
        $display("Failed:      %0d", errors);
        
        if (errors == 0) begin
            $display("\nALL TESTS PASSED");
        end else begin
            $display("\nSOME TESTS FAILED");
        end
        $display("========================================\n");
        
        $finish;
    end

endmodule