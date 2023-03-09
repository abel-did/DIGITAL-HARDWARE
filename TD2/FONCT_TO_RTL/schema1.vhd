--DIDOUH Abel
--Schema 1
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------
entity reg_entity is
    generic(
        N : positive := 8
    );
    port(
        clk     : in std_logic;
        resetn  : in std_logic;
        data    : in std_logic_vector(N downto 0);
        reg     : out std_logic_vector( N downto 0)
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of reg_entity is 
    begin
    process(clk, resetn, data) is
        begin
            if resetn = '0' then 
                reg <= (others => '0');
            elsif rising_edge(clk) then
                case cmd_reg is
                    when "00" => 
                        reg <= data;
                    when "01" =>
                        reg <= '0' & reg(N-1 downto 0);
                    when others =>
                        reg <= reg;
                end case;
            end if;
    end process;
end architecture;