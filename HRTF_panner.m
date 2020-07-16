clear all;clc;close all

%Load HRTF data
filename = "hrir_final.mat";
load(filename);

%Load audio source
filename_1 = 'Taylor Swift - Gorgeous (Lyric Video).wav';
[y,Fs] = audioread(filename_1);
y_freq = fft(y);

%Load RIR data
filename_2 = 's1_r1_b.wav';
[ry,rFs] = audioread(filename_2);

%Sound position
azm = -77;
elv =0;

%Interpolate HRIR
[hrir_L,hrir_R,itd]=interpolate_HRTF(azm,elv,hrir_l,hrir_r,ITD);

%Convolve sound with HRIR
[audio]=HRTF_sound(y,Fs,azm,hrir_L,hrir_R,itd,ry);

%Second sound position
azm = 20;
elv =0;

%Interpolate second HRIR
[hrir_L,hrir_R,itd]=interpolate_HRTF(azm,elv,hrir_l,hrir_r,ITD);

%Convolve second sound with HRIR
[audio2]=HRTF_sound(y,Fs,azm,hrir_L,hrir_R,itd);

%Padding to match sound lengths
len_diff=length(audio)-length(audio2);
zero_arr=zeros(2,abs(len_diff));
if len_diff>0
    audio2=cat(1,audio2,zero_arr');
else
    audio=cat(1,audio,zero_arr');
end

%Interpolating between sounds
amp(:,1)=cat(1,linspace(0,1,ceil(length(audio)/2))',linspace(1,0,floor(length(audio)/2))');
amp(:,2)=amp(:,1);

dist(:,1)=cat(1,linspace(1,10,ceil(length(audio)/2))',linspace(10,1,floor(length(audio)/2))');
dist(:,2)=dist(:,1);

%Writing sound to file
audio_out=rescale((audio.*amp+audio2.*(1-amp)),-1,1);
audio_out=rescale(audio./dist,-1,1);
audiowrite('test_output5.wav',audio_out,Fs)




