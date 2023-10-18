load 'SelectionDifficulte.rb'

##
# La Classe SelectionMode permet d'afficher la fenêtre de séléction de modes de jeu.
#
# Le menu est composé de 5 choix :
#
# - Normal
# - Contre la montre
# - Génie
# - Tutoriel
# - Retour
#
# On peut cliquer sur un des choix
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @ratio => la taille de la fenêtre
# * @selection_mode_box => la box qui contient les boutons et permet l'affichage de la fenêtre
# * @retour_button => bouton retour permettant de retourner sur le menu principal
#
class SelectionMode < Gtk::Builder

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +ratio+ - la taille de la fenêtre
  #
  def initialize(fenetre, ratio)
    super()
    add_from_file('../data/glade/SelectionMode.glade')
    @ratio = ratio
    @fenetre = fenetre

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    @fenetre.set_title('Hashi - Selection du mode')
    @retour_button.set_size_request(-1, 50 * @ratio)

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    @fenetre.add(@selection_mode_box)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton retour,
  # ferme la box de séléction de mode et affiche la box du menu principal
  def on_retour_button_clicked
    @fenetre.remove(@selection_mode_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    MenuPrincipal.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton normal,
  # ferme la box de séléction de mode et affiche la box de séléction de difficulté en mode normal
  def on_normal_clicked
    @fenetre.remove(@selection_mode_box)
    SelectionDifficulte.new(@fenetre, @ratio, 'normal')
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton contre la montre,
  # ferme la box de séléction de mode et affiche la box de séléction de difficulté en mode contre la montre
  def on_contre_la_montre_clicked
    @fenetre.remove(@selection_mode_box)
    SelectionDifficulte.new(@fenetre, @ratio, 'contre la montre')
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton génie,
  # ferme la box de séléction de mode et affiche la box de séléction de difficulté en mode génie
  def on_génie_clicked
    @fenetre.remove(@selection_mode_box)
    SelectionDifficulte.new(@fenetre, @ratio, 'genie')
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton tutoriel,
  # ferme la box de séléction de mode et affiche la box de séléction de map en mode tutoriel
  def on_tutoriel_clicked
    @fenetre.remove(@selection_mode_box)
    SelectionMap.new(@fenetre, @ratio, 'tutoriel', 'tutoriel')
  end

end
