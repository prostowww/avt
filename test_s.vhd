


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

	signal prt_data: std_logic_vector( 31 downto 0 );
	signal prt_addr: std_logic_vector( 31 downto 0 );
	signal prt_we: std_logic_vector( 0 downto 0 );
	signal prt_switch_in: std_logic;
	signal prt_switch_out: std_logic;
	signal par_data: std_logic_vector( 31 downto 0 );
	signal par_addr: std_logic_vector( 31 downto 0 );
	signal par_out: std_logic_vector( 31 downto 0 );
	signal par_we: std_logic_vector( 0 downto 0 );
	signal par_block: std_logic;
	signal add: std_logic_vector( 31 downto 0 );
	signal par_current: std_logic_vector( 1 downto 0 );
	signal counter: std_logic_vector( 31 downto 0 );
	signal my_rdy: std_logic_vector( 0 downto 0 );
begin
prt_data <= DI;
prt_addr <= ADDR;
prt_we <= WE;
par_data <= REG_IN_A;
par_addr <= REG_IN_B;
REG_OUT_B <= par_out;
par_we <= REG_WE_A;
REG_OUT_A <= "00000000000000000000000000000000";

STATE_PROC: process ( Clk ) is
  variable stage: integer := 0;
begin
 if ( Clk'event and Clk = '1' ) then
  if ( Reset = '1' ) then
par_out <= "00000000000000000000000000000001";
par_block <= '0';
else
if (par_we = "1") then
if (par_current = "00" and par_block = '0') then
par_out <= "00000000000000000000000000000000";
par_block <= '1';
end if;
if (par_current = "01") then
add <= par_data;
end if;
end if;
if (REG_WE_B = "1") then
par_current(1 downto 0) <= par_addr(1 downto 0);
end if;
    case stage is
      when 0 =>
          stage := stage + 1;
        if (par_we /= "1" or par_current /= "00") then
          stage := 0;
        end if;
      when 1 =>
          stage := stage + 1;
        if (counter < "00000000000000000000000000100000") then
          stage := 1;
        else
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
