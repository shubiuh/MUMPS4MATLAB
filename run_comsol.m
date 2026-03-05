import com.comsol.model.*
import com.comsol.model.util.*

model=mphload('MD140.0_Mx_total_solved_coarse_mef.mph');

try
    model.geom('geom1').run;
catch ErrInfo
    disp(ErrInfo.message);
end
model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 1);
model.mesh('mesh1').run;

model.study("std1").run();
str = mphmatrix(model, 'sol1', 'out',{'K','L','M','N'});
figure(1);
subplot(1,2,1); spy(str.K);
Q = sum(str.L);

str1 = mphmatrix(model,'sol1','out',{'Kc','Dc','Ec','Lc'});
subplot(1,2,1); hold on; spy(str1.Kc,'r');

f_str = char(model.param.get('freq1')); 
f = str2double(f_str);
omega = 2 * pi * f;
A = str1.Kc + 1i * omega * str1.Dc - (omega^2) * str1.Ec;
b = str1.Lc;
info = mphxmeshinfo(model,'soltag','sol1','studysteptag','v1');
[stats,data] = mphmeshstats(model);

X = A\str1.Lc;