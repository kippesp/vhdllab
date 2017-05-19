library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fp_addsub is
    port (
        a  : in std_logic_vector(31 downto 0);
        b  : in std_logic_vector(31 downto 0);
        op : in std_logic;
        r  : out std_logic_vector(31 downto 0)
        );
end fp_addsub;

architecture behavior of fp_addsub is
    alias sg1 is a(31);              -- sign a
    alias sg2 is b(31);              -- sign b
    alias e1 is  a(30 downto 23);    -- biased exp a
    alias e2 is  b(30 downto 23);    -- biased exp b
    alias f1 is  a(22 downto 0);     -- normalized mantissa a
    alias f2 is  b(22 downto 0);     -- normalized mantissa b

    -- u_abs_sign - calculates unsigned difference + sign bit
    component u_abs_sign
        generic (N: INTEGER := 8);
        port (
            a, b : in std_logic_vector(7 downto 0);
            sm   : out std_logic;
            r    : out std_logic_vector(7 downto 0)
            );
    end component;

    component my_busmux4to1
        generic (N : INTEGER := 8);
        port (a, b, c, d : in std_logic_vector(N-1 downto 0);
              s          : in std_logic_vector(1 downto 0);
              y_r, y_t   : out std_logic_vector(N-1 downto 0));
    end component;

    component mybarrelShifter
        generic ( N    : integer; -- Input bit-width
                  SW   : integer; -- Bit-width of the distance.. usually it is ceil(log2(N))
                  mode : string := "ARITHMETIC"); -- "ARITHMETIC", "LOGICAL" allowed
        port ( idata : in std_logic_vector(N-1 downto 0);
               dist  : in std_logic_vector(SW-1 downto 0);
               dir   : in std_logic; -- dir = 0 --> left, dir = 1 -> right
               odata : out std_logic_vector(N-1 downto 0));
    end component;

    -- sign-magnitude to two's complement
    component sm_to_2c
        port (
            sa : in std_logic;
            a  : in std_logic_vector(23 downto 0);
            r  : out std_logic_vector(24 downto 0));
    end component;

    component my_addsub
        generic ( N : INTEGER := 4);
        port ( addsub   : in std_logic;
               x, y     : in std_logic_vector (N-1 downto 0);
               s        : out std_logic_vector (N-1 downto 0);
               overflow : out std_logic;
               cout     : out std_logic);
    end component;

    component my_uabs_diff
        generic ( N : INTEGER := 4);
        port (A: in std_logic_vector (N-1 downto 0);
              B: in std_logic_vector (N-1 downto 0);
	          R: out std_logic_vector (N-1 downto 0));
    end component;

    component myLZD is
        generic ( inputwidth : integer;     -- input bit-width: p + 2
                  outputwidth : integer);   -- output bit-width: log2(p+1)
        port ( input  : in std_logic_vector (inputwidth-1 downto 0);
               sgn    : out std_logic;
               output : out std_logic_vector (outputwidth-1 downto 0));
    end component;

    signal e_diff : std_logic_vector(7 downto 0);
    signal sm : std_logic;

    signal ep : std_logic_vector(7 downto 0);     -- larger exponent

    signal f_x : std_logic_vector(22 downto 0);   -- smaller mantissa
    signal f_y : std_logic_vector(22 downto 0);   -- larger mantissa

    signal s_x : std_logic_vector(23 downto 0);   -- 1 + smaller mantissa
    signal s_y : std_logic_vector(23 downto 0);   -- 1 + larger mantissa
    signal aligned_s_x : std_logic_vector(23 downto 0);   -- smaller mantissa aligned to s_y

    signal t1 : std_logic_vector(23 downto 0); -- s_y if e1 is larger else s_x
    signal t2 : std_logic_vector(23 downto 0); -- s_x if e1 is larger else s_y

    signal t1_2c : std_logic_vector(24 downto 0); -- t1 in 2C form
    signal t2_2c : std_logic_vector(24 downto 0); -- t2 in 2C form

    signal t1_op_t2_2c : std_logic_vector(25 downto 0); -- t1 +/- t2 in 2C form

    signal sg : std_logic;  -- sign bit of t1_op_t2_2c

    signal t1_op_t2_sm : std_logic_vector(25 downto 0); -- t1 +/- t2 in 2C form

    -- lzd operation
    signal dir : std_logic;
    signal ndir : std_logic;
    signal shift : std_logic_vector(7 downto 0); -- number of zeros from LZD operation

    signal s: std_logic_vector(24 downto 0); -- shifted mantissa: 01.mmmmmmm

    signal f: std_logic_vector(22 downto 0); -- shifted mantissa: 01.mmmmmmm

    signal e: std_logic_vector(7 downto 0); -- exponent result

    begin
        u_abs_sign_lbl : u_abs_sign
            generic map (N => 8)
            port map (
                a => e1,
                b => e2,
                sm => sm,
                r => e_diff
                );

        e_max_mux_lbl : my_busmux4to1
            generic map (N => 8)
            port map (
                a => e1,
                b => e2,
                c => "00000000",
                d => "00000000",
                s(1) => '0',
                s(0) => sm,
                y_r => ep);

        f_min_mux_lbl : my_busmux4to1
            generic map (N => 23)
            port map (
                a => f2,
                b => f1,
                c => "00000000000000000000000",
                d => "00000000000000000000000",
                s(1) => '0',
                s(0) => sm,
                y_r => f_x);

        f_max_mux_lbl : my_busmux4to1
            generic map (N => 23)
            port map (
                a => f1,
                b => f2,
                c => "00000000000000000000000",
                d => "00000000000000000000000",
                s(1) => '0',
                s(0) => sm,
                y_r => f_y);

        -- Append implicit 1 to mantissa
        s_x <= '1' & f_x;
        s_y <= '1' & f_y;

        s_x_alignment_shifter : mybarrelShifter
            generic map (
                N => 24,
                SW => 8,
                mode => "LOGICAL")
            port map (
                idata => s_x,
                dist => e_diff,         -- shift amount
                dir => '1',             -- dir = right
                odata => aligned_s_x);

        s_max_mux_lbl : my_busmux4to1
            generic map (N => 24)
            port map (
                a => s_y,
                b => s_x,
                c => "000000000000000000000000",
                d => "000000000000000000000000",
                s(1) => '0',
                s(0) => sm,
                y_r => t1);

        s_min_mux_lbl : my_busmux4to1
            generic map (N => 24)
            port map (
                a => s_x,
                b => s_y,
                c => "000000000000000000000000",
                d => "000000000000000000000000",
                s(1) => '0',
                s(0) => sm,
                y_r => t2);

        t_1_sm_to_2c : sm_to_2c
            port map (
                sa => sg1,
                a  => t1,
                r  => t1_2c);

        t_2_sm_to_2c : sm_to_2c
            port map (
                sa => sg2,
                a  => t2,
                r  => t2_2c);

        -- add/subtract operation on the 2C mantissa
        mantissa_adder : my_addsub
            generic map (N => 26)
            port map (
                   addsub => op,
                   x => t1_2c(24) & t1_2c,
                   y => t2_2c(24) & t2_2c,
                   s => t1_op_t2_2c);

        sg <= t1_op_t2_2c(25); -- sign bit

        -- convert mantissa_adder 26-bit operation from 2C to 25-bit magnitude
        u_abs_lbl : my_uabs_diff
            generic map (N => 26)
            port map (
                A => t1_op_t2_2c,
                B => "00000000000000000000000000",
                r => t1_op_t2_sm);

        lzd : myLZD
            generic map (
                inputWidth => 26,
                outputWidth => 8)
            port map (
                input => t1_op_t2_sm,
                sgn => dir,
                output => shift);

        magnitude_shifter : mybarrelShifter
            generic map (
                N => 25,
                SW => 8,
                mode => "LOGICAL")
            port map (
                idata => t1_op_t2_sm(24 downto 0),
                dist => shift,
                dir => dir,
                odata => s);

        f <= s(22 downto 0);

        ndir <= not dir;

        -- exponent adder/subtractor
        exponent_adder : my_addsub
            generic map (N => 8)
            port map (
                   addsub => ndir,
                   x => ep,
                   y => shift,
                   s => e);

    -- combine for final answer
    r <= sg & e & f;

    end;
