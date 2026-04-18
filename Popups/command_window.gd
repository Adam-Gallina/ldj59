extends Window
class_name CommandWindow

class CommandOutput:
	var Success : bool = true
	var Output : Array[String] = []

	func _init(success:bool=true, output:Array[String]=[]) -> void:
		Success = success
		Output = output


@onready var _history : TextEdit = $CanvasLayer/Output
@onready var _input : LineEdit = $CanvasLayer/LineEdit


func is_open() -> bool: return visible

func open():
	show()
	_input.grab_focus()

func close():
	hide()


func log_message(msg:String):
	_history.text += '\n' + msg


#func process_command(_cmd:String, _args:Array[String]) -> CommandOutput:
#	return null
func _on_command_submitted(new_text:String) -> void:
	var inp = new_text.to_lower().split(' ')
	var cmd = inp[0]
	inp.remove_at(0)
	var args = inp

	_input.text = ''
	log_message('> ' + new_text)

	var processed = false

	for n in get_tree().get_nodes_in_group(Constants.COMMAND_GROUP):
		if !n.has_method(Constants.COMMAND_FUNC): pass

		var output = await n.process_command(cmd, args)
		if output != null:
			for o in output.Output:
				log_message(o)
			processed = true

	if not processed:
		log_message('Unknown command')
