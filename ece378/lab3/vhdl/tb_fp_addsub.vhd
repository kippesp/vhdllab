library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity fp_addsub_tb is
end;

architecture bench of fp_addsub_tb is

  component fp_addsub
      port (
          a  : in std_logic_vector(31 downto 0);
          b  : in std_logic_vector(31 downto 0);
          op : in std_logic;
          r  : out std_logic_vector(31 downto 0)
          );
  end component;

  signal a: std_logic_vector(31 downto 0);
  signal b: std_logic_vector(31 downto 0);
  signal op: std_logic;
  signal r: std_logic_vector(31 downto 0) ;

begin

  uut: fp_addsub port map ( a  => a,
                            b  => b,
                            op => op,
                            r  => r );

  stimulus: process
  begin
  
    a <= "00000000000000000000000000000000";
    b <= "00000000000000000000000000000000";
    op <= '0';
    wait for 10ns;


    a <= "01100000101000010000000000000000";
    b <= "11000010111110010111000000000000";
    op <= '0';
    wait for 10ns;

    wait;
  end process;


end;
