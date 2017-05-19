---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all; -- all operations (comparisons, +, -) treat operands as unsigned

-- Absolute value: using behavioral statements
-- Input: N-bit unsigned numbers: [0, 2^N -1]
-- Output: N-bit unsigned number : [0, 2^N-1]
entity my_uabs_diff is
	generic (N: INTEGER:= 4);
	port (A,B: in std_logic_vector (N-1 downto 0);
	      R: out std_logic_vector (N-1 downto 0));
end my_uabs_diff;

architecture Behavioral of my_uabs_diff is

begin
 -- A - B belongs to [-2^N +1,2^N -1]
 -- |A-B| belongs to [0, 2^N -1] --> N bits as unsigned
 
 -- Note that this approach would NOT work for signed numbers as we need
 -- to first sign-extend to get R with 'N+1' bits and then R might be negative
	process (A,B)
	begin
		if A >= B then -- A-B >=0
		   R <= A - B;
		else
		   R <= B - A;
		end if;
	end process;
	
end Behavioral;