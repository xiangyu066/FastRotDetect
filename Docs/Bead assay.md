Typically, the center positions of the spinning beads are fitted by a two-dimensional Gaussian function, which is then applied to each time-series image.\
\
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/P7-T_0-demo_fitting.png" width="100%">\
\
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/P7-T_0-demo_fitting_single%20trace.png" width="30%">\
\
However, using this pixel-by-pixel FFT can quickly calculate the frequency of optical fluctuations at each pixel.\
\
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/1.5um_20210330_Pos2_T_0-1-demo.gif" width="10%">
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/1.5um_20210330_Pos2_T_0-1-demo.png" width="10%">\
\
So, we can directly apply this method to wild-field, and the analysis time of a time-series images containing 2048 (w) x 512 (h) x 204 (f) can be shortened within a few seconds..\
\
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/P7-T_0-demo.gif" width="100%">\
\
<img src="https://github.com/xiangyu066/FastRotDetect/blob/main/Docs/P7-T_0-demo.png" width="100%">
