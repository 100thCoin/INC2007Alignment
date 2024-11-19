
	
	
	;;;; HEADER AND COMPILER STUFF ;;;;
	.inesprg 1  ; 2 banks
	.ineschr 1  ; 
	.inesmap 0  ; mapper 0 = NROM
	.inesmir 1  ; background mirroring, vertical

	;;;; CONSTANTS ;;;;

TestNumber = $10
TestCaseNo = $11
TestBuffer = $12
TestAddrHI = $13
TestAddrLO = $14
TestExpect = $15
TestResult = $16
TestAddrHI1 = $17
TestResult1 = $18
TestExpect1 = $19


TestResults = $10
ClearScreenAttributeMode = $FF

	;;;; ASSEMBLY CODE ;;;;
	.org $8000
	
	;;;;;;;;;;;;;;;;
	; Begin Test 1 ;
	;;;;;;;;;;;;;;;;
BeginTest1:
	;JMP PassTest2

	; TEST 1 :
	; Does INC $2007 perform "the mystery write"
	;	- Buffer holds 55, VRAM Address = $2110. INC $2007. Result: Vram $2156 = $56
	;	- Buffer holds 7F, VRAM Address = $2000. INC $2007. Result: Vram $2080 = $80
	;	- Buffer holds 00, VRAM Address = $2F7F. INC $2007. Result: Vram $2F01 = $01
	;	- Buffer holds FF, VRAM Address = $2222. INC $2007. Result: Vram $2200 = $00

	LDA #1
	PHA
	STA <TestNumber
	STA <TestCaseNo
	LDA #$55
	STA <TestBuffer
	LDA #$21
	STA <TestAddrHI
	LDA #$10
	STA <TestAddrLO
	LDA #$56
	STA <TestExpect	
		
	JSR RunTest1
	
	; CASE 2
	
	LDA #$02
	STA <TestCaseNo
	LDA #$7F
	STA <TestBuffer
	LDA #$20
	STA <TestAddrHI
	LDA #$00
	STA <TestAddrLO
	LDA #$80
	STA <TestExpect
		
	JSR RunTest1
	
	LDA #$03
	STA <TestCaseNo
	LDA #$00
	STA <TestBuffer
	LDA #$2F
	STA <TestAddrHI
	LDA #$7F
	STA <TestAddrLO
	LDA #$01
	STA <TestExpect
		
	JSR RunTest1
	
	LDA #$04
	STA <TestCaseNo
	LDA #$FF
	STA <TestBuffer
	LDA #$22
	STA <TestAddrHI
	STA <TestAddrLO
	LDA #$00
	STA <TestExpect
		
	JSR RunTest1
		
	; If all of those pass, it's safe to say you got it!
		
	JMP PassTest1
		
		
RunTest1:
	
	JSR ClearVRAM
	LDA $2002
Test1VBL:
	LDA $2002
	BPL Test1VBL
	; Case 4 overwrites $2200 with a 0, so let's initialize that byte
	LDX #$22
	LDY #$00
	JSR SetAddressToXY ; VRAM Address = $2200
	LDA #0
	STA $2007
	; now run the test	
	LDX <TestBuffer		; Prep Buffer with desired buffer
	JSR PrepBufferWithX
	LDX <TestAddrHI
	LDY <TestAddrLO
	JSR SetAddressToXY ; VRAM Address = whatever the test calls for	
	INC $2007
	LDX <TestAddrHI
	LDY <TestExpect
	JSR ReadFromAddressXXYY ; read from "mystery address"	
	STA <TestResult
	CMP <TestExpect
	; If the value read was not what was expected, the test has failed.
	BNE FailTest	
	; If we make it this far, we pass the test!
	RTS
	
FailTest:
	PLA
	PLA
	JMP TestsFailed

PassTest1:
	; reset VRAM for next test.
	JSR ClearVRAM
	
	; TEST 2 :
	; Does "the mystery write" go on the correct page if a page boundry is crossed?
	;	- Buffer holds 55, VRAM Address = $21FF. INC $2007. Result: Vram $2256 = $56
	;	- Buffer holds 7F, VRAM Address = $1FFF. INC $2007. Result: Vram $2080 = $80

	LDA #2
	PHA
	STA <TestNumber
	LDA #1
	STA <TestCaseNo
	LDA #$55
	STA <TestBuffer
	LDA #$21
	STA <TestAddrHI
	LDA #$22
	STA <TestAddrHI1
	LDA #$FF
	STA <TestAddrLO
	LDA #$56
	STA <TestExpect	
		
	JSR RunTest2
	
	LDA #2
	STA <TestCaseNo
	LDA #$55
	STA <TestBuffer
	LDA #$21
	STA <TestAddrHI
	LDA #$22
	STA <TestAddrHI1
	LDA #$FF
	STA <TestAddrLO
	LDA #$56
	STA <TestExpect	
		
	JSR RunTest2
	
	JMP PassTest2
	
	
RunTest2:
	
	JSR ClearVRAM
	LDA $2002
Test2VBL:
	LDA $2002
	BPL Test2VBL

	LDX <TestBuffer		; Prep Buffer with desired buffer
	JSR PrepBufferWithX
	LDX <TestAddrHI
	LDY <TestAddrLO
	JSR SetAddressToXY ; VRAM Address = whatever the test calls for	
	INC $2007
	LDX <TestAddrHI1
	LDY <TestExpect
	JSR ReadFromAddressXXYY ; read from "mystery address"	
	STA <TestResult
	CMP <TestExpect
	; If the value read was not what was expected, the test has failed.
	BNE FailTest2	
	; If we make it this far, we pass the test!
	RTS
	
FailTest2:
	PLA
	PLA
	JMP TestsFailed
	
PassTest2:
	; reset VRAM for next test.
	JSR ClearVRAM
	
	; TEST 3 :
	; Does "the mystery write" go "through" palette VRAM?
	;	- Buffer holds 04, VRAM Address = $3F00. INC $2007. Result: Vram $2F05 = $05 (test with 2F05 due to NT mirroring)
	;	- Buffer holds 20, VRAM Address = $3F14. INC $2007. Result: Vram $2F11 = $11

	LDA #3
	PHA
	STA <TestNumber
	LDA #1
	STA <TestCaseNo
	LDA #$04
	STA <TestBuffer
	LDA #$3F
	STA <TestAddrHI
	LDA #$2F
	STA <TestAddrHI1
	LDA #$00
	STA <TestAddrLO
	LDA #$05
	STA <TestExpect	
	LDA #0
	STA <TestExpect1
	
	JSR RunTest3
	
	LDA #2
	STA <TestCaseNo
	LDA #$10
	STA <TestBuffer
	LDA #$3F
	STA <TestAddrHI
	LDA #$2F
	STA <TestAddrHI1
	LDA #$14
	STA <TestAddrLO
	LDA #$11
	STA <TestExpect	
	LDA #$0F
	STA <TestExpect1
		
	JSR RunTest3
	
	JMP PassTest3
	
RunTest3:	
	JSR ClearVRAM
	LDA $2002
Test3VBL:
	LDA $2002
	BPL Test3VBL

	LDX <TestBuffer		; Prep Buffer with desired buffer
	JSR PrepBufferWithX
	LDX <TestAddrHI
	LDY <TestAddrLO
	JSR SetAddressToXY ; VRAM Address = whatever the test calls for	
	INC $2007
	LDX <TestAddrHI1
	LDY <TestExpect
	JSR ReadFromAddressXXYY ; read from "mystery address"	
	STA <TestResult
	; read from palette
	LDX <TestAddrHI
	LDY <TestExpect
	JSR SetAddressToXY ; VRAM Address = whatever the test calls for	
	LDA $2007
	STA <TestResult1

	CMP #00
	; If the value read was not what was expected, the test has failed.
	BNE FailTest3	
	; If we make it this far, we pass the test!
	RTS
	
FailTest3:
	PLA
	PLA
	JMP TestsFailed
	
	
	
	
	
PassTest3:
	; reset VRAM for next test.
	JSR ClearVRAM
	
	
	JMP TestsPass
	; placeholder for debugging.

	














TestsFailed:

	; print an error message
	JSR ResetVRAMWith24

	LDX #$20
	LDY #$89
	JSR SetAddressToXY
	LDA #LOW(MSG_FAILED)
	STA $0
	LDA #HIGH(MSG_FAILED)
	STA $1
	JSR PrintMessage
	PLA ; grab the test number
	STA $2007
	JSR JumpTable

	.word PrintErrorTest1 ; test 0 isn't real.
	.word PrintErrorTest1
	.word PrintErrorTest2
	.word PrintErrorTest3

ErrorTest1MessageList:
	.byte 23
	.word MSG_Test1Fail_ln1
	.word MSG_Test1Fail_ln13
	.word MSG_Test1Fail_ln14
	.word MSG_Test1Fail_ln15
	.word MSG_Test1Fail_ln16
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln12
	.word MSG_Test1Fail_ln17
	.word MSG_Test1Fail_ln18
	.word MST_LineBrk
	.word MSG_Test1Fail_ln2
	.word MSG_Test1Fail_ln3
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln4
	.word MSG_Test1Fail_ln5
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln6
	.word MSG_Test1Fail_ln7
	.word MSG_Test1Fail_ln8
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln9
	.word MSG_Test1Fail_ln10
	.word MSG_Test1Fail_ln11

PrintErrorTest1:

	LDA #LOW(ErrorTest1MessageList)
	STA <$3
	LDA #HIGH(ErrorTest1MessageList)
	STA <$4
	LDX #$20
	LDY #$C1
	JSR PrintMessageList
	
	LDX #$20
	LDY #$F3
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	
	LDX #$21
	LDY #$0C
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestAddrLO
	JSR PrintA
	
	LDX #$21
	LDY #$21
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	LDX #$21
	LDY #$2A
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA

	LDX #$21
	LDY #$47
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	LDX #$21
	LDY #$4E
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	
	LDX #$21
	LDY #$B0
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	LDX #$21
	LDY #$B6
	JSR SetAddressToXY
	LDA <TestResult
	JSR PrintA
	
	LDX #$21
	LDY #$D2
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	JMP PostErrorPrint
	
	
ErrorTest2MessageList:
	.byte 19
	.word MSG_Test1Fail_ln1
	.word MSG_Test2Fail_Ln1
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln13
	.word MSG_Test1Fail_ln14
	.word MST_Test2Fail_Ln2
	.word MSG_Test1Fail_ln15
	.word MSG_Test1Fail_ln16
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln12
	.word MSG_Test1Fail_ln17
	.word MSG_Test1Fail_ln18
	.word MSG_EMPTY
	.word MST_LineBrk
	.word MSG_EMPTY
	.word MST_Test2Fail_Ln3
	.word MST_Test2Fail_Ln4
	.word MST_Test2Fail_Ln5
	.word MST_Test2Fail_Ln6

	
PrintErrorTest2:

	LDA #LOW(ErrorTest2MessageList)
	STA <$3
	LDA #HIGH(ErrorTest2MessageList)
	STA <$4
	LDX #$20
	LDY #$C1
	JSR PrintMessageList

	LDX #$21
	LDY #$33
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	
	LDX #$21
	LDY #$4C
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestAddrLO
	JSR PrintA
	
	LDX #$21
	LDY #$62
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestAddrLO
	JSR PrintA
	LDX #$21
	LDY #$6E
	JSR SetAddressToXY
	LDA <TestAddrHI1
	JSR PrintA
	LDA #0
	JSR PrintA
	
	
	
	
	LDX #$21
	LDY #$81
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	LDX #$21
	LDY #$8A
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA

	LDX #$21
	LDY #$A7
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	LDX #$21
	LDY #$AE
	JSR SetAddressToXY
	LDA <TestAddrHI1
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	
	LDX #$22
	LDY #$10
	JSR SetAddressToXY
	LDA <TestAddrHI1
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	LDX #$22
	LDY #$16
	JSR SetAddressToXY
	LDA <TestResult
	JSR PrintA
	
	LDX #$22
	LDY #$32
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	JMP PostErrorPrint



ErrorTest3MessageList:
	.byte 22
	.word MSG_Test1Fail_ln1
	.word MSG_Test3Fail_Ln1
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln13
	.word MSG_Test1Fail_ln14
	.word MSG_Test1Fail_ln15
	.word MSG_Test1Fail_ln16
	.word MSG_EMPTY
	.word MSG_Test1Fail_ln12
	.word MSG_Test1Fail_ln17
	.word MSG_Test1Fail_ln18
	.word MSG_Test1Fail_ln17
	.word MSG_Test1Fail_ln18
	.word MSG_EMPTY
	.word MST_LineBrk
	.word MSG_EMPTY
	.word MSG_Test3Fail_Ln2
	.word MSG_Test3Fail_Ln3
	.word MSG_EMPTY
	.word MSG_Test3Fail_Ln4
	.word MSG_Test3Fail_Ln5
	.word MSG_Test3Fail_Ln6


PrintErrorTest3:

	LDA #LOW(ErrorTest3MessageList)
	STA <$3
	LDA #HIGH(ErrorTest3MessageList)
	STA <$4
	LDX #$20
	LDY #$C1
	JSR PrintMessageList

	LDX #$21
	LDY #$33
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	
	LDX #$21
	LDY #$4C
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestAddrLO
	JSR PrintA	
	
	LDX #$21
	LDY #$61
	JSR SetAddressToXY
	LDA <TestBuffer
	JSR PrintA
	LDX #$21
	LDY #$6A
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA

	LDX #$21
	LDY #$87
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	LDX #$21
	LDY #$8E
	JSR SetAddressToXY
	LDA <TestAddrHI1
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	
	LDX #$21
	LDY #$F0
	JSR SetAddressToXY
	LDA <TestAddrHI1
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	LDX #$21
	LDY #$F6
	JSR SetAddressToXY
	LDA <TestResult
	JSR PrintA
	
	LDX #$22
	LDY #$12
	JSR SetAddressToXY
	LDA <TestExpect
	JSR PrintA
	
	LDX #$22
	LDY #$30
	JSR SetAddressToXY
	LDA <TestAddrHI
	JSR PrintA
	LDA <TestExpect
	JSR PrintA
	LDX #$22
	LDY #$36
	JSR SetAddressToXY
	LDA <TestResult1
	JSR PrintA
	
	LDX #$22
	LDY #$52
	JSR SetAddressToXY
	LDA <TestExpect1
	JSR PrintA
	JMP PostErrorPrint

PostErrorPrint:

	JMP PrepareFinalScreen
	
TestsPass:

	; print "PASS"
	JSR ResetVRAMWith24

	LDX #$21
	LDY #$2E
	JSR SetAddressToXY
	LDA #LOW(MSG_PASS)
	STA $0
	LDA #HIGH(MSG_PASS)
	STA $1
	JSR PrintMessage
	
	JMP PrepareFinalScreen

PrepareFinalScreen:

	LDA $2002
PrepFinalScreen1FrameDelay
	LDA $2002
	BPL PrepFinalScreen1FrameDelay

	; use correct tiles and enable NMI
	LDA #$80
	STA $2000
	; enable background.
	LDA #$08
	STA $2001
	
	LDX #$20
	LDY #$00
	JSR SetAddressToXY ; set to 2000	

InfiniteLoop;
	JMP InfiniteLoop
	; an infinite loop for spinning. Wait for NMI here.




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



DefaultPalette:
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $20, $0
	.byte $0F, $0, $20, $2D
	.byte $0F, $0F, $0F, $0F
	
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	.byte $0F, $0, $10, $20
	
AttributeTablePattern:
	.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
	.byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55

_0 = $00
_1 = $01
_2 = $02
_3 = $03
_4 = $04
_5 = $05
_6 = $06
_7 = $07
_8 = $08
_9 = $09
_A = $0A
_B = $0B
_C = $0C
_D = $0D
_E = $0E
_F = $0F
_G = $10
_H = $11
_I = $12
_J = $13
_K = $14
_L = $15
_M = $16
_N = $17
_O = $18
_P = $19
_Q = $1A
_R = $1B
_S = $1C
_T = $1D
_U = $1E
_V = $1F
_W = $20
_X = $21
_Y = $22
_Z = $23
__ = $24  ; space
_. = $25  ; period
_xm = $26 ; exclamation mark
_qm = $27 ; question mark
_sc = $28 ; semicolon
_pl = $30 ; +
_mi = $31 ; -
_mu = $32 ; *
_di = $33 ; /
_eq = $34 ; =
_hx = $35 ; $



MSG_PASS:
	.byte 4, _P, _A, _S, _S
	
MSG_FAILED:
	.byte 12, _F, _A, _I, _L, _E, _D, __, _T, _E, _S, _T, __
	
MSG_EMPTY: ; used for empty lines when printing a list of messages
	.byte 1, __

MST_LineBrk:
	.byte	 28, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi, _mi

	


;INC $2007
;
;The value read from the ppu
;read buffer is incremented.
;
;This new value is stored at
;an unexpected VRAM address.
;
;The high byte of this write
;is the high byte of the ppu
;read write address.
;
;The low byte of this write
;is equal to the value being
;written.
;
;
;Example:
;PPU read buffer = 55
;PPUADDR = $2000
;55 + 1 = 56
;Store 56 at $2056
MSG_Test1Fail_ln1:  
	.byte	 19, _T, _H, _E, __, _T, _E, _S, _T, _sc, __, _I, _N, _C, __, _hx, _2, _0, _0, _7
MSG_Test1Fail_ln2:  
	.byte	 27, _T, _H, _E, __, _V, _A, _L, _U, _E, __, _R, _E, _A, _D, __, _F, _R, _O, _M, __, _T, _H, _E, __, _P, _P, _U
MSG_Test1Fail_ln3:
	.byte	 27, _R, _E, _A, _D, __, _B, _U, _F, _F, _E, _R, __, _I, _S, __, _I, _N, _C, _R, _E, _M, _E, _N, _T, _E, _D, _.
MSG_Test1Fail_ln4:  
	.byte	 27, _T, _H, _I, _S, __, _N, _E, _W, __, _V, _A, _L, _U, _E, __, _I, _S, __, _S, _T, _O, _R, _E, _D, __, _A, _T
MSG_Test1Fail_ln5:  
	.byte	 27, _A, _N, __, _U, _N, _E, _X, _P, _E, _C, _T, _E, _D, __, _V, _R, _A, _M, __, _A, _D, _D, _R, _E, _S, _S, _.
MSG_Test1Fail_ln6:  
	.byte	 27, _T, _H, _E, __, _H, _I, _G, _H, __, _B, _Y, _T, _E, __, _O, _F, __, _T, _H, _I, _S, __, _W, _R, _I, _T, _E
MSG_Test1Fail_ln7:  
	.byte	 27, _I, _S, __, _T, _H, _E, __, _H, _I, _G, _H, __, _B, _Y, _T, _E, __, _O, _F, __, _T, _H, _E, __, _P, _P, _U
MSG_Test1Fail_ln8:  
	.byte	 19, _R, _E, _A, _D, __, _W, _R, _I, _T, _E, __, _A, _D, _D, _R, _E, _S, _S, _.
MSG_Test1Fail_ln9:  
	.byte	 26, _T, _H, _E, __, _L, _O, _W, __, _B, _Y, _T, _E, __, _O, _F, __, _T, _H, _I, _S, __, _W, _R, _I, _T, _E
MSG_Test1Fail_ln10:  
	.byte	 27, _I, _S, __, _E, _Q, _U, _A, _L, __, _T, _O, __, _T, _H, _E, __, _V, _A, _L, _U, _E, __, _B, _E, _I, _N, _G
MSG_Test1Fail_ln11:  
	.byte	 8, _W, _R, _I, _T, _T, _E, _N, _.
MSG_Test1Fail_ln12:  
	.byte	 12, _W, _H, _A, _T, __, _F, _A, _I, _L, _E, _D, _qm
MSG_Test1Fail_ln13:  
	.byte	 17, _P, _P, _U, __, _R, _E, _A, _D, __, _B, _U, _F, _F, _E, _R, __, _eq
MSG_Test1Fail_ln14:  
	.byte	 11, _P, _P, _U, _A, _D, _D, _R, __, _eq, __, _hx
MSG_Test1Fail_ln15: 
	.byte	 8, __, __, __, _pl, __, _1, __, _eq
MSG_Test1Fail_ln16:  
	.byte	 13, _S, _T, _O, _R, _E, __, __, __, __, _A, _T, __, _hx
MSG_Test1Fail_ln17:  
	.byte	 20, _V, _A, _L, _U, _E, __, _R, _E, _A, _D, __, _A, _T, __, _hx, __, __, __, __, _sc
MSG_Test1Fail_ln18:  
	.byte	 16, _E, _X, _P, _E, _C, _T, _E, _D, __, _T, _O, __, _R, _E, _A, _D
	
	
	
	
;If PPUADDR crosses a page
;boundary during the INC
;the extra write uses the
;the new value of PPUADDR HI
MSG_Test2Fail_Ln1:
	.byte	 27, _P, _P, _U, _A, _D, _D, _R, __, _C, _R, _O, _S, _S, __, _P, _A, _G, _E, __, _B, _O, _U, _N, _D, _A, _R, _Y
MST_Test2Fail_Ln2:
	.byte	 13, _hx, __, __, __, __, __, _pl, __, _1, __, _eq, __, _hx
MST_Test2Fail_Ln3:
	.byte	 25, _I, _F, __, _P, _P, _U, _A, _D, _D, _R, __, _C, _R, _O, _S, _S, _E, _S, __, _A, __, _P, _A, _G, _E
MST_Test2Fail_Ln4:
	.byte	 23, _B, _O, _U, _N, _D, _A, _R, _Y, __, _D, _U, _R, _I, _N, _G, __, _T, _H, _E, __, _I, _N, _C
MST_Test2Fail_Ln5:
	.byte	 24, _T, _H, _E, __, _E, _X, _T, _R, _A, __, _W, _R, _I, _T, _E, __, _U, _S, _E, _S, __, _T, _H, _E
MST_Test2Fail_Ln6:
	.byte	 27, _T, _H, _E, __, _N, _E, _W, __, _V, _A, _L, _U, _E, __, _O, _F, __, _P, _P, _U, _A, _D, _D, _R, __, _H, _I

	
	
;The extra write cannot
;update the color palettes

;The extra write can be 
;seen at a mirror of
;address $3F00, at $2F00
	

MSG_Test3Fail_Ln1:
	.byte	 25, _P, _P, _U, _A, _D, _D, _R, __, _I, _N, __, _C, _O, _L, _O, _R, __, _P, _A, _L, _E, _T, _T, _E, _S
MSG_Test3Fail_Ln2:
	.byte	 22, _T, _H, _E, __, _E, _X, _T, _R, _A, __, _W, _R, _I, _T, _E, __, _C, _A, _N, _N, _O, _T
MSG_Test3Fail_Ln3:
	.byte	 25, _U, _P, _D, _A, _T, _E, __, _T, _H, _E, __, _C, _O, _L, _O, _R, __, _P, _A, _L, _E, _T, _T, _E, _S
MSG_Test3Fail_Ln4:
	.byte	 23, _T, _H, _E, __, _E, _X, _T, _R, _A, __, _W, _R, _I, _T, _E, __, _C, _A, _N, __, _B, _E, __
MSG_Test3Fail_Ln5:
	.byte	 19, _S, _E, _E, _N, __, _A, _T, __, _A, __, _M, _I, _R, _R, _O, _R, __, _O, _F
MSG_Test3Fail_Ln6:
	.byte	 22, _A, _D, _D, _R, _E, _S, _S, __, _hx, _3, _F, _0, _0, __, _A, _T, __, _hx, _2, _F, _0, _0
	
	
	
	
	
	
	
	
	
MSG_ASM_1:
	.byte	13, _P, _P, _U, _A, _D, _D, _R, _sc, __, _2, _1, _1, _0
MSG_ASM_B:
	.byte	15, _R, _E, _A, _D, __, _B, _U, _F, _F, _E, _R, _sc, __, _5, _5

MSG_ASM_2:
	.byte	 9, _I, _N, _C, __, _2, _0, _0, _7, _sc
MSG_ASM_3:
	.byte	11, _I, _N, _C, __, _2, _0, _0, _7, __, _X, _sc

MSG_ASM_2111:
	.byte	6, _2, _1, _1, _1, _sc, __
MSG_ASM_2112:
	.byte	6, _2, _1, _1, _2, _sc, __
MSG_ASM_2113:
	.byte	6, _2, _1, _1, _3, _sc, __
MSG_ASM_2156:
	.byte	6, _2, _1, _5, _6, _sc, __
MSG_ASM_2101:
	.byte	6, _2, _1, _0, _1, _sc, __
	
MSG_PHASE:
	.byte	6, _P, _H, _A, _S, _E, __

MSG_ASM_21xx:
	.byte	2, _2, _1

MSG_ASM_NO_WRITE:
	.byte	2, _X, _X




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; EXAMPLE

	;LDX #$23
	;LDY #$28
	;JSR SetAddressToXY
	;LDA #LOW(MSG_PHASE)
	;STA $0
	;LDA #HIGH(MSG_PHASE)
	;STA $1
	;JSR PrintMessage

PrintMessage:
	LDY #0
	; the first byte is the length
	LDA [$0], Y
	STA <$2
	LDX #0
	INY
PrintLoop:
	; load the next byte of the message
	LDA [$0], Y
	; store to nametable
	STA $2007
	; Inc X and Y
	INY
	INX
	; if X = length, exit loop
	CPX <$2
	BNE PrintLoop
	; return
	RTS



PrintMessageList:
	;XXYY will be the VRAM address
	STX <$80
	STY <$81
	JSR SetAddressToXY
	LDY #0
	; the first byte is the length
	LDA [$3], Y
	STA <$5
	ASL <$5	; multiply by 2
	INC <$5	; add 1
	INY
MessageListLoop:
	; load the next message
	LDA [$3], Y	; grab low byte from table
	STA $0		; store at 0 (location used in PrintMessage)
	INY			; y++
	LDA [$3], Y ; grab high byte from table
	STA $1      ; store at 1 (location used in PrintMessage)
	INY			; y++
	TYA
	PHA			; push Y to stack
	LDX <$80
	LDY <$81
	JSR SetAddressToXY
	JSR PrintMessage
	PLA			; pull Y from stack
	TAY
	; Add $20 to the VRAM address
	LDA <$81
	CLC
	ADC #$20
	STA <$81
	LDA <$80
	ADC #0
	STA <$80	
	; Check if the list is complete
	CPY <$5
	BNE MessageListLoop
	RTS

PrintA:
	PHA
	AND #$F0	; seperate the left nybble
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007	; store that on the nametable
	PLA			; grab the same byte
	AND #$0F	; seperate the right nybble
	STA $2007	; store that on the nametable
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadFromAddressXXYY:
	JSR SetAddressToXY
	; read garbage
	LDA $2007
	; read from buffer
	LDA $2007
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetAddressToXY:
	; store X then Y to address $2006 to set the VRAM Address.
	; this helps make my code a bit denser
	
	; reset the latch
	BIT $2002
	; store X and Y to $2006
	STX $2006
	STY $2006
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ResetVRAM:
	; store a 0 in every byte from VRAM $2000 to $2FFF

	LDA #0
	STA <ClearScreenAttributeMode

	; reset the latch
	BIT $2002
	; set VRAM Address to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	; set every byte to 0
	LDX #$10
	LDY #$00
ResetVRAMLoop:
	; store 0 in VRAM
	STA $2007	
	; loop 0x1000 times
	DEY
	BNE ResetVRAMLoop
	DEX 
	BNE ResetVRAMLoop 
	; return
	
	LDA ClearScreenAttributeMode
	BNE AttributesFor24
	
	JSR SetUpAttributesFor1SecondRender
	JMP ResetVRAMRTS
AttributesFor24:
	JSR SetUpAttributesForPassFail
ResetVRAMRTS:	
	RTS	
	
	
ClearVRAM:
	; reset the latch
	BIT $2002
	; set VRAM Address to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	; set every byte to 0
	LDX #$10
	LDY #$00
ClearVRAMLoop:
	; store 0 in VRAM
	STA $2007	
	; loop 0x1000 times
	DEY
	BNE ClearVRAMLoop
	DEX 
	BNE ClearVRAMLoop 
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
SetUpAttributesFor1SecondRender:
	; set up the attributes to highlight where the test is happening.

	; reset the latch
	BIT $2002
	; set VRAM Address to $223F8
	LDA #$23
	STA $2006
	LDA #$F8
	STA $2006

	; Use palette 3 for all tiles here
	LDA #$FF

	; set the bottom of the screen to palette 3 (black)
	STA $2007	
	STA $2007	
	STA $2007	
	STA $2007	
	STA $2007	
	STA $2007	
	STA $2007	
	STA $2007	

	; for VRAM $2000 to $20FF, let's use an alternating pattern of dark grey and darker grey.
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006

	LDA #$99
	LDY #16
AttributePreRenderLoop:
	STA $2007
	DEY
	BNE AttributePreRenderLoop

	; for VRAM $2200 to $22FF, let's use an alternating pattern of dark grey and darker grey.
	LDA #$23
	STA $2006
	LDA #$E0
	STA $2006
	
	LDA #$99
	LDY #24
AttributePreRenderLoop2:
	STA $2007
	DEY
	BNE AttributePreRenderLoop2

	; return
	RTS	
	
SetUpAttributesForPassFail:
; reset the latch
	BIT $2002
	; set VRAM Address to $223F8
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	
	LDA #0
	LDY #64
AttributePreResultsLoop:
	STA $2007
	DEY
	BNE AttributePreResultsLoop
	RTS
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ResetVRAMWith24:
	; store a 0x24 in every byte from VRAM $2000 to $2FFF
	; 0x24 is the empty tile in my character set.

	LDA #1
	STA <ClearScreenAttributeMode

	; reset the latch
	BIT $2002
	; set VRAM Address to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	; set every byte to 0x24
	LDX #$10
	LDY #$00
	LDA #$24
	JMP ResetVRAMLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrepBufferWithX:
	; stores X into VRAM buffer. Overwrites A register with previous buffer contents. (garbage)

	; This writes X to VRAM $2000
	; Reads from VRAM $2000
	; Then resets VRAM $2000 back to a value of zero.

	; reset the latch
	BIT $2002
	; set VRAM Address to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	; store X in VRAM $2000
	STX $2007
	; set VRAM Address back to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	; read the value from VRAM into buffer
	LDA $2007
	PHA
	; set VRAM Address back to $2000
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	LDA #0
	; Reset the value of address $2000
	STA $2007
	PLA
	; return
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StallFor1Second:
	
	
	LDX #$20
	LDY #$00
	JSR SetAddressToXY ; set to 2000	
	
	; set scroll
	LDA $2002

	LDA #$00
	STA $2005
	LDA #$F8
	STA $2005
	
	; enable rendering
	LDA #$0A
	STA $2001
	
	LDX #60

SecondLoop:
	JSR WaitForVBLank
	DEX
	BNE SecondLoop	
	
	
	; disable rendering
	LDA #$00
	STA $2001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WaitForVBLank:
	LDA $2002
VBLankLoop:
	LDA $2002
	BPL VBLankLoop
	RTS	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; copy/pasted from Super Mario Bros. 3
JumpTable:	
	ASL A
	TAY
	PLA
	STA <$0
	PLA
	STA <$1
	INY
	LDA [$0],Y
	STA <$2
	INY
	LDA [$0],Y
	STA <$3
	JMP [$2]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.org $9000
NMI_Vector: ; Both the IRQ and NMI point here.
	; For debugging purposes, if a test fails, I can press the A button to reset.
	; It won't change the outcome, but I can take a good look at the pattern drawn to the screen and record it.

	LDA #1
	STA $4016
	LSR A
	STA $4016
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	ASL A
	EOR $4016
	EOR #$C0
	
	;
	
	LDA #1
	STA $4016
	LSR A
	STA $4016
	LDA $4016
	AND #$07
	
	BEQ ExitNMI
	JMP Reset
ExitNMI:
	RTI
	


Reset:
	SEI	; disable interrupts
	
	; set SP to FF
	LDX #$FF
	TXS
	
	LDA #0	; initialize the A, X, and Y registers with 0s
	LDX #0
	LDY #0
	
	LDA #$40
	STA $4017	;prevent DMC DMAs
	
	; initialize/clear RAM
	
	LDA #0
RAMClear:	
	STA <$00, X
	STA $100, X
	STA $200, X
	STA $300, X
	STA $400, X
	STA $500, X
	STA $600, X
	STA $700, X
	INX
	BNE RAMClear
	
	LDA #$FF
	STA <TestResults
	
	; Stall for 2 frames

Loop1:
	LDA $2002
	BPL Loop1
Loop2:
	LDA $2002
	BPL Loop2	
	
	; Okay, now the PPU is ready.
	
	LDA #0
	STA $2001
	LDA #$10
	STA $2000
	
	; set up palette stuff
	
	LDA #$3F
	STA $2006
	STY $2006 ; Y = 0
	; PPU ADDR is at $3F00, the palette info

	LDX #0

PaletteLoop:
	LDA DefaultPalette, X	; load palette color from LUT
	STA $2007				; store it in the PPU
	INX						; increment X
	CPX #31 				; once X is 32, we got all the colors.
	BNE PaletteLoop			; if not X !=32, loop
	
	; overwrite the entire nametable

	JSR ClearVRAM

	; wait for next frame so debugging is easier
	LDA $2002
Loop3:
	LDA $2002
	BPL Loop3
	JMP BeginTest1
	
	
	
	.bank 1
	.org $BFFA	; Interrupt vectors go here:
	.word $9000 ; NMI
	.word Reset ; Reset
	.word $9000 ; IRQ

	;;;; MORE COMPILER STUFF, ADDING THE PATTERN DATA ;;;;

	.incchr "Sprites.pcx"
	.incchr "Tiles.pcx"