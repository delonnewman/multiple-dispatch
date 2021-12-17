require 'benchmark'

n = 20_000_000

hash = { a: 1 }

object = Object.new
def object.test
  1
end

Benchmark.bm do |b|
  b.report do
    n.times do
      hash[:a]
    end
  end

  b.report do
    n.times do
      object.test
    end
  end
end
