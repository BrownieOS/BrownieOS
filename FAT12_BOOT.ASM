;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		FAT12_BOOT.ASM - The FAT12 floppy disk boot sector													;
;===========================================================================================================;
																											;
	use16																									; We are loaded in 16-bit real mode
	org 0																									; We will set the segments later
	format binary as 'BWN'																					; Output a Brownie core file
																											;
	jmp LoadBrownieKernel																					; Jump to the main kernel loading routines
																											;
	;=======================================================================================================;
	;	BIOS Parameter Block																				;
	;=======================================================================================================;
	bpbOEMLabel					db	"BROWNIE "																; OEM Label - 8 Chars
	bpbBytesPerSector			dw	512																		; Bytes Per Sector
	bpbSectorsPerCluster		db	1																		; Sectors Per Cluster
	bpbReservedForBoot			dw	1																		; Number Of Sectors Reserved For The Bootloader
	bpbNumberOfFATs				db	2																		; Number Of FATs
	bpbRootDirEntries			dw	224																		; Root Directory Entries
	bpbTotalSectors				dw	2880																	; Total Logical Sectors
	bpbMediaDescriptorByte		db	0xF0																	; Media Descriptor Byte
	bpbSectorsPerFAT			dw	9																		; Sectors Per FAT
	bpbSectorsPerTrack			dw	18																		; Sectors Per Track
	bpbHeadsPerCylinder			dw	2																		; Heads Per Cylinder
	bpbHiddenSectors			dd	0																		; Hidden Sectors
	bpbLargeSectors				dd	0																		; Large Sectors
	bsDriveNumber				db	0																		; Drive Number A: = 0 B: = 1
	bsNTReserved				db	0																		; This Value Is Reserved For The Windows NT Operating System
	bsBootSignature				db	0x29																	; Boot Signature
	bsSerialNumber				dd	0x77777777																; Serial Number
	bsVolumeLabel				db	"BROWNIEOS  "															; Volume Label - 11 Chars
	bsFileSystem				db	"FAT12   "																; File System - 8 Chars
																											;
	LF							equ	10																		; Line Feed
	CR							equ	13																		; Carriage Return
	KernelSegment				equ	0x0800																	; Kernel Segment
	Buffer						equ	0x0200																	; Buffer
	KernelFilename				db	"KERNEL  BWN"															; Kernel Filename
	InitMSG						db	"Loading BrownieOS...", 0												; Loading Message
	KernelNotFoundMSG			db	13, 10, "Kernel Not Found!", 0											; Kernel Not Found Message
	Progress					db	".", 0																	; Progress Character
	Cluster						dw	0																		; Current Cluster
	Pointer						dw	0																		; RAM Pointer
	CRLF						db	CR, LF, CR, LF, 0														; A bunch of newlines
																											;
	;=======================================================================================================;
	;	Bootloader Subroutines																				;
	;=======================================================================================================;
	ConvertLBAtoCHS:																						; The routine to convert LBA to CHS
		push bx																								; Save the registers
		push ax																								;
																											;
		mov bx, ax																							; Save the LBA
																											;
		mov dx, 0																							; During division, dx always has to be 0
		div word [bpbSectorsPerTrack]																		; Get the track
		add dl, 1																							; Add 1 to the track
		mov cl, dl																							; Save the track
		mov ax, bx																							; Restore the LBA number
																											;
		mov dx, 0																							; DX = 0 When division
		div word [bpbSectorsPerTrack]																		; Find the head
		mov dx, 0																							;
		div word [bpbHeadsPerCylinder]																		; Find the side
																											;
		mov dh, dl																							; Put the correct values in the registers
		mov ch, al																							;
																											;
		pop ax																								; Restore the registers
		pop bx																								;
																											;
		mov dl, byte [bsDriveNumber]																		; Save the drive number
																											;
		ret																									; Return to where we were called
																											;
	ResetFloppy:																							; The reset floppy routine
		pusha																								; Save all the registers
																											;
		mov al, 0																							; 0 = Reset Floppy
		mov dl, byte [bsDriveNumber]																		; The drive to reset
		int 13h																								; The interrupt to run
																											;
		popa																								; Restore the registers
		ret																									; Return to where we were called
																											;
	PrintString:																							; The print string routine
		pusha																								; Save the registers
		mov ah, 0Eh																							; 0Eh = Print Character
	NextChar:																								; Here, we loop through all the charachters
		lodsb																								; Load one charachter
		cmp al, 0																							; Is it 0?
		je DonePrinting																						; If so, we are done printing the string
		int 10h																								; Otherwise, print the charachter
		jmp NextChar																						; Go to the next charachter
	DonePrinting:																							; We land here when we are done printing
		popa																								; Restore all the registers
		ret																									; Return to where we were called
																											;
	;=======================================================================================================;
	;	The Main Bootloader Routine																			;
	;=======================================================================================================;
	LoadBrownieKernel:																						; We land here when we are booted
		cli																									; Setup the stack
		mov ax, 0																							;
		mov ss, ax																							;
		mov sp, 0xFFFF																						;
		sti																									;
																											;
		mov ax, 0x07C0																						; Setup the segments
		mov ds, ax																							;
		mov es, ax																							;
		mov fs, ax																							;
		mov gs, ax																							;
																											;
		mov [bsDriveNumber], dl																				; Save the drive number
																											;
		mov ax, 3																							; Set the video mode
		int 10h																								;
																											;
		mov si, InitMSG																						; Print the init message
		call PrintString																					;
																											;
	ReadRoot:																								; Here, we start loading the root
		mov ax, 19																							; Root Directory is located at logical sector 19
		call ConvertLBAtoCHS																				; Convert it to CHS
																											;
		mov bx, Buffer																						; Load it to the buffer
		mov ah, 2																							; 2 = Read sector
		mov al, 14																							; Root directory is 14 sectors]
																											;
		pusha																								; Prepare to enter the loop
	LoadRoot:																								; Start reading the root
		mov si, Progress																					; Print progress star
		call PrintString																					;
		popa																								; Make sure the registers are fully saved
		pusha																								;
																											;
		stc																									; The cf has to be set to read sectors
		int 13h																								; Try to read the sectors
																											;
		jnc LoadedRoot																						; If there is no cf, we have loaded the sector(s)
		call ResetFloppy																					; Otherwise, we will reset the floppy
		jmp LoadRoot																						; And, loop to try again
																											;
	LoadedRoot:																								; We land here when we have loaded the root
		popa																								; Restore the registers
																											;
		mov di, Buffer																						; Where we loaded the root
		mov cx, word [bpbRootDirEntries]																	; Loop through the number of times in the root directory
		mov ax, 0																							; Prepare to enter the loop
																											;
	NextEntry:																								; Here, we loop through all the entries
		mov si, Progress																					; Print the progress star
		call PrintString																					;
		xchg cx, dx																							; Save cx in dx - we will modify it
																											;
		mov si, KernelFilename																				; The kernel filename
		mov cx, 11																							; 11 chars in the filename
		rep cmpsb																							; Compare it to the entry
																											;
		je FoundKernel																						; If it is the same, it is the kernel
																											;
		add ax, 32																							; Each entry is 32 bytes
																											;
		mov di, Buffer																						; Calculate the location of the next entry
		add di, ax																							;
																											;
		xchg dx, cx																							; Restore the value in cx
		loop NextEntry																						; Keep looping
																											;
		mov si, KernelNotFoundMSG																			; If we land here, the kernel doesn't exist
		call PrintString																					;
																											;
		cli																									; Halt the system
		hlt																									;
																											;
	FoundKernel:																							; We land here when we have found the kernel
		mov ax, word [es:di + 0Fh]																			; Save the first cluster
		mov [Cluster], ax																					;
																											;
		mov ax, 1																							; FAT is located at logical sector 1
		call ConvertLBAtoCHS																				; Convert it to CHS
																											;
		mov bx, Buffer																						; Load it to the buffer
																											;
		mov ah, 2																							; 2 = Load the sector(s)
		mov al, 9																							; And 9 of them
																											;
		pusha																								; Prepare to enter a loop
																											;
	LoadFAT:																								; Read the FAT here in a loop
		mov si, Progress																					; Print the progress star
		call PrintString																					;
		popa																								; Restore the registers
		pusha																								; Make sure all the registers are saved
																											;
		stc																									; Set cf
		int 13h																								; Try to load the sectors
																											;
		jnc LoadedFAT																						; If no cf, we have loaded the FAT
		call ResetFloppy																					; Otherwise, reset the floppy
		jmp LoadFAT																							; And, load the FAT again
																											;
	LoadedFAT:																								; We land here when the FAT has been loaded correctly
		popa																								; Restore the registers
																											;
		mov ax, KernelSegment																				; Setup the segment to load the kernel to
		mov es, ax																							;
																											;
		mov bx, 0																							; Fill up the entire segment with the kernel
																											;
		mov ah, 2																							; Load one file sector
		mov al, 1																							; See, 1 sector
																											;
		push ax																								; Save the registers
																											;
	LoadFileSector:																							;
		mov si, Progress																					; Print the progress star
		call PrintString																					;
		mov ax, word [Cluster]																				;
		add ax, 31																							; Calculate the actual sector location
																											;
		call ConvertLBAtoCHS																				; Convert it to CHS
																											;
		mov bx, word [Pointer]																				; Load it to the pointer
																											;
		pop ax																								; Ensure ax is saved
		push ax																								;
																											;
		stc																									; Set cf
		int 13h																								; Try to load the sector
																											;
		jnc CalculateNextCluster																			; If no cf, calculate the next cluster, and load it
		call ResetFloppy																					; Otherwise, reset the floppy
		jmp LoadFileSector																					; And, try again
																											;
	CalculateNextCluster:																					; We calculate the next cluster here
		mov ax, [Cluster]																					; Get the cluster
		mov dx, 0																							; For division
		mov bx, 3																							; Get the next FAT entry
		mul bx																								;
																											;
		mov bx, 2																							;
		div bx																								;
																											;
		mov si, Buffer																						; Find the location of the next cluster
		add si, ax																							;
		mov ax, word [ds:si]																				; The cluster is here!
		or dx, dx																							; Empty dx
																											;
		jz even																								; If so, its even
																											;
	odd:																									; Otherwise, it is odd
		shr ax, 4																							; Shift it right 1 hex number
		jmp short NextClusterCont																			; And, continue to the next cluster
																											;
	even:																									; If it is even
		and ax, 0xFFF																						; Cross out the lower 12 bits - they belong to another entry
																											;
	NextClusterCont:																						; We are here to check if it is the end of the file
		mov word [Cluster], ax																				; Save the cluster
																											;
		cmp ax, 0xFF8																						; Is it above the eof marker?
		jae EnterKernel																						; If so, enter the kernel
																											;
		add word [Pointer], 512																				; Add one sector to the pointer
		jmp LoadFileSector																					; And, load the next sector
																											;
	EnterKernel:																							; Enter the Kernel!
		pop ax																								; Pop ax, it was saved earlier
																											;
		mov si, CRLF																						; Print a bunch of newlines for the person to identify the kernel from the bootloader
		call PrintString																					;
		jmp 0:8000h																							; Jump to the kernel!
																											;
		cli																									; Halt the system
		hlt																									;
																											;
	times 510-($-$$) db 0																					; Pad out the boot sector with 0'es
	dw 0xAA55																								; The standard pc boot signature
