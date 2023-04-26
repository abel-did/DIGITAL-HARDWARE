library ieee;
use ieee.std_logic_1164.all;

entity top_basys3_tp2 is

  port (
    -- CLOCK SIGNAL ----------------------------------------
    -- NE PAS MODIFIER (display_controller)
    clk  : in  std_logic;
    -- SWITCHES --------------------------------------------
    sw :  in std_logic_vector(14 downto 0);    
    -- LEDS ------------------------------------------------
    led: out std_logic_vector(0 downto 0);
    -- 7 SEGMENT DISPLAY -----------------------------------
    -- NE PAS MODIFIER (display_controller)
    --seg  : out std_logic_vector(6 downto 0);
    --dp   : out std_logic;
    --an   : out std_logic_vector(3 downto 0);
    -- BUTTONS ---------------------------------------------
    --btnc: in std_logic;
    --btnl: in std_logic;
    --btnr: in std_logic;
    --btnd: in std_logic;
    -- NE PAS MODIFIER : utilisé par display_controller
    btnu : in  std_logic
   -- PMOD HEADER JA --------------------------------------
   -- ja: in/out/inout? std_logic_vector(7 downto 0);
   -- PMOD HEADER JB --------------------------------------
   -- jb: in/out/inout? std_logic_vector(7 downto 0);
   -- PMOD HEADER JC --------------------------------------
   -- jc: in/out/inout? std_logic_vector(7 downto 0);
   -- PMOD HEADER JXADC -----------------------------------
   -- jcxadc: in/out/inout? std_logic_vector(7 downto 0);
   -- VGA CONNECTOR ---------------------------------------
   -- vgared  : out std_logic_vector(3 downto 0);
   -- vgablue : out std_logic_vector(3 downto 0);
   -- vgagreen: out std_logic_vector(3 downto 0);
   -- USB-RS232 INTERFACE ---------------------------------
   -- rsrx :  in std_logic;
   -- rstx : out std_logic;
   -- USB HID (PS/2) --------------------------------------
   -- ps2clk: out std_logic;
   -- ps2data: inout std_logic;
   -- QUAD SPI FLASH --------------------------------------
   -- CCLK_0 cannot be placed in 7 series devices.
   -- You can access it using the STARTUPE2 primitive.
   -- qspidb: out/in/inout QspiDB(3 downto 0);
   -- qspicsn: out std_logic
    );

end;

architecture inst of top_basys3_tp2 is
  -- NE PAS MODIFIER : utilisé par display_controller
  
  
  signal  resetn 	: 	std_logic;
  signal  cmd		:   std_logic_vector(1 downto 0);
  signal  pwm       :   std_logic;
  
-- Ajouter ici vos éventuelles déclarations de signaux
  
begin

  -- Ajouter ici l'instantiation de sub


  -- NE PAS MODIFIER : utilisé par display_controller
  resetn <= not btnu;

  -- NE PAS MODIFIER : utilisé par display_controller
  impl : entity work.dimmer
    port map(clk          => clk,
             resetn       => resetn,
             pwm => led(0),
             cmd => sw(1 downto 0)
            );
end;

