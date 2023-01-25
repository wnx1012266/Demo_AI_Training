extends KinematicBody2D
class_name Enemy


export (NodePath) var BrainPath
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var speed = 150
var velocity = Vector2()
var targetNode = null
var theBrain = null

export var HP = 500.0
export var maxHP = 500.0
export var FriendCount = 0.0
export var maxFriendCount = 10.0

func _ready():
	targetNode = get_parent().get_node("Player")
	theBrain = get_node(BrainPath) as NeuralNetwork
	
	pass


func chase():
	velocity = targetNode.position - position
	velocity = velocity.normalized() * speed
	
func evade():
	velocity = position - targetNode.position
	velocity = velocity.normalized() * speed


func showPropertiesChange():
	$Panel_trainningBtn.visible = true
	pass
	
func closePropertiesChange():
	$Panel_trainningBtn.visible = false

func _physics_process(delta):
	
	$ProgressBar_HP.value = HP
	
	if isMouseOn:
		if Input.is_action_just_pressed("ui_right_click"):
			#get_tree().paused = true
			#speed = 0
			showPropertiesChange()
			
	
	theBrain.SetInput(0,getHPrate())
	theBrain.SetInput(1,getPlayerHPrate())
	theBrain.SetInput(2,getEnemyCount())
	theBrain.FeedForward()
	
	var ID = theBrain.GetMaxOutputID()
	
	match ID:
		0: #干
			$Label_msg.text = "干他"
			chase()
			pass
		1: #滚
			$Label_msg.text = "跑吧"
			evade()
			pass
	
	velocity = move_and_slide(velocity)
	
#0~1.0
func getHPrate():
	var rate = HP/maxHP
	return rate 	

func getEnemyCount():
	var rate = float(FriendCount)/float(maxFriendCount)
	return rate
	
func getPlayerHPrate():
	var rate = targetNode.getHP()/targetNode.getMAXHP()
	return rate



func isEnemy():
	return true

func _on_Area2D_checkFriend_body_entered(body):
#	var classname = body.get_class()
#	print(classname)
	if body.has_method("isEnemy"):
		FriendCount+=1.0
	pass # Replace with function body.


func _on_Area2D_checkFriend_body_exited(body):
	if body.has_method("isEnemy"):
		FriendCount-=1.0
	pass # Replace with function body.


var isMouseOn = false
func _on_Area2D_click_mouse_entered():
	isMouseOn = true
	pass # Replace with function body.


func _on_Area2D_click_mouse_exited():
	isMouseOn = false
	pass # Replace with function body.


func _on_Button_fight_pressed():
	#使用当前输出输入作为训练条目直接训练，按一次训练一次
	var inputParams = [getHPrate(),getPlayerHPrate(),getEnemyCount()]
	var outputParams = [0.9,0.1] #[干他，快跑]
	theBrain.ReTrainTheBrain(inputParams,outputParams)
	pass # Replace with function body.


func _on_Button_run_pressed():
	#使用当前输出输入作为训练条目直接训练，按一次训练一次
	var inputParams = [getHPrate(),getPlayerHPrate(),getEnemyCount()]
	var outputParams = [0.1,0.9] #[干他，快跑]
	theBrain.ReTrainTheBrain(inputParams,outputParams)
	pass # Replace with function body.


func _on_Button_save_pressed():
	theBrain.saveReTrainData()
	pass # Replace with function body.
