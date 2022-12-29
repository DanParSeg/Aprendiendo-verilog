ROM_ADDR_BITS=16
ROM_SIZE=2**ROM_ADDR_BITS

ram=[0]*ROM_SIZE

def write_rom(ram, filename):
    f=open(filename, "w")
    for i in range(ROM_SIZE):
        f.write("%d\n" % ram[i])

def compile_bf(bf_code, ram):
    pc=0
    for c in bf_code:
        if c=="+":
            ram[pc]=0b00000000+0b00000001
        elif c=="-":
            ram[pc]=0b00100000+0b00000001
        elif c==">":
            ram[pc]=0b01000000+0b00000001
        elif c=="<":
            ram[pc]=0b01100000+0b00000001
        elif c==".":
            ram[pc]=0b10000000+0b00000000
        elif c==",":
            ram[pc]=0b10000000+0b00000000
        elif c=="[":
            ram[pc]=0b10000000+0b00000000
        elif c=="]":
            ram[pc]=0b10000000+0b00000000
        pc+=1
    return ram


bf="+>++>+++"
write_rom(compile_bf(bf,ram), "bf_program.list")