----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:28:37 12/08/2023 
-- Design Name: 
-- Module Name:    Register_File - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Register_File is
	Port( RF_clock : in STD_LOGIC; -- different clock cycles
			RF_rs : in STD_LOGIC_VECTOR (1 downto 0); -- Rs register
			RF_rt : in STD_LOGIC_VECTOR (1 downto 0); -- Rt register
			RF_rd : in STD_LOGIC_VECTOR (1 downto 0); -- Destination register
			RF_rs_content : out STD_LOGIC_VECTOR (7 downto 0); -- outputs the content of rs register
			RF_rt_content : out STD_LOGIC_VECTOR (7 downto 0); -- outputs the content of rt register
			RF_write_element : in STD_LOGIC_VECTOR (7 downto 0) -- data that gets written as input gets obtained from ALU operation's result
	);
end Register_File;

architecture Behavioral of Register_File is

	type Register_Slots_4x8 is array(0 to 3) of STD_LOGIC_VECTOR(7 downto 0); -- This basically intializes the 4 different slots which contain many values of eight total bits
	signal temporary_registers : Register_Slots_4x8 := ("01001101", -- (r1)
															"00101101", -- (r2)
															"01101101", -- (r3)
															"00101001" -- (r4)
															); -- temporary array stores 4 different registers that can contain values of 8 bits. (Eight bits per each register slot).
	signal write_cycle : STD_LOGIC := '0';
	
begin
	process(RF_clock)
		begin
		
			if rising_edge(RF_clock) then
				write_cycle <= not write_cycle;
				
				if write_cycle = '0' then
				
					--This will read register rs and decide the one that will be based on RF_rs binary values
					case RF_rs is
						when "00" =>
							RF_rs_content <= temporary_registers(0); -- rs content will be the first register in the slot.
						when "01" =>
							RF_rs_content <= temporary_registers(1); -- rs content will be the second register in the slot.
						when "10" =>
							RF_rs_content <= temporary_registers(2); -- rs content will be the third register in the slot.
						when "11" =>
							RF_rs_content <= temporary_registers(3); -- rs content will be the fourth register in the slot.
						when others =>
					end case;
					
					--This will read register rt and decide the one that will be based on RF_rt binary values
					case RF_rt is
						when "00" =>
							RF_rt_content <= temporary_registers(0); -- rs content will be the first register in the slot.
						when "01" =>
							RF_rt_content <= temporary_registers(1); -- rs content will be the second register in the slot.
						when "10" =>
							RF_rt_content <= temporary_registers(2); -- rs content will be the third register in the slot.
						when "11" =>
							RF_rt_content <= temporary_registers(3); -- rs content will be the fourth register in the slot.
						when others =>
					end case;
					
				else
				
					--write the value to rd
					case RF_rd is
						when "00" =>
							temporary_registers(0) <= RF_write_element;
						when "01" =>
							temporary_registers(1) <= RF_write_element;
						when "10" =>
							temporary_registers(2) <= RF_write_element;
						when "11" =>
							temporary_registers(3) <= RF_write_element;
						when others =>
					end case;

				end if;
			end if;
	end process;

end Behavioral;

