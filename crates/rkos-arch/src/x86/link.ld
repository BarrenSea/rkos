/* 
    linker script for x86_64 kernel
    see also: https://wiki.osdev.org/Linker_Scripts
*/
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)


/* x86_64 kernel base address */
KERNEL_BASE_ADDRESS = 0x100000;

SECTIONS {
    . = KERNEL_BASE_ADDRESS;

    /*  
        .text: kernel code
        start at 0x100000
    */
    .text : {
        stext = .;              
        *(.text.entry)         
        *(.text .text.*)        
        . = ALIGN(4096);
        etext = .;              
    }
    /* 
        .rodata: kernel rodata 
    */
    .rodata : {
        srodata = .;
        *(.rodata .rodata.*)
        . = ALIGN(4096);
        erodata = .;
    }

    /* 
        .data: kernel data 
    */
    .data : {
        sdata = .;
        *(.data .data.*)
        . = ALIGN(4096);
        edata = .;
    }

    /* 
        .bss: kernel bss 
    */
    .bss : {
        sbss = .;
        *(.bss.stack)           /* kernel stack */
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4096);
        ebss = .;
    }

    /* 
        kernel end
    */
    . = ALIGN(4096);
    ekernel = .;
}
