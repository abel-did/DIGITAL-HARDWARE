--------------------------------------------------------------------------
-- Author : Abel DIDOUH							--
-- Unit Name: DIGITAL HARDWARE						--
-- Date : 18 / 03 /2023							--
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity uart_tx is
  generic (
    f_clk  : real     := 100.0E6;
    f_baud : real     := 9600.0;
    N      : positive := 8
  );
  port (
    clk    : in  std_logic;
    resetn : in  std_logic;
    start  : in  std_logic;
    data   : in  std_logic_vector (N-1 downto 0);
    ready  : out std_logic;
    tx     : out std_logic    
  );
end entity;
--------------------------------------------------------------------------
architecture rtl of uart_tx is
	constant x 	: positive := integer(f_clk / f_baud);
	signal reg	: std_logic_vector(N-1 downto 0);
	signal ctr_tempo: natural range 0 to x-1;
	signal end_tempo: std_logic;
	signal ctr_data : unsigned(N-1 downto 0);
	signal end_data : std_logic;
	signal cmd_reg  : std_logic_vector(1 downto 0);
	signal cmd_tempo : std_logic;
	signal cmd_ctr : std_logic_vector(1 downto 0);
	signal cmd_tx : std_logic_vector(1 downto 0); 

	type state is (idle, start_bit, data_bit, stop_bit);
	signal current_state	: state;
	signal next_state	: state;
begin
--------------------------------------------------------------------------
-- Opertive Part							--
--------------------------------------------------------------------------
	
	-- REG Part --
	-- Chargement parallele
	-- Decalage a droite avec 0 en MSB
	-- Memorisation
	process(clk, resetn) is 
	begin
		if resetn = '0' then
			reg <= (others => '0');
		elsif rising_edge(clk) then
			case cmd_reg is 
				when "00" =>   reg <= '0' & reg(N-2 downto 0);
				when "01" =>   reg <= data;
				when others => reg <= reg;
			end case;
		end if;
	end process;

	-- CTR TEMPO Part --
	-- Mise a 0...0
	-- Incrementation
	end_tempo <= '1' when ctr_tempo >= (x-1) else
		     '0';

	process(clk,resetn) is 
	begin
		if resetn = '0' then
			ctr_tempo <= 0;
		elsif rising_edge(clk) then
			case cmd_tempo is 
				when '0' => 	ctr_tempo <= 0;
				when others =>	ctr_tempo <= ctr_tempo + 1;
			end case;
		end if;
	end process;	

	-- CTR DATA Part --
	-- Mise a 0...0
	-- Incrementation
	-- Memorisation
	end_data <= '1' when ctr_data >= (N-1) else
		    '0';

	process(clk, resetn) is 
	begin
		if resetn = '0' then
			ctr_data <= (others => '0');
		elsif rising_edge(clk) then
			case cmd_ctr is 
				when "01" =>	ctr_data <= ctr_data + 1;
				when "00" => 	ctr_data <= (others => '0');
				when others =>	ctr_data <= ctr_data;
			end case;
		end if;
	end process;

	-- Tx Part --
	process(clk,resetn) is
	begin
		if resetn ='0' then
			tx <= '0';
		elsif rising_edge(clk) then 
			case cmd_tx is 
				when "00" => 	tx <= '0';
				when "01" => 	tx <= '1';
				when others =>	tx <= reg(0);
			end case;
		end if;
	end process;

--------------------------------------------------------------------------
-- Control Part								--
--------------------------------------------------------------------------

	process(clk, resetn) is
	begin
		if resetn = '0' then
			current_state <= idle;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;


	process(current_state, start, end_tempo, end_data) is
	begin
		next_state <= current_state;
		
		cmd_reg <= "10";	-- Memorisation
		cmd_tx  <= "01";	-- Mise a 1
		cmd_ctr <= "00";	-- Mise a 0
		cmd_tempo <= '0';	-- Mise a 0
		ready   <= '0';		-- Not ready

		case current_state is
--------------------------------------------------------------------------
			when idle =>
				if start = '1' then
					next_state <= start_bit;
			end if;
			
			cmd_reg <= "01";	 -- Chargement parallele
			cmd_tx  <= "01";         -- Mise a 1
			cmd_ctr <= "00";	 -- Mise a 0
			cmd_tempo <= '0';	 -- Mise a 0
			ready   <= '1';		 -- Ready
--------------------------------------------------------------------------
			when start_bit =>
				if end_tempo = '1' then
					next_state <= data_bit;
				end if;
			
			cmd_reg <= "10";	 	-- Memorisation
			cmd_tx  <= "00";	 	-- Mise a 0
			cmd_ctr <= "10";	 	-- Memorisation
			
			if end_tempo = '1' then
				cmd_tempo <= '0'; 	-- Mise a 0
			else
				cmd_tempo <= '1'; 	-- Incrementation
			end if;

			ready   <= '0'	; 		-- Not ready
--------------------------------------------------------------------------			
			when data_bit =>
				if end_data = '1' and end_tempo = '1' then
					next_state <= stop_bit;
				end if;
			--cmd reg
			if end_tempo = '1' then
				cmd_reg <= "00";	 		-- Decalage a droite
			else	
				cmd_reg <= "10";	 		-- Memorisation
			end if;
			--cmd tx
			cmd_tx  <= "10";         			-- Reg(0)
			--cmd ctr 
			if end_tempo = '1' and end_data = '0' then
				cmd_ctr <= "01";	 		-- Incrementation
			elsif end_tempo = '1' and end_data = '1' then
				cmd_ctr <= "00";	 		-- Mise a 0
			else
				cmd_ctr <= "10";	 		-- Memorisation
			end if;

			--ctr_tempo
			if end_tempo = '1' then
				cmd_tempo <= '0';	 		-- Mise a 0
			else 
				cmd_tempo <= '1';			-- Incrementation
			end if;
			--ready
			ready   <= '0';		 			-- Not Ready

--------------------------------------------------------------------------
			when stop_bit =>
				if start = '0' and end_tempo = '1' then
					next_state <= idle;
				elsif start = '1' and end_tempo = '1' then
					next_state <= start_bit;
				end if;

			--cmd_reg
			if start = '1' then
				cmd_reg <= "01";			-- Chargement parallele
			else
				cmd_reg <= "10";			-- Memorisation
			end if;

			cmd_tx  <= "01";				-- Mise a 1
			cmd_ctr <= "00";				-- Mise a 0
			--ctr_tempo
			if end_tempo = '1' then
				cmd_tempo <= '0';			-- Mise a 0
			else
				cmd_tempo <= '1';			-- Mise a 0
			end if;
			--ready
			ready   <= '0';					-- Not ready
--------------------------------------------------------------------------
		end case;
	end process;
end architecture;
