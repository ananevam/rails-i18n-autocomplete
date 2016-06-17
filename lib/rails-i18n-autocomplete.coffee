child = require 'child_process'
fs = require 'fs'
yaml = require('js-yaml');
_ = require 'underscore'
ConfigSchema = require('./configuration.coffee')

{CompositeDisposable} = require 'atom'

module.exports = RailsI18nAutocomplete =
  config: ConfigSchema.config
  ymls: []
  package_name: 'rails-i18n-autocomplete'

  arrayDot: (ar, prepend = '')->
    result = {}
    for k, v of ar
      if v instanceof Object
        _.extend result, @arrayDot(v, "#{prepend}#{k}.")
      else
        result["#{prepend}#{k}"] = v
    result

  searchLocaleFiles: ->
    @ymls = []
    for locales_path in @locales_paths
      @ymls.push _.without(child.spawnSync('find', ['-L', locales_path, '-name', '*.yml'])
        .stdout.toString().trim().split("\n"), "")
    @ymls = _.flatten(@ymls)

  loadLocales: ->
    suggestions = []

    for yml_path in @ymls
      try
        contents = fs.readFileSync(yml_path).toString()
        yml = yaml.safeLoad(contents, {json: true})

        for k, v of yml
          _.extend suggestions, @arrayDot(v)

    @provider.suggestions = _.pairs suggestions

  setLocalesPaths: ->
    @locales_paths = []

    for locales_path in atom.config.get("#{@package_name}.localesPaths")
      path = "#{@project_path}/#{locales_path}/"
      @locales_paths.push path if fs.existsSync(path)

  loadPackage: ->
    @setLocalesPaths()

    @searchLocaleFiles()
    @loadLocales()

    for locales_path in @locales_paths
      fs.stat locales_path, (err, stat)=>
        if not err and stat.isDirectory()
          fs.watch locales_path, (event, filename)=>
            if event == 'change' or event == 'rename'
              @searchLocaleFiles()
              @loadLocales()

  activate: (state) ->
    @provider = require './provider'
    @project_path = atom.project.getPaths()[0]

    atom.config.observe "#{@package_name}.localesPaths", (value) =>
      @loadPackage()

  deactivate: ->

  serialize: ->

  getProvider: ->
    @provider
