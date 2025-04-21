# Blackjack FPGA Project Checklist

## ✅ MIPS Logic + ISA Design
- [x] Finalize RANDOM instruction implementation in the ALU (XORSHIFT)
- [x] Add RANDOM opcode handling in control unit & datapath
- [x] Use DIV instead of MOD (encode cards as 1–52)
- [x] Verify DIV outputs quotient (default) via testbench

## ✅ VGA + Sprites
- [x] Generate/collect sprites for cards 1–13 (ignore suits). Size is 75 px wide, 105 px tall
- [ ] Use `PicToCSV.py` and `CSVToMem.py` to create `sprites.mem`
- [ ] Implement wrapper logic:
  - [ ] Detect store to `16($4)` for new card
  - [ ] Use `$4` for horizontal offset
  - [ ] Use `$9` to index into `sprites.mem`

## ✅ Game Memory + CPU-VGA Interfacing
- [ ] Add **second read port** to RAM module
- [ ] VGA uses `addr2`, CPU uses `addr1`
- [ ] Implement card duplication check via MEM[0 to $3–1]

## ✅ Game Logic
- [ ] Write MIPS routines:
  - [ ] `reset`
  - [ ] `player_draw`
  - [ ] `cpu_play`
  - [ ] main game `loop`
- [ ] Implement win/loss/draw screen logic:
  - [ ] Address `32` for LOSS
  - [ ] Address `33` for WIN
  - [ ] Address `34` for DRAW
- [ ] Implement 6-second stall using delay loop (~240M cycles at 40 MHz)

## ✅ Testing + Debugging
- [ ] Write MIPS test cases for:
  - [ ] RANDOM instruction
  - [ ] Card duplication logic
  - [ ] 6-second delay loop
- [ ] Create Verilog testbench for modified DIV
- [ ] Simulate VGA + wrapper with hardcoded test values
- [ ] Validate dual-read RAM design avoids conflicts

## ✅ Polishing
- [ ] Optional: Display # user wins from `$6`
- [ ] Fine-tune card spacing on VGA screen
- [ ] Optional: Replace delay loop with "Press RESET to continue" mechanic
