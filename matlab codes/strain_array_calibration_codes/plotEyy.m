%plotting
%plot Eyy

InputFile1 = input('First File [00MTotal]: ', 's');
load(InputFile1)
%Sparse the input strain tensor into matrix 
Exx = [E(4:6,:);
    E(13:15,:);
    E(22:24,:);
    E(31:33,:)];

%Plot strain and the variation of the strain at the pressure of 15 kPa at the different post sizes 
figure
hold on
for i=0:3
errorbar(PressureStep,Exx(i*3+1:i*3+3,9),Exx(i*3+1:i*3+3,10),color(i+1,:))
end

xlabel('pressure [kPa]')
ylabel('strain ')
legend('2.5mm','2.0mm','1.5mm','1.0mm')
title(['Eyy(Ett) at ' InputFile1(1:3)])