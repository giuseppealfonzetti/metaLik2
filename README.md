
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metaLik2

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/giuseppealfonzetti/metaLik2/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/giuseppealfonzetti/metaLik2/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The `metaLik2` provides higher order likelihood inference for
random-effects meta-analysis and meta-regression models. It leverages
the `likelihoodAsy` package to provide a modular extension to further
models than

## Installation

You can install the development version of metaLik2 like so:

``` r
pak::pkg_install("giuseppealfonzetti/metaLik2")
```

## Usage

We fit the same random-effects model to the `diuretics` data shipped
with `metaLik`, using both `metaLik()` and `metaLik2()`

``` r
library(metaLik)
library(metaLik2)
data(diuretics)

d <- metaLik2_set_data(diuretics, "continuous")
d
#> metaLik_data: continuous, 9 studies
fit <- metaLik2::metaLik2("normal_normal", d)
fit0 <- metaLik::metaLik(y ~ 1, data = diuretics, sigma2 = sigma2)
```

### A metaLik2 fit

The fit object supports `print()`, `coef()`, `vcov()` and `logLik()`
methods.

``` r
fit 
#> metaLik2 fit: normal_normal 
#> 
#> (Intercept)     log_tau2  
#>  -0.5173433   -1.4327196  
#> 
#> Heterogeneity:  tau^2 = 0.2387 
#> 
#> Log-likelihood: -9.469
coef(fit)
#> (Intercept)    log_tau2 
#>  -0.5173433  -1.4327196
vcov(fit)
#>             (Intercept)    log_tau2
#> (Intercept)  0.04263874 -0.00495638
#> log_tau2    -0.00495638  0.67407146
logLik(fit)
#> 'log Lik.' -9.468582 (df=3)

coef(fit0)
#> (Intercept) 
#>  -0.5173436
log(fit0$tau2.mle)
#> [1] -1.432674
logLik(fit0) # constant term dropped
#> 'log Lik.' -1.198135 (df=3)
```

The `confint()` method provides Wald confidence intervals

``` r
confint(fit)
#>                  2.5 %     97.5 %
#> (Intercept) -0.9220592 -0.1126274
#> log_tau2    -3.0418864  0.1764472
```

### Hypothesis testing

Both packages test a scalar parameter using the `r` statistic or
Skovgaard’s `r*`. In `metaLik2()` computations are run via
`likelihoodAsy`

``` r
metaLik2::rstar_test(fit, PARAM = 1, ALTERNATIVE = "greater")
#> 
#> Signed profile log-likelihood ratio test for parameter (Intercept)
#> 
#> First-order statistic
#> r:-2.11, p-value:0.9826
#> Skovgaard's statistic
#> rSkov:-1.86, p-value:0.9686
#> alternative hypothesis: parameter is greater than 0
metaLik::test.metaLik(fit0, param = 1, alternative = "greater")
#> 
#> Signed profile log-likelihood ratio test for parameter (Intercept)
#> 
#> First-order statistic
#> r:-2.11, p-value:0.9826
#> Skovgaard's statistic
#> rSkov:-1.846, p-value:0.9675
#> alternative hypothesis: parameter is greater than 0
```

### Confidence intervals

Confidence intervals can be computed via `rstar_ci()`, which returns an
`rstarci` object from the `likelihoodAsy` package

``` r
pr <- metaLik2::rstar_ci(fit, SEED = 123)
class(pr)
#> [1] "rstarci"
```

which comes with `print()`, `summary()` and `plot()` methods.

``` r
pr
#> Confidence interval calculations based on likelihood asymptotics
#> 1st-order
#>          90%                         95%                         99%     
#> ( -0.8935  ,  -0.1415 )         ( -0.98330  ,  -0.04845 )         ( -1.1910  ,   0.1714 )
#> 2nd-order
#>          90%                         95%                         99%     
#> ( -0.95714  ,  -0.07698 )        ( -1.06111  ,   0.03794 )        ( -1.3116  ,   0.3104 )
summary(pr)
#> Confidence interval calculations based on likelihood asymptotics
#> -----------------------------------------------------------------------------
#> Parameter of interest:        User-defined function
#> Calculations based on a grid of 27 points
#> Skovgaard covariances computed with 1000 Monte Carlo draws
#> -----------------------------------------------------------------------------
#> 1st-order
#>          90%                         95%                         99%     
#> ( -0.8935  ,  -0.1415 )       ( -0.98330  ,  -0.04845 )       ( -1.1910  ,   0.1714 )
#> 2nd-order
#>          90%                         95%                         99%     
#> ( -0.95714  ,  -0.07698 )       ( -1.06111  ,   0.03794 )       ( -1.3116  ,   0.3104 )
#> -----------------------------------------------------------------------------
#> Decomposition of high-order adjustment
#> Nuisance parameter adjustment (NP)
#>     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.  
#> -0.37260  -0.26400  -0.01116   0.02124   0.32470   0.46600  
#> Information adjustment (INF)
#>     Min.   1st Qu.    Median      Mean   3rd Qu.      Max.  
#> -0.14330  -0.09349  -0.01958  -0.02423   0.04566   0.07574  
#> -----------------------------------------------------------------------------
plot(pr)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" alt="" width="100%" />

## Binary outcomes

``` r
library(metafor)
counts <- with(dat.bcg, data.frame(
  event1 = tpos, n1 = tpos + tneg,
  event2 = cpos, n2 = cpos + cneg
))
head(counts)
#>   event1    n1 event2    n2
#> 1      4   123     11   139
#> 2      6   306     29   303
#> 3      3   231     11   220
#> 4     62 13598    248 12867
#> 5     33  5069     47  5808
#> 6    180  1541    372  1451
```

We fit a `"binomial_normal"` using `metaLik2()`. The overall log-odds
ratio is the `delta` parameter.

``` r
db <- metaLik2_set_data(counts, "binary")
fitb <- metaLik2("binomial_normal", db)
c(delta = coef(fitb)[["delta"]], tau2 = exp(coef(fitb)[["log_tau2"]]))
#>      delta       tau2 
#> -0.7450028  0.2948875
```

The same model is available in `metafor` as a mixed-effects logistic
regression.

``` r
fitb0 <- rma.glmm(measure = "OR", ai = tpos, bi = tneg, ci = cpos, di = cneg,
              data = dat.bcg, model = "UM.FS")
c(delta = as.numeric(fitb0$beta), tau2 = fitb0$tau2)
#>      delta       tau2 
#> -0.7450233  0.2949026
```

The `metafor` package returns Wald confidence intervals, which coincide
with `metaLik2` confint()

``` r
c(summary(fitb0)$ci.lb,summary(fitb0)$ci.ub)
#> [1] -1.0891246 -0.4009221
confint(fitb)
#>              2.5 %     97.5 %
#> mu1      -3.467844 -2.3660115
#> mu2      -3.375192 -2.5939718
#> mu3      -4.129531 -2.9986741
#> mu4      -4.783150 -4.5087935
#> mu5      -5.156175 -4.7063054
#> mu6      -1.641110 -1.4463346
#> mu7      -5.422918 -4.4890926
#> mu8      -5.227766 -5.1036716
#> mu9      -5.560839 -5.0915046
#> mu10     -4.128411 -3.6178186
#> mu11     -5.542486 -5.3232817
#> mu12     -7.131783 -5.7347762
#> mu13     -6.706122 -6.1778388
#> delta    -1.089099 -0.4009065
#> log_tau2 -2.224592 -0.2177308
```

Higher-order inference on `delta` can be run using the same `r*`
interface as the continuous case

``` r
metaLik2::rstar_test(fitb, PARAM = "delta", R = 200)
#> 
#> Signed profile log-likelihood ratio test for parameter delta
#> 
#> First-order statistic
#> r:-3.393, p-value:0.0006923
#> Skovgaard's statistic
#> rSkov:-3.135, p-value:0.00172
#> alternative hypothesis: parameter is different from 0
metaLik2::rstar_ci(fitb, PARAM = "delta", R = 200)
#> Confidence interval calculations based on likelihood asymptotics
#> 1st-order
#>          90%                         95%                         99%     
#> ( -1.0574  ,  -0.4464 )         ( -1.1273  ,  -0.3814 )         ( -1.2801  ,  -0.2386 )
#> 2nd-order
#>          90%                         95%                         99%     
#> ( -1.0922  ,  -0.4222 )        ( -1.169  ,  -0.348 )        ( -1.3382  ,  -0.1825 )
```
