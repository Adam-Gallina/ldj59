extends Node

@onready var _message_window = get_node('../MessageWindow')

@onready var _tut_1 = $CanvasLayer/WelcomeMessage
@onready var _tut_2 = $CanvasLayer/WelcomeMessage2
@onready var _win = $CanvasLayer/WinMessage

@export var DEBUG_fast_forward = false

@onready var _scary_door1 = get_node('../Doors/Door7')
@onready var _scary_door2 = get_node('../Doors/Door5')
@onready var _scary_door3 = get_node('../Doors/Door15')

func _ready() -> void:
	_tut_1.hide()
	_tut_2.hide()
		
	var puter = get_node('../Rooms/Room12/LabComputer')
	puter.boom.connect(boom)


func delay_message(delay, message):
	_message_window.set_typing(true)
	if not DEBUG_fast_forward:
		await get_tree().create_timer(delay * 1.5).timeout
	_message_window.log_message(message)



func start_tutorial():
	if DEBUG_fast_forward:
		await get_tree().create_timer(2).timeout
		boom()
		return

	_tut_1.show()

	while true:
		if Input.is_action_just_released('pan'):
			break
		await get_tree().process_frame

	_tut_1.hide()
	_tut_2.show()

	await delay_message(1, 'You\'re online! Wasn\'t going to say anything up here...but the boys were taking bets on whether or not the elevator cable would last until the bottom')
	
	await get_node('../CanvasLayer/MessageButton').pressed

	_tut_2.hide()

	ping()

func ping():
	get_tree().get_nodes_in_group(Constants.DRONE_GROUP)[0].destroyed.connect(_on_drone_destroyed)

	await delay_message(3, 'Yeah apparently it took some hits when the lab was evacuated')
	await delay_message(2.75, 'But that\'s old news now! Let\'s see how the M0NK3 liked the journey')
	await delay_message(2.5, 'Go ahead and try pinging it...I know it\'s an older system but shouldn\'t be too much of a hassle')
	await delay_message(2.5, 'I\'m just glad they had these old drones laying around, otherwise you\'d be going in yourself...')
	
	await delay_message(3, 'Alright, here we go')
	await delay_message(1.25, '"To identify if your new M0NK3 is connected to the M0NK3_CONTROL v2, simply select CMD on your M0NK3_CONTROL v2 terminal, then input ping and the ID of the M0NK3"')
	await delay_message(5.25, 'Wordy aren\'t they. We set that M0NK3 to m1, so looks like pressing "CMD", then "ping m1" should do it')
	_message_window.set_typing(false)
	var cmd : String = ''
	while cmd != 'ping m1':
		cmd = await CommandManager.command_raw_sent

	await delay_message(1, 'And there\'s the pong! Wasn\'t going to say anything up here...but if the drone broke you would still have to go inside yourself')
	await delay_message(4.75, 'But that\'s old news now! Let\'s start checking out the lab')

	move()

func move():
	await delay_message(3.5, 'Go ahead and run a scan on the elevator door to get an idea of the layout behind it')
	await delay_message(1.75, 'The command is "scan <DoorID>". Your map should show the door\'s ID on the network')
	_message_window.set_typing(false)
	var cmd = ''
	while cmd != 'scan d1':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'scan d1':
			await delay_message(.5, 'I\'ve got d1 on my map, try "scan d1"')
			_message_window.set_typing(false)
	
	await delay_message(1, 'Boring old hallways. Thought a secret lab underground would at least have a lava moat or something.')
	await delay_message(3, 'Now back to the M0NK3. It might be an old model, but the onboard navigation is still state o the art')
	await delay_message(2, 'Let\'s send it out to meet Mr. Boring Hallway')

	await delay_message(2.25, 'Assuming you read the briefing, you\'ll know they were able to somewhat isolate the "Specimens"')
	await delay_message(2, '"Specimens".  Not a lava moat, but at least more fitting for an underground lab')
	await delay_message(2.5, 'We rigged up your terminal to interface with the local network, so just typing "open d1" will get the door opened')
	_message_window.set_typing(false)
	while cmd != 'open d1':
		cmd = await CommandManager.command_raw_sent

	await delay_message(.5, 'And "close" will do just the opposite if you need. You can also get away with typing the door ID, the network can pull it\'s own weight sometimes')

	await delay_message(3, 'Door open, so onwards and upwards we go')
	await delay_message(2.5, '"To send a command to you M0NK3, first type the ID of that M0NK3, then the command, then any arguments"')
	await delay_message(3.25, 'There\'s a handful of commands indexed, I\'ll go ahead and send the file to your DATA folder. Try getting to room "r2"')

	DataWindow.add_file('M0NK3_COMMANDS.txt', 'res://Popups/Documents/basic_commands.txt')
	_message_window.set_typing(false)
	var fails = 0
	while cmd != 'm1 move r2':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'm1 move r2':
			fails += 1
			if fails == 1:
				await delay_message(.5, 'Don\'t forget, I set the M0NK3 to m1, and then it looks like that hallway got set to "r2"')
				_message_window.set_typing(false)
			if fails == 2:
				await delay_message(.5, 'There\'s some tips on formatting commands here, to move it to "r2", you would send "m1 move r2')
				_message_window.set_typing(false)
	
	var d = get_tree().get_nodes_in_group(Constants.DRONE_GROUP)[0]
	await d.move_complete

	scan()

func scan():
	await delay_message(1, 'First order of business is to find the generator. We can\'t open or close doors while it\'s offline')
	await delay_message(2.75, 'The network is pretty isolated, but most machinery in the lab broadcasts on a unique signal')
	await delay_message(2.5, 'I\'m not entirely sure of the use case for that...but at least our job is easier')
	await delay_message(2, 'The boys hacked a short-wave scanner onto your M0NK3 before we sent you down, and hooked it up to the terminal')
	await delay_message(2.75, 'It\'s the button labelled "SCAN". What do you expect. We aren\'t really paying them for their creativity')
	_message_window.set_typing(false)
	await get_node('../CanvasLayer/ScanButton').pressed

	await delay_message(1, 'With only the one scanner you won\'t be able to get an exact read on anything, but it\'ll give you an idea of the distance')
	await delay_message(3, 'Your briefing file will have the generator details, be back when you find it')
	await delay_message(2, 'Remember, "scan" to figure out the layout behind a door, and "move" to explore')
	_message_window.set_typing(false)
	var gen = get_node('../Rooms/Room5/Generator')
	await gen.revealed
	
	generator()

func generator():
	await delay_message(.5, 'There\'s our pesky generator!')
	await delay_message(2.5, 'They used their own M0NK3s in the lab, so most stuff should be compatible')
	await delay_message(3, 'Try telling the drone to "interface" with the generator')
	_message_window.set_typing(false)
	var cmd = ''
	while cmd != 'm1 interface':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'm1 interface' and cmd != 'interface':
			await delay_message(.5, 'It\'ll find the generator on its own with "m1 interface"')
			_message_window.set_typing(false)

	var gen = get_node('../Rooms/Room5/Generator')
	await gen.activated
	
	await delay_message(.5, 'Doors! Never thought I\'d be happy to see a bunch of doors boot up')
	await delay_message(2, 'Still some doors offline, but we\'ll figure that out when we get there')
	await delay_message(1.5, 'Next stop is the lab. The pencil pushers are saying it should have information on containing this big scary entity')
	await delay_message(3, 'Helpfully, there\'s no maps up here. Because it\'s a secret lab. Not like we need that to do our job or anything')
	await delay_message(2.5, 'Go ahead and start exploring, I\'ll message you if I see anything interesting from up here')
	_message_window.set_typing(false)
	monsters()

func monsters():
	var cmd = ''
	while not cmd.contains('d2') and not cmd.contains('d7') and not cmd.contains('d9'):
		cmd = await CommandManager.command_raw_sent
		if 'd2' not in cmd and 'd7' not in cmd and 'd9' not in cmd:
			cmd = ''
		if cmd.contains('move'):
			cmd = ''

	_scary_door1.close()
	_scary_door1.lock()
	_scary_door2.close()
	_scary_door2.lock()
	_scary_door3.close()
	_scary_door3.lock()

	await delay_message(.25, 'WARI')
	await delay_message(.1, 'WAiot')
	await delay_message(.3, 'WAIT')
	await delay_message(.1, 'WAITWAITWAIT')
	await delay_message(4, 'Ok I locked it in time')
	await delay_message(3, 'I meant explore the open rooms, not blindly fling doors open and get mauled to death!')
	_message_window.set_typing(false)
	var room = get_node('../Rooms/Room6')
	if not DoorManager.room_is_revealed(room.get_rid()):
		await delay_message(3, 'You didn\'t even scan before trying to walk in...')
		await get_tree().create_timer(2.5).timeout
		CommandManager.send_command('scan d2')
		await delay_message(.5, 'Ok I got it for you')
		await delay_message(1, 'Anywho')


	await delay_message(2.5, 'The boys threw on a radar function, it uses the wifi signals from the routers yada yada')
	await delay_message(3, 'It\'s on here somewhere...')
	await delay_message(1, 'Oh')
	await delay_message(1.5, 'The button labelled "RADR". Silly me')
	_message_window.set_typing(false)

	var radar = get_node('../RadarWindow')
	if not radar.is_open():
		await get_node('../CanvasLayer/RadarButton').pressed

	await delay_message(.5, 'It worked! Look back at the elevator and you\'ll see the radar over the map')
	await delay_message(2, 'Go ahead and point the radar over at r6, let\'s just make sure there\'s nothing exciting in there')
	_message_window.set_typing(false)
	var hit = null
	var enemy = get_node('../Enemy2')
	while hit != enemy:
		hit = await radar.object_found
	
	await delay_message(.1, 'HA! Told you there was something there')
	await delay_message(1, 'You would\'ve looked so dumb with your face ripped off')
	await delay_message(2.5, 'Looks like there\'s a little closet adjacent, open the closet and try getting it to move into it')
	_message_window.set_typing(false)
	var door = get_node('../Doors/Door12')
	while enemy.global_position.z < -6 or door.is_open():
		await get_tree().physics_frame

	hit = null
	while hit != enemy:
		hit = await radar.object_found
		
	await delay_message(.1, 'That is one trapped beasty!')
	await delay_message(1.5, 'Ok I\'ll unlock those doors now. Sorry I shouted at you')
	_message_window.set_typing(false)
	_scary_door1.unlock()
	_scary_door2.unlock()
	_scary_door3.unlock()

	routers()

func routers():
	var r = get_node('../Rooms/Room6/Router')
	while not r.is_revealed():
		await get_tree().physics_frame

	await delay_message(.1, 'Would you look at that, a gen-yoo-ine router')
	await delay_message(2, 'The boys were just telling me your radar should actually work off any router, not just the one we sent in the elevator')
	await delay_message(3, 'Command is "radar", and then whichever router you want to go through')
	await delay_message(2.5, 'That should help you clear the other nearby rooms before going into them')
	_message_window.set_typing(false)

	files()

func files():
	var file = get_node('../Rooms/Room17/File2')
	await file.revealed

	await delay_message(.5, 'Ooh a note lying on the ground')
	await delay_message(1.5, 'Must have gotten knocked down when they evacuated')
	await delay_message(2.25, 'The M0NK3 does have a basic camera under the command "download", you can use it like interface')
	_message_window.set_typing(false)

	lab()

func lab():
	var door = get_node('../Rooms/Room10/DoorControl')
	await door.activated

	await delay_message(.5, 'Alright, lab time')
	await delay_message(2.4, 'Researchers say the docs we need are stored in the main lab computer')
	_message_window.set_typing(false)

func boom():
	await delay_message(.5, 'You got the docs?')
	await delay_message(2.5, 'Well what are you waiting for? Let\'s get you to the elevator and get you out of there!')
	_message_window.set_typing(false)

	var d = get_tree().get_first_node_in_group(Constants.DRONE_GROUP)
	while d.global_position.z < -2:
		await get_tree().physics_frame
		if d.is_queued_for_deletion() or d == null:
			failed()
			return
	
	await delay_message(.5, 'And away we go!')
	_message_window.set_typing(false)
	get_node('../Doors/Door').close()
	await get_tree().create_timer(2).timeout

	var cam = get_node('../Camera3D')
	var cam_start = cam.global_position.y
	cam.global_position = Vector3(-3, cam_start, 0)
	cam._can_control = false

	var nodes = get_tree().get_nodes_in_group('EndAnim')

	show_win_screen.call_deferred()

	while true:
		for n in nodes:
			n.global_position.y += get_process_delta_time() * 3
		cam.global_position.y += get_process_delta_time() * 3
		d.global_position.y += get_process_delta_time() * 3
		
		await get_tree().process_frame


func failed():
	await delay_message(.25, 'NOOOOOOOOOO')
	await delay_message(1, 'WE WERE SO CLOSE TOO')
	await delay_message(1.5, 'We didn\'t tell you because it was a lot of pressure...the fate of humanity was riding on those files')
	await delay_message(2, 'The cure for cancer, world peace, all sorts of stuff like that!')
	await delay_message(2.5, 'Oh well, best not to dwell on the past. That lab self-destruct sequence is enough to take out both you and me anyways')
	await delay_message(1.5, 'See you on the other side...')
	_message_window.set_typing(false)

	show_win_screen()


func show_win_screen():
	await get_tree().create_timer(2).timeout

	get_parent().stop_alarm()
	_win.show()


func _on_drone_destroyed():
	await delay_message(2, 'Aw crap, we lost the drone')
	await delay_message(2.5, 'We\'ve got a few more you can use')
	await delay_message(3.5, 'You can request a new one with "deploy <droneID>"')
	await delay_message(2.5, 'I\'ll even let you choose the ID of this one (maybe..hat way...e.won\'t blow i..up)')
	await delay_message(4, 'Oh...it picked up me saying that')
	await delay_message(2, 'Well...command is "deploy <droneID>", just try to lock down any loose specimens before you send it out')
	_message_window.set_typing(false)
