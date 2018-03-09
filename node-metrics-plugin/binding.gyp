{
	'targets': [
		{
			'target_name': 'event-loop-stats',
			'sources': [
				'src/eventLoopStats.cc',
			],
			"include_dirs" : [
				"<!(node -e \"require('nan')\")"
			]
		}
	]
}