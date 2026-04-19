extends PopupWindow
class_name FileWindow

func set_file(filename, filepath):
	title = filename
	var file = FileAccess.open(filepath, FileAccess.READ)
	var content = file.get_as_text()
	$TextEdit.text =  content
