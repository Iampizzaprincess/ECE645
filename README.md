# ECE645
The main entry point to this code is the "codeTestbed.m" file. 
Above the "do not modify below" section, you will see some parameters you can change. 

sim: 'Turbo' or 'BCJR' (note: turbo works, but is not correct)
msgLength: specify the number of bits your message will be
sigma: specify the noise sigma. If a vector is entered, the program will iterate through all of the values
numIter: specify the number of runs. The error rate will be averaged for all the iterations
verbose: do you want the code to output messages? true, or false
plotOpt: if true, will plot useful BER  and CER curves
turboItr: number of iterations to perform in the turbo decoder. Hypothetically, 14-18 is good. 
