namespace :generate do
  desc 'Generates a set of definitions for a constant'
  task :definitions, :constant, :directory, :overwrite do |task, args|
    abort 'You have to specify a constant'  unless args[:constant]
    abort 'You have to specify a directory' unless args[:directory]

    generator = RubyLint::DefinitionGenerator.new(
      args[:constant],
      args[:directory],
      :overwrite => !!args[:overwrite]
    )

    generator.generate
  end

  desc 'Generates definitions for all available constants'
  task :everything, :overwrite do |task, args|
    args.with_defaults(:overwrite => false)

    require_relative '../gen/stdlib/requires'

    directory = File.expand_path(
      '../../lib/ruby-lint/definitions/core/',
      __FILE__
    )

    constants_file = File.expand_path(
      '../../gen/stdlib/constants.txt',
      __FILE__
    )

    allowed   = File.read(constants_file).split("\n")
    ignore    = Object.constants.map(&:to_s) - allowed
    generator = RubyLint::DefinitionGenerator.new(
      Object,
      directory,
      :overwrite => !!args[:overwrite],
      :ignore    => ignore
    )

    generator.generate
  end

  desc 'Generates definitions for Rails'
  task :rails do
    require 'mail'
    require 'rails/all'

    dir = File.expand_path('../../lib/ruby-lint/definitions/rails', __FILE__)

    constants = [
      'AbstractController',
      'ActionController',
      'ActionDispatch',
      'ActionMailer',
      'ActionPack',
      'ActionView',
      'ActiveModel',
      'ActiveRecord',
      'ActiveSupport',
      'Arel',
      'Rails',
      'Sprockets',
    ]

    constants.each do |name|
      constant = Object.const_get(name)

      # Deal with Rails' autoloading nonsense.
      if constant.respond_to?(:eager_load!)
        constant.eager_load!
      end

      Rake::Task['generate:definitions'].execute(
        :constant  => name,
        :directory => dir,
        :overwrite => true
      )
    end
  end
end
