data {
    int T;
    vector[T] y;
    int pred_term;
    }

parameters{
    vector[T] L;
    vector[T] S;
    vector[T] C;
    vector[T] L_coef;
    vector[T] S_coef;
    vector[T] C_coef;
    real<lower=0> s_l;
    real<lower=0> s_s;
    real<lower=0> s_c;
    real<lower=0> s_lc;
    real<lower=0> s_sc;
    real<lower=0> s_cc;
    real<lower=0> s_v;
    //real L_coef_zero;
    //real S_coef_zero;
    //real C_coef_zero;    
    }

transformed parameters{
    vector[T] alpha;

    for(i in 1:T){
        alpha[i]=L_coef[i]*L[i] + S_coef[i]*S[i] + C_coef[i]*C[i];
        }
    }

model {
    //状態方程式
    //L_coef[1] ~ normal(L_coef_zero, s_lc);
    //S_coef[1] ~ normal(S_coef_zero, s_sc);
    //C_coef[1] ~ normal(C_coef_zero, s_cc);

    for(i in 2:T) {
        L[i] ~ normal(L[i-1],s_l);
        S[i] ~ normal(S[i-1],s_s);
        C[i] ~ normal(C[i-1],s_c);
        L_coef[i] ~ normal(L_coef[i-1],s_lc);
        S_coef[i] ~ normal(S_coef[i-1],s_sc);
        C_coef[i] ~ normal(L_coef[i-1],s_cc);
        }   
    //観測方程式
    for(i in 1:T) {
        y[i] ~ normal(alpha[i],s_v);
        }
    }

generated quantities{
    vector[T + pred_term] L_pred;
    vector[T + pred_term] S_pred;
    vector[T + pred_term] C_pred;
    vector[T + pred_term] L_coef_pred;
    vector[T + pred_term] S_coef_pred;
    vector[T + pred_term] C_coef_pred;    
    vector[T + pred_term] alpha_pred;
    vector[T + pred_term] y_pred;

    L_coef_pred[1:T] = L_coef;
    S_coef_pred[1:T] = S_coef;
    C_coef_pred[1:T] = C_coef;
    L_pred[1:T] = L;
    S_pred[1:T] = S;
    C_pred[1:T] = C;

    alpha_pred[1:T] = alpha;
    y_pred[1:T] = y;
    //データ取得期間を超えた部分を予測
    for(i in 1:pred_term){
        L_pred[T+i] = normal_rng(L_pred[T + i-1],s_l);
        S_pred[T+i] = normal_rng(S_pred[T + i-1],s_s);
        C_pred[T+i] = normal_rng(C_pred[T + i-1],s_c);
        L_coef_pred[T+i] = normal_rng(L_coef_pred[T + i-1],s_lc);
        S_coef_pred[T+i] = normal_rng(S_coef_pred[T + i-1],s_sc);
        C_coef_pred[T+i] = normal_rng(C_coef_pred[T + i-1],s_cc);

        alpha_pred[T+i] = L_coef_pred[T+i]*L_pred[T+i]+S_coef_pred[T+i]*S_pred[T+i]
        +C_coef_pred[T+i]*C_pred[T+i];

        y_pred[T+i] = normal_rng(alpha_pred[T + i-1],s_v);
    }
}