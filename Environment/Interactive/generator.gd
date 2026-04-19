extends InteractiveBase


func interaction_start(drone:DroneBase) -> bool:
    print(drone, ' toggled')
    _active = not _active

    if _active:
        CommandManager.log_message('Generator powered on')
    else:
        CommandManager.log_message('Generator powered off')

    return true
    
func hide_model():
    get_node('%Model').layers = 0

func reveal_model():
    get_node('%Model').layers = 1
