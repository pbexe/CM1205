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

		mov eax,LENGTHOF type_msg
		invoke WriteConsoleA, outputHandle, addr type_msg, eax, addr bytes_written, 0

		mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr type_buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	

		mov ecx, value_bytes_read ; Set counter for the for loop
		mov ebx, 0 ; Used to increment through buffer
		mov input_value, 0 ; Initialize the input value 
		read_loop: ; Start of for loop
			mov eax, input_value ; Load the input value into eax
			mov edx, 10 ; This is what eax is going to be multiplied by
			mul edx ; Do the multiplication
			mov input_value, eax ; Save eax back into memory so it is not overwritten
			mov al, byte ptr value_buffer + [ebx] ; Load the next value from the buffer into register
			movzx eax, al ; Allow use of the whole 32 bits
			sub eax, 30h ; ASCII to int
			add eax, input_value ; Add new value with current total
			mov input_value, eax ; Save this value back to memory again
			inc ebx
			loop read_loop

		mov al, byte ptr type_buffer
		cmp al, 67
		je celcius
		cmp al, 70
		je farenheit

		celcius:
		mov eax, 1
		jmp finish

		farenheit:
		mov eax, 2
		jmp finish

		finish:
		push	0

		call	ExitProcess@4
main endp
end
