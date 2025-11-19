const express = require('express');
const cors = require('cors');
const { spawn } = require('child_process');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// API Endpoint
app.get('/api/meal-plan', (req, res) => {
    const { calories, dining_hall, meal_type } = req.query;

    // Validate required parameters
    if (!calories || !dining_hall) {
        return res.status(400).json({
            error: 'Missing required parameters: calories and dining_hall are required'
        });
    }

    // Path to Python script
    const scriptPath = path.join(__dirname, 'meal-planning', 'meal_planner.py');

    // Build arguments
    const args = [
        scriptPath,
        '--calories', calories,
        '--hall', dining_hall,
        '--json' // Force JSON output
    ];

    if (meal_type) {
        args.push('--meal', meal_type);
    }

    // Spawn Python process
    // Note: Using 'python3' - make sure it's in the path
    const pythonProcess = spawn('python3', args);

    let dataString = '';
    let errorString = '';

    // Collect data from stdout
    pythonProcess.stdout.on('data', (data) => {
        dataString += data.toString();
    });

    // Collect errors from stderr
    pythonProcess.stderr.on('data', (data) => {
        errorString += data.toString();
    });

    // Handle process close
    pythonProcess.on('close', (code) => {
        if (code !== 0) {
            console.error(`Python script exited with code ${code}`);
            console.error(`Error: ${errorString}`);
            return res.status(500).json({
                error: 'Failed to generate meal plan',
                details: errorString
            });
        }

        try {
            // Parse JSON output from Python script
            // The script might print other things (like warnings) to stdout if not careful
            // But our modified script should only print JSON when --json is used
            // We'll try to find the JSON object in the output if there's extra noise

            // Simple attempt: parse the whole string
            const mealPlan = JSON.parse(dataString);
            res.json(mealPlan);
        } catch (e) {
            console.error('Failed to parse JSON output:', e);
            console.error('Raw output:', dataString);

            // Fallback: try to find the last JSON object in the output
            try {
                const lines = dataString.trim().split('\n');
                const lastLine = lines[lines.length - 1];
                const mealPlan = JSON.parse(lastLine);
                res.json(mealPlan);
            } catch (e2) {
                res.status(500).json({
                    error: 'Invalid response from meal planner',
                    raw_output: dataString
                });
            }
        }
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
