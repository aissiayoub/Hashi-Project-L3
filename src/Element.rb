##
# La classe Element représente un élément du plateau.
# Elle est la classe mère de Pont et Ile.
# Une case peut donc être un Pont, une Ile ou un Element.
#
# Elle peut :
# - S'afficher
# - dire si elle est un pont ou une île
#
class Element

  ####################################################################################################
  #                               Methodes de classe
  ####################################################################################################

  # La méthode new est en privé
  private_class_method :new

  # Méthode qui créer un nouvel élément
  def Element.creer
    new
  end

  ####################################################################################################
  #                                   Methodes
  ####################################################################################################

  # Méthode qui vérifie si l'element est un pont
  #
  # ==== Retourne
  #
  # false par défaut
  def estPont?
    return false
  end

  # Méthode qui vérifie si l'element est une île
  #
  # ==== Retourne
  #
  # false par défaut
  def estIle?
    return false
  end

  # Méthode qui vérifie si l'element est un élément
  #
  # ==== Retourne
  #
  # true par défaut
  def estElement?
    return true
  end

  # Méthode qui affiche un élément
  def to_s
    ' element du tableau'
  end

end
