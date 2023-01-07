# mipstest.asm
# 9/16/03 David Harris David_Harris@hmc.edu
#
# Test MIPS instructions. Assumes little-endian memory was
# initialized as:
# word 16: 3
# word 17: 5
# word 18: 12

main:       #Assembly Code          effect                      Machine Code    Data memory     Bytenum
            LDB 2 0 68              # initialize $2 = 5         20200044        80020044        0
            LDB 7 0 64              # initialize $7 = 3         20700040        80070040        4
            LDB 3 7 69              # initialize $3 = 12        20338045        80e30045        8
            OR 4 7 2                # $4 <= 3 or 5 = 7          06438800        00e22025        12
            AND 5 3 4               # $5 <= 12 and 7 = 4        04519000        00642824        16
            ADD 5 5 4               # $5 <= 4 + 7 = 11          00529000        00a42820        20
            BEQ 5 7 8   (end)       # shouldn’t be taken        60538008        10a70008        24
            SLT 6 3 4               # $6 <= 12 < 7 = 0          08619000        0064302a        28
            BEQ 6 0 1   (around)    # should be taken           60600001        10c00001        32
            LDB 5 0 0               # shouldn’t happen          20500000        80050000        36
around:     SLT 6 7 2               # $6 <= 3 < 5 = 1           08638800        00e2302a        40
            ADD 7 6 5               # $7 <= 1 + 11 = 12         00731400        00c53820        44
            SUB 7 7 2               # $7 <= 12 - 5 = 7          02738800        00e23822        48
            JMP 15                  # should be taken           6200000f        0800000f        52
            LDB 7 0 0               # shouldn’t happen          20700000        80070000        56
end:        STB 7 2 71              # write adr 76 <= $7        24710047        a0470047        60
            STW 7 0 0               # mem(0) <= $7 word-wise    26700000                        64
            STB 7 0 1               # mem(1) <= $7 byte-wise    24700001                        68
            LDB 1 0 1               # $1 <= mem(1) byte-wise    20100001                        72
            LDW 1 0 0               # $1 <= mem(0) word-wise    22100000                        ...

#################################################################################
#################################################################################

[BEQ instructions]

Note to self: "end:" is 8 instructions away from next_instr("BEQ 5 7 8"). As 
such, immediate value of "BEQ 5 7 8" is 8 because of PC_plus4+imm shenaningans:

        PC_num(next_instr("BEQ 5 7 8")) + 8     =>
        PC_num("BEQ 5 7 8") + 4 + 8

#################################################################################

[JUMP instructions]

Jump instructions are absolute in nature. One can get away with counting the 
number of instructions from the top (starting at 0, obviously).

#################################################################################
#################################################################################
#################################################################################

memfile.dat
80020044
80070040
80e30045
00e22025
00642824
00a42820
10a70008
0064302a
10c00001
80050000
00e2302a
00c53820
00e23822
0800000f
80070000
a0470047
00000003
00000005
0000000c



# fib.asm
# Register usage: $3: n $4: f1 $5: f2
# return value written to address 255
fib:    addi $3, $0, 8      # initialize n=8
        addi $4, $0, 1      # initialize f1 = 1
        addi $5, $0, -1     # initialize f2 = -1
loop:   beq $3, $0, end     # Done with loop if n = 0
        add $4, $4, $5      # f1 = f1 + f2
        sub $5, $4, $5      # f2 = f1 - f2
        addi $3, $3, -1     # n = n - 1
        j loop              # repeat until done
end:    sb $4, 255($0)      # store result in address 255

    ##############################
    # translation to monkey format
    ##############################
    fib:    ADDI 3 0 8      # initialize n=8
            ADDI 4 0 1      # initialize f1 = 1
            ADDI 5 0 -1     # initialize f2 = -1
    loop:   BEQ 3 0 4       # Done with loop if n = 0
            ADD 4 4 5       # f1 = f1 + f2
            SUB 5 4 5       # f2 = f1 - f2
            ADDI 3 3 -1     # n = n - 1
            JMP 3           # repeat until done
    end:    STB 4 0 255     # store result in address 255

    #############
    # actual code
    #############
    int fib(void)
    {
        int n = 8;              /* compute nth Fibonacci number */
        int f1 = 1, f2 = -1;    /* last two Fibonacci numbers */

        while (n != 0) {        /* count down to n = 0 */
            f1 = f1 + f2;
            f2 = f1 - f2;
            n = n - 1;
        }
        return f1;
    }
