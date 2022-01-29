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
  * Stainless Steel
* **80mm PC Fan (x2)**
  * USB powered (5v)
* **80mm PC Fan Filter Grills (x2)**
  * Aluminum frame
  * Fine Stainless Steel mesh
* **USB 2.0 'Y' cable**
  * 1x Male USB-A Data+Power
  * 2x Female USB-A (1x Power only, 1x Data+Power)
* **USB Network Adapter**
  * Chipset should be supported by OpenWRT
  * Will only be used temporarily to download modem packages
* **USB 2.0, 4-port Hub***
  * D-Link DUB-H4 (HW. Rev. "D")
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
  * Accepts fully terminated Ethernet (RJ45)
  * 8.5mm NPT 

## Important Component Selection Information
### Quectel RM502Q-AE
The star of our project. Provides all the niceties that a modem with the Qualcomm SDX55 chipset can provide including NR SA/NSA/CA with M.2 Key B connector and choice of USB 3.0 or PCIe interfaces and both QMI (default) or MBIM raw-IP protocol support. Supports all available carrier low and mid bands for LTE and NR. No mmWave here but, since I don't live in a downtown/metro area, I won't be seeing any mmWave here any time soon (or ever, really). For power requirements she runs on 5v with a draw of up to 3a at peak load. Operating temperature range is from -30c to +70c.

### 5G M.2 to USB 3.0 Evaluation Board (EVB)
There are a ton of different M.2 to USB 3.0 adapters that exist but most do not have Key B M.2 slots and are designed for SSDs and not modem interfaces (USB). Many of the ones that are Key B have very basic power circuitry, many delivering even below the 900ma USB 3.0 spec current. Obviously this is a huge problem for a modem that can draw up to 3a at peak. For this reason a USB adapter (a.k.a. "USB Sled") that offers supplemntal DC power input is a necessity. There are a few out there with one of the best in the industry sold by The Wireless Haven. However, when procuring the RM502Q-AE I came across this EVB which featured dual nano SIM slots along with a USB-C data connector in addition to accepting 5v DC supplement voltage. The supplement voltage input is also controlled by a toggle switch which can be handy. So, I picked this one up for those compelling reasons.

### Raspberry Pi 4B, 4GB
I selected the RPi 4B for it's USB 3.0 ports and 1Gbps NIC. The 4GB of RAM is completely overkill for our project but due to supply chain issues it was the only SKU I could get my hands on at the moment. If you can find the 2GB for less, then that would be more than adequate as well. Power is also 5v via USB-C connector and draw is up to 1.8a when we do not factor in connected USB peripheral draw. Per specification the USB 2.0 ports deliver a maximum of 500ma per port and the USB 3.0 ports deliver a maximum of 900ma per port. It is also worth noting that the RPi USB ports are ganged together for power. Because of these limitations, we will need a a USB hub which supports Per Port Power Switching (PPPS) and also a way to supplement additional amperage to support our fans (I will touch on this more below).

### D-Link DUB-H4 (HW. Rev. "D")
Since the RPi's USB ports are ganged for power, turning them on/off programatically is an "all or nothing" affair which doesn't work for us since we obviously still need the USB 3.0 interface available at all times for the modem. Thus we need to connect the fans to a separate hub which supports Per Port Power Switching (PPPS) that will be used to turn them on/off. There are PPPS hubs made specifically for the RPi like the Uugear MEGA4 but those aren't stocked in the US so with overseas shipping can be a bit pricey compared to other options. Because of this, I searched out and found this specific model D-Link on ye olde eBay which was a cheaper option. There are not many USB hubs which ship with the hardware components required for PPPS so it's important we select one which is confirmed to have it. The hub connects via MiniUSB to USB-A and draws only about 100ma before any peripherals are connected. It comes with an AC adapter (5v 2.5a) which we won't need for our use case.

### 80mm USB PC Fans (2x)
To keep things cool I added 2, 80mm USB (5v) PC fans to the vents that were installed in the enclosure (one for cold air ingress, one for hot air exhaust). These will be programatically controlled through the USB hub and each draw 400ma max.

### Gigabit PoE Splitter
Yes, 5G will some day possibly provide over 1Gbps speeds in my area but at this point it is about 200Mbps which is far more than enough for my needs. That and the fact that routing traffic of that speed through the RPi would require a USB 2.5Gbps+ NIC and special config (over-clock, jumbo frames, etc.), made it easy for me to settle on 1Gbps for the interface. The RPi already features a native 1Gbps port and there are plenty of Gigabit 802.3 standards compliant PoE injectors and splitters on the market already. This particular unit was chosen since it will output 30w albeit at the 12v setting only (12v@2.5a). Which finally brings us to the need for a buck converter...

### Buck Converter (DC voltage step-down regulator)
This little guy takes 9-36v DC input through bare wire or a barrel connector (we are supplying it with 12v@2.5a from the PoE splitter) and outputs 5v through USB and/or bare wire connectors at up to 6a. This is perfect for us and fits within the power budget which the other components will draw (Modem@3a + RPi@1.8a + Hub@0.1a + Fans@0.8a = 5.7a max). The connectors are also great because we can use the bare wire connectors to split out power to the modem EVB and RPi while connecting the power-only end of our USB 2.0 Y-cable to the USB connecor which will provide the supplemental power we need for our hub-connected fans.

### PCB Antennas
Since I have a cell tower less than two miles away from me with generally good line-of-sight access, I opted to go for some 12dBi omnidirectional PCB antennas to mount inside the outdoor enclosure with the rest of the components. If you are further from a tower, purchasing some IPEX4/MHF4 to N-type or SMA pigtails which econnect to exteneral directional antennas may be a better choice.

## Hardware Build
### Vent, Fan, and Wire Gland Install
Since this will be going outside in the Midwestern US it is going to get hot and humid during some seasons so, in order to control heat and humidity, we will be installing two vents on the front door of the enclosure. The bottom will be a cold air intake and the top will be a hot air exhaust (since hot air rises). I chose the IPV-1116 vents because they are completed covered on 3 out of 4 sides and have a grid with small holes for air to pass through. The hole size required for the vents is kind of odd at 3.46". Luckily this worked out to exactly 88mm and by searching for that I was able to source one online.

The fans installed easily since they came with screws and the vents had the necessary screw holes already. When installing the fans it was important to check they were installed correctly so that the bottom fan drew air in and the top fan blew air out. Luckily the fans had clear labels on the edges which indicated the direction of airflow. Even though the vents have a pretty small grid for air ingress/egress, sometimes we get foggy/misty weather in the Summer and Fall so I wanted to hedge my bets against any droplets being pulled in by the fans by installing metal mesh PC fan filters on the inside of the vents between them and the fan. The wire gland install is not pictured here but it's just a simple 1/2" spade bit drilled into the bottom with some sanding so the threads slide in easy; then just tighten the locknut on from the inside.

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
Because we are working with different voltages and have invested a good chunk of change into the components we are connecting, it is always wise to check everything before making the final connections and plugging the PoE injector into mains. First up, I plugged the PoE injector into the wall outlet and connected it via Cat6 cable to the PoE splitter, ensuring the PoE splitter was set to 12v. Nothing was connected to the buck converter at this point. Once I verified the splitter was ouputting 12v (not pictured) I cannoted it to the buck converter and verified it was providing 5v output. The multimeter reading of a steady 5.20v confirmed we were well within USB spec (official range is 5.25 down to 4.45 for most USB devices powered from a 5v power supply rail).

I then tested the female DC connectors both coming of the Lever Nuts and verified they both read 5.20v as well. From there I connecxted the double sided mle DC connector for the EVB and the DC to USB-C connector for the RPi. The EVB connector tested at 5.20v as expected. Now, since it is generally quite hard to get stndard sized multimeter probes wedged into a USB-C connector, to test that one I relied on a fancy pants USB voltage and load tester which features a USB-C input. This showed a reading of roughly 5.15v which was in line with my probe readings (some juice is used by the device itself for the display thus the slight difference in reading). In the photo matrix under this section I have included a rough electrical wiring diagram showing the voltages and how each component is connected to its power source. The only piece not pictured in the illustration is the USB Y-cable power connector which is used to provide supplement power to the USB hub and, in turn, the fans. You can see the y-cable plugged into the converter in the last picture (when the mounting plate was reinstalled into the enclosure).

#### USB and Ethernet Connections
Once power connections were in place (but disconnected from the injector), I connected the USB-C to USB-A cable between the modem EVB and the RPi USB 3.0 port routing the cable nicely in an 'S' shape between/under RPi and EVB PCBs. The USB Y-cable connected to the buck converter was then routed out from under the EVB so that the data+power end fit nicely in the edge gap between the mounting plate and the enclosure wall. A short miniUSB to USB-A cable from the USB hub was plugged into the female side of the y-cable and the data+power male end was connected to the RPi USB 2.0 port. The USB hub was positioned in the bottom left corner of the enclosure positioning it nicely within reach of the USB connectors from the fans. A small piece of mounting tape was used to adhere the hub to the inside wall of the enclosure and keep it staionary before plugging the fans into it. Finally a 1' Cat6 cable was connected from the RJ45 Data port of the PoE splitter to the Gigabit NIC port on the RPi. In the final picture of the matrix below you can see the wire gland placement with injector Cat6 Data+Power PoE cable passing through it and connecting to the PoE splitter.

#### PCB Antennas
The 4x PCB antennas were mounted equal distances apart on either side of the case towards the top (metal traces facing upward), furthest away from the highest voltage source. The 20cm cables were a bit short; in hindsight I probably should have ordered them with longer ones for cleaner routing in the gap between the mounting plate and top of the case. Oh well, this will work. The back of the antennas featured a 3M white label self-adhesive. I looked it up on the 3M site and they claim it should hold reasonably in both cold and hot environments so we will not bother with our own mounting tape. The MHF4 connecters were then connected to the modem *very* gingerly using the end of a plastic spudger. The trick is to line them up exactly over the modem connector and apply centered, even pressue until the snap on. Do *NOT* use a metal tool (such as a screwdriver) for this. I have seen way too many people slice through cables and/or shear connectors off the modem when the two metal surfaces invariabley slip away from each other under pressure.



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
I decided to go with the latest stable OpenWRT (21.02.1) and ModemManager (1.16.6) for this build. I have been following the ModemManager port to OpenWRT for awhile and from the reports I read it seemed this combo was now generally quite reliable. As much as I and many others enjoy and benefit from having used ROOter in previous builds I do feel it can be a bit slow and bloated at times with odd errors from the litany of interconnected scripts which sometimes only a reboot will solve. Since ROOter maintains such a wide modem/router compatibility and continues to receive many feature enhancements from its large and active community, it is not immune to the increasing overhead and complexity that go hand-in-hand with this.

ROOter is certainly the "swiss army knife" of cellular WAN builds but for this build I really wanted to stick with something purpose-built and as close to stock OpenWRT as possible. Especially because I'm not looking for something to perform advanced routing, firewalling, VPN brokering, or DNS filtering capabilities as I already have pfSense/OPNSense with WireGuard and NextDNS running on much more capable hardware to handle these duties. I much prefer a modular approach to network design with a general outlook that can be summarized by the belief that a "Jack of all trades is master of none." So, in this case, we will let our 5G modem host be a modem host and not bog it down with much else.

### OpenWRT Pre-installation Prep
The starting point for this build was of course RTFM (reading the 'fine' manual). In this case OpenWRT already has a nice wiki page for the family of RPi devices: https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi . Here I learned that it is recommended to first load Raspberry Pi OS to perform selection of WiFi country code (in case for some reason we wish to use the WiFi for something later on), and flash the latest eeprom update from the inbuilt 'rpi-eeprom-update' utility for best compatibility. From my Windows 10 PC I downloaded the latest RPi OS Lite image (https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip) and flashed it to microSD using Balena Etcher. Once that was done I inserted the card into the RPi and connected the power to my PoE injector to power everything up. I connected the Ethernet data connection from the injector to my existing LAN so that I could hopefully just SSH into it after it booted.

In OPNSense I found the DHCP lease IP of the booted RPi but quickly came to know that the RPi folks do not have SSH daemon enabled by default so I had to power the RPi off, remove the SD card, mount it on my Ubuntu laptop, mount the '/boot' filesystem from the SD card, and 'touch ssh' there (creating an empty file called 'ssh'). Once this was done I was able to re-insert the SD card into the RPi and it allowed me to SSH into it from there. I then ran 'raspi-config' and chose the option to update 'raspi-config' to ensure I had the latest version. Once 'raspi-config' was updated I set the WiFi country code as recommended by the OpenWRT wiki and set the 'raspi-config' 'Advanced' settings from 'default' relase to 'latest'. This allowed me to get the latest eeprom update via the following commands:

*sudo rpi-eeprom-update*
*sudo rpi-eeprom-update -a'
*sudo reboot*

After the reboot I ran *sudo rpi-eeprom-update* once more to make sure it updated to the latest stable version (it did). I was ready then to flash OpenWRT.

### OpenWRT Install and Initial Configuration
After powering off the RPi ('sudo shutdown -now'), I removed the microSD card and placed it in my Windows PC again to flash the latest stable image downloaded here: https://downloads.openwrt.org/releases/21.02.1/targets/bcm27xx/bcm2711/openwrt-21.02.1-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz . Using 7-zip I extracted the .img file and flash it to SD using the same Balena Etcher program as before. We chose the ext4 image over squashfs since space is not a concern (using a 32GB SD card in this case). The ext4 image may wear down the SD storage quicker but considering OpenWRT active logging is all done in RAM and SD cards are cheap to me working with ext4 is worth this trade-off. Especially if we need to expand the root filesystem later for more software package storage etc. Extending the overlay filesystem via extroot under squashfs is a much bigger pain in the butt, IMHO. If ext4 is good enough for the many diverse deployments of RPi OS, then it is good enough for OpenWRT in my book :)

Once the SD card was replaced I disconnected it from my existing LAN and connected it directly to my test bench PC (since the default OpenWRT is 192.168.1.1 it would conflict with any existing LAN using that subnet). Once booted up, we login to the web interface to set the root password:

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
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h12_48.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h14_49.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h14_49.png" />

We can then go back into the web interface to configure the newly added device as our temporary WAN interface (you should have your USB adapted to your existing LAN now so it will have access to the Internet once connected):
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_19.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_27.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h16_59.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h17_34.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h18_00.png" />
<img src="https://github.com/hazarjast/5g_rpi4_build/blob/main/assets/2022-01-08_14h18_50.png" />

### ownload All Required Packages
Now that the RPi has Internet access via our temporary WAN, go back to the Putty SSH prompt and issue the follow commands to update the software package lists and install the packatges we need:

`opkg update`


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
