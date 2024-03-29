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
entity tb_dmx_leds is
end entity;
--------------------------------------------------------------------------
architecture testbench of tb_dmx_leds is
   
  constant f_clk      : real     := 100.0E6;   	    -- Frequence de fonctionnement
  constant canal_leds : positive := 13;		          -- Numero du 1er canal
  constant T_bit      : real     := 4.0E-6;    	    -- Duree d'un bit de la transmission UART
  constant T_c        : real     := 50.0E-9;
  
  constant hp     : time     := 1.0/(2.0*f_clk) * 1 sec;
  constant per    : time     := 2*hp;
  
  signal clk  	  : std_logic := '0'; 
  
  signal btnc     : std_logic;		                  -- Init asynchrone
  signal btnu     : std_logic;                      -- Demarage de la trame DMX
  signal rx       : std_logic;		                  -- Donnee UART recue (cable DMX)
  signal tx 	  : std_logic;		                    -- Donnee UART transmise (cable DMX)
  signal set1     : std_logic;                      -- Signal a 1 (cable DMX)
  signal ready    : std_logic;                      -- Systeme pret (en attente d'appui sur btnu)
	
begin
  clk <= not clk after hp;
  
  stimuli : process is
  begin
        btnu 	<= '0';
	btnc	<= '1';
	wait for per;

	btnc	<= '0';
	btnu 	<= '1';
	

    wait;
  end process;
  
  dut : entity work.dmx_leds
  generic map(   
    f_clk      => f_clk,   
    canal_leds => canal_leds,	
    T_bit      => T_bit,    
    T_c        => T_c
  )
  port map(
    clk	    	=> clk,
    btnc     	=> btnc,
    btnu     	=> btnu,
    rx       	=> rx,
    tx 	     	=> tx,
    set1     	=> set1,
    ready    	=> ready
  );
end architecture;
