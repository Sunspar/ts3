require 'bundler/setup'

##########
# Testing helpers
##########
desc 'TS3 | Test suites'
namespace :tests do
  desc 'TS3 | Tests | Run integration tests via Test Kitchen'
  task :integration do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    kitchen = Kitchen::Loader::YAML.new(local_config: '.kitchen.yml')
    Kitchen::Config.new(loader: kitchen).instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'TS3 | Tests | Run ChefSpec unit tests'
  task :unit do
    require 'chefspec'
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new('ts3_tests_unit') do |cfg|
      cfg.pattern = 'test/chefspec/**/*_spec.rb'
    end
    Rake::Task['ts3_tests_unit'].execute
  end
end

##########
# Style checking helpers
##########
desc 'TS3 | Style | Foodcritic (Chef) checks'
require 'foodcritic'
FoodCritic::Rake::LintTask.new('style:chef') do |t|
  t.options = {
    fail_tags: ['any']
  }
end

desc 'TS3 | Style | RuboCop tests'
require 'rubocop/rake_task'
RuboCop::RakeTask.new('style:ruby')

desc 'TS3 | Style | All Style checks'
task 'style:all' => ['style:chef', 'style:ruby']

##########
# Project interaction helpers
##########
desc 'TS3 | Project interaction helpers'
namespace :project do
  desc 'TS3 | Project | Version bumping'
  task :tag do
    require 'bump'
    require 'bump/tasks'
    require 'open3'
    version = Bump::Bump.current
    Open3.capture2("git push && git tag v#{version} && git push --tags")
  end

  desc 'TS3 | Project | Deploy to supermarket'
  task :deploy, :key do |_, args|
    require 'open3'
    key = args[:key]
    Open3.capture2("knife cookbook site share ts3 'Applications' --key #{key}")
  end

  desc 'TS3 | Project | Release new version'
  task :release, :key do |_, args|
    key = args[:key]
    Rake::Task['project:tag'].invoke
    Rake::Task['project:deploy'].invoke(key)
  end
end
