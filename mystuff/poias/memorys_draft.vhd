architecture logic of memory is

    -- create new array data type named mem which has 64 8-bit-wide address
    -- locations of 
    type mem is array (0 to 63) of std_logic_vector(7 downto 0);

    -- create 2 64x8-bit arrays to use in design
    signal mem_64x8_a : mem;
    signal mem_64x8_b : mem;

    begin
        ...
        mem_64x8_a(12) <= x"AF";
        mem_64x8_b(50) <= "11110000";
        ...
    end architecture logic;