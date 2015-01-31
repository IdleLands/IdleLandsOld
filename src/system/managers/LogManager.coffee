winston = require "winston"
Q = require "q"

class LogManager

  customLogger: null
  loggers = {}

  getLogger: (name) ->
    if loggers[name]?
      return loggers[name]

    customLogger = new (winston.Logger)({ transports: [
      new (winston.transports.Console)({ level: 'warn' }),
      new (winston.transports.File)({ filename: __dirname + '/logs/' + name + '-errors.log', level: 'warn' })
    ] })

    loggers[name] = customLogger

  setLoggerLevel: (name, level) ->
    if loggers[name]?
      loggers[name].transports.console.level = level
      loggers[name].transports.file.level = level
      return Q {isSuccess: yes, code: 75, message: "Logger level of " + name + " set to " + level}
    return Q {isSuccess: no, code: 130, message: "No logger known with name " + name}

module.exports = exports = LogManager