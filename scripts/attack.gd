extends State

func enter():
	super.enter()
	combo()

func attack(move = "1"):
	animation_player.play("attack_" + move)
	await animation_player.animation_finished

func combo():
	var move_set = ["1", "1", "2"]
	for i in move_set:
		await attack(i)
	combo()

func transition():
	if owner.direction.length() > 100:
		get_parent().change_state("follow")
