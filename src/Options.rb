##
# La Classe Options permet d'afficher la fenêtre d'option.
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
# * @options_box => la box qui contient les boutons et permet l'affichage des options
# * @fichier_options => fichier contenant les dernières options enregistrer
# * @hashOptions => objet qui récupère les données du fichier_options
# * @user => nom d'utilisateur extrait du hashOptions
# * @ratio => résolution extraite du hashOptions
# * @langue => langue extraite du hashOptions
# * @retour_bouton => bouton retour permettant de retourner sur le menu principal
# * @nom_utilisateur_entry => nom d'utilisateur actuel du jeu
# * @resolution_combotext => résolution actuelle du jeu
# * @langue_combotext => langue actuelle du jeu
#
class Options < Gtk::Builder

  # Accès en lecture
  attr_reader :user, :ratio, :langue

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  #
  def initialize(fenetre)
    super()
    add_from_file('../data/glade/Options.glade')
    @fenetre = fenetre

    @fichier_options = File.read('../data/options.json')

    @hashOptions = JSON.parse(@fichier_options)
    @user = @hashOptions['username']
    @ratio = @hashOptions['resolution_ratio']
    @langue = @hashOptions['langue']

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    @langue_comboboxtext.set_sensitive(false)
    @retour_button.set_size_request(-1, 50 * @ratio)

    @nom_utilisateur_entry.set_text(@user)

    case @ratio
    when 1
      @resolution_comboboxtext.set_active(0)
    when 1.25
      @resolution_comboboxtext.set_active(1)
    when 1.5
      @resolution_comboboxtext.set_active(2)
    end

    case @langue
    when 'Francais'
      @langue_comboboxtext.set_active(0)
    when 'Anglais'
      @langue_comboboxtext.set_active(1)
    when 'Espagnol'
      @langue_comboboxtext.set_active(2)
    end

    @fenetre.set_title('Hashi - Options')

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    @fenetre.add(@options_box)
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton retour,
  # ferme la box des options et affiche la box du menu principal
  def on_retour_button_clicked
    @fenetre.remove(@options_box)
    MenuPrincipal.new(@fenetre, @ratio)
  end

  # Action qui s'exécute lorsque l'on change la résolution,
  # change la résolution dans les options en fonction du paramètre donné
  #
  # ==== Attributs
  #
  # * +resolution+ - la résolution choisis par l'utilisateur
  #
  def on_resolution_comboboxtext_changed(resolution)
    puts "Resolution mis a jour #{resolution.active_text}"
    case resolution.active_text
    when '720p'
      @hashOptions['resolution_ratio'] = 1
      @ratio = 1
      @fenetre.set_size_request(1280 * @ratio, 720 * @ratio)
    when '900p'
      @hashOptions['resolution_ratio'] = 1.25
      @ratio = 1.25
      @fenetre.set_size_request(1280 * @ratio, 720 * @ratio)
    when '1080p'
      @hashOptions['resolution_ratio'] = 1.5
      @ratio = 1.5
      @fenetre.set_size_request(1280 * @ratio, 720 * @ratio)
    end
  end

  # Action qui s'exécute lorsque l'on change la langue,
  # change la langue dans les options en fonction du paramètre donné
  #
  # ==== Attributs
  #
  # * +langue+ - la langue choisis par l'utilisateur
  #
  def on_langue_comboboxtext_changed(langue)
    puts "Langue mis a jour #{langue.active_text}"
    @hashOptions['langue'] = langue.active_text
    @langue = langue.active_text
  end

  # Action qui s'exécute lorsque l'on change le nom d'utilisateur,
  # change le nom d'utilisateur dans les options en fonction du paramètre donné
  #
  # ==== Attributs
  #
  # * +username+ - nom d'utilisateur choisis par l'utilisateur
  #
  def on_nom_utilisateur_entry_changed(username)
    puts "Nom d'utilisateur mis a jour to \"#{username.text}\""
    @hashOptions['username'] = username.text
    @user = username.text
  end

  # Action qui s'exécute lorsque l'on sauvegarde les options actuelles,
  # ouvre le fichier d'options, et écrit dedans le contenu du hashOptions
  def on_enregistre_button_clicked
    puts 'Options sauvegarde'
    fichier = File.open('../data/options.json', 'w')
    fichier.write(JSON.dump(@hashOptions))
    fichier.close
  end

  # Affiche le nom, la résolution et la langue
  def to_s
    "Username : #{@user} \nResolution : #{(9 * @ratio.to_i)}p \nLangue : #{@langue}\n"
  end
end
