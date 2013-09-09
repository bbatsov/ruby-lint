module RubyLint
  module AST
    ##
    # Extends the Node class provided by the `parser` Gem with various extra
    # methods.
    #
    class Node < ::Parser::AST::Node
      include ::RubyLint::VariablePredicates

      ##
      # @return [Numeric]
      #
      def line
        return location.expression.line
      end

      ##
      # @return [Numeric]
      #
      def column
        return location.expression.column
      end

      ##
      # @return [String]
      #
      def file
        return location.expression.source_buffer.name
      end

      ##
      # @return [String]
      #
      def name
        return const? ? children[-1].to_s : children[0].to_s
      end

      ##
      # Similar to `#inspect` but formats the value so that it fits on a single
      # line.
      #
      # @return [String]
      #
      def inspect_oneline
        return inspect.gsub(/\s*\n\s*/, ' ')
      end

      ##
      # Generates a unique SHA1 digest hash based on the current node.
      #
      # @return [String]
      #
      def sha1
        input = inspect

        if location and location.expression
          input << "#{file}#{line}#{column}"
        end

        return Digest::SHA1.hexdigest(input)
      end
    end # Node
  end # AST
end # RubyLint
