--------------------------------------------------------------------------
-- Author   :     Abel DIDOUH                                           --
-- Date     :     01 / 04 / 2023                                        --
-- Project  :     DMX                                                   --
-- Description :  DMX                                                   --
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity dmx_MH5 is
  generic(
    canal_MH5  : positive := 100;
    T_bit      : real     := 4.0E-6;    -- 4 us
    f_clk      : real     := 100.0E6    -- 100 MHz
  );
  port (
    btnc     : in  std_logic;                       -- initialisation asynchrone
    btnu     : in  std_logic;                       -- pour demarrer la comm DMX
    btnd     : in  std_logic;                       -- pour configurer un canal du MH5
    sw       : in  std_logic_vector(15 downto 0);   -- sw(15:12) : n°canal -1
                                                    -- sw(7:0)   : valeur binaire du canal
    clk      : in  std_logic;
    ready    : out std_logic;
    -- afficheurs 7 segments
    seg      : out std_logic_vector(6 downto 0);
    dp       : out std_logic;
    an       : out std_logic_vector(3 downto 0);
    -- dmx JB
    tx       : out std_logic;
    set1     : out std_logic;
    rx       : in  std_logic
  );
end entity;
--------------------------------------------------------------------------
architecture rtl of dmx_MH5 is  

  constant f_baud     : real      := real(1.0/T_bit);
  constant T1         : real      := real(22.0*T_bit);
  constant T2		      : real      := real(2.0*T_bit);
  constant X1         : positive  := integer(ceil( f_clk * real(T1) ));    --Arrondi sup 
  constant X2         : positive  := integer(ceil( f_clk * real(T2) ));    --Arrondi sup
  constant x 		      : positive  := integer(f_clk/real(f_baud));
  constant N          : positive  := 8;

  signal ctr_tempo    : natural range 0 to X1-1;
  signal cmd_tempo    : std_logic;
  signal end_T1       : std_logic;
  signal end_T2       : std_logic;
  signal srt_ctr_addr : std_logic_vector(8 downto 0);
  signal cmd_addr 	  : std_logic;
  signal end_channel	: std_logic;
  signal data         : std_logic_vector(7 downto 0);
  signal data_uart    : std_logic_vector(7 downto 0);
  signal cmd_uart     : std_logic;
  signal tx_uart      : std_logic;
  signal cmd_tx       : std_logic_vector(1 downto 0);
  signal start_uart	  : std_logic;
  signal ready_tx     : std_logic;
  signal resetn       : std_logic;

  signal addr_canal_mh5 : std_logic_vector(3 downto 0);
  signal data_mh5_b     : std_logic_vector(N-1 downto 0);
  signal data_mh5_a     : std_logic_vector(N-1 downto 0);

  signal srt_DFF_1      : std_logic;
  signal srt_DFF_2      : std_logic;
  signal srt_DFF_3      : std_logic;
  signal rise_btnd      : std_logic;

  type state is (idle, break_state, mark, start0, start1, data0, data1);
  signal current_state    : state;
  signal next_state       : state;

begin
--------------------------------------------------------------------------
-- Structural Part                                                      --
--------------------------------------------------------------------------

    dual_port_ram_mh5 : entity work.dual_port_ram_mh5
    port map (
        clk         =>  clk,
        addr_b      =>  addr_canal_mh5,
        we_a        =>  rise_btnd,  
        di_a        =>  sw(7 downto 0),
        addr_a      =>  sw(15 downto 12),
        do_a        =>  data_mh5_a,    
        do_b        =>  data_mh5_b
    );

    uart_tx : entity work.uart_tx
    generic map
    (
    f_clk     => f_clk,
    f_baud    => f_baud,
    N         => N
    )
    port map (
        clk         =>  clk,
        resetn      =>  resetn,
        data        =>  data_uart,
        start       =>  start_uart,
        ready       =>  ready_tx,
        tx          =>  tx_uart
    );

    hexa_display_controller : entity work.hexa_display_controller
    generic map
    (
      f_clk   => f_clk,
      f_scan  => 100.0
    );
    port map (
      clk           =>  clk,
      resetn        =>  resetn,
      en            =>  "1111",
      dot_point     =>  "1111",
      hexa0         =>  data_mh5_a(3 downto 0),
      hexa1         =>  data_mh5_a(7 downto 4),
      hexa2         =>  (others => '0'),
      hexa3         =>  sw(15 downto 12),
      seg           =>  seg, 
      dp            =>  dp,
      an            =>  an
    );

--------------------------------------------------------------------------
-- Opertive Part                                                        --
--------------------------------------------------------------------------
    data      <=  data_mh5_b when (unsigned(addr) >= (canal_mh5-1) and (canal_mh5-1)+15 >= unsigned(addr)) else
                  (others => '0');
                
    data_uart <=  data when cmd_uart = '1' else
                  (others => '0');

    tx <=   tx_uart when cmd_tx = "10" else
            '1'     when cmd_tx = "01" else
            '0';

    resetn  <= not btnc;

    set1 <= '1';

    ----------------------------------------------------------------------
    --Detection de front montant
    ----------------------------------------------------------------------
    process(clk, resetn) is
      begin
        if resetn = '0' then
          srt_DFF_1 <= '0';
        elsif rising_edge(clk) then
          srt_DFF_1 <= btnd;
        end if;
    end process;

    process(clk, resetn) is
      begin
        if resetn = '0' then
          srt_DFF_2 <= '0';
        elsif rising_edge(clk) then
          srt_DFF_2 <= srt_DFF_1;
        end if;
    end process;

    in_DFF_3 <= srt_DFF_1 and (not srt_DFF_2);

    process(clk, resetn) is
      begin
        if resetn = '0' then
          srt_DFF_3 <= '0';
        elsif rising_edge(clk) then
          srt_DFF_3 <= in_DFF_3;
        end if;
    end process;

    rise_btnd <= srt_DFF_3;
    ----------------------------------------------------------------------

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
            when '1'    =>  ctr_tempo <= ctr_tempo + 1;         -- Incrementation      
            when others =>  ctr_tempo <= 0;                     -- Mise a 0
        end case;
      end if;
    end process;

    -- CTR ADDR Part --
    -- Incrementation
    -- Memorisation
    end_channel <= '1' when unsigned(srt_ctr_addr) = 0 else
                   '0';
    addr_canal_mh5 <= std_logic_vector(unsigned(srt_ctr_addr) - unsigned(canal_mh5 - 1));

    process(clk, resetn) is 
    begin
      if resetn = '0' then
        srt_ctr_addr <= (others => '0');
      elsif rising_edge(clk) then
        case cmd_addr is 
          when '1'    =>  srt_ctr_addr <= std_logic_vector(unsigned(srt_ctr_addr) + 1);               	-- Incrementation
          when others =>  srt_ctr_addr <= srt_ctr_addr;                   				                      -- Memorisation
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

    process(current_state, btnu, end_T1, end_T2, ready_tx, end_channel) is
    begin
      next_state <= current_state;

      ready           <= '1';
      cmd_tx          <= "01";
      start_uart      <= '0';
      cmd_addr        <= '0';
      cmd_tempo       <= '0';
      cmd_uart        <= '0';

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