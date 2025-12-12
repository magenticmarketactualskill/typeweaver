# frozen_string_literal: true

require "tmpdir"
require "fileutils"

Given("I am in a Ruby project directory") do
  @project_dir = Dir.mktmpdir("typeweaver-test")
  Dir.chdir(@project_dir)
end

When("I run {string}") do |command|
  @output = `#{command} 2>&1`
  @exit_status = $?.exitstatus
end

Then("the output should contain {string}") do |expected_text|
  expect(@output).to include(expected_text)
end

Then("a directory named {string} should exist") do |dir_name|
  expect(File.directory?(File.join(@project_dir, dir_name))).to be true
end

Then("a file named {string} should exist") do |file_name|
  expect(File.exist?(File.join(@project_dir, file_name))).to be true
end

Then("the file {string} should contain {string}") do |file_name, expected_content|
  file_path = File.join(@project_dir, file_name)
  content = File.read(file_path)
  expect(content).to include(expected_content)
end

Then("the file {string} should not contain {string}") do |file_name, unexpected_content|
  file_path = File.join(@project_dir, file_name)
  content = File.read(file_path)
  expect(content).not_to include(unexpected_content)
end

After do
  FileUtils.rm_rf(@project_dir) if @project_dir && File.exist?(@project_dir)
end
