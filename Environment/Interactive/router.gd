extends Node3D

@export var RouterID : String
@export var PowerSource : Node3D

func is_revealed() -> bool:
	return get_node('%Model').layers > 0

func hide_model():
	get_node('%Model').layers = 0

func reveal_model():
	get_node('%Model').layers = 1


func process_command(cmd:String, args:Array[String]):
	if cmd == 'ping':
		print(cmd, ' ', args, ' ', args[0] == RouterID, ' ', RouterID)
		if args.size() > 0 and args[0] == RouterID:
			if PowerSource != null and not PowerSource.is_active():
				return null
			DoorManager.reveal_model(self)
			return CommandManager.CommandOutput.new(true, [RouterID + ': pong'])

	return null