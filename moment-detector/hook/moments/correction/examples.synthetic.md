These three are written for this file, not taken from any session. They show the format a labelled-examples file uses; the library of real labelled moments replaces them.

Example 1. Agent's last reply: "Added a new function `greet_user(name)` in greet.py." New message: "No, I wanted the existing greet() to take the name." Answer: {"moment": true, "cue": "No, I wanted the existing greet() to take the name", "confidence": "high"}

Example 2. Agent's last reply: "Renamed the config key to `timeout_s` everywhere." New message: "Great. Now add a test for it." Answer: {"moment": false, "cue": "", "confidence": "high"}

Example 3, a near miss. Agent's last reply: "The build passes now." New message: "No rush, but could you also check the lint?" Answer: {"moment": false, "cue": "", "confidence": "medium"}
