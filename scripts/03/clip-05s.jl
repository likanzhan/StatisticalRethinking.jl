# # clip-05s.jl

# Load Julia packages (libraries) needed

using StatisticalRethinking, CmdStan

ProjDir = @__DIR__
cd(ProjDir)

# Define the Stan language model

binomialstanmodel = "
// Inferring a Rate
data {
  int N;
  int<lower=0> k[N];
  int<lower=1> n[N];
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> thetaprior;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);
  thetaprior ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

stanmodel = Stanmodel(name="binomial", monitors = ["theta"], model=binomialstanmodel,
  output_format=:mcmcchains);

# Use 16 observations

N2 = 4^2
d = Binomial(9, 0.66)
n2 = Int.(9 * ones(Int, N2))
k2 = rand(d, N2);

# Input data for cmdstan

binomialdata = Dict("N" => length(n2), "n" => n2, "k" => k2);

# Sample using cmdstan
 
rc, chn, cnames = stan(stanmodel, binomialdata, ProjDir, diagnostics=false,
  CmdStanDir=CMDSTAN_HOME);

# Describe the draws

MCMCChains.describe(chn)

# Plot the 4 chains

if rc == 0
  plot(chn)
  savefig("Fig-05s.pdf")
end

# End of `03/clip-05s.jl`
