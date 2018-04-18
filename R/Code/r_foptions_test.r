library(fOptions)
## All the examples are from Haug's Option Guide (1997)
## CHAPTER 1.4: ANALYTICAL MODELS FOR AMERICAN OPTIONS

######## BasicAmericanOptions #####
## Roll-Geske-Whaley American Calls on Dividend Paying
# Stocks [Haug 1.4.1]
RollGeskeWhaleyOption(S = 80, X = 82, time1 = 1/4,
                      Time2 = 1/3, r = 0.06, D = 4, sigma = 0.30)
## Barone-Adesi and Whaley Approximation for American
# Options [Haug 1.4.2] vs. Black76 Option on Futures:
BAWAmericanApproxOption(TypeFlag = "p", S = 100,
                        X = 100, Time = 0.5, r = 0.10, b = 0, sigma = 0.25)
Black76Option(TypeFlag = "c", FT = 100, X = 100,
              Time = 0.5, r = 0.10, sigma = 0.25)
## Bjerksund and Stensland Approximation for American Options:
BSAmericanApproxOption(TypeFlag = "c", S = 42, X = 40,
                       Time = 0.75, r = 0.04, b = 0.04-0.08, sigma = 0.35)

###### BinomialTreeOptions ########
## Cox-Ross-Rubinstein Binomial Tree Option Model:
# A European Call - Compare with Black Scholes:
CRRBinomialTreeOption(TypeFlag = "ce", S = 100, X = 100,
                      Time = 1, r = 0, b = 0, sigma = 0.1, n = 100)
GBSOption(TypeFlag = "c", S = 100, X = 100,
          Time = 1, r = 0, b = 0, sigma = 0.1)@price

## CRR - JR - TIAN Model Comparison:
# Hull's Example as Function of "n":
par(mfrow = c(2, 1), cex = 0.7)
steps = 50
CRROptionValue = JROptionValue = TIANOptionValue =
  rep(NA, times = steps)
for (n in 3:steps) {
  CRROptionValue[n] = CRRBinomialTreeOption(TypeFlag = "pa", S = 50,
                                            X = 50, Time = 0.4167, r = 0.1, b = 0.1, sigma = 0.4, n = n)@price
  JROptionValue[n] = JRBinomialTreeOption(TypeFlag = "pa", S = 50,
                                          X = 50, Time = 0.4167, r = 0.1, b = 0.1, sigma = 0.4, n = n)@price
  TIANOptionValue[n] = TIANBinomialTreeOption(TypeFlag = "pa", S = 50,
                                              X = 50, Time = 0.4167, r = 0.1, b = 0.1, sigma = 0.4, n = n)@price
}
plot(CRROptionValue[3:steps], type = "l", col = "red", ylab = "Option Value")
lines(JROptionValue[3:steps], col = "green")
lines(TIANOptionValue[3:steps], col = "blue")
# Add Result from BAW Approximation:
BAWValue = BAWAmericanApproxOption(TypeFlag = "p", S = 50, X = 50,
                                   Time = 0.4167, r = 0.1, b = 0.1, sigma = 0.4)@price
abline(h = BAWValue, lty = 3)
title(main = "Convergence")
df_compare=data.frame(CRROptionValue, JROptionValue, TIANOptionValue)
## Plot CRR Option Tree:
# Again Hull's Example:
CRRTree = BinomialTreeOption(TypeFlag = "pa", S = 50, X = 50,
                             Time = 0.4167, r = 0.1, b = 0.1, sigma = 0.4, n = 5)
BinomialTreePlot(CRRTree, dy = 1, cex = 0.8, ylim = c(-6, 7),
                 xlab = "n", ylab = "Option Value")
title(main = "Option Tree")

#### MonteCarloOptions ####
