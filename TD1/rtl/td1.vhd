-- Author : Abel DIDOUH
-- Date : 15 / 02 / 2023
-----------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all
use ieee.numeric_std.all;
use ieee.math_real.all;
-----------------------------------------------------------------------------------------
entity td1 is 
	-- param generic
	generic (
		x : natural := 2
	);
	-- I/O
	port ( 
		btnl : in std_logic;
		btnd : in std_logic;
		btnr : in std_logic;
		btnu : in std_logic;
		sw   : in std_logic_vector( 15 downto 0);
		led  : out std_logic_vector( 15 downto 0)
	);
end entity;
-----------------------------------------------------------------------------------------
architecture rtl of td1 is 
	signal sum		: signed(8 downto 0);
	signal srt_add_sat	: signed(15 downto 0);
	signal sum_add		: signed(16 downto 0);
begin 
	sum <= signed( sw(15) & sw(15 downto 8)) + signed( sw(7 downto 0));
	sum_add <= signed( sw(15) & sw(15 downto 0)) + x;
	srt_add_sat <= to_signed(2**15 - 1, 16) when sum_add < 2**15 else
		       sum_add(15 downto 0);

	process(btnu, btnl, btnd, btnr, sum, srt_add_sat) is
	begin
		if btnd = '0' and btnu = '0' and btnl = '0' and btnr = '0' then
			led <= x"FFFF";
		elsif btnd = '0' and btnu = '0' and btnl = '0' and btnr = '1' then
			led <= x"AA0F";
		elsif btnd = '0' and btnu = '0' and btnl = '0' and btnr = '0' then
			led <= std_logic_vector(srt_add_sat);
		elsif btnd = '0' and btnu = '0' and btnl = '1' and btnr = '1' then
			led <= x"5555";
		elsif btnd = '0' and btnu = '1' then
			led <= (others => sum(8));
			led(8 downto 0) <= std_logic_vector(sum);
		elsif btnd = '1' then
			led <= sw;
		end if;
	end process;
end architecture;
