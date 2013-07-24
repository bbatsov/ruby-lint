require 'spec_helper'

describe RubyLint::Report::Entry do
  example 'sort a list of entries' do
    entries = [
      RubyLint::Report::Entry.new(:info, 'info', 2, 1, 'a.rb'),
      RubyLint::Report::Entry.new(:error, 'error', 1, 1, 'a.rb'),
      RubyLint::Report::Entry.new(:warning, 'warning', 3, 1, 'a.rb'),
      RubyLint::Report::Entry.new(:warning, 'warning', 1, 1, 'b.rb'),
      RubyLint::Report::Entry.new(:error, 'error', 1, 1, 'c.rb'),
    ].sort

    entries[0].file.should  == 'a.rb'
    entries[0].level.should == :error

    entries[1].file.should  == 'a.rb'
    entries[1].level.should == :info

    entries[2].file.should  == 'a.rb'
    entries[2].level.should == :warning

    entries[3].file.should  == 'b.rb'
    entries[3].level.should == :warning

    entries[4].file.should  == 'c.rb'
    entries[4].level.should == :error
  end
end