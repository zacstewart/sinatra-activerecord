require 'bundler'

Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run the specs (use spec:name to run a single spec)"
task :spec do
  system "rspec -Ispec"
end

namespace :test do
  Dir["spec/**/*_spec.rb"].each do |spec|
    task_name = File.basename(spec)[/.+(?=_spec\.rb)/]
    task task_name do
      system "rspec -Ispec #{spec}"
    end
  end
end
