--------------------------------------------------------------------------
-- Author   :   Abel DIDOUH                                             --
-- Date     :   24 / 03 / 2023                                          --
-- Project  :   UART                                                    --
-- Description : UART_RX                                                --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity uart_rx is 
    generic (
        f_clk   : real     := 100.0E6;
        f_baud  : real     := 9600.0;
        N       : positive := 8
    );
    port(
        clk     : in std_logic;
        resetn  : in std_logic;
        data_out: out std_logic_vector(N-1 downto 0);
        busy    : out std_logic
    );
end entity;
--------------------------------------------------------------------------
architecture rtl of uart_rx is
    
    --Signal PART
    constant x 		: positive := integer(f_clk / f_baud);
    signal end_tempo    : std_logic;
    signal end_rx       : std_logic;
    signal ctr_tempo	: natural range 0 to x-1;
    signal ctr_data 	: unsigned(N-1 downto 0);
    signal end_data     : std_logic_vector(1 dwonto 0);
    signal rx_next      : std_logic;
begin
--------------------------------------------------------------------------
-- Opertive Part							                            --
--------------------------------------------------------------------------

    --REG PART
    --Memorization
    --Decalage --> Chargement en série
    process(clk, resetn)
    begin
        if resetn = '0' then
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            case cmd_rx is
                when '0'    => data_out <= data_out;
                when others => data_out <= data_out(N-2 downto 0) & rx;
            end case;
        end if;
    end process;

    --CTR_TEMPO PART
    --Set to 0...0
    --Incrementation
    end_tempo <=    '1' when ctr_tempo >= (x - 1)   else
                    '0';    
    end_rx    <=    '1' when ctr_tempo >= (x/2)     else
                    '0';

    process(clk, resetn)
    begin
        if resetn = '0' then
            end_tempo   <= '0';
            end_rx      <= '0';
        elsif rising_edge(clk) then
            case cmd_tempo is
                when '1'    =>  ctr_tempo <= ctr_tempo;
                when others =>  ctr_tempo <= (others => '0');   
            end case;
        end if;
    end process;

	-- CTR DATA Part --
	-- Set to 0...0
	-- Incrementation
	-- Memorization
	end_data <=     '1' when ctr_data >= (N-1) else
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

    --Detection Front descendant
    fall_rx <=      rx_next and not rx;
    
    process(clk, resetn)
    begin
        if resetn = '0' then
            rx_next <= '0';
        elsif rising_edge(clk) then
            rx_next <= rx;
        end if;
    end process;
            
--------------------------------------------------------------------------
-- Control Part				                            				--
--------------------------------------------------------------------------

	process(clk, resetn) is 
	begin 
		if resetn = '0' then 
			current_state <= idle;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;
	
	process(current_state, fall_rx, end_tempo, end_data) is 
	begin
		next_state <= current_state;
		
		cmd_reg   <= "10";	-- Memorisation
		cmd_data  <= "00";	-- Mise a 0
		cmd_tempo <= '0';	-- Mise a 0
		busy      <= '0';	-- Not busy

		case current_state is
--------------------------------------------------------------------------
-- Idle									--
--------------------------------------------------------------------------
			when idle =>
				if fall_rx = '1' then
					next_state <= first_bit;
				end if;
			
				cmd_reg   <= "10";	-- Memorisation
				cmd_data  <= "00";	-- Mise a 0
				cmd_tempo <= '0';	-- Mise a 0
				busy      <= '0';	-- Not busy
			
--------------------------------------------------------------------------
-- First bit								--
--------------------------------------------------------------------------
			when first_bit =>
				if end_tempo = '1' and end_data = '0' then
					next_state <= read_bit;
				end if;
					
				cmd_reg   <= "10";			-- Memorisation
				cmd_data  <= "00";			-- Mise a 0
				if end_tempo = '1' then
					cmd_tempo <= '0';		-- Mise a 0
				else	
					cmd_tempo <= '1';		-- Incrementation
				
				busy      <= '1';			-- Busy
--------------------------------------------------------------------------
-- Read bit								--
--------------------------------------------------------------------------		
			when read_bit =>
				if end_tempo = '1' and end_data = '1' then
					next_state <= stop_bit;
				end if;
			
				--cmd reg
				if end_tempo = '1' then
					cmd_reg <= "00";	 		-- Decalage a droite
				else	
					cmd_reg <= "10";	 		-- Memorisation
				end if;
				--cmd data
				if end_tempo = '1' and end_data = '0' then
					cmd_data <= "01";	 		-- Incrementation
				elsif end_tempo = '1' and end_data = '1' then
					cmd_data <= "00";	 		-- Mise a 0
				else
					cmd_data <= "10";	 		-- Memorisation
				end if;

				--ctr_tempo
				if end_tempo = '1' then
					cmd_tempo <= '0';	 		-- Mise a 0
				else 
					cmd_tempo <= '1';			-- Incrementation
				end if;
				--ready
				busy   <= '1';		 			-- Busy
--------------------------------------------------------------------------
-- Stop bit								--
--------------------------------------------------------------------------			
			when stop_bit =>
				if fall_rx = '1' and end_tempo = '1' then
					next_state <= first_bit;
				elsif fall_rx = '0' and end_tempo = '1' then
					next_state <= idle;
				end if;
				
				cmd_reg   <= "10";	-- Memorisation
				cmd_data  <= "00";	-- Mise a 0
				cmd_tempo <= '0';	-- Mise a 0
				busy      <= '0';	-- Not busy
--------------------------------------------------------------------------
		end case;	
	end process;
end architecture;
