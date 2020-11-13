//
// Copyright (c) 2017 Intel Corporation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

// create module
module nn(
        input  wire       clk,          // 50MHz FPGA input clock

        input  wire [1:0] push_button,  // KEY[1:0]
        input  wire [3:0] switch,       // SW[3:0]

        output wire [7:0] leds,         // LED[7:0]

        // HPS memory controller ports
        output wire [14:0] hps_memory_mem_a,
        output wire [2:0]  hps_memory_mem_ba,
        output wire        hps_memory_mem_ck,
        output wire        hps_memory_mem_ck_n,
        output wire        hps_memory_mem_cke,
        output wire        hps_memory_mem_cs_n,
        output wire        hps_memory_mem_ras_n,
        output wire        hps_memory_mem_cas_n,
        output wire        hps_memory_mem_we_n,
        output wire        hps_memory_mem_reset_n,
        inout  wire [31:0] hps_memory_mem_dq,
        inout  wire [3:0]  hps_memory_mem_dqs,
        inout  wire [3:0]  hps_memory_mem_dqs_n,
        output wire        hps_memory_mem_odt,
        output wire [3:0]  hps_memory_mem_dm,
        input  wire        hps_memory_oct_rzqin,

        // HPS peripheral ports
        output wire        hps_io_hps_io_emac1_inst_TX_CLK,
        output wire        hps_io_hps_io_emac1_inst_TXD0,
        output wire        hps_io_hps_io_emac1_inst_TXD1,
        output wire        hps_io_hps_io_emac1_inst_TXD2,
        output wire        hps_io_hps_io_emac1_inst_TXD3,
        input  wire        hps_io_hps_io_emac1_inst_RXD0,
        inout  wire        hps_io_hps_io_emac1_inst_MDIO,
        output wire        hps_io_hps_io_emac1_inst_MDC,
        input  wire        hps_io_hps_io_emac1_inst_RX_CTL,
        output wire        hps_io_hps_io_emac1_inst_TX_CTL,
        input  wire        hps_io_hps_io_emac1_inst_RX_CLK,
        input  wire        hps_io_hps_io_emac1_inst_RXD1,
        input  wire        hps_io_hps_io_emac1_inst_RXD2,
        input  wire        hps_io_hps_io_emac1_inst_RXD3,
        inout  wire        hps_io_hps_io_sdio_inst_CMD,
        inout  wire        hps_io_hps_io_sdio_inst_D0,
        inout  wire        hps_io_hps_io_sdio_inst_D1,
        output wire        hps_io_hps_io_sdio_inst_CLK,
        inout  wire        hps_io_hps_io_sdio_inst_D2,
        inout  wire        hps_io_hps_io_sdio_inst_D3,
        inout  wire        hps_io_hps_io_usb1_inst_D0,
        inout  wire        hps_io_hps_io_usb1_inst_D1,
        inout  wire        hps_io_hps_io_usb1_inst_D2,
        inout  wire        hps_io_hps_io_usb1_inst_D3,
        inout  wire        hps_io_hps_io_usb1_inst_D4,
        inout  wire        hps_io_hps_io_usb1_inst_D5,
        inout  wire        hps_io_hps_io_usb1_inst_D6,
        inout  wire        hps_io_hps_io_usb1_inst_D7,
        input  wire        hps_io_hps_io_usb1_inst_CLK,
        output wire        hps_io_hps_io_usb1_inst_STP,
        input  wire        hps_io_hps_io_usb1_inst_DIR,
        input  wire        hps_io_hps_io_usb1_inst_NXT,
        input  wire        hps_io_hps_io_uart0_inst_RX,
        output wire        hps_io_hps_io_uart0_inst_TX,
        output wire        hps_io_hps_io_spim1_inst_CLK,
        output wire        hps_io_hps_io_spim1_inst_MOSI,
        input  wire        hps_io_hps_io_spim1_inst_MISO,
        output wire        hps_io_hps_io_spim1_inst_SS0,
        inout  wire        hps_io_hps_io_i2c0_inst_SDA,
        inout  wire        hps_io_hps_io_i2c0_inst_SCL,
        inout  wire        hps_io_hps_io_i2c1_inst_SDA,
        inout  wire        hps_io_hps_io_i2c1_inst_SCL,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO09,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO35,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO40,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO53,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO54,
        inout  wire        hps_io_hps_io_gpio_inst_GPIO61
);

// Create a power on reset pulse for clean system reset on entry into user mode
// We create this with the altera_std_synchronizer core
wire sync_dout;
altera_std_synchronizer #(
        .depth (20)
) power_on_reset_std_sync_inst (
        .clk     (clk),
        .reset_n (1'b1),
        .din     (1'b1),
        .dout    (sync_dout)
);

// Create a qsys system reset signal that is the logical AND of the power on
// reset pulse and the KEY[0] push button
wire qsys_system_reset;
assign qsys_system_reset = sync_dout & push_button[0];

// Qsys system instantiation template from soc_system/soc_system_inst.v
soc_system u0 (
        .button_pio_export                     (push_button[1]),
        .clk_clk                               (clk),
        .hps_0_hps_io_hps_io_emac1_inst_TX_CLK (hps_io_hps_io_emac1_inst_TX_CLK),
        .hps_0_hps_io_hps_io_emac1_inst_TXD0   (hps_io_hps_io_emac1_inst_TXD0),
        .hps_0_hps_io_hps_io_emac1_inst_TXD1   (hps_io_hps_io_emac1_inst_TXD1),
        .hps_0_hps_io_hps_io_emac1_inst_TXD2   (hps_io_hps_io_emac1_inst_TXD2),
        .hps_0_hps_io_hps_io_emac1_inst_TXD3   (hps_io_hps_io_emac1_inst_TXD3),
        .hps_0_hps_io_hps_io_emac1_inst_RXD0   (hps_io_hps_io_emac1_inst_RXD0),
        .hps_0_hps_io_hps_io_emac1_inst_MDIO   (hps_io_hps_io_emac1_inst_MDIO),
        .hps_0_hps_io_hps_io_emac1_inst_MDC    (hps_io_hps_io_emac1_inst_MDC),
        .hps_0_hps_io_hps_io_emac1_inst_RX_CTL (hps_io_hps_io_emac1_inst_RX_CTL),
        .hps_0_hps_io_hps_io_emac1_inst_TX_CTL (hps_io_hps_io_emac1_inst_TX_CTL),
        .hps_0_hps_io_hps_io_emac1_inst_RX_CLK (hps_io_hps_io_emac1_inst_RX_CLK),
        .hps_0_hps_io_hps_io_emac1_inst_RXD1   (hps_io_hps_io_emac1_inst_RXD1),
        .hps_0_hps_io_hps_io_emac1_inst_RXD2   (hps_io_hps_io_emac1_inst_RXD2),
        .hps_0_hps_io_hps_io_emac1_inst_RXD3   (hps_io_hps_io_emac1_inst_RXD3),
        .hps_0_hps_io_hps_io_sdio_inst_CMD     (hps_io_hps_io_sdio_inst_CMD),
        .hps_0_hps_io_hps_io_sdio_inst_D0      (hps_io_hps_io_sdio_inst_D0),
        .hps_0_hps_io_hps_io_sdio_inst_D1      (hps_io_hps_io_sdio_inst_D1),
        .hps_0_hps_io_hps_io_sdio_inst_CLK     (hps_io_hps_io_sdio_inst_CLK),
        .hps_0_hps_io_hps_io_sdio_inst_D2      (hps_io_hps_io_sdio_inst_D2),
        .hps_0_hps_io_hps_io_sdio_inst_D3      (hps_io_hps_io_sdio_inst_D3),
        .hps_0_hps_io_hps_io_usb1_inst_D0      (hps_io_hps_io_usb1_inst_D0),
        .hps_0_hps_io_hps_io_usb1_inst_D1      (hps_io_hps_io_usb1_inst_D1),
        .hps_0_hps_io_hps_io_usb1_inst_D2      (hps_io_hps_io_usb1_inst_D2),
        .hps_0_hps_io_hps_io_usb1_inst_D3      (hps_io_hps_io_usb1_inst_D3),
        .hps_0_hps_io_hps_io_usb1_inst_D4      (hps_io_hps_io_usb1_inst_D4),
        .hps_0_hps_io_hps_io_usb1_inst_D5      (hps_io_hps_io_usb1_inst_D5),
        .hps_0_hps_io_hps_io_usb1_inst_D6      (hps_io_hps_io_usb1_inst_D6),
        .hps_0_hps_io_hps_io_usb1_inst_D7      (hps_io_hps_io_usb1_inst_D7),
        .hps_0_hps_io_hps_io_usb1_inst_CLK     (hps_io_hps_io_usb1_inst_CLK),
        .hps_0_hps_io_hps_io_usb1_inst_STP     (hps_io_hps_io_usb1_inst_STP),
        .hps_0_hps_io_hps_io_usb1_inst_DIR     (hps_io_hps_io_usb1_inst_DIR),
        .hps_0_hps_io_hps_io_usb1_inst_NXT     (hps_io_hps_io_usb1_inst_NXT),
        .hps_0_hps_io_hps_io_spim1_inst_CLK    (hps_io_hps_io_spim1_inst_CLK),
        .hps_0_hps_io_hps_io_spim1_inst_MOSI   (hps_io_hps_io_spim1_inst_MOSI),
        .hps_0_hps_io_hps_io_spim1_inst_MISO   (hps_io_hps_io_spim1_inst_MISO),
        .hps_0_hps_io_hps_io_spim1_inst_SS0    (hps_io_hps_io_spim1_inst_SS0),
        .hps_0_hps_io_hps_io_uart0_inst_RX     (hps_io_hps_io_uart0_inst_RX),
        .hps_0_hps_io_hps_io_uart0_inst_TX     (hps_io_hps_io_uart0_inst_TX),
        .hps_0_hps_io_hps_io_i2c0_inst_SDA     (hps_io_hps_io_i2c0_inst_SDA),
        .hps_0_hps_io_hps_io_i2c0_inst_SCL     (hps_io_hps_io_i2c0_inst_SCL),
        .hps_0_hps_io_hps_io_i2c1_inst_SDA     (hps_io_hps_io_i2c1_inst_SDA),
        .hps_0_hps_io_hps_io_i2c1_inst_SCL     (hps_io_hps_io_i2c1_inst_SCL),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO09  (hps_io_hps_io_gpio_inst_GPIO09),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO35  (hps_io_hps_io_gpio_inst_GPIO35),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO40  (hps_io_hps_io_gpio_inst_GPIO40),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO53  (hps_io_hps_io_gpio_inst_GPIO53),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO54  (hps_io_hps_io_gpio_inst_GPIO54),
        .hps_0_hps_io_hps_io_gpio_inst_GPIO61  (hps_io_hps_io_gpio_inst_GPIO61),
        .led_pio_export                        (leds),
        .memory_mem_a                          (hps_memory_mem_a),
        .memory_mem_ba                         (hps_memory_mem_ba),
        .memory_mem_ck                         (hps_memory_mem_ck),
        .memory_mem_ck_n                       (hps_memory_mem_ck_n),
        .memory_mem_cke                        (hps_memory_mem_cke),
        .memory_mem_cs_n                       (hps_memory_mem_cs_n),
        .memory_mem_ras_n                      (hps_memory_mem_ras_n),
        .memory_mem_cas_n                      (hps_memory_mem_cas_n),
        .memory_mem_we_n                       (hps_memory_mem_we_n),
        .memory_mem_reset_n                    (hps_memory_mem_reset_n),
        .memory_mem_dq                         (hps_memory_mem_dq),
        .memory_mem_dqs                        (hps_memory_mem_dqs),
        .memory_mem_dqs_n                      (hps_memory_mem_dqs_n),
        .memory_mem_odt                        (hps_memory_mem_odt),
        .memory_mem_dm                         (hps_memory_mem_dm),
        .memory_oct_rzqin                      (hps_memory_oct_rzqin),
        .reset_reset_n                         (qsys_system_reset),
        .switch_pio_export                     (switch)
);

endmodule
