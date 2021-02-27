;Muhammed Furkan Demir
;150170061

LIMIT 	EQU  0x78			;LIMIT = 120
size  	EQU (LIMIT+1)*4		;primeNumbers[LIMIT + 1], each index 4 byte
size_p  EQU (LIMIT+1)		;isPrimeNumbers[LIMIT + 1], each index 1 byte		
	
					AREA emptyspace, data, readwrite
primeNumbers  		SPACE size	; Allocate space from memory for primeNumbers array
primeNumbers_end

					AREA emptyspace, data, readwrite
isPrimeNumbers  	SPACE size_p ; Allocate space from memory for isPrimeNumbers array
isPrimeNumbers_end

		AREA first, code, readonly
		ENTRY
		ALIGN
__main	FUNCTION
		EXPORT __main

		  MOVS 	r0,#LIMIT	; r0 = 120
		  BL	SieveOfEratosthenes		; jump to SieveOfEratosthenes function
stop 	  B 	stop
	
		ENDFUNC 

SieveOfEratosthenes	FUNCTION
					EXPORT SieveOfEratosthenes
			
	      MOVS r3,#0		; r3 = 0 , i;
		  MOVS r7,#0		; r7 = 0
		  MOVS r2,#0	    ; r2 = 0 , for primeNumbers array value
		  MOVS r4,#1        ; r4 = 1 , for isPrimeNumbers array value is true
		  LDR  r5,=primeNumbers   ;r5 = primeNumbers address
		  LDR  r6,=isPrimeNumbers ;r6 = isPrimeNumbers address
L1		  CMP  r3,r0		; check i<LIMIT
		  BGE  con			; if i>=LIMIT jump to con
		  STR  r2,[r5,r7]	; primeNumbers[r7] = 0
		  STRB r4,[r6,r3]	; isPrimeNumbers[r3] = true
		  ADDS r3,r3,#1		; r3 = r3 + 1
		  ADDS r7,r7,#4		; r7 = r7 + 1
		  B    L1			; jump to L1
con       MOVS r3,#1		; i = 1
		  B    L2			; jump to L2
L2		  ADDS r3,r3,#1		; r3 = r3 + 1
		  MOVS r7,r3		; r7 = i
		  MULS r7,r3,r7		; r7 = i*i
		  CMP  r7,r0		; check i*i < LIMIT
		  BGT  con2			; if i*i >= LIMIT jump to con2
		  LDRB  r4,[r6,r3]	; r4 = isPrimeNumbers[i]
		  CMP  r4,#1		; check r4 == 1
		  BNE  L2			; if r4 != 1 jump to L2
L2_2	  CMP  r7,r0		; check i*i < LIMIT
		  BGT  L2			; if i*i >= LIMIT jump to L2
		  STRB r2,[r6,r7]	; isPrimeNumbers[i] = false
		  ADDS r7,r7,r3		; i*i + i, i*i + 2i, i*i + 3i ...
		  B    L2_2			; jump to L2_2
con2	  MOVS r3,#0		; index = 0
		  MOVS r7,#2		; i = 2
		  B    L3			; jump to L3
L3		  CMP  r7,LIMIT		; check i<LIMIT 
		  BGT  stop			; if i>=LIMIT jump to stop
		  LDRB r4,[r6,r7]	; r4 = isPrimeNumbers[i]
		  ADDS r7,r7,#1		; i = i + 1
		  CMP  r4,#1		; check r4 == 1
		  BNE  L3			; if r4 != 1 jump to L3		
		  SUBS r2,r7,#1		; r2 = r7 - 1  
		  STR  r2,[r5,r3]	; primeNumbers[index] = r2
		  ADDS r3,r3,#4     ; index = index + 1;
		  B    L3			; jump to L3
		  
		  
		  
		  ENDFUNC
		  END

		




	