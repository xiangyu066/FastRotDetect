%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Title: BeadAssay.m
% - Author: XYZ
% - Created date: April 1, 2021
% - Modified date: June 25, 2021
% - Notes:
%       1.)
% - Next modified:
%       1.) determine the CCW and CW rotation 
% - Version: 2.0
% - Environments: Win10 (64-bit) / MATLAB 2019b (64-bit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all, warning('off')
disp('Running...')

%% define units
global Hz
Hz = 1;

%% define image processing parameters
inputfile       = 'C:\Users\XYZ\Downloads\New folder\20210625\Tethered cell test\VF\old LBS\RAM Sequence6-1.tif';
nFrames         = 300;
width           = 64;
height          = 64;
sampling        = 100 *(Hz);
binning         = 1;
gpu_mode        = false;
modulate_amp    = 6;
clustSize       = 10;
window          = nFrames/4;

%% read image data into memory
tic
database = zeros(height,width,nFrames);
for nFrame = 1:nFrames
    origina = double(imread(inputfile,nFrame));
    database(:,:,nFrame) = origina;
end
toc

%% ratation speed spectrum
% do FFT for all pixels with time
tic
spectrum = pixelFFT(database,binning,sampling,window,modulate_amp,gpu_mode);
toc

% clustering by mean-shift algorithm
tic
[y,x] = find(spectrum>0);
[clustCent,point2cluster,clustMembsCell] = MeanShiftCluster([x';y'],clustSize,false);
toc

% label raotation speed for clusters
nClusts = length(clustMembsCell);
clustSpeed = zeros(1,nClusts);
for nClust = 1:nClusts
    rows = y(point2cluster==nClust);
    cols = x(point2cluster==nClust);
    rotation_speed = 0;
    for m = 1:length(rows)
        rotation_speed = rotation_speed + spectrum(rows(m),cols(m));
    end
    clustSpeed(nClust) = rotation_speed/length(rows);
    clustSpeed_str{nClust} = num2str(rotation_speed/length(rows),'%.0f');
end

%% show calculation result and create annotation movie
LUT_up = mean(database(:))+3*std(database(:));
LUT_low = mean(database(:))-3*std(database(:));

% show rotation speed spectrum
figure(1), set(gcf,'WindowState','maximized')
subplot 211, imshow(max(database,[],3),[LUT_low,LUT_up]),  colorbar
hold on, plot(clustCent(1,:),clustCent(2,:),'ro')
title(['maximal projection image, ','numClust:' int2str(nClusts)])
subplot 212, imshow(spectrum,[]), colormap(gca,'hot'), colorbar
title('rotation speed spectrum')

% save annotation movie
vSession = VideoWriter('T_.avi');
vSession.FrameRate = sampling;
open(vSession);
figure(2),
for nFrame = 1:nFrames
    cla(gca), imshow(database(:,:,nFrame),[LUT_low,LUT_up])
    hold on, plot(clustCent(1,:),clustCent(2,:),'rs','markersize',20)
    hold on, text(clustCent(1,:)+10,clustCent(2,:)-30,clustSpeed_str,'color','r','fontweight','bold','fontsize',14)
    frame = getframe(gcf);
    writeVideo(vSession,frame);
    drawnow
end
close(vSession);

% show speed histogram
figure(3), histogram(clustSpeed,'Binwidth',1)
xlabel('rotation speed [Hz]'), ylabel('Count')

%%  check the siganl of individual pixel 
t = (0:nFrames-1)/sampling;
f = linspace(0,sampling/2,nFrames/2);
pt = database(37,46,:);
pt = pt(:);
pt0 = movmean(pt,window,1);
pt1 = pt-pt0;
mag = 2*(abs(fft(pt1))/length(pt1));

figure(4), set(gcf,'WindowState','maximized')
subplot 121, plot(t,pt,t,pt0,t,pt1), grid on, 
xlabel('time [sec]','fontweight','bold','fontsize',24), 
ylabel('Intensity','fontweight','bold','fontsize',24), 
legend({'raw','mean','substract'},'Location','best')
set(gca,'fontsize',16)
subplot 122, plot(f, mag(1:nFrames/2)), grid on
xlabel('frequency [Hz]','fontweight','bold','fontsize',24)
ylabel('modulation amplitude','fontweight','bold','fontsize',24)
set(gca,'fontsize',16)

%%
disp('Done.')
