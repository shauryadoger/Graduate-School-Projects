----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:00:59 12/07/2023 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( Opcode : in  STD_LOGIC_VECTOR (1 downto 0); -- Two bits mean maximum of four possible operations within ALU
           Rs : in  STD_LOGIC_VECTOR (7 downto 0); -- These registers can only contain values with maximum of eight bits (8-bit register)
           Rt : in  STD_LOGIC_VECTOR (7 downto 0); -- These registers can only contain values with maximum of eight bits (8-bit register)
           Rd : out  STD_LOGIC_VECTOR (7 downto 0) -- These registers can only contain values with maximum of eight bits (8-bit register)
			  ); 
end ALU;

architecture Behavioral of ALU is
begin
	process(Opcode, Rs, Rt)
	begin
		case Opcode is
			when "00" =>
				Rd <= Rs and Rt; -- and operation per 00 opcode
			when "01" =>
				Rd <= Rs or Rt; -- or operation per 01 opcode
			when "10" =>
				Rd <= Rs + Rt; -- add operation per 10 opcode
			when "11" =>
				Rd <= Rs - Rt; -- minus operation per 11 opcode
			when others =>
				Rd <= "00000000";
		end case;
	end process;
end Behavioral;

