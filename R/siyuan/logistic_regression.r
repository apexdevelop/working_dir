#setwd("E:/Apex/project3/project3/machine_learning")
setwd("Z:/Proj/Trading/Amie Ma/project3/machine_learning")
mydata = read.csv("alum_factor_rtn.csv", stringsAsFactors=F)
data=mydata[,3:7]
install.packages("caTools")
library(caTools)
split=sample.split(data,SplitRatio=0.8)
training <- subset(data,split=="TRUE")
testing <- subset(data,split=="FALSE")
model <- glm(Y ~ ., training, family="binomial")
summary(model)

res <- predict(model,testing,type="response")
table(Actualvalue=testing$Y, predictedvalue=res>0.5)

#to find threshold
install.packages("ROCR")
library(ROCR)
res2 <- predict(model,training,type="response")
ROCRPred = prediction(res2,training$Y)
ROCRPref = performance(ROCRPred,"tpr","fpr")
plot(ROCRPref,colorize=TRUE,print.utoffs.at=seq(0.1,by=0.1))
