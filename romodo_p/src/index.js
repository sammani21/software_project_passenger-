// app.js

const express = require('express');
const mongoose = require('mongoose');
const env = require("dotenv");
const cors = require('cors');
const errorHandler = require('./middlewares/ErrorHandler');
const bodyParser = require('body-parser');
//const authRoutes = require('./routes/auth.route');
const passengerRoute = require('./routes/passenger.route');
//const cookieParser = require('cookie-parser');
env.config();



// Connect to MongoDB
//console.log(process.env.MONGO_URL)
mongoose
  .connect(process.env.MONGO_URL)
  .then(() => console.log('MongoDB connected'))
  .catch((er) => console.log(er));

 /*'mongodb://localhost:27017/passenger-db', {
  /*useNewUrlParser: true,
  useUnifiedTopology: true,
  useCreateIndex: true,
  useFindAndModify: false,*/

  const app = express();

  app.use(cors());

// Middleware
app.use(bodyParser.json());
app.use(express.json());
//app.use(cookieParser());

// Routes
//app.use('/auth', authRoutes);
app.use("/api/v1/passenger", passengerRoute);

// Start the server
//const PORT = process.env.PORT || 3000;
app.listen(process.env.PORT, () => {
    console.log(`[server]: Server is running at http://localhost:${process.env.PORT}`);
  });
