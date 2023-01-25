extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
export var HP = 500
export var MAXHP = 500

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	
	$ProgressBar_HP.value = HP
	
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused == true:
			get_tree().paused = false
		else:
			get_tree().paused = true
		
	
	
	get_input()
	velocity = move_and_slide(velocity)

func getHP():
	return float(HP)
	pass
	
func getMAXHP():
	return float(MAXHP)
	pass
