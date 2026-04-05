#![no_std]
#![no_main]

use core::arch::global_asm;
use core::panic::PanicInfo;

#[cfg(target_arch = "x86_64")]
global_asm!(include_str!("../../rkos-arch/src/x86/head_64.S"));

#[macro_use]
pub mod console;

#[unsafe(no_mangle)]
pub extern "C" fn _main() {
    let _ = rkos_arch::x86::serial::SerialPort::init();

    println!("[OK] Barrensea rkos has conquered 64-bit Long Mode!!!");
    println!("Hello from rkos serial output!");

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
