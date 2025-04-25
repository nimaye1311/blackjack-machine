transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+Wrapper  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.Wrapper xil_defaultlib.glbl

do {Wrapper.udo}

run 1000ns

endsim

quit -force
