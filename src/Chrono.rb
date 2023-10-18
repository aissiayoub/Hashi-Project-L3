##
# La classe Chrono permet de lancer deux types de chronomètres :
# - Un premier chronomètre qui compte le nombre de seconde depuis son lancement.
# - Un deuxième qui cette fois-ci décompte et se stop une fois le temps écoulé.
#
# Cette classe possède 4 méthodes:
#
# - lancerChrono : qui lance le chronomètre basique
# - lancerChronoInverse(unTemps) : qui lance le chronomètre décompteur pour unTemps donné en paramètre.
# - stopperChrono : qui permet de stopper n'importe quel des deux chronomètre.
# - remiseAZero : qui réinitialise le chronomètre.
#
# ==== Variables d'instance
# * @thr => le thread qui contient le chrono
# * @tempsDebut => le temps de début du chrono
# * @chrono => le chrono
#
class Chrono

  ###############################################################################
  #                   Methode de classe
  ###############################################################################

  # Initialise le chronomètre à vide grâce à la méthode de remise à zéro.
  def initialize(unChrono)
    @label = unChrono
    remiseAZero
  end

  ###############################################################################
  #                       Methode
  ###############################################################################

  # Lance le chronomètre, et compte le nombre de secondes depuis ce lancement.
  def lancerChrono
    Thread.start do
      @estLancer = true
      @chrono = 0
      while @estLancer
        @chrono += 0.1
        sleep(0.1)
        @label.set_text("Timer : #{'%.1f' % @chrono} s")
      end
    end
  end

  # Lance le chronomètre, et compte le nombre de secondes depuis ce lancement.
  def lancerChronoValeur(uneValeur)
    Thread.start do
      @estLancer = true
      @chrono = uneValeur
      while @estLancer
        @chrono += 0.1
        sleep(0.1)
        @label.set_text("Timer : #{'%.1f' % @chrono} s")
      end
    end
  end

  # Décompte à partir d'un temps donné et s'arrete à 0
  #
  # ==== Attributs
  #
  # * +unTemps+ - temps à décompter
  #
  # ==== Exemples
  #
  # Avec un temps donné en paramètre de 25, la méthode
  # va stopper le chronomètre au bout de 25 secondes.
  def lancerChronoInverse(unTemps)
    Thread.new do
      @chrono = unTemps
      while @chrono > 0
        @chrono -= 0.1
        sleep(0.1)
        @label.set_text("Timer : #{'%.1f' % @chrono} s")
      end
    end
  end

  # Stoppe le chronomètre.
  def stopperChrono
    @estLancer = false
  end

  # Remet les variables tempsDebut et chrono à 0.
  def pauserChrono
    if @estLancer
      @estLancer = false
    else
      @estLancer = true
      lancerChronoValeur(@chrono)
    end

  end

  # remet le chrono à 0
  def remiseAZero
    @chrono = 0
  end

  # remise à zero est privée car appelé que en interne
  private :remiseAZero

  # permet de lire le chrono
  attr_accessor :chrono, :label

end

