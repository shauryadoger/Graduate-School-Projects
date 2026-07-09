----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:42:30 12/07/2023 
-- Design Name: 
-- Module Name:    CU - Behavioral 
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

entity CU is
    Port ( Instruction_CU : in  STD_LOGIC_VECTOR (7 downto 0); -- This takes 8-bit instruction input from InstructionMemory
           ALU_op : out  STD_LOGIC_VECTOR (1 downto 0);
           ALU_rs : out  STD_LOGIC_VECTOR (1 downto 0);
			  ALU_rt : out  STD_LOGIC_VECTOR (1 downto 0);
           Reg_dest : out  STD_LOGIC_VECTOR (1 downto 0)
			  );
end CU;

architecture Behavioral of CU is

begin
		ALU_op <= Instruction_CU(7 downto 6); -- Left two bits of instruction that decides the operation code
		ALU_rs <= Instruction_CU(5 downto 4); -- 3rd and 4th instruction bits from left to represent register_s address
		ALU_rt <= Instruction_CU(3 downto 2); -- 3rd and 4th instruction bits from right to represent register_t address
		Reg_dest <= Instruction_CU(1 downto 0); -- Right two bits of instruction that represent destination_register address
end Behavioral;

