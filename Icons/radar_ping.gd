extends Sprite3D

func spawn(lifetime:float):
    var remaining = lifetime

    while remaining > 0:
        remaining -= get_process_delta_time()

        var t = 1 - remaining / lifetime
        modulate.a = 1 - t ** 1.5

        await get_tree().process_frame

    queue_free()
