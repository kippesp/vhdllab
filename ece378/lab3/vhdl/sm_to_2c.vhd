library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sm_to_2c is
    port (
        sa : in std_logic;
        a  : in std_logic_vector(23 downto 0);
        r  : out std_logic_vector(24 downto 0)
        );
end sm_to_2c;

architecture behavior of sm_to_2c is
    component my_addsub
        generic ( N : INTEGER := 4);
        port ( addsub   : in std_logic;
               x, y     : in std_logic_vector (24 downto 0);
               s        : out std_logic_vector (24 downto 0);
               overflow : out std_logic;
               cout     : out std_logic);
    end component;

    signal a_extended : std_logic_vector(24 downto 0);

begin
    a_extended <= '0' & a;

    addsub : my_addsub
        generic map (N => 25)
        port map (
            addsub => sa,
            x => "0000000000000000000000000",
            y => a_extended,
            s => r);
end;
