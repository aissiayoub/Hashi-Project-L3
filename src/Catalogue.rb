##
# La Classe Catalogue permet d'afficher la fenêtre du catalogue.
#
# Il y a trois personnalisation d'options possible :
#
# - Le nom de l'utilisateur
# - La résolution du jeu
# - La langue
#
# On peut cliquer sur un des choix
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @ratio => la taille de la fenêtre
# * @catalogue => les techniques du jeu 
# * @regle => les règles du jeu
class Catalogue < Gtk::Builder

  # Methode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du catalogue
  # * +ratio+ - la taille de la fenêtre
  #
  def initialize(fenetre, ratio)
    super()
    add_from_file('../data/glade/Catalogue.glade')

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    @ratio = ratio
    @fenetre = fenetre
    @fenetre.add(@catalogue_box)

    @catalogue = File.open('../data/catalogue/catalogue.txt').read
    @regle = File.open('../data/catalogue/regles_du_jeu.txt').read

    comment_jouer_scrolled = get_object('comment_jouer_scrolled')
    comment_jouer_scrolled.set_min_content_width(1280)
    comment_jouer_scrolled.set_min_content_height(600)

    techniques_scrolled = get_object('techniques_scrolled')
    techniques_scrolled.set_min_content_width(1280)
    techniques_scrolled.set_min_content_height(600)

    comment_jouer_buffer = Gtk::TextBuffer.new
    comment_jouer_buffer.set_text(@regle)

    comment_jouer_text_view = get_object('comment_jouer_text_view')
    comment_jouer_text_view.set_buffer(comment_jouer_buffer)

    techniques_jouer_buffer = Gtk::TextBuffer.new
    techniques_jouer_buffer.set_text(@catalogue)

    techniques_text_view = get_object('techniques_text_view')
    techniques_text_view.set_buffer(techniques_jouer_buffer)

    @fenetre.set_title('Hashi - Catalogue')

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton retour,
  # ferme la box des options et affiche la box du menu principal
  def on_retour_button_clicked
    @fenetre.remove(@catalogue_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)
    MenuPrincipal.new(@fenetre, @ratio)
  end

end
