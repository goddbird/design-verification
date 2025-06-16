📦 封裝與資料結構相關
yapp_pkg.sv：定義了整個環境中用到的 package，通常會包含所有 class 的 import，並統一做一次 uvm_component_utils 等 macro 的註冊。

yapp_packet.sv：定義了資料封包（packet）的格式與方法，例如資料欄位、比較函數、print 等。

🧩 接口與環境建構
yapp_if.sv：定義了 RTL 與 TB（testbench）之間的 interface，例如 handshake、data 線等訊號。

yapp_env.sv：整合所有 UVM 組件的環境類別，通常包含 agent、monitor、scoreboard 等。

🚗 發送端 (TX) Agent 模組
yapp_tx_agent.sv：定義一個完整的 TX agent，內含 driver、monitor、sequencer。

yapp_tx_driver.sv：實作 driver，負責將 sequence item 寫入 DUT 的訊號中（透過 interface）。

yapp_tx_monitor.sv：實作 monitor，從 interface snoop 資料並發送給分析單元。

yapp_tx_seqs.sv：定義一些測試會用到的 sequence，例如基本封包發送、邊界條件等。

🧪 示範/測試用途檔案
driver_example.sv：應該是一個簡化版或範例 driver 類別。

monitor_example.sv：可能是用來說明或測試 monitor 行為的範例。

