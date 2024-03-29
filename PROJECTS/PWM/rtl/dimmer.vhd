--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     26 / 04 / 2023                                        --
-- Project  :     PWM                                            --
-- Description :  Dimmer                                            --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------------
entity dimmer is
  port (
    clk, resetn : in std_logic;
    cmd		: in std_logic_vector(1 downto 0);
    pwm         : out std_logic
    );
end entity;
---------------------------------------------------------------------------------------
architecture rtl of dimmer is
   signal r_reg, r_next : unsigned(19 downto 0);
   signal srt_mux : unsigned(19 downto 0);
   signal q : unsigned(19 downto 0);
begin 
   --DFF
   process(clk, resetn)
   begin
    	if resetn = '0' then
      		r_reg <= (others => '0');
    	elsif rising_edge(clk) then
      		r_reg <= r_next;
    	end if;
   end process;
   --Mux 
   srt_mux <= TO_UNSIGNED(0,20) when cmd = "00" else 
	      TO_UNSIGNED(333333, 20) when cmd = "01" else
	      TO_UNSIGNED(500000, 20) when cmd = "10" else
	      TO_UNSIGNED(750000, 20) when cmd = "11" else
	      TO_UNSIGNED(0, 20);
   --Circuit calculant le prochain etat
   r_next <= TO_UNSIGNED(0, 20) when r_reg >= 1000000 else
	     r_reg + 1;
   --Circuit calculant les sorties
   q <= r_reg;
   pwm <= '0' when q >= srt_mux else
	  '1';
end architecture;





