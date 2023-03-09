--Author : Abel DIDOUH
--Operative Part Serial Transmission
--09 / 03 / 2023
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------
entity operative_part is
    generic(
        N   : positive := 8
    );
    --I/O
    port(
        clk         : in std_logic;
        resetn      : in std_logic;
        cmd_reg     : in std_logic_vector(1 downto 0);
        cmd_ctr     : in std_logic;
        cmd_tx      : in std_logic_vector(1 downto 0);
        data        : in std_logic_vector(N-1 downto 0);
        end_data    : out std_logic;
        tx          : out std_logic
    );
end entity;

architecture rtl of operative_part is
    signal reg : std_logic_vector(N-1 downto 0);
    signal end_data_int : std_logic_vector(2 downto 0);
begin 
   
--Circuit REG

    process(clk, resetn, data) is 
    begin 
        if resetn = '0' then    
            reg <= (others => '0');
        elsif rising_edge(clk) then
            case cmd_reg is
                when "00" =>
                    reg <= data(N-1 downto 0);
                when "01" =>
                    reg <= '0' & reg(N-2 downto 0);
                when others =>
                    reg <= reg;
            end case;
        end if;
    end process;

--Circuit TX
    tx <=   0 when cmd_tx = "00" else
        1 when cmd_tx = "01" else
        reg(0);

--Circuit CTR

    process(clk, resetn) is 
    begin 
        if resetn = '0' then
            end_data_int <= (others => '0');
        elsif rising_edge(clk) then
            case cmd_ctr is
                when '0' =>
                    end_data_int <= (others => '0');
                when others =>
                    end_data_int <= end_data_int + 1;
            end case;
        end if;
    end process;

    end_data <= 1 when (end_data_int >= 7) else
                0;
end architecture; 
