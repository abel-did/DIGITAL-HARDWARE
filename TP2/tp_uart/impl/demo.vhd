library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity demo is
  generic (
    f_clk  : real     := 100.0E6;
    f_baud : real     := 9600.0
  );
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    start  : in  std_logic;
    sw     : in  std_logic_vector (7 downto 0);
    ready  : out std_logic;
    tx     : out std_logic    
  );
end entity;


architecture rtl of demo is
  signal resetn : std_logic;
  
begin
  resetn <= not reset;
  
  dut : entity work.uart_tx 
  generic map (
    f_clk  => f_clk ,
    f_baud => f_baud,
    N      => 8     
  )
  port map (
    clk    => clk   ,
    resetn => resetn,
    start  => start ,
    data   => sw  ,
    ready  => ready ,
    tx     => tx    
  );  
                    
end architecture;