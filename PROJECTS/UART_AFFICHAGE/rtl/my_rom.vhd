------------------------------------------
-- Rom contenant un texte ASCII (un caractere = 8 bits)
-------------------------------------------
-- Creation      : 05/2020, Y. Blanchard
-- Modification  : 08/2020, A. Exertier


library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------
--        GENERIC PARAMETERS
-------------------------------------------
-- N_addr  : nombre de bits de l'adresse
-- message : contenu de la memoire specifie en texte 
--           (chaine de caracteres)
-------------------------------------------
--           INPUTS
-------------------------------------------
-- clk      : clock
-- address  : address
-------------------------------------------
--           OUTPUTS
-------------------------------------------
-- data      : donnee de 8 bits (ASCII code)
-------------------------------------------


entity my_rom is 
  generic ( 
    N_addr  : positive := 5;
    message : string   := "Message contenu par la ROM"
    );
  port (
    clk     : in  std_logic;
    address : in  std_logic_vector(N_addr-1 downto 0);
    data    : out std_logic_vector(7 downto 0)
  );
begin
end entity;

architecture rtl of my_rom is
  -- declaration d'un type tableau d'octets pour la memoire
  type t_rom is array(natural range 0 to 2**N_Addr-1) of std_logic_vector(data'range);
  
  -- declaration d'une fonction qui permet d'initialiser la memoire
  -- la fonction convertit la chaine de caracteres en binaire
  -- si le message est plus court que ce que peut contenir la memoire
  -- on remplit avec 0x00 
  function init_rom(mes : string) return t_rom is
    variable tmp_rom: t_rom := (others => X"00");
  begin
   tmp_rom(0) := X"0A"; -- line feed
   tmp_rom(1) := X"0D";  -- carriage return
   for i in 0 to mes'high-1 loop
      exit when i+2 > 2**N_addr-1;
      tmp_rom(i+2) := std_logic_vector(to_unsigned(character'pos(message(i+1)), data'length));
   end loop;
   return tmp_rom; 
  end function;  
  
 constant my_memory : t_rom := init_rom(message); 
 
begin  
  process(clk)
  begin
    if rising_edge(clk) then
      data <= my_memory(to_integer(unsigned(address)));
    end if;
  end process;    
end architecture;
