OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

/* kernel memory map
 *
 *   Physical Address       Memory Content
 *   ----------------       -----------------------
 *   0x100000        -----> +-----------------------+ <--- KERNEL_BASE_ADDRESS
 *                          |      .text.entry      | (boot scripts)
 *                          |-----------------------|
 *                          |         .text         | (code)
 *                          |-----------------------| <--- etext (4K aligned)
 *                          |        .rodata        | (read-only data)
 *                          |-----------------------| <--- erodata (4K aligned)
 *                          |         .data         | (initialized data)
 *                          |-----------------------| <--- edata (4K aligned)
 *                          |      .bss.stack       | (kernel stack space)
 *                          |-----------------------|
 *                          |         .bss          | (uninitialized data)
 *                          |-----------------------| <--- ebss (4K aligned)
 *                          +-----------------------+ <--- ekernel (Heap Start)
 *
 */


/* x86_64 kernel base address */
KERNEL_BASE_ADDRESS = 0x100000;

SECTIONS {
    . = KERNEL_BASE_ADDRESS;

    /* kernel code */
    .text : {
        stext = .;              
        *(.text.entry)          
        *(.text .text.*)        
        . = ALIGN(4096);
        etext = .;              
    }

    /* kernel rodata */
    .rodata : {
        srodata = .;
        *(.rodata .rodata.*)
        . = ALIGN(4096);
        erodata = .;
    }

    /* kernel data */
    .data : {
        sdata = .;
        *(.data .data.*)
        . = ALIGN(4096);
        edata = .;
    }

    /* kernel bss */
    .bss : {
        sbss = .;
        *(.bss.stack)           /* kernel stack */
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4096);
        ebss = .;
    }

    /* kernel end */
    . = ALIGN(4096);
    ekernel = .;
}
