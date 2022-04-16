# ECSE 425 Final Project: MIPS Pipeliend Processor

## Author

Chen, Byron ID: 260892558

Chen, Junjian ID: 260909101

Tian, Zeying ID: 260917301

Xu, Hongtao ID: 260773785

Xun, Chenxin ID: 260887968

Zhang, Shichang ID: 260890019

## Introduction
VHDL description of a 5-stage MIPS pipeline implementing early branch resolution, forwarding, and hazard detection. This processor was implemented as a project deliverable for ECSE 425, Computer Organisation and Architecture.

The directory "Pipeline Processor" includes all components of the processor.

The directory "Unit Tests" includes all individual unit tests of each component.

The directory "Test programs" includes 2 given benchmarks.

For more detail, please refer to our project report.



## Requirement
Since our program is run on EDA playground instead of Quartus and ModelSim, we do not submit the tcl file. EDA Playground can be accessed [here](https://www.edaplayground.com/home). To use EDA playground, the computer has to connect to the Internet.

Our program can be viewed and run in the following link: [ECSE425 Group11 Final Project](https://www.edaplayground.com/x/Ad6z)

## Program Running

### Setting

1. After opening the EDA Playground, firstly we need to select VHDL under Language & Libraries, and then enter our testbench name *Controller_tb* under Top Entity. 
2. Secondly, under Tool&Simulator, we selected the version Aldec Rivera Pro 2020.4, and the run time set as 1500ns(larger program may need longer run time). We need to select “Download files after run” to obtain the result files.

### Uploading
1. We need to upload all the files in the "Pipelined Processor" directory. It includes all necessary VHDL componenets of the processor.
2. For the testbench, upload the binary testbench code, named as "program.txt". In addition, you need to create two empty files named as "register_file.txt" and "memory.txt" (The test result is stored in these two files). The binary testbench code can be generated from MIPS assmebly by using the given assembler. 

### Run and Result
1. Click "Run"
2. The results are included in a zip file. Unzipped the zip file and the results can be viewed in "memory.txt" and "register_file.txt". 
**Warning: Turn off the auto block pop-up of your browser. Otherwise the download will fail.**
