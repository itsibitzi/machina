use core;
use core::fmt;

use spin::Mutex;

use self::color::Color;

mod color;

pub static BUFFER: Mutex<Console> = Mutex::new(Console {
    col: 0,
    row: 0,
    color: Color::color_byte(Color::Black, Color::White),
    buffer: [[VgaChar::new(b' ', Color::color_byte(Color::Black, Color::White)); BUFFER_WIDTH]; BUFFER_HEIGHT],
});

const BUFFER_HEIGHT: usize = 25;
const BUFFER_WIDTH: usize = 80;

pub struct Console {
    col: usize,
    row: usize,
    color: u8,
    buffer: [[VgaChar; BUFFER_WIDTH]; BUFFER_HEIGHT],
}

impl Console {
    fn new_line(&mut self) {
        self.row += 1;
        if self.row >= BUFFER_HEIGHT {
            for i in 1..BUFFER_HEIGHT {
                for j in 0..BUFFER_WIDTH {
                    self.buffer[i - 1][j] = self.buffer[i][j];
                }
            }
            self.row = 0;
        }
        self.col = 0;
    }

    pub fn clear(&mut self) {
        for i in 0..BUFFER_HEIGHT {
            for j in 0..BUFFER_WIDTH {
                self.buffer[i][j] = VgaChar::new(b' ', self.color);
            }
        }
    }

    pub fn flush(&self) {
        unsafe {
            let vga = 0xb8000 as *mut u8;
            let length = self.buffer.len() * self.buffer[0].len();
            let buffer: *const u8 = core::mem::transmute(&self.buffer);
            core::ptr::copy_nonoverlapping(buffer, vga, length);
        }
    }
}

impl fmt::Write for Console {
    fn write_str(&mut self, text: &str) -> fmt::Result {
        for b in text.bytes() {
            match b {
                b'\n' => self.new_line(),
                ascii => {
                    if self.col >= BUFFER_WIDTH {
                        self.new_line();
                    }

                    self.buffer[self.row][self.col] = VgaChar { color: self.color, ascii: ascii };
                    self.col += 1;
                },
            }
        }
        Ok(())
    }
}

pub fn set_background(color: Color) {
    BUFFER.lock().color &= 0b00001111;
    BUFFER.lock().color |= color.as_background_byte();
}

pub fn set_foreground(color: Color) {
    BUFFER.lock().color &= 0b11110000;
    BUFFER.lock().color |= color.as_foreground_byte();
}

pub fn clear() {
    BUFFER.lock().clear();
}

#[repr(C)]
#[derive(Copy, Clone)]
struct VgaChar {
    ascii: u8,
    color: u8,
}

impl VgaChar {
    const fn new(ascii: u8, color: u8) -> VgaChar {
        VgaChar {
            ascii: ascii,
            color: color,
        }
    }
}

#[macro_export]
macro_rules! kprintln {
    ($fmt:expr) => (kprint!(concat!($fmt, "\n")));
    ($fmt:expr, $($arg:tt)*) => (kprint!(concat!($fmt, "\n"), $($arg)*));
}

#[macro_export]
macro_rules! kprint {
    ($($arg:tt)*) => ({
        use core::fmt::Write;
        let mut b = $crate::vga::BUFFER.lock();
        b.write_fmt(format_args!($($arg)*)).unwrap();
        b.flush();
    });
}
