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
 	    buffer db bufSize dup(?)
 	    bytes_read  DWORD  ?
		sum_string db "Test Console output",0
 	 	outputHandle DWORD ?
		bytes_written dd ?
.code
	main proc
 	    invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read,0
 	
		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov	eax,LENGTHOF sum_string	;length of sum_string
		invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written, 0

 	    invoke WriteConsoleA, outputHandle, addr buffer, bytes_read, addr bytes_written, 0

		mov eax,0
		mov eax,bytes_written
		push	0

		call	ExitProcess@4
main endp
end
