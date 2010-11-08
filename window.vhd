library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity WINDOW is  
  generic (
    data_width: integer:=32;
    address_width: integer:=32;
    depth: integer := 512;
    blocksize: integer := 1
  );
  port (
-- user logic data access ports:                                             
    do: 	out std_logic_vector(data_width*blocksize-1 downto 0);      
    di: 	in std_logic_vector(data_width*blocksize-1 downto 0);      
    addr: 	in std_logic_vector(address_width*blocksize-1 downto 0);  
    we: 	in std_logic_vector(blocksize-1 downto 0);                                    
-- external memory array address:
		arrayaddress:	in std_logic_vector(address_width-1 downto 0);
-- dma put interface:
--
-- local side:
		do_dma:		out std_logic_vector(data_width*blocksize-1 downto 0);
		addro_dma:	in std_logic_vector(address_width*blocksize-1 downto 0);
-- dma setup side:
		laddr_p_dma:	out std_logic_vector(address_width-1 downto 0);
		raddr_p_dma:	out std_logic_vector(address_width-1 downto 0);
		length_p_dma:	out std_logic_vector(address_width-1 downto 0);
		start_p_dma:	out std_logic;
		done_p_dma:	in std_logic;
-- dma get interface:
--
-- local side:
		di_dma:		in std_logic_vector(data_width*blocksize-1 downto 0);
		addri_dma:	in std_logic_vector(address_width*blocksize-1 downto 0);
    we_dma: 	in std_logic_vector(blocksize-1 downto 0);
-- dma setup side:
		laddr_g_dma:	out std_logic_vector(address_width-1 downto 0);
		raddr_g_dma:	out std_logic_vector(address_width-1 downto 0);
		length_g_dma:	out std_logic_vector(address_width-1 downto 0);
		start_g_dma:	out std_logic;
		done_g_dma:	in std_logic;
-- memory mapping ports:
		yesterday:	in std_logic_vector(address_width-1 downto 0);
		we_yesterday:	in std_logic;
		today:		in std_logic_vector(address_width-1 downto 0);
		we_today:	in std_logic;
		tomorrow:	in std_logic_vector(address_width-1 downto 0);
		we_tomorrow:	in std_logic;
		remap_rq:	in std_logic;
		remap_done:	out std_logic;
--
    clk: in std_logic;                                   
    rst: in std_logic
     );
end entity WINDOW;

architecture IMP of WINDOW is
 component HI_RAMB
  generic (
    data_width: integer;
    address_width: integer;
    depth: integer
  );
  port (
	doa: out std_logic_vector(data_width-1 downto 0);
	dob: out std_logic_vector(data_width-1 downto 0);
	addra: in std_logic_vector(address_width-1 downto 0);
	addrb: in std_logic_vector(address_width-1 downto 0);
	clka: in std_ulogic;
	clkb: in std_ulogic;
	dia: in std_logic_vector(data_width-1 downto 0);
	dib: in std_logic_vector(data_width-1 downto 0);
	rsta: in std_ulogic;
	rstb: in std_ulogic;
	wea: in std_ulogic;
	web: in std_ulogic
	);
 end component;
--
-- address mapping stuff:
--
-- the base to start the main bram user logic addressing from (for each bram block) - words:
  signal user_logic_base: std_logic_vector(address_width-1 downto 0);
-- the mapping offsets in external memory - words:
  signal ryesterday: std_logic_vector(address_width-1 downto 0);
  signal rtoday: std_logic_vector(address_width-1 downto 0);
  signal rtomorrow: std_logic_vector(address_width-1 downto 0);
-- real address offsets for each bram - words:
  signal user_logic_offset: std_logic_vector(address_width*blocksize-1 downto 0);
-- end address mapping.
  signal maindmaaddr: std_logic_vector(address_width*blocksize-1 downto 0);
  signal maindmadata: std_logic_vector(data_width*blocksize-1 downto 0);
  signal maindmawe: std_logic_vector(blocksize-1 downto 0);
-- dma stuff:
begin
  bram_gen: for i in blocksize-1 downto 0 generate
    begin
      user_logic_offset(address_width*(i+1)-1 downto address_width*i) <= 
	    user_logic_base + (addr(address_width*(i+1)-1 downto address_width*i)-(rtoday/blocksize));
-- main bram: port a for user logic, port b for dma put and copy from buffer bram:
      main_bram_inst: HI_RAMB
    generic map (
		  address_width => address_width,
		  data_width => data_width,
		  depth => 2*depth
    )
    port map (
-- port a is for the user logic:
-- 
      addra => user_logic_offset(address_width*(i+1)-1 downto address_width*i),
      dia => di(data_width*(i+1)-1 downto data_width*i),
      doa => do(data_width*(i+1)-1 downto data_width*i),
      wea => we(i),
-- port b is for dma put and copy from buffer bram:
      addrb => maindmaaddr(address_width*(i+1)-1 downto address_width*i),
      dob => do_dma(data_width*(i+1)-1 downto data_width*i),
      dib => maindmadata(data_width*(i+1)-1 downto data_width*i),
      web => maindmawe(i),
      clka => clk,
      clkb => clk,
      rsta => rst,
      rstb => rst
    );
    
  end generate bram_gen;
end IMP;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library proc_common_v1_00_b;
--use proc_common_v1_00_b.proc_common_pkg.all;

entity vector_proc_32 is
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
end vector_proc_32;
architecture IMP of vector_proc_32 is

  component HI_RAMB
    generic (
     data_width: integer;
     address_width: integer;
     depth: integer
    );
    port (
      doa: out std_logic_vector(data_width-1 downto 0);
      dob: out std_logic_vector(data_width-1 downto 0);
      addra: in std_logic_vector(address_width-1 downto 0);
      addrb: in std_logic_vector(address_width-1 downto 0);
      clka: in std_ulogic;
      clkb: in std_ulogic;
      dia: in std_logic_vector(data_width-1 downto 0);
      dib: in std_logic_vector(data_width-1 downto 0);
      rsta: in std_ulogic;
      rstb: in std_ulogic;
      wea: in std_ulogic;
      web: in std_ulogic
    );
  end component;


	signal L: std_logic_vector( 31 downto 0 );
	signal sum: std_logic_vector( 31 downto 0 );
	signal ready: std_logic_vector( 31 downto 0 );
	type   l1w32_type is array (0 to 0) of std_logic_vector(31 downto 0);
	type   l1w1_type is array (0 to 0) of std_logic_vector(0 downto 0);
	signal array_addra: l1w32_type;
	signal array_addrb: l1w32_type;
	signal array_dina:  l1w32_type;
	signal array_doutb: l1w32_type;
	signal array_wea:   l1w1_type;
	signal array_dinb:  l1w32_type;
	signal array_douta: l1w32_type;
	signal array_web:   l1w1_type;

	signal wrk0: std_logic_vector(31 downto 0);
	signal wrk1: std_logic_vector(31 downto 0);


begin

array_gen: for array_i in 0 to 0 generate
begin
	array_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 16384
	)
	port map (
		addra => array_addra(array_i),
		addrb => array_addrb(array_i),
		dia => array_dina(array_i),
		wea => array_wea(array_i)(0),
		dob => array_doutb(array_i),
		doa => array_douta(array_i),
		dib => array_dinb(array_i),
		web => array_web(array_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate array_gen;

REG_OUT_A <= sum;
REG_OUT_B <= ready;
array_dina(0) <= DI;
array_addra(0) <= ADDR;
array_wea(0) <= WE;
DO <= array_douta(0);

STATE_PROC: process ( Clk ) is
  variable stage: integer := 0;
begin
 if ( Clk'event and Clk = '1' ) then
  if ( Reset = '1' ) then
    ready <= "00000000000000000000000000000000";
    sum <= "00000000000000000000000000000000";
    array_web(0) <= "0";

    request_o <= '0';
    reqwe_o <= '0';
    reqaddr_o <= (others => '1');
    reqlength_o <= (others => '1');
    reqtag_o <= (others => '1');
    reqiswrite_o <= '1';
    reqdata_o <= (others => '1');
  else
    case stage is
    when 0 =>
      stage := stage + 1;
      if (REG_WE_A = "1") then
        L <= REG_IN_A;
        array_addrb(0) <= "00000000000000000000000000000000";
        ready <= "00000000000000000000000000000000";
        sum <= "00000000000000000000000000000000";
      else
        stage := 0;
      end if;
    when 1 =>
      stage := stage + 1;
      array_addrb(0) <= array_addrb(0) + "00000000000000000000000000000001";
      L <= L + "11111111111111111111111111111111";
    when 2 =>
      stage := stage + 1;
      sum <= sum+array_doutb(0);
      array_addrb(0) <= array_addrb(0) + "00000000000000000000000000000001";
      L <= L + "11111111111111111111111111111111";
      if (L /= "00000000000000000000000000000000") then
        stage := 2;
      else
        ready <= "00000000000000000000000000000001";
        stage := 3;
      end if;
    when 3 => 
      reqaddr_o <= "01111101000000000000000000100000"; -- word 8
      reqlength_o <= "0000000010"; -- read 2 words
      reqtag_o <= "00000011";  -- tag 3
      reqiswrite_o <= '0'; -- it is a read
      request_o <= '1';
      if ( grant_i = '1' ) then
        stage := 4;
      end if;
    when 4 =>
      request_o <= '0';
      if ( complwe_i = '1' ) then  -- wait for the completion
        wrk0 <= compldata_i;
        stage := 5;
      end if;
    when 5 =>
      if ( complwe_i = '1' ) then
        wrk1 <= compltag_i & "000000000000000000000000";
        stage := 6;
      end if;
  ---- now send the received stuff to different place:
    when 6 =>
      reqaddr_o <= "01111101000000000000000010000000"; -- word 32
      reqlength_o <= "0000000010"; -- write 2 words
      reqtag_o <= "00000000";  -- tag 0
      reqiswrite_o <= '1'; -- it is a write
      request_o <= '1';
      if ( grant_i = '1' ) then
        stage := 7;
      end if;  
    when 7 =>
      reqdata_o <= wrk0;
      reqwe_o <= '1';
      stage := 8;
    when 8 =>
      reqdata_o <= wrk1;
      stage := 9;
    when 9 =>
      request_o <= '0';
      reqwe_o <= '0';
      stage := 0;
    when others => null;
    end case;
  end if;
 end if;
end process STATE_PROC;
end IMP;
