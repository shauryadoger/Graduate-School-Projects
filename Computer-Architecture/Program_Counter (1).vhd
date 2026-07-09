----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:24:59 12/04/2023 
-- Design Name: 
-- Module Name:    Program_Counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter is
    Port ( PC_Clock : in  STD_LOGIC;
           PC_Output : out  STD_LOGIC_VECTOR (2 downto 0);
           PC_Reset : in  STD_LOGIC
			  );
end Program_Counter;

architecture Behavioral of Program_Counter is
	signal count : unsigned(2 downto 0);
		begin
			process(PC_Reset, PC_Clock)
				begin
				if (rising_edge(PC_Clock)) then
					if (PC_Reset = '1') then 
						count <= (others => '0');
					else
						count <= count + 1; --increment the counter
					end if;
				end if;
		end process;
		PC_Output <= STD_LOGIC_VECTOR (count);
end Behavioral;
