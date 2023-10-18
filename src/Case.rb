##
# La classe Case représente un élément du plateau, elle peut être soit une île, soit un pont, soit un élément.
#
# Elle peut :
#
# - Donner ses voisines (droite, gauche, haut, bas)
# - Donner son élément
#
# Elle connaît :
#
# - Ses coordonnnées sur le plateau
# - Le plateau
# - Son élément
#
# ==== Variables d'instance
# * @x => coordonées x de la case
# * @y => coordonées y de la case
# * @plateau => le plateau de jeux
# * @element => l'élément de la case
#
class Case

  # Methode qui permet de créer une case
  #
  # ==== Attributs
  #
  # * +unX+ - coordonées x de la case
  # * +unY+ - coordonées y de la case
  # * +unPlateau+ - le plateau de jeux
  # * +unElem+ - l'élément de la case
  #
  def Case.creer(unX, unY, unPlateau, unElem)
    new(unX, unY, unPlateau, unElem)
  end

  # new est en privée 
  private_class_method :new

  # Methode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +unX+ - coordonées x de la case
  # * +unY+ - coordonées y de la case
  # * +unPlateau+ - le plateau de jeux
  # * +unElem+ - l'élément de la case
  #
  def initialize(unX, unY, unPlateau, unElem)
    @x = unX
    @y = unY
    @plateau = unPlateau
    @element = unElem
  end

  # Accès en lecture aux coordonnées x, et y
  attr_reader :x, :y

  # Accès a l'élément de la case
  attr_accessor :element

  # Methode qui retourne la case de droite
  #
  # ==== Exemples
  #
  # Pour une case se trouvant à la ligne 2 et à la colonne 3 de la matrice
  # du plateau, cette méthode retournera la case se trouvant à la ligne 2 et
  # à la colonne 4.
  def voisineDroite
    if @y + 1 == @plateau.y
      return nil
    else
      return @plateau.matrice[@x][@y + 1]
    end
  end

  # Methode qui retourne la case de gauche
  #
  # ==== Exemples
  #
  # Pour une case se trouvant à la ligne 2 et à la colonne 3 de la matrice
  # du plateau, cette méthode retournera la case se trouvant à la ligne 2 et
  # à la colonne 2.
  def voisineGauche
    if @y == 0
      return nil
    else
      return @plateau.matrice[@x][@y - 1]
    end
  end

  # Methode qui retourne la case du bas
  #
  # ==== Exemples
  #
  # Pour une case se trouvant à la ligne 2 et à la colonne 3 de la matrice
  # du plateau, cette méthode retournera la case se trouvant à la ligne 3 et
  # à la colonne 3.
  def voisineBas
    if @x + 1 == @plateau.x
      return nil
    else
      return @plateau.matrice[@x + 1][@y]
    end
  end

  # Methode qui retourne la case du haut
  #
  # ==== Exemples
  #
  # Pour une case se trouvant à la ligne 2 et à la colonne 3 de la matrice
  # du plateau, cette méthode retournera la case se trouvant à la ligne 1 et
  # à la colonne 3.
  def voisineHaut
    if @x == 0
      return nil
    else
      return @plateau.matrice[@x - 1][@y]
    end
  end

  # Methode qui permet d'ajouter des ponts à droite de la case appelante
  #
  # La case vérifie :
  # - Si elle a une île à sa droite
  # - Si elle a du vide
  #
  # ==== Retourne
  #
  # True si le pont peut être créé, false sinon
  def ajouterPontDroite
    droite = voisineDroite
    if droite.nil?
      return false
    else
      if droite.element.estIle?
        if @element.instance_of?(Element)
          @element = Pont.creer(true)
        elsif @element.estPont? then
          @element.deuxSens
        end
        return true
      else
        bool = droite.ajouterPontDroite
        if bool == true
          if @element.instance_of?(Element)
            @element = Pont.creer(true)
          elsif @element.estPont?
            @element.deuxSens
          end
          return true
        else
          return false
        end
      end
    end
  end

  # Methode qui permet d'ajouter des pont en bas de la case appelante
  #
  # La case vérifie :
  # - Si elle a un île en dessous
  # - Si elle a du vide
  #
  # ==== Retourne
  # True si le pont peut être créé, false sinon
  def ajouterPontBas
    bas = voisineBas
    if bas.nil?
      return false
    else
      if bas.element.estIle?
        if @element.instance_of?(Element)
          @element = Pont.creer(false)
        elsif @element.estPont? then
          @element.deuxSens
        end
        return true
      else
        bool = bas.ajouterPontBas
        if bool == true
          if !@element.estIle? && !@element.estPont?
            @element = Pont.creer(false)
          elsif @element.estPont?
            @element.deuxSens
          end
          return true
        else
          return false
        end
      end
    end
  end

  # Methode qui permet de vérifier si la case peut être un pont horizontal et/ou vertical
  #
  # ==== Retourne
  # true si le pont sélectionner peut être soit horizontale, soit vertical, false sinon
  def estEntoure
    print "courante : #{to_s}\n"
    print "haut : #{voisineHaut.to_s}\nbas : #{voisineBas.to_s}\ndroite : #{voisineDroite.to_s}\nGauche : #{voisineGauche.to_s}\n"
    if voisineBas.nil? || voisineDroite.nil? || voisineGauche.nil? || voisineHaut.nil?
      return false
    else
      return (voisineBas.element.estIle? && voisineDroite.element.estIle?) || (voisineBas.element.estIle? && voisineGauche.element.estIle?) || (voisineHaut.element.estIle? && voisineDroite.element.estIle?) || (voisineHaut.element.estIle? && voisineGauche.element.estIle?)
    end
  end

  # Methode qui permet de créer tous les ponts entre 2 îles, ces ponts ne peuvent que être vertical ou horizontal.
  #
  # ==== Retourne
  # Le sens du pont créé (Horizontal ou vertical)
  def creerPontDefaut
    sens = ''
    if @element.estPont?
      if @element.estVertical?
        if pontAjoutable('haut', true) && pontAjoutable('bas', true)
          creerPont('haut', true)
          creerPont('bas', false)
          sens = 'vertical'
        end
      else
        if pontAjoutable('gauche', true) && pontAjoutable('droite', true)
          creerPont('gauche', true)
          creerPont('droite', false)
          sens = 'horizontal'
        end
      end
    end
    
    return sens
  end

  # Methode qui permet de créer tous les ponts entre 2 îles.
  #
  # ==== Attributs
  #
  # * +unSens+ - le sens dans lequel on veut vérifier si on peut placer le pont
  # * +unBool+ - vrai si c'est la case courante qui appelle la fonction, faux sinon
  #
  # ==== Retourne
  # Le sens du pont créé (Horizontal ou vertical)
  def creerPont(unSens, unBool)
    if @element.estPont? then
      if unBool
        @element.ajoutePont
      end
      case unSens
      when 'haut'
        voisineHaut.creerPont(unSens, true)
        element.estVertical
      when 'bas'
        voisineBas.creerPont(unSens, true)
        element.estVertical
      when 'gauche'
        voisineGauche.creerPont(unSens, true)
        element.estHorizontal
      when 'droite'
        voisineDroite.creerPont(unSens, true)
        element.estHorizontal
      else
        puts 'Pas compris le sens'
      end
    elsif @element.estIle?
      @element.ajouterPont
    end
  end

  # Methode qui permet de dire si oui ou non le pont peut être ajouté.
  #
  # ==== Attributs
  #
  # * +unSens+ - le sens dans lequel on veut vérifier si on peut placer le pont
  # * +unBool+ - vrai si c'est la case courante qui appelle la fonction, faux sinon
  #
  # ==== Retourne
  # true si on peut l'ajouter, false sinon
  def pontAjoutable(unSens, unBool)
    if @element.estPont?
      # si le nombre de ponts est supèrieur à 0, soit c'est le pont cliquer, donc on augmente de 1, soit c'est un pont sur la trajectoire et on ne peut donc pas placer le pont
      if @element.nb_ponts == 1
        if unBool
          return ileFini?(unSens)
        else
          return false
        end
      elsif @element.nb_ponts == 2
        return false
      elsif unSens == 'droite' && voisineDroite != nil
        return voisineDroite.pontAjoutable(unSens, false)
      elsif unSens == 'gauche' && voisineGauche != nil
        return voisineGauche.pontAjoutable(unSens, false)
      elsif unSens == 'haut' && voisineHaut != nil
        return voisineHaut.pontAjoutable(unSens, false)
      elsif unSens == 'bas' && voisineBas != nil
        return voisineBas.pontAjoutable(unSens, false)
      else
        return false
      end
    elsif @element.estIle?
      if @element.estFini
        return false
      else
        return true
      end
    else
      return false
    end
  end

  # Methode qui permet de connaître quels ponts sont ajoutables.
  #
  # ==== Retourne
  #
  # Un nombre binaire a 4 bits, si un bits vaut 1 la case posséde une île voisine dans un sens.
  # L'ordre est le suivant du bit droit au gauche : Droite, Gauche, Haut, Bas.
  def pontAjoutables
    n = 0
    if element.estIle?
      if @y < @plateau.y - 1 && voisineDroite.element.estPont? && voisineDroite.pontAjoutable('droite', false)
        n += 1
      end

      if @y > 0 && voisineGauche.element.estPont? && voisineGauche.pontAjoutable('gauche', false)
        n += 10
      end

      if @x > 0 && voisineHaut.element.estPont? && voisineHaut.pontAjoutable('haut', false)
        n += 100
      end

      if @x < @plateau.x - 1 && voisineBas.element.estPont? && voisineBas.pontAjoutable('bas', false)
        n += 1000
      end
    end

    return n
  end

  # Methode qui permet de savoir si une ile est terminé, c'est-à-dire si
  # l'île a atteint toutes ses liaisons possibles.
  #
  # ==== Attributs
  #
  # * +unSens+ - la direction à vérifier
  #
  def ileFini?(unSens)
    if @element.estIle?
      if @element.estFini
        return false
      else
        return true
      end
    else
      case unSens
      when 'haut'
        return voisineHaut.ileFini?(unSens)
      when 'gauche'
        return voisineGauche.ileFini?(unSens)
      when 'droite'
        return voisineDroite.ileFini?(unSens)
      when 'bas'
        return voisineBas.ileFini?(unSens)
      else
        puts 'pas compris'
      end
    end
  end

  # Methode qui permet d'enlever un pont
  def enleverPont
    if @element.estPont? && @element.nb_ponts > 0
      if @element.estVertical?
        enleverPontSens('haut', true)
        enleverPontSens('bas', false)
        return 'vertical'
      else
        enleverPontSens('droite', true)
        enleverPontSens('gauche', false)
        return 'horizontal'
      end
    end
  end

  #
  # Méthode qui permet d'enlever un pont voisin, dans un sens donné
  #
  # ===== ATTRIBUTS
  #
  # * +unSens+ - La direction à vérifier
  # * +unBool+ - Indique si le pont préssent sur la case doit être retiré ou pas
  #
  def enleverPontSens(unSens, unBool)
    if @element.estPont?
      if unBool
        @element.enlevePont
      end
      case unSens
      when 'haut'
        voisineHaut.enleverPontSens('haut', true)
      when 'bas'
        voisineBas.enleverPontSens('bas', true)
      when 'droite'
        voisineDroite.enleverPontSens('droite', true)
      when 'gauche'
        voisineGauche.enleverPontSens('gauche', true)
      else
        puts 'erreur de comprehension'
      end
    elsif @element.estIle?
      @element.enlevePont
    end
  end

  # Methode qui d'afficher une case (ses coordonnées) en retournant un string.
  #
  # ==== Retourne
  #
  # Les coordonnées de la case.
  def to_s
    "x:#{@x}, y:#{@y} type : " + @element.to_s
  end

end
