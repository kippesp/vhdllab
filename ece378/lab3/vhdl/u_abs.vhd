library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity u_abs is
    generic ( N : INTEGER := 4);
    port(
        a : in std_logic_vector (N-1 downto 0);
        r : out std_logic_vector (N-2 downto 0));
end u_abs;

architecture behavioral of u_abs is

    component my_addsub
        generic ( N : INTEGER := 4);
        port ( addsub   : in std_logic;
               x, y     : in std_logic_vector (N-1 downto 0);
               s        : out std_logic_vector (N-1 downto 0);
               overflow : out std_logic;
               cout     : out std_logic);
    end component;

    signal r_2c : std_logic_vector (N-1 downto 0);

begin
    absolute_value : my_addsub
        generic map (N => 26)
        port map (
               addsub => a(25),
               x => "00000000000000000000000000",
               y => a,
               s => r_2c);

    r <= r_2c(N-2 downto 0);
end;
