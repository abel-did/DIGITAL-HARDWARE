--------------------------------------------------------------------------
-- Author : Abel DIDOUH & David CHEN                                    --
-- Description : UART RX                                                --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity uart_rx is
    generic (
        f_clk   : real := 100.0E6;
        f_baud  : real := 96000;
        N       : positive := 8
    );
    port(
        clk     : in std_logic;
        resetn  : in std_logic;
        data_out : out std_logic_vector(N-1 downto 0);
        rx       : in std_logic;
        ready    : out std_logic
    );
end uart_rx;
--------------------------------------------------------------------------
architecture arch of uart_rx is
	constant x 	: positive := integer(f_clk / f_baud);
    constant xmid : positive := integer(x / 2);

    signal reg_rx : std_logic_vector(1 downto 0);	

    signal ctr_tempo : natural range 0 to (x-1);
    signal cmd_tempo : std_logic;
    signal end_tempo : std_logic;	
    signal x_comp    : positive;
    signal mux_x_comp: std_logic;

	signal cmd_data : std_logic_vector(1 downto 0);
    signal ctr_data : unsigned (N-1 downto 0);
    signal data     : unsigned (N-1 downto 0);
    signal end_data : std_logic; 
    signal LSB      : std_logic;

    signal cmd_data_ok  : std_logic_vector (1 downto 0);
    signal data_ok      : std_logic;

    type state is (idle, start_bit, data_bit, stop_bit);
    signal current_state    : state;
    signal next_state   	: state;
begin

--------------------------------------------------------------------------
-- Operative Part                                                       --
--------------------------------------------------------------------------
    data_out <= end_data;
    -- REG RX PART
    -- DECALAGE A DROITE RX MSB 
    process (resetn, clk) is
    begin
    if resetn = '0' then
            reg_rx <= (others <= '0');
    elsif rising_edge(clk) then
            reg_rx <= rx & reg_rx(1);
    end if;
    end process;

    -- CTR TEMPO PART
    -- MISE A 0 
    -- INCREMENTATION
    x_comp <= x-1 when mux_x_comp = '1' else
              xmid - 1;	
	end_tempo <= '1' when ctr_tempo >= x_comp else
			     '0';
    
    process (resetn, clk) is
    begin
    if resetn = '0' then 
            ctr_tempo <= 0; 
	elsif rising_edge(clk) then
  		case cmd_tempo is
			when '0' => ctr_tempo <= 0;
			when others => ctr_tempo <= ctr_tempo +1;
        end case;
    end if;
	end process;

    -- DATA PART
    -- CHARGEMENT // DE 1…1
    -- DECALAGE A DROITE AVEC REG_RX(0) EN MSB
    -- MEMORISATION 
    end_data <= not LSB;
    LSB <= data(0);
    data <= ctr_data;
    process (resetn, clk) is
    begin
	if resetn = '0' then
		ctr_data <= (others => '0');
	elsif rising_edge(clk) then
		case cmd_data is
			when "00" => (others => '1');
			when "01" => reg_rx(0) & ctr_data (N-1 downto 1);
			when others => ctr_data <= ctr_data;
        end case;
	end if;
    end process;    

    -- DATA_OK PART 
    -- MISE A 0
    -- MISE A 1
    -- MEMORISATION
    process (resetn, clk) is
    begin
    if resetn = '0' then 
        data_ok <= '0'; 
    elsif rising_edge(clk) then
        case cmd_data_ok is
            when "00" => data_ok <= '0';
            when "01" => data_ok <= '1';
            when others => data_ok <= data_ok;
        end case;
    end if;
    end process;

----------------------------------------------------------------
-- Control Part                                               --
----------------------------------------------------------------

process(clk, resetn) is
begin
if resetn = '0' then
    current_state <= idle;
elsif rising_edge(clk) then
        current_state <= next_state;
end if;
end process;
    
    
process(current_state, reg_rx, end_tempo, end_data) is
begin
    next_state <= current_state;
        
    cmd_data <= "10";		-- Memorisation
    cmd_data_ok <= "00";	-- Mise a 0
    cmd_tempo	<= '0';	    -- Mise a 0
    mux_x_comp	<= '1';	    -- x - 1
    ready 	<= '1';
    
    
    case current_state is
    
-----------------------------------------------------------------
-- IDLE                                                        --
-----------------------------------------------------------------
when idle =>
	if reg_rx(0) = '0' then
		next_state <= start_bit;
	end if;

    cmd_data <= "10";		-- Memorisation

    if reg_rx(0) = '0' then
        cmd_data_ok <= "00";	-- Mise a 0
    else 
        cmd_data_ok <= "10";	-- Mémorisation
    end if;


    cmd_tempo	<= '0';	-- Mise a 0
    mux_x_comp	<= '1';	-- x - 1
    ready 	    <= '1';

-----------------------------------------------------------------
-- START BIT                                                   --
-----------------------------------------------------------------
when start_bit => 
    if (end_tempo = '1' and reg_rx(0) = '0') then
        next_state <= data_bit;
    elsif (end_tempo = '1' and reg_rx(0) = '1') then
        next_state <= idle;
    end if;

    if end_tempo = '1' then
        cmd_data <= "10";	
    else
        cmd_data <= "00";
    end if;
        
    cmd_data_ok <= "10"; - - Memorisation	

    if end_tempo = '1' then
        cmd_tempo	<= '0';
    else
    cmd_tempo <= '1';
    end if;    
    mux_x_comp	<= '0'; 	-- xmid - 1
    ready 	<= '1';

-----------------------------------------------------------------
-- DATA BIT                                                    --
-----------------------------------------------------------------
when data_bit =>
	if (end_data = '1' and end_tempo = '1') then
		next_state <= stop_bit;
	end if;
	if end_tempo = '1' then 
		cmd_data <= "01";
	else
		cmd_data <= "11";
	end if;

    cmd_data_ok <= "10";  -- Memorisation	

    if end_tempo = '1' then
        cmd_tempo <= '0';
    else 
        cmd_tempo <= '1';
    end if;

    mux_x_comp	<= '1';	-- X - 1

    ready 	<= '0';


-----------------------------------------------------------------
-- STOP BIT                                                    --
-----------------------------------------------------------------
when stop_bit =>
	if (end_tempo = '1') then
		next_state <= idle;
	end if;

	cmd_data <= "10";		-- Memorisation
	
	if (reg_rx(0) = '1' and end_tempo = '1') then 
		cmd_data_ok <= "01";                        --  Mise a 1
	else 
		cmd_data_ok <= "10";
	end if;

	if end_tempo = '1' then
		cmd_tempo <= '0';
	else 
		cmd_tempo <= '1';
	end if;


    mux_x_comp	<= '1';         -- X - 1

	ready 	<= '0';


end case;
end process;
end arch;