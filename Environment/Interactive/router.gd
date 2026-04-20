extends Node3D

@export var RouterID : String
@export var PowerSource : Node3D

func _ready() -> void:
	$Sprite3D/Label3D.text = RouterID

func is_revealed() -> bool:
	return get_node('%Model').layers > 0

func hide_model():
	get_node('%Model').layers = 0
	$Sprite3D.hide()

func reveal_model():
	get_node('%Model').layers = 1
	$Sprite3D.show()


func process_command(cmd:String, args:Array[String]):
	if cmd == 'ping':
		if args.size() > 0 and args[0] == RouterID:
			if PowerSource != null and not PowerSource.is_active():
				return null
			#DoorManager.reveal_model(self)
			return CommandManager.CommandOutput.new(true, [RouterID + ': pong'])

	if cmd == 'reboot':
		if args.size() > 0 and args[0] == RouterID:
			if PowerSource != null and not PowerSource.is_active():
				return null
			
			DoorManager.reveal_model(self)
			return CommandManager.CommandOutput.new(true, [RouterID + ': online'])

	return null