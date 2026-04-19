extends InteractiveBase


func interaction_start(_drone:DroneBase) -> bool:
    _active = not _active

    if _active:
        CommandManager.log_message('Generator powered on')
    else:
        CommandManager.log_message('Generator powered off')

    return true
    
