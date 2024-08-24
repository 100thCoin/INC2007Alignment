	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This test does NOT work on my console, though it might work on yours! The test results may vary from console to console.		 ;
	; The comments here in the source code are unchanged from the normal test. The logic for test 4 and the test results are changed.;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; This cartridge is designed to determine the current alignment of the CPU clock and PPU clock.
	
	; Here's how this test ROM works.
	
	; Assume VRAM = 2110, and the buffer currently holds 55 before INC $2007.
	; Assume X = 0, VRAM = 2110, and the buffer currently holds 55 before INC $2007, X. 
	
	; After performing the INC instruction, a screen showing the values of VRAM is displayed for about 1 second.
	; This lets you visually see the result of the test before the PASS/FAIL screen.
	; After you've had a good look at the contents of VRAM, this will read the 3 addresses that should have been affected, 
	; and compares with the values my console has.

	; You can re-run the test from the results screen by pressing and releasing the A button.
	; This should have consistent results with the previous test, allowing you to have another look at the pre-results screen.
	; This also allows the test to be re-ran without changing the alignment, as you don't press need to the reset button.

	; This cartridge is expecting the values that my console uses, though results may vary.

	; Test 1: Address $2111 should have the value 11. (Another console has been shown to read the value 10 instead of 11)
	; Test 2: Address $2112 should have the value 00 or 56.
	;	- if the value is 00, we're on alignment 0. All other alignments read 56
	; Test 3: Address $2156 should have the value 56.

	; Tests 4 through 6 are different depending on alignment.
	
	; A0 Test 4: Address $2111 should have the value 11. (Another console has been shown to read the value 10 instead of 11)
	; A0 Test 5: Address $2112 should have the value 00.
	; A0 Test 6: Address $2156 should have the value 56.
	
	; For non-0 alignments, the following tests determine the alignment.
	; Keep in mind, these tests read different addresses than the alignment 0 tests. instead reading $2111, this reads $2112.
	; A123 Test 4: Address $2112 should have the value 12.	(Another console has been shown to read the value 11 instead of 12)
	; A123 Test 5: Address $2113 should have the value 56, 11, or 01.
	;	- This has a different value for each alignment. Alignment 1 : 56. Alignment 2 : 11. Alignment 3: 01.
	;	- For alignment 2, Another console has been shown to read the value 10 instead of 11.
	;	- These values also appear in test 6
	
	; At this point, the alignment has been determined. The final test just confirms that another write occurs.
	; A1 Test 6: Address $2156 = 56
	; A2 Test 6: Address $2111 = 11 (Another console has been shown to read the value 10 instead of 11)
	; A3 Test 6: Address $2101 = 01

ExpectedTest_1 		= $10
ExpectedTest_A0_2 	= $00
ExpectedTest_A123_2 = $56
ExpectedTest_3		= $56

ExpectedTest_A0_4	= $11 ; sometimes 10?
ExpectedTest_A0_5	= $00
ExpectedTest_A0_6	= $56

; This console's behavior had varied results for test 4.

ExpectedTest_A1_4	= $12	
ExpectedTest_A2_4	= $10	
ExpectedTest_A3_4	= $00	

ExpectedTest_A1_5	= $56
ExpectedTest_A2_5	= $11	
ExpectedTest_A3_5	= $01

ExpectedTest_A1_6	= $56
ExpectedTest_A2_6	= $11
ExpectedTest_A3_6	= $01


	
	; Exmaple output: (Phase 0 PASS)	
	;
	;	PASS
	;
	;	PPUADDR: 2110
	;	READ BUFFER: 55
	;	INC 2007:
	;
	;	2111: 11
	;	2112: 00
	;	2156: 56
	;
	;	INC 2007 X:
	;
	;	2111: 11
	;	2112: 00
	;	2156: 56
	;
	;	PHASE 0
	;
	
	; Exmaple output: (Unknown phase. This console behaved differently than mine.)	
	;
	;	FAILED TEST 1
	;
	;	PPUADDR: 2110
	;	READ BUFFER: 55
	;	INC 2007:
	;
	;	2111: 10
	;	2112: 00
	;	2156: 56
	;
	
	; Exmaple output: (Phase 1) 
	; (I've added extra comments that would not be diplayed, but are for your convenience.)	
	;
	;	PASS
	;
	;	PPUADDR: 2110
	;	READ BUFFER: 55
	;	INC 2007:
	;
	;	2111: 11	; Test 1
	;	2112: 56	; Test 2 (00 if pahse 0. 56 otherwise)
	;	2156: 56	; Test 3 
	;
	;	INC 2007 X:
	;
	;	2112: 12	; Test 4 (Phase 0 tests address $2111, all other phases test $2112. the result is 11 if phase 0. 12 otherwise)
	;	2113: 56	; Test 5 (Phase 0 tests address $2112, all other phases test $2113. the result is 56, 11, and 01 for phase 1, 2, and 3 respectively)
	;	2156: 56	; test 6 (Phases 0 and 1 test address $2156. Phase 2 tests $2011, phase 3 tests $2101. the results are 56, 56, 11, and 01)
	;
	;	PHASE 1
	;
	
	; Exmaple output: (Phase 2) The first visible screen that is shown before the result screen. 
	; (I've added extra comments that would not be diplayed, but are for your convenience.)	
	;
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) The first 8 lines are darker, as the test should not affect any of these bytes.
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) This is the final dark line. The next 8 are brighter, as that's where the test can affect.
	;   0000000000000000000000000000000000115600000000000000000000000000	; This line contains a $11 at address $2111, and a $56 at address $2112
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000056000000000000000000	; This line contains a $56 at address $2156
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) These 8 lines are darker again, as the test should not affect any of these bytes.
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) This is the final line.
	;

	; Exmaple output: (Phase 2) The second visible screen that is shown before the result screen. 
	; (I've added extra comments that would not be diplayed, but are for your convenience.)	
	;
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) The first 8 lines are darker, as the test should not affect any of these bytes.
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) This is the final dark line. The next 8 are brighter, as that's where the test can affect.
	;   0000000000000000000000000000000000111211000000000000000000000000	; This line contains a $11 at address $2111, and a $12 at address $2112, and a $11 at $2113
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	; This line does NOT contain a $56 at address $2156
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;   0000000000000000000000000000000000000000000000000000000000000000	;
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) These 8 lines are darker again, as the test should not affect any of these bytes.
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark)
	;	0000000000000000000000000000000000000000000000000000000000000000	; (dark) This is the final line.
	;
	
	
	; For more info on the results that my console gives, here's a list of the results as well as the results of different tests with the same alignment.
	
	; My test INC 2007
	; My test INC 2007, X
	; state-detect-letters: https://github.com/michel-iwaniec/nes-reset-state-detect/tree/add_alternate_phase1_pattern_cc
	; Blargg's double_2007_read.nes's second row.

	
	; Phase 0:
	; INC 2007:   ($2111 = 11)              ($2156 = 56)  
	; INC 2007,X: ($2111 = 11)              ($2156 = 56)  
	; (state-detect-letters: 0-AGMS)
	; (double_2007_read: 22 33 44 55 66)
	
	; Phase 1:
	; INC 2007:   ($2111 = 11) ($2112 = 56) ($2156 = 56)  
	; INC 2007,X: ($2112 = 12) ($2113 = 56) ($2156 = 56)  
	; (state-detect-letters: 1-AGNS)
	; (double_2007_read: 22 44 55 66 77)
	
	; Phase 2:
	; INC 2007:   ($2111 = 11) ($2112 = 56) ($2156 = 56)  
	; INC 2007,X: ($2112 = 12) ($2113 = 11) ($2111 = 11)  
	; (state-detect-letters: 2-BHNT)
	; (double_2007_read: 02 44 55 66 77)
	
	; Phase 3:
	; INC 2007:   ($2111 = 11) ($2112 = 56) ($2156 = 56)  
	; INC 2007,X: ($2112 = 12) ($2113 = 01) ($2101 = 01)  
	; (state-detect-letters: 3-DGMS)
	; (double_2007_read: 02 44 55 66 77)


	; Phase 3's results were the most surprising, as the double_2007_read test starts with "02", the VRAM address' low byte.
	; This did not match the way INC 2007,X had the value 00 get incremented, and wrote 01.
	; With a bit more testing, I determined the difference here was the VRAM address being less than $2000 returning the VRAM low byte.
	; Otherwise, it returned buffer contents. I have no idea why, but that seems to be the case.
	
	
	
	;;;; HEADER AND COMPILER STUFF ;;;;
	.inesprg 1  ; 2 banks
	.ineschr 1  ; 
	.inesmap 0  ; mapper 0 = NROM
	.inesmir 1  ; background mirroring, vertical

	;;;; CONSTANTS ;;;;
	
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

TestResults = $10
RanTest2 = $21
ClearScreenAttributeMode = $FF

	;;;; ASSEMBLY CODE ;;;;
	.org $8000
	
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
	STA $800, X
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

	JSR ResetVRAM

	; wait for next frame so debugging is easier
	LDA $2002
Loop3:
	LDA $2002
	BPL Loop3
	;;;;;;;;;;;;;;;;
	; Begin Test 1 ;
	;;;;;;;;;;;;;;;;
	LDA #1
	PHA
		
	LDX #$55
	JSR PrepBufferWithX
	; The buffer now holds 55
	LDX #$21
	LDY #$10
	JSR SetAddressToXY ; VRAM Address = $2110
	
	; Here's the test:
	INC $2007
	
	; this lets me visually see the bytes in VRAM.
	; since the results could be different depending on the CPU/PPU alignment,
	; this can allow me to verify why the test might fail on real hardware.
	JSR StallFor1Second

	
	; possible results:
	
	;        #  address R/W description
    ;   --- ------- --- ------------------------------------------
    ;    1    PC     R  fetch opcode, increment PC
    ;    2    PC     R  fetch low byte of address, increment PC
    ;    3    PC     R  fetch high byte of address, increment PC
    ;    4  address  R  read from effective address
    ;    5  address  W  write the value back to effective address, and do the operation on it
    ;    6  address  W  write the new value to effective address
	
	; we know the store to VRAM happens *before* updating the address.
	
	; read. updating vram address...
	; write prematurely, mid state-machine. reset machine
	; write again prematurely. reset machine
	
	
	
	; 1.)
	; Write 11 to 2111
	; update low byte of VRAM Address.
	; writes 56 to 2112
	; writes 56 to 2156
	
	; 2.)
	; Write 11 to 2111
	; update low byte of VRAM Address.
	; writes 56 to 2156
	; Does not write to 2112

	; let's see what these values are...
	
	LDX #$21
	LDY #$11
	JSR ReadFromAddressXXYY ; read from 2111	
	; expected result is 11	
	STA <TestResults+1

	LDX #$21
	LDY #$12
	JSR ReadFromAddressXXYY ; read from 2112	
	; expected result is 11	
	STA <TestResults+2
	
	LDX #$21
	LDY #$56
	JSR ReadFromAddressXXYY ; read from 2156	
	; expected result is 11	
	STA <TestResults+3
	
	
	
	LDX #$21
	LDY #$11
	JSR ReadFromAddressXXYY ; read from 2111	
	; expected result is 11	
	CMP #ExpectedTest_1
	BEQ Pass1
	JMP TestFailed
Pass1:
	; if we pass the test, PLA and replace the value with the next one
	
	; wait for next frame so debugging is easier
	LDA $2002
	BPL Pass1
	
	;;;;;;;;;;;;;;;;
	; Begin Test 2 ; 
	;;;;;;;;;;;;;;;;
	
	PLA
	LDA #2
	PHA
		
	LDX #$21
	LDY #$12
	JSR ReadFromAddressXXYY ; read from 2112	
	; expected result is 56, or 00
	CMP #ExpectedTest_A123_2
	BEQ Pass2
	CMP #ExpectedTest_A0_2
	BEQ Pass2Alt
	JMP TestFailed

Pass2Alt:
	JMP TestAlt1
	
Pass2:
	
	; wait for next frame so debugging is easier

	LDA $2002
	BPL Pass2
	
	;;;;;;;;;;;;;;;;
	; Begin Test 3 ;
	;;;;;;;;;;;;;;;;
	
	PLA
	LDA #3
	PHA
		
	LDX #$21
	LDY #$56
	JSR ReadFromAddressXXYY ; read from 2156	
	; expected result is 56
	CMP #ExpectedTest_3
	BEQ Pass3
	JMP TestFailed
Pass3:
	
	; Okay cool, so if we made it this far then we're doing pretty good.
	; let's try INC, X
	
	;;;;;;;;;;;;;;;;
	; Begin Test 4 ;
	;;;;;;;;;;;;;;;;
	
	; wait for next frame so debugging is easier
	LDA $2002
	BPL Pass3
	
	PLA
	LDA #4
	PHA
	
	; clear VRAM to all 00s
	JSR ResetVRAM
	
	LDX #$55
	JSR PrepBufferWithX
	; The buffer now holds 55
	LDX #$21
	LDY #$10
	JSR SetAddressToXY ; VRAM Address = $2110
	
	; Here's the test:
	LDX #0
	INC $2007, X
	
	INC RanTest2

	
	; this lets me visually see the bytes in VRAM.
	; since the results could be different depending on the CPU/PPU alignment,
	; this can allow me to verify why the test might fail on real hardware.
	JSR StallFor1Second

	
	; possible results:
	
	;         #   address  R/W description
    ;   --- --------- --- ------------------------------------------
    ;    1    PC       R  fetch opcode, increment PC
    ;    2    PC       R  fetch low byte of address, increment PC
    ;    3    PC       R  fetch high byte of address, add index register X to low address byte, increment PC
    ;    4  address+X* R  read from effective address, fix the high byte of effective address
    ;    5  address+X  R  re-read from effective address
    ;    6  address+X  W  write the value back to effective address, and do the operation on it
    ;    7  address+X  W  write the new value to effective address

	
	; 1.)
	; the value 55 is read
	; Write 12 to 2112
	; update low byte of VRAM Address.
	; INC 55 to 56.
	; writes 56 to 2113
	; writes 56 to 2156
	
	; 2.)
	; the value 55 is read, then overwritten by the second read
	; Write 12 to 2112
	; update low byte of VRAM Address. 
	; Somehow 10 is on the bus. INC 10 = 11. 11 should now be on the bus.
	; writes 11 to 2113
	; writes 11 to 2111
	
	; 3.)
	; the value 55 is read, then overwritten by the second read
	; Write 12 to 2112
	; update low byte of VRAM Address. 
	; Somehow 00 is on the bus. INC 00 = 01. 01 should now be on the bus.
	; TODO: Confirm if this 00 is from the buffer? what if this field was of FFs.
	; writes 01 to 2113
	; writes 01 to 2101

	; let's see what these values are...

	LDX #$21
	LDY #$12
	JSR ReadFromAddressXXYY ; read from 2112	
	; expected result is 12
	STA <TestResults+4
	CMP #ExpectedTest_A1_4	
	BEQ Pass4
	CMP #ExpectedTest_A2_4		
	BEQ Pass4_A2
	CMP #ExpectedTest_A3_4		
	BEQ Pass4_A3
	JMP TestFailed

Pass4_A2:
	JMP Pass4
	
Pass4_A3:
	JMP Pass4
	
Pass4:
	
	;;;;;;;;;;;;;;;;
	; Begin Test 5 ;
	;;;;;;;;;;;;;;;;
	

	LDA $2002
	BPL Pass4
	
	PLA
	LDA #5
	PHA
	
	LDX #$21
	LDY #$13
	JSR ReadFromAddressXXYY ; read from 2113	
	; expected result is 56, 11, or 01	
	STA <TestResults+5
	CMP #ExpectedTest_A1_5	
	BEQ Pass5
	CMP #ExpectedTest_A2_5		
	BEQ Pass5_A2
	CMP #ExpectedTest_A3_5		
	BEQ Pass5_A3	; this will never happen with this console, as ExpectedTest_A3_5 is the same as ExpectedTest_A1_5
	JMP TestFailed

Pass5_A2:
	JMP TestAlt_A2
	
Pass5_A3:
	JMP TestAlt_A3
	
Pass5:
	
	LDA <TestResults+4	; in order to determine this is alignment 3, check the results of test 4.
	CMP #ExpectedTest_A3_4
	BEQ Pass5_A3
	
	LDA <TestResults+4	; in order to determine this is alignment 3, check the results of test 4.
	CMP #ExpectedTest_A2_4
	BEQ Pass5_A2
	
	
	LDA $2002
	BPL Pass5
	
	;;;;;;;;;;;;;;;;
	; Begin Test 6 ;
	;;;;;;;;;;;;;;;;
	
	PLA
	LDA #6
	PHA
	
	LDX #$21
	LDY #ExpectedTest_A1_6
	JSR ReadFromAddressXXYY ; read from 2156	
	; expected result is 56	
	STA <TestResults+6
	CMP #ExpectedTest_A1_6		
	BEQ Pass6
	JMP TestFailed
Pass6:
	LDA #1
	STA <TestResults
	JMP Suite2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestAlt1:
	; if test 1 never wrote to 2112...
	
	;;;;;;;;;;;;;;;;;;;;
	; Begin Test 3 Alt ;
	;;;;;;;;;;;;;;;;;;;;
	
	PLA
	LDA #3
	PHA
		
	LDX #$21
	LDY #$56
	JSR ReadFromAddressXXYY ; read from 2156	
	; expected result is 56
	STA <TestResults+3
	CMP #ExpectedTest_3
	BEQ Pass3Alt
	JMP TestFailed
Pass3Alt:

	; cool.

	; Okay cool, so if we made it this far then we're doing pretty good.
	; let's try INC, X
	
	;;;;;;;;;;;;;;;;;;;;
	; Begin Test 4 Alt ;
	;;;;;;;;;;;;;;;;;;;;
	
	; wait for next frame so debugging is easier
	LDA $2002
	BPL Pass3Alt
	
	PLA
	LDA #4
	PHA
	
	; clear VRAM to all 00s
	JSR ResetVRAM
	
	LDX #$55
	JSR PrepBufferWithX
	; The buffer now holds 55
	LDX #$21
	LDY #$10
	JSR SetAddressToXY ; VRAM Address = $2110
	
	; Here's the test:
	LDX #0
	INC $2007, X
	
	INC RanTest2
	
	; this lets me visually see the bytes in VRAM.
	; since the results could be different depending on the CPU/PPU alignment,
	; this can allow me to verify why the test might fail on real hardware.
	JSR StallFor1Second

	
	; possible results:
	
	;        #   address  R/W description
    ;   --- --------- --- ------------------------------------------
    ;    1    PC       R  fetch opcode, increment PC
    ;    2    PC       R  fetch low byte of address, increment PC
    ;    3    PC       R  fetch high byte of address, add index register X to low address byte, increment PC
    ;    4  address+X* R  read from effective address, fix the high byte of effective address
    ;    5  address+X  R  re-read from effective address
    ;    6  address+X  W  write the value back to effective address, and do the operation on it
    ;    7  address+X  W  write the new value to effective address

	; read
	; read again, interrupting
	; write, interrupting
	; write, interrupting
	
	; 1.)
	; Write 11 to 2111
	; update low byte of VRAM Address.
	; writes 56 to 2156
	; Does not write to 2112

	; let's see what these values are...

	LDX #$21
	LDY #$11
	JSR ReadFromAddressXXYY ; read from 2111	
	; expected result is 11	
	STA <TestResults+4
	CMP #ExpectedTest_A0_4
	BEQ Pass4Alt
	JMP TestFailed
Pass4Alt:
	; if we pass the test, PLA and replace the value with the next one
	
	; wait for next frame so debugging is easier
	LDA $2002
	BPL Pass4Alt
	
	;;;;;;;;;;;;;;;;;;;;
	; Begin Test 5 Alt ; 
	;;;;;;;;;;;;;;;;;;;;
	
	PLA
	LDA #5
	PHA
		
	LDX #$21
	LDY #$12
	JSR ReadFromAddressXXYY ; read from 2112	
	; expected result is 00
	STA <TestResults+5
	CMP #ExpectedTest_A0_5
	BEQ Pass5Alt
	JMP TestFailed

Pass5Alt:
	
	; wait for next frame so debugging is easier

	LDA $2002
	BPL Pass5Alt
	
	;;;;;;;;;;;;;;;;;;;;
	; Begin Test 6 Alt ;
	;;;;;;;;;;;;;;;;;;;;
	
	PLA
	LDA #6
	PHA
		
	LDX #$21
	LDY #ExpectedTest_A0_6
	JSR ReadFromAddressXXYY ; read from 2156	
	; expected result is 56
	STA <TestResults+6
	CMP #ExpectedTest_A0_6
	BEQ Pass6Alt
	JMP TestFailed
Pass6Alt:
	LDA #0
	STA <TestResults
	JMP Suite2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestAlt_A2:
	LDA $2002
	BPL TestAlt_A2
	
	;;;;;;;;;;;;;;;;;;;
	; Begin Test 6 A2 ;
	;;;;;;;;;;;;;;;;;;;
	
	PLA
	LDA #6
	PHA
	
	LDX #$21
	LDY #ExpectedTest_A2_6
	JSR ReadFromAddressXXYY ; read from 2111	
	; expected result is 11	
	STA <TestResults+6
	CMP #ExpectedTest_A2_6		
	BEQ Pass6A2
	JMP TestFailed
Pass6A2:
	LDA #2
	STA <TestResults
	JMP Suite2
	
TestAlt_A3:
	LDA $2002
	BPL TestAlt_A3
	
	;;;;;;;;;;;;;;;;;;;
	; Begin Test 6 A3 ;
	;;;;;;;;;;;;;;;;;;;
	
	PLA
	LDA #6
	PHA
	
	LDX #$21
	LDY #ExpectedTest_A3_6
	JSR ReadFromAddressXXYY ; read from 2101	
	STA <TestResults+6
	; expected result is 01	
	CMP #ExpectedTest_A3_6		
	BEQ Pass6A3
	JMP TestFailed
Pass6A3:
	LDA #3
	STA <TestResults
	
	JMP Suite2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Suite2:
	; Okay cool, so we just finished the first suite and determined that there are 4 possible "routes".
	; I was planning to add more tests here, but then I didn't do that.
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestsPassed:
	
	; We passed the tests!
	PLA
	; print PASS
	JSR ResetVRAMWith24
	; Set address to a good spot on the screen
	LDX #$21
	LDY #$28
	JSR SetAddressToXY
	; create pointer to the message
	LDA #LOW(MSG_PASS)
	STA $0
	LDA #HIGH(MSG_PASS)
	STA $1
	JSR PrintMessage
	
	; end of tests
	JMP EndOfTests
	
	
TestFailed:
	; print "FAILED TEST "
	JSR ResetVRAMWith24
	; Set address to a good spot on the screen
	LDX #$21
	LDY #$28
	JSR SetAddressToXY
	; create pointer to the message
	LDA #LOW(MSG_FAILED)
	STA $0
	LDA #HIGH(MSG_FAILED)
	STA $1
	JSR PrintMessage
	
	; pull the test number from the stack
	PLA
	; print the number too.
	STA $2007
	
	; end of tests (due to failure)


EndOfTests:

	LDA TestResults
	CMP #$FF
	BEQ TestDidNotSucceed
	
	JSR PrintInfoDump_PASS
	JMP PostInfoDump


TestDidNotSucceed:

	JSR PrintInfoDump_Fail
	JMP PostInfoDump




PostInfoDump:

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

PrintInfoDump_Fail:

	; I have no idea what the phase is, since the test failed.
	; This only prints to the screen the values of $2111, $2112, and $2156

	LDX #$21
	LDY #$68
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_1)
	STA $0
	LDA #HIGH(MSG_ASM_1)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$88
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_B)
	STA $0
	LDA #HIGH(MSG_ASM_B)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$A8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2)
	STA $0
	LDA #HIGH(MSG_ASM_2)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$E8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2111)
	STA $0
	LDA #HIGH(MSG_ASM_2111)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+1
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+1
	AND #$F
	STA $2007

	LDX #$22
	LDY #$08
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2112)
	STA $0
	LDA #HIGH(MSG_ASM_2112)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+2
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+2
	AND #$F
	STA $2007
	
	LDX #$22
	LDY #$28
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2156)
	STA $0
	LDA #HIGH(MSG_ASM_2156)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+3
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+3
	AND #$F
	STA $2007
	
	LDA RanTest2
	BNE DontExitYet
	
	RTS
	
DontExitYet:
	
	LDX #$22
	LDY #$68
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_3)
	STA $0
	LDA #HIGH(MSG_ASM_3)
	STA $1
	JSR PrintMessage
	
	LDX #$22
	LDY #$A8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2112)
	STA $0
	LDA #HIGH(MSG_ASM_2112)
	STA $1
	JSR PrintMessage
	LDA <TestResults+4
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+4
	AND #$F
	STA $2007
	
	LDX #$22
	LDY #$C8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2113)
	STA $0
	LDA #HIGH(MSG_ASM_2113)
	STA $1
	JSR PrintMessage
	LDA <TestResults+5
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+5
	AND #$F
	STA $2007	
	
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintInfoDump_PASS:

	LDX #$21
	LDY #$68
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_1)
	STA $0
	LDA #HIGH(MSG_ASM_1)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$88
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_B)
	STA $0
	LDA #HIGH(MSG_ASM_B)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$A8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2)
	STA $0
	LDA #HIGH(MSG_ASM_2)
	STA $1
	JSR PrintMessage
	
	LDX #$21
	LDY #$E8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2111)
	STA $0
	LDA #HIGH(MSG_ASM_2111)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+1
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+1
	AND #$F
	STA $2007

	LDX #$22
	LDY #$08
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2112)
	STA $0
	LDA #HIGH(MSG_ASM_2112)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+2
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+2
	AND #$F
	STA $2007
	
	LDX #$22
	LDY #$28
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2156)
	STA $0
	LDA #HIGH(MSG_ASM_2156)
	STA $1
	JSR PrintMessage
	
	LDA <TestResults+3
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+3
	AND #$F
	STA $2007
	
	LDX #$22
	LDY #$68
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_3)
	STA $0
	LDA #HIGH(MSG_ASM_3)
	STA $1
	JSR PrintMessage
	
	LDX #$22
	LDY #$A8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2112)
	STA $0
	LDA #HIGH(MSG_ASM_2112)
	STA $1
	LDA TestResults
	BNE PrintNotPhase0
	LDA #LOW(MSG_ASM_2111)
	STA $0
	LDA #HIGH(MSG_ASM_2111)
	STA $1	
PrintNotPhase0:
	JSR PrintMessage
	LDA <TestResults+4
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+4
	AND #$F
	STA $2007
	
	LDX #$22
	LDY #$C8
	JSR SetAddressToXY
	LDA #LOW(MSG_ASM_2113)
	STA $0
	LDA #HIGH(MSG_ASM_2113)
	STA $1
	LDA TestResults
	BNE PrintNotPhase0_2
	LDA #LOW(MSG_ASM_2112)
	STA $0
	LDA #HIGH(MSG_ASM_2112)
	STA $1	
PrintNotPhase0_2:
	
	JSR PrintMessage
	LDA <TestResults+5
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+5
	AND #$F
	STA $2007	
	
	LDX #$22
	LDY #$E8
	JSR SetAddressToXY
	
	LDA TestResults
	BNE PrintNotPhase0_3
	LDA #LOW(MSG_ASM_2156)
	STA $0
	LDA #HIGH(MSG_ASM_2156)
	STA $1	
	JSR PrintMessage
	JMP skip

PrintNotPhase0_3:
	LDA #LOW(MSG_ASM_21xx)
	STA $0
	LDA #HIGH(MSG_ASM_21xx)
	JSR PrintMessage


	LDA <TestResults+5
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+5
	AND #$F
	STA $2007	
	LDA #_sc
	STA $2007	
	LDA #$24
	STA $2007	

skip:
	LDA <TestResults+6
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	STA $2007
	LDA <TestResults+6
	AND #$F
	STA $2007

	
	LDX #$23
	LDY #$28
	JSR SetAddressToXY
	LDA #LOW(MSG_PHASE)
	STA $0
	LDA #HIGH(MSG_PHASE)
	STA $1
	JSR PrintMessage

	LDA TestResults
	
	STA $2007
	
	
	RTS


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


MSG_PASS:
	.byte 4, _P, _A, _S, _S
	
MSG_FAILED:
	.byte 12, _F, _A, _I, _L, _E, _D, __, _T, _E, _S, _T, __
	
	
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

PrintMessage:
	LDY #0
	; the first byte is the length
	LDA [$0], Y
	STA $2
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
	CPX $2
	BNE PrintLoop
	; return
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
	
	
	
	.bank 1
	.org $BFFA	; Interrupt vectors go here:
	.word $9000 ; NMI
	.word $8000 ; Reset
	.word $9000 ; IRQ

	;;;; MORE COMPILER STUFF, ADDING THE PATTERN DATA ;;;;

	.incchr "Sprites.pcx"
	.incchr "Tiles.pcx"