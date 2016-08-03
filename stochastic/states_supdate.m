function hmm = states_supdate(hmm,hmm_noisy,rho,update)
% update==1, W; update==2, Omega; update==3, sigma; update==4, alpha
K = length(hmm_noisy.state);
Sind = hmm.train.Sind==1;
regressed = sum((hmm.train.S==1),1)>0;

for k = 1:K
    if update==1 && isfield(hmm_noisy.state(1),'W') && ~isempty(hmm_noisy.state(1).W.Mu_W)
        hmm.state(k).W.Mu_W = (1-rho) * hmm.state(k).W.Mu_W + ...
            rho * hmm_noisy.state(k).W.Mu_W;
        hmm.state(k).W.iS_W = (1-rho) * hmm.state(k).W.iS_W + ...
            rho * hmm_noisy.state(k).W.iS_W;
        if strcmp(hmm_noisy.train.covtype,'full') || strcmp(hmm_noisy.train.covtype,'uniquefull')
            hmm.state(k).W.S_W = inv(hmm.state(k).W.iS_W);
        else
            for n = 1:size(hmm.state(k).W.S_W,1)
                hmm.state(k).W.S_W(n,Sind(:,n),Sind(:,n)) = ...
                    inv(permute(hmm.state(k).W.iS_W(n,Sind(:,n),Sind(:,n)),[2 3 1]));
            end
        end
    elseif update==2 && isfield(hmm_noisy.state(1),'Omega')
        hmm.state(k).Omega.Gam_rate = (1-rho) * hmm.state(k).Omega.Gam_rate + ...
            rho * hmm_noisy.state(k).Omega.Gam_rate;
        hmm.state(k).Omega.Gam_shape = (1-rho) * hmm.state(k).Omega.Gam_shape + ...
            rho * hmm_noisy.state(k).Omega.Gam_shape;
        if strcmp(hmm_noisy.train.covtype,'full') || strcmp(hmm_noisy.train.covtype,'uniquefull')
            hmm.state(k).Omega.Gam_irate(regressed,regressed) = ...
                inv(hmm.state(k).Omega.Gam_rate(regressed,regressed));
        else
            hmm.state(k).Omega.Gam_irate(regressed) = 1 ./ hmm.state(k).Omega.Gam_rate(regressed);
        end
    elseif update==3 && isfield(hmm_noisy.state(1),'sigma')
        hmm.state(k).sigma.Gam_rate = (1-rho) * hmm.state(k).sigma.Gam_rate + ...
            rho * hmm_noisy.state(k).sigma.Gam_rate;
        hmm.state(k).sigma.Gam_shape = (1-rho) * hmm.state(k).sigma.Gam_shape + ...
            rho * hmm_noisy.state(k).sigma.Gam_shape;
    elseif update==4 && isfield(hmm_noisy.state(1),'alpha')
        hmm.state(k).alpha.Gam_rate = (1-rho) * hmm.state(k).alpha.Gam_rate + ...
            rho * hmm_noisy.state(k).alpha.Gam_rate;
        hmm.state(k).alpha.Gam_shape = (1-rho) * hmm.state(k).alpha.Gam_shape + ...
            rho * hmm_noisy.state(k).alpha.Gam_shape;
    end
end
end