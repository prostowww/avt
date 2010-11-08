--------------------------------------------------------------------------------
-- Filename: PIO_64_TX_ENGINE.vhd
--
-- Description: 64 bit Local-Link Transmit Unit.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PIO_64_TX_ENGINE is
	port
	(
		clk: 	in std_logic;
                rst_n:  in std_logic;

		fifo_data_out: out std_logic_vector(31 downto 0);
		fifo_data_out_en: out std_logic;
		sof_n: out std_logic;
		eof_n: out std_logic;

		req_compl_i:	in std_logic;
		req_dma_i:	in std_logic;
		compl_done_o:	out std_logic;
		req_tc_i:	in std_logic_vector(2 downto 0);
		req_td_i:	in std_logic;
		req_ep_i:	in std_logic;
		req_attr_i:	in std_logic_vector(1 downto 0);
		req_len_i:	in std_logic_vector(9 downto 0);
		req_rid_i:	in std_logic_vector(15 downto 0);
		req_tag_i:	in std_logic_vector(7 downto 0);
		req_be_i:	in std_logic_vector(7 downto 0);
		req_addr_i:	in std_logic_vector(31 downto 0);
		dma_memory_start_i: in std_logic_vector(31 downto 0);

		rd_addr_o:	out std_logic_vector(23 downto 0);
		rd_be_o:	out std_logic_vector(3 downto 0);
    		rd_data_i:	in std_logic_vector(31 downto 0);

                completer_id_i:	in std_logic_vector(15 downto 0);
                cfg_bus_mstr_enable_i: in std_logic;
		wr_busy_i: in std_logic

                        );
end entity PIO_64_TX_ENGINE;

architecture IMP of PIO_64_TX_ENGINE is

    constant MEM_RD32_FMT_TYPE: std_logic_vector(6 downto 0) := "0000000";
    constant MEM_WR32_FMT_TYPE: std_logic_vector(6 downto 0) := "1000000";
    constant CPL_3DWD_FMT_TYPE: std_logic_vector(6 downto 0) := "1001010";

    signal l_fifo_data_out: std_logic_vector(31 downto 0);
    signal l_fifo_data_out_en: std_logic;
    signal l_sof_n: std_logic;
    signal l_eof_n: std_logic;
    signal stage: std_logic_vector(3 downto 0);
    signal req_compl_i_dly1: std_logic;
    signal tag: std_logic_vector(4 downto 0);
    signal wcount: std_logic_vector(9 downto 0);
    signal l_rd_addr_o: std_logic_vector(23 downto 0);
    signal pad_needed: std_logic;
    signal remember_start: std_logic;

begin
	fifo_data_out <= l_fifo_data_out;
	fifo_data_out_en <= l_fifo_data_out_en;
	sof_n <= l_sof_n;
	eof_n <= l_eof_n;
	rd_addr_o <= l_rd_addr_o;
--
	TX_PROC: process( clk ) is
	begin
	  if clk'event and clk = '1' then
	    if rst_n = '0' then
	      compl_done_o <= '1';
	      l_sof_n <= '1';
	      l_eof_n <= '1';
	      l_fifo_data_out_en <= '0';
	      stage <= "0000";
	      req_compl_i_dly1 <= '1';
	      tag <= (others => '0');
	      wcount <= (others => '0');
	      pad_needed <= '0';
	      remember_start <= '0';
            else 
	      req_compl_i_dly1 <= req_compl_i;
	      case stage is 
	        when "0000" =>
	          if ( (req_compl_i_dly1 = '0' and req_compl_i = '1') or remember_start = '1' ) then
		    if ( wr_busy_i = '0' ) then
		      remember_start <= '0';
		      compl_done_o <= '0';
		      wcount <= req_len_i;
		      pad_needed <= not req_len_i(0);
		      if ( req_dma_i = '0' ) then
		        l_fifo_data_out <= "0" & CPL_3DWD_FMT_TYPE 
					     & "0" & req_tc_i & "0000" & req_td_i & req_ep_i 
		                             & req_attr_i & "00" & req_len_i;
		      else
		        l_fifo_data_out <= "0" & MEM_WR32_FMT_TYPE
					     & "0" & req_tc_i & "0000" & req_td_i & req_ep_i 
		                             & req_attr_i & "00" & req_len_i;
		      end if;
		      l_sof_n <= '0';
		      l_eof_n <= '1';
		      l_fifo_data_out_en <= '1';
-- We need to do it here, not 1 clock later, to provide a proper EN:		      
		      l_rd_addr_o <= "00" & req_addr_i(23 downto 2);
		      stage <= "0001";
		    else
		      remember_start <= '1';
		    end if;
		  end if;    
		when "0001" =>
		  if ( wr_busy_i = '0' ) then
		    l_sof_n <= '1';
		    if ( req_dma_i = '0' ) then
		      l_fifo_data_out <= completer_id_i & "0000" & req_len_i & "00";
		    else
		      if ( wcount = "0000000001" ) then
		        l_fifo_data_out <= completer_id_i & "000" & tag & "00001111";
		      else  
		        l_fifo_data_out <= completer_id_i & "000" & tag & "11111111";
		      end if;  
		      tag <= tag + "00001";
		    end if;    
		    l_rd_addr_o <= "00" & req_addr_i(23 downto 2);
		    stage <= "0010";
		  end if;
		when "0010" =>
		  if ( wr_busy_i = '0' ) then
		    if ( req_dma_i = '0' ) then
		      l_fifo_data_out <= req_rid_i & req_tag_i & "0" & req_addr_i(6 downto 2) & "00";
		    else
		      l_fifo_data_out <= dma_memory_start_i;
		    end if;    
		    wcount <= wcount - "0000000001";
		    l_rd_addr_o <= l_rd_addr_o + "000000000000000000000001";
		    stage <= "0011";
		  end if;
		when "0011" =>
		  if ( wr_busy_i = '0' ) then
		    if ( req_dma_i = '1' and req_addr_i = "11111111111111111111111111111111" ) then
		      l_fifo_data_out <= "00000001000000000000000000000000";
		    else
		      l_fifo_data_out <= rd_data_i;
		    end if;    
		    if ( wcount = "0000000000" ) then
		      l_eof_n <= '0';
		      stage <= "0100";
		    else
		      wcount <= wcount - "0000000001";
		      l_rd_addr_o <= l_rd_addr_o + "000000000000000000000001";
		    end if;    
		  end if;
		when "0100" =>
		  if ( wr_busy_i = '0' ) then
		    l_eof_n <= '1';
		    if ( pad_needed = '0' ) then
		      l_fifo_data_out_en <= '0';
		      compl_done_o <= '1';
		      stage <= "0000";
		    else
-- output a pad - an out-of-frame word:
		      l_fifo_data_out <= (others => '0');
		      stage <= "0101";
		    end if;
		  end if;
		when "0101" =>
		  if ( wr_busy_i = '0' ) then
		    l_fifo_data_out_en <= '0';
		    compl_done_o <= '1';
		    stage <= "0000";
		  end if;
		when others => null;
	      end case;	  
	    end if;
	  end if;
        end process TX_PROC; 
end IMP;
