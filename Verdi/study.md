# Introduction
Verdi是一個業界常用的debug工具，通常會搭配Synopsys的VCS或是Cadance的NC來做simulation。有利於追蹤複雜的電路，以及查看各種Singal的變化。其功能多樣，包含了類比及數位設計的debug分析，並且具有DVE能進行coverage的驗證，也可以支援UVM的驗證。
下圖是Verdi具有的功能，主要是會吃以下三個檔案

Design的.v檔(Verilog)
test case的.v或.sv檔(System Verilog)
compiler產生的.fsdb檔(Wave)。


# Shortcut Key
通常習慣上會使用 Windows > Hardware Debug Mode，但我習慣直接在開啟後使用快捷鍵
"Ctrl+Alt+H"，Verdi就會直接叫出instance。
開出nWave後記得要load Signal才會有波型，也就是讀入fsdb檔。
在應用上，不會關閉Verdi介面，會在Verdi找到要改的電路，開gvim修改後，再重新reload一次。



** 所有訊號在Wave和Design切換都可用滑鼠中鍵拖曳 **

# Code方面的快捷鍵

重新Reload Design: shift+l
搜尋訊號: /
多選訊號: 按住ctrl+左鍵點選
框選訊號: 左鍵按住，下拉框選
拉訊號: ctrl+w (ctrl+4)
顯示/關閉 當前數值: x
# Wave方面的快捷鍵

讀取fsdb: o
讀取rc: r
保存rc: shift+s
打開找訊號視窗: g (不常用)
標記訊號: shift+m
顯示/關閉 訊號路徑: h/H
選擇/隨機 訊號顏色: c/t
框選訊號: 左鍵按住，下拉框選
跳轉code: 雙擊singal
Search Signal方面的快捷鍵

移動cursor到wave開頭: b
移動cursor到wave結尾: e
跟隨Wave falling 向前/向後: N/n
放大/縮小 scale: Z/z
放大訊號: 左鍵按住，框想放大的wave區間
cursor置中: yy
全顯示: f
# Tool Bar使用說明

左一 資料夾圖示: 開檔案
左二 Wave圖示: 開nWave
左三 Gate圖示: 開nSchema (不常用)
左四 Tree圖示: code處選某個訊號後，可以查看temporal Flow View (不常用)
左九 綠底白色向上箭頭: 追某訊號的源頭 (階層跳轉，追端點的時候用)
左十 綠底白色項下箭頭: 追某訊號的最底端 (階層跳轉，追端點的時候用)
左十一 綠色左箭頭: 回上一動 (階層跳轉)
左十二 綠色右箭頭: 回下一動 (階層跳轉)
左十三 D字符號: Drive到上一級 (階層跳轉，最常使用)
左十四 L字符號: Load到下一級 (階層跳轉，最常使用)
左十五 綠園底白色向上箭頭: 找上一個出現的相同訊號 (同個階層)
左十六 綠園底白色向下箭頭: 找下一個出現的相同訊號 (同個階層)
左十七 籃底雙方框向上: 追上一層 (ckeck 連線使用)
左十八 籃底雙方框向下: 追下一層 (ckeck 連線使用)
右五 白色搜尋框: 將訊號抓置此處，可以搜尋當前階層出現的位置
右四 搜尋圖示: 配合右五使用，向上搜尋
右三 搜尋圖示: 配合右五使用，向下搜尋


# Other Setting
量測訊號寬度(時間): 利用滑鼠左鍵跟中鍵可以分別移動cursor跟Marker，兩者時間差會顯示在上方。
設定選單: 選擇訊號，右鍵 > 可以叫出選單(Radix, Notation等常用功能)
訊號Group: 拖曳訊號到最下面會自動產生新的Group
切換Group: 滑鼠中鍵可以選擇Group
重命名Group: 在Group的地方，右鍵 > Rename
增加控掰分隔: 在Wave的地方，右鍵 > Add Blank，讓訊號分組看起來更清晰
Example
https://blog.csdn.net/weixin_38055514/article/details/123487801
https://blog.csdn.net/qq_33300585/article/details/128949131
