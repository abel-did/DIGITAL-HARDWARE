--------------------------------------------------------------------------
-- Author : Abel DIDOUH	& Haythem HADDAR								--
-- Unit Name: DIGITAL HARDWARE											--
-- Date : 28 / 03 /2023													--
--------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--------------------------------------------------------------------------
entity dmx is
	generic(
		f_clk  : real     := 100.0E6; 
		T_bit  : real	  := 4.0E-6
	);
	port(
	    clk    : in  std_logic;
        resetn : in  std_logic;
        btnu   : in  std_logic;
	    rx     : in  std_logic;
	    tx     : out std_logic;
	    set1   : out std_logic;
	    ready  : out std_logic
	);
end entity;
--------------------------------------------------------------------------
architecture rtl of dmx is
	constant x1 		: positive := integer(f_clk / f_baud);
    constant x2 		: positive := integer(f_clk / f_baud);
    constant t1 		: positive := integer(22 * T_bit);
    constant t2			: positive := integer(2 * T_bit);
    constant f_blaud	: positive := integer(1 / t_bit);
    
    signal ctr_tempo	: natural range 0 to x-1;
	signal end_t1		: std_logic;
    signal end_t2		: std_logic;
    signal cmd_tempo 	: std_logic;



	type state is (idle, break_state, mark, start0, start1, data0, data1);
	signal current_state	: state;
	signal next_state		: state;
begin

--------------------------------------------------------------------------
-- Opertive Part														--
--------------------------------------------------------------------------


	-- CTR TEMPO Part --
	-- Mise a 0...0
	-- Incrementation
    
    end_t1 <= '1' when ctr_tempo >= (x1-1) else
    		  '0';
    end_t2 <= '1' when ctr_tempo >= (x2-1) else
    		  '0';
    
    process(clk,resetn) is
    begin
    		if resetn = '0' then
            		ctr_tempo <='0';
            elsif rising_edge(clk) then
            		case cmd_tempo is
                    		when '0' =>		ctr_tempo <= ctr_tempo +1;
                            when others => 	ctr_tempo <= 0;
                    end case;
            end if;
     end process;
     
     
    
    
    
    
    
--------------------------------------------------------------------------
-- Opertive Part														--
--------------------------------------------------------------------------


--------------------------------------------------------------------------
-- Control Part															--
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

        ready       <= '1';
        tx          <= '1';
        start_uart  <= '0';
        cmd_addr    <= 
        cmd_tempo   <= 
        cmd_uart    <= 

        case current_state is 
--------------------------------------------------------------------------
            when idle =>
                if btnu = '1' then
                    next_state <= break_state;
                end if;

                ready       <= '1';
                tx          <= '1';
                start_uart  <= '0';
                cmd_addr    <= 
                cmd_tempo   <= 
                cmd_uart    <= 

--------------------------------------------------------------------------
            when break_state => 
                if end_T1 = '1' then
                    next_state <= mark;
                end if;
            
                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ; 

--------------------------------------------------------------------------
            when mark => 
                if end_T2 '1' then
                    next_state <= start0;
                end if;
                
                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ;

--------------------------------------------------------------------------
            when start0 => 
                if ready_tx = '0' then
                    next_state <= start1;
                end if;

                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ;
--------------------------------------------------------------------------
            when start1 =>
                if ready_tx = '1' then 
                    next_state <= data0
                end if;
                
                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ;
--------------------------------------------------------------------------
            when data0 =>
                if ready_tx = '0' then
                    next_state <= data1;
                end if;

                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ;
            
--------------------------------------------------------------------------
            when data1 =>
                if  ready_tx = '1'      and end_channel = '0'   then
                    next_state <= data0; 
                else if ready_tx = '1'  and  end_channel = '1'  then
                    next_state <= break_state;
                end if;

                ready       <= ;
                tx          <= ;
                start_uart  <= ;
                cmd_addr    <= ;
                cmd_tempo   <= ;
                cmd_uart    <= ;

        end case;
end process;
end architecture;
