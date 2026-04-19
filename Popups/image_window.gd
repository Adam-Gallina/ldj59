extends FileWindow

func set_file(filename, filepath):
	title = filename

	$TextureRect.texture = load(filepath)
