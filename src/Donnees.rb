##
# La classe Donnee créée la matrice du jeu à partir d'un fichier donnée.
#
# Elle est capable :
#
# - De charger une matrice avec un fichier
# - De s'afficher
#
# ==== Variables d'instance
# * @matrix => Matrice du jeu
# * @x => Le nombre de ligne de la matrice
# * @y => Le nombre de colonne de la matrice
class Donnees

  # Méthode d'initialisation d'un donnée
  #
  # Par défaut :
  #
  # - @matrix = Array.new()
  # - @x = 0
  # - @y = 0
  def initialize
    @matrix = []
    @x = 0
    @y = 0
  end

  # Accès en lecture et en écriture
  attr_accessor :matrix, :x, :y, :string

  # Méthode qui permet de générer une matrice avec un fichier donné
  #
  # ==== Attribut
  # * +file+ - Un fichier
  def getMatrice(file)
    File.open(file, 'r') do |fichier|
      while (line = fichier.gets)
        if (line = ~/^(x:)([0-9]+)( )(y:)([0-9]+)/)
          @x = $2.to_i
          @y = $5.to_i

        elsif (line = ~/(^([0-9]+( )*)+)/)
          ligne = $3 + $1
          @matrix.push(ligne.split(' ').map(&:to_i))
        end
      end
    end
  end

  # Méthode qui affiche la matrice générée
  def to_s
    puts "le x : #{@x} , le y : #{@y}"
    puts "la matrice du jeu : "
    puts @matrix.inspect
    @matrix.each do |row|
      row.each do |column|
        print "#{column} "
      end
      print "\n"
    end
  end

end
