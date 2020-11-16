
section .bss
  temp: resd 1
section .data
  format_xy: db "targetX: %.2f targetY: %.2f", 10, 0
  format_drone: db "DroneID: %d X: %.2f Y: %.2f heading: %.2f speed: %.2f Kills: %d", 10, 0
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
  global run_printer
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern sscanf
  extern stderr
  extern working_drone
  extern targetX
  extern targetY
  extern get_random_number
  extern randint
  extern destroy_distance
  extern CO_scheduler
  extern resume
  extern drones_list
  extern nDrones



run_printer:
    push ebp
    mov ebp, esp
    pushad  

    ; print target X, Y
    mov dword ebx, targetX
    fld dword[ebx]
    sub esp,8
    fstp qword[esp]

    mov dword ebx, targetY
    fld dword[ebx]
    sub esp,8
    fstp qword[esp]

    push format_xy
    call printf
    add esp, 20

    ; print drones
    mov ebx, dword[drones_list]
	  mov dword[working_drone], ebx
	  mov ecx, dword[working_drone]
    mov edx, 0
    print_drones_loop:
      cmp ecx, 0
      jz finish_print_drones
      mov eax ,[ecx + destroyed]
      cmp eax, 1
      jz  con
      push dword[ecx + kills]

      mov eax, dword[ecx + speed]
      mov dword[temp], eax
      mov dword ebx, temp
      fld dword[ebx]
      sub esp,8
      fstp qword[esp]

      mov eax, dword[ecx + heading]
      mov dword[temp], eax
      mov dword ebx, temp
      fld dword[ebx]
      sub esp,8
      fstp qword[esp]

      mov eax, dword[ecx + y]
      mov dword[temp], eax
      mov dword ebx, temp
      fld dword[ebx]
      sub esp,8
      fstp qword[esp]

      mov eax, dword[ecx + x]
      mov dword[temp], eax
      mov dword ebx, temp
      fld dword[ebx]
      sub esp,8
      fstp qword[esp]

      push dword[ecx + id]

      push format_drone
      call printf
      add esp, 44
con:
      mov ecx, dword[working_drone]
      mov ecx, dword[ecx + next]
      mov dword[working_drone], ecx
      inc edx
      jmp print_drones_loop



   finish_print_drones:
      popad
      mov esp, ebp
      pop ebp
      mov dword ebx, CO_scheduler
      call resume
      jmp run_printer



