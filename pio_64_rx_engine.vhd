--------------------------------------------------------------------------------
-- Filename: PIO_64_RX_ENGINE.vhd
--
-- Description: 64 bit Local-Link Receive Unit.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PIO_64_RX_ENGINE is
	port
	(
		clk:	in std_logic;
		rst_n:	in std_logic;
                    
		fifo_data_in:   in std_logic_vector(31 downto 0);
		fifo_data_in_ready: in std_logic;
		sof_n:		in std_logic;
		eof_n:		in std_logic;
		rbar_hit_n:	in std_logic_vector(1 downto 0);

		req_compl_o:	out std_logic;
		req_dma_o:	out std_logic;
		compl_done_i:	in std_logic;
		req_tc_o:	out std_logic_vector(2 downto 0);
		req_td_o:	out std_logic;
		req_ep_o:	out std_logic;
		req_attr_o:	out std_logic_vector(1 downto 0);
		req_len_o:	out std_logic_vector(9 downto 0);
		req_rid_o:	out std_logic_vector(15 downto 0);
		req_tag_o:	out std_logic_vector(7 downto 0);
		req_be_o:	out std_logic_vector(7 downto 0);
		req_addr_o:	out std_logic_vector(31 downto 0);
		dma_memory_start_o: out std_logic_vector(31 downto 0); 
	
		wr_addr_o:	out std_logic_vector(23 downto 0);
    		wr_data_o:	out std_logic_vector(31 downto 0);
		wr_en_o:	out std_logic;
		wr_busy_i:	in std_logic;
		
		compltag_o:	out std_logic_vector(7 downto 0);
		compldata_o:	out std_logic_vector(31 downto 0);
		complwe_o:	out std_logic
	);
end entity PIO_64_RX_ENGINE;


architecture IMP of PIO_64_RX_ENGINE is

    constant MEM_RD32_FMT_TYPE: std_logic_vector(6 downto 0) := "0000000";
    constant MEM_WR32_FMT_TYPE: std_logic_vector(6 downto 0) := "1000000";
    constant CPL_3DWD_FMT_TYPE: std_logic_vector(6 downto 0) := "1001010";
    constant MAXPAYLOAD       : std_logic_vector(31 downto 0) := "00000000000000000000000010000000";

    signal stage: std_logic_vector(4 downto 0);
    signal wcount: std_logic_vector(9 downto 0);
    signal totalcount: std_logic_vector(9 downto 0);
    
    signal l_wr_addr_o: std_logic_vector(23 downto 0);
    signal l_wr_data_o: std_logic_vector(31 downto 0);
    signal l_wr_en_o: std_logic;
    
    signal reqtc: std_logic_vector(2 downto 0);
    signal reqtd: std_logic;
    signal reqep: std_logic;
    signal reqattr: std_logic_vector(1 downto 0);
    signal reqlen: std_logic_vector(9 downto 0);
    signal reqrid: std_logic_vector(15 downto 0);
    signal reqtag: std_logic_vector(7 downto 0);
    signal reqbe: std_logic_vector(7 downto 0);
    signal reqaddr: std_logic_vector(31 downto 0);
    signal compl_done_i_dly1: std_logic;
    signal dma_request_address: std_logic_vector(7 downto 0);
    signal dma_memory_start: std_logic_vector(31 downto 0);
    signal dma_memory_start_current: std_logic_vector(31 downto 0);
    signal dma_done_address: std_logic_vector(31 downto 0);
    signal transmit_dma_done: std_logic;
    signal dma_current_address: std_logic_vector(31 downto 0);

begin
	wr_addr_o <= l_wr_addr_o;
	wr_data_o <= l_wr_data_o;
	wr_en_o <= l_wr_en_o;
	l_wr_data_o <= fifo_data_in;
	l_wr_en_o <= '1' when stage = "00011" and fifo_data_in_ready = '1' and wr_busy_i = '0' else '0';
	compldata_o <= fifo_data_in;
	complwe_o <= '1' when stage = "01010" and fifo_data_in_ready = '1' else '0';
	
	req_tc_o <= reqtc;
	req_td_o <= reqtd;
	req_ep_o <= reqep;
	req_attr_o <= reqattr;
	req_len_o <= reqlen;
	req_rid_o <= reqrid;
	req_tag_o <= reqtag;
	req_be_o <= reqbe;
	req_addr_o <= reqaddr;
	dma_memory_start_o <= dma_done_address when reqaddr = "11111111111111111111111111111111" else dma_memory_start_current;

	RX_PROC: process ( clk ) is
	begin
	  if clk'event and clk = '1' then
	    if rst_n = '0' then
              l_wr_addr_o      <= (others => '0');
	      stage            <= "00000";
	      wcount	       <= (others => '0');

	      reqtc	       <= (others => '0');
	      reqtd  	       <= '0';
	      reqep            <= '0';
	      reqattr          <= (others => '0');
	      reqlen           <= (others => '0');
	      reqrid           <= (others => '0');
	      reqtag           <= (others => '0');
	      reqbe            <= (others => '0');
	      reqaddr          <= (others => '0');
	      req_compl_o      <= '0';
	      req_dma_o        <= '0';
	      compl_done_i_dly1 <= '1';
	      dma_request_address <= (others => '0');
	      dma_memory_start <= (others => '1');
	      dma_memory_start_current <= (others => '1');
	      dma_done_address <= (others => '1');
	      transmit_dma_done <= '0';
	      totalcount <= (others => '1');
	      dma_current_address <= (others => '1');

            else 
	      compl_done_i_dly1 <= compl_done_i;
-- stages 000xx are for command discovery and write requests,
-- stages 001xx are for read requests,
-- stages 010xx are for completions,
-- stages 011xx and 1xxxx are for dma requests:
	      case stage is
		when "00000" =>
--
-- frame start:
--
		  if ( fifo_data_in_ready = '1' and sof_n = '0') then
		    wcount <= fifo_data_in(9 downto 0); 
		    if ( fifo_data_in(29 downto 24) = MEM_WR32_FMT_TYPE(5 downto 0) ) then
		      if ( fifo_data_in(30) = MEM_RD32_FMT_TYPE(6) ) then

		        reqlen <= fifo_data_in(9 downto 0); 
		        reqtc <= fifo_data_in(22 downto 20);
			reqtd <= fifo_data_in(15);
			reqep <= fifo_data_in(14);
			reqattr <= fifo_data_in(13 downto 12);

			stage <= "00100";
		      else
		        if ( rbar_hit_n(0) = '0' ) then
		          stage <= "00001";
			else
		          reqtc <= fifo_data_in(22 downto 20);
			  reqtd <= fifo_data_in(15);
			  reqep <= fifo_data_in(14);
			  reqattr <= fifo_data_in(13 downto 12);
			  
			  stage <= "01100";  
			end if;  
		      end if;
		    else
		      if ( fifo_data_in(30 downto 24) = CPL_3DWD_FMT_TYPE ) then
		        stage <= "01000";
		      end if;
		    end if;
		  end if;
		when "00001" =>
--
-- read and ignore the next word:
--
                  if (fifo_data_in_ready = '1') then 
		    stage <= "00010";
		  end if;
		when "00010" =>
--
-- read the write request address:
--
                  if (fifo_data_in_ready = '1') then 
		    l_wr_addr_o <= "00" & fifo_data_in(23 downto 2);
		    wcount <= wcount - "0000000001";
		    stage <= "00011";
		  end if;
		when "00011" =>
--
-- send the buffered word:
--
		  if ( fifo_data_in_ready = '1' and wr_busy_i = '0' ) then
		    l_wr_addr_o <= l_wr_addr_o + "000000000000000000000001";
		    wcount <= wcount - "0000000001";
		    if ( wcount = "0000000000" ) then 
		      stage <= "00000";
		    end if;  
		  end if;
---
--    read request states:
---
		when "00100" =>
--
-- read the next word:
--
                  if (fifo_data_in_ready = '1') then 
		    reqrid <= fifo_data_in(31 downto 16);
		    reqtag <= fifo_data_in(15 downto 8);
		    reqbe <= fifo_data_in(7 downto 0);
		    stage <= "00110";
		  end if;
		when "00110" =>
--
-- receive the read request address, post the request to tx engine:
--
                  if (fifo_data_in_ready = '1') then 
		    reqaddr <= fifo_data_in;
		    req_compl_o <= '1';
		    req_dma_o <= '0';
		    stage <= "00111";
		  end if;
		when "00111" =>
--
-- wait for the completion from tx engine:
--
		  if ( compl_done_i_dly1 = '0' and compl_done_i = '1' ) then
		    req_compl_o <= '0';
		    req_dma_o <= '0';
		    stage <= "00000";
		  end if;
---
--    dma request states:
---
		when "01100" =>
--
-- read the next word:
--
                  if (fifo_data_in_ready = '1') then 
		    stage <= "01101";
		  end if;
		when "01101" =>
--
-- receive the dma request address:
--
                  if (fifo_data_in_ready = '1') then 
		    dma_request_address <= fifo_data_in(7 downto 0);
		    stage <= "01110";
		  end if;
		when "01110" =>
--
-- receive the dma request data, if request, post it to tx engine:
--
		  if (fifo_data_in_ready = '1') then
		    case dma_request_address is
		      when "00000000" =>
-- request:
-- for the data from Pentium, we have to change the byte order.
-- the Pentium request format is: llllllll aaaaaaaa aaaaaaaa aaaaaaaa,
-- so:
		        reqaddr <= "000000" & fifo_data_in(15 downto 8) & fifo_data_in(23 downto 16) & 
					      fifo_data_in(31 downto 24) & "00";
		        dma_current_address <= ("000000" & fifo_data_in(15 downto 8) & fifo_data_in(23 downto 16) & 
					        fifo_data_in(31 downto 24) & "00") + MAXPAYLOAD;
			if ( fifo_data_in(7 downto 0) < (MAXPAYLOAD(9 downto 2) + "00000001") ) then 
		          reqlen     <= "00" & fifo_data_in(7 downto 0);
			  totalcount <= (others => '0');
			else
			  reqlen     <= "00" & MAXPAYLOAD(9 downto 2);
			  totalcount <= ("00" & fifo_data_in(7 downto 0)) - MAXPAYLOAD(9 downto 2);
			end if;    
		        req_compl_o <= '1';
		        req_dma_o <= '1';
			dma_memory_start_current <= dma_memory_start;
			transmit_dma_done <= '0';
		        stage <= "01111";
		      when "00000100" =>
-- dma memory start address set:	
		        dma_memory_start(31 downto 24) <= fifo_data_in(7 downto 0);
			dma_memory_start(23 downto 16) <= fifo_data_in(15 downto 8);
			dma_memory_start(15 downto 8) <= fifo_data_in(23 downto 16);
			dma_memory_start(7 downto 0) <= fifo_data_in(31 downto 24); 
			stage <= "00000";
		      when "00001000" =>
-- dma done address set:	
		        dma_done_address(31 downto 24) <= fifo_data_in(7 downto 0);
			dma_done_address(23 downto 16) <= fifo_data_in(15 downto 8);
			dma_done_address(15 downto 8) <= fifo_data_in(23 downto 16);
			dma_done_address(7 downto 0) <= fifo_data_in(31 downto 24); 
			stage <= "00000";
		      when others => 
			stage <= "00000";
		    end case;  
		  end if;
		when "01111" =>
-- 
-- wait for the completion from tx engine, if over, post the request for dma done:
--
		  if ( transmit_dma_done = '0' ) then
		    if ( compl_done_i_dly1 = '0' and compl_done_i = '1' ) then
		      req_compl_o <= '0';
		      req_dma_o <= '0';  
		      if ( totalcount = "0000000000" ) then
		        transmit_dma_done <= '1';
		      else
		        stage <= "10000";
		      end if;	
		    end if;
		  else
		    req_compl_o <= '1';
		    req_dma_o <= '1';      
		    reqlen <= "0000000001";
		    reqaddr <= (others => '1');
		    stage <= "00111";
		  end if;
		when "10000" =>
--
-- do the next turn:
--
		  reqaddr <= dma_current_address;
		  dma_current_address <= dma_current_address + MAXPAYLOAD;
		  dma_memory_start_current <= dma_memory_start_current + MAXPAYLOAD;
		  if ( totalcount < (MAXPAYLOAD(9 downto 2) + "00000001") ) then 
		    reqlen     <= "00" & totalcount(7 downto 0);
		    totalcount <= (others => '0');
		  else
		    reqlen     <= "00" & MAXPAYLOAD(9 downto 2);
		    totalcount <= totalcount - MAXPAYLOAD(9 downto 2);
		  end if;    
		  req_compl_o <= '1';
		  req_dma_o <= '1';
		  transmit_dma_done <= '0';
		  stage <= "01111";
		  
--
-- Completion handling states:
--
		when "01000" =>
--
-- read and ignore the next word:
--
                  if (fifo_data_in_ready = '1') then 
		    stage <= "01001";
		  end if;
		when "01001" =>
--
-- read the completion tag:
--
                  if (fifo_data_in_ready = '1') then 
		    compltag_o <= fifo_data_in(15 downto 8);
		    wcount <= wcount - "0000000001";
		    stage <= "01010";
		  end if;
		when "01010" =>
--
-- send the next data word:
--
		  if (fifo_data_in_ready = '1') then
		    wcount <= wcount - "0000000001";
		    if ( wcount = "0000000000" ) then 
		      stage <= "00000";
		    end if;  
		  end if;
		when others => null;
	      end case;		      
            end if;
	  end if;
	end process RX_PROC;
end IMP;
