load 'Chrono.rb'
load 'Plateau.rb'
load 'PlateauCorrection.rb'
load 'Coup.rb'

##
# La classe Genie représente le mode génie, c'est le mode le plus "simple" dans le sens où aucune aide ne sera disponible.
# Elle est donc la classe mère des autres mode de jeu.
#
# Elle peut :
#
# - sauvegarder la partie
# - charger une partie
# - calculer le score du joueur
# - lancer le chronometre
# - Supprimer/remettre un coup
# - jouer un coup
# - récupérer le coup jouer
#
# ==== Variables d'instance
# * @score         => le score du joueur
# * @chrono        => le chrono qui se lance en début de partie
# * @anciensCoups  => la file des anciens coups
# * @coups         => la pile de coups
# * @pileHypothese => la pile de coups du mode hypothèse
# * @fichierJeu    => le chemin vers le fichier qui contient la grille basique
# * @fichierCorrection => le chemin vers le fichier qui contient la correction
# * @plateau       => le plateau de jeu courant
# * @save          => la sauvegarde de la partie
# * @dir           => le chemin vers le dossier qui contient les fichiers
# * @pseudo        => le pseudo du joueur
# * @correction    => le plateau de jeu avec la correction
# * @chronoFirst   => temps au début du tour de jeu
# * @hypothese     => état du mode hypothèse
# * @autoCorrecteur : boolean qui indique si le mode auto-correcteur est activé
#
class Genie

  # La méthode new est en privé
  private_class_method :new

  attr_accessor :fichierJeu, :plateau, :coups, :label
  attr_reader :autoCorrecteur, :hypothese, :chrono, :score

  ##############################################################################################
  #                               Methode de classe
  ##############################################################################################

  # Méthode qui permet de créer un mode génie
  #
  # ==== Attributs
  #
  # * +unPlateau+ : une référence vers le plateau de jeu de la partie courante
  # * +unNiveau+ : le numéro du niveau choisis
  # * +unPseudo+ : le nom du joueur qui va jouer
  # * +uneDifficulte+ : la difficulté choisis
  #
  def Genie.creer(unPlateau, unNiveau, unPseudo, uneDifficulte)
    new(unPlateau, unNiveau, unPseudo, uneDifficulte)
  end

  # Méthode qui permet d'initialiser un mode génie
  #
  # ==== Attributs
  #
  # * +unPlateau+ : une référence vers le plateau de jeu de la partie courante
  # * +unNiveau+ : le numéro du niveau choisis
  # * +unPseudo+ : le nom du joueur qui va jouer
  # * +uneDifficulte+ : la difficulté choisis
  #
  def initialize(unPlateau, unNiveau, unPseudo, uneDifficulte)
    @score = 0
    @anciensCoups = []
    @coups = []
    @pileHypothese = []
    @fichierJeu = "../data/map/#{uneDifficulte}/demarrage/#{unNiveau}.txt"
    @fichierCorrection = "../data/map/#{uneDifficulte}/correction/#{unNiveau}.txt"
    @plateau = unPlateau
    @save = nil
    @dir = '../data/sauvegarde/'
    @pseudo = unPseudo
    @correction = PlateauCorrection.creer
    @chronoFirst = 0
    @hypothese = false
    @autoCorrecteur = false
    @difficulte = uneDifficulte
    @niveau = unNiveau
    @chrono = 0
  end

  #############################################################################################
  #                               Methodes
  #############################################################################################

  # Méthode qui permet d'initialiser le jeu (le plateau de jeu et sa correction)
  def initialiserJeu
    @plateau.generateMatrice(@fichierJeu)
    @plateau.generatePlateau
    @plateau.ajouterPont

    @correction.generateMatrice(@fichierCorrection)
    @correction.generatePlateau
  end

  # Méthode qui permet de sauvegarder une partie, elle sérialize l'objet courant
  def sauvegarder(mode)
    puts "Sauvegarde de #{@dir}#{@pseudo}_#{mode}_#{@difficulte}_#{@niveau}.bn ..."

    unLabel = @chrono.label

    chrono = @chrono
    @chrono = @chrono.chrono

    Dir.mkdir(@dir) unless File.exists?(@dir)
    f = File.open(File.expand_path("#{@dir}#{@pseudo}_#{mode}_#{@difficulte}_#{@niveau}.bn"), 'w')
    @save = Marshal::dump(self)
    f.write(@save)
    f.close

    valeur = @chrono
    @chrono = chrono
    #@chrono.lancerChronoValeur(valeur)

  end

  # Méthode qui permet de charger une partie, elle désérialize le fichier demandé
  def charger(mode)
    puts "Chargement de #{@dir}#{@pseudo}_#{mode}_#{@difficulte}_#{@niveau}.bn ..."

    f = File.open(File.expand_path("#{@dir}#{@pseudo}_#{mode}_#{@difficulte}_#{@niveau}.bn"), 'r')
    @save = f.read
    f.close

    return Marshal::load(@save)
  end

  # Méthode qui permet de calculer le score du joueur
  def calculScore
    val = 100
    chronoNow = @chrono.chrono
    div = @chronoFirst - chronoNow
    div = div.to_i
    if div != 0
      @score += (100 / div).to_i
    else
      @score += 100
    end
    @chronoFirst = chronoNow
  end

  # Méthode qui permet de lancer le chronometre dans le sens normal (part de 0 et s'incrémente jusqu'à ce que la partie soit terminé)
  def lancerChrono(unLabel)
    if (@chrono == 0) then
      @chrono = Chrono.new(unLabel)
      @chrono.lancerChrono
    else
      valeur = @chrono
      @chrono = Chrono.new(unLabel)
      @chrono.lancerChronoValeur(valeur)
    end
  end

  # Méthode qui permet de supprimer le dernier coup dans la liste des coups, le met dans à liste des anciens coups
  def deleteCoup
    @anciensCoups.push(@coup.pop)
  end

  # Méthode qui permet de récupérer l'ancien coup supprimer dans la liste des anciens coups
  def getCoup
    @coups.push(@anciensCoups.pop)
  end

  # Méthode qui permet d'enlever le dernier coup
  def annuler
    if !@coups.empty?
      coup = @coups.pop
      pontCourant = coup.pont
      sens = coup.sens
      if coup.estAjout?
        pontCourant.enleverPont
        @anciensCoups.push(Coup.creer('ajouter', coup.pont, sens))
      else
        if coup.estVertical?
          pontCourant.creerPont('haut', true)
          pontCourant.creerPont('bas', false)
        elsif coup.estHorizontal?
          pontCourant.creerPont('gauche', true)
          pontCourant.creerPont('droite', false)
        else
          puts 'erreur de undo'
        end
        if (@score >= 110) then
          @score -= 110
        end
        @anciensCoups.push(Coup.creer('enlever', coup.pont, sens))
      end
    end
    return pontCourant
  end

  # Méthode qui permet de remettre le dernier coup supprimer
  def refaire
    if !@anciensCoups.empty?
      coup = @anciensCoups.pop
      pontCourant = coup.pont
      puts pontCourant
      if !coup.estAjout?
        pontCourant.enleverPont
      else
        if coup.estVertical?
          pontCourant.creerPont('haut', true)
          pontCourant.creerPont('bas', false)
        elsif coup.estHorizontal?
          pontCourant.creerPont('gauche', true)
          pontCourant.creerPont('droite', false)
        else
          puts 'erreur de redo'
        end
      end
      if (@score >= 110) then
        @score -= 110
      end
      @coups.push(coup)
    end
    return pontCourant
  end

  # Méthode qui permet de jouer un coup
  #
  # ==== Attributs
  #
  # * +unX+ - coordonnée X de la case
  # * +unY+ - Coordonnée Y de la case
  # * +unClic+ - type de clic fait par le joueur
  #
  # ==== Retourne
  #
  # - true si la partie est finie,
  # - false si la case jouée n'est pas un pont ou si la partie n'est pas finie
  def jouerCoup(unX, unY, unClic)

    caseCourante = @plateau.getCase(unX, unY)

    joue = -1
    if caseCourante.element.estPont?
      if caseCourante.element.nb_ponts > 0
        puts 'Vous voulez enlever(1) un pont ou en ajouter(2) un ?'
        joue = gets
        joue = joue.to_i
      end

      if joue == 2 || joue == -1
        if caseCourante.element.nb_ponts > 0
          sens = caseCourante.creerPontDefaut
        elsif caseCourante.element.aDeuxSens
          #caseCourante.estEntoure() ne sert probablement à rien
          puts 'vous voulez faire un coup horizontal(1) ou vertical(2) ?'
          sens = gets
          if sens.to_i == 1
            if caseCourante.pontAjoutable('droite', true) && caseCourante.pontAjoutable('gauche', true)
              caseCourante.creerPont('droite', true)
              caseCourante.creerPont('gauche', false)
              sens = 'horizontal'
            end
          else
            if caseCourante.pontAjoutable('haut', true) && caseCourante.pontAjoutable('bas', true)
              caseCourante.creerPont('haut', true)
              caseCourante.creerPont('bas', false)
              sens = 'vertical'
            end
          end
          print "case courante : #{caseCourante.element}\n"
        else
          sens = caseCourante.creerPontDefaut
        end
        unClic = 'ajouter'
      else
        sens = caseCourante.enleverPont
        unClic = 'enlever'
      end
      puts "sens : #{sens}"
      if @hypothese
        @pileHypothese.push(Coup.creer(unClic, caseCourante, sens))
      else
        @coups.push(Coup.creer(unClic, caseCourante, sens))
      end
      if @difficulte != 'tutoriel'
        calculScore
        @chronoFirst = @chrono.chrono
      end

    else
      puts 'case pas un pont'
      return false
    end

    if @autoCorrecteur
      corrigerErreur
    end

    return @plateau.partieFini?

  end

  # Méthode qui permet de jouer un coup sur une interface
  #
  # ==== Attributs
  #
  # * +unX+ - la coordonnée x de la case
  # * +unY+ - La coordonnée y de la case
  # * +unClic+ - l'action effectué par l'utilisateur
  def jouerCoupInterface(unX, unY, unClic)
    caseCourante = @plateau.getCase(unX, unY)

    if caseCourante.element.estPont?
      if caseCourante.element.nb_ponts == 1 || caseCourante.element.nb_ponts == 2
        sens = caseCourante.element.estVertical?
        if sens
          sens = 'vertical'
        else
          sens = 'horizontal'
        end
      elsif caseCourante.element.aDeuxSens
        puts 'a deux sens'
        @anciensCoups.clear
        return false
      elsif caseCourante.element.nb_ponts == 0
        sens = caseCourante.element.estVertical?
        if sens
          sens = 'vertical'
        else
          sens = 'horizontal'
        end
      else
        return 'erreur'
      end

    end

    return sens
  end

  # Méthode qui permet de jouer un coup horizontale sur une interface
  #
  # ==== Attributs
  #
  # * +unX+ - la coordonnée x de la case
  # * +unY+ - La coordonnée y de la case
  # * +unClic+ - l'action effectué par l'utilisateur
  def jouerCoupHorizontaleInterface(unX, unY, unClic)
    caseCourante = @plateau.getCase(unX, unY)
    res = false
    sens = 'horizontal'

    if unClic
      if caseCourante.pontAjoutable('droite', true) && caseCourante.pontAjoutable('gauche', true)
        caseCourante.creerPont('droite', true)
        caseCourante.creerPont('gauche', false)

        unClic = 'ajouter'

        res = true

        if @difficulte != 'tutoriel'
          calculScore
          @chronoFirst = @chrono.chrono
          @anciensCoups.clear
          sauvegarder(self.class.name.downcase)
        end
      end
    else
      if caseCourante.element.nb_ponts > 0
        caseCourante.enleverPont
        unClic = 'enlever'
        res = true

        if @difficulte != 'tutoriel'
          if(@score <= 110)then
            @score -= 110
          end
          @anciensCoups.clear
          sauvegarder(self.class.name.downcase)
        end
      end
    end

    if res
      if @hypothese
        @pileHypothese.push(Coup.creer(unClic, caseCourante, sens))
      else
        if @autoCorrecteur
          erreur = corrigerErreur
          if erreur
            return 'mort'
          else
            @coups.push(Coup.creer(unClic, caseCourante, sens))
          end
        else
          @coups.push(Coup.creer(unClic, caseCourante, sens))
        end
      end
    end

    return res
  end

  # Méthode qui permet de jouer un coup verticale sur une interface
  #
  # ==== Attributs
  #
  # * +unX+ - la coordonnée x de la case
  # * +unY+ - La coordonnée y de la case
  # * +unClic+ - l'action effectué par l'utilisateur
  def jouerCoupVerticaleInterface(unX, unY, unClic)
    caseCourante = @plateau.getCase(unX, unY)
    res = false
    sens = 'vertical'
    if unClic
      if caseCourante.pontAjoutable('haut', true) && caseCourante.pontAjoutable('bas', true)
        caseCourante.creerPont('haut', true)
        caseCourante.creerPont('bas', false)

        unClic = 'ajouter'
        res = true

        if @difficulte != 'tutoriel'
          calculScore
          @chronoFirst = @chrono.chrono
          @anciensCoups.clear
          sauvegarder(self.class.name.downcase)
        end
      end
    else
      if caseCourante.element.nb_ponts > 0
        caseCourante.enleverPont
        unClic = 'enlever'
        res = true
        if(@score <= 110)then
          @score -= 110
        end
      end
    end

    if res
      if @hypothese
        @pileHypothese.push(Coup.creer(unClic, caseCourante, sens))
      else
        if @autoCorrecteur
          erreur = corrigerErreur
          if erreur
            return 'mort'
          else
            @coups.push(Coup.creer(unClic, caseCourante, sens))
          end
        else
          @coups.push(Coup.creer(unClic, caseCourante, sens))
        end
      end
    end

    return res
  end

  # Méthode qui permet d'afficher le mode génie
  #
  # ==== Retourne
  #
  # L'état de la partie en cours
  #
  def to_s
    "genie"
  end

  # Méthode qui affiche le plateau sur le terminal
  def afficherPlateau
    @plateau.afficherJeu
  end

  # Méthode qui affiche le plateau de correction sur le terminal
  def afficherCorrection
    @correction.afficherJeu
  end

  # Méthode qui permet de verifier les coordonnées d'une case
  #
  # ==== ATTRIBUTS
  #
  # * +unX+ - coordonnée X de la case
  # * +unY+ - Coordonnée Y de la case
  #
  def verifCoord(unX, unY)
    @plateau.verifCoord(unX, unY)
  end

  # Permet de sauvegarder le score du joueur dans un fichier pour faire le classement
  def sauvegarder_score

    Dir.mkdir("../data/map/#{@difficulte.to_s}/score") unless File.exists?("../data/map/#{@difficulte.to_s}/score")
    fichierScore = "../data/map/#{@difficulte.to_s}/score/#{@niveau.to_s}#{self.to_s}.txt"

    open(fichierScore, 'a+') do |f|
      f.puts "#{@pseudo}_#{@score.to_i.to_s}_#{@chrono.chrono.to_i.to_s}"
    end
  end

  # Ne fait rien en mode Genie
  def activerHypothese; end

  # Ne fait rien en mode Genie
  def desactiverHypothese; end

end
