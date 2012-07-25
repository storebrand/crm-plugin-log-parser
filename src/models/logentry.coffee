mongoose = require 'mongoose'

LogEntry = new mongoose.Schema
  date: Date
  severity: String
  entity: String
  event: String
  user: String
  id: String
  time: Number

module.exports = mongoose.model 'LogEntry', LogEntry