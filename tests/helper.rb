# ruby always comes handy for text generation
# this utility generated combination of different block kinds
# to check the matching routines.
blocks = [:hole, :wild, :fixed, :obstacle, :block_a, :block_b, :block_c]

blocks.each do |a|
  puts "{ #{"'#{a}'".ljust(12)}, #{"'#{a}'".ljust(12)}, true  },"
end

blocks.combination(2).map do |a, b|
  puts "{ #{"'#{a}'".ljust(12)}, #{"'#{b}'".ljust(12)}, true  },"
end
