----------------------------------------
--  Basys 2 display controller
----------------------------------------
-- Creation     : 10/2013, A. Exertier
-- Modification : 08/2014, A. Exertier
-- Modification : 02/2017, A. Exertier
----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity hexa_display_controller is 
  generic (
    f_clk  : real := 50_000_000.0;
    f_scan : real := 100.0
  );
  port (
    clk       : in  std_logic;
    resetn    : in  std_logic;
    hexa0     : in  std_logic_vector(3 downto 0);
    hexa1     : in  std_logic_vector(3 downto 0);
    hexa2     : in  std_logic_vector(3 downto 0);
    hexa3     : in  std_logic_vector(3 downto 0);
    dot_point : in  std_logic_vector(3 downto 0);
    en        : in  std_logic_vector(3 downto 0);
    seg       : out std_logic_vector(6 downto 0);
    dp        : out std_logic;
    an        : out std_logic_vector(3 downto 0)
    
  );
end entity ;

architecture rtl of hexa_display_controller is
  constant x : positive := integer(ceil(f_clk/4.0/f_scan)); 
 
  signal ctr         : natural range 0 to (x-1);
  signal reg_an      : std_logic_vector(3 downto 0);
  
  signal hexa        : std_logic_vector(3 downto 0);
  signal gfedcba     : std_logic_vector(6 downto 0);
  signal dot         : std_logic;
  signal en_i        : std_logic;

  
begin
  an <= reg_an;
-- decodeur 7 segments
  process (hexa) is
  begin
    case hexa is
      when "0000" => gfedcba <= "1000000";  -- 0
      when "0001" => gfedcba <= "1111001";  -- 1
      when "0010" => gfedcba <= "0100100";  -- 2
      when "0011" => gfedcba <= "0110000";  -- 3
      when "0100" => gfedcba <= "0011001";  -- 4
      when "0101" => gfedcba <= "0010010";  -- 5
      when "0110" => gfedcba <= "0000010";  -- 6
      when "0111" => gfedcba <= "1111000";  -- 7
      when "1000" => gfedcba <= "0000000";  -- 8
      when "1001" => gfedcba <= "0010000";  -- 9
      when "1010" => gfedcba <= "0001000";  -- A
      when "1011" => gfedcba <= "0000011";  -- B
      when "1100" => gfedcba <= "1000110";  -- C
      when "1101" => gfedcba <= "0100001";  -- D
      when "1110" => gfedcba <= "0000110";  -- E
      when others => gfedcba <= "0001110";  -- F
    end case;
  end process;

-- multiplexage
 process(reg_an, hexa0, hexa1, hexa2, hexa3, en, dot_point)  is
 begin
   case reg_an is
     when "0111"|"0000" => -- afficheur 0
       en_i <= en(0);
       dot  <= dot_point(0);
       hexa <= hexa0; 
     when "1110" => -- afficheur 1
       en_i <= en(1);
       dot  <= dot_point(1);
       hexa <= hexa1; 
     when "1101" => -- afficheur 2
       en_i <= en(2);
       dot  <= dot_point(2);
       hexa <= hexa2; 
     when "1011" => -- afficheur 3
       en_i <= en(3);
       dot  <= dot_point(3);
       hexa <= hexa3; 
     when others =>
       en_i <= '0';
       dot  <= '0';
       hexa <= X"0"; 
   end case;
 end process;
 
-- compteur de temporisation et registres
  process(resetn,clk) is
  begin
    if resetn = '0'        then 
       ctr    <= 0;
       seg    <= (others => '0');
       dp     <= '0';
       reg_an <= (others => '0');
    elsif rising_edge(clk) then
      if ctr >= (x-1) then
        ctr <= 0;
        if reg_an = X"0" then
          reg_an <= "1110";
        else
          reg_an <= reg_an(2 downto 0)&reg_an(3);
        end if;
        
        if en_i = '1' then
          seg <= gfedcba;
          dp  <= dot;
        else 
          seg <= (others => '1');
          dp  <= '1';
        end if;
      else
        ctr <= ctr+1;
      end if;   
     
    end if;
  end process;

end architecture;