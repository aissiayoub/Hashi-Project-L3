load 'Catalogue.rb'
load 'SelectionMode.rb'
load 'Options.rb'
load 'Classement.rb'

##
# La Classe MenuPrincipal permet d'afficher la fenêtre du menu principal.
#
# Le menu est composé de 5 choix :
#
# - Jouer
# - Catalogue
# - Classement
# - Options
# - Quitter
#
# On peut cliquer sur un des choix
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @ratio => la taille de la fenêtre
# * @menu_principale_box => la box qui contient les boutons et permet l'affichage du menu
#
class MenuPrincipal < Gtk::Builder

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +ratio+ - la taille de la fenêtre
  #
  def initialize(fenetre, ratio)
    super()
    add_from_file('../data/glade/MenuPrincipal.glade')
    @ratio = ratio
    @fenetre = fenetre

    @provider = Gtk::CssProvider.new
    @provider.load(:path => "assets/style.css")
    Gdk::Screen.default.add_style_provider(@provider, 1000000000)

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
        p.style_context().add_provider(@provider, 1000000000)
      end
    end

    @fenetre.set_title('Hashi - Menu Principal')

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    #@jouer.add_style_provider(@provider, 1000000000)

    @fenetre.add(@menu_principale_box)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton jouer,
  # ferme la box des menus et affiche une nouvelle box
  def on_jouer_clicked
    @fenetre.remove(@menu_principale_box)
    SelectionMode.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton catalogue,
  # ferme la box des menus et affiche une nouvelle box
  def on_catalogue_clicked
    @fenetre.remove(@menu_principale_box)
    Catalogue.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton classement,
  # ferme la box des menus et affiche une nouvelle box
  def on_classement_clicked
    @fenetre.remove(@menu_principale_box)
    Classement.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton option,
  # ferme la box des menus et affiche une nouvelle box
  def on_options_clicked
    @fenetre.remove(@menu_principale_box)
    Options.new(@fenetre)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton quitter,
  # ferme l'application
  def on_quitter_clicked
    puts 'Gtk.main_quit'
    Gtk.main_quit
  end

end
