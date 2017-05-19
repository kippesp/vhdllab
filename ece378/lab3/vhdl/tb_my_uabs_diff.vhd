---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2013).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
 
ENTITY tb_my_uabs_diff IS
    generic (N: INTEGER:= 4);
END tb_my_uabs_diff;
 
ARCHITECTURE behavior OF tb_my_uabs_diff IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component my_uabs_diff
        port (A,B: in std_logic_vector (N-1 downto 0);
              R: out std_logic_vector (N-1 downto 0));
    end component;
    
   --Inputs
   signal A,B : std_logic_vector(N-1 downto 0) := (others => '0');
   
   -- Output
   signal R : std_logic_vector (N-1 downto 0);

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_uabs_diff PORT MAP ( A => A, B => B, R => R);
   
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		bi: for i in 0 to 2**N -1 loop
               A <= conv_std_logic_vector(i, N);
               bj: for j in 0 to 2**N -1 loop
                        B <= conv_std_logic_vector(j, N); wait for 10 ns;
                   end loop;
            end loop;
       wait;
   end process;

END;
