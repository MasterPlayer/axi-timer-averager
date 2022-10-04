`timescale 1 ns / 1 ps



module axi_timer_averager #(
    parameter integer DEFAULT_SAMPLES_SERIE = 2,
    parameter integer S_AXI_LITE_DATA_WIDTH = 32  ,
    parameter integer S_AXI_LITE_ADDR_WIDTH = 32
) (
    input  logic                                 CLK               ,
    input  logic                                 RESETN            ,
    // configuration bank address
    input  logic [    S_AXI_LITE_ADDR_WIDTH-1:0] S_AXI_LITE_AWADDR ,
    input  logic [                          2:0] S_AXI_LITE_AWPROT ,
    input  logic                                 S_AXI_LITE_AWVALID,
    output logic                                 S_AXI_LITE_AWREADY,
    input  logic [    S_AXI_LITE_DATA_WIDTH-1:0] S_AXI_LITE_WDATA  ,
    input  logic [(S_AXI_LITE_DATA_WIDTH/8)-1:0] S_AXI_LITE_WSTRB  ,
    input  logic                                 S_AXI_LITE_WVALID ,
    output logic                                 S_AXI_LITE_WREADY ,
    output logic [                          1:0] S_AXI_LITE_BRESP  ,
    output logic                                 S_AXI_LITE_BVALID ,
    input  logic                                 S_AXI_LITE_BREADY ,
    input  logic [    S_AXI_LITE_ADDR_WIDTH-1:0] S_AXI_LITE_ARADDR ,
    input  logic [                          2:0] S_AXI_LITE_ARPROT ,
    input  logic                                 S_AXI_LITE_ARVALID,
    output logic                                 S_AXI_LITE_ARREADY,
    output logic [    S_AXI_LITE_DATA_WIDTH-1:0] S_AXI_LITE_RDATA  ,
    output logic [                          1:0] S_AXI_LITE_RRESP  ,
    output logic                                 S_AXI_LITE_RVALID ,
    input  logic                                 S_AXI_LITE_RREADY ,
    output logic [                         31:0] MSMT_VALUE        ,
    output logic                                 MSMT_VALID        ,
    // interrupt signals to component/from component
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY EDGE_RISING" *)
    input  logic                                 INTR
);


    logic [S_AXI_LITE_ADDR_WIDTH-1:0] axi_awaddr ;
    logic                             axi_awready;
    logic                             axi_wready ;
    logic [                      1:0] axi_bresp  ;
    logic                             axi_bvalid ;
    logic [S_AXI_LITE_ADDR_WIDTH-1:0] axi_araddr ;
    logic                             axi_arready;
    logic [S_AXI_LITE_DATA_WIDTH-1:0] axi_rdata  ;
    logic [                      1:0] axi_rresp  ;
    logic                             axi_rvalid ;



    localparam integer ADDR_LSB          = (S_AXI_LITE_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 5                             ;


    (* dont_touch="true" *)logic [                         15:0][S_AXI_LITE_DATA_WIDTH-1:0] register     = '{default:'{default:0}};
    (* dont_touch="true" *)logic                                                            slv_reg_rden                          ;
    (* dont_touch="true" *)logic                                                            slv_reg_wren                          ;
    (* dont_touch="true" *)logic [S_AXI_LITE_DATA_WIDTH-1:0]                                reg_data_out                          ;
    (* dont_touch="true" *)logic                                                            aw_en                                 ;



    logic        start_timer       ;
    logic        stop_timer        ;
    logic        avg_msmt_enable   ;
    logic [ 4:0] avg_msmt_limit    ;
    logic [31:0] msmt_count_reg    ;
    logic [63:0] avg_msmt_value_reg;



    always_comb begin : S_AXI_LITE_processing 
        S_AXI_LITE_AWREADY = axi_awready;
        S_AXI_LITE_WREADY  = axi_wready;
        S_AXI_LITE_BRESP   = axi_bresp;
        S_AXI_LITE_BVALID  = axi_bvalid;
        S_AXI_LITE_ARREADY = axi_arready;
        S_AXI_LITE_RDATA   = axi_rdata;
        S_AXI_LITE_RRESP   = axi_rresp;
    end 



    always_ff @( posedge CLK ) begin : S_AXI_LITE_RVALID_proc
        
        S_AXI_LITE_RVALID <= axi_rvalid;
    end 




    always_ff @( posedge CLK ) begin : axi_awready_proc
        if (~RESETN)
            axi_awready <= 1'b0;
        else    
            if (~axi_awready & S_AXI_LITE_AWVALID & S_AXI_LITE_WVALID & aw_en)
                axi_awready <= 1'b1;
            else 
                if (S_AXI_LITE_BREADY & axi_bvalid)
                    axi_awready <= 1'b0;
                else
                    axi_awready <= 1'b0;
    end       


    always_ff @( posedge CLK ) begin : aw_en_proc
        if (~RESETN)
            aw_en <= 1'b1;
        else
            if (~axi_awready & S_AXI_LITE_AWVALID & S_AXI_LITE_WVALID & aw_en)
                aw_en <= 1'b0;
            else 
                if (S_AXI_LITE_BREADY & axi_bvalid)
                    aw_en <= 1'b1;
    end       



    always_ff @( posedge CLK ) begin : axi_awaddr_proc
        if (~RESETN)
            axi_awaddr <= '{default:0};
        else
            if (~axi_awready & S_AXI_LITE_AWVALID & S_AXI_LITE_WVALID & aw_en)
                axi_awaddr <= S_AXI_LITE_AWADDR;
    end       



    always_ff @( posedge CLK ) begin : axi_wready_proc
        if (~RESETN)
            axi_wready <= 1'b0;
        else    
            if (~axi_wready & S_AXI_LITE_WVALID & S_AXI_LITE_AWVALID & aw_en )
                axi_wready <= 1'b1;
            else
                axi_wready <= 1'b0;
    end       

    

    always_comb begin : slv_reg_wren_processing  

        slv_reg_wren = axi_wready & S_AXI_LITE_WVALID & axi_awready & S_AXI_LITE_AWVALID;
    end





    always_ff @( posedge CLK ) begin : axi_bvalid_proc
        if (~RESETN)
            axi_bvalid  <= 1'b0;
        else
            if (axi_awready & S_AXI_LITE_AWVALID & ~axi_bvalid & axi_wready & S_AXI_LITE_WVALID)
                axi_bvalid <= 1'b1;
            else
                if (S_AXI_LITE_BREADY & axi_bvalid)
                    axi_bvalid <= 1'b0; 
    end   



    always_ff @( posedge CLK ) begin : axi_bresp_proc
        if (~RESETN)
            axi_bresp   <= 2'b0;
        else
            if (axi_awready & S_AXI_LITE_AWVALID & ~axi_bvalid & axi_wready & S_AXI_LITE_WVALID)
                axi_bresp  <= 2'b0; // 'OKAY' response 
    end   



    always_ff @( posedge CLK ) begin : axi_arready_proc
        if (~RESETN)
            axi_arready <= 1'b0;
        else    
            if (~axi_arready & S_AXI_LITE_ARVALID)
                axi_arready <= 1'b1;
            else
                axi_arready <= 1'b0;
    end       


    always_ff @( posedge CLK ) begin : axi_araddr_proc
        if (~RESETN)
            axi_araddr  <= 32'b0;
        else    
            if (~axi_arready & S_AXI_LITE_ARVALID)
                axi_araddr  <= S_AXI_LITE_ARADDR;
            
    end       



    always_ff @( posedge CLK ) begin : axi_rvalid_proc
        if (~RESETN)
            axi_rvalid <= 1'b0;
        else
            if (axi_arready & S_AXI_LITE_ARVALID & ~axi_rvalid)
                axi_rvalid <= 1'b1;
            else 
                if (axi_rvalid & S_AXI_LITE_RREADY)
                    axi_rvalid <= 1'b0;
    end    



    always_ff @( posedge CLK ) begin : axi_rresp_proc
        if (~RESETN)
            axi_rresp  <= '{default:0};
        else
            if (axi_arready & S_AXI_LITE_ARVALID & ~axi_rvalid)
                axi_rresp  <= 2'b0; // 'OKAY' response             
        
    end    



    always_ff @(posedge CLK) begin : slv_reg_rden_proc

        slv_reg_rden <= axi_arready & S_AXI_LITE_ARVALID & ~axi_rvalid;
    end 



    always_ff @(posedge CLK) begin
        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            8'h00   : reg_data_out <= {31'b0, stop_timer};
            8'h01   : reg_data_out <= {16'b0, 3'b0, avg_msmt_limit, 7'b0, avg_msmt_enable};
            8'h02   : reg_data_out <= avg_msmt_value_reg[31:0];
            8'h03   : reg_data_out <= avg_msmt_value_reg[63:32];
            8'h04   : reg_data_out <= msmt_count_reg[31:0];
            default : reg_data_out <= '{default:0};
        endcase
    end



    always_ff @(posedge CLK) begin
        if (slv_reg_rden)
            axi_rdata <= reg_data_out;     // register read data
    end    




    always_ff @(posedge CLK) begin : stop_timer_processing 
        if (~RESETN) begin 
            stop_timer <= 1'b0;
        end else begin 
            if (slv_reg_wren) begin 
                if (axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB] == 0) begin 
                    if (S_AXI_LITE_WSTRB[0]) begin 
                        stop_timer <= S_AXI_LITE_WDATA[0];
                    end else begin 
                        stop_timer <= 1'b0;
                    end 
                end else begin 
                    stop_timer <= 1'b0;
                end 
            end else begin 
                stop_timer <= 1'b0;
            end 

        end 
    end 



    always_ff @(posedge CLK) begin : avg_msmt_enable_processing 
        if (~RESETN) begin 
            avg_msmt_enable <= 1'b0;
        end else begin 
            if (slv_reg_wren) begin 
                if (axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB] == 1) begin 
                    if (S_AXI_LITE_WSTRB[0]) begin 
                        avg_msmt_enable <= S_AXI_LITE_WDATA[0];
                    end else begin 
                        avg_msmt_enable <= avg_msmt_enable;
                    end 
                end else begin 
                    avg_msmt_enable <= avg_msmt_enable;
                end 
            end else begin 
                avg_msmt_enable <= avg_msmt_enable;
            end 

        end 
    end 



    always_ff @(posedge CLK) begin : avg_msmt_limit_processing 
        if (~RESETN) begin 
            avg_msmt_limit <= DEFAULT_SAMPLES_SERIE;
        end else begin 
            if (slv_reg_wren) begin 
                if (axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB] == 1) begin 
                    if (S_AXI_LITE_WSTRB[1]) begin 
                        avg_msmt_limit <= S_AXI_LITE_WDATA[12:8];
                    end else begin 
                        avg_msmt_limit <= avg_msmt_limit;
                    end 
                end else begin 
                    avg_msmt_limit <= avg_msmt_limit;
                end 
            end else begin 
                avg_msmt_limit <= avg_msmt_limit;
            end 

        end 
    end 



    always_ff @(posedge CLK) begin : start_timer_processing 
        start_timer <= INTR;
    end 



    axi_timer_averager_functional axi_timer_averager_functional_inst (
        .CLK            (CLK               ),
        .RESET          (~RESETN           ),
        .START_TIMER    (start_timer       ),
        .STOP_TIMER     (stop_timer        ),
        .AVG_MSMT_ENABLE(avg_msmt_enable   ),
        .AVG_MSMT_LIMIT (avg_msmt_limit    ),
        .MSMT_VALUE     (MSMT_VALUE        ),
        .MSMT_VALID     (MSMT_VALID        ),
        .AVG_MSMT_VALUE (avg_msmt_value_reg),
        .MSMT_COUNT     (msmt_count_reg    )
    );


endmodule
