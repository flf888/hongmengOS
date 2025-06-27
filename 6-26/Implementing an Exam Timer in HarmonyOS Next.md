# Implementing an Exam Timer in HarmonyOS Next

	```typescript
	@Entry
	@Component
	struct QuickTestMainPage {
	  @State paperAllTime: number = 0; // Total exam duration (exam mode)
	  @State remainTimeUi: string = "00:00"; // Formatted time display
	  @State remainTime: number = 0; // Actual time value (countdown or stopwatch)
	  
	  private doExamTimer: number | null = null; // Timer reference
	  
	  aboutToAppear(): void { 
	    this.timerInit(); // Initialize timer on component appearance
	  }
	  
	  aboutToDisappear(): void {
	    // Clean up timer when component disappears
	    if (this.doExamTimer) {
	      clearTimeout(this.doExamTimer);
	      this.doExamTimer = null;
	    }
	  }
	  
	  // Initialize timer based on mode
	  timerInit() {
	    if (this.isTest) {
	      // Exam mode: countdown from total time
	      this.remainTime = this.paperAllTime - this.makeTime;
	    } else {
	      // Practice mode: stopwatch timing
	      this.remainTime = this.makeTime;
	    }
	    this.updateTimeDisplay();
	    this.startTimer();
	  }
	
	  // Update UI with formatted time
	  updateTimeDisplay() {
	    this.remainTimeUi = Utils.formatSeconds(this.remainTime);
	  }
	
	  // Core timer logic
	  startTimer() {
	    this.doExamTimer = setTimeout(() => {
	      if (this.isTest) {
	        // Exam countdown mode
	        this.remainTime--;
	        this.makeTime = this.paperAllTime - this.remainTime;
	        
	        // Stop timer when time expires
	        if (this.remainTime <= 0) {
	          this.handleTimeExpired();
	          return;
	        }
	      } else {
	        // Practice stopwatch mode
	        this.remainTime++;
	        this.makeTime = this.remainTime;
	      }
	      
	      this.updateTimeDisplay();
	      this.startTimer(); // Recursive call for continuous timing
	    }, 1000);
	  }
	  
	  // Handle exam time expiration
	  handleTimeExpired() {
	    // Implement exam submission logic here
	    console.log("Exam time has expired!");
	  }
	  
	  build() {
	    Column() {
	      // Timer icon
	      CustomIcon({
	        iconType: CustomIconType.icon_timer,
	        iconSize: 19,
	        iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
	      })
	      
	      // Time display
	      Text(this.remainTimeUi)
	        .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
	        .fontSize(11)
	    }
	  }
	}
	```

## Key Implementation Details

1. **Dual Mode Timer**:
   - **Exam Mode**: Countdown timer from total exam duration
   - **Practice Mode**: Stopwatch tracking elapsed time

2. **Lifecycle Management**:
   - Initializes timer in `aboutToAppear()`
   - Cleans up resources in `aboutToDisappear()`
   - Prevents memory leaks with proper timeout handling

3. **Time Formatting**:
   - Uses `Utils.formatSeconds()` to convert seconds to "MM:SS" format
   - Automatically updates UI display each second

4. **Time Expiration Handling**:
   - Stops countdown when time reaches zero
   - Triggers special handling for exam submission

## Utility Function (formatSeconds)

	```typescript
	class Utils {
	  static formatSeconds(seconds: number): string {
	    const mins = Math.floor(seconds / 60).toString().padStart(2, '0');
	    const secs = (seconds % 60).toString().padStart(2, '0');
	    return `${mins}:${secs}`;
	  }
	}
	```

## Usage Notes

1. **Exam Mode Setup**:
   ```typescript
   this.isTest = true;
   this.paperAllTime = 3600; // 60 minutes in seconds
   ```

2. **Practice Mode Setup**:
   ```typescript
   this.isTest = false;
   this.makeTime = 0; // Start from zero
   ```

This implementation provides a robust exam timing solution for HarmonyOS Next applications, featuring both countdown and stopwatch functionality with proper resource management and UI updates.