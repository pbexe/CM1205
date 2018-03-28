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
		output_string byte bufSize dup(?)
		output_buffer byte bufSize dup(?)
		final_length byte ?
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

 		invoke ReadConsoleA, inputHandle, addr type_buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	

		mov ecx, value_bytes_read                 ; Set counter for the for loop
		mov ebx, 0                                ; Used to increment through buffer
		mov input_value, 0                        ; Initialize the input value 
		read_loop:                                ; Start of for loop
			mov eax, input_value                  ; Load the input value into eax
			mov edx, 10                           ; This is what eax is going to be multiplied by
			mul edx                               ; Do the multiplication
			mov input_value, eax                  ; Save eax back into memory so it is not overwritten
			mov al, byte ptr value_buffer + [ebx] ; Load the next value from the buffer into register
			movzx eax, al                         ; Allow use of the whole 32 bits
			sub eax, 30h                          ; ASCII to int
			add eax, input_value                  ; Add new value with current total
			mov input_value, eax                  ; Save this value back to memory again
			inc ebx
			loop read_loop

		mov al, byte ptr type_buffer              ; Get the unit to convert to
		cmp al, 67                                ; If it is C
		je celcius                                ; Jump to celcius
		cmp al, 70                                ; If it is F
		je farenheit                              ; Jump to farenheit

		celcius:
		mov eax, input_value                      ; Load the input value
		sub eax, 32                               ; F - 32
		mov ebx, 5
		mul ebx                                   ; (f - 32) * 5
		mov ebx, 100
		mul ebx                                   ; Multiply it by 100 so I don't need to use floating points
		mov ebx, 9
		div ebx ; Divide by 9
		mov output_value, eax ; Save the result
		jmp finish

		farenheit:
		mov eax, input_value
		mov ebx, 9
		mul ebx ; 9*centigrade
		mov ebx, 100 ; Multiplication factor to give 2 decimal places
		mul ebx
		mov ebx, 5
		div ebx
		add eax, 3200
		mov output_value, eax

		jmp finish

		finish:
		mov eax, output_value
		mov ecx, 0
		mov final_length, 0
		output_loop:
			cmp ecx, 2
			je dot
			cmp eax, 0
			je ending
			mov ebx, 10
			mov edx, 0
			div ebx
			add dl, 30h
			mov byte ptr output_string + [ecx], dl
			mov bl, final_length
			inc bl
			mov final_length, bl
			inc ecx
			jmp output_loop
			dot:
				mov byte ptr output_string + [ecx], 02Eh
				mov bl, final_length
				inc bl
				mov final_length, bl
				inc ecx
				jmp output_loop

		ending:
		movzx ecx,final_length
		mov ebx, 0
		reverse_loop:
			mov al, byte ptr output_string + [ebx]
			mov byte ptr output_buffer + [ecx], al
			inc ebx
			loop reverse_loop
		mov eax, LENGTHOF output_buffer
		invoke WriteConsoleA, outputHandle, addr output_buffer, eax, addr bytes_written, 0
		push	0

		call	ExitProcess@4
main endp
end
