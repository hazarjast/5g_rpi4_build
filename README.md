# 5G RPi 4 PoE Modem Build
Repository of all information related to my Raspberry Pi4 5G PoE modem build

## Background & Guiding Principles
Back in 2016 I decided to drop my only viable broadband provider (Comcast) due to consistent outages and their unwillingness to search out and resolve the root issue. I was tired of paying top dollar for a service that always dropped out at the worst possible times. Looking at LTE speedtests on my cell phone it was clear that cellular networks had matured enough to offer the bandwidth and stability I required for home internet. However, it was not yet immediately clear how to craft a cellular internet solution which would service both the wired and wireless devices on my LAN with an acceptible level of stability and low maintenance overhead (both in terms of time and money).

The early days of this quest must have looked pretty funny to most people. My first setup involved a cheap android phone (Blu R1 HD) velcro'ed to our up high on our living room wall (where it received the best signal) running PdaNet, USB tethered to an i5 Intel NUC running Windows 10 with Internet Connection Sharing (ICS) enabled. The ICS enabled NIC on the NUC was then fed via Ethernet to an Asus RT-AC68U connected as WAN. After having Windows Updates reboot the NUC and/or other Windoze issues take down the Internet a few times I realized I needed to switch to a Linux based platform for better stability. This led me to switch to a GL.iNet GL-MT300N-V2 travel router running EasyTether to accomplish the same USB tether type connectivity back to the cell phone. This setup actually ran pretty well but still had droputs from time to time where EasyTether needed a restart etc.

At that point I knew I needed to remove the cell phone and underlying android tether apps from the equation in order to achieve even better staility and less intervention/maintenace. This led me first to the Netgear LB1120 which allowed me to eliminate the GL.iNet router and connect directly to the Asus router. Naively I also purchased the LB1120 based on its advertised ability of Bridge/IP-Passthrough for the cellular modem interface (later I found that most ceullar carriers were behind CGNAT which nullified any real benefit to having this passthrough functionality; more on that later). The LB1120 connected directly to the Asus router worked pretty well but the internal antennas were not great and speeds suffered because of this. I tried to mitigate this by mounting a pair of Yagi direction antennas on the side of my house pointed at the nearest cell tower with coax back into the house connected to the LB1120. However, due to the length of coax (30ft+), mis-matched impedence of the cable I had available (75-ohm vs. 50-ohm on the modem), and need for adapter pigtails (F-Type to TS9) this antenna setup did not improve signal by a sizable margin.

## Parts List
* **Quectel RM502Q-AE**
  * Supports all current LTE and NR low and mid-spectrum bands by US carriers (no mmWave)
  * SDX55 chipset supporting NR SA, NR CA (FDD+FDD, TDD+TDD), NSA (LTE+NR), and VoLTE
  * M.2 Key B connection supporting USB 3.x and PCIe w/ IPEX4/MHF4 antenna connectors
* **Copper Heatsink**
  * Phyiscal dimensions: 40x26x4mm
* **M.2 to USB 3.0 Evaluation Board**
  * "5G M.2 TO USB3.0-KIT PRO"
  * 5V DC carrel connector and switch; accepts external 5V power source
  * USB Type-C connector with Texas Instruments USB 3.0 control chip
  * Dual spring-loaded nano SIM slots
  * M.2 Key B connector for modem
* **12dBi 5G PCB Omnidirectional Antennas (x4)**
  * 20cm cable
  * IPEX4/MHF4 connectors
  * Frequency range: 600-6000Mhz
  * Physical dimensions: 100x21mm
* **Raspberry Pi 4B**
  * 4GB SKU
* **RPi 4 Heatsink Kit**
  * Self-adhesive 3M tape
* **IP67 Outdoor Project Box**
  * Plastic, pre-drilled mounting plate and included hardware
  * Stainless steel latches
  * Physical external dimensions 290x190x140mm
* **Large Air & Moisture Vent (x2)**
  * Bud Industries IPV-1116
  * Physical dimensions 100x96x65.5mm
  * Hole dimension diameter: 88mm
* **88mm Hole Saw**
  * Stainless Steel
* **80mm PC Fan (x2)**
  * USB powered (5v)
* **80mm PC Fan Filter Grills (x2)**
  * Aluminum frame
  * Fine Stainless Steel mesh
* **USB 2.0 'Y' cable**
  * 1x Male USB-A Data+Power
  * 2x Female USB-A (1x Power only, 1x Data+Power)
* **18AWG DC Power Cables**
  * 5.5x2.1mm 
  * Male+Female pairs (6x)
* **DC Step down voltage regulator (i.e. buck converter)**
  * 9v-36v input / 5v 6a output
  * DC barrel connector input/output
  * Additional USB-A connector output
* **Double Sided Mounting Tape**
  * 1" wide
* **802.3AT PoE Gigabit Splitter**
  * DC 48v input
  * DC 18v/12v/9v/5v output (30w max)
* **802.3AT PoE Gigabit Injector**
  * AC 120v input
  * DC 48v output (30w max)
* **320pc Nylon Standoff/Screw/Washer Kit**
  * Assorted lengths
  * M3 size
* **Outdoor-grade Zip Cable Ties (2 sizes)**
  * 10cm length, 18LB loop tensile strength (100ct)
  * 20cm length, 50LB loop tensile strength (100ct)
  * Withstands a temperature range of -40-85c
* **Wago LEVER-NUTS**
  * 3-Conductor
  * 24-12 AWG 

## Hardware Build
### Vent and Fan Install
