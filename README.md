# 5G RPi 4 PoE Modem Build
Repository of all information related to my Raspberry Pi4 5G PoE modem build.

If this project benefitted you in some way please consider supporting my efforts with a small donation below:

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/Donate_QR_Code.png" />

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=AB6H6ER4RWT74)


- [Table of Contents](#5g-rpi-4-poe-modem-build)
  * [Design Philosophy & Guiding Principles](#design-philosophy--guiding-principles)
  * [Parts List](#parts-list)
  * [Important Component Selection Information](#important-component-selection-information)
    + [Quectel RM502Q-AE](#quectel-rm502q-ae)
    + [5G M.2 to USB 3.0 Evaluation Board (EVB)](#5g-m2-to-usb-30-evaluation-board-evb)
    + [Raspberry Pi 4B, 4GB](#raspberry-pi-4b-4gb)
    + [D-Link DUB-H4 (HW. Rev. "D")](#d-link-dub-h4-hw-rev-d)
    + [80mm USB PC Fans (2x)](#80mm-usb-pc-fans-2x)
    + [Gigabit PoE Splitter](#gigabit-poe-splitter)
    + [Buck Converter (DC voltage step-down regulator)](#buck-converter-dc-voltage-step-down-regulator)
    + [PCB Antennas](#pcb-antennas)
  * [Hardware Build](#hardware-build)
    + [Vent, Fan, and Wire Gland Install](#vent-fan-and-wire-gland-install)
    + [Mounting the Core Components](#mounting-the-core-components)
      - [Overall Layout and Mounting the PoE Splitter](#overall-layout-and-mounting-the-poe-splitter)
      - [Buck Converter](#buck-converter)
      - [Raspberry Pi](#raspberry-pi)
      - [Modem EVB](#modem-evb)
    + [Connections and Cabling](#connections-and-cabling)
      - [Power Cables](#power-cables)
      - [Voltage Validation](#voltage-validation)
      - [USB and Ethernet Connections](#usb-and-ethernet-connections)
      - [PCB Antennas](#pcb-antennas-1)
  * [Software Build](#software-build)
    + [Operating System Selection](#operating-system-selection)
    + [OpenWRT Pre-installation Prep](#openwrt-pre-installation-prep)
    + [OpenWRT Install and Initial Configuration](#openwrt-install-and-initial-configuration)
    + [Temporary Creation of a USB WAN](#temporary-creation-of-a-usb-wan)
    + [Install All Required Packages](#install-all-required-packages)
    + [Flash Modem Firmware Update](#flash-modem-firmware-update)
    + [Configure Modem Interface & Remove Temp USB WAN](#configure-modem-interface--remove-temp-usb-wan)
    + [Add Custom Firewall Rules](#add-custom-firewall-rules)
    + [Configure DMZ to Main Router](#configure-dmz-to-main-router)
    + [Helper Scripts](#helper-scripts)
      - [fancontrol.sh](#fancontrolsh)
      - [modemwatcher.sh](#modemwatchersh)
      - [quickycom.sh](#quickycomsh)
    + [Switch Modem to Generic Image](#switch-modem-to-generic-image)
    + [Disable Modem NR SA](#disable-modem-nr-sa)
  * [Results](#results)  
  * [ToDo List](#todo-list)
  * [Historical Background](#historical-background)
    + [Let's start at the beginning...](#lets-start-at-the-beginning)
    + [Android Stuck to the Wall](#android-stuck-to-the-wall)
    + [My Very First Netgear](#my-very-first-netgear)
    + [Inexpensive Sierra Modem](#inexpensive-sierra-modem)
    + [The Birth of ROOter](#the-birth-of-rooter)
    + [Useless IP-Passthrough and a Solution](#useless-ip-passthrough-and-a-solution)
    + [ROOter w/ Sierra EM7455 and 'The Need for Speed'](#rooter-w-sierra-em7455-and-the-need-for-speed)
    + [Rethinking antennas and Modem Placement](#rethinking-antennas-and-modem-placement)
    + [Netgear Love-Affair Continues](#netgear-love-affair-continues)
    + [The Push to 5G](#the-push-to-5g)

## Design Philosophy & Guiding Principles
The goal of this project can be summed up as follows: Build a capable, stable, low maintenance, cost conscious 5G WAN solution using well-supported hardware/software components which can be installed outdoors and preserve hardware longevity by incorporating adequate thermal controls into the design. A checklist of guiding principles in no particular order:

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
* **Copper Modem Heatsink**
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
* **Class 10 MicroSD Card**
  * 32GB (simply because it was cheap)
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
  * Steel alloy
* **80mm PC Fan (x2)**
  * USB powered (5v)
* **80mm PC Fan Filter Grills (x2)**
  * Aluminum frame
  * Fine Stainless Steel mesh
* **USB 2.0 'Y' cable**
  * 1x female USB-A Data+Power
  * 2x Male USB-A (1x Power only, 1x Data+Power)
* **USB Network Adapter**
  * Chipset should be supported by OpenWRT (Asix in this case)
  * Will only be used temporarily to download modem packages
* **USB 2.0, 4-port Hub***
  * D-Link DUB-H4 (HW. Rev. "D")
  * Small, square, black version
  * Provides PPPS (Per Port Power Switching)
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
* **1' USB-C to USB-A cable**
  * Connects modem EVB to RPi USB 3.0
* **6" USB-C PD to DC cable**
  * Connects buck converter to RPi power
* **6" DC Male to DC Male**
  * Connects buck converter to modem EVB
* **1' Cat6 Ethernet Cable**
  * Connects PoE Splitter to RPi NIC
* **Terminated Ethernet Wire Gland - Gray Nylon**
  * Heyco, 'Heyco-Tite' Liquid Tight Cordgrip
  * Part #s: M3201GBH (gland), 8464 (locknut)
  * Accepts pre-terminated Ethernet (RJ45)
  * 8.5mm NPT 

## Important Component Selection Information
### Quectel RM502Q-AE
The star of our project. Provides all the niceties that a modem with the Qualcomm SDX55 chipset should provide including NR SA/NSA/CA with M.2 Key B connector and choice of USB 3.0 or PCIe interfaces and both QMI (default) or MBIM raw-IP protocol support. Supports all available carrier low and mid bands for LTE and NR. No mmWave here but, since I don't live in a downtown/metro area, I won't be seeing any mmWave here any time soon (or ever, really). For power requirements she runs on 5v with a draw of up to 3a at peak load. Operating temperature range is from -30c to +70c.

### 5G M.2 to USB 3.0 Evaluation Board (EVB)
There are a ton of different M.2 to USB 3.0 adapters that exist but most do not have Key B, M.2 slots and are designed for SSDs and not modem interfaces (USB). Many of the ones that are Key B have very basic power circuitry, many delivering even below the 900ma USB 3.0 spec current. Obviously this is a huge problem for a modem that can draw up to 3a at peak. For this reason a USB adapter (a.k.a. "USB Sled") that offers supplemntal DC power input is a necessity. There are a few out there with one of the best in the industry sold by The Wireless Haven (prev. "LTE Fix"). However, when procuring the RM502Q-AE I came across this EVB which featured dual nano SIM slots along with a USB-C data connector in addition to accepting 5v DC supplement voltage. The supplement voltage input is also controlled by a toggle switch which can be handy. So, I picked this one up for those compelling reasons.

### Raspberry Pi 4B, 4GB
I selected the RPi 4B for it's USB 3.0 ports and 1Gbps NIC. The 4GB of RAM is completely overkill for our project but due to supply chain issues it was the only SKU I could get my hands on at the moment. If you can find the 2GB for a lower cost, then that would be more than adequate as well. Power is also 5v via USB-C connector and draw is up to 1.8a when we do not factor in connected USB peripheral draw. Per specification the USB 2.0 ports deliver a maximum of 500ma per port and the USB 3.0 ports deliver a maximum of 900ma per port. It is also worth noting that the RPi USB ports are ganged together for power. Because of these limitations, we will need a a USB hub which supports Per Port Power Switching (PPPS) and also a way to supplement additional amperage to support our fans (I will touch on this more below).

### D-Link DUB-H4 (HW. Rev. "D")
For this project we will be using the 'uhubctl' software package which toggles USB port power to the fans on/off programatically. Since the RPi's USB ports are ganged for power, turning them on/off programatically is an "all or nothing" affair which doesn't work for us since we obviously still need the USB 3.0 interface available at all times for the modem. Thus we need to connect the fans to a separate hub which supports Per Port Power Switching (PPPS) that will be used by 'uhubctl' to turn them on/off. There are PPPS hubs made specifically for the RPi like the Uugear MEGA4 but those aren't stocked in the US so with overseas shipping can be a bit pricey compared to other options. Because of this, I searched out and found this specific model D-Link on ye olde eBay which was a cheaper option, shipped. There are not many USB hubs which leave the factory with the hardware components required for PPPS (eliminating them in the final design saves OEMs money) so it's important we select one which is confirmed to have it. The 'uhubctl' github page provides a handy list of known-working hubs here: https://github.com/mvp/uhubctl#compatible-usb-hubs. Our D-Link hub connects via MiniUSB to USB-A and draws only about 100ma before any peripherals are connected. It comes with an AC adapter (5v 2.5a) which we won't need for our use case.

### 80mm USB PC Fans (2x)
To keep things cool I added 2, 80mm USB (5v) PC fans to the vents that were installed in the enclosure (one for cold air ingress, one for hot air exhaust). These will be programatically controlled through the USB hub and each draw 400ma max. Mounting screws were included.

### Gigabit PoE Splitter
Yes, 5G will some day possibly provide over 1Gbps speeds in my area but at this point it is about 200Mbps which is far more than enough for my needs. That and the fact that routing traffic of that speed through the RPi would require a USB 2.5Gbps+ NIC and special config (over-clock, jumbo frames, etc.), made it easy for me to settle on 1Gbps for the interface. The RPi already features a native 1Gbps port and there are plenty of Gigabit 802.3 standards compliant PoE injectors and splitters on the market already. This particular unit was chosen since it will output 30w albeit at the 12v setting only (12v@2.5a). Which finally brings us to the need for a buck converter...

### Buck Converter (DC voltage step-down regulator)
This little guy takes 9-36v DC input through bare wire or a barrel connector (we are supplying it with 12v@2.5a from the PoE splitter) and outputs 5v through USB and/or bare wire connectors at up to 6a. This is perfect for us and fits within the power budget which the other components will draw (Modem@3a + RPi@1.8a + Hub@0.1a + Fans@0.8a = 5.7a max). The connectors are also great because we can use the bare wire connectors to split out power to the modem EVB and RPi while connecting the power-only end of our USB 2.0 Y-cable to the USB connector which will provide the supplemental power we need for our hub-connected fans.

### PCB Antennas
Since I have a cell tower less than two miles away from me with generally good line-of-sight access, I opted to go for some 12dBi omnidirectional PCB antennas to mount inside the outdoor enclosure with the rest of the components. If you are further from a tower, purchasing some IPEX4/MHF4 to N-type or SMA pigtails which econnect to exteneral directional antennas may be a better choice.

## Hardware Build
### Vent, Fan, and Wire Gland Install
Since this will be going outside in the Midwestern US it is going to get hot and humid during some seasons so, in order to control heat and humidity, we will be installing two vents on the front door of the enclosure. The bottom will be a cold air intake and the top will be a hot air exhaust (since hot air rises). I chose the IPV-1116 vents because they are completely covered on 3 out of 4 sides and have a grid with small holes for air to pass through. The hole size required for the vents is kind of odd at 3.46". Luckily this worked out to exactly 88mm and by searching for the metric meausrement I was able to source one online.

The fans installed easily since they came with screws and the vents had the necessary screw holes already. When installing the fans it was important to check they were installed correctly so that the bottom fan drew air in and the top fan blew air out. Luckily the fans had clear labels on the edges which indicated the direction of airflow. Even though the vents have a pretty small grid for air ingress/egress, sometimes we get foggy/misty weather in the Summer and Fall so I wanted to hedge my bets against any droplets being pulled in by the fans by installing metal mesh PC fan filters on the inside of the vents between them and the fan. The wire gland install is not pictured here but it's just a simple 1/2" spade bit drilled into the bottom of the enclosure with some sanding of the resulting hole so the threads slid in easy; then just needed to tighten the locknut on from the inside.

<table >
	<tbody>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5377.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5378.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5379.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5380.jpg" width="200" height="200" /></td>
		</tr>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5381.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5422.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5421.jpg" width="200" height="200" /></td>
			<td align= "center"><a href="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5396.MOV">Fan Test Video</a></td>
		</tr>
	</tbody>
</table>

### Mounting the Core Components
#### Overall Layout and Mounting the PoE Splitter
This part took some trial and error to figure out how to securely attach all the major components to the plastic mounting plate of the enclosure in such a tight space. The PoE splitter already had nice mounting holes and doesn't get that hot so I left it's cover on. Basically oriented things in a way so that cables could be routed under or around all components to keep them low and out of the way of the fan blades when the enclosure door is closed. I also checked to ensure that, when installed in the case, there would be no issues inserting or removing cables from their ports (didn't want anything too close to each other or the sides for this reason). I mounted the PoE splitter first by threading the smaller cable ties in through the mounting holes, all the way through the plastic mounting plate coming back up through the plate through an adjacent square before threading the zip tie into itself and closing the loop tightly to secure it in place. I did this on all 4 corners.

#### Buck Converter
Next came the buck converter (DC voltage step down regulator). Mounting this one was fun because there were no mounting holes and the underside of the mounting plate where I wanted to place this had a raised plastic edge so I had to adjust the placement down slightly to where there was a break in the plastic edge to get pulled down good and tight. Word of warning here to be extra careful and ensure the zip ties are away from the solid capacitors. Luckily these converters came in a two pack because on the first one I pulled too hard and the zip tie slipped and sheared one of the capacitors right off the board, lol. Needles to say there was lots of cursing involved as I cut it loose and installed the second one more carefully. Once this was secured, I used the provided DC barrel connector cable to connect the PoE splitter to the converter and secured the excess wire with a couple additional cable ties.

#### Raspberry Pi
The RPi was next to be mounted but width-wise where I needed to place it there was not enough room to place it without the port connectors butting up against the buck converter. So, I followed the motto of "If you can't scale out, scale up" and used some of the medium sized M3 nylon standoffs from the assorted M3 size kit making sure their screwed in position on the panel lined up with the mounting holes on the RPi PCB. I used the corresponding sized nylon nuts to secure the standoffs from the back side of the mounting panel. I did not bother with the power cabling yet as I needed to place the modem EVB in place first to get an idea of the best way to route all the power cables from there. As a final step for the RPi, I added heatsinks to the SoC and surrounding chips.

#### Modem EVB
Mounting the modem EVB was an interesting challenge since it only had two holes drilled on one side of the PCB with power and data connectors on the other, far side with no other holes to be found. The nylon washers in the standoff kit saved the day. I was able to position 5 of the tallest standoffs strategically along the edge of the PCB where I then used two of the nylon washers with the shortest nylon screw to "sandwich" and grip the PCB in between the two washers at each standoff. The standoffs themselves were secured from the back of the mounting plate with nylon nuts (same as the RPi). This setup secured the EVB very well without any play at all. This 'pinching' washer setup on the standoffs was positioned in a way which provided the best support while leaving the SIM slots unobstructed. I was then able to securely install the modem and its heatsink.

<table >
	<tbody>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/66296323492__27087534-AA27-4171-A950-CDAFE049E74A.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5384.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5395.jpg" width="200" height="200" /></td>
		</tr>
	</tbody>
</table>


### Connections and Cabling
#### Power Cables
Once the main components were mounted to the mounting plate the next step was connecting everything up and routing the wires. I began with what was already mounted to the mounting plate, starting with the bare wire connector output on the buck converter. Since the package of DC Male and Female connectors I bought had excess wire, I was able to clip them shorter and use the additional lengths of wire to distribute the power from the converter to the Lever Nuts. From the Lever Nuts, I connected two female DC connectors; one of these connected to the male-DC-to-USB-C to power the RPi, the other connected to the male-DC-to-male-DC cable to power the modem EVB. The lengths of wire between the converter and Lever Nuts, and from the Lever Nuts to the female DC connectors were all cut to appropriate lengths and neatly routed underneath the EVB and RPi. They were then secured through the mounting plate with the smaller zip ties to keep them stationary and ensure no contact was made with any of the solder joints underneath the RPi (where the male and female DC connectors were joined. Small pieces of mounting tape were used to adhere the Lever Nuts to the mounting plate to keep them from moving around.

#### Voltage Validation
Because we are working with different voltages and have invested a good chunk of change into the components we are connecting, it is always wise to check all voltage outputs before making the individual component power connections and plugging the PoE injector into mains. First up, I plugged the PoE injector into the wall outlet and connected it via Cat6 cable to the PoE splitter, ensuring the PoE splitter was set to 12v. Nothing was connected to the buck converter at this point. Once I verified the splitter was ouputting 12v (not pictured) I connected it to the buck converter and verified it was providing 5v output. The multimeter reading of a steady 5.20v confirmed we were well within USB spec (official range is 5.25 down to 4.45 for most USB devices powered from a 5v power supply rail).

I then tested the female DC connectors both coming of the Lever Nuts and verified they both read 5.20v as well. From there I connected the double sided male DC connector for the EVB and the DC to USB-C connector for the RPi. The EVB connector tested at 5.20v as expected. Now, since it is generally quite hard to get standard sized multimeter probes wedged into a USB-C connector, to test that one I relied on a fancy pants USB voltage and load tester which features a USB-C input. This showed a reading of roughly 5.15v which was in line with my probe readings (some juice is used by the device itself for the display thus the slight difference in reading). In the photo matrix under this section I have included a rough electrical wiring diagram showing the voltages and how each component is connected to its power source. The only piece not pictured in the illustration is the USB Y-cable power connector which is used to provide supplement power to the USB hub and, in turn, the fans. You can see the y-cable plugged into the converter in the last picture (when the mounting plate was reinstalled into the enclosure).

#### USB and Ethernet Connections
Once power connections were in place (but disconnected from the injector), I connected the USB-C to USB-A cable between the modem EVB and the RPi USB 3.0 port routing the cable nicely in an 'S' shape between/under RPi and EVB PCBs. The USB Y-cable connected to the buck converter was then routed out from under the EVB so that the data+power end fit nicely in the edge gap between the mounting plate and the enclosure wall. A short miniUSB to USB-A cable from the USB hub was plugged into the female side of the y-cable and the data+power male end was connected to the RPi USB 2.0 port. The USB hub was positioned in the bottom left corner of the enclosure positioning it nicely within reach of the USB connectors from the fans. A small piece of mounting tape was used to adhere the hub to the inside wall of the enclosure and keep it staionary before plugging the fans into it. Finally a 1' Cat6 cable was connected from the RJ45 Data port of the PoE splitter to the Gigabit NIC port on the RPi. In the final picture of the matrix below you can see the wire gland placement with injector Cat6 Data+Power PoE cable passing through it and connecting to the PoE splitter.

#### PCB Antennas
The 4x PCB antennas were mounted equal distances apart on either side of the case towards the top (metal traces facing upward), furthest away from the highest voltage source. The 20cm cables were a bit short; in hindsight I probably should have ordered them with longer ones for cleaner routing in the gap between the mounting plate and top of the case. Oh well, this will work. The back of the antennas featured a 3M white label self-adhesive. I looked it up on the 3M site and they claim it should hold reasonably in both cold and hot environments so we will not bother with our own mounting tape. The MHF4 connecters were then connected to the modem *very* gingerly using the end of a plastic spudger. The trick is to line them up exactly over the modem connector and apply centered, even pressue until they snap on. Do *NOT* use a metal tool (such as a screwdriver) for this. I have seen way too many people slice through cables and/or shear connectors off the modem when the two metal surfaces invariabley slip away from each other under pressure.



<table >
	<tbody>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5385.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5386.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5387.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5388.jpg" width="200" height="200" /></td>
		</tr>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5389.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5390.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5391.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5392.jpg" width="200" height="200" /></td>
		</tr>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5393.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5394.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5413.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/RenderedImage.jpg" width="200" height="200" /></td>
		</tr>
		<tr>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5419.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5420.jpg" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/5g_modem_wiring.png" width="200" height="200" /></td>
			<td><img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/IMG_5440.jpg" width="200" height="200" /></td>
		</tr>
	</tbody>
</table>

## Software Build
### Operating System Selection
I decided to go with the latest stable OpenWRT (21.02.1) and ModemManager (1.16.6) for this build. I have been following the ModemManager port to OpenWRT for awhile and from the reports I read it seemed this combo was now generally quite reliable. As much as I and many others enjoy and benefit from having used ROOter in previous builds I do feel it can be a bit slow and bloated at times with odd errors from the litany of interconnected scripts which sometimes only a reboot will solve. Since ROOter maintains such a wide router hardware compatibility and continues to receive many feature requests/enhancements from its large and active community, it is not immune to the increasing overhead and complexity that go hand-in-hand with this.

ROOter is certainly the "swiss army knife" of cellular WAN builds but for this build I really wanted to stick with something purpose-built and as close to stock OpenWRT as possible. Especially because I'm not looking for something to perform advanced routing, firewalling, VPN brokering, or DNS filtering capabilities as I already have pfSense/OPNSense with WireGuard and NextDNS running on much more capable hardware to handle these duties. I much prefer a modular approach to network design with a general outlook that can be summarized by the belief that a "Jack of all trades is master of none." So, in this case, we will let our 5G modem host be a modem host and not bog it down with much else.

### OpenWRT Pre-installation Prep
The starting point for this build was of course RTFM (reading the 'fine' manual). In this case OpenWRT already has a nice wiki page for the family of RPi devices: https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi . Here I learned that it is recommended to first load Raspberry Pi OS to perform selection of WiFi country code (in case for some reason we wish to use the WiFi for something later on), and flash the latest eeprom update from the inbuilt 'rpi-eeprom-update' utility for best compatibility. From my Windows 10 PC I downloaded the latest RPi OS Lite image (https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip) and flashed it to microSD using Balena Etcher. Once that was done I inserted the card into the RPi and connected the power to my PoE injector to power everything up. I connected the Ethernet data connection from the injector to my existing LAN so that I could hopefully just SSH into it after it booted and provide a source of internet for the eeprom update.

In OPNSense I found the DHCP lease IP of the booted RPi but quickly came to know that the RPi folks do not have SSH daemon enabled by default so I had to power the RPi off, remove the SD card, mount it on my Ubuntu laptop, mount the '/boot' filesystem from the SD card, and 'touch ssh' there (creating an empty file called 'ssh'). Once this was done I was able to re-insert the SD card into the RPi and it allowed me to SSH into it from there with the default RPi OS root credentials. I then ran 'raspi-config' and chose the option to update 'raspi-config' to ensure I had the latest version. Once 'raspi-config' was updated I set the WiFi country code as recommended by the OpenWRT wiki and set the 'raspi-config' 'Advanced' settings from 'default' relase to 'latest'. This allowed me to get the latest eeprom update via the following commands:

```bash
sudo rpi-eeprom-update
sudo rpi-eeprom-update -a
sudo reboot
```

After the reboot I ran `sudo rpi-eeprom-update` once more to make sure it updated to the latest stable version (it did). I was ready then to flash OpenWRT.

### OpenWRT Install and Initial Configuration
After powering off the RPi ('sudo shutdown -now'), I removed the microSD card and placed it in my Windows PC again to flash the latest stable image downloaded here: https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/openwrt-21.02.1-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz . Using 7-zip I extracted the .img file and flashed it to SD using the same Balena Etcher program as before. We chose the ext4 image over squashfs since space is not a concern (using a 32GB SD card in this case). The ext4 image may wear down the SD storage quicker but considering OpenWRT active logging is all done in RAM and SD cards are cheap to me working with ext4 is worth this trade-off. Especially if we need to expand the root filesystem later for more software package storage etc. Extending the overlay filesystem via extroot under squashfs is a much bigger pain in the butt, IMHO. If ext4 is good enough for the many diverse deployments of RPi OS, then it is good enough for OpenWRT in my book :)

Once the SD card was replaced I disconnected it from my existing LAN and connected it directly to my test bench PC (since the default OpenWRT is 192.168.1.1 it would conflict with any existing LAN using that subnet). Once booted up, I logged in to the web interface and set the root password:

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h39_15.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h39_30.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h39_50.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h40_00.png" />

Given the default IP will conflict with many existing routers running on 192.168.1.1 it will be best to change this as well:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h40_58.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h41_12.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h41_32.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h41_47.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h41_58.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h43_25.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h45_07.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h41_47.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_10h45_24.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_11h21_12.png" />

### Temporary Creation of a USB WAN
First hurdle to get over was the fact that RPi only has one Ethernet port and I needed that to stay configured as LAN for LuCI (web gui) and SSH access. One could move forward in one of three ways:

1. Determine all *.ipk packages and dependencies needed to run a Quectel modem and download them all for offline installation (extremely painful).
2. Setup VLANs with a switch supporting 802.11q  (https://openwrt.org/docs/guide-user/network/vlan/managed_switch)
3. Plug in a USB network adapter (physical 'eth1') to assign as WAN.

Option one is very unrealistic and I have pity for whoever chooses this one. VLANs are nice and probably even better to consider using going forward but all my managed switches are currently being used so I went for option three since I had a Trendnet USB 3.0 Ethernet adapter lying around unused. Only downside to this was that it had an Asix chipset which wasn't supported out of the box. Good news was that it only needed a handful of kmod packages installed to get it working (downloaded them on my workbench PC over wifi and then transferred them to the RPi via WinSCP (if your adapter has a different chipset you'll likely need different packages for this part but this should give an idea of what to look for):

https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/packages/kmod-libphy_5.4.154-1_aarch64_cortex-a72.ipk
https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/packages/kmod-mii_5.4.154-1_aarch64_cortex-a72.ipk
https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/packages/kmod-usb-net_5.4.154-1_aarch64_cortex-a72.ipk
https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/packages/kmod-usb-net-asix-ax88179_5.4.154-1_aarch64_cortex-a72.ipk

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h11_52.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h12_01.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h12_48.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h14_49.png" />

We can then go back into the web interface to configure the newly added device as our temporary WAN interface (you should have your USB adapted to your existing LAN now so it will have access to the Internet once connected):
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_19.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_27.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_59.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h17_34.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h18_00.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h18_50.png" />

### Install All Required Packages
Now that the RPi has Internet access via our temporary WAN, go back to the Putty SSH prompt and issue the follow commands to update the software package lists and install the packatges we need (there are actually more packages which will be installed but they will be installed automatically as dependencies for the packages listed below):

```bash
opkg update
opkg install usbutils kmod-usb-net-qmi-wwan kmod-usb-serial-option luci-proto-modemmanager uhubctl socat coreutils-timeout iptables-mod-ipopt pservice
reboot
```

### Flash Modem Firmware Update
It is usually a good idea to try and have the modem running on the latest available firmware as this generally includes bug fixes and other enhancements by the manufacturer. Here I will lay out the steps for flashing updated firmware under Windows (EVB should be connected to a PC via USB cable and power toggle should be set to USB power only). The firmware updates and their respective flash utilities can be obtained through the vendor you purchased the modem from, assuming they are reputable (shout out to Rich over at The Wireless Haven). In the case of Quectel modems, there are three items which are required to update the firmware: Drivers, QFlash utility, and the modem firmware update itself. Once you have downloaded archives for all three (usually .zip files) you should extract them then proceed as follows below.

First we run the drivers installer executable as Adminstrator and let it finish:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h02_40.png" />

Next we will open Device Manager and expand the COM Ports, making specific note of the modem's DM port:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h04_09.png" />

From the extracted QFlash archive, we will move the 'release' folder to the root of C:\ (doesn't have to be this exact path but there are lots of spaces in the file path of our user's Download directory and the utility does not like spaces; thus easy enough to move to root drive letter for our usage):
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h07_34.png" />

From the extracted firmware folder we will move the 'update' folder into the 'release' folder we just moved to the root of C:\:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h07_50.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h08_19.png" />

Now we will execute "QFlash.exe" as Administrator:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h08_49.png" />

Click on the "Load FW" button and select the "prog_firehose*.mbn" file from under the update folder which we moved under 'C:\Release':
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h10_46.png" />

Set the COM port to the DM port we made note of in the Device Manager and baudrate to '4608006'. Make absolutely sure you've selected the correct DM COM port number!!!:

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h11_05.png" />

Click 'Start' and allow the modem to update. This may take some minutes but will end with status message 'PASS':
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h12_49.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-08_16h14_13.png" />

Once firmware is successfully flashed. Wait at least 30 seconds before disconnecting it from the PC and reconnecting it to the RPi to make sure all post-flash actions have completed.

### Configure Modem Interface & Remove Temp USB WAN
Once packages are installed and OpenWRT has been rebooted, log back into the web interface to configure the modem interface (I have called mine 'WWAN'):
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-10_17h39_30.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-10_17h40_28.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-10_17h41_10.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-10_17h41_47.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-10_17h42_12.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-11_16h37_11.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-11_16h42_03.png" />

### Add Custom Firewall Rules
It will be necessary to add custom firewall rules ('Network > Firewall > Custom Rules') if you are using a SIM provisioned to a plan that differntiates on-device data from hotspot data, else you will exhaust the hotspot bucket and be left with greatly throttled speeds in some cases (Caveat Emptor: this is a ToS violation on some cellular plans so if you get your line/plan canceled by your carrier it's not my fault; you've been warned):

```bash
#IPv4 TTL mod
iptables -w -t mangle -C POSTROUTING -o wwan0 -j TTL --ttl-set 65 > /dev/null 2>&1 || \
iptables -w -t mangle -I POSTROUTING 1 -o wwan0 -j TTL --ttl-set 65

#IPv6 TTL mod (prevents leaks not covered by IPv4 rules)
ip6tables -w -t mangle -C POSTROUTING -o wwan0 -j HL --hl-set 65 > /dev/null 2>&1 || \
ip6tables -w -t mangle -I POSTROUTING 1 -o wwan0 -j HL --hl-set 65`
```

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-15_12h16_28.png" />

If you modem device is not 'wwan0' updated it accordingly in the rules above. The TTL value of 65 is used here because TTL decrements and you need it to hit the cellular network with a TTL of 64 (65-1=64). This value can vary with some LAN configurations and cellular carriers so you may have to use something like 64 or 66 (some claim simply setting it to 64 is carrier agnostic but this has not been my experience, YMMV).

### Configure DMZ to Main Router
Since I am using OPNSense as my main home router and will be using the RPi OpenWRT install as a modem host only, I will be statically assigning the IP address of my OPNSense WAN interface in the same IPv4 subnet as the RPi LAN and setting the RPi as the gateway for Internet traffic. My LAN devices are all IPv4 presently and my carrier, who is fully transitioned to IPv6 on their networks, has a mostly-working 464xlat implementation on their side so I won't be bothering with IPv6 addressing at the OPNSense router WAN or LAN as part of this project.

At this point many will ask: Why not setup a bridge or IPPT (IP Passthrough) to pass the cellular public IP to the OPNSense WAN? There's a couple reasons for this the first of which is how my carrier assigns IP addresses. Since all newer provisioned SIMs from my carrier will only allow attach to the network with a dual stack IPv4v6 (or IPv6 only) PDP connection profile, ModemManager's primary IP for the modem interface is thus IPv6; the IPv4 address is then either set to a CGNAT IP by the carrier or set statically by ModemManager to 192.0.0.2 with gateway on the modem itself as 192.0.0.1. Obviously neither IPv4 address would be publicly routable address space so there's no use bridging it to OPNSense WAN. Furthermore, the IPv6 address assigned by the carrier to the modem interface appears to be behind carrier grade NAT (CGNAT) and/or otherwise blocking unsolicited inbound traffic on IPv6 (i.e. one cannot host anything on the LAN which must be accessed from the Internet. More info here: https://community.t-mobile.com/tv-home-internet-7/home-internet-service-ipv6-traffic-is-all-filtered-even-when-using-a-netgear-lte-router-no-port-forwarding-plz-fix-34310).

On top of that, the carrier assigned IPv6 address is a /64 prefix in which Prefix Delegation, Router Advertisement or other means must be used in order connect LAN clients to the Internet (See: https://datatracker.ietf.org/doc/html/rfc7278). This is an annoyance to deal with and without a clear benefit or reward for going through the hassle of configuring it all. The second reason a bridge or IPPT setup would be not worth it is because the default QMI (and MBIM) modes of our modem are 'raw-IP' protocols, not Ethernet. Thus, traditional bridging at layer 2 does not work because our 'wwan0' device created by ModemManager is not a true Ethernet device and cannot be used as such; it does not even have a MAC address assigned by default. From a layer 3 perspective things do not get much easier even with tools like 'relayd' since that also only considers Ethernet or WiFi devices as suitable members for its bridging capabilities. If one wanted to truly create a pseudo-bridge/half-bridge/IPPPT interface to be used as WAN on another router, then you would need to setup an additional DHCP server, configure static routes, and utilize proxy ARP to accomplish the task (See: https://forums.whirlpool.net.au/thread/2530290?p=18#r360).

For me the "juice is not worth the squeeze" when it comes to configuring a bridge or IPPT as WAN to my main router, this may be different if your carrier handles IP addressing differently or you are running IPv6 in your LAN. I understasnd one size does not fit all here. However, if we look into what typical IPPT and bridge setups offer outside of a publicly addressable IP, it would be the bypass of firewall and associated routing on a device when using it as WAN on another router. For this, we can simply setup a DMZ on the RPi firewall which forwards all traffic from the modem interface to our statically assigned WAN IP in OPNSense. OpenWRT doesn't have a specific "DMZ" feature but under "Port Forwards" we have the ability to accomplish the same thing:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-10_12h09_52.png" />

In creating our rule, we will allow any protocol with a source zone of 'WWAN' (or whatever you named your modem interface), destination zone of 'lan', and an internal ip address of '192.168.21.2' (the IP address we will have statically assigned to the WAN of our main router). Be sure to 'Save & Apply' the changes:
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-10_12h11_37.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-10_12h11_58.png" />

Once that is done we will disable all DHCP server features on the LAN interface (beware that once you do this, if you connect the RPi to a PC to debug it later on, you will need to statically set the IP address for the NIC at OS level to something in the same subnet ex. 192.168.21.5 in order to access the RPi since it won't be automatically assigned an address anymore on connection):
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-10_12h06_54.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-02-10_12h07_19.png" />

At this point OpenWRT can be restarted and connect to the WAN of your main router which has been configured with the static IP of 192.168.21.2.

### Helper Scripts
For this project we will need some scripts to achieve the goals we made at the outset I cover each in detail below. Such scripts may be added/removed/consolidated at a later date depending on subsequent testing of the overall build and its performance. All such scripts are available under 'scripts' folder of this repository and live under '/scripts' on the OpenWRT installation. Some scripts are written with the intenion they should be running at all times in 'daemon' mode (aka 'service' if you come from Windows background), others are created to be run only interactively at the command line.

For daemonized scripts, we control them using the 'pservice' package. This is a very simple OpenWRT package which is a wrapper for shell scripts which should run as daemons. The reason to use this package to manage such scripts is that it saves us from having to create and maintain individual 'init.d' service defintions for each script. One downside is that 'pservice' does not handle child processes (descendants) which are launched from inside our script functions. Thus, our scripts must track any subshell processes created so that we can intercept signals on termination by 'pservice' (mostly 'SIGTERM') and end them prior to the main script ending so as not to leave orphan processes when stopping/starting/restarting 'pservice'. Final point to note is that 'pservice' start/stop controls all scripts together and not individually. If one wishes to control each script daemon individually then one would be encouraged to write proper service files for each one to be called by procd directly on boot.

#### fancontrol.sh
This script controls our case fans. On first run this script will add itself to 'pservice' config if not present already. Also, on first run it sets a hotplug rule for the USB hub so that when disconnected/reconnected it will keep the fans powered off unless otherwise controlled by the script. Further, it checks that the selected modem AT interface is unbound from ModemManager so we can use it. If this isn't the case, it creates the necessary 'udev' rule to unbind the interface and prompts the user to reboot for the change to take effect. The script runs as a daemon under 'pservice' and checks the modem SoC temperature once per minute. If the temperature is over the defined limit threshold (55c by default), it will power on the fans. Once the modem has cooled below the limit, the fans are deactivated. Fan activation/deactivation by this script is logged to the system log; the history can be viewed with 'logread -e FAN_CONTROL'. Before running this script the following variables should be entered appropriately:

**$HUB, $PRODID** - Obtain w/ 'lsusb' and 'lsusb -v' ('idVendor:idProduct'; 'idVendor/idProduct/bcdDevice'). For $PRODID, ignore leading zeros in idVendor/idProduct and separating decimal in bcdDevice. Ex. 'idVendor 0x05e3, idProduct 0x0608, bcdDevice 60.52' = "5e3/608/6052".

**$PORTS** - Populate with hub port numbers of connected fans using appropriate uhubctl syntax. Ex. '2-3' (ports two through three), '1,4 (ports one and four), etc.

**$ATDEVICE, $MMVID, $MMPID, $MMUBIND** - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules'. '...ttyUSB2...AT primary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="02"...'. Ex. ATDEVICE="/dev/ttyUSB2", MMVID="2c7c", MMPID="0800", MMUBIND="02".

**$LIMIT, $INTERVAL** - Temperature threshold in degrees celsius when fans should be activated and time in seconds between polling modem temperature.

#### modemwatcher.sh
This script is necessary because ModemManager does not automatically cycle the modem interface on state changes that can occur during normal 'modem <-> tower' communications. Other ModemManager OS platforms (especially Debian based) use NetworkManager to handle this scenario but OpenWRT has no direct feature parity here. This is a known 'issue' when using ModemManager on OpenWRT and not a defect of ModemManager itself (see: https://lists.freedesktop.org/archives/modemmanager-devel/2021-July/008739.html). Other solutions I found relied on 'watchdog' scripts scheduled at a regular interval under cron to wait and re-query the modem before taking action which resulted in some seconds or minutes of actual Internet connectivity to downstream clients which is really undesirable. Thus, this script was created to watch the modem in realtime and take immediate action as required.

Functionality-wise, this script watches the modem to see if it leaves the 'connected' state which would result in loss of Internet connectivity. On first run, the script will add itself to 'pservice' config if not present already. From then on it runs as a daemon under 'pservice' and watches the system log in real time to check for state changes. If the modem does leave the 'connected' state, it checks internet connectivity by pinging google.com and cloudflare.com (two sites with incredibly reliable uptime). If Internet connectivity is not found, the script restarts the modem using mmcli (ModemManager command line interface) and re-checks connectivity. The following inputs should be entered appropriately prior to first run:

**$PINGDST, $LIFACE** - Domains to ping, logical (uci) name of the modem interface.

#### quickycom.sh
This is an interactive wrapper for the 'socat' utility which allows us to communicate easily with the modem's AT interface for sending commands and receiving return output (for scripts which interface with the AT port, we use 'socat' directly). On first run this script checks that the selected modem AT interface is unbound from ModemManager so we can use it. If this isn't the case, it creates the necessary 'udev' rule to unbind the interface and prompts the user to reboot for the change to take effect. Also, the script aliases itself as 'qcom' by creating a symlink in bin $PATH ('/usr/sbin/qcom') so that one can simply call it as 'qcom' from under any directory going forward. The following inputs should be entered appropriately prior to first run:

**$CMD, $TIMEOUT** - AT command, timeout period before termindation (in seconds)

**$ATDEVICE, $MMVID, $MMPID, $MMUBIND** - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules'. '...ttyUSB2...AT primary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="02"...' Ex. $ATDEVICE="/dev/ttyUSB2", MMVID="2c7c", MMPID="0800", MMUBIND="02".

### Switch Modem to Generic Image
In initial testing I found that the RM502Q-AE had Quectel's auto-image-switching feature activated by default. This 'feature' switches its firmware image (MBN) based on the carrier SIM which is inserted. Thus, when I inserted my carrier SIM it promptly switched to using the commercial image for my carrier. While this first party image allowed me to obtain IP assignment which was very geo-local (lowest latency), I noticed a significant loss of ICMP and UDP packets. Thus, ping and connectivity to UDP (such as external DNS, WireGuard, etc.) was completely broken at worst or unreliable at best.

I found that if I disabled the auto-image-switching and selected the 'Generic' 3GPP image from Quectel instead of my carier image, the ICMP/UDP packet loss issues disappeared. The only downside is that the IP that the carrier then routed me out of on the generic firmware was less geo-local (higher latency). I have opened a support thread with Quectel on this issue but have not received any resolution at this time so in the interim I am staying on the generic image. AT commands for disabling auto-image-switching and switching manually to the generic image are below (utilizing our qcom/quickycom.sh wrapper script):

```bash
qcom AT+CFUN=0
qcom AT+QMBNCFG=\"AutoSel\",0
qcom AT+QMBNCFG=\"Deactivate\"
qcom AT+QMBNCFG=\"select\",\"ROW_Generic_3GPP_PTCRB_GCF\"
qcom AT+CFUN=1,1
```

### Disable Modem NR SA
The only NR SA support in my area is N71 which does not have a lot of bandwidth allocated so for now I have disabled NR SA mode to leverage the significat throughput gains offered by NSA. The command to disable NR SA is below (leveraging our qcom wrapper):

```bash
qcom AT+CFUN=0
qcom AT+QNWPREFCFG=\"nr5g_disable_mode\",1
qcom AT+CFUN=1,1
```

# Results
My local tower offers only n71 SA which is not allocated much bandwidth at present so I am operating in NSA mode with a PCC of B2 or B4/B66 aggregated with n41. The initial results are a solid improvement over my previous average speeds on LTE only and ping is much improved. The device has so far only been tested indoors so I am excited to get it outside and up high to see what additional speed improvements I may achieve under those conditions.

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-03-09_17h31_49.png" />

<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-03-09_17h29_09.png" />

# ToDo List
* Look at adding 'sms-tool' (and 'luci-app-sms-tool') for SMS functionality
* Cover band/cell locking; maybe add helper/watcher scripts for this


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
I quickly learned that vanilla OpenWRT required some very specific software packages and configuration in order to get it working with the EM7455 I purchased and the result was that as cheap, nicely modular, and configurable this solution was, it was not ready for primetime. About this time I came across the legendary Australian broadband forum, Whirlpool, and the prolific ROOter project thread headed up by user "Dairyman". This was the most excited I had been since starting my question as I finally found a group of folks doing exactly what I wanted to do: using off-the-shelf raw-IP modems with OpenWRT as host OS. This thread gave birth to what eventually became "ROOter GoldenOrb" firmware; a heavily customized version of OpenWRT which had support for many commodity raw-IP modems. Many of the problems raw-IP modems presented in OpenWRT were scripted around by Dairyman and his excellent team of colloaborators and delivered as a true FOSS labor of love via https://www.ofmodemsandmen.com/.

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
