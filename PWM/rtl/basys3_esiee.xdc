# This file is a general .xdc for the Basys3 rev B board
# To use it in a project:
# 19/06/2019 - Modified by Y. B. 
# 19/06/2019 - Modified by Y. B. : Ports names are now case insensitive

set_property -quiet IOSTANDARD LVCMOS33 [get_ports -quiet *]

# Clock signal
set_property -quiet PACKAGE_PIN W5 [get_ports -regexp -nocase -quiet clk]
create_clock -quiet -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports -regexp -nocase  -quiet clk]

# Switches
set_property -quiet PACKAGE_PIN V17 [get_ports -regexp -nocase   -quiet {sw\\[0\\]}]
set_property -quiet PACKAGE_PIN V16 [get_ports -regexp -nocase  -quiet {sw\\[1\\]}]
set_property -quiet PACKAGE_PIN W16 [get_ports -regexp -nocase  -quiet {sw\\[2\\]}]
set_property -quiet PACKAGE_PIN W17 [get_ports -regexp -nocase  -quiet {sw\\[3\\]}]
set_property -quiet PACKAGE_PIN W15 [get_ports -regexp -nocase  -quiet {sw\\[4\\]}]
set_property -quiet PACKAGE_PIN V15 [get_ports -regexp -nocase  -quiet {sw\\[5]}]
set_property -quiet PACKAGE_PIN W14 [get_ports -regexp -nocase  -quiet {sw\\[6]}]
set_property -quiet PACKAGE_PIN W13 [get_ports -regexp -nocase  -quiet {sw\\[7\\]}]
set_property -quiet PACKAGE_PIN V2 [get_ports -regexp -nocase  -quiet {sw\\[8\\]}]
set_property -quiet PACKAGE_PIN T3 [get_ports -regexp -nocase  -quiet {sw\\[9\\]}]
set_property -quiet PACKAGE_PIN T2 [get_ports -regexp -nocase  -quiet {sw\\[10\\]}]
set_property -quiet PACKAGE_PIN R3 [get_ports -regexp -nocase  -quiet {sw\\[11\\]}]
set_property -quiet PACKAGE_PIN W2 [get_ports -regexp -nocase  -quiet {sw\\[12\\]}]
set_property -quiet PACKAGE_PIN U1 [get_ports -regexp -nocase  -quiet {sw\\[13\\]}]
set_property -quiet PACKAGE_PIN T1 [get_ports -regexp -nocase  -quiet {sw\\[14\\]}]
set_property -quiet PACKAGE_PIN R2 [get_ports -regexp -nocase  -quiet {sw\\[15\\]}]


# led\\s

set_property -quiet PACKAGE_PIN U16 [get_ports -regexp -nocase  -quiet {led\\[0\\]}]
set_property -quiet PACKAGE_PIN E19 [get_ports -regexp -nocase  -quiet {led\\[1\\]}]
set_property -quiet PACKAGE_PIN U19 [get_ports -regexp -nocase  -quiet {led\\[2\\]}]
set_property -quiet PACKAGE_PIN V19 [get_ports -regexp -nocase  -quiet {led\\[3\\]}]
set_property -quiet PACKAGE_PIN W18 [get_ports -regexp -nocase  -quiet {led\\[4\\]}]
set_property -quiet PACKAGE_PIN U15 [get_ports -regexp -nocase  -quiet {led\\[5\\]}]
set_property -quiet PACKAGE_PIN U14 [get_ports -regexp -nocase  -quiet {led\\[6\\]}]
set_property -quiet PACKAGE_PIN V14 [get_ports -regexp -nocase  -quiet {led\\[7\\]}]
set_property -quiet PACKAGE_PIN V13 [get_ports -regexp -nocase  -quiet {led\\[8\\]}]
set_property -quiet PACKAGE_PIN V3 [get_ports -regexp -nocase  -quiet {led\\[9\\]}]
set_property -quiet PACKAGE_PIN W3 [get_ports -regexp -nocase  -quiet {led\\[10\\]}]
set_property -quiet PACKAGE_PIN U3 [get_ports -regexp -nocase  -quiet {led\\[11\\]}]
set_property -quiet PACKAGE_PIN P3 [get_ports -regexp -nocase  -quiet {led\\[12\\]}]
set_property -quiet PACKAGE_PIN N3 [get_ports -regexp -nocase  -quiet {led\\[13\\]}]
set_property -quiet PACKAGE_PIN P1 [get_ports -regexp -nocase  -quiet {led\\[14\\]}]
set_property -quiet PACKAGE_PIN L1 [get_ports -regexp -nocase  -quiet {led\\[15\\]}]


#7 segment display
set_property -quiet PACKAGE_PIN W7 [get_ports -regexp -nocase  -quiet {seg\\[0\\]}]
set_property -quiet PACKAGE_PIN W6 [get_ports -regexp -nocase  -quiet {seg\\[1\\]}]
set_property -quiet PACKAGE_PIN U8 [get_ports -regexp -nocase  -quiet {seg\\[2\\]}]
set_property -quiet PACKAGE_PIN V8 [get_ports -regexp -nocase  -quiet {seg\\[3\\]}]
set_property -quiet PACKAGE_PIN U5 [get_ports -regexp -nocase  -quiet {seg\\[4\\]}]
set_property -quiet PACKAGE_PIN V5 [get_ports -regexp -nocase  -quiet {seg\\[5\\]}]
set_property -quiet PACKAGE_PIN U7 [get_ports -regexp -nocase  -quiet {seg\\[6\\]}]

set_property -quiet PACKAGE_PIN V7 [get_ports -regexp -nocase  -quiet dp]
set_property -quiet IOSTANDARD LVCMOS33 [get_ports -regexp -nocase  -quiet dp]

set_property -quiet PACKAGE_PIN U2 [get_ports -regexp -nocase  -quiet {an\\[0\\]}]
set_property -quiet PACKAGE_PIN U4 [get_ports -regexp -nocase  -quiet {an\\[1\\]}]
set_property -quiet PACKAGE_PIN V4 [get_ports -regexp -nocase  -quiet {an\\[2\\]}]
set_property -quiet PACKAGE_PIN W4 [get_ports -regexp -nocase  -quiet {an\\[3\\]}]


#Buttons
set_property -quiet PACKAGE_PIN U18 [get_ports -regexp -nocase  -quiet btnC]
set_property -quiet PACKAGE_PIN T18 [get_ports -regexp -nocase  -quiet btnU]
set_property -quiet PACKAGE_PIN W19 [get_ports -regexp -nocase  -quiet btnL]
set_property -quiet PACKAGE_PIN T17 [get_ports -regexp -nocase  -quiet btnR]
set_property -quiet PACKAGE_PIN U17 [get_ports -regexp -nocase  -quiet btnD]



#Pmod Header JA
set_property -quiet PACKAGE_PIN J1 [get_ports -regexp -nocase  -quiet {JA\\[0\\]}]
set_property -quiet PACKAGE_PIN L2 [get_ports -regexp -nocase  -quiet {JA\\[1\\]}]
set_property -quiet PACKAGE_PIN J2 [get_ports -regexp -nocase  -quiet {JA\\[2\\]}]
set_property -quiet PACKAGE_PIN G2 [get_ports -regexp -nocase  -quiet {JA\\[3\\]}]
set_property -quiet PACKAGE_PIN H1 [get_ports -regexp -nocase  -quiet {JA\\[4\\]}]
set_property -quiet PACKAGE_PIN K2 [get_ports -regexp -nocase  -quiet {JA\\[5\\]}]
set_property -quiet PACKAGE_PIN H2 [get_ports -regexp -nocase  -quiet {JA\\[6\\]}]
set_property -quiet PACKAGE_PIN G3 [get_ports -regexp -nocase  -quiet {JA\\[7\\]}]



#Pmod Header JB\\
set_property -quiet PACKAGE_PIN A14 [get_ports -regexp -nocase  -quiet {JB\\[0\\]}]
set_property -quiet PACKAGE_PIN A16 [get_ports -regexp -nocase  -quiet {JB\\[1\\]}]
set_property -quiet PACKAGE_PIN B15 [get_ports -regexp -nocase  -quiet {JB\\[2\\]}]
set_property -quiet PACKAGE_PIN B16 [get_ports -regexp -nocase  -quiet {JB\\[3\\]}]
set_property -quiet PACKAGE_PIN A15 [get_ports -regexp -nocase  -quiet {JB\\[4\\]}]
set_property -quiet PACKAGE_PIN A17 [get_ports -regexp -nocase  -quiet {JB\\[5\\]}]
set_property -quiet PACKAGE_PIN C15 [get_ports -regexp -nocase  -quiet {JB\\[6\\]}]
set_property -quiet PACKAGE_PIN C16 [get_ports -regexp -nocase  -quiet {JB\\[7\\]}]



#Pmod Header JC
set_property -quiet PACKAGE_PIN K17 [get_ports -regexp -nocase  -quiet {JC\\[0\\]}]
set_property -quiet PACKAGE_PIN M18 [get_ports -regexp -nocase  -quiet {JC\\[1\\]}]
set_property -quiet PACKAGE_PIN N17 [get_ports -regexp -nocase  -quiet {JC\\[2\\]}]
set_property -quiet PACKAGE_PIN P18 [get_ports -regexp -nocase  -quiet {JC\\[3\\]}]
set_property -quiet PACKAGE_PIN L17 [get_ports -regexp -nocase  -quiet {JC\\[4\\]}]
set_property -quiet PACKAGE_PIN M19 [get_ports -regexp -nocase  -quiet {JC\\[5\\]}]
set_property -quiet PACKAGE_PIN P17 [get_ports -regexp -nocase  -quiet {JC\\[6\\]}]
set_property -quiet PACKAGE_PIN R18 [get_ports -regexp -nocase  -quiet {JC\\[7\\]}]


#Pmod Header JXADC
set_property -quiet PACKAGE_PIN J3 [get_ports -regexp -nocase  -quiet {JXADC\\[0\\]}]
set_property -quiet PACKAGE_PIN L3 [get_ports -regexp -nocase  -quiet {JXADC\\[1\\]}]
set_property -quiet PACKAGE_PIN M2 [get_ports -regexp -nocase  -quiet {JXADC\\[2\\]}]
set_property -quiet PACKAGE_PIN N2 [get_ports -regexp -nocase  -quiet {JXADC\\[3\\]}]
set_property -quiet PACKAGE_PIN K3 [get_ports -regexp -nocase  -quiet {JXADC\\[4\\]}]
set_property -quiet PACKAGE_PIN M3 [get_ports -regexp -nocase  -quiet {JXADC\\[5\\]}]
set_property -quiet PACKAGE_PIN M1 [get_ports -regexp -nocase  -quiet {JXADC\\[6\\]}]
set_property -quiet PACKAGE_PIN N1 [get_ports -regexp -nocase  -quiet {JXADC\\[7\\]}]



#VGA Connector
set_property -quiet PACKAGE_PIN G19 [get_ports -regexp -nocase  -quiet {vgaRed\\[0\\]}]
set_property -quiet PACKAGE_PIN H19 [get_ports -regexp -nocase  -quiet {vgaRed\\[1\\]}]
set_property -quiet PACKAGE_PIN J19 [get_ports -regexp -nocase  -quiet {vgaRed\\[2\\]}]
set_property -quiet PACKAGE_PIN N19 [get_ports -regexp -nocase  -quiet {vgaRed\\[3\\]}]
set_property -quiet PACKAGE_PIN N18 [get_ports -regexp -nocase  -quiet {vgaBlue\\[0\\]}]
set_property -quiet PACKAGE_PIN L18 [get_ports -regexp -nocase  -quiet {vgaBlue\\[1\\]}]
set_property -quiet PACKAGE_PIN K18 [get_ports -regexp -nocase  -quiet {vgaBlue\\[2\\]}]
set_property -quiet PACKAGE_PIN J18 [get_ports -regexp -nocase  -quiet {vgaBlue\\[3\\]}]
set_property -quiet PACKAGE_PIN J17 [get_ports -regexp -nocase  -quiet {vgaGreen\\[0\\]}]
set_property -quiet PACKAGE_PIN H17 [get_ports -regexp -nocase  -quiet {vgaGreen\\[1\\]}]
set_property -quiet PACKAGE_PIN G17 [get_ports -regexp -nocase  -quiet {vgaGreen\\[2\\]}]
set_property -quiet PACKAGE_PIN D17 [get_ports -regexp -nocase  -quiet {vgaGreen\\[3\\]}]
set_property -quiet PACKAGE_PIN P19 [get_ports -regexp -nocase  -quiet Hsync]
set_property -quiet PACKAGE_PIN R19 [get_ports -regexp -nocase  -quiet Vsync]


#USB-RS232 Interface
set_property -quiet PACKAGE_PIN B18 [get_ports -regexp -nocase  -quiet RsRx]
set_property -quiet PACKAGE_PIN A18 [get_ports -regexp -nocase  -quiet RsTx]


#USB HID (PS/2)
set_property -quiet PACKAGE_PIN C17 [get_ports -regexp -nocase  -quiet PS2Clk]
set_property -quiet PULLUP true [get_ports -regexp -nocase  -quiet PS2Clk]
set_property -quiet PACKAGE_PIN B17 [get_ports -regexp -nocase  -quiet PS2Data]
set_property -quiet PULLUP true [get_ports -regexp -nocase  -quiet PS2Data]


#Quad SPI Flash
#Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
#STARTUPE2 primitive.
set_property -quiet PACKAGE_PIN D18 [get_ports -regexp -nocase  -quiet {QspiDB\\[0\\]}]
set_property -quiet PACKAGE_PIN D19 [get_ports -regexp -nocase  -quiet {QspiDB\\[1\\]}]
set_property -quiet PACKAGE_PIN G18 [get_ports -regexp -nocase  -quiet {QspiDB\\[2\\]}]
set_property -quiet PACKAGE_PIN F18 [get_ports -regexp -nocase  -quiet {QspiDB\\[3\\]}]
set_property -quiet PACKAGE_PIN K19 [get_ports -regexp -nocase  -quiet QspiCSn]


# Configuration options, can be used for all designs
set_property -quiet CONFIG_VOLTAGE 3.3 [current_design]
set_property -quiet CFGBVS VCCO [current_design]
