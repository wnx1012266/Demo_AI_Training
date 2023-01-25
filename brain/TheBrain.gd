extends Node
class_name NeuralNetwork

var InputLayer = NeuralNetworkLayer.new()
var	HiddenLayer= NeuralNetworkLayer.new()
var	OutputLayer= NeuralNetworkLayer.new()

export var InputLayerNum = 18
export var HiddenLayerNum = 9
export var OutputLayerNum = 8

#export var enable = false
#export var enableReadPostFileFirst = false

export var enableTrainSet = false
export(String, FILE) var trainDataFile = "res://trainData/trainSet.csv"


# Called when the node enters the scene tree for the first time.
func _ready():
	#Initialize(4, 3, 3);
	Initialize(InputLayerNum, HiddenLayerNum, OutputLayerNum);
	SetLearningRate(0.2);
	SetMomentum(true, 0.9);#??
	if enableTrainSet:
		TrainingSet = ReadTrainSet()
		TrainTheBrain()
	else:
		#read weight from file
		ReadBrainData()
	pass # Replace with function body.

var DamageRate = 0.4;
var TrainingSet =[]


func ReadTrainSet():
	var filename = trainDataFile#"res://trainData/animal2.csv" #res://trainData/animal.csv
	var file = File.new()
	var filecontentSet = []
	
	file.open(filename,File.READ)
	var i = 0
	var header = file.get_csv_line()
	if header.size()<=0 or header[0]=="":
		print("read file error, please ReadTrainSet...")
		return 
		
	while true:
		i+=1
		var content = file.get_csv_line()
		if content.size()<=0 or content[0]=="":
			break
		
		var floatSet = []
		for a in content:
			floatSet.append(convert(a,TYPE_REAL))
		
		filecontentSet.append(floatSet)
	file.close()
	return filecontentSet
	pass
	
	

export(String,FILE) var PreTraining = "res://trainData/animal2/PreTraining.txt"
export(String,FILE) var PostTraining = "res://trainData/animal2/PostTraining.txt"
func TrainTheBrain():
	var	error = 1;
	var		c = 0;	
	
	self.DumpData(PreTraining)#("PreTraining.txt");
	var m = TrainingSet.size()
	while((error > 0.05) and (c<50000)):
		error = 0;
		c=c+1;
		for i in range(0,m):
			var index = 0
			for j in range(0,InputLayerNum):
				self.SetInput(j, TrainingSet[i][j]);
				index+=1

			for x in range(0,OutputLayerNum):
				self.SetDesiredOutput(x, TrainingSet[i][index]);
				index+=1	
	
			self.FeedForward();
			error += self.CalculateError();
			self.BackPropagate();

		error = error / m;

	self.DumpData(PostTraining)#("PostTraining.txt");


export(String,FILE) var PostTraining_dump = "res://trainData/animal2/PostTraining_.txt"
func ReadBrainData():
	var filename = PostTraining#"PostTraining.txt"
	var file = File.new()
	file.open(filename,File.READ)
	while true:
		var strdata = file.get_line()
		if file.eof_reached():
			break
		if strdata =="#start Input weights!!!":
			while true:
				strdata = file.get_line()
				if strdata == "#end Input weights!!!":
					break
				var value_arr = parseWeightData(strdata)
				InputLayer.feedWeightsData(value_arr[0],value_arr[1],value_arr[2])
		
		if strdata == "#start Input Bias weights!!!":
			while true:
				strdata = file.get_line()
				if strdata == "#end Input Bias weights!!!":
					break
				var value_arr = parseBiasData(strdata)
				InputLayer.feedBiasWeightsData(value_arr[0],value_arr[1])
	
		if strdata =="#start Hidden weights!!!":
			while true:
				strdata = file.get_line()
				if strdata == "#end Hidden weights!!!":
					break
				var value_arr = parseWeightData(strdata)
				HiddenLayer.feedWeightsData(value_arr[0],value_arr[1],value_arr[2])
	
		if strdata == "#start Hidden Bias weights!!!":
			while true:
				strdata = file.get_line()
				if strdata == "#end Hidden Bias weights!!!":
					break
				var value_arr = parseBiasData(strdata)
				HiddenLayer.feedBiasWeightsData(value_arr[0],value_arr[1])

	self.DumpData(PostTraining_dump)#("__PostTraining.txt");
	pass

func parseWeightData(strdata:String):
	var ret = [0,0,0]
	#strdata = "(0, 0) = 18.386477"
	var data = strdata.split("=")
	var xy = data[0] as String
	xy = xy.replace("(","")
	xy = xy.replace(")","")
	var xxyy = xy.split(", ")
	ret[0] = convert(xxyy[0],TYPE_REAL)
	ret[1] = convert(xxyy[1],TYPE_REAL)
	ret[2] = convert(data[1],TYPE_REAL)
	return ret

func parseBiasData(strdata:String):
	var ret = [0,0]
	#strdata = "(0) = 4.873817"
	var data = strdata.split("=")
	var xy = data[0] as String
	xy = xy.replace("(","")
	xy = xy.replace(")","")

	ret[0] = convert(xy,TYPE_REAL)
	ret[1] = convert(data[1],TYPE_REAL)
	return ret



var reTrainDataArray = []
func ReTrainTheBrain(inputParams,outputParams):
	#write down the parameter....
	var arrayLine = []
	arrayLine.append_array(inputParams)
	arrayLine.append_array(outputParams)
	reTrainDataArray.append(arrayLine)
	
	var	error = 1;
	var		c = 0;	

	while((error > 0.1) and (c<5000)):
		c=c+1;
		for i in range(inputParams.size()):
			self.SetInput(i, inputParams[i])
			
		for j in range(outputParams.size()):
			self.SetDesiredOutput(j, outputParams[j])

		self.FeedForward();
		error = self.CalculateError();
		self.BackPropagate();		


export(String,FILE) var saveData = "res://trainData/animal2/runtimeReTrainData"#csv
func saveReTrainData():
	var datetime = convert(OS.get_ticks_msec(),TYPE_STRING)
	var file_name = saveData+"_"+datetime+".csv" #"res://trainData/runtimeReTrainData.csv"
	var f = File.new()
	f.open(file_name,File.WRITE)
	for i in reTrainDataArray:
		f.store_csv_line(i)
		
	f.close()
	
	#save the dump weight data...
	var pos = PostTraining_dump.find_last(".txt")
	var tempStr = PostTraining_dump
	tempStr.erase(pos,4)
	var file_name_dumpfile = tempStr +datetime+".txt"
	self.DumpData(file_name_dumpfile)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func Initialize(nNodesInput:int, nNodesHidden:int, nNodesOutput:int):
	InputLayer.NumberOfNodes = nNodesInput;
	InputLayer.NumberOfChildNodes = nNodesHidden;
	InputLayer.NumberOfParentNodes = 0;	
	InputLayer.Initialize(nNodesInput, null, HiddenLayer);
	InputLayer.RandomizeWeights();
	
	HiddenLayer.NumberOfNodes = nNodesHidden;
	HiddenLayer.NumberOfChildNodes = nNodesOutput;
	HiddenLayer.NumberOfParentNodes = nNodesInput;		
	HiddenLayer.Initialize(nNodesHidden, InputLayer, OutputLayer);
	HiddenLayer.RandomizeWeights();
	
	OutputLayer.NumberOfNodes = nNodesOutput;
	OutputLayer.NumberOfChildNodes = 0;
	OutputLayer.NumberOfParentNodes = nNodesHidden;		
	OutputLayer.Initialize(nNodesOutput, HiddenLayer, null);	
	pass
	
func CleanUp():
	InputLayer.CleanUp();
	HiddenLayer.CleanUp();
	OutputLayer.CleanUp();
	pass
	
func SetInput(i:int,value:float):
	if((i>=0) and (i<InputLayer.NumberOfNodes)):
		InputLayer.NeuronValues[i] = value;
	pass
	
func GetOutput(i:int)->float:
	if((i>=0) and (i<OutputLayer.NumberOfNodes)):
		return OutputLayer.NeuronValues[i];

	return -1.0; #// to indicate an error
	pass
	
func SetDesiredOutput(i:int, value:float):
	if((i>=0) and (i<OutputLayer.NumberOfNodes)):
		OutputLayer.DesiredValues[i] = value;

	pass
	
func FeedForward():
	InputLayer.CalculateNeuronValues();
	HiddenLayer.CalculateNeuronValues();
	OutputLayer.CalculateNeuronValues();
	pass
	
func BackPropagate():
	OutputLayer.CalculateErrors();
	HiddenLayer.CalculateErrors();

	HiddenLayer.AdjustWeights();
	InputLayer.AdjustWeights();
	pass
	
func GetMaxOutputID():
	var	maxval;

	maxval = OutputLayer.NeuronValues[0];
	var id = 0;

	for i in range(0,OutputLayer.NumberOfNodes):
		if(OutputLayer.NeuronValues[i] > maxval):
			maxval = OutputLayer.NeuronValues[i];
			id = i;

	return id;
	pass
	
func CalculateError()->float:
	#int		i;
	var	error = 0;

	for i in range(0,OutputLayer.NumberOfNodes):
		error += pow(OutputLayer.NeuronValues[i] - OutputLayer.DesiredValues[i], 2);

	error = error / OutputLayer.NumberOfNodes;

	return error;
	pass
	
func SetLearningRate(rate:float):
	InputLayer.LearningRate = rate;
	HiddenLayer.LearningRate = rate;
	OutputLayer.LearningRate = rate;
	pass
	
func SetLinearOutput(useLinear:bool):
	InputLayer.LinearOutput = useLinear;
	HiddenLayer.LinearOutput = useLinear;
	OutputLayer.LinearOutput = useLinear;
	pass
	
func SetMomentum(useMomentum:bool, factor:float):
	InputLayer.UseMomentum = useMomentum;
	HiddenLayer.UseMomentum = useMomentum;
	OutputLayer.UseMomentum = useMomentum;

	InputLayer.MomentumFactor = factor;
	HiddenLayer.MomentumFactor = factor;
	OutputLayer.MomentumFactor = factor;
	pass

func DumpData(filename):
	var file = File.new()
	file.open(filename,File.WRITE)
	file.store_line("--------------------------------------------------------")
	file.store_line( "Input Layer\n");
	file.store_line("--------------------------------------------------------");
	file.store_line("");
	file.store_line("Node Values:");
	file.store_line("");
	for i in range(0,InputLayer.NumberOfNodes):
		var line = "("+convert(i,TYPE_STRING)+") = "+convert(InputLayer.NeuronValues[i],TYPE_STRING)
		file.store_line(line);
	file.store_line("");
	file.store_line("Weights:");
	file.store_line("#start Input weights!!!");
	for i in range(0,InputLayer.NumberOfNodes):
		for j in range(0,InputLayer.NumberOfChildNodes):
			var line = "("+convert(i,TYPE_STRING)+", "+convert(j,TYPE_STRING)+") = "+convert(InputLayer.Weights[i][j],TYPE_STRING)
			file.store_line(line);
	file.store_line("#end Input weights!!!");
	file.store_line("Bias Weights:");
	file.store_line("#start Input Bias weights!!!");
	for j in range(0,InputLayer.NumberOfChildNodes):
		file.store_line("("+String(j)+") = "+String(InputLayer.BiasWeights[j])+"");

	file.store_line("#end Input Bias weights!!!");
	file.store_line("");

	file.store_line("--------------------------------------------------------");
	file.store_line("Hidden Layer");
	file.store_line("--------------------------------------------------------");
	file.store_line("");
	file.store_line("Weights:");
	file.store_line("#start Hidden weights!!!");
	for i in range(0,HiddenLayer.NumberOfNodes):
		for j in range(0,HiddenLayer.NumberOfChildNodes):
			file.store_line("("+String(i)+", "+String(j)+") = "+String(HiddenLayer.Weights[i][j])+"");
	file.store_line("#end Hidden weights!!!");
	file.store_line("Bias Weights:");
	file.store_line("#start Hidden Bias weights!!!");
	for j in range(0,HiddenLayer.NumberOfChildNodes):
		file.store_line("("+String(j)+") = "+String(HiddenLayer.BiasWeights[j])+"");

	file.store_line("#end Hidden Bias weights!!!");
	file.store_line("");

	file.store_line("--------------------------------------------------------");
	file.store_line("Output Layer");
	file.store_line("--------------------------------------------------------");
	file.store_line("");
	file.store_line("Node Values:");
	file.store_line("");
	for i in range(0,OutputLayer.NumberOfNodes):		
		file.store_line("("+String(i)+") = "+String(OutputLayer.NeuronValues[i])+"");
	file.store_line("");


	file.close()
	pass



class NeuralNetworkLayer:
	var NumberOfNodes:int
	var NumberOfChildNodes:int;
	var NumberOfParentNodes:int;
	var	Weights;#array
	var	WeightChanges;#array
	var NeuronValues;#array
	var DesiredValues;#array
	var Errors;#array
	var BiasWeights;#array
	var BiasValues;#array
	var LearningRate;

	var LinearOutput:bool = false
	var UseMomentum:bool = false
	var	MomentumFactor:float = 0.9#float

	var ParentLayer:NeuralNetworkLayer = null
	var ChildLayer:NeuralNetworkLayer = null
	
	
	func createArray(number,default=0.0):
		var array = []
		for i in range(0,number):
			array.append(default)
		return array
		pass
	
	func Initialize(NumNodes:int, parent:NeuralNetworkLayer,  child:NeuralNetworkLayer):
		NeuronValues = createArray(NumberOfNodes) #(double*) malloc(sizeof(double) * NumberOfNodes);
		DesiredValues = createArray(NumberOfNodes)#(double*) malloc(sizeof(double) * NumberOfNodes);
		Errors = createArray(NumberOfNodes)# (double*) malloc(sizeof(double) * NumberOfNodes);

		if(parent != null):
			ParentLayer = parent;


		if(child != null):
			ChildLayer = child;
			Weights = createArray(NumberOfNodes,null)#(double**) malloc(sizeof(double*) * NumberOfNodes);
			WeightChanges = createArray(NumberOfNodes,null)#(double**) malloc(sizeof(double*) * NumberOfNodes);
			for i in range(0,NumberOfNodes):#for(i = 0; i<NumberOfNodes; i++)
				Weights[i] = createArray(NumberOfChildNodes,0.0) #(double*) malloc(sizeof(double) * NumberOfChildNodes);
				WeightChanges[i] = createArray(NumberOfChildNodes,0.0)#(double*) malloc(sizeof(double) * NumberOfChildNodes);

			BiasValues = createArray(NumberOfChildNodes) #(double*) malloc(sizeof(double) * NumberOfChildNodes);
			BiasWeights = createArray(NumberOfChildNodes)#(double*) malloc(sizeof(double) * NumberOfChildNodes);
		else :
			Weights = null;
			BiasValues = null;
			BiasWeights = null;


		# Make sure everything contains zeros
		for i in range(0,NumberOfNodes):#for(i=0; i<NumberOfNodes; i++)
			NeuronValues[i] = 0;
			DesiredValues[i] = 0;
			Errors[i] = 0;
			
			if(ChildLayer != null):
				for j in range(0,NumberOfChildNodes):
					Weights[i][j] = 0;
					WeightChanges[i][j] = 0;


		if(ChildLayer != null):
			for j in range(0,NumberOfChildNodes):
				BiasValues[j] = -1;
				BiasWeights[j] = 0;
			pass
		
		
		
	func CleanUp():
		NeuronValues = null
		DesiredValues = null
		Errors = null
		Weights = null
		WeightChanges = null
		BiasValues = null
		BiasWeights =null
		
		pass
		
	func RandomizeWeights():
		var	_min = 0;
		var	_max = 200;
		var	number;

		randomize()

		for i in range(0,NumberOfNodes):
			for j in range(0,NumberOfChildNodes):
				number = (((abs(randi())%(_max-_min+1))+_min));    
				if(number>_max):
					number = _max;

				if(number<_min):
					number = _min;		

				Weights[i][j] = number / 100.0 - 1;

		
		for j in range(0,NumberOfChildNodes):
			number = (((abs(randi())%(_max-_min+1))+_min));    
			if(number>_max):
				number = _max;

			if(number<_min):
				number = _min;		
			
			BiasWeights[j] = number / 100.0 - 1;		

		pass
		
		
	func feedWeightsData(i,j,value):
		Weights[i][j] = value
		
	func feedBiasWeightsData(j,value):
		BiasWeights[j] = value
		
	func CalculateErrors():
		var	sum;
		
		if(ChildLayer == null): #output layer
			for i in range(0,NumberOfNodes):
				Errors[i] = (DesiredValues[i] - NeuronValues[i]) * NeuronValues[i] * (1.0 - NeuronValues[i]);
		elif(ParentLayer == null):# { #input layer
			for i in range(0,NumberOfNodes):
				Errors[i] = 0.0;
		else:# { #hidden layer
			for i in range(0,NumberOfNodes):
				sum = 0;
				for j in range(0,NumberOfChildNodes):
					sum += ChildLayer.Errors[j] * Weights[i][j];	
				Errors[i] = sum * NeuronValues[i] * (1.0 - NeuronValues[i]);
		pass
		
	func AdjustWeights():
		var	dw;

		if(ChildLayer != null):
			for i in range(0,NumberOfNodes):
				for j in range(0,NumberOfChildNodes):
					dw = LearningRate * ChildLayer.Errors[j] * NeuronValues[i];
					Weights[i][j] += dw + MomentumFactor * WeightChanges[i][j];			
					WeightChanges[i][j] = dw;

			for j in range(0,NumberOfChildNodes):
				BiasWeights[j] += LearningRate * ChildLayer.Errors[j] * BiasValues[j];
		pass
		
		
	func CalculateNeuronValues():
		var	x;
		
		if(ParentLayer != null):
			for j in range(0,NumberOfNodes):
				x = 0;
				for i in range(0,NumberOfParentNodes):
					x += ParentLayer.NeuronValues[i] * ParentLayer.Weights[i][j];		
						
				x += ParentLayer.BiasValues[j] * ParentLayer.BiasWeights[j];
				
				if((ChildLayer == null) and LinearOutput):
					NeuronValues[j] = x;
				else:
					NeuronValues[j] = 1.0/(1+exp(-x));				
		pass
	
	
	pass





