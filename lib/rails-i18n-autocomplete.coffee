child = require 'child_process'
fs = require 'fs'
yaml = require('js-yaml');
_ = require 'underscore'

{CompositeDisposable} = require 'atom'

module.exports = RailsI18nAutocomplete =
  arrayDot: (ar, prepend = '')->
    result = {}
    for k, v of ar
      if v instanceof Object
        _.extend result, @arrayDot(v, "#{prepend}#{k}.")
      else
        result["#{prepend}#{k}"] = v
    result

  searchLocaleFiles: ->
    @ymls = _.without(child.spawnSync('find', ['-L', @locales_path, '-name', '*.yml'])
      .stdout.toString().trim().split("\n"), "")

  loadLocales: ->
    suggestions = []

    for yml_path in @ymls
      contents = fs.readFileSync(yml_path).toString()
      yml = yaml.safeLoad(contents)

      for k, v of yml
        _.extend suggestions, @arrayDot(v)

    @provider.suggestions = _.pairs suggestions

  activate: (state) ->
    @provider = require './provider'
    @project_path = atom.project.getPaths()[0]
    @locales_path = "#{@project_path}/config/locales"

    @searchLocaleFiles()
    @loadLocales()

    fs.stat @locales_path, (err, stat)=>
      if not err and stat.isDirectory()
        fs.watch @locales_path, (event, filename)=>
          if event == 'change' or event == 'rename'
            @searchLocaleFiles()
            @loadLocales()

  deactivate: ->

  serialize: ->

  getProvider: ->
    @provider
