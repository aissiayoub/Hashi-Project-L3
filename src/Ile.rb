load 'Element.rb'

##
# La classe Ile représente une île sur le plateau, elle hérite de Element
#
# Elle peut :
# - Dire qu'elle est une île
# - Dire si elle est terminée (si le nombre de pont qui la relie est équivalent à sa valeur)
#
# ==== Variables d'instance
# * @valeur => un int, représentant le nombre de pont devant être connecté à l'île
# * @nbLiens => un int, représentant le nombre de liens (ponts), connecté à l'île
# * @estFini => un bool, vrai si l'île à le bon nombre de liens, et faux dans le cas inverse
#
class Ile < Element

  ########################################################################################################
  #								Methode de classe
  ########################################################################################################

  # Méthode qui permet de créer une ile
  #
  # ==== Attributs
  #
  # * +uneValeur+ - la valeur de l'île (un entier)
  #
  def Ile.creer(uneValeur)
    new(uneValeur)
  end

  # Méthode qui permet d'initialiser une ile
  #
  # Par defaut :
  # - nbLiens = 0
  # - estFini = false
  #
  # ==== Attributs
  #
  # * +uneValeur+ - la valeur de l'île (un entier)
  #
  def initialize(uneValeur)
    @valeur = uneValeur
    @nbLiens = 0
    @estFini = false
  end

  ########################################################################################################
  #									Methodes
  ########################################################################################################

  # Accès en lecture
  attr_reader :valeur

  # Accès en lecture et en écriture
  attr_accessor :nbLiens, :estFini

  # Méthode qui vérifie si c'est une île
  #
  # ==== Retourne
  #
  # true
  def estIle?
    return true
  end

  # Méthode qui vérifie si l'element est un élément
  #
  # ==== Retourne
  #
  # false
  def estElement?
    return false
  end

  # Méthode qui vérifie si l'île est finie
  #
  # ==== Retourne
  #
  # true si l'île est complétée, false sinon
  def estFini?
    return @estFini
  end

  # Méthode qui incrémente de 1 @nbLiens et vérifie si l'île est fini
  def ajouterPont
    if !estFini
      @nbLiens += 1
      if @nbLiens == @valeur
        @estFini = true
      else
        @estFini = false
      end
    end
  end

  # Méthode qui décrémente de 1 @nbLiens
  def enlevePont
    @nbLiens -= 1
    @estFini = false
  end

  # Méthode qui affiche une ile
  def to_s
    'Ile'
  end

end


