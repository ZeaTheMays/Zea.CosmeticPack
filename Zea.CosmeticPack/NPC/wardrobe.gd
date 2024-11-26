extends Spatial

var wardrobe = preload("res://mods/Zea.CosmeticPack/NPC/wardrobe_shop.tscn")

func _open():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("OPEN")

func _close():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("CLOSE")

