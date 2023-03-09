--Author : Abel DIDOUH
--Control Part Serial Transmission
--09 / 03 / 2023
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------
entity FSM is 
    port(
        clk         : in std_logic;
        resetn      : in std_logic;
        start       : in std_logic;
        end_data    : in std_logic;
        cmd_reg     : out std_logic_vector(1 downto 0);
        cmd_ctr     : out std_logic;
        cmd_tx      : out std_logic_vector(1 downto 0);
        ready       : out std_logic
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of FSM is
    type state is (idle, start_bit, data_bit);

    signal current_state    : state;
    signal next_state       : state;

    begin
        --register
        process(resetn, clk) is
            begin
                if resetn = '0' then
                    current_state <= idle;
                elsif rising_edge(clk) then
                    current_state <= next_state;
                end if;
        end process;
        
        process(current_state, start, end_data) is
            begin
                next_state  <= current_state;
                cmd_reg     <= "00";
                cmd_ctr     <= '0';
                cmd_tx      <= '0';
                
                case current_state is
                    when idle => 
                        if start = '1' then
                            next_state <= start_bit;
                        end if;
                        
                        cmd_reg <= "00";


