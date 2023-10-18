load 'SelectionMap.rb'

##
# La Classe SelectionDifficulte permet d'afficher la fenêtre de séléction de difficulté.
#
# Le menu est composé de 4 choix :
#
# - Facile
# - Moyen
# - Difficile
# - Retour
#
# On peut cliquer sur un des choix
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @ratio => la taille de la fenêtre
# * @mode => le mode choisis par l'utilisateur
# * @selection_difficulte_box => la box qui contient les boutons et permet l'affichage de la fenêtre
# * @retour_button => bouton retour permettant de retourner sur la séléction de modes
#
class SelectionDifficulte < Gtk::Builder

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +ratio+ - la taille de la fenêtre
  # * +mode+ - le mode de jeu
  #
  def initialize(fenetre, ratio, mode)
    super()
    add_from_file('../data/glade/SelectionDifficulte.glade')
    @ratio = ratio
    @mode = mode
    @fenetre = fenetre

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    @retour_button.set_size_request(-1, 50 * @ratio)

    @fenetre.set_title('Hashi - Selection de la difficulté')

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    @fenetre.add(@selection_difficulte_box)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton retour,
  # ferme la box de séléction de mode et affiche la box de séléction de mode
  def on_retour_button_clicked
    @fenetre.remove(@selection_difficulte_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    SelectionMode.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton facile,
  # ferme la box de séléction de difficulté et affiche la box de séléction de map en facile
  def on_facile_clicked
    @fenetre.remove(@selection_difficulte_box)
    SelectionMap.new(@fenetre, @ratio, @mode, 'facile')
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton moyen,
  # ferme la box de séléction de difficulté et affiche la box de séléction de map en moyen
  def on_moyen_clicked
    @fenetre.remove(@selection_difficulte_box)
    SelectionMap.new(@fenetre, @ratio, @mode, 'moyen')
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton difficile,
  # ferme la box de séléction de difficulté et affiche la box de séléction de map en difficile
  def on_difficile_clicked
    @fenetre.remove(@selection_difficulte_box)
    SelectionMap.new(@fenetre, @ratio, @mode, 'difficile')
  end

end
