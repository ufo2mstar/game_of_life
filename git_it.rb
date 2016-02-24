files_to_add = Dir.glob('*.rb')

files_to_add.each{ |file|
str = "`git add #{file}`"
puts str
eval str
}

puts "Enter Comment for this commit :"

txt = gets.chomp

msg = "#{txt} '#{Time.now}'"
str = "`git commit -m \"#{msg}\"`"

eval str
