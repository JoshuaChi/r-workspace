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
head(IBM)
# IBM['2010/2012']$Close
# class(IBM['2010/2012']$Close)

#移动平均
ma<-function(cdata,mas=c(5,20,60)){ 
  ldata<-cdata
  for(m in mas){
    ldata<-merge(ldata,SMA(cdata,m))
  }
  ldata<-na.locf(ldata, fromLast=TRUE)
  names(ldata)<-c('Value',paste('ma',mas,sep=''))
  return(ldata)
}

# 均线图
drawLine<-function(ldata,titie="Stock_MA",sDate=min(index(ldata)),eDate=max(index(ldata)),out=FALSE){
  g<-ggplot(aes(x=Index, y=Value),data=fortify(ldata[,1],melt=TRUE))
  g<-g+geom_line()
  g<-g+geom_line(aes(colour=Series),data=fortify(ldata[,-1],melt=TRUE))
  g<-g+scale_x_date(labels=date_format("%Y-%m"),breaks=date_breaks("2 months"),limits = c(sDate,eDate))
  g<-g+xlab("") + ylab("Price")+ggtitle(title)
  
  if(out) ggsave(g,file=paste(titie,".png",sep=""))
  else g
}

# 运行程序
# cdata<-IBM['2010/2012']$Close
# cdata<-IBM['2012-02/2012-02-10']$Close
# cdata
# data<-SMA(cdata, 2)
# data
# data<-merge(data, SMA(cdata, 3))
# data
# data <- na.locf(data, fromLast=TRUE)
# data
# names(data)<-c(paste('ma',c(2,3),sep=''))
# data

cdata<-IBM['2010/2012']$Close
title<-"Stock_IBM" #图片标题
sDate<-as.Date("2010-1-1") #开始日期
eDate<-as.Date("2012-1-1") #结束日期

ldata<-ma(cdata,c(5,20,60))  #选择滑动平均指标
head(ldata)
drawLine(ldata,title,sDate,eDate) #画图
