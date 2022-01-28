# 5G RPi 4 PoE Modem Build
Repository of all information related to my Raspberry Pi4 5G PoE modem build

## Design Philosophy & Guiding Principles
The goal of this project is can be summed up as follows: Build a capable, stable, low maintenance, cost-concious 5G WAN solution using well-supported hardware/software components which can be installed outdoors and preserve hardware longevity by incorporating adequate thermal controls into the design. A checklist of guiding principles in no particular order:

* Select quality hardware and parts which are inexpensive but well supported
* Choose base software components which are stable and well documented
* Utilize pre-compiled, stable software packages wherever possible
* Assemble hardware & configure software in a way which reduces or eliminates human intervention
* Sufficiently document the build and configuration process so others can produce the same end results


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
Since this will be going outside in the Midwestern US it is going to get hot and humid during some seasons so, in order to control heat and humidity, we will be installing two vents on the front door of the enclosure. The bottom will be a cold air intake and the top will be a hot air exhaust (since hot air rises). I chose the IPV-1116 vents because they are completed covered on 3 out of 4 sides and have a grid with small holes for air to pass through. The hole size required for the vents is kind of odd at 3.46". Luckily this worked out to exactly 88mm and by searching for that I was able to source one online. Even though the vents have a pretty small grid for air ingress/egress, sometimes we get foggy/misty weather in the Summer and Fall so I wanted to hedge my bets against any droplets being pulled in by the fans by installing metal mesh PC fan filters on the inside of the vents between them and the fan.

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5377.jpg" width="200" height="200" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5378.jpg" width="200" height="200" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5379.jpg" width="200" height="200" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5380.jpg" width="200" height="200" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5381.jpg" width="200" height="200" />



## Historical Background
### Let's start at the beginning...
Back in 2016 I decided to drop my only viable broadband provider (Comcast) due to consistent outages and their unwillingness to search out and resolve the root issue. I was tired of paying top dollar for a service that always dropped out at the worst possible times. Looking at LTE speedtests on my cell phone it was clear that cellular networks had matured enough to offer the bandwidth and stability I required for home internet. However, it was not yet immediately clear how to craft a cellular internet solution which would service both the wired and wireless devices on my LAN with an acceptible level of stability and low maintenance overhead (both in terms of time and money).

### Android Stuck to the Wall
The early days of this quest must have looked pretty funny to most people. My first setup involved a cheap android phone (Blu R1 HD) velcro'ed up high on our living room wall (where it received the best signal) running PdaNet USB tethered to an i5 Intel NUC running Windows 10 with Internet Connection Sharing (ICS) enabled. The ICS enabled NIC on the NUC was then fed via Ethernet to an Asus RT-AC68U connected as WAN. After having Windows Updates reboot the NUC and/or other Windoze issues take down the Internet a few times I realized I needed to switch to a Linux based platform for better stability. This led me to switch to a GL.iNet GL-MT300N-V2 travel router running EasyTether to accomplish the same USB tether type connectivity back to the cell phone. This setup actually ran pretty well but still had droputs from time to time where EasyTether needed a restart etc.

### My Very First Netgear
At that point I knew I needed to remove the cell phone and underlying android tether apps from the equation in order to achieve even better staility and less intervention/maintenace. This led me first to the Netgear LB1120 which allowed me to eliminate the GL.iNet router and connect directly to the Asus router. Naively I also purchased the LB1120 based on its advertised ability of Bridge/IP-Passthrough for the cellular modem interface (later I found that most ceullar carriers were behind CGNAT which nullified any real benefit to having this passthrough functionality; more on that later). The LB1120 connected directly to the Asus router worked pretty well but the internal antennas were not great and speeds suffered because of this. I tried to mitigate this by mounting a pair of Yagi direction antennas on the side of my house pointed at the nearest cell tower with coax back into the house connected to the LB1120. However, due to the length of coax (30ft+), mis-matched impedence of the cable I had available (75-ohm vs. 50-ohm on the modem), and need for adapter pigtails (F-Type to TS9) this antenna setup did not improve signal by a sizable margin. I also found out that this modem didn't have that many LTE bands and lacked key features like Carrier Aggregation (CA). All of these things considered, I decided I needed to move on from the LB1120.

### Inexpensive Sierra Modem
At this point I started playing around with OpenWRT and began looking for an inexpensive modem to use with OpenWRT which could make use of my current antenna setup. I tested some hostless modems that provided an Ethernet interface in OpenWRT right out of the box. Those devices were convenient but those modems lacked a lot of US LTE bands and had limited aggregation capabilities. Finally I found the Sierra EM7455 which could be purchased inexpensively in resale channels like eBay due to the fact it came pre-installed with many OEM laptops which were coming off their lease agreements. The interface for the Sierra modem was raw-IP, not Ethernet, which required QMI or MBIM protocol on the host OS to establish a connection. The modem also had an M.2 connection so a USB-to-M.2 Key B adapter sled with SIM card slot was needed to connect it to a host OS.

### The Birth of ROOter
I quickly learned that vanilla OpenWRT required some very specific software packages and configuration in order to get it working with the EM7455 I purchased and the result was that as cheap, nicely modular, and configurable this solution was, it was not ready for primetime. About this time I came across the legendary Australian broadband forum, Whirlpool, and the prolific ROOter project thread headed up by user "Dairyman". This was the most excited I had been since starting my question as I finally found a group of folks doing exactly what I wanted to do: using off-the-shelf raw-IP modems with OpenWRT as host OS. This thread gave birth to what eventually became "ROOter GoldenOrb" firmware; a heavily customized version of OpenWRT which had support for many commodity raw-IP modems. Many of the problems raw-IP modems presented in OpenWRT were scripted around by Dairman and his excellent team of colloaborators and delivered as a true FOSS labor of love via https://www.ofmodemsandmen.com/.

### Useless IP-Passthrough and a Solution
Around this time I began to understand US cellular networks better and found that even if one had a device capable of IP Passthrough to provide a public IP directly on the WAN interface of one's router, this was essentially useless because most cellular APNs (Access Point Names) provided a shared pool of IP addresses which were all behind carrier grade NAT (CGNAT) which meant there was no ability to forward ports from the Internet back to LAN client programs which required it (i.e. multiplayer video games, web servers, etc.). Only one carrier, Sprint (at the time), offered a consumer plan add-on option for having a true public IP and their coverage near me was not great. So, I looked into my options and found that a solution would be to use a virtual private server (VPS) which did have a public IP and establish a VPN tunnel between it and my LAN in order to forward any ports I needed to. At the time the most feasible VPN option was OpenVPN. This led me to swap the Asus router out for an x86 thin client running pfSense. A much more powerful option for routing port forward OpenVPN traffic.

### ROOter w/ Sierra EM7455 and 'The Need for Speed'
Back on the modem front, I flashed an older Linksys WRT router with GoldenOrb to use with the Sierra EM7455 I had purchased and was soon off to the races. The result was a WAN connection to my Asus WiFi router which was nearly as stable as the LB1120 I had used previously but with better speeds due to more LTE band and carrier aggregation support. I ran this ROOter setup for quite a while with my sub-par Yagi MIMO antenna setup but eventually got the "itch" for more speed which led me to the Netgear MR1100. The MR1100 was a hotspot device but provided a Cat.16 LTE modem (the EM7455 was only Cat.6) which offered the ability of 4x4 MIMO and additional CA capabilities, could be powered without the battery, and most importantly, featured an Ethernet port directly on the device which abstracted the problem of dealing raw-IP interfaces directly.

### Rethinking antennas and Modem Placement
When migrating to the MR1100 I used the opportunity to re-assess my antenna setup and signal loss which affected it. It soon became clear from my research that in order to achieve the best signal strength one should limit the distance between the modem and the antennas to be as short as possible. With this in mind I worked on creating an external, weatherproof enclosure for the MR1100 with short adapter pigtails which allowed the unit to connect to N-type MIMO panel antennas which I had purchased after selling the Yagis (Yagis were also not great with summer foliage between myself and the tower; panel sytle directionals are more tolerant in this regard). In order to connect data and power to the unit outside, I purchased an 802.3AT power over Ethernet (PoE) injector and Gigabit splitter. This setup along with the new pfSense router/firewall, and new Ubiquiti UniFi WiFi APs provided the most stable setup thus far and I ran this configuration for over a year.

### Netgear Love-Affair Continues
Soon, I got the speed itch again and began searching for my next setup which should include the latest LTE bands and CA combinations added by my carrier. My search again led me back to Netgear and their new LBR20 unit is part of the Orbi mesh WiFi ecosystem. I honestly could care less for the WiFi capabilities as my UniFi setup was already providing the speed and coverage I needed across all devices, but the Cat.18 Quectel EG18NA modem inside the LBR20 and OpenWRT based firmware underneath is what caused me to pre-order it even before it was released. I disassembled the unit and converted it into an outdoor PoE powered solution reusing the panel antennas I used with the MR1100 and it has been quite solid running Voxel firmware. My complete journey with the LBR20 is covered here in detail so I won't re-hash it all here: https://wirelessjoint.com/viewtopic.php?t=1876 .

### The Push to 5G
While the LBR20 still serves my current needs, I am looking ahead to 5G (New Radio, aka 'NR') since its deployment has recently become available in my area. From my initial testing, the connection speed increase (both download and upload) and lower latency provided even by NR non-standalone (NSA) are significant when compared to LTE so this pushed me to look at 5G modems. I initially looked at the Netgear NBR750 as it is the 5G/WiFi 6 successor to my LBR20. However, it seems Netgear has lost its blessed mind when pricing this unit. At present in the US it is only sold in a combo pack (SKU: NBK752) with a paired Orbi mesh AP (model RBS750) for the princely (outrageous?) sum of $1099.99 USD. After my recovery from nearly choking to death when my eyes beheld this price, I looked up the FCC filing for it and saw that it's using a commodity modem used in many other 5G devcies: a Quectel RM502Q-AE. Armed with this knowledge, I begain to craft my next modem setup around the RM502Q-AE given it could be purchased for less than half the price of an NBR750 setup. Thus this '5G Raspberry Pi Build' was born :)
