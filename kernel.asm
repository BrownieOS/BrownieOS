;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		kernel.asm - The BrownieOS core																		;
;===========================================================================================================;
																											;
	use16																									; We are loaded in 16-bit real mode, and we will set the gdt and protected mode later
	org 8000h																								; We need this for 32 and 16-bit code
	format binary as 'bwn'																					; Output a Brownie core file
																											;
	jmp Brownie16																							; Jump to the 16-bit entry point
																											;
	;=======================================================================================================;
	;	Kernel Includes																						;
	;=======================================================================================================;
	; None For Now! :)																						;
																											;
	Brownie16:																								;
		xor ax, ax																							; Set the segment to 0
		mov ds, ax																							; We can't move directly into a segment, so move it into ax, then the segment
		mov es, ax																							; .
		mov fs, ax																							; .
		mov gs, ax																							; .
																											;
		cli																									; If we land here, clear the interrupts
		hlt																									; And, halt the system, to prevent code after this from executing