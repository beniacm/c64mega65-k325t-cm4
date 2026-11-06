#!/usr/bin/env bash
# build.sh -- generate the top and the source list, check the QNICE firmware, run Vivado.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
: "${VIVADODIR:=$HOME/Xilinx/2025.2.1/Vivado}"
python3 "$here/gen_top.py" "$root/M2M/vhdl/top_mega65-r6.vhd" "$here/top_qmtech_k325t_cm4.vhd" \
        "$here/top_qmtech_k325t_cm4.tpl.vhd"
python3 "$here/gen_sources.py"
# The QNICE firmware (M2M shell: menus, file browser, SD/FAT32) is assembled from
# CORE/m2m-rom/m2m-rom.asm by CORE/m2m-rom/make_rom.sh (needs the QNICE assembler
# M2M/QNICE/assembler/qasm + qasm2rom); the R6 project runs that as a pre-synthesis hook.
if [ ! -s "$root/CORE/m2m-rom/m2m-rom.rom" ]; then
    echo "ERROR: CORE/m2m-rom/m2m-rom.rom is missing -- build the QNICE assembler and run" >&2
    echo "       (cd CORE/m2m-rom && ./make_rom.sh) first." >&2
    exit 1
fi
source "$VIVADODIR/settings64.sh"
cd "$here"
vivado -mode batch -nojournal -log "$here/build.log" -source "$here/build.tcl"
