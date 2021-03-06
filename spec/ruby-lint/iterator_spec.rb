require 'spec_helper'

describe 'RubyLint::Iterator' do
  example 'call after_initialize if it is defined' do
    iterator = Class.new(RubyLint::Iterator) do
      attr_reader :number

      def after_initialize
        @number = 10
      end
    end

    iterator.new.number.should == 10
  end

  example 'iterate over a simple AST' do
    ast = parse('10; 20; 30', false)

    iterator = Class.new(RubyLint::Iterator) do
      attr_reader :options

      def after_initialize
        @options = {:events => [], :numbers => []}
      end

      def on_root(node)
        @options[:events] << :on_root
      end

      def after_root(node)
        @options[:events] << :after_root
      end

      def on_int(node)
        unless @options[:events].include?(:on_int)
          @options[:events] << :on_int
        end

        @options[:numbers] << node.children[0]
      end

      def after_int(node)
        unless @options[:events].include?(:after_int)
          @options[:events] << :after_int
        end
      end
    end

    iterator = iterator.new(:numbers => [], :events => [])

    iterator.iterate(ast)

    iterator.options[:numbers].should == [10, 20, 30]
    iterator.options[:events].should  == [
      :on_root,
      :on_int,
      :after_int,
      :after_root
    ]
  end

  example 'iterate over a multi dimensional AST' do
    code = <<-CODE
class Example
  def some_method
    puts '10'
  end
end
    CODE

    ast = parse(code, false)

    iterator = Class.new(RubyLint::Iterator) do
      attr_reader :options

      def after_initialize
        @options = {}
      end

      def on_class(node)
        @options[:class] = node.children[0].children[1]
      end

      def on_def(node)
        @options[:method] = node.children[0]
      end

      def on_send(node)
        @options[:call] = node.children[1]
      end
    end

    iterator = iterator.new

    iterator.iterate(ast)

    iterator.options[:class].should  == :Example
    iterator.options[:method].should == :some_method
    iterator.options[:call].should   == :puts
  end

  example 'skipping child nodes' do
    code = <<-CODE
module A
  class B
  end
end
    CODE

    ast      = parse(code, false)
    iterator = Class.new(RubyLint::Iterator) do
      attr_reader :options

      def after_initialize
        @options = {:module => false, :class => false}
      end

      def on_module(node)
        options[:module] = true

        skip_child_nodes!(node)
      end

      def on_class(node)
        options[:class] = true
      end
    end

    iterator = iterator.new

    iterator.iterate(ast)

    iterator.options[:module].should == true
    iterator.options[:class].should  == false
  end

  example 'allow callbacks without arguments' do
    ast      = parse('10', false)
    iterator = Class.new(RubyLint::Iterator) do
      attr_reader :number

      def on_int
        @number = true
      end
    end.new

    iterator.iterate(ast)

    iterator.number.should == true
  end
end
