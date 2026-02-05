%% User mode of bell_exp_cont
% Jan 13, 2026
% program to take bell data
% 0.  enter name of output file, .txt will be appeneded, program terminates
%    if file exists
% 1.  set number of measurements per angle pair (1 sec duration)
% 2.  enter polarizer angle A
% 3.  enter polarizer angle B,
% 4.  enter more polarizer B angles, enter 999 to enter new Polarizer A
%    angle
% 5.  enter new polarizer A angle, and continue steps 2-4
% 6.  enter 999 to polarizer A angle to stop program
 
 
%% Minimal C.R.M. 114 Discriminator Bell inequality panel control and data acquisition program
%
%% Oct. 9, 2025 Steven K. Lamoreaux, Yale Physics PHY382
%
% See manual and chip datasheets for explanations
%
% This program reads and writes to a National Instruments USB-6501 digital input/output device
%
%% USB-6501 Connections described below
%
% Operations in the code will be refered to the comment numbers below 
% 
% P0.0 to P0.7 and P1.0 to P1.7 are input lines
% (P0 and P1 are read together as 16 bits in a vector array) 
%
% P2.0 to P2.7 are output lines  
%
%% 1. input line 9 reads acquisition status (high means counters are active)  (P1.0)
%
%% 2. input line 10 reads prescaler setting (P1.1)
%
%% 3. time to complete data cycle allows determination of clock time setting (0.1 or 1 sec)
%
%% 4. output line 3 brought high then low triggers counter cycle (P2.3)
%
%% 5. output lines 0,1,2 select counter registers (P2.0, P2.1, P2.2) via 3 to 8 line decoder, 
%    74LS138 TTL integrated circuit
%
%% 6. input lines 0-7 read counter register outputs (P0.0 to P0.7) (two 8 bit registers per 16 bit counter)
%     which for four counters requires 8 total read requests which require register selection (comment 5)
%     counters simultaneously collect counts for the cycle time (0.1 or 1 sec)
%
%% 7. The maximum count is set by 16 bits to 64k, so the prescaler can be used on channels A and B.
%     The coincidence rate is low enough to not be of concern.  The prescaler divides the A and B counts
%     by four, but does nothing to the coincidence channel 
%
%% 8. The counts per cycle time are recorded by two 74LV8154 dual 16 bit counters. The data for each
%    counter is presented in 8 bit segments, externally addressed per comment 5 above 
%    "A" counts go to first 74LV8154 counter 1, registers 0 and 1
%    and on same IC, "B" counts go to counter 2, registers 2 and 3
%    "Coincidence counts" go to second 74LV8154, counter 1 registers 0 and 1  (mapped to 4 and 5 
%    from 74LS138)
%
%% 9. 100 kHz time base signal goes to counter 2, registers 3 and 4. (mapped to 6 and 7 from 74LS138)
%  This counter will overload for 1 sec, so it is corrected by adding on 2^{16} when 1 sec cycle time
%   is detected
%
% The time base for the displayed panel counter is not synchronized by the same clock so the counts will
% be different
%
%% 10. Data from the USB-6501 is brought over as a 16 by 1 numeric matrix, containing 0 and 1 corresponding
%  to 2^n weighting for the counts, which must be added up
 
d = daq("ni");
addinput(d,"Dev1","Port0/Line0:7","Digital");
addinput(d,"Dev1","Port1/Line0:7","Digital");
addoutput(d,"Dev1","Port2/Line0:7","Digital");
tdelay=0.001;
% prepare data session, reset counters
% the only way to do this is to initiate a count sequence (comment 3)
startTime=tic;
write(d,[0, 0, 0, 0, 0, 0, 0, 0]);
    tnow=DelayTime(startTime,tdelay);
%% trigger conversion (comment 4)
write(d,[0, 0, 0, 1, 0, 0, 0, 0]);
    tnow=DelayTime(startTime,tdelay);
write(d,[0, 0, 0, 0, 0, 0, 0, 0]);
%% delay and record start time
    tnow=DelayTime(startTime,tdelay);
x=1;
%% wait for low busy signal (comment 1)
while x==1
hData = (read(d,"OutputFormat","Matrix"));
x=hData(9);
end
%%
%% the time to complete this operation is a measure of the acquisition time setting (comment 3)
%% determine time base
%% choices are 0.1 or 1
if  toc(startTime)-tnow>0.5
    tbase=1;
    tmult=1;
else
    tbase=0.1;
    tmult=0;
end
%% determine prescale setting 
prescale=hData(10);
if prescale==0
    divide=1;
else
    divide=4;
end
 
%% start user input for controlled acquisition
 
prompt = 'Enter the name for the output file (without extension): ';
 
baseFileName = input(prompt, 's');
 
%  Make it a text file
 
fullFileName = [baseFileName, '.txt'];
% check if file exists so not overwritten
if isfile(fullFileName)
    return
end
%  Open the file for writing ('wt' for write in text mode)
fid = fopen(fullFileName, 'wt');
 
% Check if the file was opened successfully
if fid == -1
    error('Cannot open file: %s', fullFileName);
end
 
prompt='input number of measurements per angle pair ';
npts=input(prompt);
 
prompt1='enter theta1 (end=999) ';
prompt2='enter theta2 (end=999) ';
 
theta1=input(prompt1)
 
 
while theta1~=999
    %input next theta2
theta2=input(prompt2) 
   
while theta2~=999
   
startTime=tic;
for j=1:npts
    tdelay=0.001;
    %% delay to make sure i/o recovered from last operation
    tnow=DelayTime(startTime,tdelay);
    %% trigger counting cycle
write(d,[0, 0, 0, 1, 0, 0, 0, 0]);
    tnow=DelayTime(startTime,tdelay);
write(d,[0, 0, 0, 0, 0, 0, 0, 0]);
     tnow=DelayTime(startTime,tdelay);
x=1;
%% wait for low busy
while x==1
hData = (read(d,"OutputFormat","Matrix"));
x=hData(9);
end
%
%% bring in A counts
%% write counter address to 74LS138
%
write(d,[0, 0, 0, 0, 0, 0, 0, 0]);
hData = (read(d,"OutputFormat","Matrix"));
val(1)=hData(1)+hData(2)*2+hData(3)*4+hData(4)*8+hData(5)*16+hData(6)*32+hData(7)*64+128*hData(8);
write(d,[1, 0, 0, 0, 0, 0, 0, 0]);
hData = (read(d,"OutputFormat","Matrix"));
% data from USB 6501 is brought over as a 16 bit vector 
val(1)=val(1)+hData(1)*2^8+hData(2)*2^9+hData(3)*2^10+hData(4)*2^11+hData(5)*2^12+hData(6)*2^13+hData(7)*2^14+hData(8)*2^15;
%
% Multiply by 4 if prescale is on
%
val(1)=val(1)*divide;
%
%% Bring in B counts
%
write(d,[0, 1, 0, 0, 0, 0, 0, 0]);
hData = (read(d,"OutputFormat","Matrix"));
val(2)=hData(1)+hData(2)*2+hData(3)*4+hData(4)*8+hData(5)*16+hData(6)*32+hData(7)*64+128*hData(8);
write(d,[1, 1, 0, 0, 0, 0, 0, 0]);
hData = (read(d,"OutputFormat","Matrix"));
val(2)=val(2)+hData(1)*2^8+hData(2)*2^9+hData(3)*2^10+hData(4)*2^11+hData(5)*2^12+hData(6)*2^13+hData(7)*2^14+hData(8)*2^15;
write(d,[0, 0, 1, 0, 0, 0, 0, 0]);
%
%% multiply by 4 if prescale is on
%
val(2)=val(2)*divide;
%
%% bring in coincidence counts
%
hData = (read(d,"OutputFormat","Matrix"));
val(3)=hData(1)+hData(2)*2+hData(3)*4+hData(4)*8+hData(5)*16+hData(6)*32+hData(7)*64+128*hData(8);
write(d,[1, 0, 1, 0, 0, 0, 0, 0]);
hData = (read(d,"OutputFormat","Matrix"));
val(3)=val(3)+hData(1)*2^8+hData(2)*2^9+hData(3)*2^10+hData(4)*2^11+hData(5)*2^12+hData(6)*2^13+hData(7)*2^14+hData(8)*2^15;
write(d,[0, 1, 1, 0, 0, 0, 0, 0]);
%
%% bring in 100 kHz clock counts
%
hData = (read(d,"OutputFormat","Matrix"));
val(4)=hData(1)+hData(2)*2+hData(3)*4+hData(4)*8+hData(5)*16+hData(6)*32+hData(7)*64+hData(8)*128;
write(d,[1, 1, 1, 0, 0, 0, 0, 0]);
%pause(.01)
hData = (read(d,"OutputFormat","Matrix"));
%
%% add 2^16 if cycle time is one second, to account for overflow
%
val(4)=val(4)+tmult*2^16+hData(1)*2^8+hData(2)*2^9+hData(3)*2^10+hData(4)*2^11+hData(5)*2^12+hData(6)*2^13+hData(7)*2^14+hData(8)*2^15;
val
tend=toc(startTime)
fprintf(fid, '%6.2f %6.2f %6i %6i %6i %6i\n',theta1,theta2,val);
end
%input next theta2
theta2=input(prompt2) 
 
end
 
%input next theta1
theta1=input(prompt1)
end
clear d
% Close the file
fclose(fid);
disp(['Successfully wrote data to ', fullFileName]);
 
 
 
function tnow=DelayTime(startTime,tdelay)
tnow=toc(startTime);
while toc(startTime)-tnow<tdelay  
end
end
return