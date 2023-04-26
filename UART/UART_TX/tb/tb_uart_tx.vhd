--------------------------------------------------------------------------
-- Author : Abel DIDOUH	           					--
-- Unit Name: DIGITAL HARDWARE	                                        --
-- Project : UART TX Testbench        					--
-- Date : 18 / 03 /2023							--
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity tb_uart_tx is 
end entity;
--------------------------------------------------------------------------
architecture testbench of tb_uart_tx is
  constant f_clk  : real     := 100.0E6;
  constant f_baud : real     := 2.0E6;
  constant N      : positive := 8;
  constant hp     : time     := 1.0/(2.0*f_clk) * 1 sec;
  constant per    : time     := 2*hp;
  
  signal clk    : std_logic:= '0';
  signal resetn : std_logic;
  signal start  : std_logic;
  signal data   : std_logic_vector (N-1 downto 0);
  signal ready  : std_logic;
  signal tx     : std_logic; 
	
begin
  clk <= not clk after hp;
  
  stimuli : process is
  begin
    
	resetn <= '0';
	data   <= x"F1"; 
	start  <= '0';

	wait for per;

	resetn <= '1';
	start  <= '1';

	wait for per;
	start  <= '0'; 

	wait  for per; 
	data   <= x"AE";
	start  <= '1';

  wait;
  end process;
  
  dut : entity work.uart_tx 
  generic map (
    f_clk  => f_clk ,
    f_baud => f_baud,
    N      => N     
  )
  port map (
    clk    => clk   ,
    resetn => resetn,
    start  => start ,
    data   => data  ,
    ready  => ready ,
    tx     => tx    
  );
end architecture;
