library ieee;
use ieee.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;

entity priority is
  generic
  (
    N: integer := 8
  );
  port
  (
    clk: in std_logic;
    
    request_i: in  std_logic_vector(N-1 downto 0);
    grant_i: in std_logic;
    nout_o: out std_logic_vector(2 downto 0)
  );
end entity priority;

architecture IMP of priority is

    signal local: std_logic_vector(7 downto 0);
    signal temp: std_logic_vector(7 downto 0);
    shared variable nout: std_logic_vector(2 downto 0);
    signal switched: std_logic;
    signal grant_del: std_logic;
    
begin
  assert N <= 8
  report "Maximal number of internal I/O ports is 8"
  severity FAILURE;

  local(N-1 downto 0) <= request_i;
   
  SWITCH: process (clk) is
  variable empty: std_logic:='0';
  variable diff: std_logic_vector(2 downto 0);
  begin
    if (clk'event and clk = '1') then
      grant_del <= grant_i;
      if (grant_i = '0' and switched = '0') then
        if    temp(0)='1' then diff := "001";
        elsif temp(1)='1' then diff := "010";
        elsif temp(2)='1' then diff := "011";
        elsif temp(3)='1' then diff := "100";
        elsif temp(4)='1' then diff := "101";
        elsif temp(5)='1' then diff := "110";
        elsif temp(6)='1' then diff := "111";
        elsif temp(7)='1' then diff := "000";
        else empty:='1';
        end if;
        if empty = '0' then 
          nout := nout + diff;
          nout_o <= nout;
          switched <= '1';
         end if;
      elsif (grant_del='1' and grant_i = '0') then
        switched <= '0';
      end if;
    end if;
  end process SWITCH;
   
  temp_renew: process (clk) is
  begin
    if (clk'event and clk = '1') then
      case nout is
        when "000" => temp(7 downto 0) <= local(0 downto 0) & local(7 downto 1);
        when "001" => temp(7 downto 0) <= local(1 downto 0) & local(7 downto 2);
        when "010" => temp(7 downto 0) <= local(2 downto 0) & local(7 downto 3);
        when "011" => temp(7 downto 0) <= local(3 downto 0) & local(7 downto 4);
        when "100" => temp(7 downto 0) <= local(4 downto 0) & local(7 downto 5);
        when "101" => temp(7 downto 0) <= local(5 downto 0) & local(7 downto 6);
        when "110" => temp(7 downto 0) <= local(6 downto 0) & local(7 downto 7);
        when others => temp <= local;
      end case;
    end if;
  end process temp_renew;
end IMP;