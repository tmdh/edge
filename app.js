const express = require("express");
const mongoose = require("mongoose");
const app = express();
const port = 3000;

// MongoDB connection
mongoose
  .connect("mongodb://mongodb:27017/myapp", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Successfully connected to MongoDB."))
  .catch((err) => console.error("MongoDB connection error:", err));

// Create a simple Message model
const Message = mongoose.model("Message", {
  text: String,
  createdAt: { type: Date, default: Date.now },
});

// Middleware to parse JSON bodies
app.use(express.json());

// Routes
app.get("/", async (req, res) => {
  try {
    const messages = await Message.find();
    res.json({
      message: "Hello World!",
      storedMessages: messages,
    });
  } catch (error) {
    res.status(500).json({ error: "Error fetching messages" });
  }
});

// Route to add a message
app.post("/message", async (req, res) => {
  try {
    const message = new Message({ text: req.body.text });
    await message.save();
    res.json(message);
  } catch (error) {
    res.status(500).json({ error: "Error saving message" });
  }
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
