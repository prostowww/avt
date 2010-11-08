library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vector_proc_32_ext is
	port
	(
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
end entity vector_proc_32_ext;


architecture IMP of vector_proc_32_ext is
  component vector_proc_32
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
	Reset: in std_logic
       );	
  end component;
begin
vector_proc_inst: vector_proc_32
    port map	(
	Clk => Clk,
	Reset => Reset,
	EN => EN,
	WE => WE,
	ADDR => ADDR,
	DI => DI,
	DO => DO,
	REG_WE_A => REG_WE_A,
	REG_WE_B => REG_WE_B,
	REG_IN_A => REG_IN_A,
	REG_IN_B => REG_IN_B,
	REG_OUT_A => REG_OUT_A,
	REG_OUT_B => REG_OUT_B
		);
--
--
--
	reqaddr_o <= "11111111111111111111111111111111";
	reqlength_o <= "1111111111";
	reqtag_o <= "11111111";
	reqiswrite_o <= '0';
	request_o <= '0';
--
	reqdata_o <= "11111111111111111111111111111111";
	reqwe_o <= '0';
end IMP;
