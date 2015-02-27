#例：获取上证A股指数
#上证A股指数的代码为 000002.ss
getSymbols("000002.ss")

#例：获取上证B股指数
#上证B股指数的代码为 000003.ss
getSymbols("000003.ss")

#例：获取上证综合指数
#上证综合指数的代码为 000008.ss
getSymbols("000008.ss")

#例：获取沪深300指数
#沪深300指数的代码为000300.ss。
getSymbols("000300.ss")

getSymbols("^SSEC")

getSymbols("600635.ss")

getSymbols("000300.ss")


# 获取上市公司股息数据
# 
# getDividends函数可以获取上市公司的股息数据。
# 
getDividends("CHL")
# 
# 根据股息调整股票价格
# 
# adjustOHLC函数可以对股票数据进行除息调整。
# 
getSymbols("CHL", from="1990-01-01", src="yahoo")
head(CHL)
head(CHLL.a <- adjustOHLC(CHL))
head(CHL.uA <- adjustOHLC(CHL, use.Adjusted=TRUE))
# 
# 1.1.4 获取上市公司的拆股数据
# 
# 使用getSplits()函数获取上市公司的拆股数据：
# 
getSplits("MSFT")
# 
# 1.1.5 获取上市公司期权交易数据
# 
# 利用getOptionChain()函数可以获取上市公司的期权交易数据：
# 
# #例：获取苹果公司的期权交易数据
AAPL.OPT <- getOptionChain("AAPL")
AAPL.OPTS <- getOptionChain("AAPL", NULL)
# 
# 与此相关的还有options.expiry()函数和futures.expiry()函数：
# 
# #例：
getSymbols("AAPL")
options.expiry(AAPL)
futures.expiry(AAPL)
# AAPL[options.expiry(AAPL)]
# 
# 1.1.6 获取和查看上市公司的财务报表
# 
# quantmod中getFinancials()函数和getFin()函数可以获取上市公司的财务报表数据。看看两个函数的用法：
# 
args(getFinancials)
args(getFin)
# 
# 例子：获取中国移动公司的财务数据
# 
# getFinancials('CHL')
# 
# 获取数据之后，可以通过view.Fin函数查看财务报表数据:
#   
#   view.Fin(CHL.f)
# 
# 1.1.7 从网络获取汇市数据
# 
# getFX()函数可以帮助我们从oanda获取汇率数据。
# 
getFX("USD/JPY")
getFX("EUR/USD",from="2005-01-01")
# 
# 也可以：
# 
getSymbols("USD/EUR",src="oanda")
getSymbols("USD/EUR",src="oanda",from="2005-01-01")
# 
# 1.1.8 获取重金属交易数据
# 
# getMetals()函数可以获取重金属的交易数据。
# 
getFX(c("gold","XPD"))
getFX("plat",from="2005-01-01")
# 
# 1.1.9 获取美联储经济数据
# 
# getSymbols.FRED()函数可以获取美联储主页上的美国经济数据。
# 
getSymbols('CPIAUCNS',src='FRED')
# 
# 或者：
# 
setSymbolLookup(CPIAUCNS='FRED')
getSymbols('CPIAUCNS')
# 
# 1.2 从数据库获取股票数据
# 
# quantmod除了支持从网络数据库直接抓取数据外，当然也支持从本地数据库读入数据。目前，能支持的数据库类型包括：
# 
# MySQL
# SQLite
# csv
# RData
# 
# 对应的函数有以下几个：
# 
# getSymbols.MySQL()：从 MySQL 数据库读取数据
# getSymbols.SQLite()：从 SQLite 数据库读取数据
# getSymbols.csv()：从 csv 文件读取 OHLC 数据
# getSymbols.rda()：读取以 .r 格式存储的数据
# 
# 1.3 查看和移除股票数据
# 1.3.1 查看股票数据
# 
# getSymbols("CHL","000023.ss")
# showSymbols(env=.GlobalEnv)
# 
# # 结果如下：
# # 1.3.2 移除股票数据
# 
# RemoveSymbols("CHL")
# showSymbols(env=.GlobalEnv)
# 
# getQuote("AAPL")
# getQuote("QQQQ;SPY;^VXN",what=yahooQF(c("Bid","Ask")))
# standardQuote()
# yahooQF()
# 
# attachSymbols()
