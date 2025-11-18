module DataMemory #(
    parameter ADDR_WIDTH = 10   // 1024 palabras => 4 KB
)(
    input  logic [31:0] Address,
    input  logic [31:0] DataWr,
    input  logic        DMWr,
    input  logic [2:0]  DMCtrl,
    output logic [31:0] DataRd
);

    // Memoria de 32 bits por palabra
    logic [31:0] mem [0:(1<<ADDR_WIDTH)-1];

    // ------------------------------------------------------------
    //                   ESCRITURA (Store)
    // ------------------------------------------------------------
    always_comb begin
        if (DMWr) begin
            case (DMCtrl)
                3'b110: begin  // SB
                    case (Address[1:0])
                        2'b00: mem[Address[31:2]][7:0]   = DataWr[7:0];
                        2'b01: mem[Address[31:2]][15:8]  = DataWr[7:0];
                        2'b10: mem[Address[31:2]][23:16] = DataWr[7:0];
                        2'b11: mem[Address[31:2]][31:24] = DataWr[7:0];
                    endcase
                end

                3'b111: begin  // SH
                    case (Address[1:0])
                        2'b00: mem[Address[31:2]][15:0]  = DataWr[15:0];
                        2'b10: mem[Address[31:2]][31:16] = DataWr[15:0];
                    endcase
                end
                
                3'b011: begin  // SW
                    mem[Address[31:2]] = DataWr;
                end
            endcase
        end
    end

    // ------------------------------------------------------------
    //                      LECTURA (Load)
    // ------------------------------------------------------------
    always_comb begin
        case (DMCtrl)
            3'b000: begin  // LB
                unique case (Address[1:0])
                    2'b00: DataRd = {{24{mem[Address[31:2]][7]}},   mem[Address[31:2]][7:0]};
                    2'b01: DataRd = {{24{mem[Address[31:2]][15]}},  mem[Address[31:2]][15:8]};
                    2'b10: DataRd = {{24{mem[Address[31:2]][23]}},  mem[Address[31:2]][23:16]};
                    2'b11: DataRd = {{24{mem[Address[31:2]][31]}},  mem[Address[31:2]][31:24]};
                endcase
            end

            3'b100: begin  // LBU
                unique case (Address[1:0])
                    2'b00: DataRd = {24'b0, mem[Address[31:2]][7:0]};
                    2'b01: DataRd = {24'b0, mem[Address[31:2]][15:8]};
                    2'b10: DataRd = {24'b0, mem[Address[31:2]][23:16]};
                    2'b11: DataRd = {24'b0, mem[Address[31:2]][31:24]};
                endcase
            end

            3'b001: begin  // LH
                if (Address[1] == 1'b0)
                    DataRd = {{16{mem[Address[31:2]][15]}}, mem[Address[31:2]][15:0]};
                else
                    DataRd = {{16{mem[Address[31:2]][31]}}, mem[Address[31:2]][31:16]};
            end

            3'b101: begin  // LHU
                if (Address[1] == 1'b0)
                    DataRd = {16'b0, mem[Address[31:2]][15:0]};
                else
                    DataRd = {16'b0, mem[Address[31:2]][31:16]};
            end

            3'b010: begin  // LW
                DataRd = mem[Address[31:2]];
            end

            default: DataRd = 32'b0;
        endcase
    end

endmodule
