.data 
number_lookup:
	.word 0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7c,0x07,0x7f,0x67
vga_look:
	.asciz "0123456789"
.text

store:
	push {r10,r6,r4}
	mov r0,#0// thousand
	mov r1,#0//hundred
	mov r2,#0//tens
	ldr r3,=0//ones
	ldr r6,[r4]
	and r3, r6,r10
	lsr r6,r6,#1
	and r2,r6,r10
	lsr r6,r6,#1
	and r1,r6,r10
	lsr r6,r6,#1
	and r0,r6,r10
	pop {r10,r6,r4}
	bx lr

convert:
	push {r7}
thousand:
	cmp r0,#1
	bne hundred
	add r7,r7,#1000
	b hundred
hundred:
	cmp r1,#1
	bne tens
	add r7,r7,#100
	b tens
tens:
	cmp r2,#1
	bne ones
	add r7,r7,#10
	b ones
ones:
	cmp r3,#1
	bne return
	add r7,r7,#1
	b return
return:
	mov r0,r7
	pop {r7}
	bx lr

division:
	push {r7,r8,r9,r11,r12}
	mov r1,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	mov r12,#0
Comp1000:
	cmp r0,#1000 //compares counter to 1000
	blt assign0_1000// if the counter is less than 1000 we jump to the assign zero section
	subs r0,r0,#1000// division steps
	add r7,r7,#1
	cmp r0,#1000
	bge Comp1000// if the number can be divided again we continue to divide and loop to the start of the function again
	lsls r7,r7,#2// multiply the value of hundreds given by 4 to match the ofset for the lookup table
	ldr r8,[r11,r7]// using pre indexing we offset the original address to get desired value
	lsls r8,r8,#24// shift the value obtained from the lookup table to match hundreds position
	add r1,r1,r8// add to r1 to display later
	b Comp100
assign0_1000://this assigns the hundreds value to zero when no thousands are present
	ldr r8,[r11]
	lsls r8,r8,#24
	add r1,r1,r8
	b Comp100// we jump to comp10 to check where the 10s value may or may not be
Comp100:
	cmp r0,#100 //compares counter to 100
	blt assign0_100// if the counter is less than 100 we jump to the assign zero section
	subs r0,r0,#100// division steps
	add r9,r9,#1
	cmp r0,#100
	bge Comp100// if the number can be divided again we continue to divide and loop to the start of the function again
	lsls r9,r9,#2// multiply the value of hundreds given by 4 to match the ofset for the lookup table
	ldr r8,[r11,r9]// using pre indexing we offset the original address to get desired value
	lsls r8,r8,#16// shift the value obtained from the lookup table to match hundreds position
	add r1,r1,r8// add to r1 to display later
	b Comp10
assign0_100://this assigns the hundreds value to zero when no hundreds are present
	ldr r8,[r11]
	lsls r8,r8,#16
	add r1,r1,r8
	b Comp10// we jump to comp10 to check where the 10s value may or may not be
Comp10:
	cmp r0,#10//compares counter to 10
	blt assign0_10// if the counter is less than 10 we jump to the assign zero section
	subs r0,r0,#10// division steps
	add r12,r12,#1
	cmp r0,#10
	bge Comp10// if the number can be divided again we continue to divide and loop to the start of the function again
	lsls r12,r12,#2// multiply the value of tens given by 4 to match the ofset for the lookup table
	ldr r8,[r11,r12]// using pre indexing we offset the original address to get desired value
	lsls r8,r8,#8// shift the value obtained from the lookup table to match tens position
	add r1,r1,r8// add to r5 to display later
	b sumcheck
assign0_10://this assigns the tens value to zero when no tens are present
	ldr r8,[r11]
	lsls r8,r8,#8
	add r1,r1,r8
	b sumcheck// we jump to sumcheck to count the ones value may or may not be
sumcheck:
	lsls r0,r0,#2// multiply the value of ones given by 4 to match the ofset for the lookup table
	ldr r8,[r11,r0]// using pre indexing we offset the original address to get desired value
	add r1,r1,r8// add to r1 to display later
	pop {r7,r8,r9,r11,r12}
	bx lr

delay:
	push {r8}
	ldr r8,=2000000
run:
	subs r8,r8,#1
	bne run
	pop {r8}
	bx lr
	
onePixel:
	PUSH {r12}
	MOV r12, #0
	ADD r12, r9, LSL #1
	ADD r12, r10, LSL #10
	STRH r2, [r7,r12]
	POP {r12}
	Bx lr

number_writer:
	push {r3,r6,r8,r9,r10,r12}
write1000:
	mov r3,#0
run1:
	cmp r0,#1000 //compares counter to 1000
	blt write0_1000// if the counter is less than 1000 we jump to the assign zero section
	subs r0,r0,#1000// division steps
	add r3,r3,#1
	cmp r0,#1000
	bge run1// if the number can be divided again we continue to divide and loop to the start of the function again
	ldrb r2,[r6,r3]// using pre indexing we offset the original address to get desired value
	MOV r12, #0 
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write100
write0_1000://this assigns the hundreds value to zero when no thousands are present
	ldrb r2,[r6]
	MOV r12, #0 
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write100// we jump to comp10 to check where the 10s value may or may not be
write100:
	mov r3,#0
	add r9,r9,#1
run2:
	cmp r0,#100 //compares counter to 100
	blt write0_100// if the counter is less than 100 we jump to the assign zero section
	subs r0,r0,#100// division steps
	add r3,r3,#1
	cmp r0,#100
	bge run2// if the number can be divided again we continue to divide and loop to the start of the function again
	ldrb r2,[r6,r3]// using pre indexing we offset the original address to get desired value
	MOV r12, #0 // r5 offset
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write10
write0_100://this assigns the hundreds value to zero when no hundreds are present
	ldrb r2,[r6]
	MOV r12, #0 
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write10// we jump to comp10 to check where the 10s value may or may not be
write10:
	mov r3,#0
	add r9,r9,#1
run3:
	cmp r0,#10//compares counter to 10
	blt write0_10// if the counter is less than 10 we jump to the assign zero section
	subs r0,r0,#10// division steps
	add r3,r3,#1
	cmp r0,#10
	bge run3// if the number can be divided again we continue to divide and loop to the start of the function again
	ldrb r2,[r6,r3]// using pre indexing we offset the original address to get desired value
	MOV r12, #0 // r5 offset
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write_1
write0_10://this assigns the tens value to zero when no tens are present
	ldrb r2,[r6]
	MOV r12, #0 // r5 offset
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	b write_1// we jump to sumcheck to count the ones value may or may not be
write_1:
	add r9,r9,#1
	ldrb r2,[r6,r0]// using pre indexing we offset the original address to get desired value
	MOV r12, #0 // r5 offset
	ADD r12, r10, LSL #7
	ADD r12, r12, r9
	STRB r2, [r8,r12]
	pop {r3,r6,r8,r9,r10,r12}
	bx lr

.equ swtch_ctrl, 0xff200040
.equ hex_ctrl, 0xff200020
.equ paint,0xc8000000
.equ write,0xc9000000
.global _start
_start:
	ldr r4,=swtch_ctrl
	ldr r5,=hex_ctrl
	ldr r11,=number_lookup
	mov r6,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	mov r10,#0x01
	mov r12,#0
	
	bl store 
	bl convert
again:
	push {r0}
	cmp r0,#0
	blt stop
	bl division
	str r1,[r5]
	pop {r0}
	push {r0,r2,r6,r7,r8,r9,r10,r12}
	ldr r6,=vga_look
	ldr r7,=paint
	ldr r8,=write
	mov r10,#0//y
	ldr r2,=0x7098
	mov r12,#0
loopY:
	MOV r9, #0//x
loopX:
	BL onePixel
	CMP r9, #200
	ADD r9, #1
	BNE loopX
	CMP r10, #200
	ADD r10, #1
	BNE loopY
	MOV r10, #1
	MOV r9, #1
	BL number_writer
	bl delay
	pop {r0,r2,r6,r7,r8,r9,r10,r12}
	sub r0,r0,#1
	b again

stop:
	b stop
.end	