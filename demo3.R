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

# 运行程序
cdata<-IBM['2010/2012']$Close
title<-"Stock_IBM" #图片标题
sDate<-as.Date("2010-1-1") #开始日期
eDate<-as.Date("2012-1-1") #结束日期

ldata<-ma(cdata,c(5,20,60))  #选择滑动平均指标
dev.off()
drawLine(ldata,title,sDate,eDate) #画图


ldata<-ma(cdata,c(20))  #选择滑动平均指标
drawLine(ldata,title,sDate,eDate) #画图

# 均线图+散点
drawPoint<-function(ldata,pdata,titie,sDate,eDate){
  g<-ggplot(aes(x=Index, y=Value),data=fortify(ldata[,1],melt=TRUE))
  g<-g+geom_line()
  g<-g+geom_line(aes(colour=Series),data=fortify(ldata[,-1],melt=TRUE))
  g<-g+geom_point(aes(x=Index,y=Value,colour=Series),data=fortify(pdata,melt=TRUE))
  g<-g+scale_x_date(labels=date_format("%Y-%m"),breaks=date_breaks("2 months"),limits = c(sDate,eDate))
  g<-g+xlab("") + ylab("Price")+ggtitle(title)
  g
}

# 散点数据
genPoint<-function(ldata){
  pdata<-data.frame(Index=as.Date(array(index(ldata))),Series=array(ifelse(ldata$ma20>ldata$Value,"up","down")),Value=array(ldata$ma20))
  pdata
}
pdata<-genPoint(ldata)
head(pdata)
dev.off()
drawPoint(ldata,pdata,title,sDate,eDate) #画图


#test
# n = c(2, 3, 5) 
# s = c("aa", "bb", "cc") 
# b = c(TRUE, FALSE, TRUE) 
# df = data.frame(n, s, b)       # df is a data frame
# df




#交易信号
Signal<-function(cdata,pdata){
  p=0
  r0<-NULL
  r1<-NULL
  rn<-NULL
  for(i in 1:nrow(pdata)) {
    if(pdata$Series[i]=='down') {
      if( p==0) {
        r0<-c(r0,"B")
        r1<-c(r1,cdata$Close[i])
        rn<-c(rn,index(cdata[i]))
      }
      p<-1
    } 
    if(pdata$Series[i]=='up'){
      if( p==1) {
        r0<-c(r0,"S")
        r1<-c(r1,cdata$Close[i])
        rn<-c(rn,index(cdata[i]))
      }
      p<-0
    }
  }
  res<-data.frame(Value=r1,op=r0)
  rownames(res)<-as.Date(rn)
  return(res)
} 
tdata<-Signal(cdata,pdata)
tdata<-tdata[which(as.Date(row.names(tdata))<eDate),]
head(tdata)
nrow(tdata)


#交易信号

Signal<-function(cdata,pdata){
  p=0
  r0<-NULL
  r1<-NULL
  rn<-NULL
  for(i in 1:nrow(pdata)) {
    if(pdata$Series[i]=='down') {
      if( p==0) {
        r0<-c(r0,"B")
        r1<-c(r1,pdata$Value[i])
        rn<-c(rn,as.Date(index(cdata[i])))
      }
      p<-1
    } 
    if(pdata$Series[i]=='up'){
      if( p==1) {
        r0<-c(r0,"S")
        r1<-c(r1,pdata$Value[i])
        rn<-c(rn,as.Date(index(cdata[i])))
      }
      p<-0
    }
  }
  res<-data.frame(Value=r1,op=r0)
  rownames(res)<-as.Date(rn)
}
tdata<-Signal(cdata,pdata)
tdata<-tdata[which(as.Date(row.names(tdata))<eDate),]
head(tdata)
nrow(tdata)


#模拟交易
#参数：交易信号,本金,持仓比例,手续费比例
trade<-function(tdata,capital=100000,position=1,fee=0.00003){#signal,original cash,holding percent,tax
  amount<-0       #Stock amount
  cash<-capital   #Cash
  
  ticks<-data.frame()
  for(i in 1:nrow(tdata)){
    row<-tdata[i,]
    if(row$op=='B'){
      amount<-floor(cash/row$Value)
      cash<-cash-amount*row$Value
    }
    
    if(row$op=='S'){
      cash<-cash+amount*row$Value
      amount<-0
    }
    
    row$cash<-cash #Cash
    row$amount<-amount #holding shares
    row$asset<-cash+amount*row$Value # asset value
    ticks<-rbind(ticks,row)
  }
  
  ticks$diff<-c(0,diff(ticks$asset)) # asset difference
  
  #Profit action
  rise<-ticks[c(which(ticks$diff>0)-1,which(ticks$diff>0)),]
  rise<-rise[order(row.names(rise)),]
  
  #Lose action
  fall<-ticks[c(which(ticks$diff<0)-1,which(ticks$diff<0)),]
  fall<-fall[order(row.names(fall)),]
  
  
  return(list(
    ticks=ticks,
    rise=rise,
    fall=fall
  ))
}
result1<-trade(tdata,100000)

# 查看每笔交易
head(result1$ticks)
