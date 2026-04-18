extends Window
class_name CommandWindow

class CommandOutput:
	var Success : bool = true
	var Output : Array[String] = []

	func _init(success:bool=true, output:Array[String]=[]) -> void:
		Success = success
		Output = output


@onready var _history : TextEdit = $CanvasLayer/Output
var _command_history : Array[String] = []
var _curr_command = -1
@onready var _input : LineEdit = $CanvasLayer/LineEdit


func _process(_delta: float) -> void:
	if _command_history.size() > 0:
		if Input.is_action_just_pressed('previous_command'):
			_curr_command -= 1
			if _curr_command <= 0: _curr_command = 0
			fill_from_history(_curr_command)
		if Input.is_action_just_pressed('next_command'):
			_curr_command += 1
			if _curr_command >= _command_history.size(): _curr_command = _command_history.size()
			fill_from_history(_curr_command)


func is_open() -> bool: return visible

func open():
	show()
	_input.grab_focus()

func close():
	hide()


func log_message(msg:String):
	_history.text += '\n' + msg
	_history.get_v_scroll_bar().value = _history.get_v_scroll_bar().max_value

func fill_from_history(i):
	if i < 0: i = 0
	
	if i >= _command_history.size():
		_input.text = ''
	else:
		_input.text = _command_history[i]




#func process_command(_cmd:String, _args:Array[String]) -> CommandOutput:
#	return null
func _on_command_submitted(new_text:String) -> void:
	var inp = new_text.to_lower().split(' ')
	var cmd = inp[0]
	inp.remove_at(0)
	var args = inp

	_input.text = ''
	log_message('> ' + new_text)
	_command_history.append(new_text)
	_curr_command = _command_history.size()

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
