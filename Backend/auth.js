const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

// Database file path (JSON file)
const DB_FILE = path.join(__dirname, 'data', 'users.json');

// Initialize database file if it doesn't exist
function initializeDatabase() {
    const dataDir = path.join(__dirname, 'data');

    // Create data directory if it doesn't exist
    if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
    }

    // Create users.json if it doesn't exist
    if (!fs.existsSync(DB_FILE)) {
        fs.writeFileSync(DB_FILE, JSON.stringify({ users: [] }, null, 2));
        console.log('Created users database file');
    }
}

// Read users from file
function readUsers() {
    try {
        const data = fs.readFileSync(DB_FILE, 'utf8');
        return JSON.parse(data).users;
    } catch (err) {
        console.error('Error reading users:', err);
        return [];
    }
}

// Write users to file
function writeUsers(users) {
    try {
        fs.writeFileSync(DB_FILE, JSON.stringify({ users }, null, 2));
        return true;
    } catch (err) {
        console.error('Error writing users:', err);
        return false;
    }
}

// Hash password using crypto (built-in Node.js module)
function hashPassword(password) {
    const salt = crypto.randomBytes(16).toString('hex');
    const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
    return `${salt}:${hash}`;
}

// Verify password
function verifyPassword(password, storedHash) {
    const [salt, hash] = storedHash.split(':');
    const verifyHash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
    return hash === verifyHash;
}

// Register new user
function registerUser(email, password, callback) {
    const users = readUsers();

    // Check if email already exists
    if (users.find(u => u.email === email)) {
        return callback({ error: 'Email already exists' }, null);
    }

    // Create new user
    const newUser = {
        id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
        email: email,
        password_hash: hashPassword(password),
        created_at: new Date().toISOString(),
        goal: null,
        age: null,
        sex: null,
        calories: null
    };

    users.push(newUser);

    if (writeUsers(users)) {
        callback(null, {
            id: newUser.id,
            email: newUser.email,
            message: 'User registered successfully'
        });
    } else {
        callback({ error: 'Failed to save user' }, null);
    }
}

// Login user
function loginUser(email, password, callback) {
    const users = readUsers();
    const user = users.find(u => u.email === email);

    if (!user) {
        return callback({ error: 'Invalid email or password' }, null);
    }

    if (!verifyPassword(password, user.password_hash)) {
        return callback({ error: 'Invalid email or password' }, null);
    }

    callback(null, {
        id: user.id,
        email: user.email,
        goal: user.goal,
        age: user.age,
        sex: user.sex,
        calories: user.calories,
        message: 'Login successful'
    });
}

// Update user profile
function updateUserProfile(userId, profileData, callback) {
    const users = readUsers();
    const userIndex = users.findIndex(u => u.id === userId);

    if (userIndex === -1) {
        return callback({ error: 'User not found' }, null);
    }

    // Update profile fields
    const { goal, age, sex, calories } = profileData;
    users[userIndex].goal = goal;
    users[userIndex].age = age;
    users[userIndex].sex = sex;
    users[userIndex].calories = calories;
    users[userIndex].updated_at = new Date().toISOString();

    if (writeUsers(users)) {
        callback(null, {
            message: 'Profile updated successfully',
            user: {
                id: users[userIndex].id,
                email: users[userIndex].email,
                goal: users[userIndex].goal,
                age: users[userIndex].age,
                sex: users[userIndex].sex,
                calories: users[userIndex].calories
            }
        });
    } else {
        callback({ error: 'Failed to update profile' }, null);
    }
}

// Get user profile
function getUserProfile(userId, callback) {
    const users = readUsers();
    const user = users.find(u => u.id === userId);

    if (!user) {
        return callback({ error: 'User not found' }, null);
    }

    callback(null, {
        id: user.id,
        email: user.email,
        goal: user.goal,
        age: user.age,
        sex: user.sex,
        calories: user.calories,
        created_at: user.created_at
    });
}

// Initialize database on module load
initializeDatabase();

module.exports = {
    registerUser,
    loginUser,
    updateUserProfile,
    getUserProfile
};
