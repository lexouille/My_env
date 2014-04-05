`timescale 1ns/1ps
module tbench (
                      );
   wreal dvddgo1;
   wreal dvss;
   reg id_en;
   wire od_clk_spice;
   wire od_clk_vams;

   assign dvddgo1 = 1.5;
   assign dvss = 0.0;

   initial
      id_en = 1;

/*
   osc osc_vams_inst(
      .dvddgo1(dvddgo1),
      .dvss(dvss),
      .id_en(id_en),
      .od_clk(od_clk_vams)
   );
   */
   \work.osc_spice osc_spice_inst(
      .dvddgo1(dvddgo1),
      .dvss(dvss),
      .id_en(id_en),
      .od_clk(od_clk_spice)
   );
   
endmodule // tbench
