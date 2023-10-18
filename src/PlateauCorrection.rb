load 'Plateau.rb'

##
# La classe PlateauCorrection représente un Plateau corrigé, elle hérite de Plateau
#
# Elle est capable de faire tous ce que peut faire un Plateau
#
# Le plateau est composé de case, et chaque case est composé d'un Element, qui est soit une ile, soit un pont, soit un element
#
# ==== Variables d'instance
#
# * @matrice => la matrice de case avec les éléments
# * @x => la largeur du tableau
# * @y => la longueur du tableau
class PlateauCorrection < Plateau

  # la method new est en privé
  private_class_method :new

  def PlateauCorrection.creer
    super()
  end

  # Redéfinition de la méthode car le plateau de correction contient des "-"
  #
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
        elsif line = ~/(^(([0-9]|-)+( )*)+)/
          ligne = $1
          @matrice.push(ligne.split(' ').map(&:to_i))
        end
      end
    end
  end

  # Méthode qui permet de générer le plateau de correction (transformer les entiers en Ponts, en Elements et en Ile)
  #
  # ==== Légende :
  # - -1 : correspond à un lien vertical (pont)          :  |
  # - -2 : correspond à deux liens verticals  (pont)     :  ||
  # - -3 : correspond à un lien horizontale   (pont)     :  -
  # - -4 : correspond à deux liens horizontales  (pont)  :  =
  # - 1 à 8 : correspond à une Ile
  # - 0 : correspond à un Element.
  #
  def generatePlateau
    x = -1
    y = -1
    @matrice.map! do |item|
      x += 1
      y = -1
      item.map! do |elem|
        y += 1
        case elem

        when -4
          elem = Case.creer(x, y, self, Pont.creer(true, 2))
        when -3
          elem = Case.creer(x, y, self, Pont.creer(true, 1))
        when -2
          elem = Case.creer(x, y, self, Pont.creer(false, 2))
        when -1
          elem = Case.creer(x, y, self, Pont.creer(false, 1))

        when 0
          elem = Case.creer(x, y, self, Element.creer)
        else
          e = Ile.creer(elem)
          @lesIles.push(e)
          elem = Case.creer(x, y, self, e)
        end
      end
    end
  end

end
