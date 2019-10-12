asm {/* See $LK,"::/Doc/Boot.DD"$.
TempleOS starts in real, calls some BIOS
routines, switches to 32 bit, and 64 bit mode
and continues in $LK,"HolyC",A="FI:::/Doc/HolyC.DD"$ at $LK,"KMain",A="MN:KMain"$().

The boot loader jumps here in real-mode (16-bit).
It actually jumps to the $LK,"CBinFile",A="MN:CBinFile"$ header which is
placed just before this by $LK,"the compiler",A="FF:::/Compiler/CMain.HC,16 ALIGN"$.
The header begins with a short jmp to
the start of this file's code which begins
with the following small jump past some data.

This file is first in the Kernel image
because it is #included first.  $LK,"Kernel.PRJ",A="FF:::/Kernel/Kernel.PRJ,KStart16:1"$
*/
USE16
SYS_KERNEL:: //This must match $LK,"CKernel",A="MN:CKernel"$.
	JMP	I16 CORE0_16BIT_INIT

//************************************
//  ASM Global vars required for 16-bit start-up
	ALIGN	4,OC_NOP
SYS_BOOT_SRC::			DU32	BOOT_SRC_NULL;
SYS_BOOT_BLK::			DU32	0;
SYS_BOOT_PATCH_TABLE_BASE::	DU32	0;
SYS_RUN_LEVEL::			DU32	0;
#exe {StreamPrint("SYS_COMPILE_TIME:: DU64 0x%X;",Now);} //See $LK,"BootDVDProbe",A="MN:BootDVDProbe"$
#assert SYS_COMPILE_TIME+sizeof(CDate)+sizeof(CBinFile)<DVD_BLK_SIZE

MEM_BOOT_BASE::		DU32	0;	//Offset from start used by reboot
MEM_E801::		DU16	0,0;
MEM_E820::		DU8	MEM_E820_ENTRIES_NUM*sizeof(CMemE820) DUP (0);
MEM_PHYSICAL_SPACE::	DU64	0;
SYS_GDT_PTR::		DU16	sizeof(CGDT)-1;
			DU64	0;
SYS_PCI_BUSES::		DU16	0;

	ALIGN	16,OC_NOP
SYS_GDT:: //See $LK,"CGDT",A="MN:CGDT"$
GDT_NULL:	DU64	0,0;
GDT_BOOT_DS:	DU64	0x00CF92000000FFFF,0; //Gets patched.
GDT_BOOT_CS:	DU64	0x00CF9A000000FFFF,0; //Gets patched.
GDT_CS32:	DU64	0x00CF9A000000FFFF,0;
GDT_CS64:	DU64	0x00209A0000000000,0; //The $LK,"Charter",A="FI:::/Doc/Charter.DD"$ says just ring0.
GDT_CS64_RING3:	DU64	0x0020FA0000000000,0; //$LK,"Ring3",A="FI:::/Demo/Lectures/Ring3.HC"$, so you can play with.
GDT_DS:		DU64	0x00CF92000000FFFF,0;
GDT_DS_RING3:	DU64	0x00CFF2000000FFFF,0;
GDT_TR:		DU8	MP_PROCESSORS_NUM*16 DUP(0);
GDT_TR_RING3:	DU8	MP_PROCESSORS_NUM*16 DUP(0);
#assert $$-SYS_GDT==sizeof(CGDT)

#assert $$-SYS_KERNEL==sizeof(CKernel)-sizeof(CBinFile)

SYS_VESA::     DU8 256 DUP(0);
SYS_VESA_RES:  DU16   0;   
SYS_VESA_MODE: DU16   0;   
SYS_VESA_BFSZ: DU64   0;
#assert $$-SYS_VESA==sizeof(CVesaInfo)

//MODES_ARRY::    DU8 4960 DUP(0); // modes[20];
MODES_ARRY::    DU8 9920 DUP(0); // modes[40];

// should have an assert


SYS_SCRN_WIDTH:  DU16 1024;  // requested width
SYS_SCRN_HEIGHT: DU16 768;  // requested height
SYS_SCRN_BPP:    DU16 32;  // requested height
//SYS_SCRN_BPP:    DU16 8;  // requested height


//SYS_SCRN_WIDTH:  DU16 640;  // requested width
//SYS_SCRN_HEIGHT: DU16 480;  // requested height


SYS_VBE2::     
SYS_VBE2_DATA1: DU8 14 DUP(0);
SYS_VBE2_MODES: DU32;

SYS_VBE2_DATA: DU8 498 DUP(0);
SYS_VBE2_RES:  DU16   0;
//SYS_VBE2_MODE: DU16   0x4144; // <-- the the Graphics mode here
SYS_VBE2_MODE: DU16   0; // <-- the the Graphics mode here

// Virtual box
// 640x480x32   = 0x4142
// 800x600x32   = 0x4143
// 1024x768x32  = 0x4144
// 1280x1024x32 = 0x4145
// 1860x1050x32 = 0x4160 // custom vbox

#assert $$-SYS_VBE2==sizeof(CVBE2Info) // 516 

// capute the supported modes
VBE2_MODES:: DU16 50 DUP(0);     



//************************************
CORE0_16BIT_INIT::
//EAX is $LK,"SYS_BOOT_SRC",A="FF:::/Kernel/KStart16.HC,[SYS_BOOT_SRC]"$. (Val passed from boot blk, $LK,"BootHD",A="FF:::/Adam/Opt/Boot/BootHD.HC,BOOT_SRC_HARDDRV"$, $LK,"BootDVD",A="FF:::/Adam/Opt/Boot/BootDVD.HC,BOOT_SRC_DVD"$, & $LK,"BootRAM",A="FF:::/Adam/Opt/Boot/BootRAM.HC,BOOT_SRC_RAM"$.)
	MOV	ECX,EAX
	MOV	AX,(BOOT_RAM_LIMIT-BOOT_STK_SIZE)/16
	MOV	SS,AX
	MOV	SP,BOOT_STK_SIZE
	PUSH	ECX	//Will be $LK,"SYS_BOOT_SRC",A="FF:::/Kernel/KStart16.HC,[SYS_BOOT_SRC]"$. See $LK,"BootHD",A="FF:::/Adam/Opt/Boot/BootHD.HC,BOOT_SRC_HARDDRV"$, $LK,"BootDVD",A="FF:::/Adam/Opt/Boot/BootDVD.HC,BOOT_SRC_DVD"$ & $LK,"BootRAM",A="FF:::/Adam/Opt/Boot/BootRAM.HC,BOOT_SRC_RAM"$.
	PUSH	EBX

	CALL	U16 GET_RIP
GET_RIP:	POP	BX
	SUB	BX,GET_RIP
	SHR	BX,4
	MOV	AX,CS
	ADD	AX,BX
	PUSH	AX
	PUSH	U16 @@05
	RETF

@@05:	STI
	MOV	AX,CS
	MOV	DS,AX

	MOV	U32 [SYS_RUN_LEVEL],RLF_16BIT

// Get VBE2 info
        PUSH    ES
        PUSH    DS
        POP     ES
        MOV     AX,0x4F00
        MOV     DI,SYS_VBE2
                
        INT     0x10
         
        POP     ES
        MOV     [SYS_VBE2_RES],AX

//****************
// Fill the modes arry with supported modes
        PUSH    ES
        PUSH    DS
        POP     ES
        MOV     DI, MODES_ARRY
        MOV     BX, 40
        MOV     CX, 0x40FF
// array of U16 support modes    
@@06: // loop

        INC     CX 
        CMP     CX, 0x4300 // surely there are none past this?
        JE      @@07

        PUSH    CX
        PUSH    BX
        PUSH    DI

        MOV     AX, 0x4F01
        INT     0x10

        POP     DI
        POP     BX
        POP     CX

	CMP	AX,0x004F
	JNE	@@06		// don't add to list


// filter 24 bit
        MOV     AL, 24  
        CMP     [DI+25], AL   
	JE	@@06
// filter 15 bit
        MOV     AL, 15  
        CMP     [DI+25], AL   
	JE	@@06
            


// check for our requested mode
        MOV     AL, [SYS_SCRN_BPP]  
        CMP     [DI+25], AL   
	JNE	@@06A

        MOV     AX, [SYS_SCRN_WIDTH]
        CMP     [DI+18], AX    
        JNE     @@06A

        MOV     AX, [SYS_SCRN_HEIGHT]
        CMP     [DI+20], AX    
        JNE     @@06A
// were here because the width & height match
        MOV     U16 [SYS_VBE2_MODE], CX
@@06A:
        ADD     DI,256
	MOV	AX,0x004F
        MOV     [DI],AX
        MOV     [DI+2],CX
        ADD     DI,12


        DEC     BX
        JNZ     @@06
@@07:
// copy to an array of 50
        POP     ES

//********************

// get Vesa info
        PUSH    ES
        PUSH    DS
        POP     ES

        MOV     CX, [SYS_VBE2_MODE]
        MOV     [SYS_VESA_MODE], CX
        MOV     AX, 0x4F01
        MOV     DI, SYS_VESA
        INT     0x10
   
        POP     ES

        CMP     AX,0x004F

// Set Mode
	MOV	AX,0x4F02
	MOV	BX,[SYS_VBE2_MODE]

        CMP     BX, 0
        JE      @@10



//	MOV	BX,0x12		//640x480 16 color
#exe {
  if (!kernel_cfg->opts[CFG_TEXT_MODE])
    StreamPrint("INT 0x10");	//Enable VGA
};
        MOV     [SYS_VESA_RES], AX
	CMP	AX,0x004F
	JNE	@@10		//Jmp if fail
	BTS	U32 [SYS_RUN_LEVEL],RLf_24BIT_GRP
	BTS	U32 [SYS_RUN_LEVEL],RLf_VGA
@@10:

//Get mem maps.
	MOV	AX,0xE801
	INT	0x15
	MOV	U16 [MEM_E801],CX
	MOV	U16 [MEM_E801+2],DX

	MOV	CX,MEM_E820_ENTRIES_NUM-1 //Leave one to terminate
	XOR	EBX,EBX
	MOV	AX,DS
	MOV	ES,AX
	MOV	DI,MEM_E820
@@15:	PUSH	CX
	MOV	EAX,0xE820
	MOV	ECX,sizeof(CMemE820)
	MOV	EDX,'PAMS'
	INT	0x15
	JC	@@20
	CMP	EAX,'PAMS'
	JNE	@@20
	TEST	EBX,EBX
	JZ	@@20
	ADD	DI,sizeof(CMemE820)
	POP	CX
	LOOP	@@15
	SUB	SP,2
@@20:	ADD	SP,2

//Find how much space to map, start with E801 limit.
	XOR	EAX,EAX
	MOV	AX,[MEM_E801+2]
	SHL	EAX,16
	ADD	EAX,SYS_16MEG_AREA_LIMIT
	XOR	EDX,EDX

//Find max of E820 to set mapped space.
	MOV	SI,MEM_E820
@@25:	MOV	CL,CMemE820.type[SI]
	TEST	CL,CL
	JZ	@@35
	MOV	EBX,CMemE820.base[SI]
	MOV	ECX,CMemE820.base+4[SI]
	ADD	EBX,CMemE820.len[SI]
	ADC	ECX,CMemE820.len+4[SI]
	SUB	EBX,EAX
	SBB	ECX,EDX
	JC	@@30
	MOV	EAX,CMemE820.base[SI]
	MOV	EDX,CMemE820.base+4[SI]
	ADD	EAX,CMemE820.len[SI]
	ADC	EDX,CMemE820.len+4[SI]
@@30:	ADD	SI,sizeof(CMemE820)
	JMP	@@25

@@35:	MOV	[MEM_PHYSICAL_SPACE],EAX
	MOV	[MEM_PHYSICAL_SPACE+4],EDX
	
//Get PCI Bus Info
	MOV	U16 [SYS_PCI_BUSES],256
	XOR	DX,DX
	MOV	AX,0xB101
	INT	0x1A
	CMP	DX,'PC'
	JNE	@@40
	MOV	CH,0
	INC	CX
	MOV	U16 [SYS_PCI_BUSES],CX
@@40:
	CLI
//Enable A20
	IN	AL,0x92
	OR	AL,2
	OUT	0x92,AL

	POP	U32 [SYS_BOOT_BLK]
	POP	U32 [SYS_BOOT_SRC]	//See $LK,"BootHD",A="FF:::/Adam/Opt/Boot/BootHD.HC,BOOT_SRC_HARDDRV"$, $LK,"BootDVD",A="FF:::/Adam/Opt/Boot/BootDVD.HC,BOOT_SRC_DVD"$, & $LK,"BootRAM",A="FF:::/Adam/Opt/Boot/BootRAM.HC,BOOT_SRC_RAM"$.

	CLD
	XOR	EAX,EAX
	MOV	AX,CS
	MOV	DS,AX
	MOV	ES,AX
	SHL	EAX,4

	MOV	U32 [MEM_BOOT_BASE],EAX

	MOV	DX,CS
	SUB	DX,sizeof(CBinFile)/16
#assert !(sizeof(CBinFile)&15)
	MOV	GS,DX

	MOV	EDX,EAX
	ADD	EDX,U32 GS:[CBinFile.patch_table_offset]
	SUB	EDX,sizeof(CBinFile)
	MOV	U32 [SYS_BOOT_PATCH_TABLE_BASE],EDX

	ADD	U32 [GDT_BOOT_DS+2],EAX
	ADD	U32 [GDT_BOOT_CS+2],EAX
	ADD	EAX,I32 SYS_GDT
	MOV	U32 [SYS_GDT_PTR+CSysLimitBase.base],EAX
	LGDT	U32 [SYS_GDT_PTR]

	MOV	EAX,SYS_START_CR0
	MOV_CR0_EAX

/* The assembler doesn't support far jumps so
we hand code it.  16-bit code is not important
enough to fully implement in the assembler.

To complete the switch to 32-bit mode, we have to load
the code segment with a far jump.
*/
	DU8	0x66,0xEA; //JMP CGDT.boot_cs:CORE0_32BIT_INIT
	DU32	CORE0_32BIT_INIT;
	DU16	CGDT.boot_cs;
#assert $$+16<=0xFFFF
}
