.586
.model flat, stdcall
option casemap :none
.stack 4096
extrn ExitProcess@4: proc

GetStdHandle proto :dword
ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11

.data
	
		bufSize = 80
 	 	inputHandle DWORD ?
 	    value_buffer DW bufSize dup(?)
		type_buffer DWORD bufSize dup(?)
 	    bytes_read  DWORD  ?
		value_msg db "Please enter the value you wish to convert:",0
		type_msg db "Please enter the unit you wish to convert this to (C/F):"
 	 	outputHandle DWORD ?
		bytes_written dd ?
.code
	main proc
		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov eax,LENGTHOF value_msg
		invoke WriteConsoleA, outputHandle, addr value_msg, eax, addr bytes_written, 0

 	    invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr value_buffer, bufSize, addr bytes_read,0

		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov eax,LENGTHOF type_msg
		invoke WriteConsoleA, outputHandle, addr type_msg, eax, addr bytes_written, 0

		invoke GetStdHandle, STD_INPUT_HANDLE
		mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr type_buffer, bufSize, addr bytes_read,0

		;mov ax,value_buffer
		;mov ax,type_buffer
		push	0

		call	ExitProcess@4
main endp
end
