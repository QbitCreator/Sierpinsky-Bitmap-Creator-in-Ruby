require 'rubygems'
require 'matrix.rb'

puts("Willkommen zum Sierpinsky-Fraktal-Generator von Leif-Erik Hallmann!")
puts("Wie soll das neue Bild heißen?")
name = gets.chomp
puts("Wie groß soll das Bild sein? Bitte als Zahl eingeben:")
size = gets.chomp.to_i
puts("\nSoll es ein Drei-, Vier- oder Fünfeck sein? Bitte als Zahl (3, 4 oder 5) angeben:")
shape = gets.chomp.to_i-3
puts("\nWie ausführlich soll gearbeitet werden? (Standardwert: 2, höhere Werte brauchen mehr Zeit, niedrigere weniger)")
verbosity = gets.chomp.to_f
puts("\nDas Bild wird " + size.to_s + "x" + size.to_s + " Pixel, also " + (size*size/1000000).to_s + "MP groß. Das entspricht ca.:" + (size*size*0.0000038142).to_s + "MB")
puts('Zum Abbrechen "Strg+C" drücken.' + "\n") 
puts("Berechne... Dies könnte je nach Prozessor und Bildgröße etwas dauern...")

@image = Matrix.zero(size)

start = [[Matrix.column_vector([0.0, ((size-1)/2).round(0).to_f]), Matrix.column_vector([size-1.to_f, 0.0]), Matrix.column_vector([size-1.to_f, size-1.to_f])],
	[Matrix.column_vector([0.0, 0.0]), Matrix.column_vector([size-1.to_f, 0.0]), Matrix.column_vector([0.0, size-1.to_f]), Matrix.column_vector([size-1.to_f, size-1.to_f])],
	[Matrix.column_vector([0.0, ((size-1)/2).round(0).to_f]), Matrix.column_vector([((size-1).to_f*0.38), size-1.to_f]), Matrix.column_vector([((size-1).to_f*0.38), 0.0]), Matrix.column_vector([size-1.to_f, ((size-1).to_f*0.18)]), Matrix.column_vector([size-1.to_f, ((size-1).to_f*0.82)])]
	]

current_p = Matrix.column_vector([((size-1)/2).round(0).to_f, (size-1).to_f])

start[shape].each do |v|
	@image[v[0,0], v[1,0]] = 1
end

((size.to_f**verbosity).to_i).times do
	@image[current_p[0,0].round.to_i, current_p[1,0].round.to_i] = 1
	length = ((start[shape][rand(0..shape+2)] - current_p)/2)
	current_p = current_p + length
end

class Bitmap
  MAGIC = "BM"
  
  def initialize(io, width, height)
    io = File.open(io, "wb") if io.is_a?(String)
    @io = io
    @width = width
    @height = height
    
    write_header
  end
  
  private def write_header
    bitmap_size = @width * @height * 4
    file_size = 54 + bitmap_size
    
    # Magic
    @io.write MAGIC
    
    @io.write [ file_size, 0, 54 ].pack("l<*")
    
    info = [
      40, 
      @width, 
      -@height, 
      1, 
      32, 
      0, 
      bitmap_size, 
      0, 
      0, 
      0, 
      0, 
    ]
    
    @io.write info.pack("L<l<l<S<S<l<l<L<L<l<l<")
  end
  
  def <<(argb)
    @io.write Array(argb).pack("l<*")
    self
  end
  
  def close
    @io.flush
    @io.close
  end
end

pic = Bitmap.new(name+".bmp", size, size)
@total = 0
@x = 0
@y = 0

size.times do 
  row = []
  size.times do
    c = @image[@y, @x]
    if c == 1 then
      c = 99999999
      @total += 1
    end
    row.push(c)
    @x += 1 
  end
  @y += 1 
  @x = 0
  pic << row
end

pic.close # Done.

puts("Fertig, sieh in dem Ordner dieses Programms nach!")