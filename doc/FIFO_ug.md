# FIFO User guide

In the following explanation, a FIFO configured with a memory depth of 4, and indications of almost empty and full of 1, was used.

## Write Side

```
              _   _   _   _   _   _   _   _
wclk_i       | |_| |_| |_| |_| |_| |_| |_| |_
                   _______________
wen_i        _____/               \__________
             _____ ___ ___ ___ ___ __________
data_i       _____X_0_X_1_X_2_X_3_X__________
```

* Write enable (`we_i`) signal must be asserted when you want to write new input data (`data_i`).

```
              _   _   _   _   _   _   _   _   _   _
wclk_i       | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
                   ___________________     ___
wen_i        _____/                   \___/   \______
             _____ ___ ___ ___ ___ ___ _______ ______
data_i       _____X_0_X_1_X_2_X_3_X_4_X___X_5_X______
                           __________________________
afull_o      _____________/
                               ______________________
full_o       _________________/
                                   ___     ___
overflow_o   _____________________/   \___/   \______
```

* Ideally, you must check a not full (`full_o == 0`) condition before to assert write enable.
* If you asserts write enable during a full condition (`full_o == 1`), an overflow condition (`overflow_o == 1`) will be signalled, and the incoming data will be discarded.
* The almost full (`afull_o`) signal is a configurable early indication, that could be useful to ensure how many input data you can write before a full condition.

## Read Side

```
              _   _   _   _   _   _   _   _  
rclk_i       | |_| |_| |_| |_| |_| |_| |_| |_
                   _______________
ren_i        _____/               \__________
                       _______________
valid_o      _________/               \______
             _________ ___ ___ ___ ___ ______
data_o       _________X_0_X_1_X_2_X_3_X______
```

* A new output data is available the second cycle after an assertion of read enable (`ren_i`) signal.
* The valid output data (`valid_o`) indication is useful to know when a new output data is available.

```
              _   _   _   _   _   _   _   _   _   _
rclk_i       | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
                   ___________________     ___
ren_i        _____/                   \___/   \______
                       _______________
valid_o      _________/               \______________
             _________ ___ ___ ___ ___ ______________
data_o       _________X_0_X_1_X_2_X_3_X______________
                           __________________________
aempty_o     _____________/
                               ______________________
empty_o      _________________/
                                   ___     ___
underflow_o  _____________________/   \___/   \______
```

* Ideally, you must check a not empty (`empty_o == 0`) condition before to assert read enable.
* If you asserts read enable during an empty condition (`empty_o == 1`), an underflow condition (`underflow_o == 1`) will be signalled, and valid output data not will be signalled.
* The almost empty (`aempty_o`) signal is a configurable late indication, that could be useful to ensure how many output data you can read before an empty condition.

**NOTE:** Empty, almost empty and underflow indications depends on read enable assertions.
