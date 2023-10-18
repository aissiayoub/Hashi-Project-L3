load 'Element.rb'

##
# La classe Pont représente un pont sur le plateau, elle hérite de Element
# Un Pont est un Element contenu dans une case, il permet de faire le lien entre 2 Ile
#
# Elle peut : 
# - Créer un pont
# - Savoir si l'element est un pont
# - Ajouter un pont (soit il y a 1 pont, soit 2, soit 0)
# - Enlever le(s) pont(s)
# - Connaître l'orientation du pont (horizontale ou verticale)
#
# ==== Variables d'instance
#
# * @sensHorizontale => un boolean qui indique si le pont est horizontal ou pas
# * @nb_ponts => le nombre de ponts (0,1,2)
# * @deuxSens => le nombre de sens que le pont peut avoir (horizontal et/ou vertical)
# * @erreur => un boolean qui indique si le pont est faux ou non
# * @pontPossible => un boolean qui indique s'il faut surbriller le pont ou non
class Pont < Element

  ##############################################################################################################
  #                                           Methodes de classe
  ##############################################################################################################

  #la method new est en privé
  private_class_method :new

  # Méthode qui permet de créer un pont
  #
  # ==== Attributs
  #
  # * +unSens+ - booléen vérifiant si le sens du pont est horizontal
  # * +uneValeur+ - le nombre de ponts (un entier)
  #
  def Pont.creer(unSens, uneValeur = 0)
    new(unSens, uneValeur)
  end

  # Méthode qui permet d'initialiser un pont
  #
  # Par defaut :
  # - @sensHorizontal = false
  # - @erreur = false
  # - @deuxSens = 0
  #
  # ==== Attributs
  #
  # * +unSens+ - booléen vérifiant si le sens du pont est horizontal
  # * +uneValeur+ - le nombre de ponts (un entier)
  #
  def initialize(unSens, uneValeur)
    super()
    @sensHorizontal = unSens
    @nb_ponts = uneValeur
    @deuxSens = 0
    @erreur = false
    @pontPossible = false
  end

  ###############################################################################################################
  #                                               Methodes
  ###############################################################################################################

  # Accès en lecture et en écriture
  attr_accessor :sensHorizontal, :nb_ponts, :erreur, :pontPossible

  # Méthode qui vérifie si c'est un pont
  #
  # ==== Retourne
  #
  # true
  def estPont?
    true
  end

  # Méthode qui permet d'ajouter un pont (s'active lorsque l'utilisateur fait un clic droit)
  def ajoutePont
    if @nb_ponts < 2
      @nb_ponts += 1
      @erreur = false
    end
  end

  # Méthode qui permet d'enlever les ponts (mettre à 0)
  def enlevePont
    nb_ponts = 0
    @erreur = false
    if @nb_ponts > 0
      nb_ponts = @nb_ponts
      @nb_ponts -= 1
    end
    return nb_ponts
  end

  # Méthode qui permet de dire que le pont est horizontale en modifiant le boolean
  def estHorizontal
    @sensHorizontal = true
  end

  # Méthode qui permet de dire que le pont est horizontale en modifiant le boolean
  def estVertical
    @sensHorizontal = false
  end

  # Méthode qui vérifie si le sens est horizontal
  #
  # ==== Retourne
  #
  # true si le sens est horizontal, false sinon
  def estHorizontal?
    @sensHorizontal
  end

  # Méthode qui vérifie si le sens est vertical
  #
  # ==== Retourne
  #
  # true si le sens est vertical, false sinon
  def estVertical?
    @sensHorizontal == false
  end

  # Méthode qui vérifie si l'element est un élément
  #
  # ==== Retourne
  #
  # false
  def estElement?
    false
  end

  # Méthode qui permet de d'incrémenter le nombre de sens d'un pont
  def deuxSens
    @deuxSens += 1
  end

  # Méthode qui vérifie si le pont a deux sens possible
  #
  # ==== Retourne
  #
  # true si le pont a deux sens, false sinon
  def aDeuxSens
    @deuxSens > 0
  end

  # Affiche le sens du pont (true si horizontal, false sinon) et le nombre de pont
  def to_s
    "sens = #{@sensHorizontal} || nombre de ponts : #{@nb_ponts}"
  end

end



