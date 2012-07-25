fs = require("fs")
sys = require("util")

exports.FileLineReader = (filename, bufferSize) ->
  bufferSize = 8192  unless bufferSize
  currentPositionInFile = 0
  buffer = ""
  fd = fs.openSync(filename, "r")
  fillBuffer = (position) ->
    res = fs.readSync(fd, bufferSize, position, "ascii")
    buffer += res[0]
    return -1  if res[1] is 0
    position + res[1]

  currentPositionInFile = fillBuffer(0)
  
  @hasNextLine = ->
    while buffer.indexOf("\n") is -1
      currentPositionInFile = fillBuffer(currentPositionInFile)
      return false  if currentPositionInFile is -1
    return true  if buffer.indexOf("\n") > -1
    false

  @nextLine = ->
    lineEnd = buffer.indexOf("\n")
    result = buffer.substring(0, lineEnd)
    buffer = buffer.substring(result.length + 1, buffer.length)
    result

  this

class FolderReader
  constructor: (@folder) ->

  read: (ext, fnc) =>
    folder = @folder
    
    fs.readdir folder, (err, files) ->
      if ext
        files = files.filter (file) ->
          extLength = ext.length + 1    
          file.substr -extLength is '.' + ext
      
      for file in files
        do (file) ->
          fnc folder + '/' + file, file

  readSync: (ext) ->
    files = fs.readdirSync @folder

    if ext
      files = files.filter (file) ->
        extLength = ext.length + 1    
        file.substr -extLength is '.' + ext

    filenamesWithPath = []

    filenamesWithPath.push @folder + '/' + file for file in files

    return filenamesWithPath

exports.FolderReader = FolderReader