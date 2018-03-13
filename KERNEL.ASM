;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		KERNEL.ASM - The BrownieOS core																		;
;===========================================================================================================;
																											;
	use16																									; We are loaded in 16-bit real mode, and we will set the gdt and protected mode later
	org 8000h																								; We need this for 32 and 16-bit code
	format binary as 'BWN'																					; Output a Brownie core file
																											;
	jmp Brownie16																							; Jump to the 16-bit entry point
																											;
	;=======================================================================================================;
	;	Kernel 16-bit Includes																				;
	;=======================================================================================================;
	include "KERNEL16.INC"																					; Kernel main 16-bit functions
	include "CONFIG.INC"																					; Configuration screen
	include "VBE16.INC"																						; HD/VBE/VESA functions
																											;
	Brownie16:																								;
		xor ax, ax																							; Set the segment to 0
		mov ds, ax																							; We can't move directly into a segment, so move it into ax, then the segment
		mov es, ax																							; .
		mov fs, ax																							; .
		mov gs, ax																							; .
																											;
		call ConfigBrownie																					; Do the configuration screen
																											;
		call InitVBE																						; Initialize VBE
																											;
		cli																									; If we land here, clear the interrupts
		hlt																									; And, halt the system, to prevent code after this from executing