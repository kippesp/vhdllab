library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- The input is assumed to be in the format [p+2 p] unsigned
-- If input = 1X.XXXX..XXX --> output = -1
-- If input = 01.XXXX..XXX --> output = +0
-- If input = 00.1XXX..XXX --> output = +1
-- If input = 00.01XX..XXX --> output = +2
-- ..............
-- If input = 00.0000..001 --> output = +p

entity myLZD is
    Generic ( inputWidth : integer; -- Input bit-width: p + 2
              outputWidth : integer ); -- Output bit-width: log2(p+1)
    Port ( input : in STD_LOGIC_VECTOR (inputWidth-1 downto 0);
           sgn: out std_logic;
           output : out STD_LOGIC_VECTOR (outputWidth-1 downto 0));
end myLZD;

architecture Behavioral of myLZD is

begin

pa: process(input)
    begin
         output <= (others => '0');
         sgn <= '0';
         for i in inputWidth-1 downto 0 loop
             if input(i) = '1' then
                 if inputWidth-2-i >= 0 then
                    output <= std_logic_vector(to_unsigned(inputWidth-2-i, outputWidth));
                    sgn <= '0'; -- Here, we have to shift to the left.
                 else
                    output <= std_logic_vector(to_unsigned( i+2-inputWidth, outputWidth));
                    sgn <= '1'; -- Here, we have to shift to the right.
                 end if;
                 exit;
             end if;
         end loop;
  end process;

end Behavioral;
