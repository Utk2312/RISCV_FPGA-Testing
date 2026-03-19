int main() {
    volatile int a = 125;
    volatile int b = 5;
    volatile int res = (a*2); 

    // Force the final calculation into the x10 (a0) register
    __asm__ volatile ("mv a0, %0" : : "r" (res));

    // Halt the processor to trigger the UART FSM
    __asm__ volatile ("ebreak");

    return 0;
}
