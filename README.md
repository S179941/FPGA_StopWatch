# FPGA_StopWatch
[PL] Stoper na bazie układu FPGA Artix-7 [EN] Stopwatch based on Artix-7 FPGA matrix.

# Zasada działania / Working principle
[PL] Lista plików:
iup7.xdc - plik constraints do płytki ewaluacyjnej Nexys A7
display.vhdl - implementacja wyświetlacza 4-cyfrowego z wejściem równległym 32 bit, zewnętrznym zegarem i mechanizmem resetu
top.vhdl - implementacja stopera, zawiera dzielnik częstotliwości, mechanizm zegarowy, dekoder cyfry na 7-seg oraz układ tłumienia drgań styków
top_tb.vhdl - testbench, uruchamia stoper, czeka chwilę, zatrzymuje go i resetuje wynik

[EN] File list:
iup7.xdc - constraints file for Nexys A7 board
display.vhdl - implementation of 4-digit display with parallel 32 bit input, external clock and reset mechanism
top.vhdl - stopwatch implementation, contains frequency divider, clock routine, digit to 7-seg decoder and debouncing mechanism
top_tb.vhdl - testbench, starts stopwatch, pauses after while and resets.
