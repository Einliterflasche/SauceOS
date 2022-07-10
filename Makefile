TARGET_DIR = target

C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

OBJ_FILES = ${C_SOURCES:.c=.o}
	
run: image
	qemu-system-x86_64 -drive file=image,format=raw -display curses
	make clean

image: boot/main.bin kernel/main.bin
	cat $^ > $@

main.bin: force_recompile
	nasm -f bin $(SRC_DIR)/main.asm -o $(TARGET_DIR)/$@

kernel/main.bin: kernel/kernel_entry.o ${OBJ_FILES}
	ld -m elf_i386 -s -o $@ -Ttext 0x1000 $^ --oformat binary

%.o: %.c ${HEADERS} force_recompile
	i686-elf-gcc -m32 -ffreestanding -fno-pie -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm 
	nasm $< -f bin -o $@

clean:
	find . -type f \( -name "*.bin" -or -name "*.o" -or -name "*.dis" -or -name "image" \) -delete

force_recompile:
