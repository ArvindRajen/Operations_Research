# Number of Cities 
set CITIES;
# Time Quarters
set Q;
# Distance between CITIES
param d {i in CITIES, j in CITIES};
# Demand of each city i in Quarter q
param D {i in CITIES, q in Q};
# Produced units limit for production facility in city i in quarter q
param U {i in CITIES, q in Q};
#Contract cost for production facility of city i
param ccp {i in CITIES};
# Cost per unit produced in quarter q
param cp {q in Q};
# Cost per unit warehoused at the end of quarter q
param cw {q in Q};
# transportation cost to warehouses per miles per unit
param t1 = 0.1;
# transportation cost to customers per miles per unit
param t2 = 0.125;
# Large constant;
param M = 10000000000000;

var fp {i in CITIES} binary; #cities that are fixed as the production centers
var fw {i in CITIES, q in Q} binary; #cities that are fixed as the warehouses in quarter q
var xp {i in CITIES, q in Q} >= 0 ; # units produced at the end of quarter q in warehouse at city i
var xw {i in CITIES, q in Q} >= 0; # units warehoused at the end of quarter q in warehouse at city i
var ypi {i in CITIES, j in CITIES, q in Q} >= 0 ; # pf to city
var ywi {i in CITIES, j in CITIES, q in Q} >= 0 ; # ware to city
var ypw {i in CITIES, j in CITIES, q in Q} >= 0 ; #i pf to j ware

minimize Yearly_Cost: sum{i in CITIES, q in Q} cp[q] * xp[i,q] + sum{i in CITIES} ccp[i] * fp[i] + sum{i in CITIES, q in Q} cw[q] * xw[i,q] + 
sum{i in CITIES, j in CITIES, q in Q} d[i,j] * ypw[i,j,q] * t1 + sum{i in CITIES, j in CITIES, q in Q} d[i,j] * ypi[i,j,q] * t2 + 
sum{i in CITIES, j in CITIES, q in Q} d[i,j] * ywi[i,j,q] * t2;

# Production facility cities selection
# subject to PFC1: sum{i in 1..7}fp[i]=1;
# subject to PFC2: sum{i in 8..13}fp[i]=1;
# subject to PFC3: sum{i in 14..19}fp[i]=1;
# subject to PFC4: sum{i in 20..25}fp[i]=1;

subject to ADD1: fp[1]=1;

subject to ADD2: fp[2]=1;

subject to ADD3: fp[3]=1;

subject to ADD4: fp[4]=1;

subject to PFZEROS: sum{i in 5..25}fp[i]=0;

subject to WHZEROS{q in Q}: sum{i in 1..25}fw[i,q]=0;

subject to fp_Xp_relation {i in CITIES, q in Q}: xp[i,q] <= U[i,q]*fp[i];

subject to fw_Xw_relation {i in CITIES, q in Q}: xw[i,q] <= M*fw[i,q];

subject to fp_yp_relation {i in CITIES, q in Q}: sum{j in CITIES} (ypi[i,j,q]+ypw[i,j,q])<=xp[i,q]; # Need to verify and also ywi

subject to Demand {j in CITIES, q in Q}: sum{i in CITIES} (ypi[i,j,q]+ywi[i,j,q]) = D[j,q];

subject to PFC_nt_W {i in CITIES, q in Q}: fp[i] + fw[i,q] <= 1;

# subject to Ware {q in Q}: sum{i in CITIES} fw[i,q]=3;

subject to q1_inventory {i in CITIES}: xw[i,1] = sum{j in CITIES} ypw[j,i,1]; # verify the constraint in ampl expand

subject to other_inventory {i in CITIES, q in 2..4}: xw[i,q] = xw[i,q-1] +sum{j in CITIES} ypw[j,i,q] - sum{j in CITIES}ywi[i,j,q]; # verify the constraint in ampl expand

subject to YWQ1 {i in CITIES, j in CITIES}: ywi[i,j,1]=0; # check "for all indices"

subject to inventory_bal {i in CITIES, q in 2..4}: sum{j in CITIES}ywi[i,j,q] <= xw[i,q-1];

subject to Prod_bal {i in CITIES, q in Q}: xp[i,q] = sum{j in CITIES} (ypi[i,j,q] + ypw[i,j,q]);

subject to yearly_bal : sum{i in CITIES,j in CITIES, q in Q}ypw[i,j,q] <= sum{i in CITIES,q in Q} xw[i,q];