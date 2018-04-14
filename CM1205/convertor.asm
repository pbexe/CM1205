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
    bufSize = 80 ; Length of standard buffer
    inputHandle DWORD ? ; Input handle
    value_buffer byte bufSize dup(?) ; Buffer to hold value input
    type_buffer byte bufSize dup(?) ; Buffer to hold the type input
    value_bytes_read  DWORD  ? ; Number of value bytes read
    bytes_read  DWORD  ? ; Number of type bytes read
    value_msg db "Please enter the value you wish to convert:",0 ; Buffer containing the first message
    type_msg db "Please enter the unit you wish to convert this to (C/F):",0 ; Buffer containing the second message
    outputHandle DWORD ? ; Output handle
    bytes_written dd ? ; Number of bytes written.
    input_value DWORD ? ; The value the user inputted
    output_value DWORD ? ; The number after the calculation
    output_string byte bufSize dup(?) ; The string to output (Backwards)
    output_buffer byte bufSize dup(?) ; The string to output (Forwards)
    final_length byte ? ; The number of characters in the final output
.code
  main proc
    invoke GetStdHandle, STD_OUTPUT_HANDLE ; Get the standard output handle
    mov outputHandle, eax ; Save it
    mov eax,LENGTHOF value_msg ; Get the length of the first message
    invoke WriteConsoleA, outputHandle, addr value_msg, eax, addr bytes_written, 0 ; Print the first message
    invoke GetStdHandle, STD_INPUT_HANDLE ; Get the standard input handle
    mov inputHandle, eax ; Save it
    invoke ReadConsoleA, inputHandle, addr value_buffer, bufSize, addr value_bytes_read,0 ; Get the user's input
    sub value_bytes_read, 2 ; Remove the CL RF
    mov eax,LENGTHOF type_msg ; Get the length of the second message
    invoke WriteConsoleA, outputHandle, addr type_msg, eax, addr bytes_written, 0 ; Print the message
    invoke ReadConsoleA, inputHandle, addr type_buffer, bufSize, addr bytes_read,0 ; Get the user's second input
    sub bytes_read, 2 ; Remove the CL RF
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

    mov al, byte ptr type_buffer ; Get the unit to convert to
    cmp al, 67 ; If it is C
    je calc_celsius ; Jump to the celsius calculation
    cmp al, 70 ; If it is F
    je calc_fahrenheit ; Jump to the fahrenheit calculation
    calc_celsius: ; Calculate the value in celsius
    call celsius ; Call celsius
    jmp to_str ; Jump to the next section of code
    calc_fahrenheit: ; Calculate the value in fahrenheit
    call fahrenheit ; Call fahrenheit
    to_str: ; Convert to string
      mov ecx, 0 ; Set the counter to 0
      mov final_length, 0 ; Set the length counter to 0
      output_loop: ; For each digit in the number
        cmp ecx, 2 ; Is it the third (2) digit?
        je dot ; Because this needs to be a dot
        cmp eax, 0 ; Have we run out of digits?
        je ending ; If so, finish
        mov ebx, 10 ; Getting ready to divide by 10
        mov edx, 0 ; Set the remainder register to 0
        div ebx ; Divide by 10
        add dl, 30h ; Make the remainder the correct ASCII char
        mov byte ptr output_string + [ecx], dl ; Save it to the buffer
        mov bl, final_length ; Update final length
        inc bl ; Increment the digit counter
        mov final_length, bl ; Save it again because we use this register for other stuff
        inc ecx ; Increment the main loop counter
        jmp output_loop ; Do the loop again
        dot:
          mov byte ptr output_string + [ecx], 02Eh ; Set the vvalue in the buffer to be "."
          mov bl, final_length ; Update the final length
          inc bl ; Increment it
          mov final_length, bl ; And then save it again
          inc ecx ; Increment the main counter
          jmp output_loop ; Do the loop again

    ending:
    movzx ecx, final_length ; Load the final length into a 32 bit register
    mov ebx, 0 ; ebx is going to be used as a forwards counter
    reverse_loop: ; Begin the reversing process because the string is backwards!
      mov al, byte ptr output_string + [ebx] ; Move the first byte of the output into al
      mov byte ptr output_buffer + [ecx], al ; More this first byte into the last byte of the output string
      inc ebx ; Increment to get next byte
      loop reverse_loop ; Loop

    mov eax, LENGTHOF output_buffer ; Get the length for the printing function
    invoke WriteConsoleA, outputHandle, addr output_buffer, eax, addr bytes_written, 0 ; Invoke the printing function
    push 0
    call  ExitProcess@4

    ; Fin

  celsius PROC
    mov eax, input_value ; Load the input value
    sub eax, 32 ; F - 32
    mov ebx, 5
    mul ebx ; (f - 32) * 5
    mov ebx, 100
    mul ebx ; Multiply it by 100 so I don't need to use floating points
    mov ebx, 9
    div ebx ; Divide by 9
    ret
  celsius ENDP

  fahrenheit PROC
    mov eax, input_value ; Load the input value
    mov ebx, 9 ; Prepare for the multipliation
    mul ebx ; 9*centigrade
    mov ebx, 100 ; Multiplication factor to give 2 decimal places
    mul ebx ; Do the multiplication
    mov ebx, 5 ; Prepare for division
    div ebx ; Actually do the division
    add eax, 3200 ; Add 32.00
    ret
  fahrenheit ENDP
main endp
end

