extends Control


@onready var lives_label:Label = $Margins/Everything/Bottom/Lives/Count
@onready var time_label:Label = $Margins/Everything/MainInfo/Time/Info
@onready var score_label:Label = $Margins/Everything/MainInfo/Score/Info
@onready var rings_label:Label = $Margins/Everything/MainInfo/Rings/Info

func _ready() -> void:
	var disclaimer:Label = $"Margins/Everything/Bottom/Pre-Release Disclaimer"
	var proj_ver:String = ProjectSettings.get_setting("application/config/version", "pre-release")
	
	disclaimer.text = disclaimer.text.format({"version": proj_ver},)
