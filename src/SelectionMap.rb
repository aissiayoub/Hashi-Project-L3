load 'Plateau.rb'
load 'Genie.rb'
load 'ContreLaMontre.rb'
load 'Normal.rb'
load 'Jeu.rb'
load 'JeuTutoriel.rb'

##
# La Classe SelectionMap permet d'afficher la fenêtre de séléction de maps.
#
# On peut cliquer sur un des choix, on peut choisir une des maps disponibles, pour jouer, ou recommencer la partie
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @ratio => la taille de la fenêtre
# * @mode => le mode choisis par l'utilisateur
# * @difficulte => la difficulté choisis par l'utilisateur
# * @niveau => la map choisis par l'utilisateur
# * @selection_map_box => la box qui contient les boutons et permet l'affichage de la fenêtre
# * @retour_button => bouton retour permettant de retourner sur la séléction de difficulté ou sur le menu principal (si on est en mode tutoriel)
# * @user => nom d'utilisateur extrait du hashOptions
# * @fichier_options => fichier contenant les dernières options enregistrer
# * @hashOptions => objet qui récupère les données du fichier_options
# * @jouer_button => bouton jouer permettant de lancer (ou continuer si il y a une sauvegarde) une partie de jeu
# * @recommencer_button => bouton recommencer permettant de lancer une nouvelle partie de jeu si une sauvegarde est présente
#
class SelectionMap < Gtk::Builder

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +ratio+ - la taille de la fenêtre
  # * +mode+ - le mode de jeu
  # * +difficulte+ - la difficulté de jeu
  #
  def initialize(fenetre, ratio, mode, difficulte)
    super()
    add_from_file('../data/glade/SelectionMap.glade')
    @ratio = ratio
    @difficulte = difficulte
    @mode = mode
    @fenetre = fenetre

    @fichier_options = File.read('../data/options.json')
    @hashOptions = JSON.parse(@fichier_options)
    @user = @hashOptions['username']

    objects.each do |p|
      unless p.builder_name.start_with?('___object')
        instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
      end
    end

    @fenetre.set_title('Hashi - Selection de la map')

    @jouer_button.set_sensitive(false)
    @recommencer_button.set_sensitive(false)

    if @mode != 'tutoriel'
      @titre_label.set_text("Choix de la map en mode #{@mode}, difficulté #{@difficulte}")

      @selection_map_scrolled.set_min_content_height(450 * @ratio)

      @retour_button.set_size_request(-1, 50 * @ratio)
      @jouer_button.set_size_request(-1, 25 * @ratio)
      @recommencer_button.set_size_request(-1, 25 * @ratio)

      dir = "../data/map/#{@difficulte}/demarrage"
      nb_niv = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }

      model = Gtk::TreeStore.new(String, String, String)

      p = Plateau.creer

      (1..nb_niv).each do |i|
        root_iter = model.append(nil)

        p.generateMatrice("#{dir}/#{i}.txt")

        root_iter[0] = "Niveau #{i}"
        root_iter[1] = "#{p.x} * #{p.y}"

        begin
          f = File.open(File.expand_path("../data/sauvegarde/#{@user}_#{@mode}_#{@difficulte}_#{i.to_s}.bn"), 'r')
          root_iter[2] = 'Sauvegarde disponible'
          f.close
        rescue StandardError => e
          root_iter[2] = 'Sauvegarde non disponible'
        end
      end

      tv = Gtk::TreeView.new(model)

      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('Niveau', renderer, {
        :text => 0
      })

      tv.append_column(column)

      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('Taille', renderer, {
        :text => 1
      })

      tv.append_column(column)

      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('Sauvegarde', renderer, {
        :text => 2
      })

      tv.append_column(column)

      tv.activate_on_single_click = true

      tv.signal_connect('row-activated') do |widget, niveau|
        @jouer_button.set_sensitive(true)
        @niveau = niveau.to_s.to_i + 1

        begin
          f = File.open(File.expand_path("../data/sauvegarde/#{@user}_#{@mode}_#{@difficulte}_#{@niveau.to_s}.bn"), 'r')
          @recommencer_button.set_sensitive(true)
          @jouer_button.set_label('Charger la sauvegarde')
          f.close
        rescue StandardError
          @jouer_button.set_label('Jouer')
          @recommencer_button.set_sensitive(false)
        end
      end
    else
      @titre_label.set_text("Choix de la map en mode #{@mode}")

      @selection_map_scrolled.set_min_content_height(450 * @ratio)

      @retour_button.set_size_request(-1, 50 * @ratio)
      @jouer_button.set_size_request(-1, 25 * @ratio)
      @recommencer_button.set_size_request(-1, 25 * @ratio)

      dir = "../data/map/#{@difficulte}/demarrage"
      nb_niv = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }

      model = Gtk::TreeStore.new(String, String)

      p = Plateau.creer

      (1..nb_niv).each do |i|
        root_iter = model.append(nil)

        p.generateMatrice("#{dir}/#{i}.txt")

        root_iter[0] = "Tutoriel n°#{i}"
        root_iter[1] = "#{p.x} * #{p.y}"
      end

      tv = Gtk::TreeView.new(model)

      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('Tutoriel', renderer, {
        :text => 0
      })

      tv.append_column(column)

      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new('Taille', renderer, {
        :text => 1
      })

      tv.append_column(column)

      tv.activate_on_single_click = true

      tv.signal_connect('row-activated') do |widget, niveau|
        @jouer_button.set_sensitive(true)
        @niveau = niveau.to_s.to_i + 1
      end
    end

    @selection_map_scrolled.add(tv)

    connect_signals do |handler|
      method(handler)
    rescue StandardError
      puts "#{handler} n'est pas encore implementer !"
    end

    @fenetre.add(@selection_map_box)
    @fenetre.show_all
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton retour,
  # ferme la box de séléction de map et affiche la box de séléction de difficulté ou la box du menue principal (si en mode tutoriel)
  def on_retour_button_clicked
    @fenetre.remove(@selection_map_box)
    @fenetre.resize(1280 * @ratio, 720 * @ratio)

    if @mode == 'tutoriel'
      SelectionMode.new(@fenetre, @ratio)
    else
      SelectionDifficulte.new(@fenetre, @ratio, @mode)
    end
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton jouer,
  # ferme la box de séléction de map et lance ou continue une partie avec le mode, la difficulté, et le niveau choisis
  def on_jouer_button_clicked

    if @mode == 'tutoriel'
      map = Genie.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)

      map.initialiserJeu

      @fenetre.remove(@selection_map_box)
      JeuTutoriel.new(@fenetre, @ratio, @mode, @difficulte, map, @niveau.to_s)
    else
      case @mode
      when 'genie'
        map = Genie.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
      when 'normal'
        map = Normal.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
      when 'contre la montre'
        map = ContreLaMontre.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
      end

      map.initialiserJeu

      begin
        f = File.open(File.expand_path("../data/sauvegarde/#{@user}_#{@mode}_#{@difficulte}_#{@niveau.to_s}.bn"), 'r')
        map = map.charger(@mode)
        f.close
      rescue StandardError
      end

      @fenetre.remove(@selection_map_box)
      Jeu.new(@fenetre, @ratio, @mode, @difficulte, map, @niveau.to_s)
    end
  end

  # Action qui s'exécute lorsque l'on clique sur le bouton recommencer,
  # ferme la box de séléction de map et lance une partie avec le mode, la difficulté, et le niveau choisis
  def on_recommencer_button_clicked
    case @mode
    when 'genie'
      map = Genie.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
    when 'normal'
      map = Normal.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
    when 'contre la montre'
      map = ContreLaMontre.creer(Plateau.creer, @niveau.to_s, @user, @difficulte)
    end

    @fenetre.remove(@selection_map_box)

    map.initialiserJeu

    Jeu.new(@fenetre, @ratio, @mode, @difficulte, map, @niveau.to_s)
  end

end
