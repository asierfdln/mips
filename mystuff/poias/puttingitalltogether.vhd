entity cmpl_sig is
    port (
        a   : IN  BIT;
        b   : IN  BIT;
        sel : IN  BIT;
        x   : OUT BIT;
        y   : OUT BIT;
        z   : OUT BIT
    );
    end entity cmpl_sig;



architecture cmpl_sig_logic of cmpl_sig is
    begin
        -- simple signal assignment
        x <= (a and not sel) or (b and sel);
        -- conditional signal assignment
        y <= a when sel='0' else b;
        -- selected signal assignment
        with sel select
            z <= a when '0',
                 b when '1',
                '0' when others;
    end architecture cmpl_sig_logic;



configuration cmpl_sig_conf of cmpl_sig is
    for logic
    end for;
    end configuration cmpl_sig_conf;