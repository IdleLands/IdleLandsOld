winston = require "winston"

class LogManager

  customLogger: null
  loggers = []

  getLogger: (name) ->
    if loggers[name]?
      return loggers[name]

    customLogger = new (winston.Logger)({ transports: [
      new (winston.transports.Console)({ level: 'warn' }),
      new (winston.transports.File)({ filename: name + '-errors.log', level: 'error' })
    ] })

    loggers[name] = customLogger

  setLoggerLevel: (name, level) ->
    if loggers[name]?
      loggers[name].transports.console.level = level