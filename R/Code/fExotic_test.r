library(fExoticOptions)
## Examples from Chapter 2.9 in E.G. Haug's Option Guide (1997)
## Floating Strike Lookback Option [2.9.1]:
FloatingStrikeLookbackOption(TypeFlag = "p", S = 100,
                             SMinOrMax = 115, Time = 1, r = 0, b = 0.01,
                             sigma = 0.10)@price

## Fixed Strike Lookback Option [2.9.2]:
FixedStrikeLookbackOption(TypeFlag = "p", S = 100,
                          SMinOrMax = 115, X = 100, Time = 1, r = 0, b = 0.06,
                          sigma = 0.10)@price
## Partial Time Floating Strike Lookback Option [2.9.3]:
PTFloatingStrikeLookbackOption(TypeFlag = "p", S = 100,
                               SMinOrMax = 115, time1 = 0.5, Time2 = 1, r = 0, b = 0.06,
                               sigma = 0.10, lambda = 0.95)
## Partial Time Fixed Strike Lookback Option [2.9.4]:
PTFixedStrikeLookbackOption(TypeFlag = "p", S = 100, X = 100,
                            time1 = 0.5, Time2 = 1, r = 0, b = 0.06, sigma = 0.10)
## Extreme Spread Option [2.9.5]:
ExtremeSpreadOption(TypeFlag = "c", S = 100, SMin = NA,
                    SMax = 110, time1 = 0.5, Time2 = 1, r = 0.1, b = 0.1,
                    sigma = 0.30)
ExtremeSpreadOption(TypeFlag = "cr", S = 100, SMin = 90,
                    SMax = NA, time1 = 0.5, Time2 = 1, r = 0.1, b = 0.1,
                    sigma = 0.30)