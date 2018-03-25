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
 	    value_buffer byte bufSize dup(?)
		type_buffer byte bufSize dup(?)
 	    value_bytes_read  DWORD  ?
		bytes_read  DWORD  ?
		value_msg db "Please enter the value you wish to convert:",0
		type_msg db "Please enter the unit you wish to convert this to (C/F):",0
 	 	outputHandle DWORD ?
		bytes_written dd ?
		input_value DWORD ?
		output_value DWORD ?
.code
	main proc
		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov eax,LENGTHOF value_msg
		invoke WriteConsoleA, outputHandle, addr value_msg, eax, addr bytes_written, 0

 	    invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr value_buffer, bufSize, addr value_bytes_read,0
		sub value_bytes_read, 2	

		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov eax,LENGTHOF type_msg
		invoke WriteConsoleA, outputHandle, addr type_msg, eax, addr bytes_written, 0

		invoke GetStdHandle, STD_INPUT_HANDLE
		mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr type_buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	

		mov ecx, value_bytes_read
		mov ebx, 0
		mov output_value, 0
		read_loop:
			mov eax, input_value
			mov edx, 10
			mul edx
			mov input_value, eax
			mov al, byte ptr value_buffer + [ebx]
			movzx eax, al
			sub eax, 30h
			add eax, input_value
			mov input_value, eax
			inc ebx
			loop read_loop

		push	0

		call	ExitProcess@4
main endp
end
