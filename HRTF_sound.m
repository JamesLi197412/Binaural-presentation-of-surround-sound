function [audio]=HRTF_sound(y,Fs,azm,hrir_L,hrir_R,itd,ry)
    
    %Separating sound into low and high ends
    F_pass=200;
    loPass = lowpass(y,F_pass,Fs);
    hiPass = highpass(y,F_pass,Fs);

    %Convolve high pass sound with HRIR
    conv_L = conv(hiPass,hrir_L(:),'full');
    conv_R = conv(hiPass,hrir_R(:),'full');

    %Convolve high pass sound with RIR
    %conv_L = conv(conv_L,ry(:,1));
    %conv_R = conv(conv_R,ry(:,2));

    %Add padding to low passs
    zero_arr=zeros(1,length(conv_L)-length(loPass));
    loPass=cat(1,loPass,zero_arr');

    %Combine high pass and low pass
    audio_L=conv_L+loPass;
    audio_R=conv_R+loPass;

    %Add ITD
    delay=round(Fs*itd/1000);

    %Match sound lengths for L and R channels
    zero_arr=zeros(1,delay);
    if azm<0
        audio_L=cat(1,audio_L,zero_arr');
        audio_R=cat(1,zero_arr',audio_R);
    else
        audio_R=cat(1,audio_R,zero_arr');
        audio_L=cat(1,zero_arr',audio_L);
    end
    
    %Return output
    audio=[audio_L,audio_R];
   
end