require 'gtk3'
load 'Donnees.rb'
load 'Plateau.rb'

##
# La Classe PlateauInterface permet de gérer l'affichage de la zone de jeu.
#
# ==== Variables d'instance
#
# * @fenetre => la fenêtre du jeu
# * @mode => le mode choisis par l'utilisateur
# * @difficulte => la difficulté choisis par l'utilisateur
# * @niveau => la map choisis par l'utilisateur
# * @sens_popover
# * @fini_dialog
# * @map
# * @fini_label
# * @matrixPix => Matrice de buffer pour pouvoir utilisé des images
# * @matrixImg => Matrice d'images
# * @donnee
# * @tab_events
# * @x
# * @y
#
class PlateauInterface < Gtk::Fixed

  # Méthode d'initialisation de la classe
  #
  # ==== Attributs
  #
  # * +fenetre+ - la fenêtre du jeu
  # * +map+
  # * +sens_popover+
  # * +fini_dialog+
  # * +fini_label+
  # * +mode+ - le mode de jeu
  # * +difficulte+ - la difficulté de jeu
  # * +niveau+
  #
  def initialize(fenetre, map, sens_popover, fini_dialog, fini_label, mode, difficulte, niveau)
    super()
    @fenetre = fenetre
    @sens_popover = sens_popover
    @fini_dialog = fini_dialog
    @map = map
    @mode = mode
    @difficulte = difficulte
    @niveau = niveau
    @fini_label = fini_label

    @matrixPix = []
    @matrixImg = []
    @donnee = Donnees.new
    @events = []
    @tab_events = []

    @donnee.getMatrice(@map.fichierJeu)

    create_imgs
    put_img(@tab_events)

    if !@map.coups.empty?
      @map.coups.each do |i|
        if i.estHorizontal?
          afficher_pont('horizontal', i.pont.x, i.pont.y)
        else
          afficher_pont('vertical', i.pont.x, i.pont.y)
        end
      end
    end
  end

  # Méthode qui place les liens au bon endroit vers les images en fonction du niveau
  def create_imgs
    numbers = []

    (0...@donnee.y).each do |i|
      (0...@donnee.x).each do |j|
        @matrixPix.push("Img_#{i}_#{j}")
        @events.push("eventImg_#{i}_#{j}")
        numbers.push(@donnee.matrix[i][j])
      end
    end

    @events.each do |name|
      @tab_events << instance_variable_set("@#{name}", Gtk::EventBox.new)
    end

    (0...@matrixPix.length).each do |i|
      pixbuf = GdkPixbuf::Pixbuf.new(file: "../data/img/#{numbers[i]}.png")
      image = Gtk::Image.new(pixbuf: pixbuf)
      image.set_name(@matrixPix[i])
      @tab_events[i].add(image)

      @tab_events[i].signal_connect 'button-press-event' do |widget, event|
        if @difficulte != 'tutoriel'
          if @map.chrono.chrono <= 0
            fin_chrono
          end
        end

        tmp = widget.child.name.split('_')
        @x = tmp[1].to_i
        @y = tmp[2].to_i

        case event.button
        when 1
          @click = true
        when 3
          @click = false
        end

        sens = @map.jouerCoupInterface(@x, @y, @click)

        @sens_popover.set_relative_to(widget)

        jouer_afficher_pont(sens, @x, @y, @click)
      end

      @tab_events[i].signal_connect "enter-notify-event" do |widget, event|
        if @difficulte != 'tutoriel'
          if @map.chrono.chrono <= 0
            fin_chrono
          end
        end

        tmp = widget.child.name.split('_')
        x = tmp[1].to_i
        y = tmp[2].to_i

        actualiserPontAjoutables(@map.plateau.getCase(x, y), x, y, true)
      end

      @tab_events[i].signal_connect "leave-notify-event" do |widget, event|
        if @difficulte != 'tutoriel'
          if @map.chrono.chrono <= 0
            fin_chrono
          end
        end

        tmp = widget.child.name.split('_')
        x = tmp[1].to_i
        y = tmp[2].to_i

        actualiserPontAjoutables(@map.plateau.getCase(x, y), x, y, false)
      end
    end
  end

  # Méthode qui met l'image au bon endroit dans l'interface GTK
  #
  # ==== Attributs
  #
  # * +coups+ - tableau
  #
  def put_img(coups)
    xl = 0
    yl = 0
    cpt = 0

    (0...@donnee.x * @donnee.y).each do |i|
      put coups[i], xl, yl
      xl += 50
      cpt += 1
      if cpt == @donnee.x
        yl += 50
        xl = 0
        cpt = 0
      end
    end
  end

  # Méthode qui permet de jouer un coup dans le sens donné en paramètre
  #
  # ==== Attributs
  #
  # * +sens+ - le sens à utiliser
  #
  def set_sens(sens)
    jouer_afficher_pont(sens, @x, @y, @click)
    @sens_popover.popdown
  end

  # Méthode qui joue un coup en fonction d'un sens, de sa position et du type de click
  #
  # ==== Attributs
  #
  # * +sens+ - le sens à utiliser
  # * +x+ - la position x
  # * +y+ - la position y
  # * +click+ - le type de click fait par l'utilisateur
  #
  def jouer_afficher_pont(sens, x, y, click)

    case sens
    when 'vertical'
      bool = @map.jouerCoupVerticaleInterface(x, y, click)

      if bool
        nb_ponts = @map.plateau.getCase(x, y).element.nb_ponts
        while @map.plateau.getCase(x, y).element.estPont?
          x += 1
        end

        afficher_ile_pleine(x, y)

        x -= 1

        while @map.plateau.getCase(x, y).element.estPont?
          changer_image(nb_ponts, 'V', x, y)

          x -= 1
        end

        afficher_ile_pleine(x, y)
      end

      @fenetre.show_all
      @map.afficherPlateau
    when 'horizontal'
      bool = @map.jouerCoupHorizontaleInterface(x, y, click)

      if bool
        nb_ponts = @map.plateau.getCase(x, y).element.nb_ponts
        while @map.plateau.getCase(x, y).element.estPont?
          y += 1
        end

        afficher_ile_pleine(x, y)

        y -= 1

        while @map.plateau.getCase(x, y).element.estPont?
          changer_image(nb_ponts, 'H', x, y)

          y -= 1
        end

        afficher_ile_pleine(x, y)

        @fenetre.show_all
        @map.afficherPlateau
      end
    when false
      @sens_popover.popup
    end

    if @map.plateau.partieFini?
      if @difficulte != 'tutoriel'
        @map.chrono.stopperChrono
        @fini_dialog.set_title('Gagné !')
        @fini_label.set_text("Bravo !\nVous avez fini le niveau #{@niveau} en mode #{@mode} en difficulte #{@difficulte} \nVotre temps est de #{@map.chrono.chrono} et votre score est de #{@map.score} ")
      end

      set_sensitive(false)
      @fini_dialog.run
    end
  end

  # Méthode qui change le type d'image en fonction de la situation (mode hypothèse, affichage des erreurs, ect) et du nombre de pont
  #
  # ==== Attributs
  #
  # * +nb_ponts+ - le nombre de pont
  # * +sens+ - le sens à utiliser
  # * +x+ - la position x
  # * +y+ - la position y
  #
  def changer_image(nb_ponts, sens, x, y)
    if @map.hypothese == true
      sens = "H#{sens}"
    end

    if @map.plateau.getCase(x, y).element.erreur
      sens = "E#{sens}"
    end

    case nb_ponts
    when 0
      pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/0.png')
      image = Gtk::Image.new(pixbuf: pixbuf)
      image.set_name("Img_#{x}_#{y}")
    when 1
      pixbuf = GdkPixbuf::Pixbuf.new(file: "../data/img/pont#{sens}1.png")
      image = Gtk::Image.new(pixbuf: pixbuf)
      image.set_name("p1h_#{x}_#{y}")
    when 2
      pixbuf = GdkPixbuf::Pixbuf.new(file: "../data/img/pont#{sens}2.png")
      image = Gtk::Image.new(pixbuf: pixbuf)
      image.set_name("p2h_#{x}_#{y}")
    end

    @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
    @tab_events[@map.plateau.y * x + y].child = image
  end

  # Méthode qui change l'image de l'île si elle est pleine
  #
  # ==== Attributs
  #
  # * +x+ - la position x de l'île
  # * +y+ - la position y de l'île
  #
  def afficher_ile_pleine(x, y)
    valeur = @map.plateau.getCase(x, y).element.valeur

    if @map.plateau.getCase(x, y).element.estFini?
      pixbuf = GdkPixbuf::Pixbuf.new(file: "../data/img/#{valeur.to_s}Pleine.png")
    else
      pixbuf = GdkPixbuf::Pixbuf.new(file: "../data/img/#{valeur.to_s}.png")
    end

    image = Gtk::Image.new(pixbuf: pixbuf)
    image.set_name("Img_#{x}_#{y}")
    @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
    @tab_events[@map.plateau.y * x + y].child = image
  end

  # Méthode qui affiche les ponts à partir d'un sens et de la position
  #
  # ==== Attributs
  #
  # * +sens+ - le sens à utiliser
  # * +x+ - la position x
  # * +y+ - la position y
  #
  def afficher_pont(sens, x, y)

    nb_ponts = @map.plateau.getCase(x, y).element.nb_ponts
    case sens
    when 'vertical'
      while @map.plateau.getCase(x, y).element.estPont?
        x += 1
      end

      afficher_ile_pleine(x, y)

      x -= 1

      while @map.plateau.getCase(x, y).element.estPont?
        changer_image(nb_ponts, 'V', x, y)

        x -= 1
      end

      afficher_ile_pleine(x, y)
    when 'horizontal'
      while @map.plateau.getCase(x, y).element.estPont?
        y += 1
      end

      afficher_ile_pleine(x, y)

      y -= 1

      while @map.plateau.getCase(x, y).element.estPont?
        changer_image(nb_ponts, 'H', x, y)

        y -= 1
      end

      afficher_ile_pleine(x, y)
    end

    @fenetre.show_all
    @map.afficherPlateau
  end

  # Méthode qui permet l'actualisation de la prévisualisation des ponts possibles
  #
  # ==== Attributs
  #
  # * +caseCourante+ - le sens à utiliser
  # * +unX+ - la position x
  # * +unY+ - la position y
  # * +unBool+ - un booléen
  #
  def actualiserPontAjoutables(caseCourante, unX, unY, unBool)
    nbPonts = caseCourante.pontAjoutables
    pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/0.png')
    x = unX
    y = unY
    if nbPonts - 1000 >= 0
      nbPonts -= 1000
      x += 1
      while @map.plateau.getCase(x, y).element.estPont?
        if unBool
          pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontPV1.png')
        end
        @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
        image = Gtk::Image.new(pixbuf: pixbuf)
        image.set_name("Img_#{x}_#{y}")
        @tab_events[@map.plateau.y * x + y].child = image
        x += 1
      end
    end

    x = unX
    y = unY
    if nbPonts - 100 >= 0
      nbPonts -= 100
      x -= 1
      while @map.plateau.getCase(x, y).element.estPont?
        if unBool
          pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontPV1.png')
        end
        @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
        image = Gtk::Image.new(pixbuf: pixbuf)
        image.set_name("Img_#{x}_#{y}")
        @tab_events[@map.plateau.y * x + y].child = image
        x -= 1
      end
    end

    x = unX
    y = unY
    if nbPonts - 10 >= 0
      nbPonts -= 10
      y -= 1
      while @map.plateau.getCase(x, y).element.estPont?
        if unBool
          pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontPH1.png')
        end
        @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
        image = Gtk::Image.new(pixbuf: pixbuf)
        image.set_name("Img_#{x}_#{y}")
        @tab_events[@map.plateau.y * x + y].child = image
        y -= 1
      end
    end

    x = unX
    y = unY
    if nbPonts - 1 >= 0
      nbPonts -= 1
      y += 1
      while @map.plateau.getCase(x, y).element.estPont?
        if unBool
          pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontPH1.png')
        end
        @tab_events[@map.plateau.y * x + y].remove(@tab_events[@map.plateau.y * x + y].child)
        image = Gtk::Image.new(pixbuf: pixbuf)
        image.set_name("Img_#{x}_#{y}")
        @tab_events[@map.plateau.y * x + y].child = image
        y += 1
      end
    end

    @fenetre.show_all

    if @map.plateau.partieFini?
      if @difficulte != 'tutoriel'
        @fini_dialog.set_title('Gagné !')
        @fini_label.set_text("Bravo !\nVous avez fini le niveau #{@niveau} en mode #{@mode} en difficulte #{@difficulte} \nVotre temps est de #{'%.1f' % @map.chrono.chrono}s et votre score est de #{@map.score.to_i}")
        @map.sauvegarder_score
        @map.chrono.stopperChrono
      end

      set_sensitive(false)
      @fini_dialog.run
    end
  end

  # Méthode qui permet de faire un redo sur le jeu
  def refaire
    case_redo = @map.refaire

    unless case_redo.nil?
      @map.afficherPlateau

      if case_redo.element.sensHorizontal
        afficher_pont('horizontal', case_redo.x, case_redo.y)
      else
        afficher_pont('vertical', case_redo.x, case_redo.y)
      end
    end
  end

  # Méthode qui permet de faire un undo sur le jeu
  def annuler
    case_undo = @map.annuler

    unless case_undo.nil?
      @map.afficherPlateau

      if case_undo.element.sensHorizontal
        afficher_pont('horizontal', case_undo.x, case_undo.y)
      else
        afficher_pont('vertical', case_undo.x, case_undo.y)
      end
    end
  end

  # Méthode qui permet de lancer la correction d'erreur
  def corrigerErreur
    @map.corrigerErreur
    @map.afficherPlateau
    actualiserAffichage
  end

  # Méthode qui permet de lancer l'affichage des erreurs
  def afficherErreur
    @map.afficherPontErreur
    @map.coups.each do |c|
      if c.pont.element.erreur
        afficher_pont(c.sens, c.pont.x, c.pont.y)
      end
    end
  end

  # Méthode qui permet l'actualisation de l'affichage du jeu
  def actualiserAffichage
    (0...@donnee.x).each do |i|
      (0...@donnee.y).each do |j|
        if @tab_events[@map.plateau.y * j + i].child.name.match(/^Img/)
          if @map.plateau.getCase(j, i).element.estIle?
            unless @map.plateau.getCase(j, i).element.estFini?
              afficher_ile_pleine(j, i);
            end
          end
        end

        if @tab_events[@map.plateau.y * j + i].child.name.match(/^p2/)
          if @map.plateau.getCase(j, i).element.estPont?
            if @map.plateau.getCase(j, i).element.nb_ponts <= 1
              @tab_events[@map.plateau.y * j + i].remove(@tab_events[@map.plateau.y * j + i].child)
              if @map.plateau.getCase(j, i).element.estVertical?
                pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontV1.png')
                image = Gtk::Image.new(pixbuf: pixbuf)
                image.set_name("p1v_#{j}_#{i}")
              else
                pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/pontH1.png')
                image = Gtk::Image.new(pixbuf: pixbuf)
                image.set_name("p1h_#{j}_#{i}")
              end
              @tab_events[@map.plateau.y * j + i].child = image
            end
          end
        end

        if @tab_events[@map.plateau.y * j + i].child.name.match(/^p1/)
          if @map.plateau.getCase(j, i).element.estPont?
            if @map.plateau.getCase(j, i).element.nb_ponts == 0
              @tab_events[@map.plateau.y * j + i].remove(@tab_events[@map.plateau.y * j + i].child)
              pixbuf = GdkPixbuf::Pixbuf.new(file: '../data/img/0.png')
              image = Gtk::Image.new(pixbuf: pixbuf)
              image.set_name("Img_#{j}_#{i}")
              @tab_events[@map.plateau.y * j + i].child = image
            end
          end
        end
      end
    end

    @fenetre.show_all
  end

  def fin_chrono
    set_sensitive(false)
    @fini_dialog.set_title('Dommage !')
    @fini_label.set_text("Vous n'avez pas reussi a finir le niveau #{@niveau} à temps.")
    @fini_dialog.run
  end

end
