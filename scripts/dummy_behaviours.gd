extends Resource
class_name DummyBehaviours

@export var elements :Array[SkillBuilderBlock]= []
var own_parent : Player = null

func run(parent : Player = null, target : Player = null) -> void:
	own_parent = parent
	for i in elements:
		await i.run(parent)
	own_parent.dummy_behaving = false
