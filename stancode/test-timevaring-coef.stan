data {
    int T;
    matrix[3,T] ex;
    vector[T] y;
    }

parameters{
    vector[T] L_coef;
    vector[T] S_coef;
    vector[T] C_coef;
    real<lower=0> s_lc;
    real<lower=0> s_sc;
    real<lower=0> s_cc;
    real<lower=0> s_v;
    real L_coef_zero;
    real S_coef_zero;
    real C_coef_zero;     
    }
transformed parameters{
    vector[T] alpha;
    for(i in 1:T){
        alpha[i]=L_coef[i]*ex[1,i] + S_coef[i]*ex[2,i] + C_coef*ex[3,i];
        }
    }

model {
    //状態方程式
    L_coef[1] ~ normal(L_coef_zero, s_lc);
    S_coef[1] ~ normal(S_coef_zero, s_sc);
    C_coef[1] ~ normal(C_coef_zero, s_cc);
    
    for(i in 2:T) {
        L_coef[i] ~ normal(L_coef[i-1],s_lc);
        S_coef[i] ~ normal(S_coef[i-1],s_sc);
        C_coef[i] ~ normal(L_coef[i-1],s_cc);
        }   
    //観測方程式
    for(i in 1:T) {
        y[i] ~ normal(alpha[i],s_v);
        }
    }