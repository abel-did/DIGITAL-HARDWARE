-- Author : Abel DIDOUH
-- Date : 15 / 02 / 2023
-----------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------------------------------------------------------------------------
entity tb_td1 is 
end entity;
-----------------------------------------------------------------------------------------
architecture arch of tb_td1 is
	signal sw	: std_logic_vector(15 downto 0);
	signal btnd	: std_logic;
	signal btnl 	: std_logic;
	signal btnr	: std_logic;
	signal btnu 	: std_logic;
	signal led	: std_logic_vector(15 downto 0);
begin
	dut : entity work.td1
		generic map (
			x => 2
		)
	port map (
		sw 	=> 	sw,
		btnd 	=> 	btnd,
		btnl	=>	btnl,
		btnr	=>	btnr,
		btnu	=>	btnu,
		led	=> 	led
	);

	process is
	begin
		-- Vecteur n°1
		sw 	<= X"00AA";
		btnd 	<= '1';
	        btnl	<= '0';
		btnr	<= '0';
		btnu	<= '1';
		wait for 10 ns;

		-- Vecteur n°2
		btnd	<= '0';
		wait for 10 ns;
		
		-- Vecteur n°3
		sw 	<= X"2023";
		wait for 10 ns;

		-- Vecteur n°4
		btnu	<= '0';
		btnl	<= '1';
		wait for 10 ns;

		-- Vecteur n°5 
		sw	<= std_logic_vector(to_unsigned(2023, 16));
		wait for 10 ns;

		-- Attente infinie
		wait;
	end process;
end architecture;	
