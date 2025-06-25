# Fundamentals of HarmonyOS Development

## Data Storage

HarmonyOS applications offer multiple data storage options:

- **Preferences**: Lightweight key-value storage for simple data
- **SQLite**: Relational database for structured data storage
- **File Storage**: Direct file system access for custom data storage

## Arrays

Arrays are ordered collections of data accessible by index:

	```javascript
	let numbers = [1, 2, 3, 4, 5];
	console.log(numbers[0]); // Outputs 1
	```

## Functions

### Regular Functions
Encapsulate reusable blocks of code:
	```javascript
	function greet(name) {
	    return "Hello, " + name;
	}
	console.log(greet("Alice")); // Outputs "Hello, Alice"
	```

### Arrow Functions
Concise function syntax:
	```javascript
	const greet = (name) => "Hello, " + name;
	console.log(greet("Bob")); // Outputs "Hello, Bob"
	```

## Interfaces

Define object structure contracts:
	```typescript
	interface Person {
	    name: string;
	    age: number;
	    greet(): string;
	}
	
	class Employee implements Person {
	    name: string;
	    age: number;
	    
	    constructor(name: string, age: number) {
	        this.name = name;
	        this.age = age;
	    }
	    
	    greet(): string {
	        return "Hello, I am " + this.name;
	    }
	}
	```

## Objects and Methods

Collections of properties and methods:
	```javascript
	let person = {
	    name: "Charlie",
	    age: 30,
	    greet: function() {
	        return "Hello, " + this.name;
	    }
	};
	console.log(person.greet()); // Outputs "Hello, Charlie"
	```

## Union Types

Values that can be one of several types:
	```typescript
	let age: number | string;
	age = 25;        // Valid
	age = "twenty-five"; // Also valid
	```

## Enums

Named constant collections:
	```typescript
	enum Direction {
	    Up,
	    Down,
	    Left,
	    Right
	}
	let direction: Direction = Direction.Up; // Uses enum value
	```

------

## UI Development Concepts and Layout

### Component Properties and Methods
- **Properties**: Configure appearance and behavior
- **Methods**: Perform component-specific operations

### Text Styling
- **Text Color**: Set via `text-color` property
- **Text Overflow**: Control with `text-overflow` (e.g., `ellipsis` displays truncation dots)

### Image Component
	```html
	<image src="path/to/image.png" width="100" height="100"></image>
	```

### Input Field
	```html
	<input type="text" placeholder="Enter text here"></input>
	```

### SVG Icons
Embed directly or reference SVG files:
	```html
	<svg width="100" height="100">
	    <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
	</svg>
	```

### Layout Elements
Organize UI component positioning and sizing

#### Margin
	```css
	.container {
	    margin: 10px; /* Uniform margin */
	    margin: 5px 10px; /* Vertical | Horizontal */
	    margin: 5px 10px 15px; /* Top | Horizontal | Bottom */
	    margin: 5px 10px 15px 20px; /* Top | Right | Bottom | Left */
	}
	```

#### Borders
	```css
	.box {
	    border: 1px solid black; /* Width | Style | Color */
	    border-radius: 10px; /* Rounded corners */
	}
	```

#### Custom Shapes
	```css
	.special-shape {
	    border-radius: 20px 10px 30px 5px; /* Custom rounded corners */
	}
	```

### Backgrounds
	```css
	.background {
	    background-color: #f0f0f0; /* Solid color */
	    background-image: url('path/to/image.png'); /* Background image */
	    background-position: center; /* Image positioning */
	    background-size: cover; /* Image sizing */
	    background-repeat: no-repeat; /* Prevent tiling */
	}
	```

### Linear Layout Alignment
	```css
	.linear-layout {
	    display: flex;
	    justify-content: center; /* Main axis alignment */
	    align-items: center;     /* Cross axis alignment */
	    flex-direction: row;     /* Layout direction (row/column) */
	}
	```