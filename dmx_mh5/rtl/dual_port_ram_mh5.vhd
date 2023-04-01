library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_ram_MH5 is
  port (  
    clk  : in  std_logic ;  
    -- ecriture : ports A
    we_a   : in  std_logic ; 
    di_a   : in  std_logic_vector(7 downto 0);
    do_a   : out std_logic_vector(7 downto 0);
    addr_a : in  std_logic_vector(3 downto 0);
    -- lecture : ports B
    addr_b : in  std_logic_vector(3 downto 0);
    do_b   : out std_logic_vector(7 downto 0)
  );  
end entity;

architecture rtl of dual_port_ram_MH5 is  
  subtype word_t is std_logic_vector(7 downto 0);
  type memory_t is array(0 to 15) of word_t;
  -- init the RAM
  constant init_ram   : memory_t :=(
    0  => X"FF",   -- graduateur, reglage rapide
    1  => X"00",   -- graduateur, reglage fin
    2  => X"FF",   -- stroboscope (FF :ouvert)
    3  => X"00",   -- roue de couleur 1 (0 : blanc)
    4  => X"0F",   -- roue de couleur 2 (0 : blanc)
    5  => X"1C",   -- roue de gobos1 (gobos tournants)
    6  => X"00",   -- indexation et rotation des gobos (roue1)
    7  => X"00",   -- roue de gobos2 (gobos fixes)
    8  => X"00",   -- prisme ( 0 : ouvert)
    9  => X"00",   -- rotation du prisme
    10 => X"98",   -- mise au net
    11 => X"04",   -- pan ( 0° -> 540°) : MSB
    12 => X"00",   -- pan ( 0° -> 540°) : LSB
    13 => X"20",   -- pan ( 0° -> 270°) : MSB  
    14 => X"00",   -- pan ( 0° -> 270°) : LSB
    15 => X"00"     -- configuration et controle de l'appareil (0 : sans effet)
  );
  -- Declare the RAM
  shared variable ram : memory_t := init_ram;
begin

  -- Port A : write
  process(clk) is
  begin
    if rising_edge(clk) then 
      if we_a = '1' then
        ram(to_integer(unsigned(addr_a))) := di_a;
      end if;
    end if;
  end process;
  
  -- Port A : read
  process(clk) is
  begin
    if rising_edge(clk) then
      do_a <= ram(to_integer(unsigned(addr_a)));
    end if;
  end process;
  
  -- Port B : read
  process(clk)is
  begin
    if rising_edge(clk) then
      do_b <= ram(to_integer(unsigned(addr_b)));
    end if;
  end process;
end architecture;

