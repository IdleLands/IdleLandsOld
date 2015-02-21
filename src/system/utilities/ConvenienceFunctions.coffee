class ConvenienceFunctions

  @sanitizeString: (str) ->
    return str.replace /[^a-zA-Z0-9_,.;?! ]+/g, ""

  @sanitizeStringNoPunctuation: (str) ->
    return str.replace /[^a-zA-Z0-9 ]+/g, ""

  @romanize: (num) ->
    if not (+num)
      return false
    digits = String(+num).split("")
    key = ["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM",
           "","X","XX","XXX","XL","L","LX","LXX","LXXX","XC",
           "","I","II","III","IV","V","VI","VII","VIII","IX"]
    roman = ""
    i = 3
    while i--
      roman = (key[+digits.pop() + (i * 10)] || "") + roman

    return Array(+digits.join("") + 1).join("M") + roman

module.exports = exports = ConvenienceFunctions