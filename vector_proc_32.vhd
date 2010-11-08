




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

  component HI_RAMB1
   generic (
        data_width: integer;
        address_width: integer;
	depth: integer
        );
   port (
        dob: out std_logic_vector(data_width-1 downto 0);
        doc: out std_logic_vector(data_width-1 downto 0);
        addra: in std_logic_vector(address_width-1 downto 0);
        addrb: in std_logic_vector(address_width-1 downto 0);
        addrc: in std_logic_vector(address_width-1 downto 0);
        clka: in std_ulogic;
        clkb: in std_ulogic;
        dia: in std_logic_vector(data_width-1 downto 0);
        rsta: in std_ulogic;
        rstb: in std_ulogic;
        wea: in std_ulogic
        );
  end component;

  component dotpro
	port (
D0in1: in std_logic_vector(31 downto 0);
D1in1: in std_logic_vector(31 downto 0);
D0in2: in std_logic_vector(31 downto 0);
D1in2: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Reset: in std_logic;
Clk: in std_logic);
  end component;

  component expr1
	port (
Din1: in std_logic_vector(31 downto 0);
Din2: in std_logic_vector(31 downto 0);
Din3: in std_logic_vector(31 downto 0);
Din4: in std_logic_vector(31 downto 0);
Din5: in std_logic_vector(31 downto 0);
Din6: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Clk: in std_logic);
  end component;

  component expr2
	port (
Din1: in std_logic_vector(31 downto 0);
Din2: in std_logic_vector(31 downto 0);
Din3: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Clk: in std_logic);
  end component;

--5
  component floating32_mul
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

--5
  component floating32_addsub
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	operation: IN std_logic;
	clk: IN std_logic);
  end component;

  component waits32_20
	port (
DI: in std_logic_vector(31 downto 0);
DO20: out std_logic_vector(31 downto 0);
Clk: in std_logic);
  end component;

  component waits32_5
	port (
DI: in std_logic_vector(31 downto 0);
DO5: out std_logic_vector(31 downto 0);
Clk: in std_logic);
  end component;

  component waits32_10_21
	port (
DI: in std_logic_vector(31 downto 0);
DO10: out std_logic_vector(31 downto 0);
DO21: out std_logic_vector(31 downto 0);
Clk: in std_logic);
  end component;

--    floatexpr::(in1/in2) 32 div 
--    waits::(expr1.out, 5) 32 expr1_delay(2)
	signal prt_data: std_logic_vector( 31 downto 0 );
	signal prt_addr: std_logic_vector( 31 downto 0 );
	type l2w1_type is array (0 to 1) of std_logic_vector(0 downto 0);
	signal prt_we: l2w1_type;
	signal prt_switch_in: std_logic_vector( 0 downto 0 );
	signal prt_switch_out: std_logic_vector( 0 downto 0 );
	type l2w32_type is array (0 to 1) of std_logic_vector(31 downto 0);
	signal x_addra: l2w32_type;
	signal x_addrb: l2w32_type;
	signal x_dina: l2w32_type;
	signal x_doutb: l2w32_type;
	signal x_wea: l2w1_type;
	signal x_dinb: l2w32_type;
	signal x_douta: l2w32_type;
	signal x_web: l2w1_type;
	signal b_addra: l2w32_type;
	signal b_addrb: l2w32_type;
	signal b_dina: l2w32_type;
	signal b_doutb: l2w32_type;
	signal b_wea: l2w1_type;
	signal b_dinb: l2w32_type;
	signal b_douta: l2w32_type;
	signal b_web: l2w1_type;
	signal par_data: std_logic_vector( 31 downto 0 );
	signal par_addr: std_logic_vector( 31 downto 0 );
	signal par_out: std_logic_vector( 31 downto 0 );
	signal par_we: std_logic_vector( 0 downto 0 );
	signal par_block: std_logic;
	signal leng: std_logic_vector( 31 downto 0 );
	signal last_adr: std_logic_vector( 31 downto 0 );
	signal rdx2: std_logic_vector( 31 downto 0 );
	signal rdy2: std_logic_vector( 31 downto 0 );
	signal const: std_logic_vector( 31 downto 0 );
	signal niter: std_logic_vector( 31 downto 0 );
	signal prt_bufout: l2w32_type;
	signal par_current: std_logic_vector( 2 downto 0 );
	signal buff_rdy: std_logic_vector( 0 downto 0 );
	signal buff_before_rdy: std_logic_vector( 0 downto 0 );
	signal buff_rr: std_logic_vector( 31 downto 0 );
	signal buff_ll: std_logic_vector( 31 downto 0 );
	signal buff_mid: l2w32_type;
	signal buff_right: l2w32_type;
	signal buff_left: l2w32_type;
	signal buff_addra: l2w32_type;
	signal buff_addrb: l2w32_type;
	signal buff_dina: l2w32_type;
	signal buff_doutb: l2w32_type;
	signal buff_wea: l2w1_type;
	signal buff_addrc: l2w32_type;
	signal buff_doutc: l2w32_type;
	signal dotpro_in1: l2w32_type;
	signal dotpro_in2: l2w32_type;
	signal dotpro_out: std_logic_vector( 31 downto 0 );
	signal dotpro_rdy: std_logic_vector( 0 downto 0 );
	signal dotpro_we: std_logic_vector( 0 downto 0 );
	signal expr1_in1: l2w32_type;
	signal expr1_in2: l2w32_type;
	signal expr1_in3: l2w32_type;
	signal expr1_in4: l2w32_type;
	signal expr1_in5: l2w32_type;
	signal expr1_in6: l2w32_type;
	signal expr1_out: l2w32_type;
	signal expr1_rdy: l2w1_type;
	signal expr1_we: l2w1_type;
	signal expr2_in1: l2w32_type;
	signal expr2_in2: l2w32_type;
	signal expr2_in3: l2w32_type;
	signal expr2_out: l2w32_type;
	signal expr2_rdy: l2w1_type;
	signal expr2_we: l2w1_type;
	signal mult_in1: l2w32_type;
	signal mult_in2: l2w32_type;
	signal mult_we: l2w1_type;
	signal mult_rdy: l2w1_type;
	signal mult_out: l2w32_type;
	signal addsub_in1: l2w32_type;
	signal addsub_in2: l2w32_type;
	signal addsub_we: l2w1_type;
	signal addsub_rdy: l2w1_type;
	signal addsub_out: l2w32_type;
	signal addsub_operation: l2w1_type;
	signal bout_delay_20: l2w32_type;
	signal rout_delay_5: l2w32_type;
	signal xout_delay_5: l2w32_type;
	signal buff_mid_delay_10: l2w32_type;
	signal buff_mid_delay_21: l2w32_type;
	signal mult_delay_5: l2w32_type;
	signal r_addra: l2w32_type;
	signal r_addrb: l2w32_type;
	signal r_dina: l2w32_type;
	signal r_doutb: l2w32_type;
	signal r_wea: l2w1_type;
	signal r_dinb: l2w32_type;
	signal r_douta: l2w32_type;
	signal r_web: l2w1_type;
	signal p_addra: l2w32_type;
	signal p_addrb: l2w32_type;
	signal p_dina: l2w32_type;
	signal p_doutb: l2w32_type;
	signal p_wea: l2w1_type;
	signal p_dinb: l2w32_type;
	signal p_douta: l2w32_type;
	signal p_web: l2w1_type;
	signal q_addra: l2w32_type;
	signal q_addrb: l2w32_type;
	signal q_dina: l2w32_type;
	signal q_doutb: l2w32_type;
	signal q_wea: l2w1_type;
	signal q_dinb: l2w32_type;
	signal q_douta: l2w32_type;
	signal q_web: l2w1_type;
	signal addr_read: std_logic_vector( 31 downto 0 );
	signal addr_write1: std_logic_vector( 31 downto 0 );
	signal addr_write2: std_logic_vector( 31 downto 0 );
	signal addr_write_part: std_logic_vector( 31 downto 0 );
	signal counter: std_logic_vector( 31 downto 0 );
	signal rho1: std_logic_vector( 31 downto 0 );
	signal rho2: std_logic_vector( 31 downto 0 );
	signal gamma: std_logic_vector( 31 downto 0 );
	signal my_rdy: std_logic_vector( 0 downto 0 );
	signal dot_we: std_logic_vector( 0 downto 0 );
	signal phase: std_logic_vector( 1 downto 0 );
	signal blockwe: l2w1_type;
begin
x_gen: for x_i in 0 to 1 generate
begin
	x_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 512
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
b_gen: for b_i in 0 to 1 generate
begin
	b_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 512
	)
	port map (
		addra => b_addra(b_i),
		addrb => b_addrb(b_i),
		dia => b_dina(b_i),
		wea => b_wea(b_i)(0),
		dob => b_doutb(b_i),
		doa => b_douta(b_i),
		dib => b_dinb(b_i),
		web => b_web(b_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate b_gen;
buff_gen: for buff_i in 0 to 1 generate
begin
	buff_inst: HI_RAMB1
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 32
	)
	port map (
		addra => buff_addra(buff_i),
		addrb => buff_addrb(buff_i),
		dia => buff_dina(buff_i),
		wea => buff_wea(buff_i)(0),
		dob => buff_doutb(buff_i),
		addrc => buff_addrc(buff_i),
		doc => buff_doutc(buff_i),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate buff_gen;
r_gen: for r_i in 0 to 1 generate
begin
	r_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 512
	)
	port map (
		addra => r_addra(r_i),
		addrb => r_addrb(r_i),
		dia => r_dina(r_i),
		wea => r_wea(r_i)(0),
		dob => r_doutb(r_i),
		doa => r_douta(r_i),
		dib => r_dinb(r_i),
		web => r_web(r_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate r_gen;
p_gen: for p_i in 0 to 1 generate
begin
	p_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 512
	)
	port map (
		addra => p_addra(p_i),
		addrb => p_addrb(p_i),
		dia => p_dina(p_i),
		wea => p_wea(p_i)(0),
		dob => p_doutb(p_i),
		doa => p_douta(p_i),
		dib => p_dinb(p_i),
		web => p_web(p_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate p_gen;
q_gen: for q_i in 0 to 1 generate
begin
	q_inst: HI_RAMB
	generic map (
		 address_width => 32,
		 data_width => 32,
		 depth => 512
	)
	port map (
		addra => q_addra(q_i),
		addrb => q_addrb(q_i),
		dia => q_dina(q_i),
		wea => q_wea(q_i)(0),
		dob => q_doutb(q_i),
		doa => q_douta(q_i),
		dib => q_dinb(q_i),
		web => q_web(q_i)(0),
		clka => Clk,
		clkb => Clk,
		rsta => Reset,
		rstb => Reset
	);
end generate q_gen;

   COMPONENT1: dotpro
	port map (
	D0in1 => dotpro_in1(0),
	D1in1 => dotpro_in1(1),
	D0in2 => dotpro_in2(0),
	D1in2 => dotpro_in2(1),
	DOUT => dotpro_out,
	RDY => dotpro_rdy,
	EN => dotpro_we,
	Reset => Reset,
	Clk => Clk
	 );
loop116_gen: for i1 in 0 to 1 generate
begin

   COMPONENT2: expr1
	port map (
	Din1 => expr1_in1(i1),
	Din2 => expr1_in2(i1),
	Din3 => expr1_in3(i1),
	Din4 => expr1_in4(i1),
	Din5 => expr1_in5(i1),
	Din6 => expr1_in6(i1),
	DOUT => expr1_out(i1),
	RDY => expr1_rdy(i1),
	EN => expr1_we(i1),
	Clk => Clk
	 );
end generate loop116_gen;
loop130_gen: for i1 in 0 to 1 generate
begin

   COMPONENT3: expr2
	port map (
	Din1 => expr2_in1(i1),
	Din2 => expr2_in2(i1),
	Din3 => expr2_in3(i1),
	DOUT => expr2_out(i1),
	RDY => expr2_rdy(i1),
	EN => expr2_we(i1),
	Clk => Clk
	 );
end generate loop130_gen;
loop141_gen: for i1 in 0 to 1 generate
begin

   COMPONENT4: floating32_mul
	port map (
	a => mult_in1(i1),
	b => mult_in2(i1),
	operation_nd => mult_we(i1)(0),
	rdy => mult_rdy(i1)(0),
	result => mult_out(i1),
	Clk => Clk
	 );
end generate loop141_gen;
loop151_gen: for i1 in 0 to 1 generate
begin

   COMPONENT5: floating32_addsub
	port map (
	a => addsub_in1(i1),
	b => addsub_in2(i1),
	operation_nd => addsub_we(i1)(0),
	rdy => addsub_rdy(i1)(0),
	result => addsub_out(i1),
	operation => addsub_operation(i1)(0),
	Clk => Clk
	 );
end generate loop151_gen;
loop162_gen: for i1 in 0 to 1 generate
begin

   COMPONENT6: waits32_20
	port map (
	DI => b_doutb(i1),
	DO20 => bout_delay_20(i1),
	Clk => Clk
	 );
end generate loop162_gen;
loop169_gen: for i1 in 0 to 1 generate
begin

   COMPONENT7: waits32_5
	port map (
	DI => r_doutb(i1),
	DO5 => rout_delay_5(i1),
	Clk => Clk
	 );
end generate loop169_gen;
loop176_gen: for i1 in 0 to 1 generate
begin

   COMPONENT8: waits32_5
	port map (
	DI => x_doutb(i1),
	DO5 => xout_delay_5(i1),
	Clk => Clk
	 );
end generate loop176_gen;
loop183_gen: for i1 in 0 to 1 generate
begin

   COMPONENT9: waits32_10_21
	port map (
	DI => buff_mid(i1),
	DO10 => buff_mid_delay_10(i1),
	DO21 => buff_mid_delay_21(i1),
	Clk => Clk
	 );
end generate loop183_gen;
loop191_gen: for i1 in 0 to 1 generate
begin

   COMPONENT10: waits32_5
	port map (
	DI => mult_out(i1),
	DO5 => mult_delay_5(i1),
	Clk => Clk
	 );
end generate loop191_gen;
prt_data <= DI;
prt_addr(31 downto 31) <= "0";
prt_addr(30 downto 0) <= ADDR(31 downto 1);
prt_switch_in <= ADDR(0 downto 0);
loop202_gen: for i1 in 0 to 1 generate
begin
prt_we(i1) <= WE when (prt_switch_in = i1) else  "0";
end generate loop202_gen;
par_data <= REG_IN_A;
par_addr <= REG_IN_B;
REG_OUT_B <= par_out;
par_we <= REG_WE_A;
REG_OUT_A <= rho1;
loop210_gen: for i1 in 0 to 1 generate
begin
DO <= prt_bufout(i1) when (prt_switch_out = i1) else  (others => 'Z');
end generate loop210_gen;
loop213_gen: for i1 in 0 to 1 generate
begin
prt_bufout(i1) <= x_douta(i1) when (par_current = "000") else r_douta(i1) when (par_current = "001") else  q_douta(i1);
end generate loop213_gen;
b_wea(0) <= "1" when (par_current = "001" and prt_we(0) = "1") else  "0";
b_wea(1) <= "1" when (par_current = "001" and prt_we(1) = "1") else  "0";
b_dina(0) <= prt_data;
b_dina(1) <= prt_data;
b_addra(0) <= prt_addr;
b_addra(1) <= prt_addr;
buff_right(1) <= buff_doutb(0);
buff_left(0) <= buff_ll;
buff_left(1) <= buff_rr;
buff_mid(0) <= buff_rr;
loop226_gen: for i1 in 1 to 1 generate
begin
buff_mid(i1) <= buff_doutb(i1);
end generate loop226_gen;
loop229_gen: for i1 in 2 to 1 generate
begin
buff_left(i1) <= buff_doutb(i1-1);
end generate loop229_gen;
loop232_gen: for i1 in 0 to 0 generate
begin
buff_right(i1) <= buff_doutb(i1+1);
end generate loop232_gen;
loop236_gen: for i236 in 0 to 1 generate
begin
x_addrb(i236) <= addr_read;
r_addrb(i236) <= addr_read;
q_addrb(i236) <= addr_read;
p_addrb(i236) <= addr_read;
end generate loop236_gen;
loop238_gen: for i238 in 0 to 1 generate
begin
buff_wea(i238) <= my_rdy when (phase = "01") else  addsub_rdy(i238);
end generate loop238_gen;
loop239_gen: for i239 in 0 to 1 generate
begin
buff_dina(i239) <= x_doutb(i239) when (phase = "01") else  p_doutb(i239);
end generate loop239_gen;
loop241_gen: for i241 in 0 to 1 generate
begin
expr1_we(i241) <= buff_rdy;
end generate loop241_gen;
loop242_gen: for i242 in 0 to 1 generate
begin
expr1_in1(i242) <= buff_left(i242);
end generate loop242_gen;
loop243_gen: for i243 in 0 to 1 generate
begin
expr1_in2(i243) <= buff_right(i243);
end generate loop243_gen;
loop244_gen: for i244 in 0 to 1 generate
begin
expr1_in3(i244) <= rdx2;
end generate loop244_gen;
loop245_gen: for i245 in 0 to 1 generate
begin
expr1_in4(i245) <= buff_doutc(i245);
end generate loop245_gen;
loop246_gen: for i246 in 0 to 1 generate
begin
expr1_in5(i246) <= buff_dina(i246);
end generate loop246_gen;
loop247_gen: for i247 in 0 to 1 generate
begin
expr1_in6(i247) <= rdy2;
end generate loop247_gen;
loop249_gen: for i249 in 0 to 1 generate
begin
expr2_we(i249) <= my_rdy when (phase = "10") else  expr1_rdy(i249);
end generate loop249_gen;
loop250_gen: for i250 in 0 to 1 generate
begin
expr2_in1(i250) <= expr1_out(i250) when (phase < "10") else  xout_delay_5(i250);
end generate loop250_gen;
loop251_gen: for i251 in 0 to 1 generate
begin
expr2_in2(i251) <= buff_mid_delay_10(i251) when (phase < "10") else  gamma;
end generate loop251_gen;
loop252_gen: for i252 in 0 to 1 generate
begin
expr2_in3(i252) <= p_doutb(i252) when (phase = "10") else  const;
end generate loop252_gen;
loop254_gen: for i254 in 0 to 1 generate
begin
mult_we(i254) <= my_rdy;
end generate loop254_gen;
loop255_gen: for i255 in 0 to 1 generate
begin
mult_in1(i255) <= gamma;
end generate loop255_gen;
loop256_gen: for i256 in 0 to 1 generate
begin
mult_in2(i256) <= p_doutb(i256) when (phase = "00") else  q_doutb(i256);
end generate loop256_gen;
loop258_gen: for i258 in 0 to 1 generate
begin
addsub_we(i258) <= expr2_rdy(i258) when (phase = "01") else  mult_rdy(i258);
end generate loop258_gen;
loop259_gen: for i259 in 0 to 1 generate
begin
addsub_operation(i259) <= "0" when (phase = "00") else  "1";
end generate loop259_gen;
loop260_gen: for i260 in 0 to 1 generate
begin
addsub_in1(i260) <= bout_delay_20(i260) when (phase = "01") else  rout_delay_5(i260);
end generate loop260_gen;
loop261_gen: for i261 in 0 to 1 generate
begin
addsub_in2(i261) <= expr2_out(i261) when (phase = "01") else  mult_out(i261);
end generate loop261_gen;
dot_we <= addsub_rdy(0) when (phase = "01") else expr2_rdy(0) when (phase = "10") else  "0";
loop264_gen: for i264 in 0 to 1 generate
begin
dotpro_in1(i264) <= r_douta(i264) when (phase > "00") else  buff_mid_delay_21(i264);
end generate loop264_gen;
loop265_gen: for i265 in 0 to 1 generate
begin
dotpro_in2(i265) <= r_douta(i265) when (phase > "00") else  q_douta(i265);
end generate loop265_gen;
--    div.we = (phase == 1) ? 0 : dotpro.rdy
--    div.in1 = (phase == 0) ? rho1 : dotpro.out
--    div.in2 = (phase == 0) ? dotpro.out : rho2 
loop271_gen: for i271 in 0 to 1 generate
begin
q_wea(i271) <= expr2_rdy(0) and not blockwe(i271) when (phase = "00") else  "0";
end generate loop271_gen;
loop272_gen: for i272 in 0 to 1 generate
begin
q_addra(i272) <= prt_addr when (EN = "1" or WE = "1") else  addr_write_part;
end generate loop272_gen;
loop273_gen: for i273 in 0 to 1 generate
begin
q_dina(i273) <= expr2_out(i273) when (phase = "00") else  "00000000000000000000000000000000";
end generate loop273_gen;
loop275_gen: for i275 in 0 to 1 generate
begin
r_wea(i275) <= addsub_rdy(0) and not blockwe(i275) when (phase = "01") else addsub_rdy(0) when (phase = "10") else  "0";
end generate loop275_gen;
loop276_gen: for i276 in 0 to 1 generate
begin
r_addra(i276) <= prt_addr when (EN = "1" or WE = "1") else addr_write_part when (phase = "01") else  addr_write2;
end generate loop276_gen;
loop277_gen: for i277 in 0 to 1 generate
begin
r_dina(i277) <= addsub_out(i277);
end generate loop277_gen;
loop279_gen: for i279 in 0 to 1 generate
begin
p_wea(i279) <= addsub_rdy(i279) when (phase = "00") else  "0";
end generate loop279_gen;
loop280_gen: for i280 in 0 to 1 generate
begin
p_dina(i280) <= addsub_out(i280) when (phase = "00") else  "00000000000000000000000000000000";
end generate loop280_gen;
loop281_gen: for i281 in 0 to 1 generate
begin
p_addra(i281) <= addr_write1;
end generate loop281_gen;
loop283_gen: for i283 in 0 to 1 generate
begin
x_wea(i283) <= "1" when (par_current = "000" and prt_we(i283) = "1") else expr2_rdy(i283) when (phase = "10") else  "0";
end generate loop283_gen;
loop284_gen: for i284 in 0 to 1 generate
begin
x_dina(i284) <= prt_data when (WE = "1") else expr2_out(i284) when (phase = "10") else  "00000000000000000000000000000000";
end generate loop284_gen;
loop285_gen: for i285 in 0 to 1 generate
begin
x_addra(i285) <= prt_addr when (EN = "1" or WE = "1") else  addr_write2;
end generate loop285_gen;
loop287_gen: for i287 in 0 to 1 generate
begin
x_web(i287) <= "0";
b_web(i287) <= "0";
r_web(i287) <= "0";
p_web(i287) <= "0";
q_web(i287) <= "0";
end generate loop287_gen;
--определ€ем границы массива дл€ блокировки записи:
blockwe(0) <= "1" when (counter = "00000000000000000000000000000001") else  "0";
blockwe(1) <= "1" when (counter = leng) else  "0";

STATE_PROC: process ( Clk ) is
  variable stage: integer := 0;
begin
 if ( Clk'event and Clk = '1' ) then
  if ( Reset = '1' ) then
par_out <= "00000000000000000000000000000001";
par_block <= '0';
phase <= "01";
gamma <= "00000000000000000000000000000000";
my_rdy <= "0";
else
buff_ll <= buff_doutb(1);
buff_rr <= buff_doutb(0);
if (buff_wea(1) = "1") then
for i304 in 0 to 1 loop
buff_addra(i304) <= buff_addra(i304) + "00000000000000000000000000000001";
end loop;
if (buff_addra(0) >= leng(31 downto 0)+"11111111111111111111111111111111") then
for i306 in 0 to 1 loop
buff_addrb(i306) <= buff_addrb(i306) + "00000000000000000000000000000001";
end loop;
end if;
if (buff_addrb(0) >= leng(31 downto 0)) then
buff_before_rdy <= "1";
if (buff_addrb(0) > leng(31 downto 0)) then
for i311 in 0 to 1 loop
buff_addrc(i311) <= buff_addrc(i311) + "00000000000000000000000000000001";
end loop;
buff_rdy <= "1";
end if;
end if;
else
buff_rdy <= "0";
buff_before_rdy <= "0";
for i318 in 0 to 1 loop
buff_addra(i318) <= "00000000000000000000000000000000";
end loop;
for i319 in 0 to 1 loop
buff_addrc(i319) <= "00000000000000000000000000000000";
end loop;
buff_addrb(0) <= "00000000000000000000000000000001";
for i1 in 1 to 1 loop
buff_addrb(i1) <= "00000000000000000000000000000000";
end loop;
end if;
dotpro_we <= dot_we;
if (buff_before_rdy = "1") then
for i327 in 0 to 1 loop
b_addrb(i327) <= b_addrb(i327) + "00000000000000000000000000000001";
end loop;
else
for i329 in 0 to 1 loop
b_addrb(i329) <= leng;
end loop;
end if;
-- јдрес дл€ полных циклов
if (addsub_rdy(0) = "1") then
addr_write1 <= addr_write1 + "00000000000000000000000000000001";
else
addr_write1 <= "00000000000000000000000000000000";
end if;
if (expr2_rdy(0) = "1") then
addr_write2 <= addr_write2 + "00000000000000000000000000000001";
else
addr_write2 <= "00000000000000000000000000000000";
end if;
-- јдрес дл€ неполных циклов
if (addsub_rdy(0) = "1" or expr2_rdy(0) = "1") then
addr_write_part <= addr_write_part + "00000000000000000000000000000001";
else
addr_write_part <= leng;
end if;
if (((phase = "01") and (addsub_rdy(0) = "1")) or ((phase = "00") and (expr2_rdy(0) = "1"))) then
if (counter = leng) then
counter <= "00000000000000000000000000000001";
else
counter <= counter + "00000000000000000000000000000001";
end if;
else
counter <= "00000000000000000000000000000001";
end if;
prt_switch_out <= prt_switch_in;
if (par_we = "1") then
if (par_current = "000" and par_block = '0') then
par_out <= "00000000000000000000000000000000";
par_block <= '1';
end if;
if (par_current = "001") then
leng <= par_data;
end if;
if (par_current = "010") then
last_adr <= par_data;
end if;
if (par_current = "011") then
rdx2 <= par_data;
end if;
if (par_current = "100") then
rdy2 <= par_data;
end if;
if (par_current = "101") then
const <= par_data;
end if;
if (par_current = "110") then
niter <= par_data;
end if;
end if;
if (REG_WE_B = "1") then
par_current(2 downto 0) <= par_addr(2 downto 0);
end if;
    case stage is
when 0 =>
  stage := stage + 1;
if (par_we /= "1" or par_current /= "110") then
	stage := 0;
else
phase <= "01";
my_rdy <= "1";
addr_read <= "00000000000000000000000000000000";
end if;
when 1 =>
  stage := stage + 1;
if (addr_read < last_adr) then
	stage := 1;
my_rdy <= "1";
addr_read <= addr_read + "00000000000000000000000000000001";
else
my_rdy <= "0";
addr_read <= "00000000000000000000000000000000";
end if;
when 2 =>
  stage := stage + 1;
if (dotpro_rdy = "0") then
	stage := 2;
end if;
when 3 =>
  stage := stage + 1;
rho1 <= dotpro_out;
if (phase = "01") then
phase <= "00";
	stage := 1;
else
gamma <= "10111111000001111001111101000101";
if (phase = "00") then
phase <= "10";
else
phase <= "00";
niter <= niter + "11111111111111111111111111111111";
if (niter > "00000000000000000000000000000001") then
	stage := 1;
else
par_out <= "00000000000000000000000000000001";
par_block <= '0';
	stage := 0;
end if;
end if;
end if;
when others => null;
    end case;
  end if;
 end if;
end process STATE_PROC;
end architecture IMP1;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dotpro is
	port (
D0in1: in std_logic_vector(31 downto 0);
D1in1: in std_logic_vector(31 downto 0);
D0in2: in std_logic_vector(31 downto 0);
D1in2: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Reset: in std_logic;
Clk: in std_logic);
end entity dotpro;

architecture IMPZ0 of dotpro is
--5
  component floating32_mul
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

--5
  component floating32_add
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

--
  component floating32_sumagre
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	Reset: in std_logic;
	clk: IN std_logic);
  end component;
  signal v0in1: std_logic_vector(31 downto 0);
  signal v1in1: std_logic_vector(31 downto 0);
  signal v0in2: std_logic_vector(31 downto 0);
  signal v1in2: std_logic_vector(31 downto 0);
  signal rdyX: std_logic;
  signal X: std_logic_vector(31 downto 0);
  signal rdyXX: std_logic;
  signal XX: std_logic_vector(31 downto 0);
  signal rdyL0: std_logic;
  signal L0: std_logic_vector(31 downto 0);
  signal rdysumkob: std_logic;
  signal sumkob: std_logic_vector(31 downto 0);
  signal enin: std_logic;

 begin
 v0in1 <= D0in1;
 v1in1 <= D1in1;
 v0in2 <= D0in2;
 v1in2 <= D1in2;
 DOUT <= sumkob;
 RDY(0) <= rdysumkob;
 enin <= EN(0);

   COMPLB1: floating32_mul
	port map (
    a => v0in1,
    b => v0in2,
    operation_nd => enin,
    rdy => rdyX,
    result => X,
    clk => Clk);

   COMPLB2: floating32_mul
	port map (
    a => v1in1,
    b => v1in2,
    operation_nd => enin,
    rdy => rdyXX,
    result => XX,
    clk => Clk);

   COMPLB3: floating32_add
	port map (
    a => X,
    b => XX,
    operation_nd => rdyX,
    rdy => rdyL0,
    result => L0,
    clk => Clk);

   COMPLB4: floating32_sumagre
	port map (
    a => L0,
    operation_nd => rdyL0,
    rdy => rdysumkob,
    result => sumkob,
    Reset => Reset,
    clk => Clk);

end architecture IMPZ0;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity expr1 is
	port (
Din1: in std_logic_vector(31 downto 0);
Din2: in std_logic_vector(31 downto 0);
Din3: in std_logic_vector(31 downto 0);
Din4: in std_logic_vector(31 downto 0);
Din5: in std_logic_vector(31 downto 0);
Din6: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Clk: in std_logic);
end entity expr1;

architecture IMPZ1 of expr1 is
--5
  component floating32_add
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

--5
  component floating32_mul
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

  signal in1: std_logic_vector(31 downto 0);
  signal in2: std_logic_vector(31 downto 0);
  signal in3: std_logic_vector(31 downto 0);
  signal in4: std_logic_vector(31 downto 0);
  signal in5: std_logic_vector(31 downto 0);
  signal in6: std_logic_vector(31 downto 0);
  signal rdyX: std_logic;
  signal X: std_logic_vector(31 downto 0);
  signal rdyX1: std_logic;
  signal X1: std_logic_vector(31 downto 0);
  signal rdyX2: std_logic;
  signal X2: std_logic_vector(31 downto 0);
  signal rdyX3: std_logic;
  signal X3: std_logic_vector(31 downto 0);
  signal rdyX4: std_logic;
  signal X4: std_logic_vector(31 downto 0);
  signal enin: std_logic;

 begin
 in1 <= Din1;
 in2 <= Din2;
 in3 <= Din3;
 in4 <= Din4;
 in5 <= Din5;
 in6 <= Din6;
 DOUT <= X4;
 RDY(0) <= rdyX1;
 enin <= EN(0);

   COMPLB1: floating32_add
	port map (
    a => in1,
    b => in2,
    operation_nd => enin,
    rdy => rdyX,
    result => X,
    clk => Clk);

   COMPLB2: floating32_mul
	port map (
    a => X,
    b => in3,
    operation_nd => rdyX,
    rdy => rdyX1,
    result => X1,
    clk => Clk);

   COMPLB3: floating32_add
	port map (
    a => in4,
    b => in5,
    operation_nd => enin,
    rdy => rdyX2,
    result => X2,
    clk => Clk);

   COMPLB4: floating32_mul
	port map (
    a => X2,
    b => in6,
    operation_nd => rdyX2,
    rdy => rdyX3,
    result => X3,
    clk => Clk);

   COMPLB5: floating32_add
	port map (
    a => X1,
    b => X3,
    operation_nd => rdyX1,
    rdy => rdyX4,
    result => X4,
    clk => Clk);

end architecture IMPZ1;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity expr2 is
	port (
Din1: in std_logic_vector(31 downto 0);
Din2: in std_logic_vector(31 downto 0);
Din3: in std_logic_vector(31 downto 0);
DOUT: out std_logic_vector(31 downto 0);
RDY: out std_logic_vector(0 downto 0);
EN: in std_logic_vector(0 downto 0);
Clk: in std_logic);
end entity expr2;

architecture IMPZ2 of expr2 is
--5
  component floating32_mul
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

--5
  component floating32_add
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0);
	operation_nd: IN std_logic;
	rdy: OUT std_logic;
	clk: IN std_logic);
  end component;

  signal in1: std_logic_vector(31 downto 0);
  signal in2: std_logic_vector(31 downto 0);
  signal in3: std_logic_vector(31 downto 0);
  signal rdyX: std_logic;
  signal X: std_logic_vector(31 downto 0);
  signal rdyX1: std_logic;
  signal X1: std_logic_vector(31 downto 0);
  signal enin: std_logic;

 begin
 in1 <= Din1;
 in2 <= Din2;
 in3 <= Din3;
 DOUT <= X1;
 RDY(0) <= rdyX1;
 enin <= EN(0);

   COMPLB1: floating32_mul
	port map (
    a => in2,
    b => in3,
    operation_nd => enin,
    rdy => rdyX,
    result => X,
    clk => Clk);

   COMPLB2: floating32_add
	port map (
    a => in1,
    b => X,
    operation_nd => rdyX,
    rdy => rdyX1,
    result => X1,
    clk => Clk);

end architecture IMPZ2;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity waits32_20 is
	port (
DI: in std_logic_vector(31 downto 0);
DO20: out std_logic_vector(31 downto 0);
Clk: in std_logic);
end entity waits32_20;

architecture IMPZ3 of waits32_20 is
  signal ww1: std_logic_vector(31 downto 0);
  signal ww2: std_logic_vector(31 downto 0);
  signal ww3: std_logic_vector(31 downto 0);
  signal ww4: std_logic_vector(31 downto 0);
  signal ww5: std_logic_vector(31 downto 0);
  signal ww6: std_logic_vector(31 downto 0);
  signal ww7: std_logic_vector(31 downto 0);
  signal ww8: std_logic_vector(31 downto 0);
  signal ww9: std_logic_vector(31 downto 0);
  signal ww10: std_logic_vector(31 downto 0);
  signal ww11: std_logic_vector(31 downto 0);
  signal ww12: std_logic_vector(31 downto 0);
  signal ww13: std_logic_vector(31 downto 0);
  signal ww14: std_logic_vector(31 downto 0);
  signal ww15: std_logic_vector(31 downto 0);
  signal ww16: std_logic_vector(31 downto 0);
  signal ww17: std_logic_vector(31 downto 0);
  signal ww18: std_logic_vector(31 downto 0);
  signal ww19: std_logic_vector(31 downto 0);
  signal ww20: std_logic_vector(31 downto 0);

 begin
 DO20 <= ww20;
STATE_PROC: process (Clk)
begin
  if( Clk'event and Clk = '1' ) then
  ww1 <= DI;
   ww2 <= ww1;
   ww3 <= ww2;
   ww4 <= ww3;
   ww5 <= ww4;
   ww6 <= ww5;
   ww7 <= ww6;
   ww8 <= ww7;
   ww9 <= ww8;
   ww10 <= ww9;
   ww11 <= ww10;
   ww12 <= ww11;
   ww13 <= ww12;
   ww14 <= ww13;
   ww15 <= ww14;
   ww16 <= ww15;
   ww17 <= ww16;
   ww18 <= ww17;
   ww19 <= ww18;
   ww20 <= ww19;
  end if;
end process STATE_PROC;

end architecture IMPZ3;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity waits32_5 is
	port (
DI: in std_logic_vector(31 downto 0);
DO5: out std_logic_vector(31 downto 0);
Clk: in std_logic);
end entity waits32_5;

architecture IMPZ4 of waits32_5 is
  signal ww1: std_logic_vector(31 downto 0);
  signal ww2: std_logic_vector(31 downto 0);
  signal ww3: std_logic_vector(31 downto 0);
  signal ww4: std_logic_vector(31 downto 0);
  signal ww5: std_logic_vector(31 downto 0);

 begin
 DO5 <= ww5;
STATE_PROC: process (Clk)
begin
  if( Clk'event and Clk = '1' ) then
  ww1 <= DI;
   ww2 <= ww1;
   ww3 <= ww2;
   ww4 <= ww3;
   ww5 <= ww4;
  end if;
end process STATE_PROC;

end architecture IMPZ4;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity waits32_10_21 is
	port (
DI: in std_logic_vector(31 downto 0);
DO10: out std_logic_vector(31 downto 0);
DO21: out std_logic_vector(31 downto 0);
Clk: in std_logic);
end entity waits32_10_21;

architecture IMPZ5 of waits32_10_21 is
  signal ww1: std_logic_vector(31 downto 0);
  signal ww2: std_logic_vector(31 downto 0);
  signal ww3: std_logic_vector(31 downto 0);
  signal ww4: std_logic_vector(31 downto 0);
  signal ww5: std_logic_vector(31 downto 0);
  signal ww6: std_logic_vector(31 downto 0);
  signal ww7: std_logic_vector(31 downto 0);
  signal ww8: std_logic_vector(31 downto 0);
  signal ww9: std_logic_vector(31 downto 0);
  signal ww10: std_logic_vector(31 downto 0);
  signal ww11: std_logic_vector(31 downto 0);
  signal ww12: std_logic_vector(31 downto 0);
  signal ww13: std_logic_vector(31 downto 0);
  signal ww14: std_logic_vector(31 downto 0);
  signal ww15: std_logic_vector(31 downto 0);
  signal ww16: std_logic_vector(31 downto 0);
  signal ww17: std_logic_vector(31 downto 0);
  signal ww18: std_logic_vector(31 downto 0);
  signal ww19: std_logic_vector(31 downto 0);
  signal ww20: std_logic_vector(31 downto 0);
  signal ww21: std_logic_vector(31 downto 0);

 begin
 DO10 <= ww10;
 DO21 <= ww21;
STATE_PROC: process (Clk)
begin
  if( Clk'event and Clk = '1' ) then
  ww1 <= DI;
   ww2 <= ww1;
   ww3 <= ww2;
   ww4 <= ww3;
   ww5 <= ww4;
   ww6 <= ww5;
   ww7 <= ww6;
   ww8 <= ww7;
   ww9 <= ww8;
   ww10 <= ww9;
   ww11 <= ww10;
   ww12 <= ww11;
   ww13 <= ww12;
   ww14 <= ww13;
   ww15 <= ww14;
   ww16 <= ww15;
   ww17 <= ww16;
   ww18 <= ww17;
   ww19 <= ww18;
   ww20 <= ww19;
   ww21 <= ww20;
  end if;
end process STATE_PROC;

end architecture IMPZ5;
