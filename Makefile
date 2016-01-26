arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/machina-$(shell date +"%Y.%m.%d")-$(arch).iso

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg

target ?= $(arch)-unknown-linux-gnu
asm_src := $(wildcard src/arch/$(arch)/*.asm)
asm_obj := $(patsubst src/arch/$(arch)/%.asm, build/arch/$(arch)/%.o, $(asm_src))
rust_lib := target/$(target)/debug/libmachina.a

.PHONY: all clean run iso

all: $(iso)

clean:
	rm -rf build
	rm -rf target

run: $(iso)
	qemu-system-x86_64 -curses -d int -no-reboot -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel)
	echo $@
	mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	cp $(grub_cfg) build/isofiles/boot/grub
	grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	rm -r build/isofiles

$(kernel): cargo $(asm_obj) $(linker_script)
	ld -n -T $(linker_script) -o $(kernel) $(asm_obj) $(rust_lib) --gc-sections

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	mkdir -p build/arch/$(arch)/
	nasm -felf64 $< -o $@

cargo:
	cargo rustc --target $(target) -- -Z no-landing-pads
