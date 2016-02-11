                ;**************************************************************************************
                ; Jeff Stanton
                ; CS M30
                ; Program Assignment #1
                ;
                ; This program will prompt the user to input a string, 
                ; and then retrieve the input using the ReadConsole Windows API function.   
                ; The program will then copy (mov) the string entered into a byte 
                ; array in reverse order using indirect addressing.  
                ; This program only moves the number of characters that the user inputs.  
                ; Finally the program will terminate.
                ;
                ;**************************************************************************************
                
                .586
                .MODEL flat, stdcall

                include Win32API.asm

                .STACK 4096

                .DATA

BytesRead       dword       0
InputBuffer     byte        80 dup (0)
hStdIn          dword       0

userPrompt      byte        "Please enter a string up to 80 characters long:", 13, 10
index           dword       0
OutputBuffer    byte        80 dup (0)
BytesWritten    dword       0
hStdOut         dword       0

bufferFull      equ         80
hasLineFeed     equ         79
bufferEmpty     equ         2


               .CODE

start:
               ;***************************************************************
               ; Get Handle to Standard Output
               ;***************************************************************
               invoke   GetStdHandle, STD_OUTPUT_HANDLE       ;Win32 API Function
               mov      hStdOut, eax                          ;Save output handle
              
               ;***************************************************************
               ; Prompt user to input a string
               ;***************************************************************
               invoke   WriteConsoleA, hStdOut, OFFSET userPrompt, SIZEOF userPrompt, OFFSET BytesWritten, 0
               		
               ;***************************************************************
               ; Get Handle to Standard Input
               ;***************************************************************		
               invoke  GetStdHandle, STD_INPUT_HANDLE          ;Win32 API Function
               mov     hStdIn,eax                              ;Save input handle
        
               ;***************************************************************
               ; Get User Input
               ;***************************************************************		
               invoke  ReadConsoleA, hStdIn, OFFSET InputBuffer, SIZEOF InputBuffer, OFFSET BytesRead, 0

               ;***************************************************************
               ; Determine correct number of elements for array InputBuffer
               ;***************************************************************	
               mov      eax,  BytesRead         ;Number of elements in the array
               mov      index, eax              ;Index will be used to access elements in InputBuffer

               cmp      index, bufferEmpty      ;Check if the user entered anything
               je       endProgram              ;If not, end the program
               
               cmp      index, bufferFull       ;Check if the InputBuffer is full
               jge      Main                    ;If so, skip the remaining conditionals and go to main program logic for array reversal
               
               cmp      index, hasLineFeed      ;Check to see if the InputBuffer has the line feed character
               je       IgnoreLineFeed          ;If so, then remove 1 from index
                                   
               sub      index, 2                ;InputBuffer has <= 78 elements, therefore ignore carriage return and line feed
               jmp      Main                    ;Go to main program logic for array reversal

IgnoreLineFeed:
               sub      index, 1                ;Need to ignore the line feed

               ;***************************************************************
               ; Determine indexes and copy contents of InputBuffer to 
               ; OutputBuffer in reverse
               ;***************************************************************
Main:
               sub      index, 1                ;To access elements correctly in zero-based array
               xor      edi, edi                ;Index into OutputBuffer (first element in the array)
               mov      esi, index              ;Index into InputBuffer (last element in the array)

L1:
               mov      al, InputBuffer[esi * TYPE InputBuffer]     ;Get element from the array
               mov      OutputBuffer[edi * TYPE OutputBuffer], al   ;Store element in OutputBuffer
               inc      edi           
               dec      esi
               cmp      edi, index      ;Loop from 0 to n - 1, where n is the number of characters (not total elements) in the array InputBuffer
               jle      L1
			   
               ;***************************************************************
               ; Terminate Program
               ;***************************************************************		
endProgram:
			   invoke  ExitProcess, 0
               END start