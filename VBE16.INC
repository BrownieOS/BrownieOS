;===========================================================================================================;
;		BrownieOS																							;
;			(C) Copyright All BrownieOS Contributors														;
;			Licensed under the GPLv3 license - Read GPLv3.txt												;
;		VBE16.INC - The VBE 16-bit functions																;
;===========================================================================================================;
																											;
	;=======================================================================================================;
	;	VBE Info Block																						;
	;=======================================================================================================;
	VBEInfoBlock:																							;
		.Signature				db	"VBE2"																	; Signature
		.Version				dw	0																		; Version
		.OEM					dd	0																		; OEM
		.Capabilities			dd	0																		; Capabilities
		.VideoModes				dd	0																		; Video Modes
		.Memory					dw	0																		; Memory
		.SoftwareRevision		dw	0																		; Software Revision
		.Vendor					dd	0																		; Vendor
		.ProductName			dd	0																		; Product Name
		.ProductRev				dd	0																		; Product Revision
		.Reserved				times 222 db 0																; Reserved
		.OEMData				times 256 db 0																; OEM Data
		
	