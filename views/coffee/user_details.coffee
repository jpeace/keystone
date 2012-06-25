titan.presenter class UserDetailsPresenter extends titan.classes.Presenter
  loadClicked: =>
    __.loadById 5, (data) =>
      @view.bind(data);