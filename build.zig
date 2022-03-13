const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    // ROM base address from `linker.ld`
    const base_addr = "0x08002000";

    // Blue Pill STM32F103C8T6
    const target = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 },
        .os_tag = .freestanding,
        .abi = .eabi,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const elf = b.addExecutable("zig-stm32-blink.elf", "src/main.zig");
    elf.setTarget(target);
    elf.setBuildMode(mode);

    const vector_obj = b.addObject("vector", "src/vector.zig");
    vector_obj.setTarget(target);
    vector_obj.setBuildMode(mode);

    const startup_obj = b.addObject("startup", "src/startup.zig");
    startup_obj.setTarget(target);
    startup_obj.setBuildMode(mode);

    elf.addObject(vector_obj);
    elf.addObject(startup_obj);
    elf.setLinkerScriptPath(.{ .path = "linker.ld" });

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);

    const bin = b.addInstallRaw(elf, "zig-stm32-blink.bin", .{});
    const bin_step = b.step("bin", "Generate binary file to be flashed");
    bin_step.dependOn(&bin.step);

    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "dfu-util", "-i0",
        "-s", base_addr,
        "-D", b.getInstallPath(bin.dest_dir, bin.dest_filename),
    });
    flash_cmd.step.dependOn(&bin.step);
    const flash_step = b.step("flash", "Flash firmware (dfu-util)");
    flash_step.dependOn(&flash_cmd.step);
}
