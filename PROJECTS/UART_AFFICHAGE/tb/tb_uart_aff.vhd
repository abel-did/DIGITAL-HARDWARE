library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity tb_uart_aff is
end entity;
--------------------------------------------------------------------------
architecture testbench of tb_uart_aff is
	constant f_clk   : real     := 100.0E6;                      -- Frequence de fonctionnement
  	constant f_baud  : real     := 1.0E6;                        -- Debit de la liaison en bauds
  	constant T1      : real     := 1.0E-6;  
        constant N       : positive := 8;

	constant hp     : time     := 1.0/(2.0*f_clk) * 1 sec;
  	constant per    : time     := 2*hp;
        
	signal clk       : std_logic := '0';                             -- Horloge 
        signal btnc      : std_logic;                             -- Init. asynchrone
        signal tx        : std_logic;                            -- DonnÃ©e UART transmise
        signal btnu      : std_logic;                             -- Ordre pour une nouvelle transmission
        signal sw        : std_logic_vector(N-1 downto 0);        -- Code ASCII a afficher
        signal ready     : std_logic;                            -- SystÃ¨me pret
        
begin
  	clk <= not clk after hp;
  
  	stimuli : process is
  	begin
  		btnu <= '0';
  		btnc <= '1';
  		wait for per;
                btnc <= '0';
  		sw <= "01000001";
  		btnu <= '1';
  		wait;
end process;

dut : entity work.uart_aff
  generic map(
        f_clk   => f_clk,                      -- Frequence de fonctionnement
  	f_baud  => f_baud,                       -- Debit de la liaison en bauds
  	T1      => T1,  
        N       => N
    )
    port map(
        clk     => clk,                             -- Horloge 
        btnc    => btnc,                            -- Init. asynchrone
        tx      => tx,                            -- DonnÃ©e UART transmise
        btnu    => btnu,                          -- Ordre pour une nouvelle transmission
        sw      => sw,        			-- Code ASCII a afficher
        ready   => ready                            -- SystÃ¨me pret
    );
end architecture;  	
