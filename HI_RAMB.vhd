library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library proc_common_v1_00_b;
--use proc_common_v1_00_b.proc_common_pkg.all;

entity HI_RAMB is
        generic (
        data_width: integer:=32;
        address_width: integer:=32;
	depth: integer := 512
        );
        port (                                                         
                doa: out std_logic_vector(data_width-1 downto 0);      
                dob: out std_logic_vector(data_width-1 downto 0);      
                addra: in std_logic_vector(address_width-1 downto 0);  
                addrb: in std_logic_vector(address_width-1 downto 0);  
                clka: in std_logic;                                   
                clkb: in std_logic;                                   
                dia: in std_logic_vector(data_width-1 downto 0);       
                dib: in std_logic_vector(data_width-1 downto 0);       
                rsta: in std_logic;                                   
                rstb: in std_logic;                                   
                wea: in std_logic;                                    
                web: in std_logic                                     
     );
end entity HI_RAMB;

architecture IMP of HI_RAMB is
		type ram_type is array(depth-1 downto 0) of std_logic_vector(data_width-1 downto 0);
		shared variable RAM: ram_type;
begin
	  process (clka)
	  begin
	    if ( clka'event and clka = '1' ) then
	      if ( wea = '1' ) then
		RAM(conv_integer(addra)) := dia;
	      end if;
	      doa <= RAM(conv_integer(addra));
	    end if;
	  end process;

	  process (clkb)
	  begin
	    if ( clkb'event and clkb = '1' ) then
	      if ( web = '1' ) then
		RAM(conv_integer(addrb)) := dib;
	      end if;
	      dob <= RAM(conv_integer(addrb));
	    end if;
	  end process;

end IMP;
 