library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity dmaput32 is
  port
  (
    clk:    in std_logic;
    rst:    in std_logic;
-- dma engine ports:
  local_addr_i:    in std_logic_vector(31 downto 0);
  memory_addr_o:   out std_logic_vector(31 downto 0);
  local_data_i:    in std_logic_vector(31 downto 0);
  remote_addr_i:   in std_logic_vector(31 downto 0);
  length_i:   in std_logic_vector(31 downto 0);
  start_i:    in std_logic;
  done_o:     out std_logic;
-- internal request interface ports:
  reqaddr_o:    out std_logic_vector(31 downto 0);
  reqlength_o:  out std_logic_vector(9 downto 0);
  reqtag_o:     out std_logic_vector(4 downto 0);
  request_o:    out std_logic;
  grant_i:      in std_logic;
-- write request data transfer ports:
  reqdata_o:  out std_logic_vector(31 downto 0);
  reqwe_o:    out std_logic;
  reqbusy_i:  in std_logic
  );
end entity dmaput32;

architecture IMP of dmaput32 is
 signal memory_addr: std_logic_vector(31 downto 0);
 signal reqaddr_int: std_logic_vector(31 downto 0);
 signal count: std_logic_vector(4 downto 0);
 signal busy: std_logic;
 signal length_int: std_logic_vector(31 downto 0);
 signal request_int: std_logic;
 signal done_int: std_logic;
 
begin
 reqdata_o <= local_data_i;
 request_o <= request_int;
 reqtag_o <= "00000";
 memory_addr_o <= memory_addr;
 reqaddr_o <= reqaddr_int;
 -- INIT: process (clk) is
 -- begin
    -- if (clk'event and clk = '1' and busy = '0' and start_i = '0') then
      -- memory_addr <= local_addr_i;
      -- count <= "00000";
      -- length_int <= length_i;
      -- busy <= '1';
      -- request_int <= '1';
      -- reqwe_o <= '1';
      -- if (length_i < conv_std_logic_vector(32,32)) then
        -- reqlength_o <= length_i(9 downto 0);
      -- else
        -- reqlength_o <= conv_std_logic_vector(32,10);
      -- end if;
    -- end if;
  -- end process INIT;
  
  RUN: process (clk) is
  begin
    if (clk'event and clk = '1') then
		if (rst = '0') then
			if (busy = '0' and start_i = '0') then
			  memory_addr <= local_addr_i;
			  count <= "00000";
			  length_int <= length_i;
			  busy <= '1';
			  request_int <= '1';
			  reqwe_o <= '1';
			  reqaddr_int <= remote_addr_i;
			  if (length_i < conv_std_logic_vector(32,32)) then
				 reqlength_o <= length_i(9 downto 0);
			  else
				 reqlength_o <= conv_std_logic_vector(32,10);
			  end if;
			elsif (busy = '1' and grant_i = '1' and reqbusy_i = '0') then
			  memory_addr <= memory_addr + 1;
			  length_int <= length_int - 1;
			  if (length_int = conv_std_logic_vector(0,32) or count = "11111") then
				 request_int <= '0';
			  end if;
			  if (length_int = conv_std_logic_vector(0,32)) then
				 busy <= '0';
				 done_o <= '1';
			  end if;
			  if (count /= "11111") then
				 count <= count + 1;
			  else
				 count <= "00000";
				 reqaddr_int <= reqaddr_int + "100000";
			  end if;
			elsif (grant_i = '1' and request_int = '0') then
			  request_int <= '1';
			  if (length_i < conv_std_logic_vector(32,32)) then
				 reqlength_o <= length_int(9 downto 0);
			  else
				 reqlength_o <= "0000100000";
			  end if;
			end if;
		 else
	--	 clk'event and clk = '1' and 
			busy <= '0';
			count <= "00000";
			memory_addr <= (others => '0');
			length_int <= (others => '0');
			request_int <= '0';
			done_int <= '0';
		 end if;
	end if;
  end process RUN;
  
  DONE: process (clk) is
  begin
    if (clk'event and clk = '1' and  done_int = '1') then
      done_int <= not done_int;
    end if;
  end process DONE;
  
--  RESET: process (clk) is
--  begin
--	if (clk'event and clk = '1' and rst = '1') then
--		busy <= '0';
--		count <= "00000";
--		memory_addr <= (others => '0');
--		length_int <= (others => '0');
--		request_int <= '0';
--		done_int <= '0';
--	end if;
--  end process RESET; 
end architecture IMP;