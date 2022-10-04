library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;


entity axi_timer_averager_vhd is
   generic (
        DEFAULT_SAMPLES_SERIE : integer  := 1000                                                                                            ;
        S_AXI_LITE_DATA_WIDTH : integer  := 32                                                                                              ;
        S_AXI_LITE_ADDR_WIDTH : integer  := 32   
    ); 
    port (
        CLK                   : in  std_logic                                                                                              ;
        RESETN                : in  std_logic                                                                                              ;
        S_AXI_LITE_AWADDR     : in  std_logic_vector (     S_AXI_LITE_ADDR_WIDTH-1 downto 0 )                                              ;
        S_AXI_LITE_AWPROT     : in  std_logic_vector (                           2 downto 0 )                                              ;
        S_AXI_LITE_AWVALID    : in  std_logic                                                                                              ;
        S_AXI_LITE_AWREADY    : out std_logic                                                                                              ;
        S_AXI_LITE_WDATA      : in  std_logic_vector (     S_AXI_LITE_DATA_WIDTH-1 downto 0 )                                              ;
        S_AXI_LITE_WSTRB      : in  std_logic_vector ( (S_AXI_LITE_DATA_WIDTH/8)-1 downto 0 )                                              ;
        S_AXI_LITE_WVALID     : in  std_logic                                                                                              ;
        S_AXI_LITE_WREADY     : out std_logic                                                                                              ;
        S_AXI_LITE_BRESP      : out std_logic_vector (                           1 downto 0 )                                              ;
        S_AXI_LITE_BVALID     : out std_logic                                                                                              ;
        S_AXI_LITE_BREADY     : in  std_logic                                                                                              ;
        S_AXI_LITE_ARADDR     : in  std_logic_vector (     S_AXI_LITE_ADDR_WIDTH-1 downto 0 )                                              ;
        S_AXI_LITE_ARPROT     : in  std_logic_vector (                           2 downto 0 )                                              ;
        S_AXI_LITE_ARVALID    : in  std_logic                                                                                              ;
        S_AXI_LITE_ARREADY    : out std_logic                                                                                              ;
        S_AXI_LITE_RDATA      : out std_logic_vector (     S_AXI_LITE_DATA_WIDTH-1 downto 0 )                                              ;
        S_AXI_LITE_RRESP      : out std_logic_vector (                           1 downto 0 )                                              ;
        S_AXI_LITE_RVALID     : out std_logic                                                                                              ;
        S_AXI_LITE_RREADY     : in  std_logic                                                                                              ;
        MSMT_VALUE            : out std_logic_vector (                          31 downto 0 )                                              ;
        MSMT_VALID            : out std_logic                                                                                              ;
        INTR                  : in  std_logic                                                                                               
    );
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_INFO of INTR: SIGNAL is "xilinx.com:signal:interrupt:1.0 INTR INTERRUPT";
    ATTRIBUTE X_INTERFACE_PARAMETER of INTR: SIGNAL is "SENSITIVITY EDGE_RISING";

end axi_timer_averager_vhd;



architecture axi_timer_averager_vhd_arch of axi_timer_averager_vhd is

    component axi_timer_averager 
        generic (
            DEFAULT_SAMPLES_SERIE : integer  := 1000;
            S_AXI_LITE_DATA_WIDTH : integer  := 32  ;
            S_AXI_LITE_ADDR_WIDTH : integer  := 32   
        ); 
        port (
            CLK                   : in  std_logic                                                                                              ;
            RESETN                : in  std_logic                                                                                              ;
            S_AXI_LITE_AWADDR     : in  std_logic_vector (     S_AXI_LITE_ADDR_WIDTH-1 downto 0 )                                              ;
            S_AXI_LITE_AWPROT     : in  std_logic_vector (                           2 downto 0 )                                              ;
            S_AXI_LITE_AWVALID    : in  std_logic                                                                                              ;
            S_AXI_LITE_AWREADY    : out std_logic                                                                                              ;
            S_AXI_LITE_WDATA      : in  std_logic_vector (     S_AXI_LITE_DATA_WIDTH-1 downto 0 )                                              ;
            S_AXI_LITE_WSTRB      : in  std_logic_vector ( (S_AXI_LITE_DATA_WIDTH/8)-1 downto 0 )                                              ;
            S_AXI_LITE_WVALID     : in  std_logic                                                                                              ;
            S_AXI_LITE_WREADY     : out std_logic                                                                                              ;
            S_AXI_LITE_BRESP      : out std_logic_vector (                           1 downto 0 )                                              ;
            S_AXI_LITE_BVALID     : out std_logic                                                                                              ;
            S_AXI_LITE_BREADY     : in  std_logic                                                                                              ;
            S_AXI_LITE_ARADDR     : in  std_logic_vector (     S_AXI_LITE_ADDR_WIDTH-1 downto 0 )                                              ;
            S_AXI_LITE_ARPROT     : in  std_logic_vector (                           2 downto 0 )                                              ;
            S_AXI_LITE_ARVALID    : in  std_logic                                                                                              ;
            S_AXI_LITE_ARREADY    : out std_logic                                                                                              ;
            S_AXI_LITE_RDATA      : out std_logic_vector (     S_AXI_LITE_DATA_WIDTH-1 downto 0 )                                              ;
            S_AXI_LITE_RRESP      : out std_logic_vector (                           1 downto 0 )                                              ;
            S_AXI_LITE_RVALID     : out std_logic                                                                                              ;
            S_AXI_LITE_RREADY     : in  std_logic                                                                                              ;
            MSMT_VALUE            : out std_logic_vector (                          31 downto 0 )                                              ;
            MSMT_VALID            : out std_logic                                                                                              ;
            INTR                  : in  std_logic                                                                                               
        );
    end component;


begin

    axi_timer_averager_inst : axi_timer_averager 
        generic map (
            DEFAULT_SAMPLES_SERIE =>  DEFAULT_SAMPLES_SERIE         ,
            S_AXI_LITE_DATA_WIDTH =>  S_AXI_LITE_DATA_WIDTH         ,
            S_AXI_LITE_ADDR_WIDTH =>  S_AXI_LITE_ADDR_WIDTH          
        )
        port map  (
            CLK                   =>  CLK                           ,
            RESETN                =>  RESETN                        ,
            S_AXI_LITE_AWADDR     =>  S_AXI_LITE_AWADDR             ,
            S_AXI_LITE_AWPROT     =>  S_AXI_LITE_AWPROT             ,
            S_AXI_LITE_AWVALID    =>  S_AXI_LITE_AWVALID            ,
            S_AXI_LITE_AWREADY    =>  S_AXI_LITE_AWREADY            ,
            S_AXI_LITE_WDATA      =>  S_AXI_LITE_WDATA              ,
            S_AXI_LITE_WSTRB      =>  S_AXI_LITE_WSTRB              ,
            S_AXI_LITE_WVALID     =>  S_AXI_LITE_WVALID             ,
            S_AXI_LITE_WREADY     =>  S_AXI_LITE_WREADY             ,
            S_AXI_LITE_BRESP      =>  S_AXI_LITE_BRESP              ,
            S_AXI_LITE_BVALID     =>  S_AXI_LITE_BVALID             ,
            S_AXI_LITE_BREADY     =>  S_AXI_LITE_BREADY             ,
            S_AXI_LITE_ARADDR     =>  S_AXI_LITE_ARADDR             ,
            S_AXI_LITE_ARPROT     =>  S_AXI_LITE_ARPROT             ,
            S_AXI_LITE_ARVALID    =>  S_AXI_LITE_ARVALID            ,
            S_AXI_LITE_ARREADY    =>  S_AXI_LITE_ARREADY            ,
            S_AXI_LITE_RDATA      =>  S_AXI_LITE_RDATA              ,
            S_AXI_LITE_RRESP      =>  S_AXI_LITE_RRESP              ,
            S_AXI_LITE_RVALID     =>  S_AXI_LITE_RVALID             ,
            S_AXI_LITE_RREADY     =>  S_AXI_LITE_RREADY             ,
            MSMT_VALUE            =>  MSMT_VALUE                    ,
            MSMT_VALID            =>  MSMT_VALID                    ,
            INTR                  =>  INTR                           
        );



end axi_timer_averager_vhd_arch;
