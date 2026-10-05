# RISC-V CPU

RV32I processor written from scratch in SystemVerilog. Simulation only (Vivado XSim).

## Status

- ✅ ALU: 10 operations + `zero` flag, verified with a self-checking testbench (5,490 random and corner-case tests)
- ⏳ Next: Register File

## Run

```
.\sim <name>      # runs tb\tb_<name>.sv, e.g. .\sim alu_self
```