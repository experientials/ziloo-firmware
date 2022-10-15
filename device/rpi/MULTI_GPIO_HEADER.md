Since the Raspberry Pi can use GPIO pins for multiple functions, mode switching is also made possible on
the Ziloo side to allow additional signals. This switching is implemented as a map from debug connector
to RPi connector.


| Left side                  | Function  |Pin |Pin | Function  | Right side           |
|----------------------------|-----------|----|----|-----------|----------------------|
|  When VSOM fully connected | 3V3_ON    | 1  | 2  | VCC_FULL  | When VSOM fully connected  |
|       I2C3 SDA / STEM_SDA  | SDA       | 3  | 4  | VCC_FULL  | When VSOM fully connected |
|       I2C3 SCL / STEM_SCL  | SCL       | 5  | 6  | GND       |                      |
|              STEM_MSG / U3 | MSG       | 7  | 8  | TxD       | UART2_U01 TxD            |
|                            | GND       | 9  | 10 | RxD       | UART2_U01 RxD            |
|                            |           | 11 | 12 | SWD       | SWDCLK for T-USB     |
|     SDIO DAT3 / GPIO2_IO18 | SDIO      | 13 | 14 | SWD       | SWDIO for T-USB      |
|      SDIO CLK / GPIO2_IO13 | SDIO      | 15 | 16 | SDIO      | SDIO CMD / GPIO2_IO14  |
|    When any VSOM connected | 3V3       | 17 | 18 | SDIO      | SDIO DAT0 / GPIO2_IO15 |
| ECSPI2_MOSI / GPIO5_IO11   | MOSI      | 19 | 20 | GND       |                        |
| ECSPI2_MISO / GPIO5_IO12   | MISO      | 21 | 22 | SDIO      | SDIO DAT1 / GPIO2_IO16 |
| ECSPI2_SCLK/U4/ GPIO5_IO10   | SCLK      | 23 | 24 | SPI CE0   | ECSPI2_SS0/U4/GPIO5_IO13  |
|                            | GND       | 25 | 26 | SCL       | night scl |
|                    SYS I2C | SYS SDA   | 27 | 28 | SCL       | SYS I2C              |
|       STEM MSG / RPi U3 RX | MSG       | 29 | 30 | (GND)     |                      |
|                  NIGHT_SDA | SDA       | 31 | 32 | TxD       | UART4_U01 TX             |
|                   UART4_U01 RX | RxD       | 33 | 34 | JTAG      | SoM JTAG CLK (RPi GND) |
|    Battery measuring point | BAT_LDO   | 35 | 36 | JTAG      | SoM JTAG DIO          |
|     SDIO DAT2 / GPIO2_IO17 | SDIO      | 37 | 38 | CAN2      | CAN2 RX / GPIO4_IO27  |
|               (GND on RPi) |           | 39 | 40 | CAN2      | CAN2 TX / GPIO4_IO26  |




## Serial Devices 

Each UART has an associated serial device. A device is a "file" by which the operating system makes the UART and its associated serial port avalilable to software. There are four serial devices:

| Linux device  | Description      |
|---------------|------------------|
| /dev/ttyS0    | UART1 (Mini UART) |
| /dev/ttyAMA0  | UART0 (First PL011) |
| /dev/serial0  | UART assigned as primary |
| /dev/serial1  | UART assigned as secondary |

Bob UART2 connects to RPi UART 0/1 on GPIO14/15 as /dev/ttyAMA0
Bob STEM MSG connects to RPi UART 3 on GPIO4/5  (Bob UART1) as /dev/ttyAMA1
Bob UART4 connects to RPi UART 5 on GPIO12/13 as /dev/ttyAMA2


U01 is RPi UART0/1
U3 for STEM MSG

Bob UART3
dtoverlay=uart2
GPIO0 as TX, GPIO1 as RX 

dtoverlay=uart3
GPIO4 to as TX and GPIO5 as RX (or pin7 and pin29 respectively)