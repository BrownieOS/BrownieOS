;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		CONFIG.INC - The BrownieOS configuration screen														;
;===========================================================================================================;
																											;
	;=======================================================================================================;
	;	Definitions and strings																				;
	;=======================================================================================================;
	WelcomeMSG						db	13, 10, 13, 10, "BrownieOS", 0										; Welcome message
	CopyrightMSG					db	13, 10, "(C) Copyright All BrownieOS Contributors", 0				; Copyright message
																											;
	;=======================================================================================================;
	;	ConfigBrownie																						;
	;		In:																								;
	;			Nothing																						;
	;		Out:																							;
	;			Nothing																						;
	;		The Brownie Configuration Screen																;
	;=======================================================================================================;
	ConfigBrownie:																							;
		mov si, WelcomeMSG																					; Print the welcome message
		call PrintString16																					;
																											;
		mov si, CopyrightMSG																				; Print the copyright message
		call PrintString16																					;
																											;
		ret																									; Return to the main kernel routines