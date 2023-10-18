##
# La classe Coup permet de sauvegarder les coups pour pouvoir faire les undo ou les redo.
#
# On peut créer un coup (qui sera créé à chaque action de l'utilisateur)
#
# ==== Variables d'instance
#
# * @typeCoup : le type de coup réaliser par le joueur
# * @pont : le pont sur lequel le clic est réalisé
# * @sens : le sens du pont
class Coup

  ###################################################################################
  #							Methodes de classe
  ###################################################################################

  # Méthode qui permet de créer un nouveau coup
  #
  # ==== Attributs
  #
  # * +typeCoup+ : le type de coup réaliser par le joueur (clic gauche ou droit)
  # * +pont+ : le pont sur lequel le clic est réalisé
  # * +sens+ : le sens du pont (horizontal ou vertical)
  #
  def Coup.creer(typeCoup, pont, sens)
    new(typeCoup, pont, sens)
  end

  # Méthode qui permet de initialiser un coup
  #
  # ==== Attributs
  #
  # * +typeCoup+ : le type de coup réaliser par le joueur (clic gauche ou droit)
  # * +pont+ : le pont sur lequel le clic est réalisé
  # * +sens+ : le sens du pont (horizontal ou vertical)
  #
  def initialize(typeCoup, pont, sens)
    @typeCoup = typeCoup
    @pont = pont
    @sens = sens
  end

  # Méthode qui vérifie si type de coup est ajouter
  def estAjout?
    @typeCoup == 'ajouter'
  end

  # Méthode qui vérifie si type de coup est ajouter
  def estEnleve?
    @typeCoup == 'enlever'
  end

  # Méthode qui vérifie si le sens du coup est vertical
  def estVertical?
    return @sens == 'vertical'
  end

  # Méthode qui vérifie si le sens du coup est horizontal
  def estHorizontal?
    return @sens == 'horizontal'
  end

  # Méthode qui affiche le sens du coup
  def to_s
    "sens du coup : #{@sens.to_s}"
  end

  # Accès en lecture
  attr_reader :typeCoup, :pont, :sens

end
