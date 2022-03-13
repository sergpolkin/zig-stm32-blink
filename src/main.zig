const PERIPH_BASE = 0x40000000;
const PERIPH_BASE_APB1 = PERIPH_BASE + 0x00000;
const PERIPH_BASE_APB2 = PERIPH_BASE + 0x10000;
const PERIPH_BASE_AHB  = PERIPH_BASE + 0x18000;

const GPIO_PORT_C_BASE = PERIPH_BASE_APB2 + 0x1000;

fn GPIO(comptime base: usize) type {
    return struct {
        // Port configuration
        const CRL = @intToPtr(*volatile u32, base + 0x00);
        const CRH = @intToPtr(*volatile u32, base + 0x04);
        // Port input
        const IDR = @intToPtr(*volatile u32, base + 0x08);
        // Port output
        const ODR = @intToPtr(*volatile u32, base + 0x0c);

        pub fn read() u16 {
            return @truncate(u16, IDR.*);
        }

        pub fn write(val: u16) void {
            ODR.* = @as(u32, val);
        }
    };
}

export fn main() void {
    while (true) {
        const GPIOC = GPIO(GPIO_PORT_C_BASE);
        // Toggle LED (PC13)
        GPIOC.write(GPIOC.read() ^ (1<<13));
        // Sleep for some time
        var i: usize = 0;
        while (i < 600000) : (i += 1) {
            asm volatile ("nop");
        }
    }
}
