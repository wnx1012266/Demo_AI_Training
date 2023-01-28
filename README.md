# Demo_AI_Training
This is a game AI demo implemented using neural networks in Godot 3.5

Here is the usage of theBrain.tscn:

1.设置

![image](https://user-images.githubusercontent.com/6381922/215272553-ac677f5f-55ad-4350-81bf-390196d8188d.png)

Input Layer Num:
    输入层节点数量(参数).
  
Hidden Layer Num:
    隐藏层节点数量 (尽量和Output Layer Num 不要差太多）.
  
Output Layer Num:
    输出层节点数量(决策行为）.

Enable Train Set:
    如果勾选，则会读取Train Data File 里面的文件值，用来做训练数据, 按顺序重复训练5000次，直到收敛.
    注意：勾选后，每次一开始都会随机化节点值和权重值，所以有可能同一个训练集训出来的结果会不一样.
		
Train Data File:
    按每行[输入1，输入2，输入3，输出1，输出2]的方式数组排列， 会根据Input Layer Num 和 Output Layer Num 更改对应的输入输出位置
                    如：Input Layer Num = 5, Outpu Layer Num = 4时
                    则csv按此排列[输入1，输入2，输入3，输入4，输入5，输出1，输出2，输出3，输出4]
                    每行一个训练数据
                    用0.1表示非，用0.9表示真
                    
Pre Training      :使用训练集前随机生成的节点值和权重值.

Post Training     :使用训练好的结果， 注意当Enable Train Set 勾选时，Post Training会被复写，如果你已经训练好一个结果，记得另存，或者再次运行前记得取消Enable Train Set,
                    当Enable Train Set 取消勾选时，意味着AI将使用Post Training 里的文件作为Ai执行.
										
Post Training Dump : 当aveReTrainData() 函数被调用，则将当前训练的结果保存到该文件，文件名后面会加数字用于区分,

Save Data          : 当saveReTrainData（）函数被调用，保存当前新增的训练条目集到csv文件.



2.代码使用

![image](https://user-images.githubusercontent.com/6381922/215274146-54b3bbe2-c1c3-4932-b857-0abd004c6665.png)

setInput()里的 0,1,2 代表input params的索引


3.训练与保存

![image](https://user-images.githubusercontent.com/6381922/215274363-68d7dddd-4fba-42af-b494-d4ef9ad9fa6e.png)

