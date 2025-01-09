`timescale 1ns / 1ps
module MicroController(
    input clk,          // Clock signal
    input rst,          // Reset signal
    output [7:0] PC_out, // Output for Program Counter
    output [7:0] Acc_out, // Output for Accumulator
    output [3:0] SR_out,  // Output for Status Register
    output [7:0] DR_out,  // Output for Data Register
    output [11:0] IR_out  // Output for Instruction Register
);

    // State Definitions
    parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;

    // Internal Registers and Wires
    reg [1:0] current_state, next_state;
    reg [11:0] program_mem[9:0];
    reg load_done;
    reg [7:0] load_addr;
    wire [11:0] load_instr;
    reg [7:0] PC, DR, Acc;
    reg [11:0] IR;
    reg [3:0] SR;
    wire PC_E, Acc_E, SR_E, DR_E, IR_E;
    reg PC_clr, Acc_clr, SR_clr, DR_clr, IR_clr;
    wire [7:0] PC_updated, DR_updated;
    wire [11:0] IR_updated;
    wire [3:0] SR_updated;
    wire PMem_E, DMem_E, DMem_WE, ALU_E, PMem_LE, MUX1_Sel, MUX2_Sel;
    wire [3:0] ALU_Mode;
    wire [7:0] Adder_Out;
    wire [7:0] ALU_Out, ALU_Oper2;

    // Output Assignments
    assign PC_out = PC;
    assign Acc_out = Acc;
    assign SR_out = SR;
    assign DR_out = DR;
    assign IR_out = IR;

    // Initialize Program Memory
    initial begin
        $readmemb("program_mem.dat", program_mem, 0, 9);
    end

    // ALU Module
    ALU ALU_unit (
        .Operand1(Acc),
        .Operand2(ALU_Oper2),
        .E(ALU_E),
        .Mode(ALU_Mode),
        .CFlags(SR),
        .Out(ALU_Out),
        .Flags(SR_updated) // Flags: Z (zero), C (carry), S (sign), O (overflow)
    );

    // MUX2
    MUX1 MUX2_unit (
        .In2(IR[7:0]),
        .In1(DR),
        .Sel(MUX2_Sel),
        .Out(ALU_Oper2)
    );

    // Data Memory
    DMem DMem_unit (
        .clk(clk),
        .E(DMem_E),
        .WE(DMem_WE),
        .Addr(IR[3:0]),
        .DI(ALU_Out),
        .DO(DR_updated)
    );

    // Program Memory
    PMem PMem_unit (
        .clk(clk),
        .E(PMem_E),
        .Addr(PC),
        .I(IR_updated),
        .LE(PMem_LE),
        .LA(load_addr),
        .LI(load_instr)
    );

    // PC Adder
    adder PC_Adder_unit (
        .In(PC),
        .Out(Adder_Out)
    );

    // MUX1
    MUX1 MUX1_unit (
        .In2(IR[7:0]),
        .In1(Adder_Out),
        .Sel(MUX1_Sel),
        .Out(PC_updated)
    );

    // Control Logic
    Control_Logic Control_Logic_Unit (
        .stage(current_state),
        .IR(IR),
        .SR(SR),
        .PC_E(PC_E),
        .Acc_E(Acc_E),
        .SR_E(SR_E),
        .IR_E(IR_E),
        .DR_E(DR_E),
        .PMem_E(PMem_E),
        .DMem_E(DMem_E),
        .DMem_WE(DMem_WE),
        .ALU_E(ALU_E),
        .MUX1_Sel(MUX1_Sel),
        .MUX2_Sel(MUX2_Sel),
        .PMem_LE(PMem_LE),
        .ALU_Mode(ALU_Mode)
    );

    // Load Program Memory
    always @(posedge clk) begin
        if (rst == 1) begin
            load_addr <= 0;
            load_done <= 1'b0;
        end else if (PMem_LE == 1) begin
            load_addr <= load_addr + 8'd1;
            if (load_addr == 8'd9) begin
                load_addr <= 8'd0;
                load_done <= 1'b1;
            end else begin
                load_done <= 1'b0;
            end
        end
    end

    assign load_instr = program_mem[load_addr];

    // State Machine Logic
    always @(posedge clk) begin
        if (rst == 1)
            current_state <= LOAD;
        else
            current_state <= next_state;
    end

    always @(*) begin
        PC_clr = 0;
        Acc_clr = 0;
        SR_clr = 0;
        DR_clr = 0;
        IR_clr = 0;
        case (current_state)
            LOAD: begin
                if (load_done == 1) begin
                    next_state = FETCH;
                    PC_clr = 1;
                    Acc_clr = 1;
                    SR_clr = 1;
                    DR_clr = 1;
                    IR_clr = 1;
                end else
                    next_state = LOAD;
            end
            FETCH: next_state = DECODE;
            DECODE: next_state = EXECUTE;
            EXECUTE: next_state = FETCH;
        endcase
    end

    // Register Updates
    always @(posedge clk) begin
        if (rst == 1) begin
            PC <= 8'd0;
            Acc <= 8'd0;
            SR <= 4'd0;
        end else begin
            if (PC_E) PC <= PC_updated;
            else if (PC_clr) PC <= 8'd0;

            if (Acc_E) Acc <= ALU_Out;
            else if (Acc_clr) Acc <= 8'd0;

            if (SR_E) SR <= SR_updated;
            else if (SR_clr) SR <= 4'd0;
        end
    end

    always @(posedge clk) begin
        if (DR_E) DR <= DR_updated;
        else if (DR_clr) DR <= 8'd0;

        if (IR_E) IR <= IR_updated;
        else if (IR_clr) IR <= 12'd0;
    end
endmodule