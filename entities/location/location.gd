class_name Location extends Marker2D

@export var job: JobConstants.JOB = JobConstants.JOB.UNASSIGNED
@export var modifiers: Mood = Mood.new()
@export var title: String = ""

func initialize(_job: JobConstants.JOB, _modifiers: Mood, _title: String) -> void:
	self.job = _job
	self.modifiers = _modifiers
	self.title = _title
