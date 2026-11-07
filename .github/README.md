# C64MEGA65 — QMTech XC7K325T CM4 carrier port (`K325T/`)

A fork of [MJoergen/C64MEGA65](https://github.com/MJoergen/C64MEGA65) (release V5.2) that runs
the C64 core on a **QMTech XC7K325T development board with a CM4 carrier**.  A Luckfox
Core3566 (Rockchip) in the CM4 socket stands in for the MEGA65's keyboard, SD card, joysticks
and mouse; the board's DDR3 replaces the HyperRAM.  Not affiliated with the C64MEGA65 authors.

**Branch `qmtech-k325t-cm4`** (default here) = V5.2 + this port.  The upstream README is
[`README.md`](../README.md); this file only describes the port.

Board harness (scripts, Rockchip daemons, write-up):
**[beniacm/mega65-k325t-cm4](https://github.com/beniacm/mega65-k325t-cm4)** (section "C64 core").
The MEGA65 core for the same board: [beniacm/mega65-core-k325t-cm4](https://github.com/beniacm/mega65-core-k325t-cm4).

## What the port adds

| file | role |
|---|---|
| `K325T/top_qmtech_k325t_cm4.tpl.vhd`, `gen_top.py` | top generated from the R6 top: clocks, MIG, Rockchip bridge, SD emulator, flash, warm boot |
| `K325T/avm_mig.vhd`, `mig_ddr3.prj` | M2M Avalon memory bus (the HyperRAM interface) → MIG DDR3 native UI |
| `K325T/m65kbd_emu.vhd` | the MEGA65 keyboard's serial link, answered from the bridge's key matrix |
| `K325T/qmtech_k325t_cm4.xdc`, `build.sh`, `build.tcl`, `gen_sources.py` | constraints and the Vivado batch build |
| `M2M/vhdl/framework.vhd` | generics `G_EXT_HR` (external memory instead of HyperRAM), `G_TMDS_INVERT` (J11 pair polarity), `G_NO_I2C` |
| `CORE/vhdl/main.vhd`, `reu_mapper.vhd`, `config.vhd` | **16 MB REU** (menu "Simulate REU 16MB"; upstream 1750 512 KB): `reu.v` already supports 16 MB, the mapper no longer wraps at the 8 MB HyperRAM |

The Rockchip bridge (`rk_bridge`) and SD emulator come from the MEGA65 core fork.  Works on
hardware: BASIC, keyboard, menu, SD/D64 load + save, REU, EasyFlash cartridges, disk games,
joysticks and the 1351 mouse (USB mouse via the Rockchip).

## Build

```
K325T/build.sh            # ~8 min -> K325T/bin/c64_k325t_cm4.bit
```
The QNICE firmware needs its assembler built once (`M2M/QNICE/assembler/`).  Vivado 2025.2 was
used.  Written to flash slot 1 from the Rockchip (`m65flash.py write 1 …` in the harness).

## Following upstream

```
git remote add upstream https://github.com/MJoergen/C64MEGA65.git   # fetch only
git fetch upstream --tags && git merge <release tag>
```
Nothing here is pushed to upstream.

## Licence

GPL-3.0, as upstream (`LICENSE`); the port's files under the same terms.
