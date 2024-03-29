--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     01 / 04 / 2023                                        --
-- Project  :     chenillard                                            --
-- Description :  chenillard                                            --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity chenillard is
  generic(   
    f_clk      : real     := 100.0E6;   			-- Frequence de fonctionnement
    canal_leds : positive := 13;					-- Numero du 1er canal
    T_c        : real     := 50.0E-9    			-- Duree d'allumage d'un spot
  );
  port (
    clk	     : in std_logic;						-- Horloge
    resetn   : in std_logic;            			-- Init asynchrone
    addr_spot: out std_logic_vector(8 downto 0) 	-- Adresse sur 9 bits du spot a allumer
  );
end entity;
--------------------------------------------------------------------------
architecture rtl of chenillard is 

	constant xc         : positive  := integer(ceil( T_c * f_clk ));
	
	signal end_Tc       : std_logic;
	signal end_ctr      : std_logic;
	signal ctr_tempo    : natural range 0 to xc-1;
	
	signal end_L        : std_logic;
	signal end_ctr_L    : std_logic;
	signal end_C	    : std_logic;
	signal end_ctr_C    : std_logic;
	signal ctr_c        : std_logic_vector(1 downto 0);
	signal ctr_L        : std_logic_vector(1 downto 0);
	signal ctr_L0       : std_logic_vector(2 downto 0);
	signal cmd_ctrL     : std_logic;
	signal cmd_ctrC     : std_logic;
	
	signal ctr_L_add    : std_logic_vector(3 downto 0);
	signal ctr_L_C_add  : std_logic_vector(3 downto 0);
	
begin 
	
	
	
	-- CTR TEMPO 
	-- Incrementation modulo xc
	end_Tc   <= end_ctr;
	end_ctr <= '1' when ctr_tempo >=(xc - 1) else 
	           '0';
	process(clk,resetn) is
	begin
	if resetn = '0' then
		ctr_tempo <= 0;
	elsif rising_edge(clk) then
		if end_ctr = '1' then
		  ctr_tempo 		<= 0;
		else
		  ctr_tempo 		<= ctr_tempo + 1;
		end if;
	end if;
	end process;
	
	-- CTR L
	--Incrementation modulo 4
	--Memorisation	
	end_L   <= end_ctr_L;
	end_ctr_L <= '1' when unsigned(ctr_L) = 3 else 
	             '0';
	process(clk,resetn) is
	begin
	if resetn = '0' then
		ctr_L <= (others => '0');
	elsif rising_edge(clk) then
		if end_Tc = '1' then
		  ctr_L 		<= std_logic_vector(unsigned(ctr_L) + 1); 		--Incrementation
		elsif (end_Tc = '1' and end_ctr_L = '1') then
		  ctr_L 		<= (others => '0');								--Set to 0...0
		else 
		  ctr_L 		<= ctr_L;										--Mem
		end if;
	end if;
	end process;
	
	-- CTR C
	--Incrementation modulo 3
	--Memorisation	
	end_C   <= end_ctr_C;
	end_ctr_C <= '1' when unsigned(ctr_C) = 2 else 
	             '0';
	process(clk,resetn) is
	begin
	if resetn = '0' then
		ctr_C <= (others => '0');
	elsif rising_edge(clk) then
		if end_Tc = '1' and end_L = '1' then
		  ctr_C 		<= std_logic_vector(unsigned(ctr_C) + 1); 			--Incrementation
		elsif end_ctr_C = '1' and (end_Tc = '1' and end_L = '1') then
		  ctr_C 		<= (others => '0');	
		else 
		  ctr_C			<= ctr_C;											--Memorisation 
		end if;
	end if;
	end process;
	
	ctr_L0 <= ctr_L & '0';
	ctr_L_add <=   std_logic_vector(unsigned('0' & ctr_L0) + unsigned("00" & ctr_L));
	ctr_L_C_add <= std_logic_vector(unsigned(ctr_C) + unsigned(ctr_L_add));
	
	addr_spot <= std_logic_vector(to_unsigned(canal_leds - 1, 4) + unsigned("00000" & ctr_L_C_add));
	
	
end architecture;
