--------------------------------------------------------------------------
-- Author : Abel DIDOUH	                						                    --
-- Unit Name: DIGITAL HARDWARE	                                        --
-- Project : UART RX            					                              --
-- Date : 18 / 03 /2023							                                    --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity tb_uart_rx is 
end entity;
--------------------------------------------------------------------------
architecture testbench of tb_uart_rx is
  constant f_clk  : real     := 100.0E6;
  constant f_baud : real     := 2.0E6;
  constant N      : positive := 8;
  constant hp     : time     := 1.0/(2.0*f_clk) * 1 sec;
  constant per    : time     := 2*hp;
  
  signal clk    : std_logic:= '0';
  signal resetn : std_logic;
  signal ready   : std_logic;
  signal rx     : std_logic;
  signal data_out : std_logic_vector(N-1 downto 0);
  
begin
  clk <= not clk after hp;
  
 
stimuli : process is
begin
  resetn <= '0';
  rx <= '1';		-- Ligne repos
  wait for 500 ns;
  resetn <= '1';
  rx <= '0';

  -- A 01000001

  wait for 500 ns;
  rx <= '0'; -- Bit 0
  wait for 500 ns;
  rx <= '0'; -- Bit 1
  wait for 500 ns;
  rx <= '0'; -- Bit 2
  wait for 500 ns;
  rx <= '0'; -- Bit 3
  wait for 500 ns;
  rx <= '0'; -- Bit 4
  wait for 500 ns;
  rx <= '0'; -- Bit 5
  wait for 500 ns;
  rx <= '1'; -- Bit 6
  wait for 500 ns;
  rx <= '0'; -- Bit 7
  wait for 500 ns;

  

  -- E 01000101
  --wait for 1000 ns;
  --rx <= '0'; 	-- BIT 7
  --wait for 500 ns;
  --rx <= '1';	-- BIT 6
  --wait for 500 ns;
  --rx <= '0';	-- BIT 5
  --wait for 500 ns;
  --rx <= '0';    -- BIT 4
  --wait for 500 ns;
  --rx <= '0';	-- BIT 3 
  --wait for 500 ns;
  --rx <= '1';	-- BIT 2
  --wait for 500 ns;
  --rx <= '0';	-- BIT 1
  --wait for 500 ns;
  --rx <= '1';	-- BIT 0
  

  wait;
  end process;
  
  dut : entity work.uart_rx 
  generic map (
    f_clk  => f_clk ,
    f_baud => f_baud,
    N      => N     
  )
  port map (
    clk    => clk   ,
    resetn => resetn,
    data_out   => data_out  ,
    ready  => ready ,
    rx     => rx 
  );
end architecture;
