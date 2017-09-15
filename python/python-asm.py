def peachpy_one():
  import peachpy
  import peachpy.x86_64
  
  x = peachpy.Argument(peachpy.int32_t)
  y = peachpy.Argument(peachpy.int32_t)
  
  with peachpy.x86_64.Function("Add", (x, y), peachpy.int32_t) as asm_function:
    reg_x = peachpy.x86_64.GeneralPurposeRegister32()
    reg_y = peachpy.x86_64.GeneralPurposeRegister32()
  
    peachpy.x86_64.LOAD.ARGUMENT(reg_x, x)
    peachpy.x86_64.LOAD.ARGUMENT(reg_y, y)
    for _ in range(1000):
      peachpy.x86_64.ADD(reg_x, reg_y)
  
    peachpy.x86_64.RETURN(reg_x)
  
  py_fun = asm_function.finalize(peachpy.x86_64.abi.detect()).encode().load()
  print("done creating function") 

  import time
  start = time.perf_counter()
  for _ in range(100000):
    _ = py_fun(2,2) 
  print("end time for pypeach is {}".format(time.perf_counter() - start))

  start = time.perf_counter()
  for _ in range(100000):
    _ = 2+2
  print("end time for statement is {}".format(time.perf_counter() - start))

def peachpy_conways_game_of_life():
  # http://computer-programming-forum.com/45-asm/a583f83ace3871c5.htm
  # https://news.ycombinator.com/item?id=10232025
  # http://www.dlr.de/sc/en/Portaldata/15/Resources/dokumente/PyHPC2013/submissions/pyhpc2013_submission_10.pdf
  # implement this in peachpy:
  """
OPTION SEGMENT:USE16
.386
cseg SEGMENT BYTE
ASSUME NOTHING
ORG 0100h
kode PROC NEAR 
MOV SP,0100h
MOV AX,013h
INT 010h
MOV AH,02Ch
INT 021h  
MOV BP,CX
MOV AX,DS
ADD AX,01Ah             ;(OFFSET endofprog+0Fh>>4)=(1A)
MOV ES,AX              
MOV AX,0A000h
MOV DS,AX 
XOR DI,DI
MOV CX,0FA00h
REP STOSB 
MOV CL,0C6h
MOV DI,0141h            ;array offset we are addressing
MOV BX,DI
lopr0:  MOV SI,-013Eh  
lopr:   LEA AX,[BP+DI]
ROR BP,3
XOR BP,DX
SUB DX,AX 
CMP AL,0C0h
SBB AL,AL
INC AX
STOSB 
INC SI
JNZ lopr
SCASW                   ;DI+=2, skipping edge
LOOP lopr0 
PUSH ES
PUSH DS
POP ES
POP DS                  ;DS=vseg,ES=0A000h throughout 
mlop: 
MOV DI,BX               ;DI=0141h 
lopy:   MOV SI,013Eh 
lopx:   MOV AX,[DI-0141h]
ADD AL,[DI-013Fh]
ADD AX,[DI+BX-2]
ADD AL,[DI+BX]
ADD AL,[DI-1]
ADD AL,[DI+1]
ADD AL,AH 
OR AL,[DI]
AND AL,0Fh
CMP AL,3
JNZ SHORT ko
OR BYTE PTR [DI],010h
ko:     INC DI
DEC SI
JNZ lopx 
CASW
CMP DI,0FA00h-013Fh
JC lopy 
MOV CX,03E80h
XOR DI,DI
lopc:   LODSD
SHR EAX,4
AND EAX,01010101h
MOV [SI-4],EAX
STOSD
LOOP lopc 
MOV AH,0Bh
INT 021h
ADD AL,3 
JP mlop 
CBW
INT 010h 
MOV AH,04Ch
INT 021h 
kode ENDP
endof EQU $
cseg ENDS
END FAR PTR kode 
  """  

if __name__ == "__main__":
  peachpy_one() 
