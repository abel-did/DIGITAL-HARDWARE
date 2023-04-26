--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     01 / 04 / 2023                                        --
-- Project  :     dmx_leds                                              --
-- Description :  dmx_leds                                              --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity dmx_leds is
  generic(   
    f_clk      : real     := 100.0E6;   -- Frequence de fonctionnement
    canal_leds : positive := 13;	-- Numero du 1er canal
    T_bit      : real     := 4.0E-6;    -- Duree d'un bit de la transmission UART
    T_c        : real     := 1.0
  );
  port (
    clk	     : in std_logic;		-- Horloge
    btnc     : in std_logic;		-- Init asynchrone
    btnu     : in std_logic;            -- Demarage de la trame DMX
    rx       : in std_logic;		-- Donnee UART recue (cable DMX)
    tx 	     : out std_logic;		-- Donnee UART transmise (cable DMX)
    set1     : out std_logic;           -- Signal a 1 (cable DMX)
    ready    : out std_logic            -- Systeme pret (en attente d'appui sur btnu)
  );
end entity;
--------------------------------------------------------------------------
architecture rtl of dmx_leds is  

  constant f_baud     : real      := real(1.0/T_bit);
  constant T1         : real      := real(22.0*T_bit);
  constant T2	      : real      := real(2.0*T_bit);
  constant X1         : positive  := integer(ceil( f_clk * real(T1) ));    --Arrondi sup 
  constant X2         : positive  := integer(ceil( f_clk * real(T2) ));    --Arrondi sup
  constant x 	      : positive  := integer(f_clk/real(f_baud));
  constant N          : positive  := 8;

  signal ctr_tempo    : natural range 0 to X1-1;
  signal cmd_tempo    : std_logic;
  signal end_T1       : std_logic;
  signal end_T2       : std_logic;
  signal srt_ctr_addr : std_logic_vector(8 downto 0);
  signal cmd_addr     : std_logic;
  signal end_channel  : std_logic;
  signal data         : std_logic_vector(7 downto 0);
  signal data_uart    : std_logic_vector(7 downto 0);
  signal cmd_uart     : std_logic;
  signal tx_uart      : std_logic;
  signal cmd_tx       : std_logic_vector(1 downto 0);
  signal start_uart   : std_logic;
  signal ready_tx     : std_logic;
  signal resetn       : std_logic;
  
  signal start_dmx    : std_logic;

  signal addr_spot      : std_logic_vector(N downto 0);
  signal cmd_mux_data   : std_logic;
    

  type state is (idle, break_state, mark, start0, start1, data0, data1);
  signal current_state    : state;
  signal next_state       : state;

begin
--------------------------------------------------------------------------
-- Structural Part                                                      --
--------------------------------------------------------------------------

    chenillard : entity work.chenillard
    generic map
    (
    	f_clk       => f_clk,
    	T_c         => T_c,
    	canal_leds  => canal_leds
    )
    port map (
        clk         =>  clk,
        resetn      =>  resetn,
        addr_spot   =>  addr_spot
    );

    uart_tx : entity work.uart_tx
    generic map
    (
    f_clk     => f_clk,
    f_baud    => f_baud,
    N         => 8
    )
    port map (
        clk         =>  clk,
        resetn      =>  resetn,
        data        =>  data_uart,
        start       =>  start_uart,
        ready       =>  ready_tx,
        tx          =>  tx_uart
    );
    
--------------------------------------------------------------------------
-- Opertive Part                                                        --
--------------------------------------------------------------------------
    set1 <= '1';
                
    data_uart <=  data when cmd_uart = '1' else
                  (others => '0');

    tx <=   tx_uart when cmd_tx = "10" else
            '1'     when cmd_tx = "01" else
            '0';

    resetn  <= not btnc;
        
    start_dmx <= btnu;
    
    cmd_mux_data <= '1' when unsigned(srt_ctr_addr) = unsigned(addr_spot) else
    		    '0';
    		    
    data 	 <= (others => '0') when cmd_mux_data = '0' else
    		    (others => '1');
      
    -- CTR TEMPO Part --
    -- Mise a 0...0
    -- Incrementation
    end_T1 <= '1' when ctr_tempo >= (X1 - 1) else
    '0';
    end_T2 <= '1' when ctr_tempo >= (X2 - 1) else
    '0';

    process(clk,resetn) is
    begin
      if resetn = '0' then
        ctr_tempo <= 0;
      elsif rising_edge(clk) then
        case cmd_tempo is
            when '1'    =>  ctr_tempo <= ctr_tempo + 1;         					-- Incrementation      
            when others =>  ctr_tempo <= 0;                     					-- Mise a 0
        end case;
      end if;
    end process;

    -- CTR ADDR Part --
    -- Incrementation
    -- Memorisation
    end_channel <= '1' when unsigned(srt_ctr_addr) = 0 else
                   '0';

    process(clk, resetn) is 
    begin
      if resetn = '0' then
        srt_ctr_addr <= (others => '0');
      elsif rising_edge(clk) then
        case cmd_addr is 
          when '1'    =>  srt_ctr_addr <= std_logic_vector(unsigned(srt_ctr_addr) + 1);               	-- Incrementation
          when others =>  srt_ctr_addr <= srt_ctr_addr;                   				-- Memorisation
        end case;
      end if;
    end process;

--------------------------------------------------------------------------
-- Control Part                                                         --
--------------------------------------------------------------------------

    process(clk, resetn) is
      begin
          if resetn = '0' then
              current_state <= idle;
          elsif rising_edge(clk) then
              current_state <= next_state;
          end if;
    end process;

    process(current_state, start_dmx, end_T1, end_T2, ready_tx, end_channel) is
    begin
      next_state <= current_state;

      ready           <= '1';
      cmd_tx          <= "01";
      start_uart      <= '0';
      cmd_addr        <= '0';     --Mem
      cmd_tempo       <= '0';     --Mise a 0
      cmd_uart        <= '0';     --Mise a 0

      case current_state is 
--------------------------------------------------------------------------
-- IDLE
--------------------------------------------------------------------------
          when idle =>
              if btnu = '1' then
                  next_state <= break_state;
              end if;

              ready           <= '1';
              cmd_tx          <= "01";
              start_uart      <= '0';
              cmd_addr        <= '0';     --Mem
              cmd_tempo       <= '0';     --Mise a 0
              cmd_uart        <= '0';     --Mise a 0
--------------------------------------------------------------------------
-- break_state
--------------------------------------------------------------------------
          when break_state => 
              if end_T1 = '1' then
                  next_state <= mark;
              end if;
          
              ready           <= '0';      
              cmd_tx          <= "00";    
              start_uart      <= '0';     
              cmd_addr        <= '0';     --Mem

              if end_T1 = '1' then
                  cmd_tempo   <= '0'; 	  -- Set to 0
              else
                  cmd_tempo   <= '1'; 	  -- Incrementation
              end if;

              cmd_uart        <= '0';     -- Set to 0
--------------------------------------------------------------------------
-- MARK 
--------------------------------------------------------------------------
          when mark => 
              if end_T2 = '1' then
                  next_state <= start0;
              end if;
              
              ready           <= '0';
              cmd_tx          <= "01";
              start_uart      <= '0';
              cmd_addr        <= '0';

              if end_T2 = '1' then          
                  cmd_tempo       <= '0';   --  Mise a 0
              else
                  cmd_tempo       <= '1';   --  Incr
              end if;
              
              cmd_uart        <= '0';
--------------------------------------------------------------------------
-- Start0
--------------------------------------------------------------------------
          when start0 => 
              if ready_tx = '0' then
                  next_state <= start1;
              end if;

              ready           <= '0';
              cmd_tx          <= "10";
              start_uart      <= '1';
              cmd_addr        <= '0';   --Mem
              cmd_tempo       <= '0';   --Mise a 0
              cmd_uart        <= '0';   --Mise a 0
--------------------------------------------------------------------------
-- Start1
--------------------------------------------------------------------------
          when start1 =>
              if ready_tx = '1' then 
                  next_state <= data0;
              end if;
              
              ready           <= '0';
              cmd_tx          <= "10";
              start_uart      <= '0';
              cmd_addr        <= '0';   --Mem
              cmd_tempo       <= '0';   --Mise a 0
              cmd_uart        <= '1';   -- data
--------------------------------------------------------------------------
-- Data0
--------------------------------------------------------------------------
          when data0 =>
              if ready_tx = '0' then
                  next_state <= data1;
              end if;
      
              ready           <= '0';
              cmd_tx          <= "10";
              start_uart      <= '1';

              if ready_tx = '0' then
                  cmd_addr <= '1';      --Incr
              else
                  cmd_addr <= '0';      --Mem
              end if;

              cmd_tempo       <= '0';   --Mise a 0
              cmd_uart        <= '1';   -- data
--------------------------------------------------------------------------
-- Data1
--------------------------------------------------------------------------
          when data1 =>
              if  ready_tx = '1'      and     end_channel = '0'   then
                  next_state <= data0; 
              elsif ready_tx = '1'  and     end_channel = '1'   then
                  next_state <= break_state;
              end if;

              ready           <= '0';
              cmd_tx          <= "10";
              start_uart      <= '0';
              cmd_addr        <= '0';   --Mem
              cmd_tempo       <= '0';   --Mise a 0
              cmd_uart        <= '1';   --data     
      end case;
    end process;
end architecture;
