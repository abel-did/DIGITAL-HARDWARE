------------------------------------------
-- DMX512 : ROM
------------------------------------------
-- Creation : A. Exertier, 02/2021
------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_light is
  port (
    clk     : in  std_logic;
    address : in  std_logic_vector(8 downto 0);
    data    : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of rom_light is
  constant N : natural := address'length;
  type t_message is array (0 to 2**N-1) of std_logic_vector(data'range);
  constant message : t_message := (
    0   => X"FF",  
    1   => X"00",  
    2   => X"00",
    3   => X"00",
    4   => X"FF",
    5   => X"00",
    6   => X"00",
    7   => X"00",
    8   => X"FF",
    9   => X"FF",
    10  => X"FF",
    11  => X"FF",
    12  => X"FF",
    13  => X"FF",
    14  => X"00",
    15  => X"00",
    16  => X"FF",
    17  => X"FF",
    18  => X"FF",
    19  => X"00",
    20  => X"FF",  
    21  => X"80",  
    22  => X"80",
    23  => X"FF",
    24  => X"FF",
    25  => X"00",
    26  => X"00",
    27  => X"00",
    28  => X"FF",
    29  => X"00",
    30  => X"00",
    31  => X"00",
    32  => X"FF",
    33  => X"FF",
    34  => X"FF",
    35  => X"FF",
    36  => X"80",
    37  => X"00",
    38  => X"00",
    39  => X"00",
    40  => X"80",
    41  => X"00",
    42  => X"00",
    43  => X"00",
    44  => X"80",
    45  => X"80",
    46  => X"80",
    47  => X"80",
    others => X"00"
    );
    
begin
  process(clk)
  begin
    if rising_edge(clk) then
      data <= message(to_integer(unsigned(address)));
    end if;
  end process;    
end architecture;