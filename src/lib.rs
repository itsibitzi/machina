#![feature(lang_items, const_fn)]
#![no_std]

extern crate rlibc;
extern crate spin;

#[macro_use]
mod vga;

mod service;

#[no_mangle]
pub extern fn kmain() {
    for i in 0..100 {
        kprintln!("A number: {}", i);
    }
}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop{}}
