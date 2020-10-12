include GenericFunctions

class Person; end
class Jackie; end
class Delon; end

multi :love, Delon, Jackie do |a, b|
  puts "#{a} loves #{b}"
end

multi :love, Delon, Person do |a, b|
  puts "#{a} loves Jackie, not sure about #{b}"
end

multi :love, Jackie, Person do |a, b|
  puts "#{a} loves Delon, not sure about #{b}"
end