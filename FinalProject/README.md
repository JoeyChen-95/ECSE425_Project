# ECSE 425 Final Project: MIPS Pipeliend Processor

## Author
Chen, Byron ID: 
Chen, Junjian ID: 260909101
Tian, Zeying ID: 260917301
Xu, Hongtao ID: 260773785
Xun, Chenxin ID: 260887968
Zhang, Shichang ID: 260890019

## Introduction
VHDL description of a 5-stage MIPS pipeline implementing early branch resolution, forwarding, and hazard detection. This processor was implemented as a project deliverable for ECSE 425, Computer Organisation and Architecture.

## Requirement
The assembler requires EDA Playground to run which can be found [here](https://www.edaplayground.com/x/Ad6z).

## EDA Playground

### Setting

1. After opening the EDA Playground, firstly we need to select VHDL under Language & Libraries, and then enter our testbench name Controller_tb under Top Entity. 
2. Secondly, under Tool&Simulator, we selected the version Aldec Rivera Pro 2020.4, and the run time set as 200ns. We can select either “Open EPWave after run” or “Download files after run” for seeing the waves or download files.

### Uploading
1. We first upload the “Controller_tb.vhd” into the VHDL testbench area, which can be found under the [Unit Test](https://github.com/JoeyChen-95/ECSE425_Project/tree/main/FinalProject/Unit%20Tests) files. 
2. Then, we can upload all the vhd. codes from Pipelined Processor file into the VHDL design area. Noticed that benchmark files can be found under Test Programs to test our results.

### Run&Result
1. Now we are ready to click the Run button, we can select Open EPwave to see all the waves. As we can see, all the tests work. 
2. We can also select download files to download all the files.
