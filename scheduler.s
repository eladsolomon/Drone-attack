

section .bss
  curr: resd 1

section .data
  	format_winner: db "The Winner is , drone number: %d", 10, 0
	drone_func: dd run_drone
	steps: dd 0
	drone_i: dd 0
	destroyed_drones: dd 0
	destroyed_d: dd 0
	rounds_passed: dd 0
	struc drone
		id: resd 1
		destroyed: resd 1
		kills: resd 1
		x: resd 1
		y: resd 1
		heading: resd 1
		speed: resd 1
		next: resd 1
	endstruc

section .text
	align 16
	global main
	extern printf
	extern fprintf 
	extern fflush
	extern malloc 
	extern calloc 
	extern free 
	extern sscanf
	extern stderr
	extern drones_list
	extern k_to_print
	global run_scheduler
	global do_resume
	global resume
	extern working_drone
	extern CO_printer
	extern COi_drone_array
	extern nDrones
	extern run_drone
	extern rounds
	extern endCo
	


run_scheduler:
	drones_co_rots:
		mov dword ebx, [COi_drone_array]
		mov eax, dword[drone_i]
		cmp eax, dword[nDrones]
		jnz keep_looping
		inc dword[rounds_passed]
		mov eax, dword[rounds_passed]
		cmp eax, dword[rounds]
		jz elemination
	continuation:
		mov dword[drone_i], 0
		mov eax, 0
		keep_looping:
			call get_i_drone
			mov ecx, 8
			mul ecx
			add ebx, ecx
			call resume

			inc dword[drone_i]
			inc dword[steps]
			mov edx, dword[steps]
			cmp edx, dword[k_to_print]
			jz printer_co_rot
			jmp drones_co_rots

	printer_co_rot:
		mov dword ebx, CO_printer
		call resume
		mov dword[steps], 0
		jmp drones_co_rots


elemination:
	inc dword[destroyed_d]
	mov dword[drone_i], 0
	mov edx, 0x7FFFFFFF					; minimum kills
	find_the_noob:
		mov eax, dword[drone_i]
		cmp eax, dword[nDrones]
		jz found_minimum_kills
		call get_i_drone
	
		mov eax, dword[working_drone]
		cmp dword[eax+destroyed],1
		je not_the_minimum
		check:
		cmp edx, dword[eax + kills]
		jl not_the_minimum 
	min:	
		mov edx,  dword[eax + kills]
	not_the_minimum:
		inc dword[drone_i]
		jmp find_the_noob

	found_minimum_kills:
		mov dword[drone_i], 0
		eliminate_the_noob:
			call get_i_drone
			mov eax, dword[working_drone]
			cmp dword[eax + destroyed], 1
			jz already_destoryed
			cmp edx, dword[eax + kills]
			je found_noob
			;mov edx ,[nDrones]
			;cmp edx,[drone_i]
			;jz eliminate_the_noob
			; mov ecx ,dword[nDrones]
			; sub ecx , 1
			; cmp eax ,drone_i
			; jz found_noob
			inc dword[drone_i]
			jmp eliminate_the_noob

	already_destoryed:
		;inc dword[destroyed_drones]
		;mov ecx, dword[destroyed_drones]
		;cmp ecx, dword[nDrones]
		;jz finish
		inc dword[drone_i]
		jmp eliminate_the_noob

	found_noob: ;noob in in eax
		mov dword[eax + destroyed], 1
		mov dword[rounds_passed], 0
		mov dword[destroyed_drones], 0
		mov ecx, dword[destroyed_drones]
		mov eax ,[destroyed_d]
		mov edx ,[nDrones]
		sub edx , eax
		cmp edx ,1
		jz finish
		jmp continuation



resume:
    pushfd
    pushad
    mov edx,[curr] ; before call resume put in edx the runing coi and put in curr what we want to remember
    mov [edx+4],esp
do_resume:
    mov esp ,[ebx+4]  ;go to function
    mov [curr],ebx
    popad
    popfd
    ret



get_i_drone:
	push ebp
	mov ebp, esp
    pushad  

	mov ecx, dword[drone_i]
	mov eax, 0
	mov ebx, dword[drones_list]
	mov dword[working_drone], ebx
	mov ebx, dword[working_drone]

	get_drone_loop:
		cmp eax, ecx
		jz got_working_drone
		mov ebx, dword[ebx + next]
		inc eax
		jmp get_drone_loop


	got_working_drone:
		mov dword[working_drone], ebx
		popad
        mov esp, ebp
        pop ebp
        ret 

finish:
	mov ebx, dword[drones_list]
	mov dword[working_drone], ebx
	mov ebx, dword[working_drone]
	get_drone_winner:
		cmp dword[ebx+destroyed], 0
		jz got_winner
		mov ebx, dword[ebx + next]
		jmp get_drone_winner
	got_winner:
		mov ebx, [ebx]
		push  ebx
		push format_winner
		call printf
		add esp ,8
	call endCo

finish_main:
    popad
    mov esp, ebp       
    pop ebp
    ret