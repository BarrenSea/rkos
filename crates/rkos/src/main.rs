#![no_std]
#![no_main]

use core::arch::global_asm;
use core::panic::PanicInfo;

global_asm!(
    r#"
    .section .text.entry
    .align 4
    
    .global multiboot_header
    multiboot_header:
    
    .long 0x1badb002
    .long 0x00010000
    .long -(0x1badb002 + 0x00010000)

    .long multiboot_header
    .long stext
    .long edata
    .long ebss
    .long _start

    .global _start
    _start:
    .code32
        mov eax, 0x4f4f4f4f
        mov dword ptr [0xb8000], eax
        
    .loop:
        hlt
        jmp .loop
    "#
);

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
