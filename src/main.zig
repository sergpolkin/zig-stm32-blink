const regs = @import("registers.zig");

pub fn main() noreturn {
    // Set pin 13 mode to general purpose output
    regs.GPIOC.CRH.modify(.{ .MODE13 = 0b10, .CNF13 = 0b00, });

    // Reset pin 13 (LED on)
    regs.GPIOC.BRR.modify(.{ .BR13 = 1, });

    while (true) {
        // Read the LED state
        const leds_state = regs.GPIOC.ODR.read();
        // Set the LED output to the negation of the currrent output
        regs.GPIOC.ODR.modify(.{ .ODR13 = ~leds_state.ODR13, });

        // Sleep for some time
        var i: u32 = 0;
        while (i < 600000) : (i +%= 1) {
            asm volatile ("nop");
        }
    }
}
