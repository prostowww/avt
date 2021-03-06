


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vector_proc_32 is
 port (
DO: out std_logic_vector(31 downto 0);
ADDR: in std_logic_vector(31 downto 0);
DI: in std_logic_vector(31 downto 0);
EN: in std_logic_vector(0 downto 0);
WE: in std_logic_vector(0 downto 0);
REG_IN_A: in std_logic_vector(31 downto 0);
REG_OUT_A: out std_logic_vector(31 downto 0);
REG_WE_A: in std_logic_vector(0 downto 0);
REG_IN_B: in std_logic_vector(31 downto 0);
REG_OUT_B: out std_logic_vector(31 downto 0);
REG_WE_B: in std_logic_vector(0 downto 0);
Clk: in std_logic;
Reset: in std_logic
);
end entity vector_proc_32;
architecture IMP1 of vector_proc_32 is

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

	signal prt_data: std_logic_vector( 31 downto 0 );
	signal prt_addr: std_logic_vector( 31 downto 0 );
	signal prt_we: std_logic_vector( 0 downto 0 );
	signal prt_switch_in: std_logic;
	signal prt_switch_out: std_logic;
	type l1w32_type is array (0 to 0) of std_logic_vector(31 downto 0);
	type l1w1_type is array (0 to 0) of std_logic_vector(0 downto 0);
	signal x_addra: l1w32_type;
	signal x_addrb: l1w32_type;
	signal x_dina: l1w32_type;
	signal x_doutb: l1w32_type;
	signal x_wea: l1w1_type;
	signal x_dinb: l1w32_type;
	signal x_douta: l1w32_type;
	signal x_web: l1w1_type;
	signal par_data: std_logic_vector( 31 downto 0 );
	signal par_addr: std_logic_vector( 31 downto 0 );
	signal par_out: std_logic_vector( 31 downto 0 );
	signal par_we: std_logic_vector( 0 downto 0 );
	signal par_block: std_logic;
	signal par_current: std_logic_vector( 0 downto 0 );
	signal counter: std_logic_vector( 31 downto 0 );
	signal my_rdy: std_logic_vector( 0 downto 0 );
begin
x_gen: for x_i in 0 to 0 generate
begin
	x_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 1024
	)
	port map (
		addra => x_addra(x_i),
		addrb => x_addrb(x_i),
		dia => x_dina(x_i),
		wea => x_wea(x_i)(0),
		dob => x_doutb(x_i),
		doa => x_douta(x_i),
		dib => x_dinb(x_i),
		web => x_web(x_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate x_gen;
prt_data <= DI;
prt_addr <= ADDR;
prt_we <= WE;
par_data <= REG_IN_A;
par_addr <= REG_IN_B;
REG_OUT_B <= par_out;
par_we <= REG_WE_A;
REG_OUT_A <= "00000000000000000000000000000000";
DO <= x_douta(0);
x_wea(0) <= "1" when (prt_we = "1") else  "0";
x_dina(0) <= prt_data;
x_addra(0) <= prt_addr;
x_addrb(0) <= counter;
x_dinb(0) <= counter;
x_web(0) <= my_rdy;

STATE_PROC: process ( Clk ) is
  variable stage: integer := 0;
begin
 if ( Clk'event and Clk = '1' ) then
  if ( Reset = '1' ) then
par_out <= "00000000000000000000000000000001";
par_block <= '0';
counter <= "00000000000000000000000000000000";
else
if (my_rdy = "1") then
counter <= counter + "00000000000000000000000000000001";
end if;
if (par_we = "1") then
if (par_current = "0" and par_block = '0') then
par_out <= "00000000000000000000000000000000";
par_block <= '1';
end if;
end if;
if (REG_WE_B = "1") then
par_current(0 downto 0) <= par_addr(0 downto 0);
end if;
    case stage is
when 0 =>
  stage := stage + 1;
if (par_we /= "1" or par_current /= "0") then
	stage := 0;
else
my_rdy <= "1";
end if;
when 1 =>
  stage := stage + 1;
if (counter < "00000000000000000000010000000000") then
	stage := 1;
else
my_rdy <= "0";
par_out <= "00000000000000000000000000000001";
par_block <= '0';
	stage := 0;
counter <= "00000000000000000000000000000000";
end if;
when others => null;
    end case;
  end if;
 end if;
end process STATE_PROC;
end architecture IMP1;
