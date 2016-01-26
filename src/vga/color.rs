#[repr(u8)]
#[derive(Copy, Clone)]
pub enum Color {
    Black      = 0,
    Blue       = 1,
    Green      = 2,
    Cyan       = 3,
    Red        = 4,
    Magenta    = 5,
    Brown      = 6,
    LightGray  = 7,
    DarkGray   = 8,
    LightBlue  = 9,
    LightGreen = 10,
    LightCyan  = 11,
    LightRed   = 12,
    Pink       = 13,
    Yellow     = 14,
    White      = 15,
}

impl Color {
    pub const fn as_foreground_byte(self) -> u8 {
        self as u8
    }

    pub const fn as_background_byte(self) -> u8 {
        (self as u8) << 4
    }

    pub const fn color_byte(bg: Color, fg: Color) -> u8 {
        bg.as_background_byte() | fg.as_foreground_byte()
    }
}
