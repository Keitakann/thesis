data {
    int T;
    matrix[3,T] ex;
    vector[T] y;
    int pred_term;
    matrix[3,pred_term] ex_test;
    }

parameters{
    vector[T] L_coef;
    vector[T] S_coef;
    vector[T] C_coef;
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
        alpha[i]=L_coef[i]*ex[1,i] + S_coef[i]*ex[2,i] + C_coef[i]*ex[3,i];
        }
    }

model {
    //状態方程式
    //L_coef[1] ~ normal(L_coef_zero, s_lc);
    //S_coef[1] ~ normal(S_coef_zero, s_sc);
    //C_coef[1] ~ normal(C_coef_zero, s_cc);

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

generated quantities{
    //vector[T + pred_term] L_coef_pred;
    //vector[T + pred_term] S_coef_pred;
    //vector[T + pred_term] C_coef_pred;    
    //vector[T + pred_term] alpha_pred;
    //vector[T + pred_term] y_pred;

    //L_coef_pred[1:T] = L_coef;
    //S_coef_pred[1:T] = S_coef;
    //C_coef_pred[1:T] = C_coef;

    //alpha_pred[1:T] = alpha;
    //y_pred[1:T] = y;

    //for(i in 1:pred_term){
    //    L_coef_pred[T+i] = normal_rng(L_coef_pred[T + i-1],s_lc);
    //    S_coef_pred[T+i] = normal_rng(S_coef_pred[T + i-1],s_sc);
    //    C_coef_pred[T+i] = normal_rng(C_coef_pred[T + i-1],s_cc);

    //    alpha_pred[T+i] = L_coef_pred[T+i]*ex_test[1,i]+S_coef_pred[T+i]*ex_test[2,i]
    //    +C_coef_pred[T+i]*ex_test[3,i];

    //    y_pred[T+i] = normal_rng(alpha_pred[T + i-1],s_v);

    vector[1 + pred_term] L_coef_pred;
    vector[1 + pred_term] S_coef_pred;
    vector[1 + pred_term] C_coef_pred;    
    vector[1 + pred_term] alpha_pred;
    vector[1 + pred_term] y_pred;

    L_coef_pred[1] = L_coef[T];
    S_coef_pred[1] = S_coef[T];
    C_coef_pred[1] = C_coef[T];

    alpha_pred[1] = alpha[T];
    y_pred[1] = y[T];
    //データ取得期間を超えた部分を予測
    for(i in 1:pred_term){
        L_coef_pred[1+i] = normal_rng(L_coef_pred[1 + i-1],s_lc);
        S_coef_pred[1+i] = normal_rng(S_coef_pred[1 + i-1],s_sc);
        C_coef_pred[1+i] = normal_rng(C_coef_pred[1 + i-1],s_cc);

        alpha_pred[1+i] = L_coef_pred[1+i]*ex_test[1,i]+S_coef_pred[1+i]*ex_test[2,i]
        +C_coef_pred[1+i]*ex_test[3,i];

        //y_pred[1+i] = normal_rng(alpha_pred[1 + i-1],s_v);
        y_pred[1+i] = normal_rng(alpha_pred[1 + i],s_v);
    }
}