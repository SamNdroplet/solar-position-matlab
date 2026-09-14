%% Solar Position and Solar-Time Calculation for London
% This script calculates solar position and solar-time parameters for
% London over a complete year (365 days).
%
% The model calculates:
%   - Solar declination angle
%   - Sunset hour angle
%   - Sunrise and sunset times
%   - Daylight duration
%   - Equation of time
%   - Local-to-solar time correction
%   - Solar noon
%   - Solar altitude, zenith and azimuth angles
%   - Monthly solar-path curves
%
% Angles are expressed in degrees unless otherwise stated.

%% Location parameters

phi=51.51;% latitude of London [degrees]
Lloc=0.1278;%longitude of London[degrees]
Lst=0;%standard meridian is in Greenwich [degrees]
beta=0; % Surface inclination angle [degrees]

delta=zeros(365,1);
omega_s=zeros(365,1);
h=zeros(365,1);
min=zeros(365,1);
h_noon=zeros(365,1);
min_noon=zeros(365,1);
solar_noon=zeros(365,2);
ST_solarnoon=zeros(365,2);
sunset=zeros(365,2);
sunrise=zeros(365,2);
daylight=zeros(365,1);
Nh=zeros(365,1);
Nm=zeros(365,1);
B=zeros(365,2);
E=zeros(365,2);
K=zeros(365,2);
ST_sunrise=zeros(365,2);
ST_sunset=zeros(365,2);
%% Daily solar geometry calculations
for n=1:365
    % Solar declination angle for day n [degrees]
    delta(n,1)=23.45*sind(360*(284+n)/365);
    % Sunset hour angle [degrees]
    omega_s(n,1)=acosd(-tand(phi)*tand(delta(n,1)));
    % Convert sunset hour angle to hours and minutes
    h(n,1)=floor(omega_s(n,1)/15);
    min(n,1)=round(((omega_s(n,1)/15)-h(n,1))*60);
    % sunset
    sunset=[h+12 min];
    %sunrise
    if min==0
        sunrise=[12-h min];
    else
        sunrise=[11-h 60-min];
    end
    %daylight hours
    daylight(n,1)=(2/15)*acosd(-tand(phi)*tand(delta(n,1)));
    Nh(n,1)=floor(daylight(n,1));
    Nm(n,1)=round((daylight(n,1)-Nh(n,1))*6*10);
    N=[Nh Nm];
    % Day angle used in the equation-of-time calculation [degrees]
    B(n,2)=(n-1)*360/365;
    % Equation of time [minutes] 
    E(n,2)=22.92*(0.000075+0.001868*cosd(B(n,2))-0.032077*sind(B(n,2))-0.014615*cosd(2*B(n,2))...
        -0.04089*sind(2*B(n,2)));
    % Correction between local standard time and solar time [minutes]
    K(n,2)=4*(Lst-Lloc)+E(n,2);
    if round(sunrise(n,2)-K(n,2))<60 && round(sunrise(n,2)-K(n,2))>=0
        ST_sunrise(n,1)=sunrise(n,1);
        ST_sunrise(n,2)=round(sunrise(n,2)-K(n,2));
    elseif round(sunrise(n,2)-K(n,2))<0
        ST_sunrise(n,1)=sunrise(n,1)-1;
        ST_sunrise(n,2)=round(60+sunrise(n,2)-K(n,2));
    elseif round(sunrise(n,2)-K(n,2))>=60
        ST_sunrise(n,1)=sunrise(n,1)+1;
        ST_sunrise(n,2)=round((sunrise(n,2)-K(n,2))-60);
    end
    % solar time sunset
    if round(sunset(n,2)-K(n,2))<60 && round(sunset(n,2)-K(n,2))>=0
        ST_sunset(n,1)=sunset(n,1);
        ST_sunset(n,2)=round(sunset(n,2)-K(n,2));
    elseif round(sunset(n,2)-K(n,2))<0
        ST_sunset(n,1)=sunset(n,1)-1;
        ST_sunset(n,2)=round(60+sunset(n,2)-K(n,2));
    elseif round(sunset(n,2)-K(n,2))>=60
        ST_sunset(n,1)=sunset(n,1)+1;
        ST_sunset(n,2)=round((sunset(n,2)-K(n,2))-60);
    end
    h_noon(n,1)=floor(daylight(n,1)/2);
    min_noon(n,1)=round(((daylight(n,1)/2)-h_noon(n,1))*6*10);
    %solar noon
    solar_noon(:,1)=12;
    solar_noon(:,2)=0;
    
    if round(K(n,2))>=0
        ST_solarnoon(n,1)=12;
        ST_solarnoon(n,2)=round(solar_noon(n,2)+K(n,2));
    else
        ST_solarnoon(n,2)=round(60+K(n,2));
        ST_solarnoon(n,1)=11;
    end
    
    %     if ST_sunrise(n,2)+min_noon(n,1)<60 && ST_sunrise(n,2)+min_noon(n,1)>=0
    %         solar_noon(n,1)=ST_sunrise(n,1)+h_noon(n,1);
    %         solar_noon(n,2)=round(ST_sunrise(n,2)+min_noon(n,1));
    %        elseif ST_sunrise(n,2)+min_noon(n,1)>=60
    %        solar_noon(n,1)=ST_sunrise(n,1)+h_noon(n,1)+1;
    %        solar_noon(n,2)=round((ST_sunrise(n,2)+min_noon(n,1))-60);
    %     end
    
    
end


%% Solar position for representative days of each month
% Representative/average days are selected for the 12 months.
% Solar altitude, zenith and azimuth angles are calculated between
% sunrise and sunset for each representative day.
%select the average day of month
T_new=zeros(12,1);%zamani k az omega s be dast miyad
DELTA=zeros(12,1);
a=1;
for i=[17,47,75,105,135,162,198,228,258,288,318,344]
    DELTA(a)=delta(i,1);
    T_new(a)=omega_s(i,1)/15;
    a=a+1;
end
SUNRISE=12-T_new;%time of sunrise for the average day of month
SUNSET=12+T_new;%time of sunset for the average day of month
w=zeros(12);
alfa_s=zeros(12);
teta_z=zeros(12);
gamma_s=zeros(12);
numi=zeros(12,1);% # of matrix without zero for creating plot
a=1;
for j=1:12 %number of months
    for i=[SUNRISE(j)-12,ceil(SUNRISE(j))-12:floor(SUNSET(j))-12,SUNSET(j)-12]
        numi(j,1)=numel([SUNRISE(j)-12,ceil(SUNRISE(j))-12:floor(SUNSET(j))-12,SUNSET(j)-12]);
        w(a,j)=i*15; % each colum=# of month
	% Solar altitude angle [degrees]
        alfa_s(a,j)=asind((cosd(phi-beta)*cosd(DELTA(j,1))*cosd(w(a,j)))+(sind(phi-beta)*sind(DELTA(j,1))));
	% Solar zenith angle [degrees]
        teta_z(a,j)=90-abs(alfa_s(a,j));
	% Solar azimuth angle [degrees]
        gamma_s(a,j)=sign(w(a,j))*abs(acosd(((cosd(teta_z(a,j))*sind(phi))-sind(DELTA(j,1)))/(sind(teta_z(a,j))*cosd(phi))));
        a=a+1;
        if i==SUNSET(j)-12
            a=1;
        end
    end
end

% seperate matrix for creating plot
for i=1:12
    eval(sprintf('alfa_s%d = alfa_s(1:numi(i,1),i)', i));
    eval(sprintf('gamma_s%d = gamma_s(1:numi(i,1),i)', i));
    eval(sprintf('teta_z%d = teta_z(1:numi(i,1),i)', i));
end

plot(gamma_s1,alfa_s1,gamma_s2,alfa_s2,'y',gamma_s3,alfa_s3,'y--',gamma_s4,alfa_s4,...
  'm',  gamma_s5,alfa_s5,'m--',gamma_s6,alfa_s6,'c',gamma_s7,alfa_s7,'c--',gamma_s8,alfa_s8,...
   'g', gamma_s9,alfa_s9,'g--',gamma_s10,alfa_s10,'b',gamma_s11,alfa_s11,gamma_s12,alfa_s12,'b--')
legend('Jan 17','Feb 16','Mar 16','Apr 15','May 15','Jun 11','Jul 17','Aug 16','Sep 15','Oct 15','Nov 14','Dec 10')

axis([-150  150    0  80])
xlabel({'Solar Azimuth Angle',' gamma_s'})
ylabel({'Solar Altitude Angle',' alfa_s'})
title('Solar Position plot for London')
