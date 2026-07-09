----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:23:33 12/07/2023 
-- Design Name: 
-- Module Name:    processor - Behavioral 
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

entity processor is
    Port ( clock : in  STD_LOGIC;
			  reset: in STD_LOGIC;
           rd_out : out  STD_LOGIC_VECTOR (7 downto 0));
end processor;

architecture Behavioral of processor is

	signal PC_output_addr : STD_LOGIC_VECTOR (2 downto 0); --This line basically takes memory address of an instruction for every clock cycle
	
	signal instruction : STD_LOGIC_VECTOR (7 downto 0); --This line takes an instruction that is eight total bits
	
	signal alu_OP : STD_LOGIC_VECTOR (1 downto 0); -- represents opcode for one of four possible operations
	signal alu_RS : STD_LOGIC_VECTOR (1 downto 0); -- represents one of four registers as RS
	signal alu_RT : STD_LOGIC_VECTOR (1 downto 0); -- represents one of four registers as RT
	signal alu_reg_DEST : STD_LOGIC_VECTOR (1 downto 0); -- represents one of four registers as RD (destination)
	
	--signal rf_clock : STD_LOGIC;
	signal rf_rs : STD_LOGIC_VECTOR (1 downto 0);
	signal rf_rt : STD_LOGIC_VECTOR (1 downto 0);
	signal rf_rd : STD_LOGIC_VECTOR (1 downto 0);
	signal rf_write_element : STD_LOGIC_VECTOR (7 downto 0); -- This element should probably be the result of rd register via ALU operations
	signal rf_rs_content : STD_LOGIC_VECTOR (7 downto 0);
	signal rf_rt_content : STD_LOGIC_VECTOR (7 downto 0);

	--signal rd : STD_LOGIC_VECTOR (7 downto 0);
	--signal rs : STD_LOGIC_VECTOR (7 downto 0);
	--signal rt : STD_LOGIC_VECTOR (7 downto 0);
	signal opcode : STD_LOGIC_VECTOR (1 downto 0);
	
begin

	program_counter: entity work.ProgramCounter
	PORT MAP(
		PC_Clock => clock,
		PC_Reset => reset,
		PC_Output => PC_output_addr
	);
	
	instruction_memory: entity work.InstructionMemory
	PORT MAP(
		Instruction_Address => PC_output_addr,
		--IM_Clock => clock,
		Instruction => instruction
	);
	
	control_unit: entity work.CU
	PORT MAP(
		Instruction_CU => instruction,
		ALU_op => alu_OP,
		ALU_rs => alu_RS, -- This sends output as the address of rs register
		ALU_rt => alu_RT, -- This sends output as the address of rt register
		Reg_dest => alu_reg_DEST -- This output is basically the same thing as rd-register address
	);
	
	register_file: entity work.Register_File
	Port MAP(
		RF_clock => clock, -- regsiter file takes in clock signals from the processor's clock input
		RF_rs => alu_RS, -- collects rs register's address from CU
		RF_rt => alu_RT, -- collects rt register's address from CU
		RF_rd => alu_reg_DEST, -- collects rd (destination) register's address from CU
		RF_rs_content => rf_rs_content, -- sends rs register's content to the ALU Rs
		RF_rt_content => rf_rt_content, -- sends rs register's content to the ALU Rt
		RF_write_element => rf_write_element -- the result for the write register gets recived from ALU operation
	);
	
	arithmetic_logic_unit: entity work.ALU
	Port MAP(
		Opcode => alu_OP, -- Opcode signal obtains value from alu_op
		Rs => rf_rs_content, -- recieves rs-register content from the register file
		Rt => rf_rt_content, -- recieves rt-register content from the register file
		Rd => rf_write_element -- This output should get fed in as input to Register File's write element.
		);

	rd_out <= rf_write_element; -- Processor's final output value must also contain write element of the registers
	
end Behavioral;

