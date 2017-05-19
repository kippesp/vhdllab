library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity u_abs_sign is
    generic (N: INTEGER := 8);
    port (
        a, b : in std_logic_vector (N-1 downto 0);
        sm   : out std_logic;
        r    : out std_logic_vector (N-1 downto 0)
        );
end u_abs_sign;

architecture behavior of u_abs_sign is
    component my_uabs_diff
        generic (N : INTEGER := 4);
        port (
            A, B : in std_logic_vector (N - 1 downto 0);
            R    : out std_logic_vector (N - 1 downto 0)
            );
    end component;

    begin
        u_abs_sign : my_uabs_diff
        generic map (N => 8)
        port map (
            A => a,
            B => b,
            R => r);

        process (a, b)
        begin
            if A >= B then
                sm <= '0';
            else
                sm <= '1';
            end if;
        end process;
    end;
