library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity HI_RAMB1 is  
        generic (                                                      
        data_width: integer:=32;                                       
        address_width: integer:=32;
	depth: integer := 512
        );                                                             
        port (                                                         
                dob: out std_logic_vector(data_width-1 downto 0);      
                doc: out std_logic_vector(data_width-1 downto 0);      
                addra: in std_logic_vector(address_width-1 downto 0);  
                addrb: in std_logic_vector(address_width-1 downto 0);  
                addrc: in std_logic_vector(address_width-1 downto 0);  
                clka: in std_logic;                                   
                clkb: in std_logic;                                   
                dia: in std_logic_vector(data_width-1 downto 0);       
                dib: in std_logic_vector(data_width-1 downto 0);       
                rsta: in std_logic;                                   
                rstb: in std_logic;                                   
                wea: in std_logic
     );
end entity HI_RAMB1;

architecture IMP of HI_RAMB1 is
		type ram_type is array(depth-1 downto 0) of std_logic_vector(data_width-1 downto 0);
		shared variable RAMB: ram_type;
		shared variable RAMC: ram_type;
begin
	  process (clka)
	  begin
	    if ( clka'event and clka = '1' ) then
	      if ( wea = '1' ) then
		RAMB(conv_integer(addra)) := dia;
		RAMC(conv_integer(addra)) := dia;	      end if;
	    end if;
	  end process;

	  process (clkb)
	  begin
	    if ( clkb'event and clkb = '1' ) then
	      dob <= RAMB(conv_integer(addrb));
	      doc <= RAMC(conv_integer(addrc));
	    end if;
	  end process;

end IMP;
 