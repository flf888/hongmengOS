# Debugging Dart Code in HarmonyOS Flutter Applications

## Debugging Approaches
- **ETS Code**: Use DevEco Studio for debugging
- **Dart Code**: Use VS Code or Android Studio for debugging

> **Important**: When debugging HarmonyOS-adapted Flutter, include the local engine parameter:  
> `--local-engine=/path/to/engine/build`

---

## VS Code Configuration
1. Create `.vscode/launch.json` in your project root
2. Add the following configurations:

	```json
	{
	  "version": "0.2.0",
	  "configurations": [
	    {
	      "name": "Flutter (Debug)",
	      "request": "launch",
	      "type": "dart",
	      "args": [
	        "--local-engine=/Users/your_user/engine_build/src/out/ohos_debug_unopt_arm64"
	      ]
	    },
	    {
	      "name": "Flutter (Profile)",
	      "request": "launch",
	      "type": "dart",
	      "flutterMode": "profile",
	      "args": [
	        "--local-engine=/Users/your_user/engine_build/src/out/ohos_profile_arm64"
	      ]
	    },
	    {
	      "name": "Flutter (Release)",
	      "request": "launch",
	      "type": "dart",
	      "flutterMode": "release",
	      "args": [
	        "--local-engine=/Users/your_user/engine_build/src/out/ohos_release_arm64"
	      ]
	    }
	  ]
	}
	```

3. Replace `/Users/your_user/...` with your actual engine build path
4. Start debugging using VS Code's debug panel

---

## Android Studio Configuration
1. Open your Flutter project in Android Studio
2. Go to `Run > Edit Configurations...`
3. Create a new Flutter configuration
4. Add the engine parameter in "Additional arguments":



	```bash
	--local-engine=/Users/your_user/engine_build/src/out/ohos_debug_unopt_arm64
	```

5. Apply changes and start debugging

---

## Key Notes
1. **Engine Paths**:
   - Debug: `ohos_debug_unopt_arm64`
   - Profile: `ohos_profile_arm64`
   - Release: `ohos_release_arm64`

2. **Path Customization**:
   - Replace `/Users/your_user/...` with your actual build path
   - Ensure the path points to a valid engine build

3. **Debugging Workflow**:
   - Set breakpoints in Dart files
   - Inspect variables during execution
   - Use the debug console for runtime evaluation
   - Analyze call stacks for error tracing

This setup enables full debugging capabilities for Dart code in HarmonyOS Flutter applications across different build modes.