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
  def initialize(op, operand = nil)
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
    code.split('').each do |chr|
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
        a = @stack.pop
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
    @data = { 0 => 0 }
    @pointer = 0
  end

  def run(nodes)
    i = 0
    while i < nodes.size
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
          @pointer = 255
        else
          @pointer -= 1
        end
        @data[@pointer] = 0 unless @data[@pointer]

      when RSHFT
        @pointer += 1
        @pointer = 0 if @pointer == 256
        @data[@pointer] = 0 unless @data[@pointer]

      when OUTPUT
        print @data[@pointer].chr
      when INPUT
        @data[@pointer] = gets[0].ord % 256

      when OPEN
        i = node.operand if @data[@pointer] == 0
      when CLOSE
        i = node.operand if @data[@pointer] != 0

      end
      i += 1
    end
    [@data, @pointer]
  end
end

def run(filename)
  code = File.read(filename)
  res1 = Compiler.new.compile(code)
  return FAILURE if res1 == 0

  puts "--------------\nOutput:\n"
  res2 = Interpreter.new.run(res1)
  r = res2[0].values
  r.map!.with_index do |x, k|
    k == res2[1] ? "[#{x}]" : x.to_s
  end
  puts "\nSlots:\n{ #{r.join(', ')} }\n--------------"
  SUCCESS
end

def main
  unless ARGV[0]
    puts 'File name expected'
    return FAILURE
  end
  run(ARGV[0])
end

main
