load 'Pont.rb'
load 'Element.rb'
load 'Ile.rb'
load 'Case.rb'

require 'matrix'

##
# La classe Plateau représente les Case du jeu, le plateau a une taille défini dans le fichier
#
# Elle est capable : 
# - De charger un fichier
# - De générer le plateau en fonction du fichier
# - D'ajouter les ponts possible
# - De s'afficher
#
# Le plateau est composé de case, et chaque case est composé d'un Element, qui est soit une ile, soit un pont, soit un element
#
# ==== Variables d'instance
#
# * @matrice => la matrice de case avec les éléments
# * @x => la largeur du tableau
# * @y => la longueur du tableau
# * @lesIles => tableau des iles du plateau
class Plateau

  ###########################################################################################
  #						Methodes de classe
  ###########################################################################################

  # Mettre new en privée
  private_class_method :new

  # Méthode qui permet de créer un plateau
  def Plateau.creer
    new
  end

  # Méthode qui permet d'initialiser un plateau
  #
  # Par defaut :
  # - @x = 0
  # - @y = 0
  #
  def initialize
    @x = 0
    @y = 0
    @matrice = Array.new { Array.new } # On initialise le tableau des cases pour le charger
    @lesIles = [] # On initialise le tableau des ILes
  end

  ##########################################################################################
  #						Methodes
  ##########################################################################################

  # Accès en lecture et en écriture
  attr_accessor :matrice, :plateau, :x, :y

  # Méthode qui génère la matrice à partir du fichier passé en parametre
  # elle récupère la taille de la matrice, valeur de x(lignes) et la valeur de y(colonne),
  # puis parcourir la matrice et charger les valeurs.
  #
  # ===== Attributs
  #
  # * +file+ - le fichier qui contient le niveau à charger
  #
  def generateMatrice(file)
    File.open(file, 'r') do |fichier|
      while line = fichier.gets
        if line = ~/^(x:)([0-9]+)( )(y:)([0-9]+)/
          @x = $5.to_i
          @y = $2.to_i

        elsif line = ~/(^([0-9]+( )*)+)/
          ligne = $3 + $1
          @matrice.push(ligne.split(' ').map(&:to_i))
        end
      end
    end
  end

  # Méthode qui permet de générer le plateau (transformer les entiers en Elements et en Ile)
  def generatePlateau
    # Ne plus toucher!
    x = -1
    y = -1
    @matrice.map! do |item|
      x += 1
      y = -1
      item.map! do |elem|
        y += 1
        if elem == 0
          elem = Case.creer(x, y, self, Element.creer)
        else
          e = Ile.creer(elem)
          @lesIles.push(e)
          elem = Case.creer(x, y, self, e)
        end
      end
    end
  end

  # Méthode qui permet de retourner la matrice de jeu en string.
  #
  # ==== Retourne
  #
  # un string
  def to_s
    res = "le x : #{@x} , le y : #{@y}\n"
    res = "#{res}la matrice du jeu : \n"
    @matrice.each do |row|
      row.each do |column|
        res = res + "#{column} "
      end
      res = "#{res}\n"
    end

    return res
  end

  # Méthode de débogage qui permet d'afficher la matrice une fois que les éléments ont été initialisé
  #
  def affiche
    @matrice.each do |row|
      row.each do |column|
        if column.element.instance_of?(Element)
          print('E ')
        elsif column.element.instance_of?(Ile)
          print('I ')
        elsif column.element.instance_of?(Pont)
          print('P ')
        end
      end
      print "\n"
    end
  end

  # Méthode qui permet d'ajouter des ponts là ou le joueur pourra en créer
  #
  def ajouterPont
    @matrice.each do |row|
      row.each do |column|
        if !column.nil? && column.element.instance_of?(Ile)
          column.ajouterPontDroite
          column.ajouterPontBas
        end
      end
    end
  end

  # Méthode de débogage qui permet d'afficher un plateau de jeu en terminal
  #
  # * . : ponts possibles
  # * - : pont simple
  # * = : ponts doubles
  # * n : iles (valeur)
  def afficherJeu
    print '     '
    (0..@y - 1).each { |i|
      print " #{i} "
    }
    print "\n    "
    (0..@y - 1).each { |i|
      print '###'
    }
    i = 0
    @matrice.each do |row|
      if i < 10
        print "\n #{i}  #"
      else
        print "\n #{i} #"
      end
      i += 1
      row.each do |column|
        elem = column.element
        if elem.estIle?
          print " #{elem.valeur.to_s} "
        elsif elem.estPont?
          if elem.nb_ponts == 0
            print ' . '
          elsif elem.nb_ponts == 1
            if elem.estHorizontal?
              print '---'
            else
              print ' | '
            end
          elsif elem.estHorizontal?
            print '==='
          else
            print '|| '
          end
        else
          print '   '
        end
      end
    end
    print "\n\n"
  end

  # Méthode qui trouve une case dans la matrice
  #
  # ==== Attributs
  #
  # * +unX+ - coordonnée x de la case
  # * +unY+ - coordonnée y de la case
  #
  # ==== Retourne
  #
  # une case
  def getCase(unX, unY)
    @matrice[unX][unY]
  end

  # Méthode qui permet de verifier les coordonnées passées en paramètre si elles ne débordent pas
  # par rapport à la dimension de la matrice
  #
  # ==== Retourne
  #
  # true si les coordonnées sont bonnes, false sinon

  def verifCoord(unX, unY)
    return (unX >= 0 && unX < @x) && (unY >= 0 && unY < @y)
  end

  # Méthode qui permet de savoir si une partie est finie.
  #
  # ==== Retourne
  #
  # true si la partie est fini, false sinon
  def partieFini?
    res = true
    @lesIles.map { |x| res = res && x.estFini? }
    return res
  end

end

