library(tidyverse)
library(mosaic)
library(corrplot)
library(glmnet)
library(plyr)
library(scales)
library(ggrepel)
library(psych)
library(Rmisc)
library(caret)
library(foreach)
library(LICORS)




path = 'C:/Users/thinkpad/Desktop/SDS 323/Project/train.csv'
df = read.csv(path, stringsAsFactors=FALSE)
dim(df)


# numerical variables
num_Vars <- which(sapply(df, is.numeric)) #index vector numeric variables
num_VarNames <- names(num_Vars)
df_num = subset(df, select = num_VarNames)


### data preprocessing
df$PoolQC[is.na(df$PoolQC)] = 'None'
Quality = c('None'=0, 'Po'=1, 'Fa'=2, 'TA'=3, 'Gd'=4, 'Ex'=5)
df$PoolQC = as.integer(revalue(df$PoolQC, Quality))
table(df$PoolQC)

df$MiscFeature[is.na(df$MiscFeature)] = 'None'
df$MiscFeature = as.factor(df$MiscFeature)

df$Alley[is.na(df$Alley)] = 'None'
df$Alley = as.factor(df$Alley)

df$Fence[is.na(df$Fence)] = 'None'
df$Fence = as.factor(df$Fence)

df$FireplaceQu[is.na(df$FireplaceQu)] = 'None'
df$FireplaceQu = as.integer(revalue(df$FireplaceQu, Quality))
table(df$FireplaceQu)

df$LotShape = as.integer(revalue(df$LotShape, c('IR3'=0, 'IR2'=1, 'IR1'=2, 'Reg'=3)))
table(df$LotShape)
df$LotConfig = as.factor(df$LotConfig)

df$GarageType[is.na(df$GarageType)] = 'None'
df$GarageType = as.factor(df$GarageType)
table(df$GarageType)

df$GarageFinish[is.na(df$GarageFinish)] <- 'None'
Finish = c('None'=0, 'Unf'=1, 'RFn'=2, 'Fin'=3)
df$GarageFinish = as.integer(revalue(df$GarageFinish, Finish))
table(df$GarageFinish)

df$GarageQual[is.na(df$GarageQual)] = 'None'
df$GarageQual = as.integer(revalue(df$GarageQual, Quality))
table(df$GarageQual)
df$GarageCond[is.na(df$GarageCond)] = 'None'
df$GarageCond = as.integer(revalue(df$GarageCond, Quality))
table(df$GarageCond)

# basement vars
df$BsmtFinType2[333] = names(sort(-table(df$BsmtFinType2)))[1]
df$BsmtExposure[949] = names(sort(-table(df$BsmtExposure)))[1]
df$BsmtQual[is.na(df$BsmtQual)] = 'None'
df$BsmtQual = as.integer(revalue(df$BsmtQual, Quality))
table(df$BsmtQual)
df$BsmtCond[is.na(df$BsmtCond)] = 'None'
df$BsmtCond = as.integer(revalue(df$BsmtCond, Quality))
table(df$BsmtCond)
df$BsmtExposure[is.na(df$BsmtExposure)] = 'None'
Exposure = c('None'=0, 'No'=1, 'Mn'=2, 'Av'=3, 'Gd'=4)
df$BsmtExposure = as.integer(revalue(df$BsmtExposure, Exposure))
table(df$BsmtExposure)
df$BsmtFinType1[is.na(df$BsmtFinType1)] = 'None'
FinType = c('None'=0, 'Unf'=1, 'LwQ'=2, 'Rec'=3, 'BLQ'=4, 'ALQ'=5, 'GLQ'=6)
df$BsmtFinType1 = as.integer(revalue(df$BsmtFinType1, FinType))
df$BsmtFinType2[is.na(df$BsmtFinType2)] = 'None'
FinType = c('None'=0, 'Unf'=1, 'LwQ'=2, 'Rec'=3, 'BLQ'=4, 'ALQ'=5, 'GLQ'=6)
df$BsmtFinType2 = as.integer(revalue(df$BsmtFinType2, FinType))

df$BsmtFullBath[is.na(df$BsmtFullBath)] = 0
df$BsmtHalfBath[is.na(df$BsmtHalfBath)] = 0
df$BsmtFinSF1[is.na(df$BsmtFinSF1)] = 0
df$BsmtFinSF2[is.na(df$BsmtFinSF2)] = 0
df$BsmtUnfSF[is.na(df$BsmtUnfSF)] = 0
df$TotalBsmtSF[is.na(df$TotalBsmtSF)] = 0

df$MasVnrArea[is.na(df$MasVnrArea)] = 0

df$MSZoning[is.na(df$MSZoning)] = names(sort(-table(df$MSZoning)))[1]
df$MSZoning = as.factor(df$MSZoning)

df$KitchenQual[is.na(df$KitchenQual)] = 'TA' 
df$KitchenQual = as.integer(revalue(df$KitchenQual, Quality))

df$Functional[is.na(df$Functional)] = names(sort(-table(df$Functional)))[1]
df$Functional = as.integer(revalue(df$Functional, c('Sal'=0, 'Sev'=1, 'Maj2'=2, 'Maj1'=3, 'Mod'=4, 'Min2'=5, 'Min1'=6, 'Typ'=7)))

df$Exterior1st[is.na(df$Exterior1st)] = names(sort(-table(df$Exterior1st)))[1]
df$Exterior1st = as.factor(df$Exterior1st)
df$Exterior2nd[is.na(df$Exterior2nd)] = names(sort(-table(df$Exterior2nd)))[1]
df$Exterior2nd = as.factor(df$Exterior2nd)
df$ExterQual = as.integer(revalue(df$ExterQual, Quality))
df$ExterCond = as.integer(revalue(df$ExterCond, Quality))

df$Electrical[is.na(df$Electrical)] = names(sort(-table(df$Electrical)))[1]
df$Electrical = as.factor(df$Electrical)

df$SaleType[is.na(df$SaleType)] = names(sort(-table(df$SaleType)))[1]
df$SaleType = as.factor(df$SaleType)
df$SaleCondition = as.factor(df$SaleCondition)

df$HeatingQC = as.integer(revalue(df$HeatingQC, Quality))


# remove PoolQC, LotFrontage, GarageYrBlt, MasVnrType, Utilities
df = subset(df, select = -c(PoolQC,LotFrontage,GarageYrBlt,MasVnrType,Utilities))
dim(df)
df = na.omit(df)
dim(df)



### visualization
# price
ggplot(data=df, aes(x=SalePrice)) +
  geom_histogram(fill='#46ACC9', color='black', binwidth=10000) +
  scale_x_continuous(breaks= seq(0, 800000, by=100000), labels=scales::comma)
summary(df$SalePrice)





## correlation
# corr matrix
corr = cor(df_num)
cor_sorted <- as.matrix(sort(corr[, 'SalePrice'], decreasing=TRUE))
# select only high corelations
CorHigh <- names(which(apply(cor_sorted, 1, function(x) abs(x)>0.5)))
corr_high <- corr[CorHigh, CorHigh]
# correlation plot
# pdf('correlation plot.pdf')
col = colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(corr_high, method="color", col=col(200), type="upper", number.cex=0.5,
         addCoef.col="black", tl.col="gray", diag=FALSE )
# dev.off()
# Overall Qualoty, Living Area above ground


## plots
# Overall Quality
p1 = ggplot(data=df, aes(x=as.factor(OverallQual), y=SalePrice))+
  geom_boxplot() + 
  labs(x='Overall Quality', y='Sale Price') +
  scale_y_continuous(breaks=seq(0, 800000, by=100000), labels=scales::comma)

# Ground Liv Area
p2 = ggplot(data=df, aes(x=GrLivArea, y=SalePrice))+
  geom_point(size=1, color='#46ACC9') +
  geom_text_repel(aes(label=ifelse(GrLivArea>4500, rownames(df), '')), size=3) +
  geom_smooth(method = 'lm', se=FALSE, color='red', size=0.8) +
  scale_y_continuous(breaks=seq(0, 800000, by=100000), labels=scales::comma)

layout = matrix(c(1,2),1,2,byrow=TRUE)
multiplot(p1, p2, layout=layout)


## features
# bath
df$TotalBath = df$FullBath+df$BsmtFullBath+0.5*(df$HalfBath+df$BsmtHalfBath)
df$Remod = ifelse(df$YearBuilt==df$YearRemodAdd, 0, 1)
df$Age = as.numeric(df$YrSold)-df$YearRemodAdd

df$NeighRich[df$Neighborhood %in% c('StoneBr', 'NridgHt', 'NoRidge')] = 2
df$NeighRich[!df$Neighborhood %in% c('MeadowV', 'IDOTRR', 'BrDale', 'StoneBr', 'NridgHt', 'NoRidge')] = 1
df$NeighRich[df$Neighborhood %in% c('MeadowV', 'IDOTRR', 'BrDale')] = 0

df$TotalPorchSF = df$OpenPorchSF + df$EnclosedPorch + df$X3SsnPorch + df$ScreenPorch

df = subset(df, select=-c(FullBath,BsmtFullBath,HalfBath,BsmtHalfBath))
df = subset(df, select=-c(OpenPorchSF,EnclosedPorch,X3SsnPorch,ScreenPorch))


### data for modeling
dropVars = c('YearRemodAdd','GarageArea','GarageCond','Id','YrSold',
              'TotalBsmtSF', 'TotalRmsAbvGrd', 'BsmtFinSF1','YearBuilt')
df = df[, !(names(df) %in% dropVars)]
df = df[-c(524, 1299),]
dim(df)






num_VarNames = num_VarNames[!(num_VarNames %in% c('MSSubClass', 'MoSold', 'YrSold', 'SalePrice', 'OverallQual', 'OverallCond'))] 
num_VarNames = append(num_VarNames, c('Age','TotalPorchSF','TotBath'))
df_num = df[, names(df) %in% num_VarNames]
df_factor = df[, !(names(df) %in% num_VarNames)]
df_factor = df_factor[, names(df_factor) != 'SalePrice']




#  Skewness and normalizing of the numeric predictors
for(i in 1:ncol(df_num)){
  if(abs(skew(df_num[, i])) > 0.8){
    df_num[, i] = log(df_num[, i]+1)
    }
}

Num = preProcess(df_num, method=c("center", "scale"))
df_sc = predict(Num, df_num)
dim(df_sc)

#  One hot encoding the categorical variables
df_dum = as.data.frame(model.matrix(~(.-1), df_factor))
fewOnes = which(colSums(df_dum[1:nrow(df[!is.na(df$SalePrice),]),])<10)
colnames(df_dum[fewOnes])
df_dum = df_dum[, -fewOnes]
dim(df_dum)


SalePrice = df$SalePrice
df_all = cbind(df_sc, df_dum, SalePrice)
dim(df_all)


## price
qqnorm(df_all$SalePrice)
qqline(df_all$SalePrice)

df_all$SalePrice = log(df_all$SalePrice) 
qqnorm(df_all$SalePrice)
qqline(df_all$SalePrice)




### model


### RMSE function
rmse = function(y, yhat) 
{
  sqrt(mean(data.matrix((y-yhat)^2) ))
}


X = model.matrix( ~ (.-SalePrice), data=df_all)[,-1]
y = df_all$SalePrice

lasso = cv.glmnet(X, y, alpha=1, standardize=FALSE)
plot(lasso)
yhat_lasso = predict(lasso, X)
rmse(yhat_lasso, y)



## split
n = nrow(df_all)
n_train = round(0.8*n)
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
D_train = df_all[train_cases,]
D_test = df_all[test_cases,]


# lm
lm = lm(SalePrice ~ (.), data=D_train)
yhat = predict(lm, D_test)
rmse(yhat, D_test$SalePrice)


rmse_vals = do(100)*
  {
    n = nrow(df_all)
    n_train = round(0.8*n)
    n_test = n - n_train
    train_cases = sample.int(n, n_train, replace=FALSE)
    test_cases = setdiff(1:n, train_cases)
    D_train = df_all[train_cases,]
    D_test = df_all[test_cases,]
    X_train = model.matrix( ~ (.-SalePrice), data=D_train)[,-1]
    y_train = D_train$SalePrice
    X_test = model.matrix( ~ (.-SalePrice), data=D_test)[,-1]
    y_test = D_test$SalePrice
    
    scx = model.matrix(SalePrice ~ .-1, data=D_train) 
    scy = D_train$SalePrice 
    
    
    # fit to training set
    # lasso = cv.glmnet(X_train, y_train, nfold=10, standardize=FALSE)
    # ridge = glmnet(X_train, y_train, alpha=0, standardize=FALSE)
    # lm = lm(SalePrice ~ (.), data=D_train)

    # predict on test set
    yhat_lasso = predict(lasso, X_test)
    # yhat_ridge = predict(ridge, X_test)
    yhat_lm = predict(lm, D_test)

    c(rmse(yhat_lasso, y_test),
      # rmse(yhat_ridge, y_test),
      rmse(yhat_lm, D_test$SalePrice)
    )
  }
colMeans(rmse_vals)
