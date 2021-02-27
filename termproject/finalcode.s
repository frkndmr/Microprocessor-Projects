;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x10, 0x20, 0x15, 0x65, 0x25, 0x20, 0x65, 0x85, 0x12, 0x15, 0x25, 0x85, 0x46, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x02, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02
END_IN_DATA_FLAG




;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		1
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION
				EXPORT SysTick_Handler
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				PUSH {LR}				; To return main
				LDR r2,=INDEX_INPUT_DS  ; r2=INDEX_INPUT_DS address
                LDR r5,[r2]				; r2=INDEX_INPUT_DS
				LDR r3,=TICK_COUNT      ; r3 = TICK_COUNT address 
				LDR r4,[r3]				; r4 = TICK_COUNT
                ADDS r4,r4,#1			; TICK_COUNT++
				STR r4,[r3]				; Store TICK_COUNT
				
				LDR r3,=IN_DATA			; r3 = Initial Address of IN_DATA array
				LDR r4,=END_IN_DATA		; r4 = Finish Address of IN_DATA array
				SUBS r4,r4,r3			; r4 = Size of IN_DATA array
				LSRS r4,r4,#2			; r4 = due to each data is 4byte
				CMP r5,r4				; Compare INDEX_INPUT_DS and Size of IN_DATA
				BEQ Timer_Stop			; If they are equal, branch to SysTick_Stop
				
				
				LSLS r5,r5,#2			; To get data and flag
				LDR r0,=IN_DATA			; R0 = Address of IN_DATA	
                LDR r1,=IN_DATA_FLAG	; R1 = Address of IN_DATA_FLAG	
				LDR R0,[r0,r5]			; R0 = IN_DATA [INDEX_INPUT_DS]
                LDR R1,[r1,r5]			; R1 = IN_DATAFLAG [INDEX_INPUT_DS]
				LSRS r5,r5,#2			; convert INDEX_INPUT_DS to index 
                ADDS r5,r5,#1;			; INDEX_INPUT_DS++
                STR r5,[r2]				; Store updated INDEX_INPUT_DS 
           
                CMP R1,#1				; If flag == 1
                BEQ go_insert			; Make insert operation
                CMP R1,#0				; If flag == 0
                BEQ go_remove			; Make insert operation
                CMP R1,#2				; If flag == 2
                BEQ go_array			; Make insert operation
                
				MOVS r0,#6				; r1 = Error Code 6 : Operation not found 
			    B call_error  		    ; branch to preparation of WriteErrorLog
			  

go_insert       BL	Insert				; call Insert Function
				CMP r0,#0				; checks r0 return value
				BNE call_error			; if it is not 0 , branch to preparation of WriteErrorLog
				POP {PC}				; if it is zero returns main
				
go_remove       BL	Remove				; call Remove Function
				CMP r0,#0				; checks r0 return value
				BNE call_error			; if it is not 0 , branch to preparation of WriteErrorLog
				POP {PC}				; if it is zero returns main
				
								
go_array        BL LinkedList2Arr		; call LinkedList2Arr Function
                CMP r0,#0				; checks r0 return value
				BNE call_error			; if it is not 0 , branch to preparation of WriteErrorLog
				POP {PC}				; if it is zero returns main

										; Return main Function
Timer_Stop      BL SysTick_Stop			; call SysTick_Stop Function
				POP {PC}	
											; Return main Function
call_error		MOVS r1,r0
				BL OBTAIN_ERROR
				POP {PC}
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------															
				LDR r0,=0xE000E010
				LDR r1,=3463
				STR r1,[r0,#4]
				MOVS r1,#0
				STR r1,[r0,#8]
				MOVS r1,#7
				STR r1,[r0]
				LDR R1, =PROGRAM_STATUS
				MOVS r2,#1
				STR r2,[r1]
				BX LR
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR r0,=0xE000E010
				MOVS r1,#0
				STR r1,[r0]
				LDR r0,=PROGRAM_STATUS
				MOVS r1,#2
				STR r1,[r0]
				BX LR
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				MOVS r0,#AT_SIZE
				MOVS r1,#0
				MOVS r3,#0
loop_x			CMP r0,r1
				BEQ return
				LDR r2,=AT_MEM
				STR r3,[r2,r1]
				ADDS r1,r1,#4
				B loop_x
return			BX LR
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				MOVS r0,#AT_SIZE
				LSLS r0,r0,#5
				MOVS r1,#3
				MULS r0,r1,r0
				MOVS r1,#0
				MOVS r3,#0
loop_ErrorLogs	CMP r0,r1
				BEQ return_ErrorLogs
				LDR r2,=LOG_MEM
				STR r3,[r2,r1]
				ADDS r1,r1,#4
				B loop_ErrorLogs
return_ErrorLogs BX LR
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				MOVS r1,#0
				LDR r0,=TICK_COUNT
				STR r0,[r1]
				LDR r0,=FIRST_ELEMENT
				STR r0,[r1]
				LDR r0,=INDEX_INPUT_DS
				STR r0,[r1]
				LDR r0,=INDEX_ERROR_LOG
				STR r0,[r1]
				LDR r0,=PROGRAM_STATUS
				STR r0,[r1]
				BX LR
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
			LDR R5,=AT_MEM        ; R5 = __AT_Start
			LDR r1,=NUMBER_OF_AT  ; r1 = NUMBER_OF_AT
			LSLS r1,r1,#2		  ; Each table contain 4bytes
			MOVS R2,#0			  ; i for table iteration
			MOVS R4,#1			  ; To allocate a node
read_allocation	CMP r2,r1		  ; Compare AllocationSize and i
			BEQ error			  ; Error Code 1
			LDR R3,[R5,R2]		  ;  r3 = Table[i] 
			PUSH {R3}			  ; r3 --> stack
			MOVS r6,#0			  ; y for obtain each bit individually
shift		CMP r6,#32			  ; Compare y - 32
			BEQ new_table	      ; If y == 32 , branch to new_table 
			LSRS r3,r3,#1		  ; Obtaining bits seperately by using carry flag
			BCC location_finded   ; If carry = 0 , it means empty node is found
			ADDS r6,r6,#1		  ; If carry == 1 , y++
			B shift				  ; New y goes to shift operation 
new_table  	ADDS r2,r2,#4		  ; To read new table (i) = i + 4  
			POP{R3}				  ; erase pushed value of table 
			B read_allocation     ; branch to read new table
location_finded LSLS R4,R4,R6     ; makes 1 logical shift left r6 times
			POP {R3}			  ; r3 = table's value
			ORRS R3,R3,R4         ; updated table's value by converting bit that corresponding to empty node 1 from 0  
			STR R3,[r5,r2]		  ; store updated allocated table
			LDR r0,=DATA_MEM      ; r0 = address of DATA_MEM
			LSLS r2,r2,#6		  ; r2 = table_no * 256 (64 byte)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EKLENDI 8 di 6 oldu
			ADDS r0,r2,r0		  ;	r0 = address of DATA_MEM + table_no * 256
			LSLS r6,r6,#3		  ; y = y * 8 because each node has 8 byte
			ADDS r0,r6,r0		  ; r0 = address of DATA_MEM + table_no * 256 (each table has 64 byte) + node_no * 8 (each node has 2 byte)
			BX LR				  ; return Insert
error		MOVS r0,#0			  ;	return 0 as a error (link list is full)	
			BX LR				  ; return insert
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
			LDR r3,=DATA_MEM	; r3 = Initial addres of DATA_MEM 
			SUBS r0,r0,r3		; r0 = Address to deallocate - Initial addres of DATA_MEM 
			LSRS r0,r0,#3		; r0 = r0 / 8 because each node has 8 bytes
			MOVS r5,#0			; r5 = addres for corresponding AT_MEM
compare		CMP r0,#32		    ; Compare (Address to deallocate-DATA_MEM)/8 and 32
			BLT table_found		; If r0 is less than 32 ,then table is found
			ADDS r5,r5,#4		; If the table is not found, r5 ++
			SUBS r0,r0,#32		; pass to new table
			B compare			; loop to check new table
table_found	MOVS r4,#1		   ; r4 = 1 
			LSLS r4,r4,r0	   ; 1 is shifted to left r0 times
			LDR r3,=AT_MEM	   ; r3 = Initial address of AT_MEM
			LDR r0,[r3,r5]	   ; r0 = AT_MEM[table_no]
			EORS r0,r4,r0	   ; r0 = r4 xor r0. This makes bit 0 to deallocate  
			STR r0,[r3,r5]	   ; Store updated allocate table value
			BX LR			   ; Return Remove
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert		FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
			PUSH {LR}       		; return handler
            PUSH {r0}       		; data -> stack
            LDR r7, =FIRST_ELEMENT 	; r7 = FIRST_ELEMENT address
            LDR r6, [r7]			; r6 = head
            PUSH{r6} 				; Push head address
			LDR r4,[r6] 			; r4 = head's data
            CMP r4, #0 				; compare r4 and null
            BEQ head_null			; if head == NULL branch to head_null
            LDR r6, [r6]			; r6 = head's data
            CMP r6, r0				; compare r6 and insert data
            BEQ head_dublicate_error; if r6 == insert data branch head_dublicate_error   
            BGT head_change			; if r6 > insert data branch head_change
            BLT formal				; if r6 < insert data branch formal

head_null   POP{r6}					; Pop head address
            BL Malloc				; Branch to malloc
            POP{r3}            		; data -> r3
			STR r3, [r0]    		; malloc( data )
            STR r0, [r7]    		; head =malloc
            B success_insert		; branch to success_insert

head_change POP{r6}					; Pop head address
            PUSH{r7}				; Push FIRST_ELEMENT adress
            BL Malloc				; Branch to malloc
            POP{r7}					; Pop FIRST_ELEMENT adress
            POP{r3}					; data -> r3
			CMP r0,#0				; compare data and null 
			BEQ linklist_full_error ; if data == null branch to linklist_full_error
            ADDS r0,r0,#4			; r0 = r0 + 4
            LDR r2,[r7]				; inside r7 value load to r2
            STR r2, [r0]			; Store r2 to inside r0
            SUBS r0,r0,#4			; r0 = r0 - 4
            STR r3, [r0]			; Store r3 to inside r0 
            STR r0, [r7]			; Store r0 to inside r7 
            B success_insert		; Branch to success_insert

formal      POP{r6}          		; r6 = head
            ADDS r1,r6,#4			; r1 = r6 + 4
            LDR r6, [r1]    		; r6 = head.data 
            POP {r3}				; pop insert data
            B loop					; branch loop

loop        CMP r6, #0				; compare to iteration and null
            BEQ formal_add			; if iteration == null branch to formal_add
            LDR r7,[r6]				; iteration's value load r7
            CMP r7, r3				; compare iteration's value and data 
            BEQ dublicate_error		; if iteration's value == data branch to dublicate_error
            BGT araya_ekle			; if iteration's value > data branch to araya_ekle
            ADDS r6,r6,#4			; r6 = r6 + 4
            ADDS r1,r6,#0			; r1 = r6 
            LDR r6,[r6]				; r6 = next iteration's adress
            B loop					; back to loop 

formal_add  PUSH{r1}				; Push previous iter adress
            PUSH{R3}				; Push data
            BL Malloc				; branch malloc
            POP{R3}					; Pop data
            POP{r1}            		; Pop r1 = iter adress
            CMP R0,#0				; compare DATA_MEM adress and null	
			BEQ linklist_full_error	; if DATA_MEM adress == null branch to linklist_full_error
			STR r3, [r0]    		; inside DATA_MEM  = data
            STR r0, [r1]    		; iter address = DATA_MEM address
            B success_insert        ; Branch to success_insert

araya_ekle  PUSH{r1}				; Push previous iter adress
            PUSH{R3}				; Push data
            BL Malloc				; Branch to malloc
            POP {R3}				; Pop data
            POP{r1}					; Pop r1 = iter adress
			CMP R0,#0				; compare DATA_MEM address and null
			BEQ linklist_full_error	; if DATA_MEM address == null branch to linklist_full_error
            STR r3, [r0]			; inside DATA_MEM  = data
            ADDS r0,r0,#4			; iter address = DATA_MEM address
            LDR r4, [r1]			; load iter address to r4 
            STR r4, [r0]			; strore iter address to inside DATA_MEM
            SUBS r0,r0,#4			; r0 = r0 - 4
            STR r0, [r1]			; Merge the address of the interleaved data with the previous element
            B success_insert		; Branch success_insert

success_insert MOVS r0,#0			; r0 = error code
			   POP {PC} 			; return handler 

linklist_full_error MOVS r0,#1      ; r0 = error code
					POP {PC} 		; return handler 

head_dublicate_error POP {r6}		; Excess stack unloading		
					POP {r6}		; Excess stack unloading
					
dublicate_error     MOVS r0,#2      ; r0 = error code
                    POP {PC}  		; return handler
					        

;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
			PUSH {LR}						 	; return handler
            LDR r7, =FIRST_ELEMENT				; r7 = FIRST_ELEMENT address
            LDR r6, [r7]						; r6 = FIRST_ELEMENT's data
			LDR r4,[r6] 						; r4 = Head's value
            CMP r4, #0 							; compare head's value and NULL
            BEQ remove_null_error				; if head's == NULL branch to remove_null_error
            PUSH{r6}							; Push head address
            LDR r6,[r6]							; r6 = Head's value
            CMP r6, r0							; compare head's value and NULL
            BEQ head_remove						; if head == NULL branch to remove_null_error
            POP{r6}								; Pop head address
            B loop_remove						; branch loop_remove


loop_remove CMP r6, #0							; compare iter and NULL
            BEQ not_found_error					; if iter's value == NULL branch to remove_null_error
            LDR r5,[r6]							; r5 = iter's value
            CMP r5, r0							; compare iter's value and data
            BEQ remove_formal					; if iter's value == data branch to remove_formal
            ADDS r6,r6,#4						; iter = iter + 4
            MOVS r1,r6							; r1 = iter
            LDR r6,[r6]							; iter = iter's value
            B loop_remove						; branch loop_remove


remove_formal ADDS r4,r6,#4						; r4 = r6 + 4
              ADDS r0,r6,#0						; r0 = r6
              ADDS r5,r6,#4						; r5 = r6 + 4
              LDR  r5,[r5]						; r5 = r5's value
              STR  r5,[r1]						; store r5 to r1 
              MOVS r5,#0						; r5 = 0
              STR  r5,[r4]						; store r4 to 0
              STR  r5,[r0]						; store r0 to r5
              B success_remove					; branch success_remove

head_remove POP{r6}								; Pop head address
            ADDS r1,r6,#4						; r1 = head address + 4
            LDR r1,[r1]							; r1 = r1 inside
            CMP r1,#0							; compare r1 and null
            BEQ head_even						; if equal go head_even
            ADDS r0,r6,#0 						; r0 = head address
            MOVS r1,#0							; r1 = 0
            STR r1,[r6]							; head's value = 0
            ADDS r4,r6,#0						; r4 = head
            ADDS r6,r6,#4						; head = head + 4
            LDR r6,[r6]							; r6 = head's inside
            ADDS r4,r4,#4						; head = head + 4
            STR r1,[r4]							; r1 stores head + 4's inside
            STR r6,[r7]							; r6 stores r7's inside
            B success_remove					; branch success_remove


head_even   LDR r1,[r6]							; r1 = r6 inside 
            MOVS r1,#0							; r1 = 0
			STR r1,[r6] 						; r1 stores r6's inside
            ADDS r0,r6,#0						; r0 = r6
            B success_remove					; branch success_remove


success_remove BL Free							; branch to free function
			   MOVS r0,#0						; r0 = 0, error code, No error
			   POP {PC} 						; Return handler

not_found_error     MOVS r0,#4					; r0 = 4, error code
                    POP {PC}          			; Return handler

remove_null_error   MOVS r0,#3 					; r0 = 3, error code
                    POP {PC}           			; Return handler

;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															

				MOVS r0,#20  		; It should be AT_SIZE but it exceeds interrupt time due to clear operation.
									; So we used a constant number
                MOVS r1,#32	 		; r1 = 32
				MULS r0,r1,r0		; r0 = 20 * 32
				MOVS r1,#0			; r1 = 0, index
				MOVS r3,#0			; r3 = 0
clear           LDR r2,=ARRAY_MEM	; r2 = ARRAY_MEM address
                STR r3,[r2,r1]		; ARRAY_MEM[r1] = r3
                ADDS r1,r1,#4		; r1 = r1 + 4
                CMP r0,r1			; compare r0 and r1
                BGT clear			; if r0 > r1 branch to clear
				LDR r3,=FIRST_ELEMENT;r3 = FIRST_ELEMENT address
				LDR r4,[r3]			; inside FIRST_ELEMENT load r4
				PUSH{r4} 			; Push r4
				LDR r4,[r4]			; r4 = FIRST_ELEMENT's value
				CMP r4,#0			; compare r4 and null
				POP{r4} 			; Pop r4
				BEQ linklist_error	; if FIRST_ELEMENT's value and null branch to linklist_error
				MOVS r1,#0			; r1 = 0
				
add_data		CMP r4,#0			; compare FIRST_ELEMENT's value and null 
				BEQ end_function	; if FIRST_ELEMENT's value and null branch to end_function
				LDR r5,[r4]			; linked list data load to r5
				STR r5,[r2,r1]		; ARRAY_MEM[r1] = linked list data
				ADDS r1,r1,#4		; r1 = r1 + 4;
				ADDS r4,r4,#4		; r4 = r4 + 4;
				LDR r4,[r4]			; linked list data load to r4
				B add_data			; branch to add_data
			
linklist_error	MOVS r0,#5			; r0 = error code
				BX LR				; branch handler

end_function    MOVS r0,#0			; r0 = error code
				BX LR				; branch handler
			


                ENDFUNC
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				PUSH{LR}					; to return the address that is WriteErrorLog called.
				LDR r4,=INDEX_ERROR_LOG		; r4 = address of INDEX_ERROR_LOG	
				LDR r4,[r4]					; r4 = INDEX_ERROR_LOG
				PUSH{r4}					; to save INDEX_ERROR_LOG
				MOVS r5,#12					; to use in multiplication
				MULS r4,r5,r4				; each errorlog has 12 byte
				LDR r5,=LOG_MEM				; r5 = Initial address of LOG_MEM
				STRH r0,[r5,r4]				; LOG_MEM [INDEX_ERROR_LOG,#0] = Index of Input Dataset Array
				ADDS r4,r4,#2				; r4 = r4 + 2 bytes 
				STRB r1,[r5,r4]				; LOG_MEM [INDEX_ERROR_LOG,#2] = Error Code
				ADDS r4,r4,#1				; r4 = r4 + 1 byte
				STRB r2,[r5,r4]				; LOG_MEM [INDEX_ERROR_LOG,#3] = Operation
				ADDS r4,r4,#1				; r4 = r4 + 1 byte
				STR r3,[r5,r4]				; LOG_MEM [INDEX_ERROR_LOG,#4] = Data
				ADDS r4,r4,#4				; r4 = r4 + 4 byte
				BL GetNow					; call GetNow to get Timestamp
				STR  r0,[r5,r4]				; LOG_MEM [INDEX_ERROR_LOG,#8] = Timestamp
				POP{r4}						; r4 = INDEX_ERROR_LOG again
				ADDS r4,r4,#1				; INDEX_ERROR_LOG ++
				LDR r5,=INDEX_ERROR_LOG		;
				STR r4,[r5]					;
				POP{PC}						; return the link register that WriteErrorLog is called
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				LDR r1,=0xE000E018
				LDR r1,[r1]
				LDR r2,=TICK_COUNT
				LDR r2,[r2]
				LDR r3,=0xE000E014
				LDR r3,[r3]	
				SUBS r2,r2,#1
				MULS r3,r2,r3
				ADDS r0,r1,r3
				LSRS r0,r0,#2
				BX LR
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															

OBTAIN_ERROR	FUNCTION													
				PUSH {LR}
				LDR r0,=TICK_COUNT
				LDRH r0,[r0]
				SUBS r0,r0,#1
				LSLS r0,r0,#2
				LDR r2,=IN_DATA_FLAG
				LDRB r2,[r2,r0]
				LDR r3,=IN_DATA
				LDR r3,[r3,r0]
				LSRS r0,r0,#2
				BL WriteErrorLog  ; brachi kontrol et
				POP{PC}
				ENDFUNC

;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

