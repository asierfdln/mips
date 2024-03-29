def r_instruction(list_of_arguments):

    # [R-type]    opcode_31-25    dst_24-20       src1_19-15      src2_14-10              zeroes_9-0
    #             0000000         00000           00000           00000                   0000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # r_type = [
    #     "ADD",      # r1 <- r2 + r3
    #     "SUB",      # r1 <- r2 - r3
    #     "AND",      # r1 <- r2 AND r3
    #     "OR",       # r1 <- r2 OR r3
    #     "SLT",      # r1 <- "1" if r2 < r3, otherwise r1 <- "0"
    #     # "MUL",      # r1 <- r2 * r3
    # ]

    opcode_31_25    = '0000000'
    dst_24_20       = '00000'
    src1_19_15      = '00000'
    src2_14_10      = '00000'
    zeroes_9_0      = '0000000000'

    dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
    src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
    src2_14_10      = bin(int(list_of_arguments[3]) % (2 ** len(src2_14_10)))[2:].zfill(len(src2_14_10))

    # print(dst_24_20)
    # print(src1_19_15)
    # print(src2_14_10)
    # exit(0)

    if list_of_arguments[0] == "ADD":
        opcode_31_25 = '0000000'
    elif list_of_arguments[0] == "SUB":
        opcode_31_25 = '0000001'
    elif list_of_arguments[0] == "AND":
        opcode_31_25 = '0000010'
    elif list_of_arguments[0] == "OR":
        opcode_31_25 = '0000011'
    elif list_of_arguments[0] == "SLT":
        opcode_31_25 = '0000100'
    elif list_of_arguments[0] == "MUL":
        opcode_31_25 = '0000101'
    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in r_instruction()')
        exit(1)

    # print(opcode_31_25)
    # exit(0)

    concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{src2_14_10}{zeroes_9_0}'
    if len(concat) != 32:
        print(f'Oops, "{list_of_arguments}" crashed in r_instruction(), failed lengthcheck: {len(concat)} {concat}')
        exit(1)

    hexvalue = hex(int(concat, 2))[2:].zfill(8)
    # print(hexvalue)
    # exit(0)

    return hexvalue, concat


def m_instruction(list_of_arguments):

    # [M-type]    opcode_31-25    dst_24-20       src1_19-15      offset_14-0
    #             0000000         00000           00000           000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # m_type = [
    #     "ADDI",     # r1 <- r2 + imm
    #     "LDB",      # r1 <- mem[r2 + imm]
    #     "LDW",      # r1 <- mem[r2 + imm]
    #     "STB",      # mem[r2 + imm] <- r1                       # s.t. r1 is moved to r3
    #     "STW",      # mem[r2 + imm] <- r1                       # s.t. r1 is moved to r3
    # ]

    opcode_31_25    = '0000000'
    dst_24_20       = '00000'
    src1_19_15      = '00000'
    offset_14_0     = '000000000000000'

    dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
    src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
    offset_14_0     = bin(int(list_of_arguments[3]) % (2 ** len(offset_14_0)))[2:].zfill(len(offset_14_0))

    # print(dst_24_20)
    # print(src1_19_15)
    # print(offset_14_0)
    # exit(0)

    if list_of_arguments[0] == "ADDI":
        opcode_31_25 = '0000111'
    elif list_of_arguments[0] == "LDB":
        opcode_31_25 = '0010000'
    elif list_of_arguments[0] == "LDW":
        opcode_31_25 = '0010001'
    elif list_of_arguments[0] == "STB":
        opcode_31_25 = '0010010'
    elif list_of_arguments[0] == "STW":
        opcode_31_25 = '0010011'
    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in m_instruction()')
        exit(1)

    # print(opcode_31_25)
    # exit(0)

    concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{offset_14_0}'
    if len(concat) != 32:
        print(f'Oops, "{list_of_arguments}" crashed in m_instruction(), failed lengthcheck: {len(concat)} {concat}')
        exit(1)

    hexvalue = hex(int(concat, 2))[2:].zfill(8)
    # print(hexvalue)
    # exit(0)

    return hexvalue, concat


def b_instruction(list_of_arguments):

    # [LIES : start]
    # [B-type]    opcode_31-25    offsethi_24-20  src1_19-15      src2/offsetmid_14-10    offsetlo_9-0
    #             0000000         00000           00000           00000                   0000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000
    # [LIES :   end]

    # [BEQ-type]  opcode_31-25    dst_24-20       src1_19-15      offset_14-0
    #             0000000         00000           00000           000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000
    # [JMP-type]  opcode_31-25    offset_24-0
    #             0000000         0000000000000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # b_type = [
    #     "BEQ",      # if r1 == r2, PC = PC_plus4 + imm          # s.t. r1 is moved to r3
    #     "JMP",      # PC = concat(PC(31 downto 27, imm, "00")   # imm is instr(24 downto 0)
    # ]

    if list_of_arguments[0] == "BEQ":

        opcode_31_25    = '0110000'
        dst_24_20       = '00000'
        src1_19_15      = '00000'
        offset_14_0     = '000000000000000'

        dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
        src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
        offset_14_0     = bin(int(list_of_arguments[3]) % (2 ** len(offset_14_0)))[2:].zfill(len(offset_14_0))

        # print(dst_24_20)
        # print(src1_19_15)
        # print(offset_14_0)
        # exit(0)

        concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{offset_14_0}'
        if len(concat) != 32:
            print(f'Oops, "{list_of_arguments}" crashed in BEQ, in b_instruction(), failed lengthcheck: {len(concat)} {concat}')
            exit(1)

        hexvalue = hex(int(concat, 2))[2:].zfill(8)
        # print(hexvalue)
        # exit(0)

        return hexvalue, concat

    elif list_of_arguments[0] == "JMP":

        opcode_31_25    = '0110001'
        offset_24_0     = '0000000000000000000000000'

        offset_24_0     = bin(int(list_of_arguments[1]) % (2 ** len(offset_24_0)))[2:].zfill(len(offset_24_0))

        # print(offset_24_0)
        # exit(0)

        concat = f'{opcode_31_25}{offset_24_0}'
        if len(concat) != 32:
            print(f'Oops, "{list_of_arguments}" crashed in JMP, in b_instruction(), failed lengthcheck: {len(concat)} {concat}')
            exit(1)

        hexvalue = hex(int(concat, 2))[2:].zfill(8)
        # print(hexvalue)
        # exit(0)

        return hexvalue, concat

    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in b_instruction()')
        exit(1)


r_type = [
    "ADD",      # r1 <- r2 + r3
    "SUB",      # r1 <- r2 - r3
    "AND",      # r1 <- r2 AND r3
    "OR",       # r1 <- r2 OR r3
    "SLT",      # r1 <- "1" if r2 < r3, otherwise r1 <- "0"
    "MUL",      # r1 <- r2 * r3
]

m_type = [
    "ADDI",     # r1 <- r2 + imm
    "LDB",      # r1 <- mem[r2 + imm]
    "LDW",      # r1 <- mem[r2 + imm]
    "STB",      # mem[r2 + imm] <- r1                       # s.t. r1 is moved to r3
    "STW",      # mem[r2 + imm] <- r1                       # s.t. r1 is moved to r3
]

b_type = [
    "BEQ",      # if r1 == r2, PC = PC_plus4 + imm          # s.t. r1 is moved to r3
    "JMP",      # PC = concat(PC(31 downto 27, imm, "00")   # imm is instr(24 downto 0)
]

asm_src = [

    # ###########################################################################
    # # NeilWeste check program, end up writing a 7 in adr 76
    # ###########################################################################
    # "LDB 2 0 68",
    # "LDB 7 0 64",
    # "LDB 3 7 69",
    # "OR 4 7 2",
    # "AND 5 3 4",
    # "ADD 5 5 4",
    # "BEQ 5 7 8",
    # "SLT 6 3 4",
    # "BEQ 6 0 1",
    # "LDB 5 0 0",
    # "SLT 6 7 2",
    # "ADD 7 6 5",
    # "SUB 7 7 2",
    # "JMP 15",
    # "LDB 7 0 0",
    # "STB 7 2 71",
    # "STW 7 0 0",
    # "STB 7 0 1",
    # "LDB 1 0 1",
    # "LDW 1 0 0",
    # "ADDI 3 3 -1",
    # "MUL 3 3 3",

    # ###########################################################################
    # # NeilWeste nth Fibonacci number
    # ###########################################################################
    # "ADDI 3 0 9",
    # "ADDI 4 0 1",
    # "ADDI 5 0 -1",
    # "BEQ 3 0 4",
    # "ADD 4 4 5",
    # "SUB 5 4 5",
    # "ADDI 3 3 -1",
    # "JMP 3",
    # "STW 4 0 255",

    # # moneyharris(84)
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 5 5 5",
    # "ADDI 6 6 6",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADD 6 2 3",    # reg6 should have a 5
    # "AND 7 6 1",    # reg7 should have a 1
    # "OR 7 4 6",     # reg7 should have a 5
    # "SUB 7 6 5",    # reg7 should have a 0

    # # ADDIstuff
    # "ADDI 1 1 5", # $1 <- "5"
    # "ADDI 2 2 6", # $2 <- "6"
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "ADDI 1 1 1", # increase $1 by one
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "ADD 2 1 2", # $2 <- $1 + $2, which should be "12"
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "LDB 2 0 68",
    # "LDW 1 0 0",
    # "ADDI 0 0 0", # NOP
    # "ADDI 0 0 0", # NOP
    # "STB 2 0 0",
    # "STB 1 0 0",
    # "STW 2 0 0",

    # # 134(70)
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 5 5 5",
    # "ADDI 6 6 6",
    # "OR 0 0 0",
    # "OR 0 0 0",
    # "OR 0 0 0",
    # "ADD 2 1 3",
    # "AND 12 2 5",
    # "OR 13 6 2",
    # "ADD 14 2 2",

    # # CHECK
    # "STB 2 2 0", # dmem(4) should have a 4

    # # # CHECK
    # # "STB 2 14 0", # dmem(8) should have a 4 bc ME_toEX_alu_bypass

    # # # CHECK
    # # "OR 0 0 0",
    # # "STB 2 14 0", # dmem(8) should have a 4 bc ME_toEX_alu_bypass

    # # # CHECK
    # # "STB 14 2 0", # dmem(4) should have a 8 bc ME_toEX_memWdata_bypass

    # # # CHECK
    # # "OR 0 0 0",
    # # "STB 14 2 0", # dmem(4) should have a 8 bc ME_toEX_memWdata_bypass

    # # # CHECK
    # # "STB 14 14 0", # dmem(8) should have a 8 bc ME_toEX_alu_bypass __and__ ME_toEX_memWdata_bypass

    # # # CHECK
    # # "OR 0 0 0",
    # # "STB 14 14 0", # dmem(8) should have a 8 bc ME_toEX_alu_bypass __and__ ME_toEX_memWdata_bypass

    #############################################################################

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "STB 2 1 0", # dmem(2) should have a 0

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "OR 0 0 0",
    # "STB 2 1 0", # dmem(2) should have a 0

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "STB 1 2 0", # dmem(0) should have a 2

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "OR 0 0 0",
    # "STB 1 2 0", # dmem(0) should have a 2

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "STB 1 1 1", # dmem(3) should have a 2

    # # CHECK
    # "LDB 1 0 2", # reg1 should have a 2
    # "OR 0 0 0",
    # "STB 1 1 1", # dmem(3) should have a 2

    #############################################################################
    # load add store...
    # add load store...
    #############################################################################


    # # double data hazard
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADD 1 1 2",    # reg1 should have a 3
    # "ADD 1 1 3",    # reg1 should have a 6
    # "ADD 1 1 4",    # reg1 should have a 10
    # # "ADD 1 2 3",    # reg1 should have a 5
    # # "ADD 1 1 4",    # reg1 should have a 9

    # # load-arith
    # "LDB 1 0 39",   # put an 0x80, 0d128 into reg1
    # "ADDI 2 1 1",   # reg2 should have a 129
    # "ADD 3 2 1",    # reg3 should have a 257
    # "ADD 4 1 3",    # reg4 should have a 385

    # # BEQstallstuff distance 1
    # "ADDI 1 1 1",
    # "ADDI 10 10 8",
    # "BEQ 10 10 3",
    # "SUB 1 1 1",
    # "ADDI 2 2 2",
    # "SUB 3 3 3",
    # "LDB 4 0 0",

    # # BEQstallstuff distance 2
    # "ADDI 1 1 1",
    # "ADDI 10 10 8",
    # "OR 0 0 0",
    # "BEQ 10 10 3",
    # "SUB 1 1 1",
    # "ADDI 2 2 2",
    # "SUB 3 3 3",
    # "LDB 4 0 0",

    # # BEQstallstuff sanitycheck1
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 5 5 5",
    # "ADDI 6 6 6",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADD 1 2 3",
    # "ADD 4 5 6",
    # # "ADD 4 2 3", # for takingbranch
    # "BEQ 1 4 1",
    # "ADDI 1 2 3",
    # "OR 4 5 6",

    # # BEQstallstuff sanitycheck2
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 5 5 5",
    # "ADDI 6 6 6",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "LDB 1 0 0",
    # "ADD 4 5 6",
    # # "ADDI 4 0 68", # for takingbranch
    # "BEQ 1 4 1",
    # "ADDI 1 2 3",
    # "OR 4 5 6",

    # # BEQstallstuff sanitycheck3
    # "ADDI 1 1 1",
    # "ADDI 2 2 2",
    # "ADDI 3 3 3",
    # "ADDI 4 4 4",
    # "ADDI 5 5 5",
    # "ADDI 6 6 6",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADDI 0 0 0",
    # "ADD 4 5 6",
    # # "ADDI 4 0 68", # for takingbranch
    # "LDB 1 0 0",
    # "BEQ 1 4 1",
    # "ADDI 1 2 3",
    # "OR 4 5 6",

    # # 134(45)
    # "LDB 1 0 0",  # reg1 should have a 68
    # "LDB 2 0 4",  # reg2 shoudl have a 64
    # "ADD 3 1 2",  # reg3 should have a 132
    # "STB 3 0 12", # dmem(12) should have a 132
    # "LDB 4 0 8",  # reg4 should have a 69
    # "ADD 5 1 4",  # reg5 should have a 137
    # "STB 5 0 16", # demem(16) shoudl have a 137

    # # perftest 1
    # "ADDI 1 0 128", # limit of 128
    # "ADD 2 0 0",    # sum
    # "ADD 3 0 0",    # i
    # "BEQ 1 3 4",    # start loop
    # "LDB 4 3 0",
    # "ADD 2 2 4",    # sum = a[i]
    # "ADDI 3 3 1",   # i++
    # "JMP 3",        # try loop condition again
    # "ADDI 5 0 1",   # finish flag

    # # perftest 2
    # "ADDI 1 0 128", # limit of 128
    # "ADDI 2 0 5",   # 5 value
    # "ADD 3 0 0",    # i
    # "ADDI 4 0 0",   # base pointer for a[128]
    # "ADDI 5 0 128", # base pointer for b[128]
    # "BEQ 1 3 4",    # start loop #1
    # "STB 2 4 0",    # a[i] = 5
    # "ADDI 4 4 1",   # update pointer of a[128]
    # "ADDI 3 3 1",   # i++
    # "JMP 5",        # try loop condition again
    # "SUB 4 4 3",    # reset pointer of a[128]
    # "ADDI 3 0 0",   # reset i
    # "BEQ 1 3 6",    # start loop #2
    # "LDB 6 4 0",    # intermediate register to hold a[i] value
    # "STB 6 5 0",    # b[i] = a[i]
    # "ADDI 4 4 1",   # update pointer of a[128]
    # "ADDI 5 5 1",   # update pointer of b[128]
    # "ADDI 3 3 1",   # i++
    # "JMP 12",       # try loop condition again
    # "ADDI 31 0 1",  # finish flag

    # perftest 3
    "ADDI 1 0 10", # limit of 128
    "ADD 2 0 0",    # i
    "ADD 3 0 0",    # j
    "ADD 4 0 0",    # k
    "ADDI 5 0 0",   # base pointer for a[][]
    "ADDI 6 0 0",   # base pointer for b[][]
    "ADDI 7 0 0",   # base pointer for c[][]
    "BEQ 1 2 22",   # start loop #1
    "BEQ 1 3 18",   # start loop #2
    "MUL 10 2 1",   # i*128
    "ADD 11 10 3",  # (i*128)+j
    "ADD 12 11 7",  # (i*128)+j+base_c_pointer
    "STB 0 12 0",   # c[i][j] = 0
    "BEQ 1 4 10",   # start loop #3
    # a[i][k] section
    "MUL 13 2 1",   # i*128
    "ADD 14 13 4",  # (i*128)+k
    "ADD 15 14 5",  # (i*128)+k+base_a_pointer
    # b[k][j] section
    "MUL 16 2 1",   # k*128
    "ADD 17 16 3",  # (k*128)+j
    "ADD 18 17 6",  # (k*128)+j+base_b_pointer
    # a[i][k]*b[k][j] section
    "MUL 19 15 18",
    # c[i][j]=c[i][j]+a[i][k]*b[k][j] section
    "ADD 12 12 19",
    "ADDI 4 4 1",   # k++
    "JMP 13",       # try loop #3 condition again
    "ADDI 4 0 0",   # reset k
    "ADDI 3 3 1",   # j++
    "JMP 8",        # try loop #2 condition again
    "ADDI 3 0 0",   # reset j
    "ADDI 2 2 1",   # i++
    "JMP 7",        # try loop #1 condition again
    "ADDI 2 0 0",   # reset i
    "ADDI 8 0 1",   # finish flag


]

isa_instrs = []

bin_instrs = []

for asm_instr in asm_src:
    spacesplit = asm_instr.split(" ")
    if spacesplit[0] in r_type:
        instruction_hex, instruction_bin = r_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    elif spacesplit[0] in m_type:
        instruction_hex, instruction_bin = m_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    elif spacesplit[0] in b_type:
        instruction_hex, instruction_bin = b_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    else:
        print(f'Oops, "{asm_instr}" crashed, instruction not known')
        exit(1)

for final_instr, bin_versh, asm_instr in zip(isa_instrs, bin_instrs, asm_src):
    print(f'{final_instr:<12}{asm_instr:<20}{bin_versh}')
