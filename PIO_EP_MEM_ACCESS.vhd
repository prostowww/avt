library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PIO_EP_MEM_ACCESS is
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

-- internal request/reply stuff:

		internal_access_request: out std_logic;
		internal_access_granted:  in std_logic;
		internal_we:		 out std_logic;
		internal_busy_i:          in std_logic;
		internal_do:             out std_logic_vector(35 downto 0);
		rid_i:			  in std_logic_vector(15 downto 0);
		
-- reply to internal requests stuff:

		compltag_i:		in std_logic_vector(7 downto 0);
		compldata_i:		in std_logic_vector(31 downto 0);
		complwe_i:		in std_logic
	);
end entity PIO_EP_MEM_ACCESS;


architecture IMP of PIO_EP_MEM_ACCESS is
  component vector_proc_32_ext
  port (
	DO: out std_logic_vector(31 downto 0);
	ADDR: in std_logic_vector(31 downto 0);
	DI: in std_logic_vector(31 downto 0);
	EN: in std_logic_vector(0 downto 0);
	WE: in std_logic_vector(0 downto 0);
	REG_IN_A: in std_logic_vector(31 downto 0);
	REG_IN_B: in std_logic_vector(31 downto 0);
	REG_OUT_A: out std_logic_vector(31 downto 0);
	REG_OUT_B: out std_logic_vector(31 downto 0);
	REG_WE_A: in std_logic_vector(0 downto 0);
	REG_WE_B: in std_logic_vector(0 downto 0);
	Clk: in std_logic;
	Reset: in std_logic;
-- internal request/reply ports:
--
-- reply (completion) data:
	compltag_i: in std_logic_vector(7 downto 0);
	compldata_i: in std_logic_vector(31 downto 0);
	complwe_i: in std_logic;
-- request data:
--
-- request head ports:
	reqaddr_o: out std_logic_vector(31 downto 0);
	reqlength_o: out std_logic_vector(9 downto 0);
	reqtag_o: out std_logic_vector(7 downto 0);
	reqiswrite_o: out std_logic;
	request_o: out std_logic;
	grant_i: in std_logic;
-- write request data transfer ports:
	reqdata_o: out std_logic_vector(31 downto 0);
	reqwe_o: out std_logic;
	reqbusy_i: in std_logic
       );	
  end component;
  signal rst_p: std_ulogic;
  signal addr: std_logic_vector(23 downto 0);  
  signal wea: std_logic;
  signal web: std_logic;
  signal data_out: std_logic_vector(31 downto 0);
  signal reg_a: std_logic_vector(31 downto 0);
  signal reg_b: std_logic_vector(31 downto 0);
  signal addr_dly1: std_logic_vector(21 downto 0);
  signal not_memory: std_logic;
  signal goodrip: std_logic;
  signal mem_write_enable: std_logic;
  signal input_converter: std_logic_vector(31 downto 0);
  signal output_converter: std_logic_vector(31 downto 0);
  signal stage: std_logic_vector(3 downto 0);
  signal user_request: std_logic;
  signal user_grant: std_logic;
  signal grant: std_logic;
  signal reqiswrite: std_logic;
  signal reqlength: std_logic_vector(9 downto 0);
  signal reqtag: std_logic_vector(7 downto 0);
  signal reqaddr: std_logic_vector(31 downto 0);
  signal wcount: std_logic_vector(9 downto 0);
  signal pad_needed: std_logic;
  signal reqdata: std_logic_vector(31 downto 0);
  signal reqwe: std_logic;
---- TESTING STUFF ----
--  signal stage: std_logic_vector(3 downto 0);
--  signal mozhno: std_logic;
--  signal wrk0: std_logic_vector(31 downto 0);
--  signal wrk1: std_logic_vector(31 downto 0);
---- END TESTING STUFF
begin
  rst_p <= not rst_n;
  addr <= wr_addr_i when wr_en_i = '1' else rd_addr_i;
  wr_busy_o <= '0';
  not_memory <= '1' when wr_en_i = '1' and wr_addr_i(21 downto 1) = "111111111111111111111" else '0';
  wea <= '1' when not_memory = '1' and wr_addr_i(0) = '1' else '0';
  web <= '1' when not_memory = '1' and wr_addr_i(0) = '0' else '0';
  mem_write_enable <= '0' when not_memory = '1' else wr_en_i;
  output_converter <= reg_a when addr_dly1 = "1111111111111111111111" else reg_b when addr_dly1 = "1111111111111111111110" else data_out;
  rd_data_o(31 downto 24) <= output_converter(7 downto 0); 
  rd_data_o(23 downto 16) <= output_converter(15 downto 8); 
  rd_data_o(15 downto 8) <= output_converter(23 downto 16); 
  rd_data_o(7 downto 0) <= output_converter(31 downto 24); 
  input_converter(31 downto 24) <= wr_data_i(7 downto 0);
  input_converter(23 downto 16) <= wr_data_i(15 downto 8);
  input_converter(15 downto 8) <= wr_data_i(23 downto 16);
  input_converter(7 downto 0) <= wr_data_i(31 downto 24);
  goodrip <= '1' when rip = '1' and rd_addr_i(21 downto 1) /= "111111111111111111111" else '0';
vector_proc_inst: vector_proc_32_ext
    port map	(
	Clk => clk,
	Reset => rst_p,
	EN(0) => goodrip,
	WE(0) => mem_write_enable,
	ADDR(31 downto 24) => "00000000",
	ADDR(23 downto 0) => addr,
	DI => input_converter,
	DO => data_out,
	REG_WE_A(0) => wea,
	REG_WE_B(0) => web,
	REG_IN_A => input_converter,
	REG_IN_B => input_converter,
	REG_OUT_A => reg_a,
	REG_OUT_B => reg_b,
--
--
	compltag_i => compltag_i,
	compldata_i => compldata_i,
	complwe_i => complwe_i,
--
	reqaddr_o => reqaddr,
	reqlength_o => reqlength,
	reqtag_o => reqtag,
	reqiswrite_o => reqiswrite,
	request_o => user_request,
	grant_i => grant,
--
	reqdata_o => reqdata,
	reqwe_o => reqwe,
	reqbusy_i => internal_busy_i
		);
WEAB_PROC: process( clk ) is
begin
    if clk'event and clk = '1' then
      addr_dly1 <= rd_addr_i(21 downto 0);
    end if;
end process WEAB_PROC;

    grant <= user_grant and internal_access_granted;

REQUEST_PROC: process ( clk ) is
begin
  if clk'event and clk = '1' then
    if rst_n = '0' then
      stage <= "0000";
      internal_access_request <= '0';
      internal_we <= '0';
      internal_do <= (others => '1');
      user_grant <= '1';
      wcount <= (others => '1');
      pad_needed <= '0';
    else
      case stage is
	when "0000" =>
	  if ( user_request = '1' ) then
	    internal_access_request <= '1';
	    user_grant <= '0';
	    if ( internal_access_granted = '1' ) then
	      if ( internal_busy_i = '0' ) then
-- send the first header word:
		internal_we <= '1';
		internal_do <= "0100" & '0' & reqiswrite & "000000" & "00000000000000" & reqlength;
		stage <= "0001";
	      end if;
	    end if;
	  end if;
	when "0001" =>
	  if ( internal_busy_i = '0' ) then
	    if ( reqlength = "0000000001" ) then
	      internal_do <= "1100" & rid_i & reqtag & "00001111"; 
	    else
	      internal_do <= "1100" & rid_i & reqtag & "11111111";
	    end if;
	    stage <= "0010";
	  end if;
	when "0010" =>
	  if ( internal_busy_i = '0' ) then
	    user_grant <= '1';
	    if ( reqiswrite = '0' ) then
	      internal_do <= "1000" & reqaddr;
	      stage <= "0011";
	    else
	      internal_do <= "1100" & reqaddr;
	      wcount <= reqlength - "0000000001";
	      pad_needed <= not reqlength(0);
	      stage <= "0110";
	    end if;
	  end if;
	when "0011" =>
	  if ( internal_busy_i = '0' ) then
-- output a pad:
	    internal_do <= "1100" & "11111111111111111111111111111111";	    
	    stage <= "0100";
	  end if;
	when "0100" =>
	  if ( internal_busy_i = '0' ) then
	    internal_we <= '0';
	    internal_access_request <= '0';
	    stage <= "0101";
	  end if;
	when "0101" =>
	  if ( internal_access_granted = '0' ) then
	    stage <= "0000";
	  end if;
	when "0110" =>
	  if ( internal_busy_i = '0' ) then
	    if ( reqwe = '1' ) then
	      internal_we <= '1';
	      wcount <= wcount - "0000000001";
	      if ( wcount = "0000000000" ) then
		internal_do <= "1000" & reqdata;
		if ( pad_needed = '1' ) then
		  stage <= "0011";
		else
		  stage <= "0100";
		end if;
	      else
		internal_do <= "1100" & reqdata;
	      end if;
	    else
	      internal_we <= '0';  
	    end if;
	  end if;
	when others => null;
      end case;
    end if;
  end if;
end process REQUEST_PROC;
---- TESTING STUFF ----
--TEST_INTERNAL_PROC: process ( clk ) is
--begin
--  if clk'event and clk = '1' then
--    if rst_n = '0' then
--      stage <= "0000";
--      internal_access_request <= '0';
--      internal_we <= '0';
--      internal_do <= (others => '1');
--      mozhno <= '0';
--    else
--      if ( wea = '1' ) then
--        mozhno <= '1';
--      end if;
--      if ( mozhno = '1' ) then	
--        case stage is
--          when "0000" => 
--		internal_access_request <= '1';
--		if ( internal_access_granted = '1' ) then
--		  stage <= "0001";
--		end if;
--	  when "0001" =>
--		internal_we <= '1';
--		internal_do <= "0100" & "00000000000000000000000000000010"; -- read 2 words
--		stage <= "0010";
--	  when "0010" =>
--		internal_do <= "1100" & rid_i & "00000011" & "11111111";   -- tag = 3
--		stage <= "0011";
--	  when "0011" =>
--		internal_do <= "1000" & "01111101000000000000000000100000"; --word 8
--		stage <= "0100";
--	  when "0100" =>
--		internal_do <= "1100" & "11111111111111111111111111111111"; --value "-1", don't care
--		stage <= "0101";
--	  when "0101" =>
--		internal_we <= '0';
--		internal_access_request <= '0';
--		if ( complwe_i = '1' ) then  -- wait for the completion
--		  wrk0 <= compldata_i;
--		  stage <= "0110";
--		end if;
--	  when "0110" =>
--		if ( complwe_i = '1' ) then
--		  wrk1 <= compltag_i & "000000000000000000000000";
--		  stage <= "0111";
--		end if;
---- now send the received stuff to different place:
--	  when "0111" =>
--		internal_access_request <= '1';
--		if ( internal_access_granted = '1' ) then
--		  stage <= "1000";
--		end if;  
--	  when "1000" =>
--		internal_we <= '1';
--		internal_do <= "0100" & "01000000000000000000000000000010";
--		stage <= "1001";
--	  when "1001" =>
--		internal_do <= "1100" & rid_i & "00000000" & "11111111";
--		stage <= "1010";
--	  when "1010" =>
--		internal_do <= "1100" & "01111101000000000000000010000000"; --word 32
--		stage <= "1011";
--	  when "1011" =>
------		internal_do <= "1100" & "11111110111111111111111111111111"; --value "-2"
--		internal_do <= "1100" & wrk0;
--		stage <= "1100";
--	  when "1100" =>
------		internal_do <= "1000" & "11111101111111111111111111111111"; --value "-3"
--		internal_do <= "1000" & wrk1;
--		stage <= "1101";
--	  when "1101" =>
--		internal_do <= "1100" & "11111111111111111111111111111111"; --value "-1", don't care
--		stage <= "1110";
--	  when "1110" =>
--		internal_we <= '0';
--		internal_access_request <= '0';
--		stage <= "1111";
--        when others => null;
--        end case;
--      end if;	
--    end if;
--  end if;
--end process TEST_INTERNAL_PROC;
---- END TESTING STUFF ----
end IMP;
