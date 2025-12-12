# frozen_string_literal: true

require "spec_helper"

RSpec.describe TypeWeaver::IR::IntermediateRepresentation do
  let(:ir) { described_class.new }

  describe "#add_class" do
    it "adds a class to the IR" do
      klass = TypeWeaver::IR::ClassNode.new("User")
      ir.add_class(klass)
      
      expect(ir.classes).to include(klass)
    end
  end

  describe "#add_module" do
    it "adds a module to the IR" do
      mod = TypeWeaver::IR::ModuleNode.new("Helpers")
      ir.add_module(mod)
      
      expect(ir.modules).to include(mod)
    end
  end

  describe "#find_class" do
    it "finds a class by name" do
      klass = TypeWeaver::IR::ClassNode.new("User")
      ir.add_class(klass)
      
      expect(ir.find_class("User")).to eq(klass)
    end

    it "returns nil if class not found" do
      expect(ir.find_class("NonExistent")).to be_nil
    end
  end

  describe "#all_nodes" do
    it "returns all modules and classes" do
      klass = TypeWeaver::IR::ClassNode.new("User")
      mod = TypeWeaver::IR::ModuleNode.new("Helpers")
      
      ir.add_class(klass)
      ir.add_module(mod)
      
      expect(ir.all_nodes).to contain_exactly(klass, mod)
    end
  end
end
