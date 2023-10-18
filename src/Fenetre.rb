require 'gtk3'
require 'json'

load 'MenuPrincipal.rb'

##
# La classe Fenetre met en place la fenêtre principale
#
class Fenetre < Gtk::Builder

  attr_reader :ratio

  # Methode d'initialisation de la classe
  def initialize
    super()
    add_from_file('../data/glade/Fenetre.glade')

    objects.each { |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    }

    begin
      @fichier_options = File.read('../data/options.json')
    rescue
      @fichier_options = File.open('../data/options.json', 'w')
      @fichier_options.write('{"username": "Invité","resolution_ratio": 1,"langue": "Francais"}')
      @fichier_options.close
      @fichier_options = File.read('../data/options.json')
    end

    @hashOptions = JSON.parse(@fichier_options)
    @ratio = @hashOptions['resolution_ratio']

    @fenetre.set_resizable(false)
    @fenetre.set_default_size(1280 * @ratio, 720 * @ratio)
    @fenetre.show_all
    @fenetre.set_window_position Gtk::WindowPosition::CENTER

    @fenetre.set_name(@ratio.to_s)

    @fenetre.signal_connect('destroy') do
      puts 'Gtk.main_quit'
      Gtk.main_quit
    end

    MenuPrincipal.new(@fenetre, @ratio)

  end

end
