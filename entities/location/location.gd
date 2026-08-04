class_name Location extends Marker2D

@export var _job: JobConstants.JOB = JobConstants.JOB.UNASSIGNED
@export var _personality_modifiers: Mood = Mood.new()
@export var _title: String = ""

func initialize(job: JobConstants.JOB, personality_modifiers: Mood, title: String) -> void:
	self._job = job
	self._personality_modifiers = personality_modifiers
	self._title = title
