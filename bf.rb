SUCCESS = 1
FAILURE = 0

INC     = 0
DEC     = 1
LSHFT   = 2
RSHFT   = 3
OUTPUT  = 4
INPUT   = 5
OPEN    = 6
CLOSE   = 7
COMMENT = 8
EOF     = 9

class Node
  attr_accessor :op, :operand
  def initialize(op, operand=nil)
    @op = op
    @operand = operand
  end
end

class Compiler
  def initialize
    @stack = []
  end

  def compile(code)
    nodes = []
    i = 0
    for chr in code.split('') do
      case chr
      when '+'
        nodes << Node.new(INC)
      when '-'
        nodes << Node.new(DEC)
      when '<'
        nodes << Node.new(LSHFT)
      when '>'
        nodes << Node.new(RSHFT)
      when '.'
        nodes << Node.new(OUTPUT)
      when ','
        nodes << Node.new(INPUT)
      when '['
        @stack << i
        nodes << Node.new(OPEN)
      when ']'
        if @stack.size == 0
          puts "On Char #{i}: Mismatched ']'"
          return FAILURE
        end
        a = @stack.pop()
        nodes[a].operand = i
        nodes << Node.new(CLOSE, a)
      else
        nodes << Node.new(COMMENT)
      end
      i += 1
    end
    if @stack.size != 0
      puts "Unexpected End of File: Unclosed '['"
      return FAILURE
    end
    nodes << Node.new(EOF)
    nodes
  end
end

class Interpreter
  def initialize
    @data = Array.new(1, 0)
    @pointer = 0
  end

  def run(nodes)
    i = 0
    while i < nodes.size do
      node = nodes[i]
      case node.op
      when INC
        if @data[@pointer] == 255
          @data[@pointer] = 0
        else
          @data[@pointer] += 1
        end
      when DEC
        if @data[@pointer] == 0
          @data[@pointer] = 255
        else
          @data[@pointer] -= 1
        end

      when LSHFT
        if @pointer == 0
          @pointer = @data.size - 1
        else
          @pointer -= 1
        end
      when RSHFT
        @pointer += 1
        unless @data[@pointer]
          @data << 0
        end
      
      when OUTPUT
        print @data[@pointer].chr
      when INPUT
        @data[@pointer] = gets[0].ord % 256

      when OPEN
        if @data[@pointer] == 0
          i = node.operand
        end
      when CLOSE
        if @data[@pointer] != 0
          i = node.operand
        end

      else
      end
      i += 1
    end
    return [@data, @pointer]
  end
end

def run(filename)
  code = File.read(filename)
  res1 = Compiler.new.compile(code)
  if res1 == 0
    return FAILURE
  end
  puts "--------------\nOutput:\n"
  res2 = Interpreter.new.run(res1)
  r = res2[0]
  r.map!.with_index { |x, k| 
    k == res2[1] ? "[#{x}]" : "#{x}"
  }
  puts "\nSlots:\n{ #{r.join(", ")} }\n--------------"
  return SUCCESS
end

def main()
  unless ARGV[0]
    puts "File name expected"
    return FAILURE
  end
  run(ARGV[0])
end

main()
