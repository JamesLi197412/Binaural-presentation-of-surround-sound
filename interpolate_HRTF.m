function [hrir_L,hrir_R,itd]=interpolate_HRTF(azm,elv,hrir_l,hrir_r,ITD)

    %Defining HRIR locations
    azimuths = [-80, -65, -55, -45:5:45, 55, 65, 80];
    elevations = [-45:5.625:230.625];  
    
    %Generating points
    for i=0:(length(azimuths)-1)
        for j=0:(length(elevations)-1)
            points(i*length(elevations)+j+1,:)=[azimuths(i+1),elevations(j+1)];
        end
    end
    
    %Triangulation of points
    triangles=delaunay(points);
    
    %Find triangle that the source location is located within
    g1 = ones(1,length(triangles));
    g2 = ones(1,length(triangles));
    g3 = ones(1,length(triangles));
    for i=1:length(triangles)
        A=points(triangles(i,1),:);
        B=points(triangles(i,2),:);
        C=points(triangles(i,3),:);
        T = [A(1)-C(1),A(2)-C(2),B(1)-C(1),B(2)-C(2)];
        invT=[T(4),-T(2),-T(3),T(1)];
        det=1/(T(1)*T(4)-T(2)*T(3));
        invT=invT*det;
        X=[azm-C(1),elv-C(2)];
        g1(i)=invT(1)*X(1)+invT(3)*X(2);
        g2(i)=invT(2)*X(1)+invT(4)*X(2);
        g3(i)=1-g1(i)-g2(i);
        if g1(i)>=0 && g2(i)>=0 && g3(i)>=0
            
            %Interpolate HRIR between vertices
            hrir_L=hrir_l(find(azimuths==A(1)),find(elevations==A(2)),:)*g1(i)+hrir_l(find(azimuths==B(1)),find(elevations==B(2)),:)*g2(i)+hrir_l(find(azimuths==C(1)),find(elevations==C(2)),:)*g3(i);
            hrir_R=hrir_r(find(azimuths==A(1)),find(elevations==A(2)),:)*g1(i)+hrir_r(find(azimuths==B(1)),find(elevations==B(2)),:)*g2(i)+hrir_r(find(azimuths==C(1)),find(elevations==C(2)),:)*g3(i);

            %Interpolate ITD between vertices
            itd=ITD(find(azimuths==A(1)),find(elevations==A(2)))*g1(i)+ITD(find(azimuths==B(1)),find(elevations==B(2)))*g2(i)+ITD(find(azimuths==C(1)),find(elevations==C(2)))*g3(i);
            
            %Original HRIR at each vertex for left ear
            orig_hrir_L1=hrir_l(find(azimuths==A(1)),find(elevations==A(2)),:);
            orig_hrir_L2=hrir_l(find(azimuths==B(1)),find(elevations==B(2)),:);
            orig_hrir_L3=hrir_l(find(azimuths==C(1)),find(elevations==C(2)),:);

            %Original HRIR at each vertex for right ear
            orig_hrir_R1=hrir_r(find(azimuths==A(1)),find(elevations==A(2)),:);
            orig_hrir_R2=hrir_r(find(azimuths==B(1)),find(elevations==B(2)),:);
            orig_hrir_R3=hrir_r(find(azimuths==C(1)),find(elevations==C(2)),:);

            break;
        end
       
    end
    
    %Plotting
    
    %Left Ear Comparsion ( Original Sound & Interpolated Sound )
    val_l=length(hrir_l(1,1,:))/2;
    xx_l=1:val_l;
    xx_l=xx_l*200/1000;
    % interpolated one
    yy_l(:)=hrir_L;
    % Original One
    % The left ears
    yyl_1(:)=orig_hrir_L1;
    yyl_2(:)=orig_hrir_L2;
    yyl_3(:)=orig_hrir_L3;
    % yy is SNR
    freq_l=fft(yy_l);

    freq_yyl_1 = fft(yyl_1);
    freq_yyl_2 = fft(yyl_2);
    freq_yyl_3 = fft(yyl_3);

    plot(xx_l,20*log10(freq_l(1:val_l)),'k');
    axis([0.020 20 -40 20])
    hold on
    plot(xx_l,20*log10(freq_yyl_1(1:length(xx_l))),"r")
    plot(xx_l,20*log10(freq_yyl_2(1:length(xx_l))),"b")
    plot(xx_l,20*log10(freq_yyl_3(1:length(xx_l))),"g")
    title("Left Ear");
    xlabel('Frequency (kHz)');
    ylabel("Relative Amplitude in dB");
    legend('Interpolated Frequency Response', 'Frequency Response Of Vertex 1', 'Frequency Response Of Vertex 2',' Frequency Response Of Vertex 3','Location','southwest')

    hold off

    %Right Ear analysis ( original and Interpolated signal comparsion)
    figure;
    val_r=length(hrir_r(1,1,:))/2;
    xx_r=1:val_r;
    xx_r=xx_r*200;  % Scale it
    % interpolated one
    yy_r(:)=hrir_R;
    % Original One
    % The left ears
    yyr_1(:)=orig_hrir_R1;
    yyr_2(:)=orig_hrir_R2;
    yyr_3(:)=orig_hrir_R3;
    % yy is SNR
    freq_r=fft(yy_r);
    freq_yyr_1 = fft(yyr_1);
    freq_yyr_2 = fft(yyr_2);
    freq_yyr_3 = fft(yyr_3);

    plot(xx_r,20*log10(freq_r(1:val_r)),'k');
    axis([20 20000 -40 20])
    legend("Interpolated Sound");
    hold on
    plot(xx_r,20*log10(freq_yyr_1(1:length(xx_r))),"r")
    plot(xx_r,20*log10(freq_yyr_2(1:length(xx_r))),"b")
    plot(xx_r,20*log10(freq_yyr_3(1:length(xx_r))),"g")
    title("Right Ear");
    xlabel('Frequency');
    ylabel("Relative Amplitude in dB");
    legend('Interpolated Frequency Response', 'Frequency Response Of Vertex 1', 'Frequency Response Of Vertex 2',' Frequency Response Of Vertex 3','Location','southwest')
    hold off


    %Combine Left and Right Ear sound (Original Sound)
    figure;
    plot(xx_l,20*log10(freq_l(1:val_l)),'b');
    hold on
    plot(xx_r,20*log10(freq_r(1:val_r)),'k');
    axis([20 20000 -60 20])
    legend('Interpolated Frequency Response for Left Ear','Interpolated Frequency Response for Right Ear')
    xlabel('Frequency')
    ylabel('Relative Amplitude in dB')
    title('Left Ear vs Right Ear');
    hold off
    
end