# RISC-V CPU

RV32I processor written from scratch in SystemVerilog. Simulation only (Vivado XSim).

## Status

Building blocks, each verified with a self-checking testbench (random + corner cases, independent reference model):

| Module | Description | Tests |
|---|---|---|
| `alu` | 10 operations + `zero` flag | 5,490 |
| `regfile` | 32 x 32-bit, 2 read / 1 write ports, `x0` hardwired to 0 | 534 |
| `pc` | Program counter, synchronous reset | 13 |
| `imem` | Instruction memory (ROM), loaded from a hex file | 5 |
| `dmem` | Data memory, byte-enable writes, little-endian | 505 |
| `immgen` | Immediate generator for I/S/B/U/J formats | 1,200 |

- `programs/sum.hex`: hand-assembled program (sum 1..5), verified in Venus
- ⏳ Next: single-cycle datapath and control unit

## Layout

```
rtl/        design (rtl/pkg/ compiled first)
tb/         testbenches (tb_<name>.sv)
programs/   hex programs
```

## Run

```
.\sim <name>      # runs tb\tb_<name>.sv, e.g. .\sim immgen
```
