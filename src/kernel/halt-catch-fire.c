static void hcf(void) {
    asm ("cli");
    for (;;) {
        asm ("hlt");
    }
}
