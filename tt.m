function out = model
%
% tt.m
%
% Model exported on Mar 3 2026, 16:08 by COMSOL 6.4.0.293.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\shubi\Downloads\comaglib-mumps4matlab_windows_openmp-9ad2150');

model.label('UDAR_COMSOL_unparallel_fine.mph');

model.title('TITL COMSOL unparallel');

model.param.set('Dip', '45', 'dip angle');
model.param.set('RC', '20[ft]', 'radius of computational domain');
model.param.set('Rh_1', '10[ohm*m]', 'Rh of upper layer');
model.param.set('Rh_0', '10[ohm*m]', 'Rh of local layer');
model.param.set('Rh_2', '1[ohm*m]', 'Rh of lower layer');
model.param.set('Rv_1', '20[ohm*m]', 'Rv of upper layer');
model.param.set('Rv_0', '20[ohm*m]', 'Rv of local layer');
model.param.set('Rv_2', '1[ohm*m]', 'Rv of lower layer');
model.param.set('DTB_1', '2[ft]', 'distance to upper bed');
model.param.set('DTB_2', '2[ft]', 'distance to lower bed');
model.param.set('freq1', '2e6', 'working frequency');
model.param.set('T_x', '0[m]', 'Transmitter coordinate x');
model.param.set('T_y', '0[m]', 'Transmitter coordinate y');
model.param.set('T_z', '0[m]', 'Transmitter coordiante z');
model.param.set('R1_x', '1[m]', 'R1 X');
model.param.set('R1_y', '1[m]', 'R1 Y');
model.param.set('R1_z', '1[m]', 'R1 Z');
model.param.set('R2_x', '2[m]', 'R2 X');
model.param.set('R2_y', '2[m]', 'R2 Y');
model.param.set('R2_z', '2[m]', 'R2 Z');
model.param.set('r_loop', '0.3[inch]', 'radius of loop transmitter and receiver');
model.param.set('Ix', '1', 'Ix for loop');
model.param.set('Iy', '1', 'Iy for loop');
model.param.set('Iz', '1', 'Iz for loop');
model.param.set('mx', '1', 'mx for point dipole');
model.param.set('my', '1', 'my for point dipole');
model.param.set('mz', '1', 'mz for point dipole');
model.param.set('dip_LB', '0', 'slant angle of lower bed');
model.param.set('Sxx_1', '10[S/m]');
model.param.set('Sxy_1', '10[S/m]');
model.param.set('Sxz_1', '10[S/m]');
model.param.set('Syx_1', '10[S/m]');
model.param.set('Syy_1', '10[S/m]');
model.param.set('Syz_1', '10[S/m]');
model.param.set('Szx_1', '10[S/m]');
model.param.set('Szy_1', '10[S/m]');
model.param.set('Szz_1', '10[S/m]');
model.param.set('Sxx_0', '10[S/m]');
model.param.set('Sxy_0', '10[S/m]');
model.param.set('Sxz_0', '10[S/m]');
model.param.set('Syx_0', '10[S/m]');
model.param.set('Syy_0', '10[S/m]');
model.param.set('Syz_0', '10[S/m]');
model.param.set('Szx_0', '10[S/m]');
model.param.set('Szy_0', '10[S/m]');
model.param.set('Szz_0', '10[S/m]');
model.param.set('Sxx_2', '10[S/m]');
model.param.set('Sxy_2', '10[S/m]');
model.param.set('Sxz_2', '10[S/m]');
model.param.set('Syx_2', '10[S/m]');
model.param.set('Syy_2', '10[S/m]');
model.param.set('Syz_2', '10[S/m]');
model.param.set('Szx_2', '10[S/m]');
model.param.set('Szy_2', '10[S/m]');
model.param.set('Szz_2', '10[S/m]');

model.component.create('mod1', false);

model.component('mod1').geom.create('geom1', 3);

model.component('mod1').label('Model 1');

model.component('mod1').defineLocalCoord(false);

model.component('mod1').curvedInterior(false);

model.result.table.create('tbl1', 'Table');
model.result.table.create('tbl2', 'Table');

model.component('mod1').mesh.create('mesh1');

model.component('mod1').geom('geom1').geomRep('comsol');
model.component('mod1').geom('geom1').repairTolType('relative');
model.component('mod1').geom('geom1').create('blk1', 'Block');
model.component('mod1').geom('geom1').feature('blk1').set('size', {'3*RC' '3*RC' '3*RC'});
model.component('mod1').geom('geom1').feature('blk1').set('pos', {'-1.5*RC+T_x' '-1.5*RC+T_y' '-DTB_2+T_z'});
model.component('mod1').geom('geom1').create('blk2', 'Block');
model.component('mod1').geom('geom1').feature('blk2').set('size', {'3*RC' '3*RC' '3*RC'});
model.component('mod1').geom('geom1').feature('blk2').set('pos', {'-1.5*RC+T_x' '-1.5*RC+T_y' '-3*RC-DTB_2+T_z'});
model.component('mod1').geom('geom1').create('uni1', 'Union');
model.component('mod1').geom('geom1').feature('uni1').selection('input').set({'blk1' 'blk2'});
model.component('mod1').geom('geom1').create('rot1', 'Rotate');
model.component('mod1').geom('geom1').feature('rot1').set('axis', [1 0 0]);
model.component('mod1').geom('geom1').feature('rot1').set('rot', 'dip_LB');
model.component('mod1').geom('geom1').feature('rot1').set('pos', {'0' '0' '-DTB_2'});
model.component('mod1').geom('geom1').feature('rot1').selection('input').set({'uni1'});
model.component('mod1').geom('geom1').create('sph1', 'Sphere');
model.component('mod1').geom('geom1').feature('sph1').set('r', 'RC');
model.component('mod1').geom('geom1').feature('sph1').set('pos', {'T_x' 'T_y' 'T_z'});
model.component('mod1').geom('geom1').create('int1', 'Intersection');
model.component('mod1').geom('geom1').feature('int1').selection('input').set({'rot1' 'sph1'});
model.component('mod1').geom('geom1').create('blk3', 'Block');
model.component('mod1').geom('geom1').feature('blk3').set('size', {'3*RC' '3*RC' '3*RC'});
model.component('mod1').geom('geom1').feature('blk3').set('pos', {'-1.5*RC+T_x' '-1.5*RC+T_y' 'DTB_1+T_z'});
model.component('mod1').geom('geom1').create('co1', 'Compose');
model.component('mod1').geom('geom1').feature('co1').set('formula', 'int1+int1*blk3');
model.component('mod1').geom('geom1').create('pc1', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc1').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc1').set('coord', {'0' 'r_loop*cos(s)' 'r_loop*sin(s)'});
model.component('mod1').geom('geom1').feature('pc1').set('pos', {'T_x' 'T_y' 'T_z'});
model.component('mod1').geom('geom1').create('pc2', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc2').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc2').set('coord', {'r_loop*sin(s)' '0' 'r_loop*cos(s)'});
model.component('mod1').geom('geom1').feature('pc2').set('pos', {'T_x' 'T_y' 'T_z'});
model.component('mod1').geom('geom1').create('pc3', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc3').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc3').set('coord', {'r_loop*cos(s)' 'r_loop*sin(s)' '0'});
model.component('mod1').geom('geom1').feature('pc3').set('pos', {'T_x' 'T_y' 'T_z'});
model.component('mod1').geom('geom1').create('pc4', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc4').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc4').set('coord', {'0' 'r_loop*cos(s)' 'r_loop*sin(s)'});
model.component('mod1').geom('geom1').feature('pc4').set('pos', {'R1_x' 'R1_y' 'R1_z'});
model.component('mod1').geom('geom1').create('pc5', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc5').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc5').set('coord', {'r_loop*sin(s)' '0' 'r_loop*cos(s)'});
model.component('mod1').geom('geom1').feature('pc5').set('pos', {'R1_x' 'R1_y' 'R1_z'});
model.component('mod1').geom('geom1').create('pc6', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc6').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc6').set('coord', {'r_loop*cos(s)' 'r_loop*sin(s)' '0'});
model.component('mod1').geom('geom1').feature('pc6').set('pos', {'R1_x' 'R1_y' 'R1_z'});
model.component('mod1').geom('geom1').create('pc7', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc7').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc7').set('coord', {'0' 'r_loop*cos(s)' 'r_loop*sin(s)'});
model.component('mod1').geom('geom1').feature('pc7').set('pos', {'R2_x' 'R2_y' 'R2_z'});
model.component('mod1').geom('geom1').create('pc8', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc8').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc8').set('coord', {'r_loop*sin(s)' '0' 'r_loop*cos(s)'});
model.component('mod1').geom('geom1').feature('pc8').set('pos', {'R2_x' 'R2_y' 'R2_z'});
model.component('mod1').geom('geom1').create('pc9', 'ParametricCurve');
model.component('mod1').geom('geom1').feature('pc9').set('parmax', '2*pi');
model.component('mod1').geom('geom1').feature('pc9').set('coord', {'r_loop*cos(s)' 'r_loop*sin(s)' '0'});
model.component('mod1').geom('geom1').feature('pc9').set('pos', {'R2_x' 'R2_y' 'R2_z'});
model.component('mod1').geom('geom1').create('pt1', 'Point');
model.component('mod1').geom('geom1').feature('pt1').set('p', {'T_x' 'T_y' 'T_z'});
model.component('mod1').geom('geom1').create('pt2', 'Point');
model.component('mod1').geom('geom1').feature('pt2').set('p', {'R1_x' 'R1_y' 'R1_z'});
model.component('mod1').geom('geom1').create('pt3', 'Point');
model.component('mod1').geom('geom1').feature('pt3').set('p', {'R2_x' 'R2_y' 'R2_z'});
model.component('mod1').geom('geom1').feature('fin').set('repairtoltype', 'relative');
model.component('mod1').geom('geom1').feature('fin').set('repairtol', 1.0E-12);
model.component('mod1').geom('geom1').run;

model.component('mod1').selection.create('box1', 'Box');
model.component('mod1').selection.create('box2', 'Box');
model.component('mod1').selection.create('box3', 'Box');
model.component('mod1').selection.create('ball1', 'Ball');
model.component('mod1').selection('ball1').set('entitydim', 0);
model.component('mod1').selection.create('ball2', 'Ball');
model.component('mod1').selection('ball2').set('entitydim', 0);
model.component('mod1').selection.create('ball3', 'Ball');
model.component('mod1').selection('ball3').set('entitydim', 0);
model.component('mod1').selection('box1').set('zmin', 'T_z+RC-0.1');
model.component('mod1').selection('box2').set('zmin', 'T_z-RC+0.1');
model.component('mod1').selection('box2').set('zmax', 'T_z+RC-0.1');
model.component('mod1').selection('box2').set('condition', 'allvertices');
model.component('mod1').selection('box3').set('zmax', 'T_z-RC+0.1');
model.component('mod1').selection('ball1').set('posx', 'T_x');
model.component('mod1').selection('ball1').set('posy', 'T_y');
model.component('mod1').selection('ball1').set('posz', 'T_z');
model.component('mod1').selection('ball1').set('r', 'r_loop/10');
model.component('mod1').selection('ball1').set('condition', 'inside');
model.component('mod1').selection('ball2').set('posx', 'R1_x');
model.component('mod1').selection('ball2').set('posy', 'R1_y');
model.component('mod1').selection('ball2').set('posz', 'R1_z');
model.component('mod1').selection('ball2').set('r', 'r_loop/10');
model.component('mod1').selection('ball2').set('condition', 'inside');
model.component('mod1').selection('ball3').set('posx', 'R2_x');
model.component('mod1').selection('ball3').set('posy', 'R2_y');
model.component('mod1').selection('ball3').set('posz', 'R2_z');
model.component('mod1').selection('ball3').set('r', 'r_loop/10');
model.component('mod1').selection('ball3').set('condition', 'inside');

model.component('mod1').view.create('view2', 'geom1');
model.component('mod1').view.create('view3', 'geom1');

model.component('mod1').material.create('mat1', 'Common');
model.component('mod1').material.create('mat2', 'Common');
model.component('mod1').material.create('mat3', 'Common');
model.component('mod1').material('mat1').selection.named('box1');
model.component('mod1').material('mat2').selection.named('box2');
model.component('mod1').material('mat3').selection.named('box3');

model.component('mod1').physics.create('emw', 'ElectromagneticWaves', 'geom1');
model.component('mod1').physics('emw').create('sctr1', 'Scattering', 2);
model.component('mod1').physics('emw').feature('sctr1').selection.set([1 2 3 4 5 7 8 10 11 12 13 14 15 16 17 18]);
model.component('mod1').physics('emw').create('mpd1', 'MagneticPointDipole', 0);
model.component('mod1').physics('emw').feature('mpd1').selection.named('ball1');

model.component('mod1').mesh('mesh1').create('ftet1', 'FreeTet');
model.component('mod1').mesh('mesh1').create('ftet2', 'FreeTet');
model.component('mod1').mesh('mesh1').create('ftet3', 'FreeTet');
model.component('mod1').mesh('mesh1').create('ftet4', 'FreeTet');
model.component('mod1').mesh('mesh1').create('ref1', 'Refine');
model.component('mod1').mesh('mesh1').feature('ftet1').selection.named('box1');
model.component('mod1').mesh('mesh1').feature('ftet1').create('size1', 'Size');
model.component('mod1').mesh('mesh1').feature('ftet2').selection.named('box2');
model.component('mod1').mesh('mesh1').feature('ftet2').create('size1', 'Size');
model.component('mod1').mesh('mesh1').feature('ftet3').selection.named('box3');
model.component('mod1').mesh('mesh1').feature('ftet3').create('size1', 'Size');

model.result.table('tbl1').comments('R1_pt_evaluation');
model.result.table('tbl2').comments('R1_pt_evaluation');

model.thermodynamics.label('Thermodynamics Package');

model.component('mod1').view('view1').set('renderwireframe', true);
model.component('mod1').view('view1').set('scenelight', false);
model.component('mod1').view('view2').set('environmentmap', 'Indoor');
model.component('mod1').view('view3').set('environmentmap', 'Indoor');

model.component('mod1').material('mat1').label('upper_bed');
model.component('mod1').material('mat1').propertyGroup('def').set('electricconductivity', {'Sxx_1' 'Syx_1' 'Szx_1' 'Sxy_1' 'Syy_1' 'Szy_1' 'Sxz_1' 'Syz_1' 'Szz_1'});
model.component('mod1').material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat1').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat2').label('local_bed');
model.component('mod1').material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat2').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat2').propertyGroup('def').set('electricconductivity', {'Sxx_0' 'Syx_0' 'Szx_0' 'Sxy_0' 'Syy_0' 'Szy_0' 'Sxz_0' 'Syz_0' 'Szz_0'});
model.component('mod1').material('mat3').label('lower_bed');
model.component('mod1').material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat3').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.component('mod1').material('mat3').propertyGroup('def').set('electricconductivity', {'Sxx_2' 'Syx_2' 'Szx_2' 'Sxy_2' 'Syy_2' 'Szy_2' 'Sxz_2' 'Syz_2' 'Szz_2'});

model.component('mod1').physics('emw').label('Electromagnetic Waves');
model.component('mod1').physics('emw').prop('MeshControl').set('SizeControlParameter', 'UserDefined');
model.component('mod1').physics('emw').prop('EquationForm').set('freq', '1e9[Hz]');
model.component('mod1').physics('emw').prop('EquationForm').set('modeFreq', '1e9[Hz]');
model.component('mod1').physics('emw').prop('BackgroundField').set('w0', '(2*pi)/emw.k0');
model.component('mod1').physics('emw').prop('AnalysisMethodology').set('MethodologyOptions', 'Robust');
model.component('mod1').physics('emw').prop('PortOptions').set('PortFormulation', 'ConstraintBased');
model.component('mod1').physics('emw').feature('wee1').set('Tref', '293.15[K]');
model.component('mod1').physics('emw').feature('wee1').set('murPrim', 0);
model.component('mod1').physics('emw').feature('wee1').set('minput_temperature_src', 'userdef');
model.component('mod1').physics('emw').feature('wee1').set('minput_magneticfield_src', 'root.mod1.emw.Hx');
model.component('mod1').physics('emw').feature('wee1').set('minput_magneticfluxdensity_src', 'root.mod1.emw.Bx');
model.component('mod1').physics('emw').feature('wee1').set('minput_frequency_src', 'userdef');
model.component('mod1').physics('emw').feature('wee1').set('minput_frequency', 'root.freq');
model.component('mod1').physics('emw').feature('wee1').set('epsilonInf_mat', 'from_mat');
model.component('mod1').physics('emw').feature('dcont1').set('pairDisconnect', true);
model.component('mod1').physics('emw').feature('dcont1').label('Continuity');
model.component('mod1').physics('emw').feature('sctr1').set('WaveType', 'SphericalWave');
model.component('mod1').physics('emw').feature('sctr1').set('r0', {'T_x'; 'T_y'; 'T_z'});
model.component('mod1').physics('emw').feature('sctr1').set('IncidentField', 'EField');
model.component('mod1').physics('emw').feature('sctr1').set('Order', 'SecondOrder');
model.component('mod1').physics('emw').feature('mpd1').set('normm', 1);
model.component('mod1').physics('emw').feature('mpd1').set('enm', {'mx'; 'my'; 'mz'});

model.component('mod1').mesh('mesh1').feature('size').set('hauto', 2);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('custom', 'on');
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmax', 2);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmaxactive', true);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hminactive', true);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hcurve', 0.7);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hcurveactive', true);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hnarrow', 2);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hnarrowactive', true);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hgrad', 1.6);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hgradactive', true);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('custom', 'on');
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmax', 2);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmaxactive', true);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hminactive', true);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('custom', 'on');
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmax', 2);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmaxactive', true);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hminactive', true);
model.component('mod1').mesh('mesh1').feature('ref1').set('rmethod', 'regular');
model.component('mod1').mesh('mesh1').run;

model.study.create('std1');
model.study('std1').create('freq', 'Frequency');

model.sol.create('sol1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('p1', 'Parametric');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').create('sv1', 'SORVector');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').create('sv1', 'SORVector');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.dataset.create('cpl1', 'CutPlane');
model.result.numerical.create('pev1', 'EvalPoint');
model.result.numerical.create('pev2', 'EvalPoint');
model.result.numerical('pev1').selection.named('ball2');
model.result.numerical('pev2').selection.named('ball3');
model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').create('slc1', 'Slice');
model.result('pg1').create('slc2', 'Slice');
model.result('pg1').create('slc3', 'Slice');
model.result('pg1').create('str1', 'Streamline');
model.result('pg1').feature('slc1').set('expr', 'log10(emw.normE)');
model.result('pg1').feature('slc2').set('expr', 'log10(emw.normE)');
model.result('pg1').feature('slc3').set('expr', 'log10(emw.normE)');
model.result('pg1').feature('str1').selection.all;
model.result('pg1').feature('str1').set('expr', {'emw.Hx' 'emw.Hy' 'emw.Hz'});
model.result.export.create('data1', 'Data');

model.study('std1').feature('freq').set('punit', 'Hz');
model.study('std1').feature('freq').set('plist', 'freq1');
model.study('std1').feature('freq').set('preusesol', 'yes');
model.study('std1').feature('freq').set('usestol', true);
model.study('std1').feature('freq').set('stol', '0.0010');
model.study('std1').feature('freq').set('ftplistmethod', 'manual');

model.sol('sol1').label('Solver 1');
model.sol('sol1').feature('st1').label('Compile Equations: Frequency Domain');
model.sol('sol1').feature('v1').label('Dependent Variables 1.1');
model.sol('sol1').feature('v1').set('clistctrl', {'p1'});
model.sol('sol1').feature('v1').set('cname', {'freq'});
model.sol('sol1').feature('v1').set('clist', {'freq1[Hz]'});
model.sol('sol1').feature('s1').label('Stationary Solver 1.1');
model.sol('sol1').feature('s1').set('stol', '0.0010');
model.sol('sol1').feature('s1').feature('dDef').label('Direct 1');
model.sol('sol1').feature('s1').feature('dDef').set('thresh', 0.1);
model.sol('sol1').feature('s1').feature('dDef').set('ooc', false);
model.sol('sol1').feature('s1').feature('dDef').set('rhob', 400);
model.sol('sol1').feature('s1').feature('aDef').label('Advanced 1');
model.sol('sol1').feature('s1').feature('aDef').set('complexfun', true);
model.sol('sol1').feature('s1').feature('p1').label('Parametric 1.1');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});
model.sol('sol1').feature('s1').feature('p1').set('plistarr', {'freq1'});
model.sol('sol1').feature('s1').feature('p1').set('punit', {'Hz'});
model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');
model.sol('sol1').feature('s1').feature('p1').set('preusesol', 'yes');
model.sol('sol1').feature('s1').feature('fc1').label('Fully Coupled 1.1');
model.sol('sol1').feature('s1').feature('fc1').set('termonres', false);
model.sol('sol1').feature('s1').feature('fc1').set('probesel', 'manual');
model.sol('sol1').feature('s1').feature('i1').label('Iterative 1.1');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'bicgstab');
model.sol('sol1').feature('s1').feature('i1').feature('ilDef').label('Incomplete LU 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').label('Multigrid 1.1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').label('Presmoother 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sv1').label('SOR Vector 1.1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').label('Postsmoother 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').feature('soDef').label('SOR 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('po').feature('sv1').label('SOR Vector 1.1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').label('Coarse Solver 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('dDef').label('Direct 1');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('dDef').set('thresh', 0.1);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('dDef').set('ooc', false);
model.sol('sol1').feature('s1').feature('i1').feature('mg1').feature('cs').feature('dDef').set('errorchk', false);

model.study('std1').runNoGen;

model.result.dataset('dset1').label('Solution 1');
model.result.dataset('cpl1').set('quickplane', 'xz');
model.result.dataset('cpl1').set('quicky', 0.2);
model.result.numerical('pev1').label('R1_pt_evaluation');
model.result.numerical('pev1').set('table', 'tbl1');
model.result.numerical('pev1').set('expr', {'emw.Ex' 'emw.Ey' 'emw.Ez' 'emw.Hx' 'emw.Hy' 'emw.Hz'});
model.result.numerical('pev1').set('unit', {'V/m' 'V/m' 'V/m' 'A/m' 'A/m' 'A/m'});
model.result.numerical('pev1').set('descr', {'Electric field, x-component' 'Electric field, y-component' 'Electric field, z-component' 'Magnetic field, x-component' 'Magnetic field, y-component' 'Magnetic field, z-component'});
model.result.numerical('pev2').label('R2_pt_evaluation');
model.result.numerical('pev2').set('table', 'tbl2');
model.result.numerical('pev2').set('expr', {'emw.Ex' 'emw.Ey' 'emw.Ez' 'emw.Hx' 'emw.Hy' 'emw.Hz'});
model.result.numerical('pev2').set('unit', {'V/m' 'V/m' 'V/m' 'A/m' 'A/m' 'A/m'});
model.result.numerical('pev2').set('descr', {'Electric field, x-component' 'Electric field, y-component' 'Electric field, z-component' 'Magnetic field, x-component' 'Magnetic field, y-component' 'Magnetic field, z-component'});
model.result.numerical('pev1').setResult;
model.result.numerical('pev2').setResult;
model.result('pg1').label('Electric Field (emw)');
model.result('pg1').set('showlegendsmaxmin', true);
model.result('pg1').set('smooth', 'internal');
model.result('pg1').feature('slc1').set('quickplane', 'xy');
model.result('pg1').feature('slc1').set('quickznumber', 1);
model.result('pg1').feature('slc1').set('colortable', 'RainbowClassic');
model.result('pg1').feature('slc1').set('smooth', 'internal');
model.result('pg1').feature('slc1').set('resolution', 'normal');
model.result('pg1').feature('slc2').set('quickxnumber', 1);
model.result('pg1').feature('slc2').set('colortable', 'RainbowClassic');
model.result('pg1').feature('slc2').set('smooth', 'internal');
model.result('pg1').feature('slc2').set('inheritplot', 'slc1');
model.result('pg1').feature('slc2').set('resolution', 'normal');
model.result('pg1').feature('slc3').set('quickplane', 'zx');
model.result('pg1').feature('slc3').set('quickynumber', 1);
model.result('pg1').feature('slc3').set('colortable', 'RainbowClassic');
model.result('pg1').feature('slc3').set('smooth', 'internal');
model.result('pg1').feature('slc3').set('inheritplot', 'slc1');
model.result('pg1').feature('slc3').set('resolution', 'normal');
model.result('pg1').feature('str1').active(false);
model.result('pg1').feature('str1').set('selnumber', 100);
model.result('pg1').feature('str1').set('smooth', 'internal');
model.result('pg1').feature('str1').set('resolution', 'normal');
model.result.export('data1').set('data', 'cpl1');
model.result.export('data1').set('expr', {'emw.Ex' 'emw.Ey' 'emw.Ez' 'emw.Hx' 'emw.Hy' 'emw.Hz'});
model.result.export('data1').set('unit', {'V/m' 'V/m' 'V/m' 'A/m' 'A/m' 'A/m'});
model.result.export('data1').set('descr', {'Electric field, x-component' 'Electric field, y-component' 'Electric field, z-component' 'Magnetic field, x-component' 'Magnetic field, y-component' 'Magnetic field, z-component'});
model.result.export('data1').set('filename', 'C:\Users\shubi\Downloads\test1.txt');
model.result.export('data1').set('location', 'grid');
model.result.export('data1').set('gridx2', 'range(-1,1,1)');
model.result.export('data1').set('gridy2', 'range(-1,1,1)');

model.component('mod1').mesh('mesh1').feature('ref1').set('boxcoord', true);
model.component('mod1').mesh('mesh1').feature('ref1').set('xmin', -1);
model.component('mod1').mesh('mesh1').feature('ref1').set('xmax', 1);
model.component('mod1').mesh('mesh1').feature('ref1').set('ymin', -1);
model.component('mod1').mesh('mesh1').feature('ref1').set('ymax', 1);
model.component('mod1').mesh('mesh1').feature('ref1').set('zmin', -1);
model.component('mod1').mesh('mesh1').feature('ref1').set('zmax', 1);
model.component('mod1').mesh('mesh1').feature('ref1').set('rmethod', 'longest');

model.label('UDAR_COMSOL_unparallel_fine.mph');

model.component('mod1').mesh('mesh1').feature('ref1').set('rmethod', 'regular');

model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').run;
model.result('pg2').create('mesh1', 'Mesh');
model.result('pg2').feature('mesh1').set('colortable', 'TrafficFlow');
model.result('pg2').feature('mesh1').set('colortabletrans', 'nonlinear');
model.result('pg2').feature('mesh1').set('nonlinearcolortablerev', true);
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('meshdomain', 'volume');
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('meshdomain', 'surface');
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('meshdomain', 'volume');
model.result('pg2').feature('mesh1').set('elemtype3', 'tet');
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('filteractive', true);
model.result('pg2').feature('mesh1').set('logfilterexpr', 'y<T_y');
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('elemcolor', 'type');
model.result('pg2').feature('mesh1').set('elemtype3', 'all');
model.result('pg2').feature('mesh1').set('elemcolor', 'gray');
model.result('pg2').feature('mesh1').set('logfilterexpr', 'y>T_y');
model.result('pg2').run;

model.component('mod1').view('view1').set('transparency', false);

model.result('pg2').feature('mesh1').set('logfilterexpr', 'y>=T_y');
model.result('pg2').run;
model.result('pg2').feature('mesh1').set('elemscale', 0.8);
model.result('pg2').run;

model.label('UDAR_COMSOL_unparallel_fine.mph');
model.label('MD140.0_Mx_total');

model.param.set('Rh_0', '100.0[ohm*m]');
model.param.set('Rh_1', '2.0[ohm*m]');
model.param.set('Rh_2', '2.0[ohm*m]');
model.param.set('Rv_0', '100.0[ohm*m]');
model.param.set('Rv_1', '2.0[ohm*m]');
model.param.set('Rv_2', '2.0[ohm*m]');
model.param.set('Sxx_0', '0.01[S/m]');
model.param.set('Syy_0', '0.01[S/m]');
model.param.set('Szz_0', '0.01[S/m]');
model.param.set('Sxy_0', '0[S/m]');
model.param.set('Sxz_0', '0[S/m]');
model.param.set('Syx_0', '0[S/m]');
model.param.set('Syz_0', '0[S/m]');
model.param.set('Szx_0', '0[S/m]');
model.param.set('Szy_0', '0[S/m]');
model.param.set('Sxx_1', '0.5[S/m]');
model.param.set('Syy_1', '0.5[S/m]');
model.param.set('Szz_1', '0.5[S/m]');
model.param.set('Sxy_1', '0[S/m]');
model.param.set('Sxz_1', '0[S/m]');
model.param.set('Syx_1', '0[S/m]');
model.param.set('Syz_1', '0[S/m]');
model.param.set('Szx_1', '0[S/m]');
model.param.set('Szy_1', '0[S/m]');
model.param.set('Sxx_2', '0.5[S/m]');
model.param.set('Syy_2', '0.5[S/m]');
model.param.set('Szz_2', '0.5[S/m]');
model.param.set('Sxy_2', '0[S/m]');
model.param.set('Sxz_2', '0[S/m]');
model.param.set('Syx_2', '0[S/m]');
model.param.set('Syz_2', '0[S/m]');
model.param.set('Szx_2', '0[S/m]');
model.param.set('Szy_2', '0[S/m]');
model.param.set('DTB_1', '11.562000000000012[m]');
model.param.set('DTB_2', '-8.437999999999988[m]');
model.param.set('Dip', '0');
model.param.set('dip_LB', '0.0');
model.param.set('freq1', '10000.0');
model.param.set('mx', '1.0');
model.param.set('my', '0.0');
model.param.set('mz', '0.0');
model.param.set('T_x', '23.94[m]');
model.param.set('T_y', '41.44[m]');
model.param.set('T_z', '131.562[m]');
model.param.set('R1_x', '21.855168[m]');
model.param.set('R1_y', '37.831168[m]');
model.param.set('R1_z', '120.103958[m]');
model.param.set('R2_x', '19.770336[m]');
model.param.set('R2_y', '34.222336[m]');
model.param.set('R2_z', '108.645917[m]');
model.param.set('z_R1', '-11.458042000000006[m]');
model.param.set('z_R2', '-22.916083000000015[m]');
model.param.set('Ix', '1.0');
model.param.set('Iy', '0.0');
model.param.set('Iz', '0.0');
model.param.set('RC', '330.2441844817705[ft]');

model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('custom', true);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmax', 3.5588127170858854);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('custom', true);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmax', 10);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('custom', true);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmax', 3.5588127170858854);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmin', 'r_loop/10');
model.component('mod1').mesh('mesh1').feature('ref1').active(false);
model.component('mod1').mesh('mesh1').run;

model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 3);

model.sol('sol1').feature('s1').feature('i1').active(true);

model.study('std1').run;

model.result('pg2').feature('mesh1').set('colortable', 'TrafficFlow');
model.result('pg2').feature('mesh1').set('colortabletrans', 'nonlinear');
model.result('pg2').feature('mesh1').set('nonlinearcolortablerev', true);
model.result('pg2').feature('mesh1').set('meshdomain', 'volume');
model.result('pg2').feature('mesh1').set('filteractive', true);
model.result('pg2').feature('mesh1').set('elemcolor', 'gray');
model.result('pg2').feature('mesh1').set('logfilterexpr', 'y>=T_y');
model.result('pg2').feature('mesh1').set('elemscale', 0.8);
model.result('pg2').feature('mesh1').set('elemcolor', 'type');
model.result('pg2').feature('mesh1').set('elemtype3', 'all');
model.result('pg2').feature('mesh1').set('elemcolor', 'size');

model.component('mod1').view('view1').set('transparency', false);

model.result('pg2').run;
model.result.export.create('img1', 'Image');
model.result.export('img1').set('sourceobject', 'pg2');
model.result.export('img1').set('pngfilename', '/export/home/mnle8/01_szeng/workspace/03_projects/2DFDM_matlab/build/cpp/outputSecondaryTrueDebugDip20Azi60_total/comsol_results/mesh_MD140.0_Mx_total.png');
model.result.export('img1').set('imagetype', 'png');
model.result.export('img1').set('width', 1920);
model.result.export('img1').set('height', 1080);
model.result.export('img1').set('lockratio', true);
model.result.export('img1').run;

model.sol('sol1').getSize;

model.label('MD140.0_Mx_total_solved.mph');

model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmax', 10);
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmax', 10);
model.component('mod1').mesh('mesh1').run('ftet1');
model.component('mod1').mesh('mesh1').run('ftet2');
model.component('mod1').mesh('mesh1').run('ftet3');
model.component('mod1').mesh('mesh1').run('ftet4');

model.sol('sol1').runAll;

model.result('pg1').run;

model.label('MD140.0_Mx_total_solved_coarse.mph');

model.result('pg1').run;

model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmax', 30);
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmax', 30);
model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmax', 20);
model.component('mod1').mesh('mesh1').run;

model.param.set('DTB_2', '8.437999999999988[m]');

model.component('mod1').geom('geom1').run('fin');

model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmin', 'r_loop/3');
model.component('mod1').mesh('mesh1').feature('ftet1').feature('size1').set('hmin', 'r_loop/3');
model.component('mod1').mesh('mesh1').feature('ftet3').feature('size1').set('hmin', 'r_loop/3');
model.component('mod1').mesh('mesh1').run;

model.param.set('r_loop', '2[inch]');

model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run('fin');

model.component('mod1').mesh('mesh1').run;

model.param.set('DTB_1', '15[m]');
model.param.set('DTB_2', '18[m]');

model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmax', 40);
model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hgradactive', true);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hcurveactive', true);
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hnarrowactive', true);

model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 2);
model.component('mod1').physics('emw').prop('AnalysisMethodology').set('MethodologyOptions', 'Fast');
model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 2);

model.sol('sol1').feature('s1').feature('dDef').active(true);

model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', '2t2');

model.component('mod1').geom('geom1').feature('pc1').active(false);
model.component('mod1').geom('geom1').feature('pc2').active(false);
model.component('mod1').geom('geom1').feature('pc3').active(false);
model.component('mod1').geom('geom1').feature('pc4').active(false);
model.component('mod1').geom('geom1').feature('pc5').active(false);
model.component('mod1').geom('geom1').feature('pc6').active(false);
model.component('mod1').geom('geom1').feature('pc7').active(false);
model.component('mod1').geom('geom1').feature('pc8').active(false);
model.component('mod1').geom('geom1').feature('pc9').active(false);
model.component('mod1').geom('geom1').run('fin');

model.component('mod1').mesh('mesh1').run;

model.sol('sol1').runAll;

model.result('pg1').run;

model.component('mod1').physics('emw').feature('sctr1').active(false);
model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 2);

model.sol('sol1').runAll;

model.result('pg1').run;

model.component('mod1').physics.create('mf', 'InductionCurrents', 'geom1');
model.component('mod1').physics('mf').create('mpd1', 'MagneticPointDipole', 0);
model.component('mod1').physics('mf').feature('mpd1').selection.named('ball1');
model.component('mod1').physics('mf').feature('mpd1').set('normm', 1);
model.component('mod1').physics('mf').feature('mpd1').set('enm', {'mx' 'my' 'mz'});

model.sol('sol1').create('v2', 'Variables');
model.sol('sol1').feature.remove('v2');

model.component('mod1').physics('emw').active(false);

model.sol('sol1').feature('v1').feature.move('mod1_E', 1);
model.sol('sol1').runFromTo('st1', 's1');

model.result.duplicate('pg3', 'pg1');
model.result('pg3').label('Electric Field (mf)');
model.result('pg3').run;
model.result('pg3').feature('slc1').set('expr', 'log10(mf.normE)');
model.result('pg3').feature('slc2').set('expr', 'log10(mf.normE)');
model.result('pg3').feature('slc3').set('expr', 'log10(mf.normE)');
model.result('pg3').run;

model.component('mod1').physics('mf').create('als1', 'AmperesLawSolid', 3);

model.result('pg3').run;
model.result('pg3').run;
model.result('pg3').run;
model.result('pg3').run;
model.result('pg3').run;

model.component('mod1').physics('mf').feature.move('als1', 3);
model.component('mod1').physics('mf').feature('als1').selection.set([1 2 3]);

model.sol('sol1').runAll;

model.result('pg3').run;

model.component('mod1').physics('mf').create('gfa1', 'GaugeFixingA', 3);

model.sol('sol1').runAll;

model.result('pg3').run;

model.component('mod1').physics('mf').feature('gfa1').active(false);

model.sol('sol1').runAll;

model.result('pg3').run;
model.result.numerical.duplicate('pev3', 'pev1');
model.result.numerical('pev3').setIndex('expr', 'mf.Ex', 0);
model.result.numerical('pev3').setIndex('expr', 'mf.Ey', 1);
model.result.numerical('pev3').setIndex('expr', 'mf.Ez', 2);
model.result.numerical('pev3').setIndex('expr', 'mf.Hx', 3);
model.result.numerical('pev3').setIndex('expr', 'mf.Hy', 4);
model.result.numerical('pev3').setIndex('expr', 'mf.Hz', 5);
model.result.numerical('pev3').set('table', 'tbl1');
model.result.numerical('pev3').setResult;
model.result.table('tbl1').save('/export/home/mnle8/01_szeng/workspace/Untitled.txt');
model.result.numerical('pev3').selection.named('ball3');
model.result.numerical('pev3').set('table', 'tbl1');
model.result.numerical('pev3').appendResult;
model.result.table('tbl1').clearTableData;
model.result.numerical('pev3').set('table', 'tbl1');
model.result.numerical('pev3').setResult;
model.result.table('tbl1').save('/export/home/mnle8/01_szeng/workspace/Untitled.txt');

model.component('mod1').physics('mf').active(false);
model.component('mod1').physics('emw').active(true);

model.sol('sol1').runAll;

model.result('pg1').run;
model.result.table.remove('tbl1');
model.result.table.create('tbl3', 'Table');
model.result.table('tbl3').comments('R1_pt_evaluation');
model.result.numerical('pev1').set('table', 'tbl3');
model.result.numerical('pev1').setResult;
model.result.table('tbl3').save('/export/home/mnle8/01_szeng/workspace/Untitled1.txt');

model.component('mod1').physics('mf').active(true);
model.component('mod1').physics('emw').active(false);

model.sol('sol1').runAll;

model.component('mod1').physics('mf').feature('gfa1').active(true);

model.sol('sol1').runAll;

model.result.table('tbl3').clearTableData;
model.result.table.create('tbl4', 'Table');
model.result.table('tbl4').comments('R1_pt_evaluation 1');
model.result.numerical('pev3').set('table', 'tbl4');
model.result.numerical('pev3').setResult;
model.result.numerical('pev3').selection.named('ball2');
model.result.table('tbl4').clearTableData;
model.result.numerical('pev3').set('table', 'tbl4');
model.result.numerical('pev3').setResult;

model.component('mod1').mesh('mesh1').stat.setQualityMeasure('skewness');

model.component('mod1').physics.create('mfh', 'MagneticFieldFormulation', 'geom1');
model.component('mod1').physics.remove('mfh');
model.component('mod1').physics.create('mef', 'ElectricInductionCurrents', 'geom1');
model.component('mod1').physics('mef').create('alcs1', 'ElectromagneticModelSolid', 3);
model.component('mod1').physics('mef').feature('alcs1').selection.set([1 2 3]);
model.component('mod1').physics('mef').create('mpd1', 'MagneticPointDipole', 0);
model.component('mod1').physics('mef').feature('mpd1').selection.named('ball1');
model.component('mod1').physics('mef').feature('mpd1').set('enm', {'mx' 'my' 'mz'});
model.component('mod1').physics('mef').feature('mpd1').set('normm', 1);
model.component('mod1').physics('mf').active(false);

model.result.duplicate('pg4', 'pg3');
model.result('pg4').label('Electric Field (mef) 1');
model.result('pg4').run;
model.result('pg4').feature('slc1').set('expr', 'log10(mef.normE)');
model.result('pg4').feature('slc2').set('expr', 'log10(mef.normE)');
model.result('pg4').feature('slc3').set('expr', 'log10(mef.normE)');
model.result('pg4').run;

model.component('mod1').physics('mef').prop('ShapeProperty').set('order_magneticvectorpotential', 1);
model.component('mod1').physics('mef').prop('ShapeProperty').set('order_electricpotential', 1);

model.result('pg4').run;

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');

model.result('pg4').run;

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'cudss');

model.result('pg4').run;

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');

model.component('mod1').mesh('mesh1').feature('ref1').active(true);
model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').run;
model.component('mod1').mesh('mesh1').feature('ref1').set('boxcoord', false);
model.component('mod1').mesh('mesh1').run;

model.component('mod1').physics('mef').prop('ShapeProperty').set('order_magneticvectorpotential', 2);
model.component('mod1').physics('mef').prop('ShapeProperty').set('order_electricpotential', 2);

model.component('mod1').mesh('mesh1').feature('ref1').active(false);
model.component('mod1').mesh('mesh1').clearMesh;

model.sol('sol1').clearSolutionData;

model.label('MD140.0_Mx_total_solved_coarse_mef.mph');

model.result('pg4').run;
model.result('pg4').run;
model.result('pg4').run;
model.result.duplicate('pg5', 'pg4');
model.result('pg5').run;
model.result('pg5').label('A (mef)');
model.result('pg5').run;
model.result('pg5').feature('slc1').set('expr', 'mef.Ax');
model.result('pg5').feature('slc1').set('descr', 'Magnetic vector potential, x-component');
model.result('pg5').run;
model.result('pg5').feature('slc2').set('expr', 'mef.Ax');
model.result('pg5').run;
model.result('pg5').feature('slc3').set('expr', 'mef.Ax');
model.result('pg5').run;
model.result('pg5').feature('slc1').set('expr', 'mef.Ay');
model.result('pg5').run;
model.result('pg5').feature('slc2').set('expr', 'mef.Ay');
model.result('pg5').run;
model.result('pg5').feature('slc3').set('expr', 'mef.Ay');
model.result('pg5').run;
model.result('pg4').run;
model.result('pg5').run;
model.result('pg5').run;
model.result('pg5').run;
model.result('pg5').run;
model.result('pg5').feature('slc3').set('expr', 'mef.Az');
model.result('pg5').run;
model.result('pg5').feature('slc2').set('expr', 'mef.Az');
model.result('pg5').run;
model.result('pg5').feature('slc1').set('expr', 'mef.Az');
model.result('pg5').run;
model.result('pg5').feature('slc1').set('expr', 'V');
model.result('pg5').feature('slc1').set('descr', 'Electric potential');
model.result('pg5').run;
model.result('pg5').feature('slc2').set('expr', 'V');
model.result('pg5').run;
model.result('pg5').feature('slc3').set('expr', 'V');

model.component('mod1').physics('mef').create('gfa1', 'GaugeFixingA', 3);

model.sol('sol1').runAll;

model.result('pg4').run;
model.result('pg5').run;
model.result('pg5').run;
model.result('pg5').run;
model.result('pg5').run;

model.component('mod1').geom('geom1').run('sph1');
model.component('mod1').geom('geom1').runPre('fin');
model.component('mod1').geom('geom1').run('blk3');
model.component('mod1').geom('geom1').run('blk3');
model.component('mod1').geom('geom1').run('blk3');

model.component('mod1').view('view1').set('renderwireframe', false);

model.component('mod1').geom('geom1').run('blk3');
model.component('mod1').geom('geom1').run('co1');
model.component('mod1').geom('geom1').runPre('co1');
model.component('mod1').geom('geom1').create('wp1', 'WorkPlane');
model.component('mod1').geom('geom1').feature('wp1').set('unite', true);
model.component('mod1').geom('geom1').run('wp1');
model.component('mod1').geom('geom1').feature.move('wp1', 8);
model.component('mod1').geom('geom1').run('co1');
model.component('mod1').geom('geom1').create('par1', 'Partition');
model.component('mod1').geom('geom1').feature('par1').selection('input').set({'co1'});
model.component('mod1').geom('geom1').feature('par1').set('partitionwith', 'workplane');
model.component('mod1').geom('geom1').feature.move('par1', 9);
model.component('mod1').geom('geom1').feature('par1').set('workplane', 'wp1');
model.component('mod1').geom('geom1').run('par1');
model.component('mod1').geom('geom1').feature('wp1').set('quickplane', 'yz');
model.component('mod1').geom('geom1').run('wp1');
model.component('mod1').geom('geom1').run('par1');
model.component('mod1').geom('geom1').feature('wp1').set('quickx', 'T_x');
model.component('mod1').geom('geom1').run('wp1');
model.component('mod1').geom('geom1').run('par1');
model.component('mod1').geom('geom1').create('wp2', 'WorkPlane');
model.component('mod1').geom('geom1').feature('wp2').set('unite', true);
model.component('mod1').geom('geom1').feature('wp2').set('quickplane', 'zx');
model.component('mod1').geom('geom1').feature('wp2').set('quicky', 'T_y');
model.component('mod1').geom('geom1').run('wp2');
model.component('mod1').geom('geom1').create('par2', 'Partition');
model.component('mod1').geom('geom1').feature('par2').selection('input').set({'par1'});
model.component('mod1').geom('geom1').feature('par2').set('partitionwith', 'workplane');
model.component('mod1').geom('geom1').run('par2');
model.component('mod1').geom('geom1').runPre('fin');

model.component('mod1').view('view1').set('renderwireframe', true);

model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').feature('pc1').active(true);
model.component('mod1').geom('geom1').feature('pc2').active(true);
model.component('mod1').geom('geom1').feature('pc3').active(true);
model.component('mod1').geom('geom1').runPre('fin');
model.component('mod1').geom('geom1').run;

model.component('mod1').mesh('mesh1').run('ftet3');

model.component('mod1').view('view1').set('transparency', true);

model.component('mod1').mesh('mesh1').run('ftet2');
model.component('mod1').mesh('mesh1').run('ftet1');
model.component('mod1').mesh('mesh1').run('ftet2');
model.component('mod1').mesh('mesh1').feature('ftet2').feature('size1').set('hmin', 'r_loop/8');
model.component('mod1').mesh('mesh1').create('ftri1', 'FreeTri');
model.component('mod1').mesh('mesh1').feature.move('ftri1', 2);
model.component('mod1').mesh('mesh1').feature('ftri1').selection.set([1 17 30 31]);
model.component('mod1').mesh('mesh1').feature('ftri1').create('size1', 'Size');
model.component('mod1').mesh('mesh1').feature('ftri1').feature('size1').set('custom', true);
model.component('mod1').mesh('mesh1').feature('ftri1').feature('size1').set('hmaxactive', true);
model.component('mod1').mesh('mesh1').feature('ftri1').feature('size1').set('hminactive', true);
model.component('mod1').mesh('mesh1').feature('ftri1').feature('size1').set('hmin', 'r_loop/8');
model.component('mod1').mesh('mesh1').run('ftri1');
model.component('mod1').mesh('mesh1').current('ftet2');

model.component('mod1').geom('geom1').feature('pc1').active(false);
model.component('mod1').geom('geom1').feature('pc2').active(false);
model.component('mod1').geom('geom1').feature('pc3').active(false);
model.component('mod1').geom('geom1').run;

model.component('mod1').mesh('mesh1').run('ftet2');
model.component('mod1').mesh('mesh1').run;

model.sol('sol1').runAll;

model.result('pg5').run;

model.component('mod1').view('view1').set('transparency', false);

model.result.dataset.create('cln1', 'CutLine3D');
model.result.dataset('cln1').setIndex('genpoints', 'T_x', 0, 0);
model.result.dataset('cln1').setIndex('genpoints', -50, 0, 2);
model.result.dataset('cln1').setIndex('genpoints', 'T_x', 1, 0);
model.result.dataset('cln1').setIndex('genpoints', 50, 1, 2);
model.result.dataset('cln1').setIndex('genpoints', 250, 1, 2);
model.result.create('pg6', 'PlotGroup1D');
model.result('pg6').run;
model.result('pg6').create('lngr1', 'LineGraph');
model.result('pg6').feature('lngr1').set('markerpos', 'datapoints');
model.result('pg6').feature('lngr1').set('linewidth', 'preference');
model.result('pg6').feature('lngr1').set('evaluationsettings', 'parent');
model.result('pg6').feature('lngr1').set('data', 'cln1');
model.result('pg6').run;
model.result('pg6').run;

model.component('mod1').physics('mef').feature('gfa1').active(false);

model.result('pg5').run;
model.result('pg5').run;
model.result('pg4').run;
model.result('pg5').run;

model.component('mod1').physics('mef').feature('gfa1').active(true);

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'mumps');
model.sol('sol1').runAll;

model.result('pg4').run;
model.result('pg5').run;

model.component('mod1').physics('mef').feature('gfa1').active(false);

model.result('pg5').run;

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');

model.result('pg4').run;
model.result('pg5').run;

model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'mumps');

model.result('pg4').run;
model.result('pg5').run;
model.result('pg4').run;

model.label('MD140.0_Mx_total_solved_coarse_mef.mph');

model.component('mod1').physics('mef').active(false);
model.component('mod1').physics('emw').active(true);

model.sol('sol1').runAll;

model.result('pg1').run;

model.label('MD140.0_Mx_total_solved_coarse_mef.mph');

model.result('pg1').run;

model.component('mod1').physics('emw').prop('ShapeProperty').set('order_electricfield', 1);

out = model;
