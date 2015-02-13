class ConvenienceFunctions

  @sanitizeString: (str) ->
    return str.replace /[^a-zA-Z0-9]+/g, ""

module.exports = exports = ConvenienceFunctions