------------------------------------------------------------------------------
-- test_add - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          test_add
-- Version:           1.00.a
-- Description:       Example FSL core (VHDL).
-- Date:              Tue Oct 15 10:40:39 2013 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk             : Synchronous clock
-- FSL_Rst           : System reset, should always come from FSL bus
-- FSL_S_Clk       : Slave asynchronous clock
-- FSL_S_Read      : Read signal, requiring next available input to be read
-- FSL_S_Data      : Input data
-- FSL_S_CONTROL   : Control Bit, indicating the input data are control word
-- FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk       : Master asynchronous clock
-- FSL_M_Write     : Write signal, enabling writing to output FSL bus
-- FSL_M_Data      : Output data
-- FSL_M_Control   : Control Bit, indicating the output data are contol word
-- FSL_M_Full      : Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity test_add is
	port 
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		FSL_Clk	: in	std_logic;
		FSL_Rst	: in	std_logic;
		FSL_S_Clk	: in	std_logic;
		FSL_S_Read	: out	std_logic;
		FSL_S_Data	: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk	: in	std_logic;
		FSL_M_Write	: out	std_logic;
		FSL_M_Data	: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full	: in	std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

--attribute SIGIS : string; 
--attribute SIGIS of FSL_Clk : signal is "Clk"; 
--attribute SIGIS of FSL_S_Clk : signal is "Clk"; 
--attribute SIGIS of FSL_M_Clk : signal is "Clk"; 

end test_add;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENTITY test_add
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which
--    acts as an accumulator
-- 3. After all the inputs have been read, write out the
--    content of 'sum' into the output FSL bus NUMBER_OF_OUTPUT_WORDS times
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY test_add to implement your coprocessor

architecture EXAMPLE of test_add is

   -- Total number of input data.
   constant NUMBER_OF_LINES  : natural := 4;

   -- Total number of output data
   constant NUMBER_OF_INPUT_WORDS : natural := 8;

   type STATE_TYPE is (Idle, Setup, Read_Inputs, Write_Outputs);

   signal state        : STATE_TYPE;

   -- Accumulator to hold sum of inputs read at any point in time
   signal R_out          : std_logic_vector(0 to 31);    
   -- R_out est le résultat
    signal R1, R2, R3   : std_logic_vector(0 to 47);  -- R1,R2,R3 sont les
                                                   -- registres qui gardent
                                                     -- en mémoire les lignes.
   --(0 to 7)=(40 to 47)="00000000" pour les problèmes de bords;
   --(8 to 39) reprèsentent les données reçues
   
   signal is_first	   : std_logic;  -- indique si c'est la première ligne
                                         -- de l'image qu'on lit.


   -- Counters to store the number inputs read & outputs written
   signal nr_of_reads  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
   signal nr_of_writes : natural range 0 to NUMBER_OF_LINES - 1;
	
	--Signal reserved for saving the Matrix size
	signal MatSize : integer;
	signal MatSizeSaved : std_logic;

begin
	-- CAUTION:
	-- The sequence in which data are read in and written out should be
	-- consistent with the sequence they are written and read in the
	-- driver's test_add.c file

	FSL_S_Read  <= FSL_S_Exists   when ((state = Read_Inputs) or (state = Setup)) else '0';
	FSL_M_Write <= not FSL_M_Full when state = Write_Outputs else '0';

	FSL_M_Data <= R_out;

	The_SW_accelerator : process (FSL_Clk) is
	--This counter is used to verifie if all the elements of one line were read
	variable pcLine : integer range 0 to 65535;
	--For the writing process
	variable pcWrite : integer range 0 to 65535;
	
	begin  -- process The_SW_accelerator
	
		
	
		if FSL_Clk'event and FSL_Clk = '1' then     -- Rising clock edge
			if FSL_Rst = '1' then               -- Synchronous reset (active high)
  
				-- CAUTION: make sure your reset polarity is consistent with the
				-- system reset polarity
				state        <= Idle;
				nr_of_reads  <= 0;
				nr_of_writes <= 0;
				MatSizeSaved <= '0';
				R_out        <= (others => '0');
		else
		
			case state is
			
				---------------
				-----IDLE------
				---------------
				--In this state the program waits for a beginning
				when Idle =>
				
					if (FSL_S_Exists = '1') then 

						--If it is the beginning of the program the next state is setup
						if (MatSizeSaved = '0') then 
							state <= Setup;						
						--If it is not the biginning it is a infinite loop
						else
							state	<= Idle;
						end if;			
						
					end if;
					--elsif (is_first = '1') then
						--state <= Read_Inputs;
					--end if;
				
				
				
				----------------
				-----SETUP------
				----------------
				--Program initial configurations 
				when Setup =>				
					if (FSL_S_Exists = '1') then 
						--We save the matrix size and we change to '1' the value 
						--of MatSizeSaved
						MatSize 		<= conv_integer(FSL_S_Data);
						MatSizeSaved<= '1';
						
						-- receive data from MicroBlaze
						is_first    <= '1';
						
						--All the vectors and signals are seted to zero
						nr_of_reads  <= 0;
						nr_of_writes <= 0;
						R_out        <= (others => '0');
						R1           <= (others => '0');
						R2           <= (others => '0');
						R3           <= (others => '0');
						
						--The counter is seted to zero
						pcLine := 1;
						pcWrite := 1;
						
						
						--The next step is to reading the other matrix elements 
						state <= Read_Inputs;
						
					end if;
					
					
					
				---------------------
				-----READ INPUTS-----
				---------------------
				--In this state the matrix lines are read
				when Read_Inputs =>
					--If there is a value for be read or if all the lines were read
					if (FSL_S_Exists = '1' or (nr_of_writes = MatSize - 1)) then
						
						--We read another 8 bits of the memory
						if ( (pcLine < MatSize) and (nr_of_writes < (MatSize - 1))) then
							--If the value is the first of this line
							if (pcLine = 1) then
								R1 <= R2;
								R2 <= R3;
							end if;
							
							--We save the 8 bits in the right position and order
							R3( (pcLine*8) to ((pcLine*8) + 7)) <= FSL_S_Data (31 downto 24);
							--The counter is incremented
							pcLine := pcLine + 1;
						
						--The line has been completely read
						else 
							--We are dealing with the first line of the picture
							if (is_first = '1') then
								--We start the reading of the second line
								--We need at least two to execute the correct filtering process
								state <= Read_Inputs;

							--All the lines had been already read
							elsif ( nr_of_writes = NUMBER_OF_LINES - 1 ) then
								R1 <= R2;
								R2 <= R3;
								--We create the last line, full of zeros
								R3 <= (others => '0');
								
								state <= Write_Outputs;
							--A intermediate line has been fully read	
							else 
								--R1 <= R2;
								--R2 <= R3;
								--R3 (8 to 39 ) <= FSL_S_Data;
								
								state <= Write_Outputs;
							end if;
							
							--Definition for the next line reading process
							--It starts in '1' cause the first part of the line is full
							--of zeros to do the filtering process
							pcLine := 1;
								
						end if;
						
					else 
						state <= Read_Inputs;
					end if;

				-----------------------
				-----WRITE OUTPUTS-----
				-----------------------
				--State responsable for the writing of the filtered lines
				when Write_Outputs =>
					--if((is_first /= '1') or (FSL_S_Exists /= '1')) then
					--If FSL_S_Exists = 1, the previous result is still being saved
					if(FSL_S_Exists /= '1') then
						--if (is_first = '1') then 
							--is_first <= '0';
							--state <= Read_Inputs;
							
						--We write another filtered position in the result line	
						if (pcWrite <= MatSize) then
						
							R_out ((pcWrite * 8) to ((pcWrite * 8) + 7)) <= conv_std_logic_vector((conv_integer( R1(((pcWrite - 1) * 8) to (((pcWrite - 1) * 8) + 7)))*(-1) + conv_integer(R1((pcWrite * 8) to ((pcWrite * 8) + 7)))*(-1) + conv_integer(R1(((pcWrite + 1) * 8) to (((pcWrite + 1) * 8) + 7)))*1+ 
																			  conv_integer(R2(((pcWrite - 1) * 8) to (((pcWrite - 1) * 8) + 7)))*(-1) + conv_integer(R2((pcWrite * 8) to ((pcWrite * 8) + 7)))*0 + conv_integer(R2(((pcWrite + 1) * 8) to (((pcWrite + 1) * 8) + 7)))*1 + 
																			  conv_integer(R3(((pcWrite - 1) * 8) to (((pcWrite - 1) * 8) + 7)))*(-1) + conv_integer(R3((pcWrite * 8) to ((pcWrite * 8) + 7)))*1 + conv_integer(R3(((pcWrite + 1) * 8) to (((pcWrite + 1) * 8) + 7)))*1),8);
							pcWrite := pcWrite + 1;
				
						--We wrote all the filtered results in R_out 
						else

							--R_out (0 to 7) <= conv_std_logic_vector((conv_integer(R1(0 to 7))*(-1)+ conv_integer(R1(8 to 15))*(-1) + conv_integer(R1(16 to 23))*1+ 
							--												  conv_integer(R2(0 to 7))*(-1) + conv_integer(R2(8 to 15))*0 + conv_integer(R2(16 to 23))*1 + 
							--												  conv_integer(R3(0 to 7))*(-1) + conv_integer(R3(8 to 15))*1 + conv_integer(R3(16 to 23))*1),8);

							--R_out (8 to 15) <= conv_std_logic_vector((conv_integer(R1(8 to 15))*(-1) + conv_integer(R1(16 to 23))*(-1) + conv_integer(R1(24 to 31))*1 + 
							--													conv_integer(R2(8 to 15))*(-1) + conv_integer(R2(16 to 23))*0 + conv_integer(R2(24 to 31))*1 + 
							--													conv_integer(R3(8 to 15))*(-1) + conv_integer(R3(16 to 23))*1 + conv_integer(R3(24 to 31))*1),8);

							--R_out (16 to 23) <= conv_std_logic_vector((conv_integer(R1(16 to 23))*(-1) + conv_integer(R1(24 to 31))*(-1) + conv_integer(R1(32 to 39))*1 + 
							--													 conv_integer(R2(16 to 23))*(-1) + conv_integer(R2(24 to 31))*0 + conv_integer(R2(32 to 39))*1 + 
							--													 conv_integer(R3(16 to 23))*(-1) + conv_integer(R3(24 to 31))*1 + conv_integer(R3(32 to 39))*1),8);

							--R_out (24 to 31) <= conv_std_logic_vector((conv_integer(R1(24 to 31))*(-1) + conv_integer(R1(32 to 39))*(-1) + conv_integer(R1(40 to 47))*1 + 
							--													 conv_integer(R2(24 to 31))*(-1) + conv_integer(R2(32 to 39))*0 + conv_integer(R2(40 to 47))*1 + 
							--													 conv_integer(R3(24 to 31))*(-1) + conv_integer(R3(32 to 39))*1 + conv_integer(R3(40 to 47))*1),8);
							nr_of_writes <= nr_of_writes + 1;
							
							--The counter is reseted
							pcWrite := 1;
							
							--If all the lines were written
							if(nr_of_writes = (MatSize-1)) then
								--The program is finished
								is_first <= '0';
								state <= Idle;
							else
								state <= Read_Inputs;
							end if;

						end if;
					else
						state <= write_outputs;
					end if;
			end case;
		end if;
	end if;
	
	end process The_SW_accelerator;
	
end architecture EXAMPLE;
