extends Node

@onready var _message_window = get_node('../MessageWindow')

@onready var _tut_1 = $CanvasLayer/WelcomeMessage
@onready var _tut_2 = $CanvasLayer/WelcomeMessage2

@export var DEBUG_fast_forward = false

@onready var _scary_door1 = get_node('../Doors/Door7')
@onready var _scary_door2 = get_node('../Doors/Door5')

func _ready() -> void:
	_tut_1.hide()
	_tut_2.hide()


func delay_message(delay, message):
	if not DEBUG_fast_forward:
		await get_tree().create_timer(delay).timeout
	_message_window.log_message(message)



func start_tutorial():
	monsters()
	return
	if DEBUG_fast_forward:
		ping()
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
	await delay_message(3, 'Yeah apparently it took some hits when the lab was evacuated')
	await delay_message(2.75, 'But that\'s old news now! Let\'s see how the M0NK3 liked the journey')
	await delay_message(2.5, 'Go ahead and try pinging it...I know it\'s an older system but shouldn\'t be too much of a hassle')
	await delay_message(2.5, 'I\'m just glad they had these old drones laying around, otherwise you\'d be going in yourself...')
	
	await delay_message(3, 'Alright, here we go')
	await delay_message(1.25, '"To identify if your new M0NK3 is connected to the M0NK3_CONTROL v2, simply select CMD on your M0NK3_CONTROL v2 terminal, then input ping and the ID of the M0NK3"')
	await delay_message(5.25, 'Wordy aren\'t they. We set that M0NK3 to m1, so looks like pressing "CMD", then "ping m1" should do it')

	var cmd : String = ''
	while cmd != 'ping m1':
		cmd = await CommandManager.command_raw_sent

	await delay_message(1, 'And there\'s the pong! Wasn\'t going to say anything up here...but if the drone broke you would still have to go inside yourself')
	await delay_message(4.75, 'But that\'s old news now! Let\'s start checking out the lab')

	move()

func move():
	await delay_message(3.5, 'Go ahead and run a scan on the elevator door to get an idea of the layout behind it')
	await delay_message(1.75, 'The command is "scan <DoorID>". Your map should show the door\'s ID on the network')
	
	var cmd = ''
	while cmd != 'scan d1':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'scan d1':
			await delay_message(.5, 'I\'ve got d1 on my map, try "scan d1"')
	
	await delay_message(1, 'Boring old hallways. Thought a secret lab underground would at least have a lava moat or something.')
	await delay_message(3, 'Now back to the M0NK3. It might be an old model, but the onboard navigation is still state o the art')
	await delay_message(2, 'Let\'s send it out to meet Mr. Boring Hallway')

	await delay_message(2.25, 'Assuming you read the briefing, you\'ll know they were able to somewhat isolate the "Specimens"')
	await delay_message(2, '"Specimens".  Not a lava moat, but at least more fitting for an underground lab')
	await delay_message(2.5, 'We rigged up your terminal to interface with the local network, so just typing "open d1" will get the door opened')

	while cmd != 'open d1':
		cmd = await CommandManager.command_raw_sent

	await delay_message(.5, 'And "close" will do just the opposite if you need. You can also get away with typing the door ID, the network can pull it\'s own weight sometimes')

	await delay_message(3, 'Door open, so onwards and upwards we go')
	await delay_message(2.5, '"To send a command to you M0NK3, first type the ID of that M0NK3, then the command, then any arguments"')
	await delay_message(3.25, 'There\'s a handful of commands indexed, I\'ll go ahead and send you the file')

	DataWindow.add_file('M0NK3_COMMANDS.txt', 'res://Popups/Documents/basic_commands.txt')
	
	var fails = 0
	while cmd != 'm1 move r2':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'm1 move r2':
			fails += 1
			if fails == 1:
				await delay_message(.5, 'Don\'t forget, I set the M0NK3 to m1, and then it looks like that hallway got set to "r2"')
			if fails == 2:
				await delay_message(.5, 'There\'s some tips on formatting commands here, to move it to "r2", you would send "m1 move r2')
	
	var d = get_tree().get_nodes_in_group(Constants.DRONE_GROUP)[0]
	await d.move_complete

	scan()

func scan():
	await delay_message(1, 'First order of business is to find the generator. We can\'t open or close doors while it\'s offline')
	await delay_message(2.75, 'The network is pretty isolated, but most machinery in the lab broadcasts on a unique signal')
	await delay_message(2.5, 'I\'m not entirely sure of the use case for that...but at least our job is easier')
	await delay_message(2, 'The boys hacked a short-wave scanner onto your M0NK3 before we sent you down, and hooked it up to the terminal')
	await delay_message(2.75, 'It\'s the button labelled "SCANNER". What do you expect. We aren\'t really paying them for their creativity')
	await delay_message(3, 'With only the one scanner you won\'t be able to get an exact read on anything, but it\'ll give you an idea of the distance')
	await delay_message(3, 'Your briefing file will have the generator details, be back when you find it')
	await delay_message(2, 'Remember, "scan" to figure out the layout behind a door, and "move" to explore')

	var gen = get_node('../Rooms/Room5/Generator')
	var d = get_tree().get_nodes_in_group(Constants.DRONE_GROUP)[0]
	var dist = 10
	while dist > 3.5:
		dist = gen.global_position.distance_to(d.global_position)
		await get_tree().physics_frame
	
	generator()

func generator():
	await delay_message(.5, 'There\'s our pesky generator!')
	await delay_message(2.5, 'They used their own M0NK3s in the lab, so most stuff should be compatible')
	await delay_message(3, 'Try telling the drone to interface with the generator')

	var cmd = ''
	while cmd != 'm1 interface':
		cmd = await CommandManager.command_raw_sent
		if cmd != 'm1 interface':
			await delay_message(.5, 'It\'ll find the generator on it\'s own with "m1 interface"')

	var gen = get_node('../Rooms/Room5/Generator')
	await gen.activated
	
	await delay_message(.5, 'Doors! Never thought I\'d be happy to see a bunch of doors boot up')
	await delay_message(2, 'Still some doors offline, but we\'ll figure that out when we get there')
	await delay_message(1.5, 'Next stop is the lab. The pencil pushers are saying it should have information on containing this big scary entity')
	await delay_message(3, 'Helpfully, there\'s no maps up here. Because it\'s a secret lab. Not like we need that to do our job or anything')
	await delay_message(2.5, 'Go ahead and start exploring, I\'ll message you if I see anything interesting from up here')

	monsters()

func monsters():
	var cmd = ''
	while not cmd.contains('d5') and not cmd.contains('d7'):
		cmd = await CommandManager.command_raw_sent
		if cmd == 'd5' or cmd == 'd6' or cmd.contains('open'):
			break

	_scary_door1.close()
	_scary_door1.lock()
	_scary_door2.close()
	_scary_door2.lock()

	await delay_message(.25, 'WARI')
	await delay_message(.1, 'WAiot')
	await delay_message(.3, 'WAIT')
	await delay_message(.1, 'WAITWAITWAIT')
	await delay_message(4, 'Ok I locked it in time')
	await delay_message(3, 'I meant explore the open rooms, not blindly fling doors open and get mauled to death!')
	await delay_message(2.5, 'The boys threw on a radar function, it uses the wifi signals from the routers yada yada')
	await delay_message(3, 'It\'s on here somewhere...')
	await delay_message(1, 'Oh')
	await delay_message(1.5, 'The button labelled "RADAR". Silly me')

	var radar = get_node('../RadarWindow')
	if not radar.is_open():
		await get_node('../CanvasLayer/RadarButton').pressed

	await delay_message(.5, 'Go ahead and point the radar over at r6, let\'s just make sure there\'s nothing exciting in there')
	
	var hit = null
	var enemy = get_node('../Enemy2')
	while hit != enemy:
		hit = await radar.object_found
	
	await delay_message(.1, 'HA! Told you there was something there')
	await delay_message(1, 'You would\'ve looked so dumb with your face ripped off')
	await delay_message(2.5, 'Looks like there\'s a little closet adjacent, open the closet and try getting it to move into it')

	var door = get_node('../Doors/Door12')
	while enemy.global_position.x < 3 or door.is_open():
		await get_tree().physics_frame

	hit = null
	while hit != enemy:
		hit = await radar.object_found
		
	await delay_message(.1, 'That is one trapped beasty!')
	await delay_message(1.5, 'Ok I\'ll unlock those doors now. Sorry I shouted at you')
	_scary_door1.unlock()
	_scary_door2.unlock()

	file()

func file():
	pass
	
