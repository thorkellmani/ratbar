class_name Location extends Marker2D

@export var _job: JobConstants.JOB = JobConstants.JOB.UNASSIGNED
@export var _personality_modifiers: Mood = Mood.new()

func initialize(job: JobConstants.JOB, personality_modifiers: Mood) -> void:
	self._job = job
	self._personality_modifiers = personality_modifiers
