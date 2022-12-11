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
end:        STB 7 2 71              # write adr 76 <= 7         24710047        a0470047        60
                                                                                                64
                                                                                                68
                                                                                                72
                                                                                                ...

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
