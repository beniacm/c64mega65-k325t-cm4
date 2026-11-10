#!/usr/bin/env bash
# build.sh -- generate the top and the source list, check the QNICE firmware, run Vivado.
set -euo pipefail
# Usage: build.sh [radxacm3]
#   (none)    Luckfox Core3566 module   -> bin/c64_k325t_cm4.bit           (log build.log)
#   radxacm3  Radxa CM3 module: the "CM bus" section of qmtech_k325t_cm4.xdc replaced by
#             qmtech_k325t_cm4_radxacm3_bus.xdc -> bin/c64_k325t_cm4_radxacm3.bit (log build_radxacm3.log)
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
: "${VIVADODIR:=$HOME/Xilinx/2025.2.1/Vivado}"
variant="${1:-}"
case "$variant" in
    "")       xdc="$here/qmtech_k325t_cm4.xdc"; suffix="" ;;
    radxacm3) xdc="$here/qmtech_k325t_cm4_radxacm3.xdc"; suffix="_radxacm3"
              awk -v f="$here/qmtech_k325t_cm4_radxacm3_bus.xdc" \
                  '/^## >>> CM bus/ { while ((getline l < f) > 0) print l; skip=1; next }
                   /^## <<< CM bus/ { skip=0; next } !skip' "$here/qmtech_k325t_cm4.xdc" > "$xdc"
              grep -q 'PACKAGE_PIN D14 ' "$xdc" && ! grep -q 'PACKAGE_PIN B9 ' "$xdc" \
                  || { echo "ERROR: CM bus section not replaced in $xdc" >&2; exit 1; } ;;
    *)        echo "usage: $0 [radxacm3]" >&2; exit 2 ;;
esac
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
vivado -mode batch -nojournal -log "$here/build$suffix.log" -source "$here/build.tcl" -tclargs "$xdc" "$suffix"
