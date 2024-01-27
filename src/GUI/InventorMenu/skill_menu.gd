class_name SkillMenu
extends CanvasLayer

signal skill_selected(skill)

const inventory_menu_item_scene := preload("res://src/GUI/InventorMenu/inventory_menu_item.tscn")

@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var title_label: Label = $"%TitleLabel"

func _ready() -> void:
	hide()


func build(title_text: String, skil: FighterComponent) -> void:
	if skil.skill_tracker.get_child_count() == 0:
		button_pressed.call_deferred()
		MessageLog.send_message(" no skills to skill.", GameColors.IMPOSSIBLE)
		skill_selected.emit(null)
		return
	title_label.text = title_text
	for i in skil.skill_tracker.get_child_count():
		_register_item(i, skil.skill_tracker.get_child(i))
	inventory_list.get_child(0).grab_focus()
	show()


func _register_item(index: int, Skill: Skills) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	item_button.icon = Skill.skill_icon
	item_button.add_theme_color_override("icon_normal_color",Skill.message_color)
	item_button.add_theme_color_override("icon_focus_color",Skill.message_color)
	var char: String = String.chr("a".unicode_at(0) + index)
	var button_text = "%s %s/%s"%[Skill.skill_name,Skill.tick_cooldown,Skill.cooldown]
	item_button.text = "( %s ) %s" % [char, button_text]
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + index
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	item_button.pressed.connect(button_pressed.bind(Skill))
	inventory_list.add_child(item_button)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		skill_selected.emit(null)
		queue_free()


func button_pressed(Skill:Skills = null) -> void:
	skill_selected.emit(Skill)
	queue_free()
