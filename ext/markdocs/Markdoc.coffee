
_ = require "lodash"
glob = require "glob"
fs = require "fs"

files = glob.sync "../../src/**/*.coffee", cwd: __dirname
baseUrl = "https://github.com/IdleLands/IdleLands/blob/master"

class Markdoc
  constructor: (@doc, @files) ->
    @parseFiles()
    @sortLines()
    @getFragments()
    @buildFile()

  getSortIndex: (key) ->
    @doc.sortIndexes[@doc.tags.indexOf key]

  parseFiles: ->

    @lines = {}
    _.each @doc.tags, (tag) => @lines[tag] = []

    _.each @files, (file) =>

      fileContent = fs.readFileSync "#{__dirname}/#{file}", encoding: "UTF-8"
      lines = fileContent.split /\r\n|\n/

      for i in [0...lines.length]
        spliced = lines[i].split(' ').join('')
        continue if -1 is spliced.indexOf "##TAG:"

        [empty, tag, params] = lines[i].split ":"
        continue unless tag in @doc.tags

        arr = _.map (params.split "|"), (s) -> s.trim()

        trimmedFile = file.substring file.indexOf "src"
        arr[@getSortIndex tag] = "[#{arr[@getSortIndex tag]}](#{baseUrl}/#{trimmedFile}#L#{i})"

        @lines[tag].push arr

  sortLines: ->
    _.each (_.keys @lines), (key) =>
      @lines[key] = _.sortBy @lines[key], (line) => line[@getSortIndex key]

  getFragments: ->
    @head = fs.readFileSync "#{__dirname}/base/#{@doc.key}_head.md", encoding: "UTF-8" if fs.existsSync "#{__dirname}/base/#{@doc.key}_head.md"
    @foot = fs.readFileSync "#{__dirname}/base/#{@doc.key}_foot.md", encoding: "UTF-8" if fs.existsSync "#{__dirname}/base/#{@doc.key}_foot.md"

  buildFile: ->
    string = ""
    string += @head if @head

    string += "\n\n"

    _.each @doc.tags, (tag, i) =>
      string += @doc.headers[i].join " | "
      string += "\n"
      string += (_.map @doc.headers[i], -> "---").join " | "
      string += "\n"
      _.each @lines[tag], (line) ->
        string += "#{line.join " | "}\n"

      string += "\n\n"

    string += @foot if @foot

    fs.writeFileSync "#{__dirname}/../../docs/#{@doc.key}.md", string

docs = [
  {
    key: 'APIROUTE',
    tags: ['APIROUTE', 'APIROUTE_PARAM', 'APIROUTE_RETVAL']
    headers: [
      ['Verb', 'Route', 'Request Data', 'Return Data']
      ['Parameter', 'Type', 'Definition', 'Restrictions']
      ['Return Value', 'Type', 'Description']
    ]
    sortIndexes: [
      1
      0
      0
    ]
  }
  {
    key: 'REDUCTION',
    tags: ['REDUCTION']
    headers: [
      ['Reduction', 'Base Value', 'Arguments Passed', 'Description']
    ]
    sortIndexes: [
      0
    ]
  }
]

_.each docs, (doc, i) -> new Markdoc doc, files