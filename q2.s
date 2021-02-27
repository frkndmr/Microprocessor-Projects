;Muhammed Furkan Demir
;15017061

index 	EQU 0x06			 ; index value = 6
size  	EQU (index+1)*4		 ; array size, 4 bytes for each index
	
		AREA emptyspace, data, readwrite
array  	SPACE size			 ; Allocate space from memory for array
array_end

		AREA first, code, readonly
		ENTRY
		ALIGN
__main	FUNCTION
		EXPORT __main

		  MOVS 	r0,#index	 ; r0 = index 
		  LDR	r5,=array	 ; r5 = address of array
		  BL	factorial	 ; jump factorial function
stop 	  B 	stop

		 ENDFUNC

factorial	FUNCTION
		    EXPORT factorial

          MOVS r3,#1       ; r3 = 1 , i value
		  STR  r3,[r5,#0]  ; array[0] = 1
		  MOVS r4,#4	   ; r4=4
loop	  CMP  r3,r0	   ; check i<index cond
		  BGT  stop        ; if i>=index jump stop
		  SUBS r4,r4,#4	   ; r4 = r4-4
		  LDR  r6,[r5,r4]  ; r6 = array[r4] , array[i-1]
		  MULS r6,r3,r6    ; r6 = r6*i      , i*array[i-1] 
		  ADDS r4,r4,#4    ; r4 = r4+4
		  STR  r6,[r5,r4]  ; array[r4] = r6 , array[i] = i*array[i-1]
		  ADDS r4,r4,#4    ; r4 = r4+1
		  ADDS r3,r3,#1    ; r3 = r3+1 , i+1
		  B    loop		   ; jump loop, (for loop)
		  
		  ENDFUNC
		  END

		




	