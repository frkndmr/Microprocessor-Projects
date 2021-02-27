;Muhammed Furkan Demir
;150170061

index 	EQU 0x06			;index = 6            
size  	EQU (index+1)*4		;array[index+1], each index 4 byte
	
		AREA emptyspace, data, readwrite
array  	SPACE size			;allocate space from memory for array
array_end

		AREA first, code, readonly
		ENTRY
		ALIGN
__main	FUNCTION
		EXPORT __main

		  MOVS  r3,#0		;r3 = i
		  MOVS  r7,#0		;r7 = 0
		  MOVS 	r0,#index	;r0 = index
		  LDR	r5,=array	;r5 = address of array		  
loop	  CMP   r3,r0		;check i<index
		  BGT   stop		;if i>= index jump stop
		  MOVS  r1,r3		;r1 = r3
		  MOVS  r2,#1		;r2 = 1
    	  BL	factorial	;jump to factorial
main	  STR   r2,[r5,r7]	;array[r7] = r2,   store the return r2 value to array
		  ADDS  r3,r3,#1	;i = i+1
		  ADDS  r7,r7,#4	;r7 = r7 + 4
		  B     loop	  	;jump to loop , for loop
stop 	  B 	stop
			
		  ENDFUNC

factorial	FUNCTION
		    EXPORT factorial
			
		  PUSH	{LR}		;Pushes the last address	
		  CMP   r1,#2		;check i<2
		  BLT   con			;if i>=2 jump to con
		  SUBS  r1,r1,#1	;r1 = r1-1 , factorial(i-1)
		  BL 	factorial	;jump to factorial
		  ADDS  r1,r1,#1	;r1 = r1 + 1
		  MULS  r2,r1,r2	;r2 = i * factorial(i-1)
		  POP	{PC}		;Pops the last address
con  	  MOVS  r2,#1		;return 1
		  POP	{PC}		;Pops the last address
		
		  ENDFUNC
		  END

		




	