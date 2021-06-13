const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const Step = std.build.Step;

const builtin = @import("builtin");

pub fn build(b: *Builder) void {
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

    const elf = b.addExecutable("zig-stm32-blink.elf", "src/startup.zig");
    elf.setTarget(target);
    elf.setBuildMode(mode);

    const vector_obj = b.addObject("vector", "src/vector.zig");
    vector_obj.setTarget(target);
    vector_obj.setBuildMode(mode);

    elf.addObject(vector_obj);
    elf.setLinkerScriptPath("linker.ld");

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);

    // const bin = b.addInstallRaw(elf, "zig-stm32-blink.bin");
    // const bin_step = b.step("bin", "Generate binary file to be flashed");
    // bin_step.dependOn(&bin.step);

    const bin_step = create_binary(b, elf);

    const flash_step = dfu_flash(b, "firmware.bin");
    flash_step.dependOn(bin_step);
}

fn create_binary(b: *Builder, elf: *LibExeObjStep) *Step {
    if (elf.install_step == null) {
        @panic("install_step not set");
    }
    const install_step = elf.install_step.?;

    const objcopy_cmd = b.addSystemCommand(&[_][]const u8{
        "llvm-objcopy", "-Obinary",
        b.getInstallPath(install_step.dest_dir, elf.out_filename),
        "firmware.bin",
    });
    objcopy_cmd.step.dependOn(&install_step.step);

    const bin_step = b.step("bin", "Generate binary file to be flashed");
    bin_step.dependOn(&objcopy_cmd.step);

    return bin_step;
}

fn dfu_flash(b: *Builder, firmware: []const u8) *Step {
    // ROM base address from `linker.ld`
    const base_addr = "0x08002000";

    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "dfu-util", "-i0",
        "-s", base_addr,
        "-D", firmware,
    });

    const flash_step = b.step("flash", "Flash firmware (dfu-util)");
    flash_step.dependOn(&flash_cmd.step);

    return &flash_cmd.step;
}
