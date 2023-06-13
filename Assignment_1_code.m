clear;
close all;
% -----------------Requirement 3------------------
x =-6:0.01:6;
n_bits = 3;
xmax = 6;
% mid-tread
m = 1;
y=UniformQuantizer(x,n_bits,xmax,m);
y_deq=UniformDequantizer(y,n_bits, xmax, m);
plotFourOutput(x,x,x,y,x,y_deq,x,x.*0,"mid-tread","input","output")
legend('original','quantizied','dequantizied');
% mid-rise
m=0;
y=UniformQuantizer(x,n_bits,xmax,m);
y_deq=UniformDequantizer(y,n_bits,xmax,m);
plotFourOutput(x,x,x,y,x,y_deq,x,x.*0,"mid-rise","input","output")
legend('original','quantizied','dequantizied');
% ------------------Requirement 4---------------------
sim_snr=[];
thr_snr=[];
x = random('Uniform',-5,5,1,10000);
xmax=max(abs(x));
m=0;
for n_bits= 2:1:8
y=UniformQuantizer(x,n_bits,xmax,m);
y_deq = UniformDequantizer(y, n_bits, xmax, m);
error=abs(x-y_deq);
sim_snr = [sim_snr, mean(x.^2)/mean(error.^2)];
scale=(3*((2^n_bits)^2))/(xmax^2);
thr_snr = [thr_snr, scale*mean(x.^2)];
end
n_bits= 2:1:8;
plotTwoOutput(n_bits,mag2db(sim_snr),n_bits,mag2db(thr_snr),"SNR(4)","n-bits","snr")
legend('sim','thr');
% ------------------Requirement 5---------------------
sim_snr=[];
thr_snr=[];
size = [1 10000];
x_exp = exprnd(1,size);
sign = (randi([0,1],size)*2)-1;
x = x_exp.*sign;
xmax=max(abs(x));
m=0;
for n_bits= 2:1:8
y=UniformQuantizer(x,n_bits,xmax,m);
y_deq = UniformDequantizer(y, n_bits, xmax, m);
error=abs(x-y_deq);
sim_snr = [sim_snr, mean(x.^2)/mean(error.^2)];
scale=(3*((2^n_bits)^2))/(xmax^2);
thr_snr = [thr_snr, scale*mean(x.^2)];
end
n_bits= 2:1:8;
plotTwoOutput(n_bits,mag2db(sim_snr),n_bits,mag2db(thr_snr),"SNR(5)","n-bits","snr")
legend('sim','thr');
% ------------------Requirement 6---------------------
figure();
x_norm=x/xmax;
c={"r",'g','b','m'};
i=1;
for mu=[0, 5, 100,200]
sim_snr=[];
thr_snr=[];
if(mu~=0)
x_comp = Compression(x_norm,mu,sign);
else
x_comp=x;
end
ymax=max(abs(x_comp));
for n_bits= 2:1:8
y = UniformQuantizer(x_comp, n_bits,ymax, m);
y_deq = UniformDequantizer(y, n_bits, ymax, m);
if(mu~=0)
y_expand = Expansion(y_deq,mu,sign);
y_deq = y_expand *xmax;
end
error=abs(x-y_deq);
sim_snr = [sim_snr, mean(x.^2)/mean(error.^2)];
if(mu~=0)
scale=(3*((2^n_bits)^2));
thr_snr = [thr_snr,scale/((log(1+mu))^2)];
else
scale=(3*((2^n_bits)^2))/(xmax^2);
thr_snr = [thr_snr, scale*mean(x.^2)];
end
end
n_bits= 2:1:8;
% plotTwoOutput(n_bits,mag2db(sim_snr),n_bits,mag2db(thr_snr),strcat('SNR(6) mu= ',
% num2str(mu)),"n-bits","snr");
% legend('sim','thr');
plot(n_bits,mag2db(sim_snr),'-','color',c{i})
hold on
plot(n_bits,mag2db(thr_snr),'--','color',c{i})
title("SNR (6)")
xlabel("n-bits")
ylabel("snr")
i=i+1;
end
legend('sim mu=0','thr mu=0','sim mu=5','thr mu=5','sim mu=100','thr mu=100','sim mu=200','thr
mu=200');
% -----------------------Requirement 1----------------
function q_ind = UniformQuantizer(in_val, n_bits, xmax, m)
levels = 2 ^ n_bits;
delta = 2 * xmax / levels;
q_ind = floor((in_val - ((m) * (delta / 2) - xmax)) / delta);
q_ind(q_ind<0) = 0;
end
% ----------------------Requirement 2-----------------
function deq_val = UniformDequantizer(q_ind, n_bits, xmax, m)
levels = 2 ^ n_bits;
delta = 2 * xmax / levels;
deq_val = ((q_ind) * delta) + ((m+1) * (delta / 2) - xmax);
end
% ------------------ plotting functions --------------
function plotTwoOutput(x1,y1,x2,y2,label,labelx,labely)
figure();
plot(x1,y1)
hold on
plot(x2,y2)
hold off
title(strcat(label, ""))
xlabel(strcat(labelx, ""))
ylabel(strcat(labely, ""))
end
function plotFourOutput(x1,y1,x2,y2,x3,y3,x4,y4,label,labelx,labely)
figure();
plot(x1,y1)
hold on
plot(x2,y2)
plot(x3,y3)
plot(x4,y4)
hold off
title(strcat(label, ""))
xlabel(strcat(labelx, ""))
ylabel(strcat(labely, ""))
end
% ------------------- For Requirement 6---------------------
function y = Compression(x, u, sign)
y=sign .* (log(1+u*abs(x))/log(1+u));
end
function y = Expansion(x, u, sign)
y= sign .*(((1+u).^abs(x)-1)/u);
end