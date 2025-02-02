Author: Yilin Li
SID: 530536402
Unikey: yili2677



**Test Cases**
Table 1. Summary of test cases for `buy_cheese` function in `shop.py`. 	

| Test ID | Description                                | Inputs     | Expected Output                                                                                          | Status  |
| ------- | ------------------------------------------ | ---------- | ---------------------------------------------------------------------------------------------------------| ------- |
| 01      | buy 2 marble - Positive Case               | marble 2   | Successfully purchase 2 marble.<br/>You have 25 gold to spend.<br/>return value: (100, (0, 2, 0)         | Success |
| 02      | buy 10 cheddar - Positive Case             | cheddar 10 | Successfully purchase 10 cheddar. <br/>You have 25 gold to spend.<br/>return value: (100, (10, 0, 0)     | Success |
| 03      | buy swiss with no quantity - Negative Case | swiss      | Missing quantity.<br/>return value: (0, (0, 0, 0)                                                        | Success |
| 04      | buy 0 marble - Negative Case               | marble 0   | Must purchase positive amount of cheese.<br/>You have 125 gold to spend.<br/>return value: (0, (0, 0, 0) | Success |
| 05      | buy 1 cheddar - Edge Case                  | cheddar 1  | Successfully purchase 1 cheddar.<br/>You have 115 gold to spend.<br/>return value: (10, (1, 0, 0)        | Success |
| 06      | buy 12 cheddar - Edge Case                 | cheddar 12 | Successfully purchase 12 cheddar.<br/>You have 5 gold to spend.<br/>return value: (120, (12, 0, 0)       | Success |

Table 2. Summary of test cases for `change_cheese` function in `game.py`.
| Test ID | Description                                                                                                                                                      | Inputs           | Expected Output                                                                                                                                                                        | Status  |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| 01      | arm a cheddar with having 4 cheddar cheeses in the inventory (Cheddar - 4) and confirm - Positive Case<br />cheese = ['Cheddar', 1], ['Marble', 0], ['Swiss', 0] | cheddar<br/>yes  | Type cheese name to arm trap: #CHEDDAR<br/>Do you want to arm your trap with Cheddar? #yes<br/>Cardboard and Hook Trap is now armed with Cheddar!<br />return value: [True, "Cheddar"] | Success |
| 02      | arm a marble with having 2 marble cheeses in the inventory (Marble - 2) and confirm - Positive Case<br />cheese = ['Cheddar', 0], ['Marble', 1], ['Swiss', 0]    | marble<br/>yes   | Type cheese name to arm trap: #MARBLE<br/>Do you want to arm your trap with Marble? #yes<br/>Cardboard and Hook Trap is now armed with Marble!<br />return value: [True, "Marble"]     | Success |
| 03      | put an invalid input 'brie' that does not catch - Negative Case<br />cheese = ['Cheddar', 1], ['Marble', 0], ['Swiss', 0]                                        | brie             | Type cheese name to arm trap: #brie<br/>No such cheese!<br />return value: [False, None]                                                                                               | Success |
| 04      | arm a marble with having 0 marble cheese in the inventory (Marble - 0) - Negative Case<br />cheese = ['Cheddar', 0], ['Marble', 0], ['Swiss', 0]                 | marble           | Type cheese name to arm trap: #MARBLE<br/>Out of cheese!<br />return value: [False, None]                                                                                              | Success |
| 05      | enter command 'back' to end the function - Edge Case<br />cheese = ['Cheddar', 1], ['Marble', 2], ['Swiss', 0]                                                   | back             | Type cheese name to arm trap: #back                                                                                                                                                    | Success |
| 06      | arm a cheddar with having 1 cheddar cheeses in the inventory and provide an invalid input (e.g., stop) on confirmation.                                          |                  |
          | Due to this input isn't considered, so will be back to the beginning output of the function - Edge Case                                                          |                  |
          |  cheese = ['Cheddar', 1], ['Marble', 1], ['Swiss', 0]                                                                                                            |cheddar<br/>stop  | Type cheese name to arm trap: #CHEDDAR<br/>Do you want to arm your trap with Cheddar? #stop<br/>(back to display the current quantity of cheese)                                       | Success |
