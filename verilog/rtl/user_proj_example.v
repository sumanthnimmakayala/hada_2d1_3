// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

hada_2d1_3 dut(

i0s,i1s,i2s,i3s,i4s,i5s,i6s,i7s,
i0,i1,i2,i3,i4,i5,i6,i7,
o0s,o1s,o2s,o3s,o4s,o5s,o6s,o7s,
o0,o1,o2,o3,o4,o5,o6,o7,

sel,clk,reset

);

endmodule

//8-point 2D-discrete hadamard transform

/*`include "mux2_33.v"
`include "dflipflop33.v"
`include "kgp.v"
`include "kgp_carry.v"
`include "recursive_stage1.v"
`include "mux8_33.v"
`include "recurse3.v"
`include "dflipflop3.v"*/

//////////////////////////////////////////////////////////////////////////////////////////////////

/*`include "hadamard_conv.v"
`include "adder32.v"
`include "recurse.v" */

//////////////////////////////////////////////////////////////////////////////////////////////////
       
/*`include "hadamard_dist.v"
`include "lut.v"
`include "adder3.v"
`include "adder32.v"
`include "recurse.v"
`include "recurshada_2d1_3(

i0s,i1s,i2s,i3s,i4s,i5s,i6s,i7s,
i0,i1,i2,i3,i4,i5,i6,i7,
o0s,o1s,o2s,o3s,o4s,o5s,o6s,o7s,
o0,o1,o2,o3,o4,o5,o6,o7,

sel,clk,reset

);e5.v"
`include "dflipflop5.v"
`include "mux2_4.v"*/

//////////////////////////////////////////////////////////////////////////////////////////////////
    
/*`include "hada_csa.v"
`include "adder32.v"
`include "hada4_csa.v"
`include "recurse.v"
`include "mux2_32.v"
`include "csa4.v"
`include "fulladd.v"
`include "recurse36.v"*/

//////////////////////////////////////////////////////////////////////////////////////////////////
      
/*`include "hadamard_pro.v"
`include "recurse.v"
`include "csa.v"
`include "mux2_32.v"
`include "fulladd.v"
`include "recurse36.v"*/

//////////////////////////////////////////////////////////////////////////////////////////////////

module hada_2d1_3(

i0s,i1s,i2s,i3s,i4s,i5s,i6s,i7s,
i0,i1,i2,i3,i4,i5,i6,i7,
o0s,o1s,o2s,o3s,o4s,o5s,o6s,o7s,
o0,o1,o2,o3,o4,o5,o6,o7,

sel,clk,reset

);

input i0s,i1s,i2s,i3s,i4s,i5s,i6s,i7s;
input [31:0] i0,i1,i2,i3,i4,i5,i6,i7;
output o0s,o1s,o2s,o3s,o4s,o5s,o6s,o7s;
output [31:0] o0,o1,o2,o3,o4,o5,o6,o7;

input sel,clk,reset;

//sel=0 for row process and sel=1 for column process

wire z0s,z1s,z2s,z3s,z4s,z5s,z6s,z7s;
wire [31:0] z0,z1,z2,z3,z4,z5,z6,z7;
wire x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s;
wire [31:0] x0,x1,x2,x3,x4,x5,x6,x7;
wire g0s,g1s,g2s,g3s,g4s,g5s,g6s,g7s;
wire [31:0] g0,g1,g2,g3,g4,g5,g6,g7;

mux2_33 m1({i0s,i0},{g0s,g0},sel,{x0s,x0});
mux2_33 m2({i1s,i1},{g1s,g1},sel,{x1s,x1});
mux2_33 m3({i2s,i2},{g2s,g2},sel,{x2s,x2});
mux2_33 m4({i3s,i3},{g3s,g3},sel,{x3s,x3});
mux2_33 m5({i4s,i4},{g4s,g4},sel,{x4s,x4});
mux2_33 m6({i5s,i5},{g5s,g5},sel,{x5s,x5});
mux2_33 m7({i6s,i6},{g6s,g6},sel,{x6s,x6});
mux2_33 m8({i7s,i7},{g7s,g7},sel,{x7s,x7});

///////////////////////////////////////////////////////////////////////////////
/*wire c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s;
wire [31:0] c0,c1,c2,c3,c4,c5,c6,c7;
hadamard_conv h1d(

x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,
x0,x1,x2,x3,x4,x5,x6,x7,
c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s,
c0,c1,c2,c3,c4,c5,c6,c7

);*/

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/*wire c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s;
wire [31:0] c0,c1,c2,c3,c4,c5,c6,c7;
hadamard_dist h1d(

x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,
x0,x1,x2,x3,x4,x5,x6,x7,
c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s,
c0,c1,c2,c3,c4,c5,c6,c7,
clk,reset

);*/

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
wire c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s;
wire [32:0] c0,c1,c2,c3,c4,c5,c6,c7;
hada_csa h1d(

x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,
x0,x1,x2,x3,x4,x5,x6,x7,
c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s,
c0,c1,c2,c3,c4,c5,c6,c7

);

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/*wire c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s;
wire [33:0] c0,c1,c2,c3,c4,c5,c6,c7;
hadamard_pro h1d(

x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,
x0,x1,x2,x3,x4,x5,x6,x7,
c0s,c1s,c2s,c3s,c4s,c5s,c6s,c7s,
c0,c1,c2,c3,c4,c5,c6,c7

);*/

///////////////////////////////////////////////////////////////////////////////

wire y0s,y1s,y2s,y3s,y4s,y5s,y6s,y7s;
wire [31:0] y0,y1,y2,y3,y4,y5,y6,y7;

assign {y0s,y0}={c0s,c0[31:0]};
assign {y1s,y1}={c1s,c1[31:0]};
assign {y2s,y2}={c2s,c2[31:0]};
assign {y3s,y3}={c3s,c3[31:0]};
assign {y4s,y4}={c4s,c4[31:0]};
assign {y5s,y5}={c5s,c5[31:0]};
assign {y6s,y6}={c6s,c6[31:0]};
assign {y7s,y7}={c7s,c7[31:0]};

//Transpose buffer

wire bu00s,bu01s,bu02s,bu03s,bu04s,bu05s,bu06s;
wire [31:0] bu00,bu01,bu02,bu03,bu04,bu05,bu06;

wire bu10s,bu11s,bu12s,bu13s,bu14s,bu15s,bu16s;
wire [31:0] bu10,bu11,bu12,bu13,bu14,bu15,bu16;

wire bu20s,bu21s,bu22s,bu23s,bu24s,bu25s,bu26s;
wire [31:0] bu20,bu21,bu22,bu23,bu24,bu25,bu26;

wire bu30s,bu31s,bu32s,bu33s,bu34s,bu35s,bu36s;
wire [31:0] bu30,bu31,bu32,bu33,bu34,bu35,bu36;

wire bu40s,bu41s,bu42s,bu43s,bu44s,bu45s,bu46s;
wire [31:0] bu40,bu41,bu42,bu43,bu44,bu45,bu46;

wire bu50s,bu51s,bu52s,bu53s,bu54s,bu55s,bu56s;
wire [31:0] bu50,bu51,bu52,bu53,bu54,bu55,bu56;

wire bu60s,bu61s,bu62s,bu63s,bu64s,bu65s,bu66s;
wire [31:0] bu60,bu61,bu62,bu63,bu64,bu65,bu66;

wire bu70s,bu71s,bu72s,bu73s,bu74s,bu75s,bu76s;
wire [31:0] bu70,bu71,bu72,bu73,bu74,bu75,bu76;

//first row

dflipflop33 bu0_0({bu00s,bu00},{y0s,y0},clk,reset);
dflipflop33 bu0_1({bu01s,bu01},{bu00s,bu00},clk,reset);
dflipflop33 bu0_2({bu02s,bu02},{bu01s,bu01},clk,reset);
dflipflop33 bu0_3({bu03s,bu03},{bu02s,bu02},clk,reset);
dflipflop33 bu0_4({bu04s,bu04},{bu03s,bu03},clk,reset);
dflipflop33 bu0_5({bu05s,bu05},{bu04s,bu04},clk,reset);
dflipflop33 bu0_6({bu06s,bu06},{bu05s,bu05},clk,reset);
dflipflop33 bu0_7({z0s,z0},{bu06s,bu06},clk,reset);

//second row

dflipflop33 bu1_0({bu10s,bu10},{y1s,y1},clk,reset);
dflipflop33 bu1_1({bu11s,bu11},{bu10s,bu10},clk,reset);
dflipflop33 bu1_2({bu12s,bu12},{bu11s,bu11},clk,reset);
dflipflop33 bu1_3({bu13s,bu13},{bu12s,bu12},clk,reset);
dflipflop33 bu1_4({bu14s,bu14},{bu13s,bu13},clk,reset);
dflipflop33 bu1_5({bu15s,bu15},{bu14s,bu14},clk,reset);
dflipflop33 bu1_6({bu16s,bu16},{bu15s,bu15},clk,reset);
dflipflop33 bu1_7({z1s,z1},{bu16s,bu16},clk,reset);

wire y11s;
wire [31:0] y11;

dflipflop33 d11({y11s,y11},{z1s,z1},clk,reset);

//third row

dflipflop33 bu2_0({bu20s,bu20},{y2s,y2},clk,reset);
dflipflop33 bu2_1({bu21s,bu21},{bu20s,bu20},clk,reset);
dflipflop33 bu2_2({bu22s,bu22},{bu21s,bu21},clk,reset);
dflipflop33 bu2_3({bu23s,bu23},{bu22s,bu22},clk,reset);
dflipflop33 bu2_4({bu24s,bu24},{bu23s,bu23},clk,reset);
dflipflop33 bu2_5({bu25s,bu25},{bu24s,bu24},clk,reset);
dflipflop33 bu2_6({bu26s,bu26},{bu25s,bu25},clk,reset);
dflipflop33 bu2_7({z2s,z2},{bu26s,bu26},clk,reset);

wire y21s,y22s;
wire [31:0] y21,y22;

dflipflop33 d21({y21s,y21},{z2s,z2},clk,reset);
dflipflop33 d22({y22s,y22},{y21s,y21},clk,reset);

//fourth row

dflipflop33 bu3_0({bu30s,bu30},{y3s,y3},clk,reset);
dflipflop33 bu3_1({bu31s,bu31},{bu30s,bu30},clk,reset);
dflipflop33 bu3_2({bu32s,bu32},{bu31s,bu31},clk,reset);
dflipflop33 bu3_3({bu33s,bu33},{bu32s,bu32},clk,reset);
dflipflop33 bu3_4({bu34s,bu34},{bu33s,bu33},clk,reset);
dflipflop33 bu3_5({bu35s,bu35},{bu34s,bu34},clk,reset);
dflipflop33 bu3_6({bu36s,bu36},{bu35s,bu35},clk,reset);
dflipflop33 bu3_7({z3s,z3},{bu36s,bu36},clk,reset);

wire y31s,y32s,y33s;
wire [31:0] y31,y32,y33;

dflipflop33 d31({y31s,y31},{z3s,z3},clk,reset);
dflipflop33 d32({y32s,y32},{y31s,y31},clk,reset);
dflipflop33 d33({y33s,y33},{y32s,y32},clk,reset);

//fifth row

dflipflop33 bu4_0({bu40s,bu40},{y4s,y4},clk,reset);
dflipflop33 bu4_1({bu41s,bu41},{bu40s,bu40},clk,reset);
dflipflop33 bu4_2({bu42s,bu42},{bu41s,bu41},clk,reset);
dflipflop33 bu4_3({bu43s,bu43},{bu42s,bu42},clk,reset);
dflipflop33 bu4_4({bu44s,bu44},{bu43s,bu43},clk,reset);
dflipflop33 bu4_5({bu45s,bu45},{bu44s,bu44},clk,reset);
dflipflop33 bu4_6({bu46s,bu46},{bu45s,bu45},clk,reset);
dflipflop33 bu4_7({z4s,z4},{bu46s,bu46},clk,reset);

wire y41s,y42s,y43s,y44s;
wire [31:0] y41,y42,y43,y44;

dflipflop33 d41({y41s,y41},{z4s,z4},clk,reset);
dflipflop33 d42({y42s,y42},{y41s,y41},clk,reset);
dflipflop33 d43({y43s,y43},{y42s,y42},clk,reset);
dflipflop33 d44({y44s,y44},{y43s,y43},clk,reset);

//sixth row

dflipflop33 bu5_0({bu50s,bu50},{y5s,y5},clk,reset);
dflipflop33 bu5_1({bu51s,bu51},{bu50s,bu50},clk,reset);
dflipflop33 bu5_2({bu52s,bu52},{bu51s,bu51},clk,reset);
dflipflop33 bu5_3({bu53s,bu53},{bu52s,bu52},clk,reset);
dflipflop33 bu5_4({bu54s,bu54},{bu53s,bu53},clk,reset);
dflipflop33 bu5_5({bu55s,bu55},{bu54s,bu54},clk,reset);
dflipflop33 bu5_6({bu56s,bu56},{bu55s,bu55},clk,reset);
dflipflop33 bu5_7({z5s,z5},{bu56s,bu56},clk,reset);

wire y51s,y52s,y53s,y54s,y55s;
wire [31:0] y51,y52,y53,y54,y55;

dflipflop33 d51({y51s,y51},{z5s,z5},clk,reset);
dflipflop33 d52({y52s,y52},{y51s,y51},clk,reset);
dflipflop33 d53({y53s,y53},{y52s,y52},clk,reset);
dflipflop33 d54({y54s,y54},{y53s,y53},clk,reset);
dflipflop33 d55({y55s,y55},{y54s,y54},clk,reset);

//seventh row

dflipflop33 bu6_0({bu60s,bu60},{y6s,y6},clk,reset);
dflipflop33 bu6_1({bu61s,bu61},{bu60s,bu60},clk,reset);
dflipflop33 bu6_2({bu62s,bu62},{bu61s,bu61},clk,reset);
dflipflop33 bu6_3({bu63s,bu63},{bu62s,bu62},clk,reset);
dflipflop33 bu6_4({bu64s,bu64},{bu63s,bu63},clk,reset);
dflipflop33 bu6_5({bu65s,bu65},{bu64s,bu64},clk,reset);
dflipflop33 bu6_6({bu66s,bu66},{bu65s,bu65},clk,reset);
dflipflop33 bu6_7({z6s,z6},{bu66s,bu66},clk,reset);

wire y61s,y62s,y63s,y64s,y65s,y66s;
wire [31:0] y61,y62,y63,y64,y65,y66;

dflipflop33 d61({y61s,y61},{z6s,z6},clk,reset);
dflipflop33 d62({y62s,y62},{y61s,y61},clk,reset);
dflipflop33 d63({y63s,y63},{y62s,y62},clk,reset);
dflipflop33 d64({y64s,y64},{y63s,y63},clk,reset);
dflipflop33 d65({y65s,y65},{y64s,y64},clk,reset);
dflipflop33 d66({y66s,y66},{y65s,y65},clk,reset);

//eighth row

dflipflop33 bu7_0({bu70s,bu70},{y7s,y7},clk,reset);
dflipflop33 bu7_1({bu71s,bu71},{bu70s,bu70},clk,reset);
dflipflop33 bu7_2({bu72s,bu72},{bu71s,bu71},clk,reset);
dflipflop33 bu7_3({bu73s,bu73},{bu72s,bu72},clk,reset);
dflipflop33 bu7_4({bu74s,bu74},{bu73s,bu73},clk,reset);
dflipflop33 bu7_5({bu75s,bu75},{bu74s,bu74},clk,reset);
dflipflop33 bu7_6({bu76s,bu76},{bu75s,bu75},clk,reset);
dflipflop33 bu7_7({z7s,z7},{bu76s,bu76},clk,reset);

wire y71s,y72s,y73s,y74s,y75s,y76s,y77s;
wire [31:0] y71,y72,y73,y74,y75,y76,y77;

dflipflop33 d71({y71s,y71},{z7s,z7},clk,reset);
dflipflop33 d72({y72s,y72},{y71s,y71},clk,reset);
dflipflop33 d73({y73s,y73},{y72s,y72},clk,reset);
dflipflop33 d74({y74s,y74},{y73s,y73},clk,reset);
dflipflop33 d75({y75s,y75},{y74s,y74},clk,reset);
dflipflop33 d76({y76s,y76},{y75s,y75},clk,reset);
dflipflop33 d77({y77s,y77},{y76s,y76},clk,reset);

//3-bit counter

wire [2:0] count,qcount;
wire countc;

recurse3 r3(count,countc,3'b001,qcount);
dflipflop3 df3(qcount,count,clk,reset);

//column of 8-to-1 multiplexers

mux8_33 m8_1({bu00s,bu00},{bu01s,bu01},{bu02s,bu02},{bu03s,bu03},{bu04s,bu04},{bu05s,bu05},{bu06s,bu06},{z0s,z0},qcount,{g0s,g0});
mux8_33 m8_2({bu11s,bu11},{bu12s,bu12},{bu13s,bu13},{bu14s,bu14},{bu15s,bu15},{bu16s,bu16},{z1s,z1},{y11s,y11},qcount,{g1s,g1});
mux8_33 m8_3({bu22s,bu22},{bu23s,bu23},{bu24s,bu24},{bu25s,bu25},{bu26s,bu26},{z2s,z2},{y21s,y11},{y22s,y22},qcount,{g2s,g2});
mux8_33 m8_4({bu33s,bu33},{bu34s,bu34},{bu35s,bu35},{bu36s,bu36},{z3s,z3},{y31s,y31},{y32s,y32},{y33s,y33},qcount,{g3s,g3});
mux8_33 m8_5({bu44s,bu44},{bu45s,bu45},{bu46s,bu46},{z4s,z4},{y41s,y41},{y42s,y42},{y43s,y43},{y44s,y44},qcount,{g4s,g4});
mux8_33 m8_6({bu55s,bu55},{bu56s,bu56},{z5s,z5},{y51s,y51},{y52s,y52},{y53s,y53},{y54s,y54},{y55s,y55},qcount,{g5s,g5});
mux8_33 m8_7({bu66s,bu66},{z6s,z6},{y61s,y61},{y62s,y62},{y63s,y63},{y64s,y64},{y65s,y65},{y66s,y66},qcount,{g6s,g6});
mux8_33 m8_8({z7s,z7},{y71s,y71},{y72s,y72},{y73s,y73},{y74s,y74},{y75s,y75},{y76s,y76},{y77s,y77},qcount,{g7s,g7});

//output

assign {o0s,o0}={g0s,g0};
assign {o1s,o1}={g1s,g1};
assign {o2s,o2}={g2s,g2};
assign {o3s,o3}={g3s,g3};
assign {o4s,o4}={g4s,g4};
assign {o5s,o5}={g5s,g5};
assign {o6s,o6}={g6s,g6};
assign {o7s,o7}={g7s,g7};

endmodule


//mux8to1

module mux8_33(i0,i1,i2,i3,i4,i5,i6,i7,sel,out);


input [32:0] i0,i1,i2,i3,i4,i5,i6,i7;
output [32:0] out;
input [2:0] sel;

reg [32:0] out;

always@(i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or sel)
	begin
		if(sel==3'b000)
			out=i7;
		else if (sel==3'b001)
			out=i6;
		else if (sel==3'b010)
			out=i5;
		else if (sel==3'b011)
			out=i4;
		else if (sel==3'b100)
			out=i3;
		else if (sel==3'b101)
			out=i2;
		else if (sel==3'b110)
			out=i1;
		else if (sel==3'b111)
			out=i0;
	end

endmodule

// D flip flop

module dflipflop3(q,d,clk,reset);
output [2:0] q;
input [2:0] d;
input clk,reset;
reg [2:0] q;
always@(posedge reset or negedge clk)
if(reset)
q<=3'b0;
else
q<=d;
endmodule

//5 bit recursive doubling technique

//`include "kgp.v"
//`include "kgp_carry.v"
//`include "recursive_stage1.v"

module recurse3(sum,carry,a,b); 

output [2:0] sum;
output  carry;
input [2:0] a,b;

wire [7:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);

wire [5:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);

wire [5:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);

// final sum and carry

assign sum[0]=a[0]^b[0]^x2[0];
assign sum[1]=a[1]^b[1]^x2[2];
assign sum[2]=a[2]^b[2]^x2[4];

kgp_carry kkc(x[7:6],x2[5:4],carry);

endmodule

// D flip flop

module dflipflop33(q,d,clk,reset);
output [32:0] q;
input [32:0] d;
input clk,reset;
reg [32:0] q;
always@(negedge clk or posedge reset)
if(reset)
q<=33'b0;
else
q<=d;
endmodule
// 8-point discrete hadamard transorm (forward) using existing csa based method

////`include "recurse.v"
////`include "kgp.v"
////`include "kgp_carry.v"
////`include "recursive_stage1.v"
//`include "adder32.v"
//`include "hada4_csa.v"

module hada_csa(

x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,
x0,x1,x2,x3,x4,x5,x6,x7,
y0s,y1s,y2s,y3s,y4s,y5s,y6s,y7s,
y0,y1,y2,y3,y4,y5,y6,y7

);

input x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s;
input [31:0] x0,x1,x2,x3,x4,x5,x6,x7;
output y0s,y1s,y2s,y3s,y4s,y5s,y6s,y7s;
output [32:0] y0,y1,y2,y3,y4,y5,y6,y7;

//stage1

wire k0s,k1s,k2s,k3s,k4s,k5s,k6s,k7s;
wire [31:0] k0,k1,k2,k3,k4,k5,k6,k7;

adder32 a00(x0s,x0,x4s,x4,k0s,k0);
adder32 a10(x1s,x1,x5s,x5,k1s,k1);
adder32 a20(x2s,x2,x6s,x6,k2s,k2);
adder32 a30(x3s,x3,x7s,x7,k3s,k3);
adder32 a40(x0s,x0,(~x4s),x4,k4s,k4);
adder32 a50(x1s,x1,(~x5s),x5,k5s,k5);
adder32 a60(x2s,x2,(~x6s),x6,k6s,k6);
adder32 a70(x3s,x3,(~x7s),x7,k7s,k7);

//stage2

hada4_csa h1(

k0s,k1s,k2s,k3s,
k0,k1,k2,k3,
y0s,y1s,y2s,y3s,
y0,y1,y2,y3

);

hada4_csa h2(

k4s,k5s,k6s,k7s,
k4,k5,k6,k7,
y4s,y5s,y6s,y7s,
y4,y5,y6,y7

);

endmodule
//mux2to1

module mux2_33(i0,i1,sel,out);


input [32:0] i0,i1;
output [32:0] out;
input sel;

reg [32:0] out;

always@(i0 or i1 or sel)
	begin
		if(sel==1'b0)
			out=i0;
		else if (sel==1'b1)
			out=i1;
	end

endmodule
//4-point hadamard transform using signed carry save addition

////`include "kgp.v"
////`include "kgp_carry.v"
////`include "recursive_stage1.v"
//`include "recurse.v"
//`include "mux2_32.v"
//`include "csa4.v"

module hada4_csa(

x0s,x1s,x2s,x3s,
x0,x1,x2,x3,
y0s,y1s,y2s,y3s,
y0,y1,y2,y3

);

input x0s,x1s,x2s,x3s;
input [31:0] x0,x1,x2,x3;
output y0s,y1s,y2s,y3s;
output [32:0] y0,y1,y2,y3;

wire [31:0] x0r,x1r,x2r,x3r;
wire [31:0] x0r1,x1r1,x2r1,x3r1;

assign x0r=~x0;
assign x1r=~x1;
assign x2r=~x2;
assign x3r=~x3;

wire c0,c1,c2,c3;

recurse r31_1(x0r1,c0,x0r,32'b00000000000000000000000000000001); 
recurse r31_2(x1r1,c1,x1r,32'b00000000000000000000000000000001); 
recurse r31_3(x2r1,c2,x2r,32'b00000000000000000000000000000001);
recurse r31_4(x3r1,c3,x3r,32'b00000000000000000000000000000001);

wire [31:0] z0,z1,z2,z3;

mux2_32 m01(x0,x0r1,x0s,z0);
mux2_32 m02(x1,x1r1,x1s,z1);
mux2_32 m03(x2,x2r1,x2s,z2);
mux2_32 m04(x3,x3r1,x3s,z3);

wire [31:0] zr0,zr1,zr2,zr3;

mux2_32 mr01(x0,x0r1,(~x0s),zr0);
mux2_32 mr02(x1,x1r1,(~x1s),zr1);
mux2_32 mr03(x2,x2r1,(~x2s),zr2);
mux2_32 mr04(x3,x3r1,(~x3s),zr3);

csa4 cs1(z0,z1,z2,z3,y0,y0s);
csa4 cs2(z0,zr1,z2,zr3,y1,y1s);
csa4 cs3(z0,z1,zr2,zr3,y2,y2s);
csa4 cs4(z0,zr1,zr2,z3,y3,y3s);

endmodule
////32 bit fixed point signed adder 

//`include "recurse.v"
//`include "kgp.v"
//`include "kgp_carry.v"
//`include "recursive_stage1.v"

module adder32(as,a,bs,in_b,rrs,rr);

input as,bs;
input [31:0] a,in_b;
output rrs;
output [31:0] rr;

reg rrs;
reg [31:0] rr;
wire z;
assign z=as^bs;
wire cout,cout1;

wire [31:0] r1,b1,b2;
assign b1=(~in_b);

recurse c0(b2,cout1,b1,32'b00000000000000000000000000000001);

reg [31:0] b;

always@(z or in_b or b2)
	begin
		if(z==0)
			b=in_b;
		else if (z==1)
			b=b2;
	end
	
recurse c1(r1,cout,a,b);

wire cout2;
wire [31:0] r11,r22;
assign r11=(~r1);
recurse c2(r22,cout2,r11,32'b00000000000000000000000000000001);

reg carry;
always@(r1 or cout or z or as or bs or r22 or a or in_b)
 begin
	if(z==0 && a!=32'b0 && in_b!=32'b0)	
		begin
			rrs=as;
			rr=r1;
			carry=cout;
		end
	else if (z==1 && cout==1 && a!=32'b0 && in_b!=32'b0)
		begin	
			rrs=as;
			rr=r1;
			carry=1'b0;
		end
	else if (z==1 && cout==0 && a!=32'b0 && in_b!=32'b0)
		begin
			rrs=(~as);
			rr=r22;
			carry=1'b0;
		end
	else if (a==32'b0)
		begin
			rrs=bs;
			rr=in_b;
		end
	else if (in_b==32'b0)
		begin
			rrs=as;
			rr=a;
		end
 end

endmodule

module kgp_carry(a,b,carry);

input [1:0] a,b;
output carry;
//reg carry;

//always@(a or b)
//begin
//case(a)
//2'b00:carry=1'b0;  
//2'b11:carry=1'b1;
//2'b01:carry=b[0];
//2'b10:carry=b[0];
//default:carry=1'bx;
//endcase
//end

wire carry;

wire f,g;
assign g=a[0] & a[1];
assign f=a[0] ^ a[1];

assign carry=g|(b[0] & f);

endmodule

module recursive_stage1(a,b,y);

input [1:0] a,b;
output [1:0] y;

wire [1:0] y;
wire b0;
not n1(b0,b[1]);
wire f,g0,g1;
and a1(f,b[0],b[1]);
and a2(g0,b0,b[0],a[0]);
and a3(g1,b0,b[0],a[1]);

or o1(y[0],f,g0);
or o2(y[1],f,g1);

//reg [1:0] y;
//always@(a or b)
//begin
//case(b)
//2'b00:y=2'b00;  
//2'b11:y=2'b11;
//2'b01:y=a;
//default:y=2'bx;
//endcase
//end

//always@(a or b)
//begin
//if(b==2'b00)
//	y=2'b00;  
//else if (b==2'b11)
//	y=2'b11;
//else if (b==2'b01)
//	y=a;
//end

//wire x;
//assign x=a[0] ^ b[0];
//always@(a or b or x)
//begin
//case(x)
//1'b0:y[0]=b[0];  
//1'b1:y[0]=a[0]; 
//endcase
//end
//
//always@(a or b or x)
//begin
//case(x)
//1'b0:y[1]=b[1];  
//1'b1:y[1]=a[1];
//endcase
//end


//always@(a or b)
//begin
//if (b==2'b00)
//	y=2'b00; 
//else if (b==2'b11)	
//	y=2'b11;
//else if (b==2'b01 && a==2'b00)
//	y=2'b00;
//else if (b==2'b01 && a==2'b11)
//	y=2'b11;
//else if (b==2'b01 && a==2'b01)
//	y=2'b01;
//end

endmodule

module kgp(a,b,y);

input a,b;
output [1:0] y;
//reg [1:0] y;

//always@(a or b)
//begin
//case({a,b})
//2'b00:y=2'b00;  //kill
//2'b11:y=2'b11;	  //generate
//2'b01:y=2'b01;	//propagate
//2'b10:y=2'b01;  //propagate
//endcase   //y[1]=ab  y[0]=a+b  
//end

assign y[0]=a | b;
assign y[1]=a & b;

endmodule
//32 bit recursive doubling technique

module recurse(sum,carry,a,b); 

output [31:0] sum;
output  carry;
input [31:0] a,b;

wire [65:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);
kgp a03(a[3],b[3],x[9:8]);
kgp a04(a[4],b[4],x[11:10]);
kgp a05(a[5],b[5],x[13:12]);
kgp a06(a[6],b[6],x[15:14]);
kgp a07(a[7],b[7],x[17:16]);
kgp a08(a[8],b[8],x[19:18]);
kgp a09(a[9],b[9],x[21:20]);
kgp a10(a[10],b[10],x[23:22]);
kgp a11(a[11],b[11],x[25:24]);
kgp a12(a[12],b[12],x[27:26]);
kgp a13(a[13],b[13],x[29:28]);
kgp a14(a[14],b[14],x[31:30]);
kgp a15(a[15],b[15],x[33:32]);
kgp a16(a[16],b[16],x[35:34]);
kgp a17(a[17],b[17],x[37:36]);
kgp a18(a[18],b[18],x[39:38]);
kgp a19(a[19],b[19],x[41:40]);
kgp a20(a[20],b[20],x[43:42]);
kgp a21(a[21],b[21],x[45:44]);
kgp a22(a[22],b[22],x[47:46]);
kgp a23(a[23],b[23],x[49:48]);
kgp a24(a[24],b[24],x[51:50]);
kgp a25(a[25],b[25],x[53:52]);
kgp a26(a[26],b[26],x[55:54]);
kgp a27(a[27],b[27],x[57:56]);
kgp a28(a[28],b[28],x[59:58]);
kgp a29(a[29],b[29],x[61:60]);
kgp a30(a[30],b[30],x[63:62]);
kgp a31(a[31],b[31],x[65:64]);

wire [63:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);
recursive_stage1 s02(x[5:4],x[7:6],x1[7:6]);
recursive_stage1 s03(x[7:6],x[9:8],x1[9:8]);
recursive_stage1 s04(x[9:8],x[11:10],x1[11:10]);
recursive_stage1 s05(x[11:10],x[13:12],x1[13:12]);
recursive_stage1 s06(x[13:12],x[15:14],x1[15:14]);
recursive_stage1 s07(x[15:14],x[17:16],x1[17:16]);
recursive_stage1 s08(x[17:16],x[19:18],x1[19:18]);
recursive_stage1 s09(x[19:18],x[21:20],x1[21:20]);
recursive_stage1 s10(x[21:20],x[23:22],x1[23:22]);
recursive_stage1 s11(x[23:22],x[25:24],x1[25:24]);
recursive_stage1 s12(x[25:24],x[27:26],x1[27:26]);
recursive_stage1 s13(x[27:26],x[29:28],x1[29:28]);
recursive_stage1 s14(x[29:28],x[31:30],x1[31:30]);
recursive_stage1 s15(x[31:30],x[33:32],x1[33:32]);
recursive_stage1 s16(x[33:32],x[35:34],x1[35:34]);
recursive_stage1 s17(x[35:34],x[37:36],x1[37:36]);
recursive_stage1 s18(x[37:36],x[39:38],x1[39:38]);
recursive_stage1 s19(x[39:38],x[41:40],x1[41:40]);
recursive_stage1 s20(x[41:40],x[43:42],x1[43:42]);
recursive_stage1 s21(x[43:42],x[45:44],x1[45:44]);
recursive_stage1 s22(x[45:44],x[47:46],x1[47:46]);
recursive_stage1 s23(x[47:46],x[49:48],x1[49:48]);
recursive_stage1 s24(x[49:48],x[51:50],x1[51:50]);
recursive_stage1 s25(x[51:50],x[53:52],x1[53:52]);
recursive_stage1 s26(x[53:52],x[55:54],x1[55:54]);
recursive_stage1 s27(x[55:54],x[57:56],x1[57:56]);
recursive_stage1 s28(x[57:56],x[59:58],x1[59:58]);
recursive_stage1 s29(x[59:58],x[61:60],x1[61:60]);
recursive_stage1 s30(x[61:60],x[63:62],x1[63:62]);

wire [63:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);
recursive_stage1 s102(x1[3:2],x1[7:6],x2[7:6]);
recursive_stage1 s103(x1[5:4],x1[9:8],x2[9:8]);
recursive_stage1 s104(x1[7:6],x1[11:10],x2[11:10]);
recursive_stage1 s105(x1[9:8],x1[13:12],x2[13:12]);
recursive_stage1 s106(x1[11:10],x1[15:14],x2[15:14]);
recursive_stage1 s107(x1[13:12],x1[17:16],x2[17:16]);
recursive_stage1 s108(x1[15:14],x1[19:18],x2[19:18]);
recursive_stage1 s109(x1[17:16],x1[21:20],x2[21:20]);
recursive_stage1 s110(x1[19:18],x1[23:22],x2[23:22]);
recursive_stage1 s111(x1[21:20],x1[25:24],x2[25:24]);
recursive_stage1 s112(x1[23:22],x1[27:26],x2[27:26]);
recursive_stage1 s113(x1[25:24],x1[29:28],x2[29:28]);
recursive_stage1 s114(x1[27:26],x1[31:30],x2[31:30]);
recursive_stage1 s115(x1[29:28],x1[33:32],x2[33:32]);
recursive_stage1 s116(x1[31:30],x1[35:34],x2[35:34]);
recursive_stage1 s117(x1[33:32],x1[37:36],x2[37:36]);
recursive_stage1 s118(x1[35:34],x1[39:38],x2[39:38]);
recursive_stage1 s119(x1[37:36],x1[41:40],x2[41:40]);
recursive_stage1 s120(x1[39:38],x1[43:42],x2[43:42]);
recursive_stage1 s121(x1[41:40],x1[45:44],x2[45:44]);
recursive_stage1 s122(x1[43:42],x1[47:46],x2[47:46]);
recursive_stage1 s123(x1[45:44],x1[49:48],x2[49:48]);
recursive_stage1 s124(x1[47:46],x1[51:50],x2[51:50]);
recursive_stage1 s125(x1[49:48],x1[53:52],x2[53:52]);
recursive_stage1 s126(x1[51:50],x1[55:54],x2[55:54]);
recursive_stage1 s127(x1[53:52],x1[57:56],x2[57:56]);
recursive_stage1 s128(x1[55:54],x1[59:58],x2[59:58]);
recursive_stage1 s129(x1[57:56],x1[61:60],x2[61:60]);
recursive_stage1 s130(x1[59:58],x1[63:62],x2[63:62]);

wire [63:0] x3;  //recursive doubling stage3
assign x3[7:0]=x2[7:0];

recursive_stage1 s203(x2[1:0],x2[9:8],x3[9:8]);
recursive_stage1 s204(x2[3:2],x2[11:10],x3[11:10]);
recursive_stage1 s205(x2[5:4],x2[13:12],x3[13:12]);
recursive_stage1 s206(x2[7:6],x2[15:14],x3[15:14]);
recursive_stage1 s207(x2[9:8],x2[17:16],x3[17:16]);
recursive_stage1 s208(x2[11:10],x2[19:18],x3[19:18]);
recursive_stage1 s209(x2[13:12],x2[21:20],x3[21:20]);
recursive_stage1 s210(x2[15:14],x2[23:22],x3[23:22]);
recursive_stage1 s211(x2[17:16],x2[25:24],x3[25:24]);
recursive_stage1 s212(x2[19:18],x2[27:26],x3[27:26]);
recursive_stage1 s213(x2[21:20],x2[29:28],x3[29:28]);
recursive_stage1 s214(x2[23:22],x2[31:30],x3[31:30]);
recursive_stage1 s215(x2[25:24],x2[33:32],x3[33:32]);
recursive_stage1 s216(x2[27:26],x2[35:34],x3[35:34]);
recursive_stage1 s217(x2[29:28],x2[37:36],x3[37:36]);
recursive_stage1 s218(x2[31:30],x2[39:38],x3[39:38]);
recursive_stage1 s219(x2[33:32],x2[41:40],x3[41:40]);
recursive_stage1 s220(x2[35:34],x2[43:42],x3[43:42]);
recursive_stage1 s221(x2[37:36],x2[45:44],x3[45:44]);
recursive_stage1 s222(x2[39:38],x2[47:46],x3[47:46]);
recursive_stage1 s223(x2[41:40],x2[49:48],x3[49:48]);
recursive_stage1 s224(x2[43:42],x2[51:50],x3[51:50]);
recursive_stage1 s225(x2[45:44],x2[53:52],x3[53:52]);
recursive_stage1 s226(x2[47:46],x2[55:54],x3[55:54]);
recursive_stage1 s227(x2[49:48],x2[57:56],x3[57:56]);
recursive_stage1 s228(x2[51:50],x2[59:58],x3[59:58]);
recursive_stage1 s229(x2[53:52],x2[61:60],x3[61:60]);
recursive_stage1 s230(x2[55:54],x2[63:62],x3[63:62]);

wire [63:0] x4;  //recursive doubling stage 4
assign x4[15:0]=x3[15:0];

recursive_stage1 s307(x3[1:0],x3[17:16],x4[17:16]);
recursive_stage1 s308(x3[3:2],x3[19:18],x4[19:18]);
recursive_stage1 s309(x3[5:4],x3[21:20],x4[21:20]);
recursive_stage1 s310(x3[7:6],x3[23:22],x4[23:22]);
recursive_stage1 s311(x3[9:8],x3[25:24],x4[25:24]);
recursive_stage1 s312(x3[11:10],x3[27:26],x4[27:26]);
recursive_stage1 s313(x3[13:12],x3[29:28],x4[29:28]);
recursive_stage1 s314(x3[15:14],x3[31:30],x4[31:30]);
recursive_stage1 s315(x3[17:16],x3[33:32],x4[33:32]);
recursive_stage1 s316(x3[19:18],x3[35:34],x4[35:34]);
recursive_stage1 s317(x3[21:20],x3[37:36],x4[37:36]);
recursive_stage1 s318(x3[23:22],x3[39:38],x4[39:38]);
recursive_stage1 s319(x3[25:24],x3[41:40],x4[41:40]);
recursive_stage1 s320(x3[27:26],x3[43:42],x4[43:42]);
recursive_stage1 s321(x3[29:28],x3[45:44],x4[45:44]);
recursive_stage1 s322(x3[31:30],x3[47:46],x4[47:46]);
recursive_stage1 s323(x3[33:32],x3[49:48],x4[49:48]);
recursive_stage1 s324(x3[35:34],x3[51:50],x4[51:50]);
recursive_stage1 s325(x3[37:36],x3[53:52],x4[53:52]);
recursive_stage1 s326(x3[39:38],x3[55:54],x4[55:54]);
recursive_stage1 s327(x3[41:40],x3[57:56],x4[57:56]);
recursive_stage1 s328(x3[43:42],x3[59:58],x4[59:58]);
recursive_stage1 s329(x3[45:44],x3[61:60],x4[61:60]);
recursive_stage1 s330(x3[47:46],x3[63:62],x4[63:62]);

wire [63:0] x5;  //recursive doubling stage 5
assign x5[31:0]=x4[31:0];

recursive_stage1 s415(x4[1:0],x4[33:32],x5[33:32]);
recursive_stage1 s416(x4[3:2],x4[35:34],x5[35:34]);
recursive_stage1 s417(x4[5:4],x4[37:36],x5[37:36]);
recursive_stage1 s418(x4[7:6],x4[39:38],x5[39:38]);
recursive_stage1 s419(x4[9:8],x4[41:40],x5[41:40]);
recursive_stage1 s420(x4[11:10],x4[43:42],x5[43:42]);
recursive_stage1 s421(x4[13:12],x4[45:44],x5[45:44]);
recursive_stage1 s422(x4[15:14],x4[47:46],x5[47:46]);
recursive_stage1 s423(x4[17:16],x4[49:48],x5[49:48]);
recursive_stage1 s424(x4[19:18],x4[51:50],x5[51:50]);
recursive_stage1 s425(x4[21:20],x4[53:52],x5[53:52]);
recursive_stage1 s426(x4[23:22],x4[55:54],x5[55:54]);
recursive_stage1 s427(x4[25:24],x4[57:56],x5[57:56]);
recursive_stage1 s428(x4[27:26],x4[59:58],x5[59:58]);
recursive_stage1 s429(x4[29:28],x4[61:60],x5[61:60]);
recursive_stage1 s430(x4[31:30],x4[63:62],x5[63:62]);

 // final sum and carry

assign sum[0]=a[0]^b[0]^x5[0];
assign sum[1]=a[1]^b[1]^x5[2];
assign sum[2]=a[2]^b[2]^x5[4];
assign sum[3]=a[3]^b[3]^x5[6];
assign sum[4]=a[4]^b[4]^x5[8];
assign sum[5]=a[5]^b[5]^x5[10];
assign sum[6]=a[6]^b[6]^x5[12];
assign sum[7]=a[7]^b[7]^x5[14];
assign sum[8]=a[8]^b[8]^x5[16];
assign sum[9]=a[9]^b[9]^x5[18];
assign sum[10]=a[10]^b[10]^x5[20];
assign sum[11]=a[11]^b[11]^x5[22];
assign sum[12]=a[12]^b[12]^x5[24];
assign sum[13]=a[13]^b[13]^x5[26];
assign sum[14]=a[14]^b[14]^x5[28];
assign sum[15]=a[15]^b[15]^x5[30];
assign sum[16]=a[16]^b[16]^x5[32];
assign sum[17]=a[17]^b[17]^x5[34];
assign sum[18]=a[18]^b[18]^x5[36];
assign sum[19]=a[19]^b[19]^x5[38];
assign sum[20]=a[20]^b[20]^x5[40];
assign sum[21]=a[21]^b[21]^x5[42];
assign sum[22]=a[22]^b[22]^x5[44];
assign sum[23]=a[23]^b[23]^x5[46];
assign sum[24]=a[24]^b[24]^x5[48];
assign sum[25]=a[25]^b[25]^x5[50];
assign sum[26]=a[26]^b[26]^x5[52];
assign sum[27]=a[27]^b[27]^x5[54];
assign sum[28]=a[28]^b[28]^x5[56];
assign sum[29]=a[29]^b[29]^x5[58];
assign sum[30]=a[30]^b[30]^x5[60];
assign sum[31]=a[31]^b[31]^x5[62];


kgp_carry kkc(x[65:64],x5[63:62],carry);

endmodule
//csa4

//`include "fulladd.v"
//`include "recurse36.v"
//`include "kgp.v"
//`include "kgp_carry.v"
//`include "recursive_stage1.v"

module csa4(p0,p1,p2,p3,sum,sum_sign);

input [31:0] p0,p1,p2,p3;
output [32:0] sum;
output sum_sign;

//csa1

wire [31:0] sum1;
wire [31:0] carry1;
wire [32:0] carry11;

fulladd f100(sum1[0],carry1[0],p0[0],p1[0],p2[0]);
fulladd f101(sum1[1],carry1[1],p0[1],p1[1],p2[1]);
fulladd f102(sum1[2],carry1[2],p0[2],p1[2],p2[2]);
fulladd f103(sum1[3],carry1[3],p0[3],p1[3],p2[3]);
fulladd f104(sum1[4],carry1[4],p0[4],p1[4],p2[4]);
fulladd f105(sum1[5],carry1[5],p0[5],p1[5],p2[5]);
fulladd f106(sum1[6],carry1[6],p0[6],p1[6],p2[6]);
fulladd f107(sum1[7],carry1[7],p0[7],p1[7],p2[7]);
fulladd f108(sum1[8],carry1[8],p0[8],p1[8],p2[8]);
fulladd f109(sum1[9],carry1[9],p0[9],p1[9],p2[9]);
fulladd f110(sum1[10],carry1[10],p0[10],p1[10],p2[10]);
fulladd f111(sum1[11],carry1[11],p0[11],p1[11],p2[11]);
fulladd f112(sum1[12],carry1[12],p0[12],p1[12],p2[12]);
fulladd f113(sum1[13],carry1[13],p0[13],p1[13],p2[13]);
fulladd f114(sum1[14],carry1[14],p0[14],p1[14],p2[14]);
fulladd f115(sum1[15],carry1[15],p0[15],p1[15],p2[15]);
fulladd f116(sum1[16],carry1[16],p0[16],p1[16],p2[16]);
fulladd f117(sum1[17],carry1[17],p0[17],p1[17],p2[17]);
fulladd f118(sum1[18],carry1[18],p0[18],p1[18],p2[18]);
fulladd f119(sum1[19],carry1[19],p0[19],p1[19],p2[19]);
fulladd f120(sum1[20],carry1[20],p0[20],p1[20],p2[20]);
fulladd f121(sum1[21],carry1[21],p0[21],p1[21],p2[21]);
fulladd f122(sum1[22],carry1[22],p0[22],p1[22],p2[22]);
fulladd f123(sum1[23],carry1[23],p0[23],p1[23],p2[23]);
fulladd f124(sum1[24],carry1[24],p0[24],p1[24],p2[24]);
fulladd f125(sum1[25],carry1[25],p0[25],p1[25],p2[25]);
fulladd f126(sum1[26],carry1[26],p0[26],p1[26],p2[26]);
fulladd f127(sum1[27],carry1[27],p0[27],p1[27],p2[27]);
fulladd f128(sum1[28],carry1[28],p0[28],p1[28],p2[28]);
fulladd f129(sum1[29],carry1[29],p0[29],p1[29],p2[29]);
fulladd f130(sum1[30],carry1[30],p0[30],p1[30],p2[30]);
fulladd f131(sum1[31],carry1[31],p0[31],p1[31],p2[31]);

assign carry11={carry1,1'b0};

//csa2

wire [32:0] sum3;
wire [32:0] carry3;
wire [33:0] carry33;

fulladd f300(sum3[0],carry3[0],sum1[0],carry11[0],p3[0]);
fulladd f301(sum3[1],carry3[1],sum1[1],carry11[1],p3[1]);
fulladd f302(sum3[2],carry3[2],sum1[2],carry11[2],p3[2]);
fulladd f303(sum3[3],carry3[3],sum1[3],carry11[3],p3[3]);
fulladd f304(sum3[4],carry3[4],sum1[4],carry11[4],p3[4]);
fulladd f305(sum3[5],carry3[5],sum1[5],carry11[5],p3[5]);
fulladd f306(sum3[6],carry3[6],sum1[6],carry11[6],p3[6]);
fulladd f307(sum3[7],carry3[7],sum1[7],carry11[7],p3[7]);
fulladd f308(sum3[8],carry3[8],sum1[8],carry11[8],p3[8]);
fulladd f309(sum3[9],carry3[9],sum1[9],carry11[9],p3[9]);
fulladd f310(sum3[10],carry3[10],sum1[10],carry11[10],p3[10]);
fulladd f311(sum3[11],carry3[11],sum1[11],carry11[11],p3[11]);
fulladd f312(sum3[12],carry3[12],sum1[12],carry11[12],p3[12]);
fulladd f313(sum3[13],carry3[13],sum1[13],carry11[13],p3[13]);
fulladd f314(sum3[14],carry3[14],sum1[14],carry11[14],p3[14]);
fulladd f315(sum3[15],carry3[15],sum1[15],carry11[15],p3[15]);
fulladd f316(sum3[16],carry3[16],sum1[16],carry11[16],p3[16]);
fulladd f317(sum3[17],carry3[17],sum1[17],carry11[17],p3[17]);
fulladd f318(sum3[18],carry3[18],sum1[18],carry11[18],p3[18]);
fulladd f319(sum3[19],carry3[19],sum1[19],carry11[19],p3[19]);
fulladd f320(sum3[20],carry3[20],sum1[20],carry11[20],p3[20]);
fulladd f321(sum3[21],carry3[21],sum1[21],carry11[21],p3[21]);
fulladd f322(sum3[22],carry3[22],sum1[22],carry11[22],p3[22]);
fulladd f323(sum3[23],carry3[23],sum1[23],carry11[23],p3[23]);
fulladd f324(sum3[24],carry3[24],sum1[24],carry11[24],p3[24]);
fulladd f325(sum3[25],carry3[25],sum1[25],carry11[25],p3[25]);
fulladd f326(sum3[26],carry3[26],sum1[26],carry11[26],p3[26]);
fulladd f327(sum3[27],carry3[27],sum1[27],carry11[27],p3[27]);
fulladd f328(sum3[28],carry3[28],sum1[28],carry11[28],p3[28]);
fulladd f329(sum3[29],carry3[29],sum1[29],carry11[29],p3[29]);
fulladd f330(sum3[30],carry3[30],sum1[30],carry11[30],p3[30]);
fulladd f331(sum3[31],carry3[31],sum1[31],carry11[31],p3[31]);
fulladd f332(sum3[32],carry3[32],sum1[31],carry11[32],p3[31]);

assign carry33={carry3,1'b0};

wire [35:0] sum7,sum7r,sum7r1;
wire carry7,carry,carry8;

recurse36 r361(sum7,carry7,{sum3[32],sum3[32],sum3[32],sum3[32:0]},{carry33[33],carry33[33],carry33[33:0]});

assign carry=sum7[33];

assign sum7r=~sum7;

recurse36 r362(sum7r1,carry8,{sum7r[33],sum7r[33],sum7r[33:0]},36'b000000000000000000000000000000000001);

reg [32:0] sum;
reg sum_sign;

always@(sum7r1 or carry or sum7)
begin
	if (carry==1'b0)
		begin
			sum[32:0]=sum7[32:0];
			sum_sign=1'b0;
		end
	else if (carry==1'b1)
		begin
			sum[32:0]=sum7r1[32:0];
			sum_sign=1'b1;
		end
end


endmodule

//mux2to1

module mux2_32(i0,i1,sel,out);


input [31:0] i0,i1;
output [31:0] out;
input sel;

reg [31:0] out;

always@(i0 or i1 or sel)
	begin
		if(sel==1'b0)
			out=i0;
		else if (sel==1'b1)
			out=i1;
	end

endmodule
//39 bit recursive doubling technique

module recurse36(sum,carry,a,b); 

output [35:0] sum;
output  carry;
input [35:0] a,b;

wire [73:0] x;

assign x[1:0]=2'b00;  // kgp generation

kgp a00(a[0],b[0],x[3:2]);
kgp a01(a[1],b[1],x[5:4]);
kgp a02(a[2],b[2],x[7:6]);
kgp a03(a[3],b[3],x[9:8]);
kgp a04(a[4],b[4],x[11:10]);
kgp a05(a[5],b[5],x[13:12]);
kgp a06(a[6],b[6],x[15:14]);
kgp a07(a[7],b[7],x[17:16]);
kgp a08(a[8],b[8],x[19:18]);
kgp a09(a[9],b[9],x[21:20]);
kgp a10(a[10],b[10],x[23:22]);
kgp a11(a[11],b[11],x[25:24]);
kgp a12(a[12],b[12],x[27:26]);
kgp a13(a[13],b[13],x[29:28]);
kgp a14(a[14],b[14],x[31:30]);
kgp a15(a[15],b[15],x[33:32]);
kgp a16(a[16],b[16],x[35:34]);
kgp a17(a[17],b[17],x[37:36]);
kgp a18(a[18],b[18],x[39:38]);
kgp a19(a[19],b[19],x[41:40]);
kgp a20(a[20],b[20],x[43:42]);
kgp a21(a[21],b[21],x[45:44]);
kgp a22(a[22],b[22],x[47:46]);
kgp a23(a[23],b[23],x[49:48]);
kgp a24(a[24],b[24],x[51:50]);
kgp a25(a[25],b[25],x[53:52]);
kgp a26(a[26],b[26],x[55:54]);
kgp a27(a[27],b[27],x[57:56]);
kgp a28(a[28],b[28],x[59:58]);
kgp a29(a[29],b[29],x[61:60]);
kgp a30(a[30],b[30],x[63:62]);
kgp a31(a[31],b[31],x[65:64]);
kgp a32(a[32],b[32],x[67:66]);
kgp a33(a[33],b[33],x[69:68]);
kgp a34(a[34],b[34],x[71:70]);
kgp a35(a[35],b[35],x[73:72]);

wire [71:0] x1;  //recursive doubling stage 1
assign x1[1:0]=x[1:0];

recursive_stage1 s00(x[1:0],x[3:2],x1[3:2]);
recursive_stage1 s01(x[3:2],x[5:4],x1[5:4]);
recursive_stage1 s02(x[5:4],x[7:6],x1[7:6]);
recursive_stage1 s03(x[7:6],x[9:8],x1[9:8]);
recursive_stage1 s04(x[9:8],x[11:10],x1[11:10]);
recursive_stage1 s05(x[11:10],x[13:12],x1[13:12]);
recursive_stage1 s06(x[13:12],x[15:14],x1[15:14]);
recursive_stage1 s07(x[15:14],x[17:16],x1[17:16]);
recursive_stage1 s08(x[17:16],x[19:18],x1[19:18]);
recursive_stage1 s09(x[19:18],x[21:20],x1[21:20]);
recursive_stage1 s10(x[21:20],x[23:22],x1[23:22]);
recursive_stage1 s11(x[23:22],x[25:24],x1[25:24]);
recursive_stage1 s12(x[25:24],x[27:26],x1[27:26]);
recursive_stage1 s13(x[27:26],x[29:28],x1[29:28]);
recursive_stage1 s14(x[29:28],x[31:30],x1[31:30]);
recursive_stage1 s15(x[31:30],x[33:32],x1[33:32]);
recursive_stage1 s16(x[33:32],x[35:34],x1[35:34]);
recursive_stage1 s17(x[35:34],x[37:36],x1[37:36]);
recursive_stage1 s18(x[37:36],x[39:38],x1[39:38]);
recursive_stage1 s19(x[39:38],x[41:40],x1[41:40]);
recursive_stage1 s20(x[41:40],x[43:42],x1[43:42]);
recursive_stage1 s21(x[43:42],x[45:44],x1[45:44]);
recursive_stage1 s22(x[45:44],x[47:46],x1[47:46]);
recursive_stage1 s23(x[47:46],x[49:48],x1[49:48]);
recursive_stage1 s24(x[49:48],x[51:50],x1[51:50]);
recursive_stage1 s25(x[51:50],x[53:52],x1[53:52]);
recursive_stage1 s26(x[53:52],x[55:54],x1[55:54]);
recursive_stage1 s27(x[55:54],x[57:56],x1[57:56]);
recursive_stage1 s28(x[57:56],x[59:58],x1[59:58]);
recursive_stage1 s29(x[59:58],x[61:60],x1[61:60]);
recursive_stage1 s30(x[61:60],x[63:62],x1[63:62]);
recursive_stage1 s31(x[63:62],x[65:64],x1[65:64]);
recursive_stage1 s32(x[65:64],x[67:66],x1[67:66]);
recursive_stage1 s33(x[67:66],x[69:68],x1[69:68]);
recursive_stage1 s34(x[69:68],x[71:70],x1[71:70]);

wire [71:0] x2;  //recursive doubling stage2
assign x2[3:0]=x1[3:0];

recursive_stage1 s101(x1[1:0],x1[5:4],x2[5:4]);
recursive_stage1 s102(x1[3:2],x1[7:6],x2[7:6]);
recursive_stage1 s103(x1[5:4],x1[9:8],x2[9:8]);
recursive_stage1 s104(x1[7:6],x1[11:10],x2[11:10]);
recursive_stage1 s105(x1[9:8],x1[13:12],x2[13:12]);
recursive_stage1 s106(x1[11:10],x1[15:14],x2[15:14]);
recursive_stage1 s107(x1[13:12],x1[17:16],x2[17:16]);
recursive_stage1 s108(x1[15:14],x1[19:18],x2[19:18]);
recursive_stage1 s109(x1[17:16],x1[21:20],x2[21:20]);
recursive_stage1 s110(x1[19:18],x1[23:22],x2[23:22]);
recursive_stage1 s111(x1[21:20],x1[25:24],x2[25:24]);
recursive_stage1 s112(x1[23:22],x1[27:26],x2[27:26]);
recursive_stage1 s113(x1[25:24],x1[29:28],x2[29:28]);
recursive_stage1 s114(x1[27:26],x1[31:30],x2[31:30]);
recursive_stage1 s115(x1[29:28],x1[33:32],x2[33:32]);
recursive_stage1 s116(x1[31:30],x1[35:34],x2[35:34]);
recursive_stage1 s117(x1[33:32],x1[37:36],x2[37:36]);
recursive_stage1 s118(x1[35:34],x1[39:38],x2[39:38]);
recursive_stage1 s119(x1[37:36],x1[41:40],x2[41:40]);
recursive_stage1 s120(x1[39:38],x1[43:42],x2[43:42]);
recursive_stage1 s121(x1[41:40],x1[45:44],x2[45:44]);
recursive_stage1 s122(x1[43:42],x1[47:46],x2[47:46]);
recursive_stage1 s123(x1[45:44],x1[49:48],x2[49:48]);
recursive_stage1 s124(x1[47:46],x1[51:50],x2[51:50]);
recursive_stage1 s125(x1[49:48],x1[53:52],x2[53:52]);
recursive_stage1 s126(x1[51:50],x1[55:54],x2[55:54]);
recursive_stage1 s127(x1[53:52],x1[57:56],x2[57:56]);
recursive_stage1 s128(x1[55:54],x1[59:58],x2[59:58]);
recursive_stage1 s129(x1[57:56],x1[61:60],x2[61:60]);
recursive_stage1 s130(x1[59:58],x1[63:62],x2[63:62]);
recursive_stage1 s131(x1[61:60],x1[65:64],x2[65:64]);
recursive_stage1 s132(x1[63:62],x1[67:66],x2[67:66]);
recursive_stage1 s133(x1[65:64],x1[69:68],x2[69:68]);
recursive_stage1 s134(x1[67:66],x1[71:70],x2[71:70]);

wire [71:0] x3;  //recursive doubling stage3
assign x3[7:0]=x2[7:0];

recursive_stage1 s203(x2[1:0],x2[9:8],x3[9:8]);
recursive_stage1 s204(x2[3:2],x2[11:10],x3[11:10]);
recursive_stage1 s205(x2[5:4],x2[13:12],x3[13:12]);
recursive_stage1 s206(x2[7:6],x2[15:14],x3[15:14]);
recursive_stage1 s207(x2[9:8],x2[17:16],x3[17:16]);
recursive_stage1 s208(x2[11:10],x2[19:18],x3[19:18]);
recursive_stage1 s209(x2[13:12],x2[21:20],x3[21:20]);
recursive_stage1 s210(x2[15:14],x2[23:22],x3[23:22]);
recursive_stage1 s211(x2[17:16],x2[25:24],x3[25:24]);
recursive_stage1 s212(x2[19:18],x2[27:26],x3[27:26]);
recursive_stage1 s213(x2[21:20],x2[29:28],x3[29:28]);
recursive_stage1 s214(x2[23:22],x2[31:30],x3[31:30]);
recursive_stage1 s215(x2[25:24],x2[33:32],x3[33:32]);
recursive_stage1 s216(x2[27:26],x2[35:34],x3[35:34]);
recursive_stage1 s217(x2[29:28],x2[37:36],x3[37:36]);
recursive_stage1 s218(x2[31:30],x2[39:38],x3[39:38]);
recursive_stage1 s219(x2[33:32],x2[41:40],x3[41:40]);
recursive_stage1 s220(x2[35:34],x2[43:42],x3[43:42]);
recursive_stage1 s221(x2[37:36],x2[45:44],x3[45:44]);
recursive_stage1 s222(x2[39:38],x2[47:46],x3[47:46]);
recursive_stage1 s223(x2[41:40],x2[49:48],x3[49:48]);
recursive_stage1 s224(x2[43:42],x2[51:50],x3[51:50]);
recursive_stage1 s225(x2[45:44],x2[53:52],x3[53:52]);
recursive_stage1 s226(x2[47:46],x2[55:54],x3[55:54]);
recursive_stage1 s227(x2[49:48],x2[57:56],x3[57:56]);
recursive_stage1 s228(x2[51:50],x2[59:58],x3[59:58]);
recursive_stage1 s229(x2[53:52],x2[61:60],x3[61:60]);
recursive_stage1 s230(x2[55:54],x2[63:62],x3[63:62]);
recursive_stage1 s231(x2[57:56],x2[65:64],x3[65:64]);
recursive_stage1 s232(x2[59:58],x2[67:66],x3[67:66]);
recursive_stage1 s233(x2[61:60],x2[69:68],x3[69:68]);
recursive_stage1 s234(x2[63:62],x2[71:70],x3[71:70]);

wire [71:0] x4;  //recursive doubling stage 4
assign x4[15:0]=x3[15:0];

recursive_stage1 s307(x3[1:0],x3[17:16],x4[17:16]);
recursive_stage1 s308(x3[3:2],x3[19:18],x4[19:18]);
recursive_stage1 s309(x3[5:4],x3[21:20],x4[21:20]);
recursive_stage1 s310(x3[7:6],x3[23:22],x4[23:22]);
recursive_stage1 s311(x3[9:8],x3[25:24],x4[25:24]);
recursive_stage1 s312(x3[11:10],x3[27:26],x4[27:26]);
recursive_stage1 s313(x3[13:12],x3[29:28],x4[29:28]);
recursive_stage1 s314(x3[15:14],x3[31:30],x4[31:30]);
recursive_stage1 s315(x3[17:16],x3[33:32],x4[33:32]);
recursive_stage1 s316(x3[19:18],x3[35:34],x4[35:34]);
recursive_stage1 s317(x3[21:20],x3[37:36],x4[37:36]);
recursive_stage1 s318(x3[23:22],x3[39:38],x4[39:38]);
recursive_stage1 s319(x3[25:24],x3[41:40],x4[41:40]);
recursive_stage1 s320(x3[27:26],x3[43:42],x4[43:42]);
recursive_stage1 s321(x3[29:28],x3[45:44],x4[45:44]);
recursive_stage1 s322(x3[31:30],x3[47:46],x4[47:46]);
recursive_stage1 s323(x3[33:32],x3[49:48],x4[49:48]);
recursive_stage1 s324(x3[35:34],x3[51:50],x4[51:50]);
recursive_stage1 s325(x3[37:36],x3[53:52],x4[53:52]);
recursive_stage1 s326(x3[39:38],x3[55:54],x4[55:54]);
recursive_stage1 s327(x3[41:40],x3[57:56],x4[57:56]);
recursive_stage1 s328(x3[43:42],x3[59:58],x4[59:58]);
recursive_stage1 s329(x3[45:44],x3[61:60],x4[61:60]);
recursive_stage1 s330(x3[47:46],x3[63:62],x4[63:62]);
recursive_stage1 s331(x3[49:48],x3[65:64],x4[65:64]);
recursive_stage1 s332(x3[51:50],x3[67:66],x4[67:66]);
recursive_stage1 s333(x3[53:52],x3[69:68],x4[69:68]);
recursive_stage1 s334(x3[55:54],x3[71:70],x4[71:70]);

wire [71:0] x5;  //recursive doubling stage 5
assign x5[31:0]=x4[31:0];

recursive_stage1 s415(x4[1:0],x4[33:32],x5[33:32]);
recursive_stage1 s416(x4[3:2],x4[35:34],x5[35:34]);
recursive_stage1 s417(x4[5:4],x4[37:36],x5[37:36]);
recursive_stage1 s418(x4[7:6],x4[39:38],x5[39:38]);
recursive_stage1 s419(x4[9:8],x4[41:40],x5[41:40]);
recursive_stage1 s420(x4[11:10],x4[43:42],x5[43:42]);
recursive_stage1 s421(x4[13:12],x4[45:44],x5[45:44]);
recursive_stage1 s422(x4[15:14],x4[47:46],x5[47:46]);
recursive_stage1 s423(x4[17:16],x4[49:48],x5[49:48]);
recursive_stage1 s424(x4[19:18],x4[51:50],x5[51:50]);
recursive_stage1 s425(x4[21:20],x4[53:52],x5[53:52]);
recursive_stage1 s426(x4[23:22],x4[55:54],x5[55:54]);
recursive_stage1 s427(x4[25:24],x4[57:56],x5[57:56]);
recursive_stage1 s428(x4[27:26],x4[59:58],x5[59:58]);
recursive_stage1 s429(x4[29:28],x4[61:60],x5[61:60]);
recursive_stage1 s430(x4[31:30],x4[63:62],x5[63:62]);
recursive_stage1 s431(x4[33:32],x4[65:64],x5[65:64]);
recursive_stage1 s432(x4[35:34],x4[67:66],x5[67:66]);
recursive_stage1 s433(x4[37:36],x4[69:68],x5[69:68]);
recursive_stage1 s434(x4[39:38],x4[71:70],x5[71:70]);

wire [71:0] x6;  // recursive doubling stage 6
assign x6[63:0]=x5[63:0];

recursive_stage1 s531(x5[1:0],x5[65:64],x6[65:64]);
recursive_stage1 s532(x5[3:2],x5[67:66],x6[67:66]);
recursive_stage1 s533(x5[5:4],x5[69:68],x6[69:68]);
recursive_stage1 s534(x5[7:6],x5[71:70],x6[71:70]);

// final sum and carry

assign sum[0]=a[0]^b[0]^x6[0];
assign sum[1]=a[1]^b[1]^x6[2];
assign sum[2]=a[2]^b[2]^x6[4];
assign sum[3]=a[3]^b[3]^x6[6];
assign sum[4]=a[4]^b[4]^x6[8];
assign sum[5]=a[5]^b[5]^x6[10];
assign sum[6]=a[6]^b[6]^x6[12];
assign sum[7]=a[7]^b[7]^x6[14];
assign sum[8]=a[8]^b[8]^x6[16];
assign sum[9]=a[9]^b[9]^x6[18];
assign sum[10]=a[10]^b[10]^x6[20];
assign sum[11]=a[11]^b[11]^x6[22];
assign sum[12]=a[12]^b[12]^x6[24];
assign sum[13]=a[13]^b[13]^x6[26];
assign sum[14]=a[14]^b[14]^x6[28];
assign sum[15]=a[15]^b[15]^x6[30];
assign sum[16]=a[16]^b[16]^x6[32];
assign sum[17]=a[17]^b[17]^x6[34];
assign sum[18]=a[18]^b[18]^x6[36];
assign sum[19]=a[19]^b[19]^x6[38];
assign sum[20]=a[20]^b[20]^x6[40];
assign sum[21]=a[21]^b[21]^x6[42];
assign sum[22]=a[22]^b[22]^x6[44];
assign sum[23]=a[23]^b[23]^x6[46];
assign sum[24]=a[24]^b[24]^x6[48];
assign sum[25]=a[25]^b[25]^x6[50];
assign sum[26]=a[26]^b[26]^x6[52];
assign sum[27]=a[27]^b[27]^x6[54];
assign sum[28]=a[28]^b[28]^x6[56];
assign sum[29]=a[29]^b[29]^x6[58];
assign sum[30]=a[30]^b[30]^x6[60];
assign sum[31]=a[31]^b[31]^x6[62];
assign sum[32]=a[32]^b[32]^x6[64];
assign sum[33]=a[33]^b[33]^x6[66];
assign sum[34]=a[34]^b[34]^x6[68];
assign sum[35]=a[35]^b[35]^x6[70];

kgp_carry kkc(x[73:72],x6[71:70],carry);

endmodule

// Full Adder Module
module fulladd(sum, carry, x,y,z);

output sum,carry;
input x,y,z;

wire w;	
	assign 	 w = x ^ y;
        assign	 sum = w ^ z;
	assign 	 carry = (x & y)|(w & z);
endmodule
`default_nettype wire
