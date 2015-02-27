#加载工具包
library(plyr)
library(quantmod)
library(TTR)
library(ggplot2)
library(scales)

#下载数据
download<-function(stock,from="2010-01-01"){
  df<-getSymbols(stock,from=from,env=environment(),auto.assign=FALSE)  #下载数据
  names(df)<-c("Open","High","Low","Close","Volume","Adjusted")
  write.zoo(df,file=paste(stock,".csv",sep=""),sep=",",quote=FALSE) #保存到本地
}

#本地读数据
read<-function(stock){  
   as.xts(read.zoo(file=paste(stock,".csv",sep=""),header = TRUE,sep=",", format="%Y-%m-%d"))
}

stock<-"IBM"
download(stock,from='2010-01-01')
IBM<-read(stock)

# 查看数据类型
class(IBM)


# 查看前6条数据
head(IBM)

#简单的蜡烛图
chartSeries(IBM)


#带指标的蜡烛图
chartSeries(IBM,TA = "addVo(); addSMA(); addEnvelope();addMACD(); addROC()")
