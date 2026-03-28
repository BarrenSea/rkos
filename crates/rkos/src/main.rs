#![no_std]
#![no_main]

use core::arch::global_asm;
use core::panic::PanicInfo;

#[cfg(target_arch = "x86_64")]
global_asm!(include_str!("../../rkos-arch/src/x86/head_64.S"));

#[unsafe(no_mangle)]
pub extern "C" fn _main() {
    // VGA_BASE: 0xb8000
    let vga_buffer = 0xb8000 as *mut u8;

    let text = b"[OK] Barrensea rkos has conquered 64-bit Long Mode!!!";
    let color_byte = 0x0a;

    for (i, &byte) in text.iter().enumerate() {
        unsafe {
            *vga_buffer.add(i * 2) = byte;
            *vga_buffer.add(i * 2 + 1) = color_byte;
        }
    }

    unsafe extern "C" {
        fn stext();
        fn edata();
        fn ebss();
    }
    let _text_size = edata as *const () as usize - stext as *const () as usize;
    let _bss_size = ebss as *const () as usize - edata as *const () as usize;

    //loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
