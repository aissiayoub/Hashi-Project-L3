load 'PlateauInterface.rb'

##
# La classe JeuTutoriel permet d'afficher la fenêtre du jeu quand le joueur à lancer le tutoriel
#
# Le jeu en tutoriel est composé de :
#
# - Le plateau
# - Le bouton "Retour"
# - Lorsque le joueur a fini le plateau il peut : revenir en arrière ou passer au tutoriel suivant
#
# ==== Variables d'instance
# * @ratio => la taille de la fenêtre
# * @fenetre => la fenêtre du jeu
# * @mode => le mode du jeu
# * @difficulte => la difficulté du plateau
# * @map => la map
# * @niveau => le niveau du plateau
#
class JeuTutoriel < Gtk::Builder

  # Methode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +ratio+ - la taille de la fenêtre
  # * +mode+ - le mode du jeu
  # * +difficulte+ - la difficulté du plateau
  # * +map+ - la map
  # * +niveau+ - le niveau du plateau
  #
  def initialize(fenetre, ratio, mode, difficulte, map, niveau)
    super()
    add_from_file('../data/glade/JeuTutoriel.glade')
    @ratio = ratio
    @fenetre = fenetre
    @mode = mode
    @difficulte = difficulte
    @map = map
    @niveau = niveau

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    nb_niv = Dir[File.join("../data/map/#{@difficulte}/demarrage", '**', '*')].count { |file| File.file?(file) }

    if nb_niv == @niveau.to_i
      @suivant_button.set_sensitive(false)
    end

    @grille = PlateauInterface.new(@fenetre, @map, @sens_popover, @fini_dialog, @fini_label, @mode, @difficulte, @niveau)

    @plateau_box.add(@grille)

    @retour_button.set_size_request(-1, 50 * @ratio)
    @fini_label.set_text("Vous avez fini le tutoriel n°#{niveau}.")
    @fini_dialog.set_title('Bravo !')

    @fenetre.set_title("Hashi - Tutoriel n°#{niveau}")

    @tutoriel_label.set_text((File.read(File.expand_path("../data/catalogue/#{niveau}.txt"))))

    @map.afficherPlateau

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    @fenetre.add(@jeu_box)
    @fenetre.show_all
  end

  # Méthode activée lorque le bouton "Retour" est cliquée
  # Sauvegarde la partie et retourne à la page de sélection de map
  def on_retour_button_clicked
    @fenetre.remove(@jeu_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    SelectionMap.new(@fenetre, @ratio, 'tutoriel', 'tutoriel')
  end

  # Méthode activée lorque le bouton "Menu principal" est cliquée
  # Retourne à la fenêtre du menu principal
  def on_menu_principal_button_clicked
    @fini_dialog.response(1)

    @fenetre.remove(@jeu_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    MenuPrincipal.new(@fenetre, @ratio)
  end

  # Méthode activée lorque le bouton "Selection map" est cliquée
  # Retourne à la fenêtre de la sélection des maps
  def on_selection_button_clicked
    @fini_dialog.response(2)

    @fenetre.remove(@jeu_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    SelectionMap.new(@fenetre, @ratio, @mode, @difficulte)
  end

  # Méthode activée lorque le bouton "Suivant" est cliquée
  # Lance la map suivante
  def on_suivant_button_clicked
    @fini_dialog.response(3)
    @fenetre.remove(@jeu_box)

    @niveau = @niveau.to_i
    @niveau += 1

    map = Genie.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)

    map.initialiserJeu

    JeuTutoriel.new(@fenetre, @ratio, @mode, @difficulte, map, @niveau.to_s)
  end

  # Méthode activée lorque le bouton pour fermer le popup "Fini" est cliquée
  # Ferme le popup
  def on_fini_dialog_response(widget, response)
    widget.close
  end

end
