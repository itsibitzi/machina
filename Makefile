arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/machina-$(shell date +"%Y.%m.%d")-$(arch).iso

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg

asm_src := $(wildcard src/arch/$(arch)/*.asm)
asm_obj := $(patsubst src/arch/$(arch)/%.asm, build/arch/$(arch)/%.o, $(asm_src))

.PHONY: all clean run iso

all: $(iso)

clean:
	rm -rf build
	#rm -rf target

run: $(iso)
	qemu-system-x86_64 -curses -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel)
	echo $@
	mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	cp $(grub_cfg) build/isofiles/boot/grub
	grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	rm -r build/isofiles

$(kernel): $(asm_obj) $(linker_script)
	ld -n -T $(linker_script) -o $(kernel) $(asm_obj)

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	mkdir -p build/arch/$(arch)/
	nasm -felf64 $< -o $@
