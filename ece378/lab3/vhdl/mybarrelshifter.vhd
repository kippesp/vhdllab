library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- It computes (idata)*(2^i), i = DIST when dir=0, i=-DIST when dir=1
entity mybarrelShifter is
   generic ( N : integer; -- Input bit-width
             SW : integer; -- Bit-width of the distance.. usually it is ceil(log2(N))
             mode: string:= "ARITHMETIC"); -- "ARITHMETIC", "LOGICAL" allowed
   -- Use Arithmetic Mode when dealing with signed inputs.
   port ( idata : in std_logic_vector(N-1 downto 0);
          dist : in std_logic_vector(SW-1 downto 0);
          dir : in std_logic; -- dir = 0 --> left, dir = 1 -> right
          odata : out std_logic_vector(N-1 downto 0));
end mybarrelShifter;

architecture Behavioral of myBarrelShifter is

begin

  pr: process(iData, dist, dir) begin
        if dir = '0' then
            odata <= std_logic_vector(shift_left(unsigned(idata), to_integer(unsigned(dist))));
        else
            if mode = "LOGICAL" then
                odata <= std_logic_vector(shift_right(unsigned(idata), to_integer(unsigned(dist))));
            elsif mode = "ARITHMETIC" then
                odata <= std_logic_vector(shift_right(signed(idata), to_integer(unsigned(dist))));
            else
                odata <= (others => '0');
            end if;
        end if;
  end process;

end Behavioral;
