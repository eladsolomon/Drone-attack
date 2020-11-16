section .data
    mayDestory: dd 0
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
    global run_target
    global mayDestroy
    extern working_drone
    extern targetX
    extern targetY
    extern get_random_number
    extern randint
    extern destroy_distance
    extern CO_scheduler
    extern resume


    run_target:
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

        popad
        mov esp, ebp       
        pop ebp
        
        mov dword ebx, CO_scheduler
        call resume
        jmp run_target


    mayDestroy:
        push ebp            
        mov ebp, esp
        pushad

        mov dword[mayDestory], 0
        debug:
        mov ebx, dword[working_drone]
        fld dword[ebx + x]
        fld dword[targetX]
        fsub
        fld dword[ebx + x]
        fld dword[targetX]
        fsub
        fmul

        fld dword[ebx + y]
        fld dword[targetY]
        fsub
        fld dword[ebx + y]
        fld dword[targetY]
        fsub
        fmul

        fadd
        fsqrt

        fld dword[destroy_distance]
        fcomip

        jb finish_destory
        mov dword[mayDestory], 1  ;1 means destory

        finish_destory:
            popad
            mov eax, dword[mayDestory]
            mov esp, ebp       
            pop ebp
            ret


        
    



