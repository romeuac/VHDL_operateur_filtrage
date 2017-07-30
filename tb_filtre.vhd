--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:50:11 10/31/2013
-- Design Name:   
-- Module Name:   /auto/h/hgilbert/VHDL/ise/Please/tb_filtre.vhd
-- Project Name:  Please
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: test_add
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.Numeric_Std.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_signed.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_filtre IS
END tb_filtre;
 
ARCHITECTURE behavior OF tb_filtre IS 
 
	-- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT test_add
	PORT(
		FSL_Clk : IN  std_logic;
		FSL_Rst : IN  std_logic;
		FSL_S_Clk : IN  std_logic;
		FSL_S_Read : OUT  std_logic;
		FSL_S_Data : IN  std_logic_vector(0 to 7);
		FSL_S_Control : IN  std_logic;
		FSL_S_Exists : IN  std_logic;
		FSL_M_Clk : IN  std_logic;
		FSL_M_Write : OUT  std_logic;
		FSL_M_Data : OUT  std_logic_vector(0 to 7);
		FSL_M_Control : OUT  std_logic;
		FSL_M_Full : IN  std_logic
	);
	END COMPONENT;
    

	--Inputs
	signal FSL_Clk : std_logic := '0';
	signal FSL_Rst : std_logic := '0';
	signal FSL_S_Clk : std_logic := '0';
	signal FSL_S_Data : std_logic_vector(0 to 31) := (others => '0');
	signal FSL_S_Control : std_logic := '0';
	signal FSL_S_Exists : std_logic := '0';
	signal FSL_M_Clk : std_logic := '0';
	signal FSL_M_Full : std_logic := '0';

	--Outputs
	signal FSL_S_Read : std_logic;
	signal FSL_M_Write : std_logic;
	signal FSL_M_Data : std_logic_vector(0 to 31);
	signal FSL_M_Control : std_logic;

	-- Clock period definitions
	constant FSL_Clk_period : time := 10 ns;
	constant FSL_S_Clk_period : time := 10 ns;
	constant FSL_M_Clk_period : time := 10 ns;

	--Other constants
	constant MatrixSize: integer := 4; 

	type memory is array(0 to (MatrixSize)) of integer;
	--The data input
	signal mem : memory;
	--The data output 
	signal memOut : memory;
	
	--PC is the control to the memory vector 
	signal pc: integer range 0 to 65535;
	signal pcOut: integer range 0 to 65535;

 
 
	BEGIN
	 
		-- Instantiate the Unit Under Test (UUT)
		uut: test_add PORT MAP (
			FSL_Clk => FSL_Clk,
			FSL_Rst => FSL_Rst,
			FSL_S_Clk => FSL_S_Clk,
			FSL_S_Read => FSL_S_Read,
			FSL_S_Data => FSL_S_Data,
			FSL_S_Control => FSL_S_Control,
			FSL_S_Exists => FSL_S_Exists,
			FSL_M_Clk => FSL_M_Clk,
			FSL_M_Write => FSL_M_Write,
			FSL_M_Data => FSL_M_Data,
			FSL_M_Control => FSL_M_Control,
			FSL_M_Full => FSL_M_Full
		);
	 

		mem(00) <= MatrixSize;
		mem(01) <= 1;	
		mem(02) <= 2;		
		mem(03) <= 3;	
		mem(04) <= 4;
		mem(05) <= 5;
		mem(06) <= 6;
		mem(07) <= 7;	
		mem(08) <= 8;		
		mem(09) <= 9;	
		mem(10) <= 10;
		mem(11) <= 11;
		mem(12) <= 12;
		mem(13) <= 13;	
		mem(14) <= 14;		
		mem(15) <= 15;	
		mem(16) <= 16;



		-- Clock process definitions
		FSL_Clk_process :process
		begin
			--5ns
			FSL_Clk <= '0';
			wait for FSL_Clk_period/2;
			--5ns
			FSL_Clk <= '1';
			wait for FSL_Clk_period/2;
		end process;

		FSL_S_Clk_process :process
		begin
			--5ns
			FSL_S_Clk <= '0';
			wait for FSL_S_Clk_period/2;
			--5ns
			FSL_S_Clk <= '1';
			wait for FSL_S_Clk_period/2;
		end process;

		FSL_M_Clk_process :process
		begin
			--5ns
			FSL_M_Clk <= '0';
			wait for FSL_M_Clk_period/2;
			--5ns	
			FSL_M_Clk <= '1';
			wait for FSL_M_Clk_period/2;
		end process;
	 
	 
	 


		--pc process
		pc_p : process
		begin
			--wait for 100 ns;
			wait for FSL_Clk_period*0.5;
			
			--Rising clock and reset
			if rising_edge(FSL_Clk) and FSL_Rst='1' then
				--Initialization of the pc values
				pc 	<= 0;
				pcOut <= 0;
				
			--If the clock is rising but the reset is not activated
			elsif (FSL_Clk = '1') then 
				--while(FSL_M_Write /= '0') loop
					--wait for FSL_Clk_period*0.5;
				--end loop;
				
				
				--It verifies if it is the end
				--if(pc < mem'length) then
					
				--To guarantee that the data input can not exist and
				--the writing process is done
				FSL_S_Exists <= '1' ;
				--To handle issues related to reading
				if (FSL_S_Read = '1' and (pc < mem'length)) then
					FSL_S_Data <= std_logic_vector(to_unsigned(mem(pc),32));
					--The input data exist
					FSL_S_Exists <= '1' ;
					--Incrementation of pc
					pc <= pc + 1;
					--wait for 
				end if;
				
				--To handle issues related to writing
				if (FSL_M_Write = '1' and (pcOut < memOut'length)) then
					--To NOT ALLOW the execution of another writing process in this moment
					FSL_S_Exists <= '1' ;
					
					memOut(pcOut) <= conv_integer(FSL_M_Data);
					--Incrementation of pcOut
					pcOut <= pcOut + 1;
					
					--To ALLOW the execution of another writing process in this moment
					FSL_S_Exists <= '0' ;
				end if;
									
					--while( FSL_M_Write /= '1') loop
						--wait for FSL_Clk_period*0.5;
					--end loop;
					--FSL_S_Exists <= '0' ;
				--end if;
			end if;	
		end process;

	
	END;





