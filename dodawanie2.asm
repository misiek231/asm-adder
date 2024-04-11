         [bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

extern   _scanf
extern   _printf
extern   _exit

section .data

; Zmienne pomocnicze do ustawienia trybu zaokroglenia w fpu
up  dd 0x0800
old dd 0

max_a_b dd 0

a dd 0
b dd 0

; zmienne przechowuj¹ce formaty
f_input_a   db "a = ", 0
f_input_b   db "b = ", 0
f_input_dec db "%d", 0
f_newline   db 0xA, " ", 0
f_space     db " ", 0
f_one       db "1", 0
f_max_a_b   db 0xA, "  %d", 0xA, 0
f_min_a_b   db "+ %*d", 0xA, 0
f_dash      db "-", 0
f_result    db 0xA, " %*d", 0xA, 0

section .text

global _main

_main:

         push f_input_a  ; f_input_a -> stack

;        esp -> [f_input_a][ret]

         call _printf  ; printf('a = ');
         add esp, 4    ; esp = esp + 4

;        esp -> [ret] ; zmienna a, adres format nie jest juz potrzebny

         push a  ; addr_a -> stack

;        esp -> [addr_a][ret]

         push f_input_dec  ; f_input_dec -> stack

;        esp -> [f_input_dec][addr_a][ret]

         call _scanf  ; scanf("%d", &a);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [ret]

         push f_input_b  ; f_input_b -> stack

;        esp -> [f_input_b][ret]

         call _printf  ; printf('b = ');
         add esp, 4    ; esp = esp + 4

;        esp -> [ret] ; zmienna a, adres format nie jest juz potrzebny

         push b  ; addr_b -> stack

;        esp -> [addr_b][ret]

         push f_input_dec  ; f_input_dec -> stack

;        esp -> [f_input_dec][addr_b][ret]

         call _scanf  ; scanf("%d", &b);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [ret]

         mov eax, [a]  ; eax = *(int*)a
         mov ecx, [b]  ; ecx = *(int*)b

         cmp ecx, eax
         cmovl eax, ecx  ; if ecx < eax then eax = ecx

         push eax  ; min_a_b -> stack

;        esp -> [min_a_b][ret]

         mov eax, [a]  ; eax = *(int*)a
         mov ecx, [b]  ; ecx = *(int*)b

         cmp eax, ecx
         cmovl eax, ecx  ; if eax < ecx then eax = ecx

         push eax  ; max_a_b -> stack

;        esp -> [max_a_b][min_a_b][ret]

         mov [max_a_b], eax  ; *(int*)max_a_b = eax

         push 1

;        esp -> [1][max_a_b][min_a_b][ret]

         cmp eax, 1

         jle skip_log  ; pomijamy logarytm jeœli max_a_b = 1 lub max_a_b = 0

;        esp -> [ ][max_a_b][min_a_b][ret]  ; jeœli liczymy logarytm 1 traktujemy jako wolne miejsce na wynik

         call log10
         
;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

skip_log:

         mov ecx, [esp]  ; ecx = *(int*)esp = width_max_a_b

         mov edi, 10  ; edi = 10

         push 2  ; liczba pomocnicza do wyjscia z pêtli

;        esp -> [2][width_max_a_b][max_a_b][min_a_b][ret]

loop1:

         mov eax, [a]  ; eax = *(int*)a
         mov edx, 0    ; edx = 0

         div edi  ; edx = eax % edi = digits_a

         mov esi, edx  ; esi = edx

         mov eax, [b]  ; eax = *(int*)b
         mov edx, 0    ; edx = 0

         div edi  ; edx = eax % edi = digits_b

         add esi, edx  ; esi = esi + edx = digits_a + digits_b

         cmp edi, esi
         jle add_1  ; jeœli edi <= esi odk³adamy 1

         push 0  ; jeœli edi > esi odk³adamy 0

;        esp -> [0][2][width_max_a_b][max_a_b][min_a_b][ret]

         jmp done  ; skocz do done

add_1    push 1

;        esp -> [1][2][width_max_a_b][max_a_b][min_a_b][ret]

done     mov esi, 10   ; esi = 10
         mov eax, edi  ; eax = edi
         mul esi       ; eax = eax * esi = eax * 10
         mov edi, eax  ; edi = eax = edi * 10

         loop loop1  ; ecx = ecx - 1  ; jmp loop1

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         push f_newline

;        esp -> [f_newline][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call _printf  ; printf(f_newline);
         add esp, 4    ; esp = esp + 4

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

loop2    pop eax  ; eax <- stack

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         cmp eax, 0
         je print_space  ; jeœli eax = 0 wypisujemy spacjê

         cmp eax, 1
         je print_1  ; jeœli eax = 1 wypisujemy 1

;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

         jmp done2  ; w pozosta³ych przypadkach wychodzimy z pêtli

print_space:

         push f_space

;        esp -> [f_space][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call _printf  ; printf(" ");
         add esp, 4  ; esp = esp + 4
         
;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         jmp loop2

print_1:

         push f_one

;        esp -> [f_one][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call _printf  ; printf("1");
         add esp, 4  ; esp = esp + 4
         
;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         jmp loop2

done2:

;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

         pop edi  ; edi <- stack = width_max_a_b

;        esp -> [max_a_b][min_a_b][ret]

         push f_max_a_b

;        esp -> [f_max_a_b][max_a_b][min_a_b][ret]

         call _printf  ; printf(f_max_a_b, max_a_b);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [min_a_b][ret]

         push edi  ; edi -> stack

;        esp -> [width_max_a_b][min_a_b][ret]

         push f_min_a_b

;        esp -> [f_min_a_b][width_max_a_b][min_a_b][ret]

         call _printf  ; printf(f_min_a_b, width_max_a_b, min_a_b);
         add esp, 4    ; esp = esp + 4

;        esp -> [width_max_a_b][min_a_b][ret]

         mov ecx, [esp]  ; ecx = *(int*)esp = width_max_a_b

         add ecx, 2  ; ecx = ecx + 2

         push f_dash

;        esp -> [f_dash][width_max_a_b][min_a_b][ret]

loop3    mov edi, ecx  ; edi = ecx  ; store counter

         call _printf  ; printf(f_dash);

         mov ecx, edi  ; restore counter

         loop loop3  ; ecx = ecx - 1  ; jmp loop3

         add esp, 4  ; esp = esp + 4

;        esp -> [width_max_a_b][min_a_b][ret]

         mov eax, [a]  ; eax = *(int*)a
         mov edx, [b]  ; edx = *(int*)b

         add eax, edx  ; eax = eax + edx

         pop edx  ; edx <- stack = width_max_a_b

;        esp -> [min_a_b][ret]

         add edx, 1  ; edx = edx + 1

         push eax  ; eax -> stack

;        esp -> [a+b][min_a_b][ret]

         push edx  ; edx -> stack

;        esp -> [width_max_a_b][a+b][min_a_b][ret]

         push f_result

;        esp -> [f_result][width_max_a_b][a+b][min_a_b][ret]

         call _printf  ; printf(f_result, width_max_a_b, a+b);
         add esp, 4*4    ; esp = esp + 16

;        esp -> [ret]

         push 0      ; esp -> [0][ret]
         call _exit  ; exit(0);

log10:

;        esp -> [ret][ ][max_a_b][min_a_b][ret]

;        setup fpu rounding mode to up

         fstcw [old]  ; *(int*)old = fpu_control_word

         mov eax, [old]  ; eax = *(int*)old
         mov ecx, [up]   ; ecx = *(int*)up

         or eax, ecx  ; eax = eax | ecx

         mov [old], eax  ; *(int*)old = eax

         fldcw [old]  ; load fpu control word

         fld1  ; 1 -> st ; fpu load floating-point: 1

;        st = [st0] = [1]

         fild dword [max_a_b]  ; *(int*)(max_a_b) -> st ; fpu load floating-point

;        st = [st0, st1] = [max_a_b, 1] ; fpu stack

         fyl2x  ; [st0, st1] => [st0, st1*log2(st0)] => [st1*log2(st0)]

;        st = [st1*(log2(st0)] = [1*log2(max_a_b)]

         fldlg2  ; log10(2) -> st  ; fpu load log10(2)

;        st = [st0, st1] = [log10(2), log2(max_a_b)]

         fmulp st1  ; [st0, st1] => [st0, st0*st1] => [st0*st1]

;        st = [st0] = [log10(2)*log2(max_a_b)]

;        esp -> [ret][ ][max_a_b][min_a_b][ret]

         fistp dword [esp+4]  ; *(int*)(esp+4) <- st = [log10(2)*log2(max_a_b)]  ; fpu store top element and pop fpu stack

;        esp -> [ret][log10(max_a_b)][max_a_b][min_a_b][ret]

         ret

%ifdef COMMENT
Kompilacja:

nasm dodawanie2.asm -o dodawanie2.o -f win32

ld dodawanie2.o -o dodawanie2.exe c:\windows\system32\msvcrt.dll -m i386pe

lub:

nasm dodawanie2.asm -o dodawanie2.o -f win32

gcc dodawanie2.o -o dodawanie2.exe -m32

nasm dodawanie2.asm -o dodawanie2.o -f win32 && gcc dodawanie2.o -o dodawanie2.exe -m32 && dodawanie2

%endif
