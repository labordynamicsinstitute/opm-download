/* $Id$ */
/* $URL$ */

%let opmout=../../clean/opm;

libname outputs "&opmout./extra";
libname quartrly "&opmout./quarterly";
libname yearly "&opmout./yearly";

libname opmfmt (outputs);

options nocenter;
options fmtsearch=(opmfmt);

options SASAUTOS=(!SASAUTOS,"macros/","../common/macros");

/* for comparisons to QCEW */
%let qcewdir=../../clean/qcew/extra;

libname qcew "&qcewdir.";

%let interwrk=/temporary/lv39/opm-qa;
x mkdir -p &interwrk.;
libname INTERWRK "&interwrk";
