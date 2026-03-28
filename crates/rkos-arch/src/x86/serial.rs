// see also: https://wiki.osdev.org/Serial_Ports
use core::arch::asm;
use core::fmt;

const COM1: u16 = 0x3F8;

/// Write a byte to the serial port
unsafe fn outb(port: u16, val: u8) {
    unsafe {
        asm!("out dx, al", in("dx") port, in("al") val, options(nomem, nostack, preserves_flags));
    }
}

/// Read a byte from the serial port
unsafe fn inb(port: u16) -> u8 {
    let mut val: u8;
    unsafe {
        asm!("in al, dx", out("al") val, in("dx") port, options(nomem, nostack, preserves_flags));
    }
    val
}

pub struct SerialPort;

impl SerialPort {
    /// Initialize the standard COM1 serial port
    pub fn init() {
        unsafe {
            outb(COM1 + 1, 0x00); // Disable all interrupts
            outb(COM1 + 3, 0x80); // Enable DLAB (set baud rate divisor)
            outb(COM1, 0x03); // Set divisor to 3 (lo byte) 38400 baud
            outb(COM1 + 1, 0x00); //                  (hi byte)
            outb(COM1 + 3, 0x03); // 8 bits, no parity, one stop bit
            outb(COM1 + 2, 0xC7); // Enable FIFO, clear them, with 14-byte threshold
            outb(COM1 + 4, 0x0B); // IRQs enabled, RTS/DSR set
        }
    }

    /// Check if transmit buffer is empty
    fn is_transmit_empty() -> bool {
        unsafe { inb(COM1 + 5) & 0x20 != 0 }
    }

    /// Write a byte to the serial port
    pub fn write_byte(b: u8) {
        while !Self::is_transmit_empty() {}
        unsafe {
            outb(COM1, b);
        }
    }
}

impl fmt::Write for SerialPort {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for byte in s.bytes() {
            SerialPort::write_byte(byte);
        }
        Ok(())
    }
}

pub fn _print(args: fmt::Arguments) {
    let mut serial = SerialPort;
    let _ = fmt::Write::write_fmt(&mut serial, args);
}
