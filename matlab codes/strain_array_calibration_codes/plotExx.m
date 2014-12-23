%plotting function
%plot Exx
InputFile1 = input('First File [00MTotal]: ', 's');
load(InputFile1)

%Sparse the input strain tensor into matrix 
Exx = [E(1:3,:);
E(10:12,:);
E(19:21,:);
E(28:30,:)];

%Define the pressure step 
PressureStep = [10 15 20];
figure
hold on
color = ['b-';'r-';'k-';'g-'];

%Plot strain and the variation of the strain at the pressure ranging from 0, 5, 10, to 15 kPa
for i =0:3
errorbar(PressureStep,Exx(i*3+1:i*3+3,1),Exx(i*3+1:i*3+3,2),color(i+1,:))
errorbar(PressureStep,Exx(i*3+1:i*3+3,3),Exx(i*3+1:i*3+3,4),color(i+1,:))
errorbar(PressureStep,Exx(i*3+1:i*3+3,5),Exx(i*3+1:i*3+3,6),color(i+1,:))
errorbar(PressureStep,Exx(i*3+1:i*3+3,7),Exx(i*3+1:i*3+3,8),color(i+1,:))
end
xlabel('pressure [kPa]')
ylabel('strain ')

%Plot strain and the variation of the strain at the pressure of 15 kPa at the different post sizes 
figure
hold on
for i=0:3
errorbar(PressureStep,Exx(i*3+1:i*3+3,9),Exx(i*3+1:i*3+3,10),color(i+1,:))
end
xlabel('pressure [kPa]')
ylabel('strain ')
legend('2.5mm','2.0mm','1.5mm','1.0mm')
