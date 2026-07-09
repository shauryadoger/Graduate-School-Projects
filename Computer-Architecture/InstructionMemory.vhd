----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:55:11 12/06/2023 
-- Design Name: 
-- Module Name:    InstructionMemory - Behavioral 
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

entity InstructionMemory is
    Port ( Instruction_Address : in  STD_LOGIC_VECTOR (2 downto 0); -- This line basically tells system that there will be eight seperate memory slots
			  --IM_Clock : in  STD_LOGIC;
           Instruction : out  STD_LOGIC_VECTOR (7 downto 0) -- This one tells that the instruction will always contain eight total bits
			  );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
	
	type Instruction_Memory_Slots_8x8 is array(0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	signal temporary_memory : Instruction_Memory_Slots_8x8 := ( "01001101", --Eight bits per each line
																		  "00001101",
																		  "10001101",
																		  "11001101",
																		  "01001101",
																		  "00001101",
																		  "10001101",
																		  "11001101"
																		); --
	begin
		process(Instruction_Address)
			begin
				case Instruction_Address is
					when "000" =>
						Instruction <= temporary_memory(0);
					when "001" =>
						Instruction <= temporary_memory(1);
					when "010" =>
						Instruction <= temporary_memory(2);
					when "011" =>
						Instruction <= temporary_memory(3);
					when "100" =>
						Instruction <= temporary_memory(4);
					when "101" =>
						Instruction <= temporary_memory(5);
					when "110" =>
						Instruction <= temporary_memory(6);
					when "111" =>
						Instruction <= temporary_memory(7);
					when others =>
			end case;
		end process; -- This process over here decides the instruction that gets sent over to control unit of the next CPU component
		
end Behavioral;

