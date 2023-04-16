--------------------------------------------------------------------------
-- Author   :   Abel DIDOUH                                             --
-- Date     :   14 / 04 / 2023                                          --
-- Project  :   UART AFFICHAGE                                          --
-- Description : UART_AFF                                               --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity uart_aff is 
    generic (
        f_clk   : real     := 100.0E6;                      -- Frequence de fonctionnement
  	f_baud  : real     := 1.0E6;                        -- Debit de la liaison en bauds
  	T1      : real     := 1.0E-6;  
        N       : positive := 8
    );
    port(
        clk     : in std_logic;                             -- Horloge 
        btnc    : in std_logic;                             -- Init. asynchrone
        tx      : out std_logic;                            -- DonnÃ©e UART transmise
        btnu    : in std_logic;                             -- Ordre pour une nouvelle transmission
        sw      : in std_logic_vector(N-1 downto 0);        -- Code ASCII a afficher
        ready   : out std_logic                             -- SystÃ¨me pret
    );
end entity;
--------------------------------------------------------------------------
architecture rtl of uart_aff is
    --Signal PART
    constant x 		    : positive := integer(ceil(f_clk * T1));

    signal sortie_process_1 : std_logic;
    signal sortie_process_2 : std_logic;
    signal entree_combined_1 : std_logic;
    signal sortie_process_3  : std_logic;
    signal start             : std_logic;

    signal end_tempo         : std_logic;
    signal ctr_tempo	     : natural range 0 to x-1;

    signal addr              : std_logic_vector(3 downto 0);
    signal end_message       : std_logic;
    signal data              : std_logic_vector(N-1 downto 0);
    signal sortie_mux_data   : std_logic_vector(N-1 downto 0);

    signal start_uart        : std_logic;
    signal ready_tx          : std_logic;

    signal cmd_tempo : std_logic;
    signal cmd_addr  : std_logic;

    signal resetn 	     : std_logic;

    type state is (idle, wait_for_uart_busy, wait_for_uart_ready, wait_for_tempo);
    signal current_state	: state;
    signal next_state		: state;

    

    begin
--------------------------------------------------------------------------
-- Opertive Part							                            --
--------------------------------------------------------------------------

    resetn <= not btnc;

    --Detection de front montant
    process(clk, resetn)
    begin
        if resetn = '0' then
            sortie_process_1 <= '0';
        elsif rising_edge(clk) then
            sortie_process_1 <= btnu;
        end if;
    end process;

    process(clk, resetn)
    begin
        if resetn = '0' then
            sortie_process_2 <= '0';
        elsif rising_edge(clk) then
            sortie_process_2 <= sortie_process_1;
        end if;
    end process;

    entree_combined_1 <= sortie_process_1 and not sortie_process_2;

    process(clk, resetn)
    begin
        if resetn = '0' then
            sortie_process_3 <= '0';
        elsif rising_edge(clk) then
            sortie_process_3 <= entree_combined_1;
        end if;
    end process;
    
    start <= sortie_process_3;

    --CTR_TEMPO PART
    --Set to 0...0
    --Incrementation
    end_tempo <=    '1' when ctr_tempo >= (x - 1)   else
                    '0';    

    process(clk, resetn)
    begin
        if resetn = '0' then
            ctr_tempo <= 0;
        elsif rising_edge(clk) then
            case cmd_tempo is
                when '1'    =>  ctr_tempo <= ctr_tempo + 1;
                when others =>  ctr_tempo <= 0;   
            end case;
        end if;
    end process;

   	-- ADDR PART
	-- Incrementation
	-- Memorization
    process(clk, resetn) is 
    begin
        if resetn = '0' then
        addr <= (others => '0');
        elsif rising_edge(clk) then
            case cmd_addr is 
                when '1'    =>	addr <= std_logic_vector(unsigned(addr) + 1);
                when others =>  addr <= addr;
            end case;
        end if;
    end process; 

    end_message <= '1' when unsigned(addr) = 0 else
                   '0';

    my_rom : entity work.my_rom
    generic map
    (
        N_addr  => 4,
        message => "Caractere : "

    )
    port map (
        clk         =>  clk,
        address     =>  addr,
        data        =>  data
    );

    sortie_mux_data <= sw when unsigned(addr)  = 14 else
                       data;
    
    uart_tx : entity work.uart_tx
    generic map
    (
        f_clk   => f_clk,                      
        f_baud  => f_baud,
	N       => N                      
                   
    )
    port map (
	clk          => clk,
        resetn       => resetn,
        data         => sortie_mux_data,
        start        => start_uart,
        ready        => ready_tx,
        tx           => tx
    );

--------------------------------------------------------------------------
-- Control Part				                            	            --
--------------------------------------------------------------------------

    process(clk, resetn) is 
        begin 
            if resetn = '0' then 
                current_state <= idle;
            elsif rising_edge(clk) then
                current_state <= next_state;
            end if;
    end process;

    process(current_state, start, ready_tx, end_message, end_tempo) is 
	begin
		next_state <= current_state;

        start_uart <= '0';
        cmd_addr   <= '0';  --Mem
        ready      <= '1';
        cmd_tempo  <= '0';  --Set to 0

        case current_state is

--------------------------------------------------------------------------
-- Idle									                                --
--------------------------------------------------------------------------
	    when idle =>
            if start = '1' and ready_tx = '1' then
                next_state <= wait_for_uart_busy;
            end if;
        
            start_uart <= '1';
            cmd_addr   <= '0';  --Mem
            ready      <= '1';
            cmd_tempo  <= '0';  --Set to 0
            
--------------------------------------------------------------------------
-- Wait for uart busy								                                --
--------------------------------------------------------------------------
            when wait_for_uart_busy =>
            if ready_tx = '0' then
                next_state <= wait_for_uart_ready;
            end if;
            
            start_uart <= '1';
            if ready_tx = '0' then
                cmd_addr       <= '1';
            else
                cmd_addr       <= '0';  --Mem
            end if;
            ready      <= '0';
            cmd_tempo  <= '0';  --Set to 0

--------------------------------------------------------------------------
-- Wait for uart ready							                        --
--------------------------------------------------------------------------
            when wait_for_uart_ready =>
            if ready_tx = '1' and end_message = '0' then
                next_state <= wait_for_uart_busy;
            elsif ready_tx = '1' and end_message = '1' then
                next_state <= wait_for_tempo;
            end if;

            start_uart <= '0';
            cmd_addr       <= '0';  --Mem
            ready      <= '0';
            cmd_tempo  <= '0';  --Set to 0
            
--------------------------------------------------------------------------
-- Wait for uart tempo   						                        --
--------------------------------------------------------------------------
            when wait_for_tempo =>
            if end_tempo = '1' then
                next_state <= wait_for_uart_busy;
            end if;
            start_uart <= '0';
            cmd_addr       <= '0';  --Mem
            ready      <= '0';
            if end_tempo = '1' then
                cmd_tempo  <= '0';  --Set to 0
            else
                cmd_tempo  <= '1';  --Inc
            end if;           

        end case;
    end process;
end architecture;