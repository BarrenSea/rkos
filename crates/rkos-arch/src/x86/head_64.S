/*
    Bootstrapping x86_64 kernel
    see also: https://wiki.osdev.org/Setting_Up_Long_Mode
*/
    /* prepare space for 4-level paging to entering long mode 
        .bss: | PML4 | PML3 | PML2 | Kernel_Stack(.bss.stack)|
              | 4kb  | 4kb  | 4kb  | 16kb                 |
    */
    .section .bss
    .align 4096
p4_table:
    .skip 4096
p3_table:
    .skip 4096
p2_table:
    .skip 4096

    /* Kernel Stack */
    .section .bss.stack
    .align 16
stack_bottom:
    .skip 16384
stack_top:

    /*  
        64-bit Global Descriptor Table (GDT) 
        see also: https://wiki.osdev.org/Global_Descriptor_Table
    */

    /* because of .rodata is read only now,when adding more features,we should move it to .data */
    .section .rodata 
    /* every items in gdt64 is 8 bytes */
    .align 8
gdt64:
    /* the first item is null */
    .quad 0x0000000000000000  
    
    /* the second item is 64-bit code segment 
        Base 63:56 0x00000000
        G 55 0
        D/B 54 0
        L 53 1 (64-bit code segment)
        AVL 52 0
        Limit 51:48 0x0000
        P 47 1
        DPL 46:45 0x00
        S 44 1
        Type 43:40 0x10
        Base 39:16 0x000000
        Limit 15:0 0x0000
    */
    .quad 0x0020980000000000  
gdt64_pointer:
    /* length of gdt64 minus 1 */
    .word 15    
    /* pointer to gdt64 */              
    .long gdt64 

    /* 
        multiboot header
        see also: https://wiki.osdev.org/Multiboot_Specification
    */
    .section .text.entry
    .align 4
    
    .global multiboot_header
multiboot_header:
    /* 0x1badb002: magic number for multiboot protocol*/
    .long 0x1badb002
    /* 0x00010000: flags */
    .long 0x00010000
    /* checksum */
    .long -(0x1badb002 + 0x00010000)

    /* pointer to multiboot_header */
    .long multiboot_header
    .long stext
    .long edata
    .long ebss
    .long _start

    /* 
        start of 32-bit code
    */
    .global _start
_start:
    .code32
    /* set stack pointer */
    mov esp, offset stack_top

    /* 
        set up temporary page table
        map first 2MB of physical memory to virtual memory
    */
    mov eax, offset p3_table
    or eax, 0b11          /* 0b11 means present and writable */
    mov dword ptr [p4_table], eax

    /* p3_table[0] -> p2_table */
    mov eax, offset p2_table
    or eax, 0b11
    mov dword ptr [p3_table], eax

    /* map first 2MB of physical memory to virtual memory as huge page */
    mov eax, 0x83         /* 0x80 (Huge) + 0x02 (Writable) + 0x01 (Present) */
    mov dword ptr [p2_table], eax

    /* into long mode */
    /* step 1: set CR3 to p4_table */
    mov eax, offset p4_table
    mov cr3, eax

    /* step 2: enable PAE in CR4 */
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    /* step 3: enable LME in EFER */
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    /* step 4: enable paging in CR0 */
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    /* step 5: load gdt64 */
    lgdt [gdt64_pointer]

    /* jump to 64-bit code */
    push 8                     /* push 64-bit code segment */
    mov eax, offset long_mode_start
    push eax                   /* push 64-bit code entry point */
    retf                       /* retf to long mode */

    .code64
long_mode_start:
    /* first thing: set all data segment registers to 0 */
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    /* call _main */
    call _main

    /* if _main returns, loop forever */
.loop64:
    hlt
    jmp .loop64
