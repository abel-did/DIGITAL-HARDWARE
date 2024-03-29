--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     01 / 04 / 2023                                        --
-- Project  :     PWM                                            --
-- Description :  TB_DIMMER                                            --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------------
entity tb_dimmer is
end entity;
------------------------------------------------------------------------------------
architecture tb of tb_dimmer is

  signal resetn : std_logic;
  signal pwm    : std_logic;
  signal cmd    : std_logic_vector(1 downto 0);

  --clk period
  constant T : time := 10 ns;
  signal clk : std_logic := '0';

begin 
  clk <= not clk after T/2;
  
  uut : entity work.dimmer
  port map(clk => clk,
	   resetn => resetn,
           cmd => cmd,
	   pwm => pwm);

  process
  begin
       	resetn <= '0';
       	cmd <= "00";
	wait until falling_edge(clk);

	resetn <= '1';
       	cmd <= "11";
	wait for 30000000 ns;  --until falling_edge(clk);

       	cmd <= "10";
	wait for 30000000 ns;
       	cmd <= "00";
	wait for 30000000 ns;
       	cmd <= "01";
	wait for 30000000 ns;


       wait;
  end process; 
end architecture;
       
