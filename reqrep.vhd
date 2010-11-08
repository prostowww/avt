library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity reqrep is
  generic
  (
    N: integer := 8
  );
  port
  (
--    clk:    in std_logic;
    nout:   in std_logic_vector(2 downto 0);
-- upstream port:
--
-- reply (completion) data:
    compltag_i:     in std_logic_vector(7 downto 0);
    compldata_i:    in std_logic_vector(31 downto 0);
    complwe_i:      in std_logic;
-- request data:
--
-- request head ports:
    reqaddr_o:      out std_logic_vector(31 downto 0);
    reqlength_o:    out std_logic_vector(9 downto 0);
    reqtag_o:       out std_logic_vector(7 downto 0);
    reqiswrite_o:   out std_logic;
    request_o:      out std_logic;
    grant_i:        in  std_logic;
-- write request data transfer ports:
    reqdata_o:      out std_logic_vector(31 downto 0);
    reqwe_o:        out std_logic;
    reqbusy_i:      in  std_logic;
-- downstream ports:
--
--
    compltag_o:     out std_logic_vector(5*N-1 downto 0);
    compldata_o:    out std_logic_vector(32*N-1 downto 0);
    complwe_o:      out std_logic_vector(N-1 downto 0);
--
    reqaddr_i:      in  std_logic_vector(32*N-1 downto 0);
    reqlength_i:    in  std_logic_vector(10*N-1 downto 0);
    reqtag_i:       in  std_logic_vector(5*N-1 downto 0);
    reqiswrite_i:   in  std_logic_vector(N-1 downto 0);
    request_i:      in  std_logic_vector(N-1 downto 0);
    grant_o:        out std_logic_vector(N-1 downto 0);
    reqdata_i:      in  std_logic_vector(32*N-1 downto 0);
    reqwe_i:        in  std_logic_vector(N-1 downto 0);
    reqbusy_o:      out std_logic_vector(N-1 downto 0)
  );
end entity reqrep;

architecture IMP of reqrep is

begin
-- generic validation
	assert N <= 8
	report "Maximal number of internal I/O ports is 8"
	severity FAILURE;

  DOWNPORTS_GEN: for i in N-1 downto 0 generate
    begin
      compldata_o(32*(i+1)-1 downto 32*i) <= compldata_i;
      compltag_o(5*(i+1)-1 downto 5*i) <= compltag_i(7 downto 3);
      complwe_o(i)  <= '1' when conv_integer( compltag_i(2 downto 0) ) = i  and complwe_i = '1' else '0'; 
      grant_o(i)    <= '1' when conv_integer( nout ) = i and grant_i = '1' else '0';
--      grant_o(i)    <= grant_i;
      reqbusy_o(i)  <= '0' when conv_integer( nout ) = i and reqbusy_i = '0' else '1';
--      reqbusy_o(i)  <= reqbusy_i;

      -- form tag
      reqtag_o(2 downto 0) <= conv_std_logic_vector(i,3)     when conv_integer( nout ) = i else (others => 'Z');
      reqtag_o(7 downto 3) <= reqtag_i(5*(i+1)-1 downto 5*i) when conv_integer( nout ) = i else (others => 'Z');
      
      reqaddr_o     <= reqaddr_i(32*(i+1)-1 downto 32*i)    when conv_integer( nout ) = i else (others => 'Z');
      reqlength_o   <= reqlength_i(10*(i+1)-1 downto 10*i)  when conv_integer( nout ) = i else (others => 'Z');
      reqiswrite_o  <= reqiswrite_i(i)                      when conv_integer( nout ) = i else 'Z';
      request_o     <= request_i(i)                         when conv_integer( nout ) = i else 'Z';
      reqdata_o     <= reqdata_i(32*(i+1)-1 downto 32*i)    when conv_integer( nout ) = i else (others => 'Z');
      reqwe_o       <= reqwe_i(i)                           when conv_integer( nout ) = i else 'Z'; 
    end generate DOWNPORTS_GEN;

--  process
--  begin
--    for i in 1 to 100 loop
--      nout <= "000";
--      wait for 5 us;
--      nout <= "001";
--      wait for 5 us;
--      nout <= "010";
--      wait for 5 us;
--      nout <= "011";
--      wait for 5 us;
--      -- clock period = 10 ns
--    end loop;
--  end process;

--  REQUEST_PROC: process ( clk ) is
--  begin
--    if clk'event and clk = '1' then
--      
--    end if;
--  end process REQUEST_PROC;
end IMP;
