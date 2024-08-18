TITLE String Primitives & Macros    (Proj6_emburyj.asm)

; Author: Josh Embury
; Last Modified: 03/16/2024
; OSU email address: emburyj@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 6                Due Date: 03/17/2024
; Description: This program uses macros and procedures to prompt the user to input signed integers (10 times),
;				validates the input value is of appropriate size and format, converts the input string to a SDWORD, and
;				stores the integers in an array. The program procedes to display the values that the user input by
;				converting the signed integer values to strings and printing them to the console. The sum and truncated average
;				of the input values are displayed to the user as well. Arrays are processed and manipulated using primitive functions.

INCLUDE Irvine32.inc

; (insert macro definitions here)
; ---------------------------------------------------------------------------------
; Name: mGetString

; Description: This macro uses WriteString (Irvine Procedure) to prompt user for an input.
;				Then reads the user's input in the console using ReadString (Irvine Procedure)
;				and stores the string into memory. Stores size of the input to memory.

; Postconditions: Prompt is displayed to console and user's input is stored in provided memory locations.

; Receives: Three inputs by reference:
;			1. promptAddr: Memory location of prompt string to display to user.
;			2. outputAddr: Memory location for user's input to be stored.
;			3. outputSize: Memory location for size of user's input to be stored.

; Returns: outputAddr: BYTE array User's input string is written to this address location.
;		   outputSize: DWORD Size of user's input string is written to this address location.

; ---------------------------------------------------------------------------------
mGetString MACRO	promptAddr:REQ,	outputAddr:REQ, outputSize
	; preserve registers
	PUSH EAX
	PUSH ECX
	PUSH EDX

	; prompt user for input
	MOV EDX, promptAddr
	CALL WriteString


	; retrieve user input
	MOV EAX, 0
	MOV EDX, outputAddr ; address location for string to be stored
	MOV ECX, 12
	CALL ReadString ; input string stored to memory
	CALL CrLf
	
	; store size of input to memory
	MOV [outputSize], EAX
	
	; restore registers
	POP EDX
	POP ECX
	POP EAX
ENDM

; ---------------------------------------------------------------------------------
	; Name: mDisplayString

	; Description: This macro prints a string to the console.

	; Postconditions: String printed to console.

	; Receives: One input by reference:
	;			1. stringAddr = address location of string to be printed.

	; Returns: Void
; ---------------------------------------------------------------------------------
mDisplayString MACRO stringAddr:REQ
	PUSH EDX ; save register to call stack

	MOV EDX, stringAddr
	CALL WriteString
	POP EDX ; clean up the call stack

ENDM

; (insert constant definitions here)
MAX_INPUT_SIZE = 12
NUMBER_OF_INPUTS = 10
.data

; (insert variable definitions here)
welcomeStr	  BYTE "Programming Project 6: Designing low-level I/O procedures. ", 13, 10,
				   "Author: Josh Embury.", 13,10,0
instructStr   BYTE "Please provide signed integers when prompted. Each ",
				   "number needs to be small enough to fit inside a 32 bit ",
				   "register. After you input the integers, I will display the ",
				   "list of integers you input, their sum, and their truncated average.", 13, 10, 0
promptStr     BYTE "Please enter a signed number: ", 0
errorStr      BYTE "INVALID INPUT: You didn't input a signed integer or your input was too large to handle!", 13, 10, 0
resultsStr1	  BYTE "You entered the following numbers: ", 13, 10, 0
resultsStr2   BYTE "The sum of these numbers is: ", 0
resultsStr3   BYTE "The truncated average is: ", 0
farewellStr	  BYTE "That is a nice set of numbers. Thank you for choosing CS271. Goodbye!", 13, 10, 0

commaStr	  BYTE ", ", 0
userInputStr  BYTE 13 DUP(?)
userInputSize DWORD ?
userInputInt  SDWORD 0

outputStr     BYTE 11 DUP(?) ; maximum length of a signed integer represented as a string is 11 chars including null terminator

inputArray    SDWORD NUMBER_OF_INPUTS DUP(?)
inputAvg      SDWORD ?
inputSum	  SDWORD ?

.code
main PROC
	; Display welcome and instructions
	mDisplayString OFFSET welcomeStr
	
	mDisplayString OFFSET instructStr
	CALL CrLf

	; Get user input, convert to signed int, and store in array
	MOV ECX, NUMBER_OF_INPUTS
	MOV EDI, OFFSET inputArray
	_get_vals:		
		PUSH OFFSET errorStr
		PUSH OFFSET userInputInt 
		PUSH OFFSET userInputSize 
		PUSH OFFSET userInputStr
		PUSH OFFSET promptStr
		CALL ReadVal
		MOV EAX, userInputInt

		CLD ; clear dir flag to move fwd through array
		STOSD ; store EAX to array
		LOOP _get_vals
	
	; Display the input values (convert signed int to str and print to console)
	MOV ECX, NUMBER_OF_INPUTS
	MOV ESI, OFFSET inputArray
	mDisplayString OFFSET resultsStr1
	_show_vals:
		CLD
		LODSD
		PUSH EAX
		PUSH OFFSET outputStr
		CALL WriteVal
		CMP ECX, 1
		JNE _loopBack
		JMP _calculate
		_loopBack:
			; fencepost to display ', '
			DEC ECX
			mDisplayString OFFSET commaStr
			JMP _show_vals
	
	; calculate sum and average of inputs
	_calculate:
		CALL CrLf
		PUSH OFFSET inputAvg
		PUSH OFFSET inputSum
		PUSH OFFSET inputArray
		CALL calculateStats

	; display sum and average of inputs
	_finish:
		mDisplayString OFFSET resultsStr2
		PUSH inputSum
		PUSH OFFSET outputStr
		CALL WriteVal
		CALL CrLf
		mDisplayString OFFSET resultsStr3
		PUSH inputAvg
		PUSH OFFSET outputStr
		CALL WriteVal

	; display farewell string
	CALL CrLf
	mDisplayString OFFSET farewellStr
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)
; ---------------------------------------------------------------------------------
; Name: ReadVal

; Description: This procedure calls the mGetString macro. From the macro it
;				receives a string representing a signed integer. The string is
;				validated by checking if it will fit in 32 bit register and that string only
;				contains numerical characters. Optional for string to lead with '+' or '-'.
;				Displays error message if invalid input. Otherwise, converts string to SDWORD
;				and stores to memory. Uses a local DWORD array as a placeholder for digits
;				processed from string. Uses a local SDWORD as a sign flag to keep track of 
;				sign of input value.

; Preconditions: Input parameters are pushed to the call stack.

; Postconditions: and call stack cleaned.

; Receives: 5 parameters pushed to the call stack in the following order:
;			1. Memory address of BYTE array string to be displayed as error message.
;			2. Memory address to store the SDWORD int converted from string
;			3. Memory address location of DWORD size of input string.
;			4. Memory address location of BYTE array string to be converted to int (passed to mGetString).
;			5. Memory addres of BYTE array string to prompt user for input (passed to mGetString).

; Returns: Converted signed integer SDWORD gets stored to userInputInt memory address.

; ---------------------------------------------------------------------------------
ReadVal PROC
	LOCAL tempArray[MAX_INPUT_SIZE]:DWORD, signFlag:SDWORD
	; signFlag is either 1 or -1
	; preserve registers
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH ESI
	PUSH EDI
	_input:
		; get input from user
		MOV [signFlag], 1 ; initialize sign flag to positive
		mGetString [EBP + 8], [EBP + 12], [EBP + 16] ; prompt address, address for storing string, address for storing string size
		MOV EAX, [EBP + 16]
		MOV ESI, [EBP + 12]
		MOV EDI, [EBP + 20]
		MOV EAX, 0
		MOV [EDI], EAX
		LEA EDI, tempArray
		MOV ECX, [EBP + 16]
		; check first item in user's input if +/-
		MOV EAX, 0
		MOV AL, [ESI]
		CMP AL, 43
		JE _positive
		CMP AL, 45
		JE _negative
		
		_stringParse:
			MOV EAX, [EBP + 16]
			MOV EAX, 0
			CLD
			LODSB
			SUB AL, 48
			; check if input char is valid
			CMP AL, 0
			JL _charError
			CMP AL, 9
			JG _charError
			; if valid char then continue
			STOSD
			LOOP _stringParse
		JMP _next
		_positive:
			; if you're here, a '+' was input as the first char
			LODSB
			DEC ECX
			MOV [EBP + 16], ECX ; decrement the value on stack (represents num of digits in user's input)
			JMP _stringParse
		_negative:
			; if you're here, a '-' was input as the first char
			LODSB
			DEC ECX
			MOV [EBP + 16], ECX ; decrement the value on stack (represents num of decimals in user's input)
			MOV [signFlag], -1 ; set the sign flag to negative
			JMP _stringParse
		_charError:
			; display error string
			mDisplayString [EBP + 24] ; offset to error string
			MOV [signFlag], 1
			JMP _input
	_next:
		MOV ECX, [EBP + 16]
		MOV EBX, [signFlag] ; decimal placeholder in EBX
		MOV ESI, EDI
		SUB ESI, 4
		_accumulate:
			MOV EAX, 0
			STD
			LODSD
			IMUL EBX
			MOV EDX, [EBP + 20]
			ADD EAX, [EDX]
			JO _overFlowError
			MOV [EDX], EAX
			MOV EAX, EBX
			MOV EDX, 10
			IMUL EDX
			MOV EBX, EAX
			LOOP _accumulate
		JMP _finish
	_overFlowError:
		MOV EBX, 1
		MOV [signFlag], EBX
		MOV EBX, 0
		MOV EDX, [EBP + 20]
		MOV [EDX], EBX
		; display error string
		mDisplayString [EBP + 24] ; offset to error string
		JMP _input

	_finish:
		; restore registers
		POP EDI
		POP ESI
		POP EDX
		POP ECX
		POP EBX
		POP EAX
		RET 20 ; clean up the call stack
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal

; Description: This procedure receives a SDWORD signed integer as input,
;				converts the value to a string represetation, and calls the 
;				mDisplayString macro to display the converted string.
;				Uses a local DWORD array as a placeholder for digits
;				processed from input integer. Uses a local SDWORD as a sign  
;				flag to keep track of sign of input value.

; Preconditions: All input parameters are pushed to the call stack.

; Postconditions: String representing the input integer is printed to the console and the call stack is cleaned.

; Receives: Receives 2 input parameters pushed to the call stack in the following order:
;			1. SDWORD integer value representing integer to be converted.
;			2. Memory address location for converted BYTE array string to be stored.

; Returns: Converted BYTE array string stored in memory address provided.

; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL tempArray[11]:DWORD, signFlag:SDWORD
	; signFlag is +1 or -1
	; preserve registers
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH ESI
	PUSH EDI

	MOV [signFlag], 1 ; default sign is positive
	MOV [tempArray], 0 ; initialize first index to 0
	LEA EDI, tempArray
	MOV EAX, [EBP + 12]
	MOV ECX, 0 ; used to track number of digits in input value
	CMP EAX, 0
	JGE _loop1
	NEG EAX
	MOV [signFlag], -1
	_loop1:
		CMP EAX, 0
		JE _zeroCheck
		MOV EDX, 0
		MOV EBX, 10
		DIV EBX
		PUSH EAX ; preserve quotient on stack
		MOV EAX, EDX
		; store remainder in tempArray
		CLD
		STOSD
		POP EAX ; restore quotient from stack
		INC ECX
		JMP _loop1
	_zeroCheck:
		MOV ESI, EDI
		MOV EDI, [EBP + 8] ; address output string array
		CMP ECX, 0
		JNE _signCheck
		INC ECX
		JMP _loop2
		_signCheck:
			SUB ESI, 4 ; move ESI to last value in tempArray
			; write a '-' depending on sign flag
			CMP [signFlag], 1
			JE _loop2
			MOV EAX, 45
			STOSB

	_loop2:
		MOV EAX, 0
		; traverse backward through tempArray and load to EAX
		STD
		LODSD

		ADD EAX, 48 ; convert integer value to ascii value

		; traverse forward through output string array and store EAX
		CLD
		STOSB

		LOOP _loop2
	;JMP _finish
		
	_finish:
		; add the null terminator
		MOV EAX, 0
		CLD
		STOSB
		mDisplayString [EBP + 8] ; display string
		; restore registers
		POP EDI
		POP ESI
		POP EDX
		POP ECX
		POP EBX
		POP EAX
		RET 8 ; clean up call stack
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: calculateStats

; Description: This procedure takes a SDWORD array of integers as input and calculates the sum and
;				average of the values stored in the array. The sum and average values are stored in
;				memory address locations provided.

; Preconditions: Input parameters are pushed to the call stack.

; Receives: 3 input parameters pushed to the call stack in the following order:
;			1. Memory address to store the DWORD representing the average of the values stored in the input array.
;			2. Memory address to store the DWORD representing the sum of the values stored in the input array.
;			2. Memory address of the SDWORD array of integers from which to calculate sum and average values.

; Returns: Sum and average values, stored as SDWORD integers, written to memory in the provided address locations.
; ---------------------------------------------------------------------------------
calculateStats PROC
	PUSH EBP
	MOV EBP, ESP
	; preserve registers
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH ESI
	PUSH EDI

	MOV ECX, NUMBER_OF_INPUTS
	MOV EBX, 0
	MOV ESI, [EBP + 8]
	; loop through input array and calculate sum
	_accum:
		CLD
		LODSD
		ADD EBX, EAX
		LOOP _accum
	MOV EDI, [EBP + 12]
	MOV [EDI], EBX ; store sum
	MOV EAX, EBX
	MOV EBX, NUMBER_OF_INPUTS
	CDQ
	IDIV EBX ; calculate avg
	MOV EDI, [EBP + 16]
	MOV [EDI], EAX ; store avg

	_finish:
		; restore registers
		POP EDI
		POP ESI
		POP ECX
		POP EBX
		POP EAX
		POP EBP
		RET 12 ; clean up the call stack
calculateStats ENDP

END main