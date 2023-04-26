--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     01 / 04 / 2023                                        --
-- Project  :     DMX MH5                                            --
-- Description :  Testbench                                            --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_dmx512 is
  
end entity;

architecture testbench of tb_dmx512 is
  constant f_clk  : real     := 100.0E6;
  constant canal_MH5 : positive := 33;
  constant T_bit  : real     := 50.0E-9;
  
  constant hp     : time     := 1.0/(2.0*f_clk) * 1 sec;
  constant per    : time     := 2*hp;
  
  signal clk  	: std_logic := '0'; 
  signal btnc	: std_logic;
  signal btnu 	: std_logic;
  signal btnd 	: std_logic;
  signal sw   	: std_logic_vector(15 downto 0);
  signal rx   	: std_logic;
  signal tx   	: std_logic;
  signal set1 	: std_logic;
  signal ready	: std_logic;
  signal seg 	: std_logic_vector(6 downto 0);
  signal dp  	: std_logic;
  signal an 	: std_logic_vector(3 downto 0);
	
begin
  clk <= not clk after hp;
  
  stimuli : process is
  begin
        btnu 	<= '0';
	btnc	<= '1';
	wait for per;

	--btnc	<= '0';
	--btnu 	<= '1';
	wait for per;
	--Magenta color
	sw(15 downto 12) 	<= "0011";
	sw(11 downto 8) 	<= "0000";
	sw(7 downto 0) 		<= "00111100";
	rx <= '0';
	btnd 			<= '1'; 
	btnc	<= '0';
	btnu 	<= '1';

    wait;
  end process;
  
  dut : entity work.dmx_mh5
  generic map (
    f_clk  	=> f_clk,
    canal_mh5  	=> canal_mh5, 
    T_bit  	=> T_bit    
  )
  port map (
    clk    => clk, 
    btnc   => btnc,
    btnu   => btnu,
    btnd   => btnd,
    sw     => sw,
    rx     => rx,
    tx     => tx,
    set1   => set1,
    ready  => ready,
    seg    => seg,
    dp     => dp,
    an     => an
  );
end architecture;
