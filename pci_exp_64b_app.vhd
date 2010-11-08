------------------------------------------------------------------------------
-- Filename: pci_exp_64b_app.v
--
-- Description:  PCI Express Endpoint Core 64 bit interface sample application
--               design. 
--
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity  pci_exp_64b_app is
	port
	(
         trn_clk:	in std_logic;
         trn_reset_n:	in std_logic;
         trn_lnk_up_n:	in std_logic;
            
         trn_td:	out std_logic_vector(63 downto 0);
         trn_trem:	out std_logic_vector(7 downto 0);
         trn_tsof_n:	out std_logic;
         trn_teof_n:	out std_logic;
         trn_tsrc_rdy_n: out std_logic;
         trn_tdst_rdy_n: in std_logic;
         trn_tsrc_dsc_n: out std_logic;
         trn_tdst_dsc_n: in std_logic;
         trn_terrfwd_n:	out std_logic;
         trn_tbuf_av:	in std_logic_vector(4 downto 0);
            
         trn_rd:	in std_logic_vector(63 downto 0);
         trn_rrem:	in std_logic_vector(7 downto 0);
         trn_rsof_n:	in std_logic;
         trn_reof_n:	in std_logic;
         trn_rsrc_rdy_n: in std_logic;
         trn_rsrc_dsc_n: in std_logic;
         trn_rdst_rdy_n: out std_logic;
         trn_rerrfwd_n:	in std_logic;
         trn_rnp_ok_n:	out std_logic;

         trn_rbar_hit_n: in std_logic_vector(6 downto 0); 
         trn_rfc_nph_av: in std_logic_vector(7 downto 0);
         trn_rfc_npd_av: in std_logic_vector(11 downto 0);
         trn_rfc_ph_av:	in std_logic_vector(7 downto 0);
         trn_rfc_pd_av:	in std_logic_vector(11 downto 0);
         trn_rfc_cplh_av: in std_logic_vector(7 downto 0);
         trn_rfc_cpld_av: in std_logic_vector(11 downto 0);

         cfg_do:		in std_logic_vector(31 downto 0);
         cfg_rd_wr_done_n:	in std_logic;
         cfg_di:		out std_logic_vector(31 downto 0);
         cfg_byte_en_n:		out std_logic_vector(3 downto 0);
         cfg_dwaddr:		out std_logic_vector(9 downto 0);
         cfg_wr_en_n:		out std_logic;
         cfg_rd_en_n:		out std_logic;
         cfg_err_cor_n:		out std_logic;
         cfg_err_ur_n:		out std_logic;
         cfg_err_ecrc_n:	out std_logic;
         cfg_err_cpl_timeout_n:	out std_logic;
         cfg_err_cpl_abort_n:	out std_logic;
         cfg_err_cpl_unexpect_n: out std_logic;
         cfg_err_posted_n:	out std_logic;
         cfg_err_tlp_cpl_header: out std_logic_vector(47 downto 0);
         cfg_interrupt_n:	out std_logic;
         cfg_interrupt_rdy_n:	in std_logic;
         cfg_turnoff_ok_n:	out std_logic;
         cfg_to_turnoff_n:	in std_logic;
         cfg_pm_wake_n:		out std_logic;
         cfg_status:		in std_logic_vector(15 downto 0);
         cfg_command:		in std_logic_vector(15 downto 0);
         cfg_dstatus:		in std_logic_vector(15 downto 0);
         cfg_dcommand:		in std_logic_vector(15 downto 0);
         cfg_lstatus:		in std_logic_vector(15 downto 0);
         cfg_lcommand:		in std_logic_vector(15 downto 0);

         cfg_bus_number:	in std_logic_vector(7 downto 0);
         cfg_device_number:	in std_logic_vector(4 downto 0);
         cfg_function_number:	in std_logic_vector(2 downto 0);
         cfg_pcie_link_state_n:	in std_logic_vector(2 downto 0);
         cfg_trn_pending_n:	out std_logic
        );   
end entity pci_exp_64b_app;

architecture IMP of pci_exp_64b_app is
-- general stuff:
	signal rst_n:			std_logic;
	signal rst:			std_logic;
	signal cfg_completer_id:	std_logic_vector(15 downto 0);
	signal cfg_bus_mstr_enable:	std_logic;
	signal trn_pending:		std_logic;
-- end general stuff.
-- input fifo converter:
	signal data_32_in:		std_logic_vector(35 downto 0);
	signal data_in_we:		std_logic;
	signal data_in_re:		std_logic;
	signal data_in_empty:		std_logic;
	signal l_trn_rdst_rdy_n:	std_logic;
	signal sof_left_in:		std_logic;
	signal eof_left_in:		std_logic;
	signal sof_right_in:		std_logic;
	signal eof_right_in:		std_logic;
-- end input fifo converter.
-- output fifo converter:
	signal data_32_out:		std_logic_vector(35 downto 0);
	signal data_out_we:		std_logic;
	signal data_out_re:		std_logic;
	signal data_out_full:		std_logic;
	signal l_trn_tsrc_rdy_n:	std_logic;
	signal sof_left_out:		std_logic;
	signal eof_left_out:		std_logic;
	signal sof_right_out:		std_logic;
	signal eof_right_out:		std_logic;
	signal trem_out:		std_logic;
	signal tsrc_rdy_n:		std_logic;
	signal din_mux:			std_logic_vector(35 downto 0);
	signal wr_en_mux:		std_logic;
	signal output_fifo_source:	std_logic;
	signal internal_data_out:	std_logic_vector(35 downto 0);
	signal internal_we:		std_logic;
	signal want_internal_req:	std_logic;
-- end output fifo converter.
-- input to logic:
	signal wr_addr:			std_logic_vector(23 downto 0);
	signal wr_data:			std_logic_vector(31 downto 0);
	signal wr_en:			std_logic;
	signal wr_busy:			std_logic;
	signal compltag:		std_logic_vector(7 downto 0);
	signal compldata:		std_logic_vector(31 downto 0);
	signal complwe:			std_logic;
-- end input to logic.
-- logic to output:
	signal rd_addr:			std_logic_vector(23 downto 0);
	signal rd_be: 			std_logic_vector(3 downto 0);
	signal rd_data:			std_logic_vector(31 downto 0);
-- end logic to output.
-- between rx and tx:
	signal req_compl:	std_logic;
	signal req_dma:		std_logic;
	signal compl_done:	std_logic;
	signal req_tc:		std_logic_vector(2 downto 0);
	signal req_td:		std_logic;
	signal req_ep:		std_logic;
	signal req_attr:	std_logic_vector(1 downto 0);
	signal req_len:		std_logic_vector(9 downto 0);
	signal req_rid:		std_logic_vector(15 downto 0);
	signal req_tag:		std_logic_vector(7 downto 0);
	signal req_be:		std_logic_vector(7 downto 0);
	signal req_addr:	std_logic_vector(31 downto 0);
	signal dma_memory_start: std_logic_vector(31 downto 0);
	signal req_compl_mux:	std_logic;
-- end between rx and tx.	
component fifo_64to32
	port (
	din: IN std_logic_VECTOR(71 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(35 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_32to64
	port (
	din: IN std_logic_VECTOR(35 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(71 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component PIO_64_RX_ENGINE                              
	port (  
	clk: 		in std_logic;
	rst_n:  	in std_logic;
	
	fifo_data_in:	in std_logic_vector(31 downto 0);
	fifo_data_in_ready:in std_logic;
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
end component;

component PIO_64_TX_ENGINE 
	port (
        clk:		in std_logic;
        rst_n:		in std_logic;

	fifo_data_out:	out std_logic_vector(31 downto 0);
	fifo_data_out_en: out std_logic;
	sof_n:		out std_logic;
	eof_n:		out std_logic;

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
        cfg_bus_mstr_enable_i:	in std_logic;
	wr_busy_i:	in std_logic
        );
end component;

component PIO_EP_MEM_ACCESS 
	port
	(
		clk:		in std_logic;
		rst_n:		in std_logic;
		
-- Read access:

		rd_addr_i:	in std_logic_vector(23 downto 0);
		rd_be_i:	in std_logic_vector(3 downto 0);
		rd_data_o:	out std_logic_vector(31 downto 0);
		rip:		in std_logic;
		
-- Write access:

		wr_addr_i:	in std_logic_vector(23 downto 0);
		wr_data_i:	in std_logic_vector(31 downto 0);
		wr_en_i:	in std_logic;
		wr_busy_o:	out std_logic;

-- Internal request/reply stuff:

		internal_access_request: out std_logic;
		internal_access_granted:  in std_logic;
		internal_we:		out std_logic;
		internal_busy_i:	in  std_logic;
		internal_do:		out std_logic_vector(35 downto 0);
		rid_i:			in  std_logic_vector(15 downto 0);
		
-- data reply for internal requests stuff:

		compltag_i:		in std_logic_vector(7 downto 0);
		compldata_i:		in std_logic_vector(31 downto 0);
		complwe_i:		in std_logic
	);
end component;

begin
        rst_n <= trn_reset_n and (not trn_lnk_up_n);
	rst <= not rst_n;

-- Core input tie-offs

	trn_rnp_ok_n <= '0';
	trn_terrfwd_n <= '1';

	cfg_err_cor_n <= '1';
	cfg_err_ur_n <= '1';
	cfg_err_ecrc_n <= '1';
	cfg_err_cpl_timeout_n <= '1';
	cfg_err_cpl_abort_n <= '1';
	cfg_err_cpl_unexpect_n <= '1';
	cfg_err_posted_n <= '0';
	cfg_interrupt_n <= '1';
	cfg_pm_wake_n <= '1';
	cfg_trn_pending_n <= '1';

	cfg_dwaddr <= (others => '0');
	cfg_err_tlp_cpl_header <= (others => '0');

	cfg_di <= (others => '0');
	cfg_byte_en_n <= "1111";
	cfg_wr_en_n <= '1';
	cfg_rd_en_n <= '1';

	cfg_completer_id <= cfg_bus_number & cfg_device_number & cfg_function_number;
	cfg_bus_mstr_enable <= cfg_command(2);  

--	cfg_turnoff_ok_n <= '0';

-- input fifo converter instantiation:
	data_in_we <= (not trn_rsrc_rdy_n) and (not l_trn_rdst_rdy_n) and trn_rsrc_dsc_n and (not rst);
	data_in_re <= (not data_in_empty) and (not wr_busy) and (not rst);
	trn_rdst_rdy_n <= l_trn_rdst_rdy_n;
	sof_left_in <= trn_rsof_n;
	sof_right_in <= '1';
	eof_left_in <= '0' when (trn_reof_n = '0') and (trn_rrem(0) = '1') else '1';
	eof_right_in <= '0' when (trn_reof_n = '0') and (trn_rrem(0) = '0') else '1';
	
    INPUT_FIFO: fifo_64to32
		port map (
			din(71) => sof_left_in,
			din(70) => eof_left_in,
			din(69 downto 68) => trn_rbar_hit_n(1 downto 0),
			din(67 downto 36) => trn_rd(63 downto 32),
			din(35) => sof_right_in,
			din(34) => eof_right_in,
			din(33 downto 32) => trn_rbar_hit_n(1 downto 0),
			din(31 downto 0)  => trn_rd(31 downto 0),
			
			rd_clk => trn_clk,
			rd_en => data_in_re,	--data from fifo ready
			rst => rst,
			wr_clk => trn_clk,
			wr_en => data_in_we,
			dout => data_32_in,	--data from fifo
			empty => data_in_empty,
			full => l_trn_rdst_rdy_n);

    EP_RX: PIO_64_RX_ENGINE 
		port map (

                   clk 		=> trn_clk, 
                   rst_n	=> rst_n, 
		   --
		   fifo_data_in		=> data_32_in(31 downto 0),
		   fifo_data_in_ready	=> data_in_re,
		   sof_n		=> data_32_in(35),
		   eof_n		=> data_32_in(34),
		   rbar_hit_n		=> data_32_in(33 downto 32),
		   --
		   req_compl_o		=> req_compl,
		   req_dma_o		=> req_dma,
		   compl_done_i		=> compl_done,
		   req_tc_o		=> req_tc,
		   req_td_o		=> req_td,
		   req_ep_o		=> req_ep,
		   req_attr_o		=> req_attr,
		   req_len_o		=> req_len,
		   req_rid_o		=> req_rid,
		   req_tag_o		=> req_tag,
		   req_be_o		=> req_be,
		   req_addr_o		=> req_addr,
		   dma_memory_start_o	=> dma_memory_start,
		   -- 
		   wr_addr_o	=> wr_addr,
                   wr_data_o	=> wr_data,      
		   wr_en_o	=> wr_en,
		   wr_busy_i	=> wr_busy,
		   compltag_o	=> compltag,
		   compldata_o	=> compldata,
		   complwe_o	=> complwe
                   
                   );

-- output fifo converter instantiation:
	trn_tsrc_dsc_n <= '1';
	data_out_re <= (not l_trn_tsrc_rdy_n) and (not trn_tdst_rdy_n) and trn_tdst_dsc_n and (not rst);
	trn_tsrc_rdy_n <= l_trn_tsrc_rdy_n when rst = '0' else '1';
	trn_tsof_n <= sof_left_out when data_out_re = '1' else '1';
	trn_teof_n <= '0' when (eof_left_out = '0' or eof_right_out = '0') and data_out_re = '1' else '1';
	trn_trem(7 downto 4) <= (others => '0'); 
	trn_trem(3 downto 0) <= (others => trem_out);
	trem_out <= '1' when eof_left_out = '0' and eof_right_out = '1' else '0';
	l_trn_tsrc_rdy_n <= tsrc_rdy_n when cfg_bus_mstr_enable = '1' else '1';
	din_mux   <= data_32_out when output_fifo_source = '0' else internal_data_out;
	wr_en_mux <= data_out_we when output_fifo_source = '0' else internal_we;
	req_compl_mux <= req_compl when output_fifo_source = '0' else '0';

    OUTPUT_FIFO: fifo_32to64
		port map (
			din => din_mux, 	--data_32_out,
			rd_clk => trn_clk,
			rd_en => data_out_re,		
			rst => rst,
			wr_clk => trn_clk,
			wr_en => wr_en_mux,	--data_out_we,
			
			dout(67 downto 36) => trn_td(63 downto 32),
			dout(71) => sof_left_out,
			dout(70) => eof_left_out,
			dout(69 downto 68) => open,
			dout(31 downto 0)  => trn_td(31 downto 0),
			dout(35) => sof_right_out,
			dout(34) => eof_right_out,
			dout(33 downto 32) => open,
			
			empty => tsrc_rdy_n,
			full => data_out_full);
			
    EP_TX: PIO_64_TX_ENGINE 
		port map (

                   clk		=> trn_clk, 
                   rst_n	=> rst_n,
                   -- 
                   fifo_data_out		=> data_32_out(31 downto 0),
                   fifo_data_out_en		=> data_out_we,
		   sof_n			=> data_32_out(35),
		   eof_n			=> data_32_out(34),
		   --
		   req_compl_i			=> req_compl_mux,
		   req_dma_i			=> req_dma,
		   compl_done_o			=> compl_done,
		   req_tc_i			=> req_tc,
		   req_td_i			=> req_td,
		   req_ep_i			=> req_ep,
		   req_attr_i			=> req_attr,
		   req_len_i			=> req_len,
		   req_rid_i			=> req_rid,
		   req_tag_i			=> req_tag,
		   req_be_i			=> req_be,
		   req_addr_i			=> req_addr,
		   dma_memory_start_i		=> dma_memory_start,
		   --    
		   rd_addr_o			=> rd_addr,
		   rd_be_o			=> rd_be,
                   rd_data_i			=> rd_data, 

                   completer_id_i		=> cfg_completer_id, 
                   cfg_bus_mstr_enable_i	=> cfg_bus_mstr_enable,
		   
		   wr_busy_i			=> data_out_full
                   );
		   
    MEM_ACC: PIO_EP_MEM_ACCESS
		port map (
		
		clk		=> trn_clk,
		rst_n		=> rst_n,

		rd_addr_i	=> rd_addr,
		rd_be_i		=> rd_be,
		rd_data_o	=> rd_data,
		rip		=> data_out_we,
		
		wr_addr_i	=> wr_addr,
		wr_data_i	=> wr_data,
		wr_en_i		=> wr_en,
		wr_busy_o	=> wr_busy,

		internal_access_request => want_internal_req,
		internal_access_granted => output_fifo_source,
		internal_we	=> internal_we,
		internal_busy_i	=> data_out_full,
		internal_do	=> internal_data_out,
		rid_i		=> cfg_completer_id,
		
		compltag_i	=> compltag,
		compldata_i	=> compldata,
		complwe_i	=> complwe

		);

	OUT_FIFO_MUX_PROC: process ( trn_clk ) is
	begin
	  if trn_clk'event and trn_clk = '1' then
	    if rst_n = '0' then
	      output_fifo_source <= '0';
	    else
	      if ( output_fifo_source = '1') then
		if ( want_internal_req = '0' ) then
		  output_fifo_source <= '0';
		end if;
	      else
		if ( want_internal_req = '1' ) then
		  if ( compl_done = '1' and req_compl = '0' ) then
		    output_fifo_source <= '1';
		  end if;
		end if;
	      end if;
	    end if;
	  end if;
	end process OUT_FIFO_MUX_PROC;
	PWRM_PROC: process ( trn_clk ) is
	begin
	  if trn_clk'event and trn_clk = '1' then
	    if rst_n = '0' then
	      trn_pending <= '0';
  	      cfg_turnoff_ok_n <= '1';
	    else
	      if ( trn_pending = '0' and data_in_empty = '0' ) then
	        trn_pending <= '1';
	      else
	        if ( tsrc_rdy_n = '1' ) then
		  trn_pending <= '0';
		end if;  
	      end if;	
	      if ( cfg_to_turnoff_n = '0' and trn_pending = '0' ) then
	        cfg_turnoff_ok_n <= '0';
	      else
	        cfg_turnoff_ok_n <= '1';
	      end if;	
	    end if;
	  end if;
	end process PWRM_PROC;      
end IMP;
