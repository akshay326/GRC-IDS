param W;
param inst_cost {w in 0..W} = 10*(exp(0.05*w)-1);

param Ch1;
param Ch2;
param Cl1;
param Cl2;

# ----------------------------
# IDS is represented by Player2

param discount;
set actions;

param s1 {actions};
param s2 {actions};
param Pmin {1..5};
param Pmax {1..5}; 

param chi1 {w in 0..W, a in actions, b in actions} = -inst_cost[w] + (if a="high" then Ch1 else Cl1);

param chi2 {w in 0..W, a in actions, b in actions} = inst_cost[w] + (if b="high" then Ch2 else Cl2);

# defense probab
param pbar_min{a in actions, b in actions} = (if s1[a] =0 then 1 else min( 0.16*Pmin[1]*s2[b]/s1[a], 1));
param pbar_max{a in actions, b in actions} = (if s1[a] =0 then 1 else min( 0.16*Pmax[1]*s2[b]/s1[a], 1));

param pi_min {w in 0..W, w_next in 0..W, a in actions, b in actions} =  
		 (if w_next = w-1 then (w*pbar_min[a,b]/W) 	
	else (if w_next = w   then (w*(1-pbar_min[a,b])/W  + (W-w)*pbar_min[a,b]/W)   
	else (if w_next = w+1 then ((W-w)*(1-pbar_min[a,b])/W)  
	else 0)))  ;

param pi_max {w in 0..W, w_next in 0..W, a in actions, b in actions} =  
		 (if w_next = w-1 then (w*pbar_max[a,b]/W) 	
	else (if w_next = w   then (w*(1-pbar_max[a,b])/W  + (W-w)*pbar_max[a,b]/W)   
	else (if w_next = w+1 then ((W-w)*(1-pbar_max[a,b])/W)  
	else 0)))  ;

param tmin{w in 0..W,w_next in 0..W, a in actions, b in actions} = min(pi_min[w,w_next,a,b],pi_max[w,w_next,a,b]);
param tmax{w in 0..W,w_next in 0..W, a in actions, b in actions} = max(pi_min[w,w_next,a,b],pi_max[w,w_next,a,b]);

# check{w in 0..W,  
# 	w_next in 0..W, a in actions, b in actions}:
# 	 tmin[w,w_next,a,b] <= tmax[w,w_next,a,b];


# ---------------------------
# finished params. var starts

# ---------------------------
# keeping polytope size j=n, not 2ml^n
					

var sigma {i in 1..2, w in 0..W, a in actions} >=0, <=1, := 0.5;
var _gamma {i in 1..2, w in 0..W} ;

# l^n-1 * l for given i,w
var C {i in 1..2, w in 0..W,
	a in actions, b in actions}=
	if i=1 then chi1[w,a,b]*sigma[2,w,b] else chi2[w,a,b]*sigma[1,w,a];

# l^n * ml^n  for given w
# var D {w in 0..W, 
# 	a1 in actions, b1 in actions, w_next in 0..W, a2 in actions, b2 in actions} binary; 

param D {w in 0..W, 
	a1 in actions, b1 in actions, w_next in 0..W, a2 in actions, b2 in actions} = 
	(if w_next = w-1 and a1 = a2 and b1 = b2 then 1 	
	else (if w_next = w  and a1 = a2 and b1 = b2 then 1
	else (if w_next = w+1 and a1 = a2 and b1 = b2  then 1
	else 0)))  ;

# ml^n * 1 for given i,w
var T {i in 1..2, w in 0..W,  # worst case transition probab
	w_next in 0..W, a in actions, b in actions} >= tmin[w,w_next,a,b], <= tmax[w,w_next,a,b];

# j * 1 for given i,w
var q {i in 1..2, w in 0..W, 
	j in 1..2} <=0 ;

# j * ml^n for given w
var A {w in 0..W, 
	j in 1..2, w_next in 0..W, a in actions, b in actions}; 

# j * 1 for given w
var _b {w in 0..W, 
	j in 1..2};

# l^n * 1 for given i,w
var _r {i in 1..2, w in 0..W, 
	a in actions, b in actions};

# ml^n * 1 for given i,w
var _z {i in 1..2, w in 0..W, 
	w_next in 0..W, a in actions, b in actions};

# ml^n * l for given i,w
var _Z {i in 1..2, w in 0..W, 
	w_next in 0..W, a in actions, b in actions, x in actions};

# ---------------------------
# inequality starts 

subject to corollary2_9 {i in 1..2, w in 0..W}:
	_gamma[i,w] = (sum {a in actions, b in actions} C[i,w,a,b]*(if i =1 then sigma[i,w,a] else sigma[i,w,b])) + 
				  discount*(sum{w_next in 0..W} (sum{a in actions,b in actions} sigma[1,w,a]*sigma[2,w,b]*T[i,w,w_next,a,b])*_gamma[i,w_next]);

subject to corollary2_8 {i in 1..2, w in 0..W, l in actions}:
	(sum{b in actions}(if i =1 then C[i,w,l,b] else C[i,w,b,l])) +
	discount*(sum{w_next in 0..W, a in actions, b in actions} _Z[i,w,w_next,a,b,l]*T[i,w,w_next,a,b]) >= _gamma[i,w];

subject to corollary2_7 {i in 1..2, w in 0..W}:
	_gamma[i,w] >= (sum{j in 1..2} _b[w,j]*q[i,w,j]) + (sum{a in actions, b in actions} _r[i,w,a,b]) +
				   (sum{a in actions, b in actions} C[i,w,a,b]*(if i =1 then sigma[i,w,a] else sigma[i,w,b]));

subject to corollary2_6 {i in 1..2, w in 0..W,
	w_next in 0..W, a in actions, b in actions}:
	(sum{j in 1..2} A[w,j,w_next,a,b]*q[i,w,j]) + (sum{x in actions, y in actions} D[w,a,b,w_next,x,y]*_r[i,w,x,y]) -
	discount*_z[i,w,w_next,a,b] >= 0;   # reduced this using eqn_15

subject to eqn_15 {i in 1..2, w in 0..W,
	w_next in 0..W, a in actions, b in actions}:
	_z[i,w,w_next,a,b] = (sum{x in actions} _Z[i,w,w_next,a,b,x]*sigma[i,w,x]);

subject to eqn_14 {i in 1..2, w in 0..W,
	w_next in 0..W, a in actions, b in actions}:
	_z[i,w,w_next,a,b] = _gamma[i,w_next]*sigma[1,w,a]*sigma[2,w,b];

subject to corollary2_5 {i in 1..2, w in 0..W}:
	(sum{a in actions} sigma[i,w,a]) = 1 ;

subject to corollary2_2 {i in 1..2, w in 0..W,
	j in 1..2}: 
	(sum{w_next in 0..W, a in actions, b in actions} A[w,j,w_next,a,b]*T[i,w,w_next,a,b]) >= _b[w,j];

subject to corollary2_1 {i in 1..2, w in 0..W,
	a1 in actions, b1 in actions}:
	 (sum{w_next in 0..W, a2 in actions, b2 in actions} D[w,a1,b1,w_next,a2,b2]*T[i,w,w_next,a2,b2])=1;