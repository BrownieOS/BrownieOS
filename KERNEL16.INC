;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		KERNEL16.INC - The BrownieOS 16-bit kernel functions												;
;===========================================================================================================;
																											;
	;=======================================================================================================;
	;	PrintString16																						;
	;		In:																								;
	;			SI => String to print (0-terminated)														;
	;		Out:																							;
	;			Nothing																						;
	;		Prints a string in 16-bit real mode to the VGA display											;
	;=======================================================================================================;
	PrintString16:																							;
		pusha																								; Save the registers
		mov ah, 0Eh																							; Int 10h Function 0Eh = Print Character
	NextChar16:																								; Loop through all the characters
		lodsb																								; Load 1 character
		cmp al, 0																							; Is it asciiz 0?
		je DonePrinting16																					; If so, we are done printing
		int 10h																								; Otherwise, we are done printing
		jmp NextChar16																						; And, print the next character
	DonePrinting16:																							; Land here when we are done
		popa																								; Restore the registers
		ret																									; Return to where we were called
																											;
	;=======================================================================================================;
	;	GetChar16																							;
	;		In:																								;
	;			Nothing																						;
	;		Out:																							;
	;			Nothing																						;
	;		Waits for a char and then returns it in 16-bit real mode										;
	;=======================================================================================================;
	GetChar16:																								;
		pusha																								; Save the registers
																											;
		mov ax, 0																							; 16h 00h Get char
		int 16h																								;
																											;
		mov [.Char], al																						; Save the char
																											;
		popa																								; Restore the registers
																											;
		mov al, [.Char]																						; Restore the char
																											;
		ret																									; Return to where we were called
																											;
		.Char				db	0																			; Char pressed