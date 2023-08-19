name='xxx';

[~,~,data] = xlsread(strcat(name,'_anfas.csv')) ;
[~,~,s] = xlsread(strcat(name,'.csv')) ;
T = table2cell(podaci);
t = cell2mat(T(:,1));
ecg = cell2mat(T(:,1));
T = table2cell(xxx);
s = cell2mat(T(:,1));
fs = 1000;
fps = 60;
t = t/fs;
time = 1:1:length(s);
time = time/fps;
max_duzina=12600;

%% prikaz signala temperature

figure
plot(time,s)
grid on
xlabel('vrijeme [s]')
ylabel('temperatura [^{\circ}C]')
title('Promjena temperature ROI tokom vremena')
xlim([30,50])

%% ecg signal filtration

% notch
wo = 50/(fs/2);  
bw = wo/35;
[b,a] = iirnotch(wo,bw);
ecgf = filter(b,a, ecg);

% baseline removal
[C, L] = wavedec (ecgf,8,'bior3.7'); 
a = wrcoef ('a', C, L,'bior3.7',8); 
d8 = wrcoef ('d', C, L,'bior3.7',8);
d7 = wrcoef ('d', C, L,'bior3.7',7);
d6 = wrcoef ('d', C, L,'bior3.7',6);
d5 = wrcoef ('d', C, L,'bior3.7',5);
d4 = wrcoef ('d', C, L,'bior3.7',4);
d3 = wrcoef ('d', C, L,'bior3.7',3);
d2 = wrcoef ('d', C, L,'bior3.7',2);
d1 = wrcoef ('d', C, L,'bior3.7',1);
ecgf= d8+d7+d6+d5+d4+d3+d2+d1;

%%
figure
plot(t,ecg)
hold all
plot(t,ecgf)
grid on;
xlabel(['vrijeme [s]'])
ylabel(['EKG [uV]'])
title('Filtracija EKG signala')
legend('originalana','filtriran')
xlim([0,20])

%%
figure
plot(time,10000*sf)
hold all
plot(t,ecgf)
grid on;
xlabel(['vrijeme [s]'])
title('EKG i signal temperature')
legend('izdvojen filtriran signal','EKG')
xlim([15,30])

%%
figure
plot(s)
hold all
plot(sf)

%% filtration of temperature signal

Wn=[1 1.66]/(fps/2);
[b,a]=butter(5,Wn,'bandpass');
sf=filter(b,a,s);

%% estimacija pulsa na osnovu ecg-a

puls_ecg=[];
k=50;
pocetak = 1;
kraj = pocetak;
pp = 0;
duzina = 500;
for j=0:20
    while(t(kraj)<(j+1)*10)
        kraj = kraj+1;
	if kraj == 12600
            break
        end
    end
    [Pks,locs]=findpeaks(ecgf(pocetak:kraj),'MinPeakHeight',k/100*max(ecgf(pocetak:kraj)));
    if length(locs)>1
        puls_ecg=[puls_ecg,length(Pks)/10*60];
    end
    pp = pocetak;
    pocetak = kraj;
    if pocetak == 12600
        break
    end
end

%% estimation Hr based on temperature signal

puls_estimated = [];
for j=0:20
    [Pks1,locs1]=findpeaks(sf(1+j*10*fps:(j+1)*10*fps));
    locs=[locs1(1)];
    Pks=[Pks1(1)];
    for i=2:length(Pks1)
        if locs1(i)-locs1(i-1)>30
            Pks=[Pks,Pks1(i)];
            locs=[locs,locs1(i)];
        end 
    end
    puls_estimated = [puls_estimated, length(Pks)/10/fps*60*60];
end

%% filtriranje

Wn=[12/60 30/60]/(fps/2);
[b,a]=butter(4,Wn,'bandpass');
sf=filter(b,a,s);

figure
plot(time,sf)
grid on
xlabel('vrijeme [s]')
ylabel('temperatura [^{\circ}C]')
title('Filtriran signal temperature 0.2- 0.5 Hz')
xlim([30,60])


%% estimacija BR na osnovu signala temperature

br_estim=[];
k=50;
pocetak = 1;
kraj = pocetak;
pp = 0;
duzina = 500;
t = time;
for j=0:20
    while(t(kraj)<(j+1)*20)
        if kraj == 12600
            break
        end
        kraj = kraj+1;
    end
    [Pks,locs]=findpeaks(sf(pocetak:kraj));
    if length(locs)>1
        br_estim=[br_estim,length(Pks)/20*60];
    end
    pp = pocetak;
    pocetak = kraj;
    if pocetak == 12600
        break
    end
end

br_estim



