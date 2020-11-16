


section .text
  align 16
  global main
  global targetX
  global targetY
  global rounds
  global destroy_distance
  global drone
  global stack_size
  global randint
  global working_drone
  global get_random_number
  global CO_scheduler
  global CO_target
  global CO_printer
  global COi_drone_array
  global k_to_print
  global drones_list
  global nDrones
  global drone_func
  global endCo
  global finish_main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern sscanf
  extern stderr
  extern run_drone
  extern run_printer
  extern run_scheduler
  extern run_target
  extern do_resume

section .data
    format_string: db "%s", 10, 0
    format_int: db "%d", 0
    format_float: db "%f", 0
    format_all: dd "%d %d", 0
    nDrones: dd 0
    rounds: dd 0
    k_to_print: dd 0
    stack_size: equ 16*1024
    destroy_distance: dd 1.1 ;float
    seed: dd 0
    randint: dd 0
    targetX: dd 0
    targetY: dd 0
    drone_func: dd run_drone
    CO_target: dd run_target
                dd target_stack+stack_size
    CO_printer: dd run_printer
                dd stack_size+printer_stack
    CO_scheduler: dd run_scheduler
                    dd stack_size+scheduler_stack

    drone_start:
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
    drone_len: equ $ - drone_start

section .bss
    beta_angle: resd 1 ;float
    working_drone: resd 1
    drones_list: resd 1
    target: resd 1
    target_stack: resb stack_size
    drone_stack: resb stack_size
    printer_stack: resb stack_size
    scheduler_stack: resb stack_size
    COi_drone_array: resd 1
    SPT: resd 1  
    SPMAIN: resd 1


section .text


init_drones:
    push ebp
	mov ebp, esp
    pushad   

    mov ebx, 0
    mov dword[drones_list], 0
    init_drones_loop:
        cmp ebx, dword[nDrones]
        jz finish_init_drones
        push ebx
        push 32         ; TODO check if need to edit
        call malloc
        add esp, 4
        pop ebx
        mov dword[eax + id], ebx
        mov dword[eax + destroyed], 0
        mov dword[eax + kills], 0

        push 100
        call get_random_number
        mov ecx, dword[randint]
        mov dword[eax + x], ecx

        push 100
        call get_random_number
        mov ecx, dword[randint]
        mov dword[eax + y], ecx

        push 100  
        call get_random_number
        mov ecx, dword[randint]
        mov dword[eax + speed], ecx
        

        push 360 
        call get_random_number
        mov ecx, dword[randint]
        mov dword[eax + heading], ecx

        mov dword[eax + next], 0

        insert_drone:
            mov edx, dword[drones_list]
            cmp edx, 0
            jnz not_empty_list
            mov dword[drones_list], eax
            inc ebx
            jmp init_drones_loop

        not_empty_list:
            cmp dword[edx + next] ,0
            jz insert_here
            mov edx, dword[edx + next]
            jmp not_empty_list

        insert_here:
            mov dword[edx + next], eax
            inc ebx
            jmp init_drones_loop

    finish_init_drones:
        popad
        mov esp, ebp
        pop ebp
        ret 

init_drones_coi:
    push ebp
	mov ebp, esp
    pushad 

    mov eax , dword[nDrones]
    mov ebx, 8
    mul ebx                ;malloc the size of all the drone coi
    push eax
    call malloc
    add esp, 4
    mov dword[COi_drone_array] ,eax

    mov edi, 0
init_drones_coi_loop:
    cmp edi, dword[nDrones]
    jz finish_init_drones_coi
    mov ebx, dword[COi_drone_array] ; we got the drone
    mov eax, 8
    mul edi
    add ebx, eax

    mov edx , run_drone
    mov dword[ebx], edx ; TODO check if pointer

    push stack_size  
    call malloc
    add esp, 4
    add ebx, 4 ;pointer to stack
    mov dword[ebx], eax ;put the drone stack
  
    sub ebx, 4
    mov eax , [ebx] ;get pointer of the function
    mov [SPT] , esp
    mov esp , dword[ebx + 4]

    push eax
    pushfd
    pushad
    mov dword[ebx + 4], esp
    mov esp ,[SPT]

    inc edi
    jmp init_drones_coi_loop


finish_init_drones_coi:
        popad
        mov esp, ebp
        pop ebp
        ret 


init_target:
    push ebp
	mov ebp, esp
    pushad 

    push 100
    call get_random_number
    mov ecx, dword[randint]
    mov dword[targetX], ecx

    push 100
    call get_random_number
    mov ecx, dword[randint]
    mov dword[targetY], ecx   

    ;init coi
    mov dword ebx , CO_target ;get pointer of the struct
    mov eax , dword[ebx] ;get pointer of the function
    mov dword[SPT] , esp
    mov esp ,dword [ebx+4]
    push eax
    pushfd
    pushad
    mov [ebx+4], esp
    mov esp ,[SPT]

    finish_init_target:
        popad
        mov esp, ebp
        pop ebp
        ret 


init_printer:
    push ebp
	mov ebp, esp
    pushad 

    ;init coi
    mov dword ebx , CO_printer ;get pointer of the struct
    mov eax , dword[ebx] ;get pointer of the function
    mov dword[SPT] , esp
    mov esp ,dword [ebx+4]
    push eax
    pushfd
    pushad
    mov [ebx+4], esp
    mov esp ,[SPT]

    finish_init_printer:
        popad
        mov esp, ebp
        pop ebp
        ret 



init_scheduler:
    push ebp
	mov ebp, esp
    pushad 

    ;init coi

    mov dword ebx , CO_scheduler ;get pointer of the struct
    mov eax , dword[ebx] ;get pointer of the function
    mov dword[SPT] , esp
    mov esp ,dword [ebx+4]
    push eax
    pushfd
    pushad
    mov [ebx+4], esp
    mov esp ,[SPT]

    finish_init_scheduler:
        popad
        mov esp, ebp
        pop ebp
        ret 

get_random_seed:
    push    ebp           
    mov     ebp, esp        
    pushad   

    mov cx, word[seed]

    ; bit 16
    mov bx, 1
    and bx, cx

    ;bit 14
    mov dx, 4
    and dx, cx
    shr dx, 2

    xor bx, dx          ; XOR with bit 14,16

    ;bit 13
    mov dx, 8
    and dx, cx
    shr dx, 3

    xor bx, dx          ; XOR with bit 13 (14,16)

    ;bit 11
    mov dx, 32
    and dx, cx
    shr dx, 5

    xor bx, dx          ; XOR with bit 11 (13,14,16)

    shr cx, 1

    cmp bx, 1
    jnz finish_random_seed
    add cx, 32768       ; 2^15

    finish_random_seed:
        movzx ebx, cx
        mov dword[seed], ebx
        mov dword[randint], ebx   
        popad                             
        pop ebp             
        ret                    

get_random_number:
    push ebp            
    mov ebp, esp
    pushad

    mov edx, 0
    loop_seed:
        cmp edx, 16
        jz seed_is_ready
        call get_random_seed
        inc edx
        jmp loop_seed

    seed_is_ready:
        fild dword[randint]
        mov ebx, [ebp + 8]    ;arg 1
        mov dword[randint], ebx
        fimul dword[randint]
        mov dword[randint], 65535      ;2^16
        fidiv dword[randint]
        fstp dword[randint]

    popad
    mov esp, ebp
    pop ebp
    ret 4


startCo:
    pushad
    mov dword[SPMAIN] , esp
    mov dword ebx , CO_scheduler
    jmp do_resume
    
endCo:
    mov esp, [SPMAIN]
    popad
    jmp finish_main




_start:
main:
    push ebp            
    mov ebp, esp
    pushad

    finit

    mov ebx, dword[ebp + 12]            ; argv
    mov ecx, dword[ebx + 4]             ; argv[0] number of drones (int)
    push nDrones
    push format_all
    push ecx
    call sscanf
    add esp, 12

    mov ecx, dword[ebx + 8]             ; argv[1] rounds (int)
    push rounds
    push format_int
    push ecx
    call sscanf
    add esp, 12

    mov ecx, dword[ebx + 12]             ; argv[2] k to print (int)
    push k_to_print
    push format_int
    push ecx
    call sscanf
    add esp, 12

    mov ecx, dword[ebx + 16]             ; argv[3] destory distance (float)
    push destroy_distance
    push format_float
    push ecx
    call sscanf
    add esp, 12

    mov ecx, dword[ebx + 20]             ; argv[4] seed (int)
    push seed
    push format_int
    push ecx
    call sscanf
    add esp, 12
    call init_target
    call init_drones
    call init_drones_coi
    call init_printer
    call init_scheduler
    call startCo
   


finish_main:
    mov ebx , 0 
    mov eax ,1
    int 0x80
    nop 
    ret
