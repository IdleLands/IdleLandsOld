
_ = require "lodash"
glob = require "glob"
fs = require "fs"

files = glob.sync "../../src/**/*.coffee", cwd: __dirname
baseUrl = "https://github.com/IdleLands/IdleLands/blob/master"

class Markdoc
  constructor: (@tag, @headers, @sortIndex, @files) ->
    @parseFiles()
    @sortLines()
    @getFragments()
    @buildFile()

  parseFiles: ->

    @lines = []

    _.each @files, (file) =>

      fileContent = fs.readFileSync "#{__dirname}/#{file}", encoding: "UTF-8"
      lines = fileContent.split /\r\n|\n/

      for i in [0...lines.length]
        spliced = lines[i].split(' ').join('')
        continue if -1 is spliced.indexOf "##TAG:"

        [empty, tag, params] = lines[i].split ":"
        continue unless tag is @tag

        arr = _.map (params.split "|"), (s) -> s.trim()

        trimmedFile = file.substring file.indexOf "src"
        arr[@sortIndex] = "[#{arr[@sortIndex]}](#{baseUrl}/#{trimmedFile}#L#{i})"

        @lines.push arr

  sortLines: ->
    @lines = _.sortBy @lines, (line) => line[@sortIndex]

  getFragments: ->
    @head = fs.readFileSync "#{__dirname}/base/#{@tag}_head.md", encoding: "UTF-8" if fs.existsSync "#{__dirname}/base/#{@tag}_head.md"
    @foot = fs.readFileSync "#{__dirname}/base/#{@tag}_foot.md", encoding: "UTF-8" if fs.existsSync "#{__dirname}/base/#{@tag}_foot.md"

  buildFile: ->
    string = ""
    string += @head if @head

    string += "\n\n"
    string += @headers.join " | "
    string += "\n"
    string += (_.map @headers, -> "---").join " | "
    string += "\n"
    _.each @lines, (line) ->
      string += "#{line.join "|"}\n"
    string += "\n\n"

    string += @foot if @foot

    fs.writeFileSync "#{__dirname}/../../docs/#{@tag}.md", string

tags = [
  'APIROUTE'
]

headers = [
  ['Verb', 'Route', 'Request Data', 'Return Data']
]

sortIndexes = [
  1
]

_.each tags, (tag, i) -> new Markdoc tag, headers[i], sortIndexes[i], files