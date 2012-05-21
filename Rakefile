require 'bundler'

Bundler::GemHelper.install_tasks

task :default => :test

task :test do
  Dir["test/**/*_test.rb"].each do |test|
    system "ruby -Itest #{test}"
  end
end

namespace :test do
  Dir["test/**/*_test.rb"].each do |test|
    name = test[/\w+(?=_test.rb$)/]
    task name do
      system "ruby -Itest #{test}"
    end
  end
end
