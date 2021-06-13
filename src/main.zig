// Blue Pill STM32F103C8T6

const GPIOC_BASE = 0x4001_1000;

const GPIOC_CRL = @intToPtr(*volatile u32, GPIOC_BASE + 0x00);
const GPIOC_CRH = @intToPtr(*volatile u32, GPIOC_BASE + 0x04);

const GPIOC_IDR = @intToPtr(*volatile u32, GPIOC_BASE + 0x08);
const GPIOC_ODR = @intToPtr(*volatile u32, GPIOC_BASE + 0x0C);

const GPIOC_BSRR = @intToPtr(*volatile u32, GPIOC_BASE + 0x10);
const GPIOC_BRR = @intToPtr(*volatile u32, GPIOC_BASE + 0x14);

pub fn main() noreturn {
    while (true) {
        GPIOC_ODR.* ^= 1 << 13;
        // Sleep for some time
        var i: u32 = 0;
        while (i < 600000) : (i +%= 1) {
            asm volatile ("nop");
        }
    }
}
