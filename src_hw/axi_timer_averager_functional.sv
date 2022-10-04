`timescale 1ns / 1ps


module axi_timer_averager_functional (
    input  logic        CLK            ,
    input  logic        RESET          ,
    input  logic        START_TIMER    ,
    input  logic        STOP_TIMER     ,
    input  logic        AVG_MSMT_ENABLE,
    input  logic [ 4:0] AVG_MSMT_LIMIT ,
    output logic [31:0] MSMT_VALUE     ,
    output logic        MSMT_VALID     ,
    output logic [63:0] AVG_MSMT_VALUE ,
    output logic [31:0] MSMT_COUNT  
);


    logic d_start_timer = 1'b0;
    logic start_event   = 1'b0;

    logic d_stop_timer = 1'b0;
    logic stop_event   = 1'b0;

    typedef enum {
        IDLE_ST , 
        MSMT_ST 
    } fsm;

    logic [31:0] measurement_value = '{default:0};

    fsm current_state = IDLE_ST;

    logic [31:0] avg_msmt_count = '{default:0};
    logic [31:0] avg_msmt_limit = '{default:0};

    logic [63:0] avg_msmt_value         = '{default:0};
    logic [63:0] avg_msmt_value_shifted = '{default:0};
    logic        avg_msmt_value_valid   = 1'b0        ;

    logic [0:31][31:0] avg_msmt_limit_rom = '{
        32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008,
        32'h00000010, 32'h00000020, 32'h00000040, 32'h00000080,
        32'h00000100, 32'h00000200, 32'h00000400, 32'h00000800,
        32'h00001000, 32'h00002000, 32'h00004000, 32'h00008000,
        32'h00010000, 32'h00020000, 32'h00040000, 32'h00080000,
        32'h00100000, 32'h00200000, 32'h00400000, 32'h00800000,
        32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000,
        32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000 
    };



    logic d_avg_msmt_enable = 1'b0;
    logic avg_msmt_event = 1'b0;



    always_ff @(posedge CLK) begin : MSMT_COUNT_processing  
        MSMT_COUNT = avg_msmt_count + 1;
    end 



    always_comb begin 
        MSMT_VALUE = measurement_value;
    end 



    always_ff @(posedge CLK) begin 
        d_start_timer <= START_TIMER ;
    end 



    always_ff @(posedge CLK) begin 
        if (!d_start_timer & START_TIMER) begin 
            start_event <= 1'b1;
        end else begin 
            start_event <= 1'b0;
        end 
    end 



    always_ff @(posedge CLK) begin 
        d_stop_timer <= STOP_TIMER;
    end 



    always_ff @(posedge CLK) begin 
        if (!d_stop_timer & STOP_TIMER) begin 
            stop_event <= 1'b1;
        end else begin 
            stop_event <= 1'b0;
        end 
    end 



    always_ff @(posedge CLK) begin : current_state_processing 
        if (RESET) begin 
            current_state <= IDLE_ST;
        end else begin 
            case (current_state)
                IDLE_ST : 
                    if (start_event) begin 
                        current_state <= MSMT_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                MSMT_ST : 
                    if (stop_event) begin 
                        current_state <= IDLE_ST;
                    end else begin 
                        current_state <= current_state;
                    end 

                default : 
                    current_state <= current_state;

            endcase // current_state
        end 
    end 



    always_ff @(posedge CLK) begin : measurement_value_processing 
        case (current_state)
            MSMT_ST : 
                measurement_value <= measurement_value + 1;

            default : 
                measurement_value <= '{default:0};

        endcase // current_state
    end 



    always_ff @(posedge CLK) begin : MSMT_VALID_processing 
        case (current_state) 
            MSMT_ST : 
                if (stop_event) begin 
                    MSMT_VALID <= 1'b1;
                end else begin 
                    MSMT_VALID <= 1'b0;
                end 

            default : 
                MSMT_VALID <= 1'b0;

        endcase // current_state
    end 



    always_ff @(posedge CLK) begin : avg_msmt_count_processing 
        if ((avg_msmt_count == avg_msmt_limit) | !AVG_MSMT_ENABLE) begin 
            avg_msmt_count <= '{default:0};
        end else begin 
            if (MSMT_VALID) begin 
                avg_msmt_count <= avg_msmt_count + 1;
            end else begin 
                avg_msmt_count <= avg_msmt_count;
            end 
        end 
    end 



    always_ff @(posedge CLK) begin : d_avg_msmt_enable_processing 
        d_avg_msmt_enable <= AVG_MSMT_ENABLE;
    end 



    always_ff @(posedge CLK) begin 
        if (AVG_MSMT_ENABLE & !d_avg_msmt_enable) begin 
            avg_msmt_event <= 1'b1;
        end else begin 
            avg_msmt_event <= 1'b0;
        end 
    end 



    always_ff @(posedge CLK) begin : avg_msmt_limit_processing 
        if (avg_msmt_event) begin 
            avg_msmt_limit <= avg_msmt_limit_rom[AVG_MSMT_LIMIT];
        end else begin 
            avg_msmt_limit <= avg_msmt_limit;
        end 
    end 



    always_ff @(posedge CLK) begin : avg_msmt_value_processing 
        if (avg_msmt_limit == avg_msmt_count) begin 
            avg_msmt_value <= '{default:0};
        end else begin 
            if (AVG_MSMT_ENABLE) begin 
                if (MSMT_VALID) begin 
                        avg_msmt_value <= avg_msmt_value + measurement_value;
                end else begin 
                    avg_msmt_value <= avg_msmt_value;
                end 
            end else begin 
                avg_msmt_value <= '{default:0};
            end 
        end 
    end 



    always_ff @(posedge CLK) begin : avg_msmt_value_shifted_processing 
        case (AVG_MSMT_LIMIT) 
            8'h00   : avg_msmt_value_shifted <= avg_msmt_value[63:0];
            8'h01   : avg_msmt_value_shifted <= avg_msmt_value[63:1];
            8'h02   : avg_msmt_value_shifted <= avg_msmt_value[63:2];
            8'h03   : avg_msmt_value_shifted <= avg_msmt_value[63:3];
            8'h04   : avg_msmt_value_shifted <= avg_msmt_value[63:4];
            8'h05   : avg_msmt_value_shifted <= avg_msmt_value[63:5];
            8'h06   : avg_msmt_value_shifted <= avg_msmt_value[63:6];
            8'h07   : avg_msmt_value_shifted <= avg_msmt_value[63:7];
            8'h08   : avg_msmt_value_shifted <= avg_msmt_value[63:8];
            8'h09   : avg_msmt_value_shifted <= avg_msmt_value[63:9];
            8'h0a   : avg_msmt_value_shifted <= avg_msmt_value[63:10];
            8'h0b   : avg_msmt_value_shifted <= avg_msmt_value[63:11];
            8'h0c   : avg_msmt_value_shifted <= avg_msmt_value[63:12];
            8'h0d   : avg_msmt_value_shifted <= avg_msmt_value[63:13];
            8'h0e   : avg_msmt_value_shifted <= avg_msmt_value[63:14];
            8'h0f   : avg_msmt_value_shifted <= avg_msmt_value[63:15];
            8'h10   : avg_msmt_value_shifted <= avg_msmt_value[63:16];
            8'h11   : avg_msmt_value_shifted <= avg_msmt_value[63:17];
            8'h12   : avg_msmt_value_shifted <= avg_msmt_value[63:18];
            8'h13   : avg_msmt_value_shifted <= avg_msmt_value[63:19];
            8'h14   : avg_msmt_value_shifted <= avg_msmt_value[63:20];
            8'h15   : avg_msmt_value_shifted <= avg_msmt_value[63:21];
            8'h16   : avg_msmt_value_shifted <= avg_msmt_value[63:22];
            8'h17   : avg_msmt_value_shifted <= avg_msmt_value[63:23];
            8'h18   : avg_msmt_value_shifted <= avg_msmt_value[63:24];
            8'h19   : avg_msmt_value_shifted <= avg_msmt_value[63:25];
            8'h1a   : avg_msmt_value_shifted <= avg_msmt_value[63:26];
            8'h1b   : avg_msmt_value_shifted <= avg_msmt_value[63:27];
            8'h1c   : avg_msmt_value_shifted <= avg_msmt_value[63:28];
            8'h1d   : avg_msmt_value_shifted <= avg_msmt_value[63:29];
            8'h1e   : avg_msmt_value_shifted <= avg_msmt_value[63:30];
            8'h1f   : avg_msmt_value_shifted <= avg_msmt_value[63:31];
            default : avg_msmt_value_shifted <= avg_msmt_value[63:31];
        endcase // current_state
    end 



    always_ff @(posedge CLK) begin : avg_msmt_value_valid_processing 
        if (avg_msmt_count == avg_msmt_limit) begin 
            avg_msmt_value_valid <= 1'b1;
        end else begin 
            avg_msmt_value_valid <= 1'b0;
        end 
    end


    always_ff @(posedge CLK) begin 
        if (avg_msmt_value_valid) begin 
            AVG_MSMT_VALUE <= avg_msmt_value_shifted;
        end else begin 
            AVG_MSMT_VALUE <= AVG_MSMT_VALUE;
        end 
    end 


endmodule